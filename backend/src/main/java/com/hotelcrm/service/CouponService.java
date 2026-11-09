package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Coupon;
import com.hotelcrm.domain.enums.DiscountType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.repository.CouponRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CouponService {

    private final CouponRepository couponRepository;
    private final HotelRepository hotelRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;

    @Transactional(readOnly = true)
    public List<OpsDtos.CouponResponse> list(Long hotelId) {
        accessService.assertPermission(Permission.BOOKING_READ);
        Long scope = accessService.requireHotel(hotelId);
        return couponRepository.findForHotel(scope).stream().map(this::toResponse).toList();
    }

    @Transactional
    public OpsDtos.CouponResponse create(OpsDtos.CouponRequest request) {
        accessService.assertPermission(Permission.COUPON_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        couponRepository.findByCodeIgnoreCase(request.code().trim()).ifPresent(existing -> {
            throw new BusinessException("Coupon code " + request.code() + " already exists");
        });
        Coupon coupon = Coupon.builder()
                .hotel(hotelRepository.findById(request.hotelId()).orElse(null))
                .code(request.code().trim().toUpperCase())
                .description(request.description())
                .discountType(request.discountType())
                .value(MoneyUtils.scale(request.value()))
                .minAmount(MoneyUtils.scale(request.minAmount()))
                .maxDiscount(request.maxDiscount() == null ? null : MoneyUtils.scale(request.maxDiscount()))
                .validFrom(request.validFrom())
                .validTo(request.validTo())
                .usageLimit(request.usageLimit())
                .usedCount(0)
                .active(request.active() == null || request.active())
                .build();
        couponRepository.save(coupon);
        auditService.record(request.hotelId(), "COUPON_CREATED", "Coupon", coupon.getId(),
                "Coupon " + coupon.getCode() + " created");
        return toResponse(coupon);
    }

    @Transactional
    public OpsDtos.CouponResponse update(Long id, OpsDtos.CouponRequest request) {
        accessService.assertPermission(Permission.COUPON_WRITE);
        Coupon coupon = couponRepository.findById(id).orElseThrow(() -> NotFoundException.of("Coupon", id));
        accessService.assertHotelAccess(request.hotelId());
        coupon.setDescription(request.description());
        coupon.setDiscountType(request.discountType());
        coupon.setValue(MoneyUtils.scale(request.value()));
        coupon.setMinAmount(MoneyUtils.scale(request.minAmount()));
        coupon.setMaxDiscount(request.maxDiscount() == null ? null : MoneyUtils.scale(request.maxDiscount()));
        coupon.setValidFrom(request.validFrom());
        coupon.setValidTo(request.validTo());
        coupon.setUsageLimit(request.usageLimit());
        if (request.active() != null) {
            coupon.setActive(request.active());
        }
        couponRepository.save(coupon);
        return toResponse(coupon);
    }

    @Transactional
    public void delete(Long id) {
        accessService.assertPermission(Permission.COUPON_WRITE);
        Coupon coupon = couponRepository.findById(id).orElseThrow(() -> NotFoundException.of("Coupon", id));
        if (coupon.getUsedCount() > 0) {
            coupon.setActive(false);
            couponRepository.save(coupon);
            return;
        }
        couponRepository.delete(coupon);
    }

    @Transactional(readOnly = true)
    public BigDecimal validateForBooking(String code, Long hotelId, BigDecimal amount) {
        Coupon coupon = couponRepository.findByCodeIgnoreCase(code)
                .orElseThrow(() -> new BusinessException("Coupon " + code + " is not valid"));
        if (!Boolean.TRUE.equals(coupon.getActive()) || (coupon.getValidTo() != null
                && LocalDate.now().isAfter(coupon.getValidTo()))) {
            throw new BusinessException("This coupon has expired");
        }
        return coupon.getDiscountType() == DiscountType.PERCENTAGE
                ? MoneyUtils.percentOf(amount, coupon.getValue())
                : coupon.getValue();
    }

    private OpsDtos.CouponResponse toResponse(Coupon coupon) {
        return new OpsDtos.CouponResponse(coupon.getId(),
                coupon.getHotel() == null ? null : coupon.getHotel().getId(), coupon.getCode(),
                coupon.getDescription(), coupon.getDiscountType().name(), coupon.getValue(),
                coupon.getMinAmount(), coupon.getMaxDiscount(), coupon.getValidFrom(), coupon.getValidTo(),
                coupon.getUsageLimit(), coupon.getUsedCount(), Boolean.TRUE.equals(coupon.getActive()));
    }
}
