package com.hotelcrm.service;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Guest;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.enums.GuestCategory;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.dto.BookingDtos;
import com.hotelcrm.dto.GuestDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.GuestFeedbackRepository;
import com.hotelcrm.repository.GuestRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.PaymentRepository;
import com.hotelcrm.repository.ServiceOrderRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.FieldCipher;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class GuestService {

    private final GuestRepository guestRepository;
    private final HotelRepository hotelRepository;
    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final GuestFeedbackRepository feedbackRepository;
    private final ServiceOrderRepository serviceOrderRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final UserDirectoryService userDirectoryService;

    @Transactional(readOnly = true)
    public PageResponse<GuestDtos.Response> search(String term, GuestCategory category, Boolean vip,
                                                   Long hotelId, int page, int size) {
        accessService.assertPermission(Permission.GUEST_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        List<Long> guestIds = accessService.isSuperAdmin() && hotelId == null
                ? List.of() : bookingRepository.findGuestIdsForHotels(scope);

        Specification<Guest> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (!accessService.isSuperAdmin()) {
                if (guestIds.isEmpty()) {
                    predicates.add(cb.disjunction());
                } else {
                    predicates.add(root.get("id").in(guestIds));
                }
            }
            if (term != null && !term.isBlank()) {
                String like = "%" + term.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("fullName")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("mobile"), "")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("email"), "")), like)));
            }
            if (category != null) {
                predicates.add(cb.equal(root.get("category"), category));
            }
            if (vip != null) {
                predicates.add(cb.equal(root.get("vip"), vip));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        Page<Guest> result = guestRepository.findAll(spec,
                PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100), Sort.by("fullName")));
        return PageResponse.of(result, this::toResponse);
    }

    @Transactional(readOnly = true)
    public GuestDtos.Detail get(Long id) {
        accessService.assertPermission(Permission.GUEST_READ);
        Guest guest = requireGuest(id);
        assertGuestVisible(guest);
        List<BookingDtos.Summary> bookings = bookingRepository.findByGuestIdOrderByCheckInDateDesc(id).stream()
                .map(BookingDtos.Summary::from).toList();
        List<PaymentDtos.Response> payments = paymentRepository.findByBookingGuestIdOrderByPaidAtDesc(id).stream()
                .map(p -> PaymentDtos.Response.from(p, userDirectoryService.nameOf(p.getReceivedBy()))).toList();
        List<OpsDtos.FeedbackRow> feedback = feedbackRepository.findByGuestIdOrderByCreatedAtDesc(id).stream()
                .map(OpsDtos.FeedbackRow::from).toList();
        List<OpsDtos.ServiceOrderResponse> services = serviceOrderRepository
                .findByGuestIdOrderByOrderedAtDesc(id).stream()
                .map(OpsDtos.ServiceOrderResponse::from).toList();
        return new GuestDtos.Detail(toResponse(guest), bookings, payments, feedback, services);
    }

    @Transactional
    public GuestDtos.Response create(GuestDtos.Request request) {
        accessService.assertPermission(Permission.GUEST_WRITE);
        Hotel hotel = null;
        if (request.hotelId() != null) {
            accessService.assertHotelAccess(request.hotelId());
            hotel = hotelRepository.findById(request.hotelId()).orElse(null);
        }
        guestRepository.findByMobile(request.mobile().trim()).ifPresent(existing -> {
            throw new BusinessException("A guest with mobile " + request.mobile()
                    + " already exists (" + existing.getFullName() + ")");
        });
        Guest guest = Guest.builder()
                .hotel(hotel)
                .fullName(request.fullName().trim())
                .mobile(request.mobile().trim())
                .email(request.email())
                .address(request.address())
                .city(request.city())
                .state(request.state())
                .country(request.country())
                .idProofType(request.idProofType())
                .idProofNumber(request.idProofNumber())
                .idProofLast4(FieldCipher.last4(request.idProofNumber()))
                .category(request.category() == null ? GuestCategory.REGULAR : request.category())
                .vip(Boolean.TRUE.equals(request.vip()))
                .blacklisted(Boolean.TRUE.equals(request.blacklisted()))
                .notes(request.notes())
                .specialRequests(request.specialRequests())
                .loyaltyPoints(0)
                .build();
        guestRepository.save(guest);
        auditService.record(hotel == null ? null : hotel.getId(), "GUEST_CREATED", "Guest", guest.getId(),
                "Guest " + guest.getFullName() + " created");
        return toResponse(guest);
    }

    @Transactional
    public GuestDtos.Response update(Long id, GuestDtos.Request request) {
        accessService.assertPermission(Permission.GUEST_WRITE);
        Guest guest = requireGuest(id);
        assertGuestVisible(guest);
        guestRepository.findByMobile(request.mobile().trim()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new BusinessException("Another guest already uses mobile " + request.mobile());
            }
        });
        guest.setFullName(request.fullName().trim());
        guest.setMobile(request.mobile().trim());
        guest.setEmail(request.email());
        guest.setAddress(request.address());
        guest.setCity(request.city());
        guest.setState(request.state());
        guest.setCountry(request.country());
        if (request.idProofType() != null) {
            guest.setIdProofType(request.idProofType());
        }
        if (request.idProofNumber() != null && !request.idProofNumber().isBlank()) {
            guest.setIdProofNumber(request.idProofNumber());
            guest.setIdProofLast4(FieldCipher.last4(request.idProofNumber()));
        }
        if (request.category() != null) {
            guest.setCategory(request.category());
        }
        if (request.vip() != null) {
            guest.setVip(request.vip());
        }
        if (request.blacklisted() != null) {
            guest.setBlacklisted(request.blacklisted());
        }
        guest.setNotes(request.notes());
        guest.setSpecialRequests(request.specialRequests());
        guestRepository.save(guest);
        auditService.record(guest.getHotel() == null ? null : guest.getHotel().getId(), "GUEST_UPDATED",
                "Guest", guest.getId(), "Guest " + guest.getFullName() + " updated");
        return toResponse(guest);
    }

    @Transactional(readOnly = true)
    public Guest requireGuest(Long id) {
        return guestRepository.findById(id).orElseThrow(() -> NotFoundException.of("Guest", id));
    }

    private GuestDtos.Response toResponse(Guest guest) {
        long totalBookings = bookingRepository.countByGuestId(guest.getId());
        long completed = bookingRepository.countByGuestIdAndStatus(guest.getId(),
                com.hotelcrm.domain.enums.BookingStatus.CHECKED_OUT);
        BigDecimal spending = bookingRepository.sumPaidByGuest(guest.getId());
        BigDecimal outstanding = bookingRepository.sumPendingByGuest(guest.getId());
        java.time.LocalDate lastStay = bookingRepository.findLastStayDate(guest.getId());
        GuestDtos.Response base = GuestDtos.Response.from(guest);
        return new GuestDtos.Response(base.id(), base.fullName(), base.mobile(), base.email(), base.address(),
                base.city(), base.state(), base.country(), base.idProofType(), base.idProofMasked(),
                base.category(), base.vip(), base.blacklisted(), base.notes(), base.specialRequests(),
                base.loyaltyPoints(), totalBookings, completed, spending, outstanding, lastStay,
                base.createdAt(), base.hotelName());
    }

    private void assertGuestVisible(Guest guest) {
        if (accessService.isSuperAdmin()) {
            return;
        }
        boolean visible = guest.getHotel() != null && accessService.canAccessHotel(guest.getHotel().getId());
        if (!visible) {
            visible = !bookingRepository.findByGuestIdOrderByCheckInDateDesc(guest.getId()).isEmpty()
                    && bookingRepository.findByGuestIdOrderByCheckInDateDesc(guest.getId()).stream()
                    .anyMatch(b -> accessService.canAccessHotel(b.getHotel().getId()));
        }
        if (!visible) {
            throw new com.hotelcrm.common.exception.ForbiddenException("You do not have access to this guest");
        }
    }
}
