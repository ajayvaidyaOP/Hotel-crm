package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.entity.RoomCategory;
import com.hotelcrm.domain.entity.RoomPricing;
import com.hotelcrm.domain.enums.AdjustmentType;
import com.hotelcrm.dto.RoomDtos;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.RoomCategoryRepository;
import com.hotelcrm.repository.RoomPricingRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

/**
 * Rate engine: base rate -> weekend rate -> seasonal / holiday / promotional override.
 * The highest priority applicable rule wins; the resulting nightly rates are frozen into the
 * booking so later price changes never alter existing reservations.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PricingService {

    private final RoomPricingRepository pricingRepository;
    private final RoomRepository roomRepository;
    private final RoomCategoryRepository categoryRepository;
    private final HotelRepository hotelRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;

    public record StayPricing(int nights,
                              BigDecimal averageNightly,
                              BigDecimal roomTotal,
                              BigDecimal extraPersonTotal,
                              BigDecimal extraBedTotal,
                              BigDecimal total,
                              List<RoomDtos.NightlyRate> breakdown) {
    }

    /* ------------------------------ rate plans ------------------------------ */

    @Transactional(readOnly = true)
    public List<RoomDtos.RatePlanResponse> listPlans(Long hotelId) {
        accessService.assertHotelAccess(hotelId);
        return pricingRepository.findByHotelIdOrderByPriorityDesc(hotelId).stream()
                .map(RoomDtos.RatePlanResponse::from).toList();
    }

    @Transactional
    public RoomDtos.RatePlanResponse createPlan(Long hotelId, RoomDtos.RatePlanRequest request) {
        accessService.assertPermission(com.hotelcrm.domain.enums.Permission.PRICING_WRITE);
        accessService.assertHotelAccess(hotelId);
        Hotel hotel = hotelRepository.findById(hotelId).orElseThrow(() -> NotFoundException.of("Hotel", hotelId));
        validatePlanDates(request);
        RoomPricing plan = RoomPricing.builder()
                .hotel(hotel)
                .name(request.name().trim())
                .pricingType(request.pricingType())
                .adjustmentType(request.adjustmentType())
                .amount(MoneyUtils.scale(request.amount()))
                .startDate(request.startDate())
                .endDate(request.endDate())
                .daysOfWeek(request.daysOfWeek())
                .priority(request.priority() == null ? 10 : request.priority())
                .active(request.active() == null || request.active())
                .build();
        applyScope(plan, hotelId, request);
        pricingRepository.save(plan);
        auditService.record(hotelId, "RATE_PLAN_CREATED", "RoomPricing", plan.getId(),
                "Rate plan " + plan.getName() + " created");
        return RoomDtos.RatePlanResponse.from(plan);
    }

    @Transactional
    public RoomDtos.RatePlanResponse updatePlan(Long hotelId, Long planId, RoomDtos.RatePlanRequest request) {
        accessService.assertPermission(com.hotelcrm.domain.enums.Permission.PRICING_WRITE);
        accessService.assertHotelAccess(hotelId);
        RoomPricing plan = pricingRepository.findByIdAndHotelId(planId, hotelId)
                .orElseThrow(() -> NotFoundException.of("Rate plan", planId));
        validatePlanDates(request);
        plan.setName(request.name().trim());
        plan.setPricingType(request.pricingType());
        plan.setAdjustmentType(request.adjustmentType());
        plan.setAmount(MoneyUtils.scale(request.amount()));
        plan.setStartDate(request.startDate());
        plan.setEndDate(request.endDate());
        plan.setDaysOfWeek(request.daysOfWeek());
        plan.setPriority(request.priority() == null ? plan.getPriority() : request.priority());
        plan.setActive(request.active() == null || request.active());
        plan.setCategory(null);
        plan.setRoom(null);
        applyScope(plan, hotelId, request);
        pricingRepository.save(plan);
        auditService.record(hotelId, "RATE_PLAN_UPDATED", "RoomPricing", plan.getId(),
                "Rate plan " + plan.getName() + " updated");
        return RoomDtos.RatePlanResponse.from(plan);
    }

    @Transactional
    public void deletePlan(Long hotelId, Long planId) {
        accessService.assertPermission(com.hotelcrm.domain.enums.Permission.PRICING_WRITE);
        accessService.assertHotelAccess(hotelId);
        RoomPricing plan = pricingRepository.findByIdAndHotelId(planId, hotelId)
                .orElseThrow(() -> NotFoundException.of("Rate plan", planId));
        pricingRepository.delete(plan);
        auditService.record(hotelId, "RATE_PLAN_DELETED", "RoomPricing", planId, "Rate plan deleted");
    }

    /* ------------------------------- quoting -------------------------------- */

    @Transactional(readOnly = true)
    public RoomDtos.QuoteResponse quote(Long hotelId, RoomDtos.QuoteRequest request) {
        accessService.assertHotelAccess(hotelId);
        RoomCategory category = categoryRepository.findByIdAndHotelId(request.categoryId(), hotelId)
                .orElseThrow(() -> NotFoundException.of("Room category", request.categoryId()));
        Room room = null;
        if (request.roomId() != null) {
            room = roomRepository.findByIdAndHotelId(request.roomId(), hotelId)
                    .orElseThrow(() -> NotFoundException.of("Room", request.roomId()));
        }
        StayPricing pricing = computeStay(hotelId, room, category, request.checkIn(), request.checkOut(),
                request.adults() == null ? 1 : request.adults(),
                request.children() == null ? 0 : request.children(), 0);
        return new RoomDtos.QuoteResponse(category.getId(), category.getName(), request.checkIn(),
                request.checkOut(), pricing.nights(), pricing.averageNightly(), pricing.roomTotal(),
                pricing.extraPersonTotal(), pricing.total(), pricing.breakdown());
    }

    /** Nightly pricing for a stay. Rates are computed per calendar date and totalled. */
    @Transactional(readOnly = true)
    public StayPricing computeStay(Long hotelId, Room room, RoomCategory category, LocalDate from, LocalDate to,
                                   int adults, int children, int extraBeds) {
        if (!to.isAfter(from)) {
            throw new BusinessException("Check-out date must be after the check-in date");
        }
        long nights = ChronoUnit.DAYS.between(from, to);
        if (nights > 365) {
            throw new BusinessException("A single reservation cannot exceed 365 nights");
        }
        List<RoomPricing> plans = pricingRepository.findActiveByHotel(hotelId);
        List<RoomDtos.NightlyRate> breakdown = new ArrayList<>();
        BigDecimal roomTotal = BigDecimal.ZERO;
        for (int i = 0; i < nights; i++) {
            LocalDate date = from.plusDays(i);
            BigDecimal base = baseRate(room, category, date);
            AppliedRate applied = applyPlans(base, date, room, category, plans);
            breakdown.add(new RoomDtos.NightlyRate(date, applied.rate(), applied.planName()));
            roomTotal = roomTotal.add(applied.rate());
        }
        int capacity = room != null ? room.getMaxOccupancy()
                : category != null ? category.getMaxOccupancy() : 2;
        int extraPersons = Math.max(0, adults + children - capacity);
        BigDecimal perPerson = room != null && room.getExtraPersonCharge() != null
                ? room.getExtraPersonCharge() : category == null ? BigDecimal.ZERO : category.getExtraPersonCharge();
        BigDecimal extraPersonTotal = MoneyUtils.multiply(perPerson, BigDecimal.valueOf((long) extraPersons * nights));
        BigDecimal extraBedCharge = category == null ? BigDecimal.ZERO : category.getExtraBedCharge();
        BigDecimal extraBedTotal = MoneyUtils.multiply(extraBedCharge, BigDecimal.valueOf((long) extraBeds));
        BigDecimal total = MoneyUtils.add(roomTotal, extraPersonTotal, extraBedTotal);
        BigDecimal average = nights == 0 ? BigDecimal.ZERO : MoneyUtils.scale(
                roomTotal.divide(BigDecimal.valueOf(nights), 2, RoundingMode.HALF_UP));
        return new StayPricing((int) nights, average, MoneyUtils.scale(roomTotal),
                extraPersonTotal, extraBedTotal, total, breakdown);
    }

    private record AppliedRate(BigDecimal rate, String planName) {
    }

    private BigDecimal baseRate(Room room, RoomCategory category, LocalDate date) {
        BigDecimal base = room != null && room.getBasePrice() != null ? room.getBasePrice()
                : category == null ? BigDecimal.ZERO : category.getBasePrice();
        BigDecimal weekend = room != null && room.getWeekendPrice() != null ? room.getWeekendPrice()
                : category == null ? null : category.getWeekendPrice();
        if (isWeekend(date) && weekend != null) {
            return MoneyUtils.scale(weekend);
        }
        return MoneyUtils.scale(base);
    }

    private AppliedRate applyPlans(BigDecimal baseRate, LocalDate date, Room room, RoomCategory category,
                                   List<RoomPricing> plans) {
        RoomPricing best = plans.stream()
                .filter(plan -> Boolean.TRUE.equals(plan.getActive()))
                .filter(plan -> appliesToRoom(plan, room, category))
                .filter(plan -> appliesToDate(plan, date))
                .max(Comparator.comparingInt((RoomPricing p) -> specificity(p, room, category))
                        .thenComparingInt(p -> p.getPriority() == null ? 0 : p.getPriority()))
                .orElse(null);
        if (best == null) {
            return new AppliedRate(baseRate, null);
        }
        BigDecimal amount = best.getAmount() == null ? BigDecimal.ZERO : best.getAmount();
        BigDecimal rate = switch (best.getAdjustmentType()) {
            case FIXED -> amount;
            case PERCENTAGE -> baseRate.add(MoneyUtils.percentOf(baseRate, amount));
            case INCREMENT -> baseRate.add(amount);
        };
        if (rate.compareTo(BigDecimal.ZERO) < 0) {
            rate = BigDecimal.ZERO;
        }
        return new AppliedRate(MoneyUtils.scale(rate), best.getName());
    }

    private int specificity(RoomPricing plan, Room room, RoomCategory category) {
        if (plan.getRoom() != null && room != null && plan.getRoom().getId().equals(room.getId())) {
            return 2;
        }
        if (plan.getCategory() != null && category != null && plan.getCategory().getId().equals(category.getId())) {
            return 1;
        }
        return plan.getCategory() == null && plan.getRoom() == null ? 0 : -1;
    }

    private boolean appliesToRoom(RoomPricing plan, Room room, RoomCategory category) {
        if (plan.getRoom() != null) {
            return room != null && plan.getRoom().getId().equals(room.getId());
        }
        if (plan.getCategory() != null) {
            return category != null && plan.getCategory().getId().equals(category.getId());
        }
        return true;
    }

    private boolean appliesToDate(RoomPricing plan, LocalDate date) {
        if (plan.getStartDate() != null && date.isBefore(plan.getStartDate())) {
            return false;
        }
        if (plan.getEndDate() != null && date.isAfter(plan.getEndDate())) {
            return false;
        }
        String days = plan.getDaysOfWeek();
        if (days != null && !days.isBlank()) {
            String token = date.getDayOfWeek().name().substring(0, 3);
            return days.toUpperCase(Locale.ROOT).contains(token);
        }
        return true;
    }

    private boolean isWeekend(LocalDate date) {
        DayOfWeek day = date.getDayOfWeek();
        return day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY;
    }

    private void validatePlanDates(RoomDtos.RatePlanRequest request) {
        if (request.startDate() != null && request.endDate() != null
                && request.endDate().isBefore(request.startDate())) {
            throw new BusinessException("Rate plan end date cannot be before the start date");
        }
        if (request.adjustmentType() == AdjustmentType.PERCENTAGE
                && request.amount() != null
                && request.amount().abs().compareTo(BigDecimal.valueOf(100)) > 0) {
            throw new BusinessException("A percentage adjustment cannot exceed 100%");
        }
    }

    private void applyScope(RoomPricing plan, Long hotelId, RoomDtos.RatePlanRequest request) {
        if (request.roomId() != null) {
            Room room = roomRepository.findByIdAndHotelId(request.roomId(), hotelId)
                    .orElseThrow(() -> NotFoundException.of("Room", request.roomId()));
            plan.setRoom(room);
            plan.setCategory(room.getCategory());
        } else if (request.categoryId() != null) {
            RoomCategory category = categoryRepository.findByIdAndHotelId(request.categoryId(), hotelId)
                    .orElseThrow(() -> NotFoundException.of("Room category", request.categoryId()));
            plan.setCategory(category);
        }
    }
}
