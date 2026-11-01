package com.hotelcrm.service;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.ConflictException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.entity.BookingGuest;
import com.hotelcrm.domain.entity.BookingRoom;
import com.hotelcrm.domain.entity.Coupon;
import com.hotelcrm.domain.entity.Guest;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.HousekeepingTask;
import com.hotelcrm.domain.entity.Invoice;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.entity.RoomCategory;
import com.hotelcrm.domain.enums.BookingPaymentStatus;
import com.hotelcrm.domain.enums.BookingRoomStatus;
import com.hotelcrm.domain.enums.BookingSource;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.DiscountType;
import com.hotelcrm.domain.enums.GuestCategory;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.HousekeepingTaskStatus;
import com.hotelcrm.domain.enums.HousekeepingTaskType;
import com.hotelcrm.domain.enums.IdProofType;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.domain.enums.PaymentMethod;
import com.hotelcrm.domain.enums.PaymentType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.domain.enums.TaskPriority;
import com.hotelcrm.dto.BookingDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.BookingRoomRepository;
import com.hotelcrm.repository.CouponRepository;
import com.hotelcrm.repository.GuestRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.HousekeepingTaskRepository;
import com.hotelcrm.repository.InvoiceRepository;
import com.hotelcrm.repository.RoomCategoryRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.repository.ServiceOrderRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.CodeGenerator;
import com.hotelcrm.util.MoneyUtils;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
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
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Slf4j
@Service
@RequiredArgsConstructor
public class BookingService {

    static final List<BookingStatus> HOLDING_STATUSES =
            List.of(BookingStatus.PENDING, BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN);

    private final BookingRepository bookingRepository;
    private final BookingRoomRepository bookingRoomRepository;
    private final RoomRepository roomRepository;
    private final RoomCategoryRepository categoryRepository;
    private final GuestRepository guestRepository;
    private final HotelRepository hotelRepository;
    private final CouponRepository couponRepository;
    private final InvoiceRepository invoiceRepository;
    private final ServiceOrderRepository serviceOrderRepository;
    private final HousekeepingTaskRepository housekeepingTaskRepository;
    private final PricingService pricingService;
    private final PaymentService paymentService;
    private final InvoiceService invoiceService;
    private final NotificationService notificationService;
    private final AuditService auditService;
    private final UserDirectoryService userDirectoryService;
    private final HotelAccessService accessService;
    private final DocumentService documentService;

    /* -------------------------------- create -------------------------------- */

    @Transactional
    public BookingDtos.Response create(BookingDtos.Request request) {
        accessService.assertPermission(Permission.BOOKING_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Hotel hotel = hotelRepository.findById(request.hotelId())
                .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId()));
        if (hotel.getStatus() != com.hotelcrm.domain.enums.HotelStatus.ACTIVE) {
            throw new BusinessException("This hotel is not active and cannot accept new reservations");
        }
        validateDates(request.checkInDate(), request.checkOutDate(), true);
        if (request.rooms() == null || request.rooms().isEmpty()) {
            throw new BusinessException("At least one room is required");
        }
        Guest guest = resolveGuest(request, hotel);
        if (Boolean.TRUE.equals(guest.getBlacklisted()) || guest.getCategory() == GuestCategory.BLACKLISTED) {
            throw new BusinessException("This guest is blacklisted and cannot be booked");
        }

        BookingStatus status = request.status() == null ? BookingStatus.CONFIRMED : request.status();
        if (status != BookingStatus.PENDING && status != BookingStatus.CONFIRMED) {
            throw new BusinessException("New reservations can only be PENDING or CONFIRMED");
        }

        Booking booking = Booking.builder()
                .hotel(hotel)
                .guest(guest)
                .checkInDate(request.checkInDate())
                .checkOutDate(request.checkOutDate())
                .adults(request.adults())
                .children(request.children() == null ? 0 : request.children())
                .bookingSource(request.bookingSource() == null ? BookingSource.DIRECT : request.bookingSource())
                .status(status)
                .specialRequests(request.specialRequests())
                .internalNotes(request.internalNotes())
                .createdBy(accessService.currentUserId())
                .currency("INR")
                .paymentStatus(BookingPaymentStatus.UNPAID)
                .roomChargeTotal(BigDecimal.ZERO)
                .extraCharges(BigDecimal.ZERO)
                .discountAmount(BigDecimal.ZERO)
                .taxAmount(BigDecimal.ZERO)
                .totalAmount(BigDecimal.ZERO)
                .advanceAmount(BigDecimal.ZERO)
                .paidAmount(BigDecimal.ZERO)
                .pendingAmount(BigDecimal.ZERO)
                .build();

        int capacity = 0;
        Long excludeId = -1L;
        for (BookingDtos.RoomLineRequest line : request.rooms()) {
            RoomCategory category = categoryRepository.findByIdAndHotelId(line.categoryId(), hotel.getId())
                    .orElseThrow(() -> NotFoundException.of("Room category", line.categoryId()));
            Room room = null;
            if (line.roomId() != null) {
                room = lockAndValidateRoom(line.roomId(), hotel.getId(), request.checkInDate(),
                        request.checkOutDate(), excludeId);
            }
            capacity += room != null ? room.getMaxOccupancy() : category.getMaxOccupancy();
            booking.addRoom(buildSegment(booking, category, room, request.checkInDate(), request.checkOutDate(),
                    line, request.adults(), request.children()));
        }
        validateOccupancy(capacity, booking.getAdults(), booking.getChildren());

        booking.setBookingCode(nextBookingCode(hotel));
        booking.getRooms().forEach(segment -> segment.setBooking(booking));

        BigDecimal couponDiscount = BigDecimal.ZERO;
        Coupon coupon = null;
        if (request.couponCode() != null && !request.couponCode().isBlank()) {
            coupon = findCoupon(request.couponCode(), hotel, booking.getRoomChargeTotal());
            couponDiscount = couponDiscount(coupon, booking.getRoomChargeTotal());
            coupon.setUsedCount(coupon.getUsedCount() + 1);
            couponRepository.save(coupon);
            booking.setCoupon(coupon);
        }
        booking.setDiscountAmount(MoneyUtils.add(request.discountAmount(), couponDiscount));
        recalculateTotals(booking);

        BigDecimal advance = MoneyUtils.nullToZero(request.advanceAmount());
        if (advance.compareTo(booking.getTotalAmount()) > 0) {
            throw new BusinessException("Advance amount cannot exceed the booking total");
        }
        booking.setAdvanceAmount(MoneyUtils.scale(advance));
        bookingRepository.save(booking);
        booking.getGuest().setLoyaltyPoints(booking.getGuest().getLoyaltyPoints() == null ? 0
                : booking.getGuest().getLoyaltyPoints() + (int) (booking.getTotalAmount().doubleValue() / 1000));
        guestRepository.save(booking.getGuest());

        if (MoneyUtils.isPositive(advance)) {
            paymentService.record(new PaymentDtos.Request(hotel.getId(), booking.getId(), null, advance,
                    request.advanceMethod() == null ? PaymentMethod.CASH : request.advanceMethod(),
                    PaymentType.ADVANCE, null, "Advance collected at booking", null));
        } else {
            paymentService.recalculateBooking(booking);
        }

        notificationService.dispatch(hotel, null, NotificationType.BOOKING_CREATED, NotificationSeverity.SUCCESS,
                "New booking " + booking.getBookingCode(),
                guest.getFullName() + " booked " + booking.getRooms().size() + " room(s) from "
                        + booking.getCheckInDate() + " to " + booking.getCheckOutDate() + ".",
                "/bookings");
        auditService.record(hotel.getId(), "BOOKING_CREATED", "Booking", booking.getId(),
                "Booking " + booking.getBookingCode() + " created for " + guest.getFullName()
                        + " (" + booking.getTotalAmount() + ")");
        return buildResponse(booking);
    }

    /* -------------------------------- update -------------------------------- */

    @Transactional
    public BookingDtos.Response update(Long id, BookingDtos.UpdateRequest request) {
        accessService.assertPermission(Permission.BOOKING_WRITE);
        Booking booking = requireBooking(id);
        if (booking.getStatus() != BookingStatus.PENDING && booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new BusinessException("Only pending or confirmed reservations can be modified");
        }
        validateDates(request.checkInDate(), request.checkOutDate(), false);
        if (request.rooms() == null || request.rooms().isEmpty()) {
            throw new BusinessException("At least one room is required");
        }

        List<BookingRoom> rebuilt = new ArrayList<>();
        int capacity = 0;
        for (BookingDtos.RoomLineRequest line : request.rooms()) {
            RoomCategory category = categoryRepository.findByIdAndHotelId(line.categoryId(), booking.getHotel().getId())
                    .orElseThrow(() -> NotFoundException.of("Room category", line.categoryId()));
            Room room = null;
            if (line.roomId() != null) {
                room = lockAndValidateRoom(line.roomId(), booking.getHotel().getId(), request.checkInDate(),
                        request.checkOutDate(), booking.getId());
            }
            capacity += room != null ? room.getMaxOccupancy() : category.getMaxOccupancy();
            rebuilt.add(buildSegment(booking, category, room, request.checkInDate(), request.checkOutDate(),
                    line, request.adults(), request.children()));
        }
        validateOccupancy(capacity, request.adults(), request.children() == null ? 0 : request.children());

        booking.setCheckInDate(request.checkInDate());
        booking.setCheckOutDate(request.checkOutDate());
        booking.setAdults(request.adults());
        booking.setChildren(request.children() == null ? 0 : request.children());
        if (request.bookingSource() != null) {
            booking.setBookingSource(request.bookingSource());
        }
        booking.setSpecialRequests(request.specialRequests());
        booking.setInternalNotes(request.internalNotes());

        booking.getRooms().clear();
        rebuilt.forEach(segment -> {
            segment.setBooking(booking);
            booking.getRooms().add(segment);
        });

        BigDecimal couponDiscount = BigDecimal.ZERO;
        booking.setCoupon(null);
        if (request.couponCode() != null && !request.couponCode().isBlank()) {
            Coupon coupon = findCoupon(request.couponCode(), booking.getHotel(), booking.getRoomChargeTotal());
            couponDiscount = couponDiscount(coupon, booking.getRoomChargeTotal());
            coupon.setUsedCount(coupon.getUsedCount() + 1);
            couponRepository.save(coupon);
            booking.setCoupon(coupon);
        }
        booking.setDiscountAmount(MoneyUtils.add(request.discountAmount(), couponDiscount));
        recalculateTotals(booking);
        bookingRepository.save(booking);
        paymentService.recalculateBooking(booking);
        auditService.record(booking.getHotel().getId(), "BOOKING_UPDATED", "Booking", booking.getId(),
                "Booking " + booking.getBookingCode() + " updated (" + booking.getTotalAmount() + ")");
        return buildResponse(booking);
    }

    /* -------------------------------- cancel -------------------------------- */

    @Transactional
    public BookingDtos.Response cancel(Long id, BookingDtos.CancelRequest request) {
        accessService.assertPermission(Permission.BOOKING_CANCEL);
        Booking booking = requireBooking(id);
        accessService.assertHotelAccess(booking.getHotel().getId());
        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new BusinessException("This booking is already cancelled");
        }
        if (booking.getStatus() == BookingStatus.CHECKED_OUT) {
            throw new BusinessException("Completed stays cannot be cancelled");
        }
        if (booking.getStatus() == BookingStatus.CHECKED_IN) {
            throw new BusinessException("The guest is currently checked in. Check them out first.");
        }
        for (BookingRoom segment : booking.getRooms()) {
            segment.setStatus(BookingRoomStatus.CANCELLED);
        }
        booking.setStatus(BookingStatus.CANCELLED);
        booking.setCancelledAt(Instant.now());
        booking.setCancellationReason(request.reason());
        bookingRepository.save(booking);

        if (request.refundAmount() != null && MoneyUtils.isPositive(request.refundAmount())) {
            paymentService.refund(new PaymentDtos.RefundRequest(null, booking.getId(), request.refundAmount(),
                    request.reason(), request.refundMethod()));
        } else {
            paymentService.recalculateBooking(booking);
        }
        notificationService.dispatch(booking.getHotel(), null, NotificationType.BOOKING_CANCELLED,
                NotificationSeverity.WARNING, "Booking cancelled",
                booking.getBookingCode() + " for " + booking.getGuest().getFullName() + " was cancelled. Reason: "
                        + request.reason(), "/bookings");
        auditService.record(booking.getHotel().getId(), "BOOKING_CANCELLED", "Booking", booking.getId(),
                "Booking " + booking.getBookingCode() + " cancelled: " + request.reason());
        return buildResponse(booking);
    }

    /* ------------------------------- check-in ------------------------------- */

    @Transactional
    public BookingDtos.Response checkIn(Long id, BookingDtos.CheckInRequest request) {
        accessService.assertPermission(Permission.CHECKIN_WRITE);
        Booking booking = requireBooking(id);
        accessService.assertHotelAccess(booking.getHotel().getId());
        if (booking.getStatus() != BookingStatus.CONFIRMED && booking.getStatus() != BookingStatus.PENDING) {
            throw new BusinessException("Only pending or confirmed bookings can be checked in");
        }
        if (booking.getCheckOutDate().isBefore(LocalDate.now())) {
            throw new BusinessException("This reservation has already expired. Update the dates before check-in.");
        }
        if (request != null && request.assignments() != null) {
            for (BookingDtos.RoomAssignment assignment : request.assignments()) {
                if (assignment.roomId() == null) {
                    continue;
                }
                BookingRoom segment = booking.getRooms().stream()
                        .filter(s -> s.getId().equals(assignment.segmentId()))
                        .findFirst()
                        .orElseThrow(() -> new BusinessException("Invalid room assignment requested"));
                Room room = lockAndValidateRoom(assignment.roomId(), booking.getHotel().getId(),
                        segment.getCheckInDate(), segment.getCheckOutDate(), booking.getId());
                segment.setRoom(room);
            }
        }
        for (BookingRoom segment : booking.getRooms()) {
            if (segment.getRoom() == null) {
                Room room = findAvailableRoom(booking.getHotel().getId(), segment.getCategory().getId(),
                        segment.getCheckInDate(), segment.getCheckOutDate(), booking.getId());
                if (room == null) {
                    throw new BusinessException("No " + segment.getCategory().getName()
                            + " room is available for the selected dates");
                }
                segment.setRoom(room);
            }
            segment.setStatus(BookingRoomStatus.CHECKED_IN);
            Room room = segment.getRoom();
            room.setStatus(RoomStatus.OCCUPIED);
            room.setHousekeepingStatus(HousekeepingCondition.CLEAN);
            roomRepository.save(room);
        }
        if (request != null && MoneyUtils.isPositive(request.earlyCheckInCharge())) {
            booking.setExtraCharges(MoneyUtils.add(booking.getExtraCharges(), request.earlyCheckInCharge()));
        }
        booking.setStatus(BookingStatus.CHECKED_IN);
        booking.setActualCheckInAt(Instant.now());
        booking.setCheckedInBy(accessService.currentUserId());
        recalculateTotals(booking);
        bookingRepository.save(booking);
        paymentService.recalculateBooking(booking);

        notificationService.dispatch(booking.getHotel(), null, NotificationType.CHECKIN_DUE,
                NotificationSeverity.SUCCESS, "Guest checked in",
                booking.getGuest().getFullName() + " checked into room(s) " + roomNumbers(booking) + ".", "/bookings");
        auditService.record(booking.getHotel().getId(), "CHECK_IN", "Booking", booking.getId(),
                "Checked in " + booking.getGuest().getFullName() + " to room(s) " + roomNumbers(booking));
        return buildResponse(booking);
    }

    /* ------------------------------- check-out ------------------------------ */

    @Transactional
    public BookingDtos.CheckOutResponse checkOut(Long id, BookingDtos.CheckOutRequest request) {
        accessService.assertPermission(Permission.CHECKOUT_WRITE);
        Booking booking = requireBooking(id);
        accessService.assertHotelAccess(booking.getHotel().getId());
        if (booking.getStatus() != BookingStatus.CHECKED_IN) {
            throw new BusinessException("Only checked-in guests can be checked out");
        }
        BigDecimal extras = MoneyUtils.add(MoneyUtils.nullToZero(request.extraCharges()),
                MoneyUtils.nullToZero(request.lateCheckOutCharge()));
        if (MoneyUtils.isPositive(extras)) {
            booking.setExtraCharges(MoneyUtils.add(booking.getExtraCharges(), extras));
        }
        if (MoneyUtils.isPositive(request.discount())) {
            booking.setDiscountAmount(MoneyUtils.add(booking.getDiscountAmount(), request.discount()));
        }
        recalculateTotals(booking);
        bookingRepository.save(booking);

        Invoice invoice = invoiceService.createInvoice(booking, null, request.notes(), true);
        BigDecimal settled = BigDecimal.ZERO;
        if (Boolean.TRUE.equals(request.collectPayment()) && MoneyUtils.isPositive(booking.getPendingAmount())) {
            BigDecimal amount = booking.getPendingAmount();
            paymentService.record(new PaymentDtos.Request(booking.getHotel().getId(), booking.getId(),
                    invoice.getId(), amount,
                    request.paymentMethod() == null ? PaymentMethod.CASH : request.paymentMethod(),
                    PaymentType.SETTLEMENT, request.paymentReference(), "Settled at check-out", null));
            settled = amount;
        }

        booking.setStatus(BookingStatus.CHECKED_OUT);
        booking.setActualCheckOutAt(Instant.now());
        booking.setCheckedOutBy(accessService.currentUserId());
        for (BookingRoom segment : booking.getRooms()) {
            segment.setStatus(BookingRoomStatus.CHECKED_OUT);
            Room room = segment.getRoom();
            if (room != null) {
                room.setStatus(RoomStatus.CLEANING);
                room.setHousekeepingStatus(HousekeepingCondition.DIRTY);
                roomRepository.save(room);
                housekeepingTaskRepository.save(HousekeepingTask.builder()
                        .hotel(booking.getHotel())
                        .room(room)
                        .taskType(HousekeepingTaskType.CLEANING)
                        .status(HousekeepingTaskStatus.PENDING)
                        .priority(TaskPriority.NORMAL)
                        .notes("Departure cleaning after " + booking.getBookingCode())
                        .scheduledDate(LocalDate.now())
                        .createdBy(accessService.currentUserId())
                        .build());
            }
        }
        bookingRepository.save(booking);
        paymentService.recalculateBooking(booking);
        Invoice refreshed = invoiceRepository.findWithLines(invoice.getId()).orElse(invoice);
        paymentService.recalculateInvoice(refreshed);

        notificationService.dispatch(booking.getHotel(), null, NotificationType.CHECKOUT_DUE,
                NotificationSeverity.INFO, "Guest checked out",
                booking.getGuest().getFullName() + " checked out from room(s) " + roomNumbers(booking)
                        + ". Invoice " + invoice.getInvoiceNumber() + ".", "/invoices");
        notificationService.dispatch(booking.getHotel(), null, NotificationType.HOUSEKEEPING,
                NotificationSeverity.INFO, "Rooms need cleaning",
                "Rooms " + roomNumbers(booking) + " are now dirty and need housekeeping.", "/housekeeping");
        auditService.record(booking.getHotel().getId(), "CHECK_OUT", "Booking", booking.getId(),
                "Checked out " + booking.getGuest().getFullName() + "; invoice " + invoice.getInvoiceNumber());
        return new BookingDtos.CheckOutResponse(BookingDtos.Summary.from(booking),
                PaymentDtos.InvoiceResponse.from(refreshed), settled);
    }

    /* ---------------------------- room operations --------------------------- */

    @Transactional
    public BookingDtos.Response transferRoom(Long id, BookingDtos.TransferRoomRequest request) {
        accessService.assertPermission(Permission.BOOKING_WRITE);
        Booking booking = requireBooking(id);
        accessService.assertHotelAccess(booking.getHotel().getId());
        if (booking.getStatus() == BookingStatus.CHECKED_OUT) {
            throw new BusinessException("Completed bookings cannot be modified");
        }
        BookingRoom segment = booking.getRooms().stream()
                .filter(s -> s.getId().equals(request.segmentId()))
                .findFirst()
                .orElseThrow(() -> new BusinessException("Invalid room segment"));
        Room room = lockAndValidateRoom(request.newRoomId(), booking.getHotel().getId(),
                segment.getCheckInDate(), segment.getCheckOutDate(), booking.getId());
        Room old = segment.getRoom();
        segment.setRoom(room);
        if (booking.getStatus() == BookingStatus.CHECKED_IN) {
            if (old != null) {
                old.setStatus(RoomStatus.CLEANING);
                old.setHousekeepingStatus(HousekeepingCondition.DIRTY);
                roomRepository.save(old);
                housekeepingTaskRepository.save(HousekeepingTask.builder()
                        .hotel(booking.getHotel())
                        .room(old)
                        .taskType(HousekeepingTaskType.CLEANING)
                        .status(HousekeepingTaskStatus.PENDING)
                        .priority(TaskPriority.NORMAL)
                        .notes("Room transfer to " + room.getRoomNumber() + " (" + booking.getBookingCode() + ")")
                        .scheduledDate(LocalDate.now())
                        .createdBy(accessService.currentUserId())
                        .build());
            }
            room.setStatus(RoomStatus.OCCUPIED);
            roomRepository.save(room);
        }
        bookingRepository.save(booking);
        auditService.record(booking.getHotel().getId(), "ROOM_TRANSFER", "Booking", booking.getId(),
                "Booking " + booking.getBookingCode() + " moved to room " + room.getRoomNumber()
                        + (request.reason() == null ? "" : ": " + request.reason()));
        notificationService.dispatch(booking.getHotel(), null, NotificationType.SYSTEM,
                NotificationSeverity.INFO, "Room transfer",
                booking.getGuest().getFullName() + " moved to room " + room.getRoomNumber() + ".", "/bookings");
        return buildResponse(booking);
    }

    @Transactional
    public BookingDtos.Response reschedule(Long id, BookingDtos.RescheduleRequest request) {
        accessService.assertPermission(Permission.BOOKING_WRITE);
        Booking booking = requireBooking(id);
        accessService.assertHotelAccess(booking.getHotel().getId());
        if (booking.getStatus() == BookingStatus.CHECKED_OUT || booking.getStatus() == BookingStatus.CANCELLED
                || booking.getStatus() == BookingStatus.NO_SHOW) {
            throw new BusinessException("This booking can no longer be rescheduled");
        }
        validateDates(request.checkInDate(), request.checkOutDate(), false);
        List<BookingRoom> segments = request.segmentId() == null ? booking.getRooms()
                : booking.getRooms().stream().filter(s -> s.getId().equals(request.segmentId())).toList();
        if (segments.isEmpty()) {
            throw new BusinessException("Invalid room segment");
        }
        for (BookingRoom segment : segments) {
            Long roomId = request.roomId() != null ? request.roomId()
                    : segment.getRoom() == null ? null : segment.getRoom().getId();
            Room room = null;
            if (roomId != null) {
                room = lockAndValidateRoom(roomId, booking.getHotel().getId(), request.checkInDate(),
                        request.checkOutDate(), booking.getId());
            }
            BookingDtos.RoomLineRequest line = new BookingDtos.RoomLineRequest(roomId,
                    segment.getCategory().getId(), segment.getRatePerNight(), segment.getExtraBedCount());
            BookingRoom refreshed = buildSegment(booking, segment.getCategory(), room, request.checkInDate(),
                    request.checkOutDate(), line, booking.getAdults(), booking.getChildren());
            segment.setRoom(refreshed.getRoom());
            segment.setCheckInDate(refreshed.getCheckInDate());
            segment.setCheckOutDate(refreshed.getCheckOutDate());
            segment.setNights(refreshed.getNights());
            segment.setRatePerNight(refreshed.getRatePerNight());
            segment.setTotalAmount(refreshed.getTotalAmount());
        }
        booking.setCheckInDate(request.checkInDate());
        booking.setCheckOutDate(request.checkOutDate());
        recalculateTotals(booking);
        bookingRepository.save(booking);
        paymentService.recalculateBooking(booking);
        auditService.record(booking.getHotel().getId(), "BOOKING_RESCHEDULED", "Booking", booking.getId(),
                "Booking " + booking.getBookingCode() + " moved to " + request.checkInDate()
                        + " - " + request.checkOutDate());
        return buildResponse(booking);
    }

    /* -------------------------------- queries ------------------------------- */

    @Transactional(readOnly = true)
    public BookingDtos.Response get(Long id) {
        accessService.assertPermission(Permission.BOOKING_READ);
        Booking booking = requireBooking(id);
        return buildResponse(booking);
    }

    @Transactional(readOnly = true)
    public PageResponse<BookingDtos.Summary> search(Long hotelId, List<BookingStatus> statuses,
                                                    BookingPaymentStatus paymentStatus, BookingSource source,
                                                    LocalDate from, LocalDate to, String search, int page, int size) {
        accessService.assertPermission(Permission.BOOKING_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        Specification<Booking> spec = (root, query, cb) -> {
            if (query != null) {
                query.distinct(true);
            }
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(root.get("hotel").get("id").in(scope));
            if (statuses != null && !statuses.isEmpty()) {
                predicates.add(root.get("status").in(statuses));
            }
            if (paymentStatus != null) {
                predicates.add(cb.equal(root.get("paymentStatus"), paymentStatus));
            }
            if (source != null) {
                predicates.add(cb.equal(root.get("bookingSource"), source));
            }
            if (from != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("checkOutDate"), from));
            }
            if (to != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("checkInDate"), to));
            }
            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase(Locale.ROOT) + "%";
                Join<Object, Object> guest = root.join("guest", JoinType.LEFT);
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("bookingCode")), like),
                        cb.like(cb.lower(guest.get("fullName")), like),
                        cb.like(cb.lower(cb.coalesce(guest.get("mobile"), "")), like),
                        cb.like(cb.lower(cb.coalesce(guest.get("email"), "")), like)));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        Page<Booking> result = bookingRepository.findAll(spec, PageRequest.of(Math.max(page, 0),
                Math.min(Math.max(size, 1), 100), Sort.by(Sort.Direction.DESC, "checkInDate", "id")));
        return PageResponse.of(result, BookingDtos.Summary::from);
    }

    @Transactional(readOnly = true)
    public BookingDtos.CalendarResponse calendar(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.BOOKING_READ);
        Long scopeHotel = accessService.requireHotel(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? start.plusMonths(1) : to;
        if (end.isBefore(start)) {
            throw new BusinessException("The calendar end date must be after the start date");
        }
        List<BookingDtos.TimelineRoom> rooms = roomRepository.findAllByHotelId(scopeHotel).stream()
                .filter(room -> Boolean.TRUE.equals(room.getActive()))
                .map(room -> new BookingDtos.TimelineRoom(room.getId(), room.getRoomNumber(), room.getFloor(),
                        room.getCategory().getName(), room.getStatus().name(), room.getHousekeepingStatus().name(),
                        room.getBasePrice()))
                .toList();
        List<BookingDtos.TimelineEntry> entries = bookingRoomRepository
                .findForCalendar(List.of(scopeHotel), start, end.plusDays(1), HOLDING_STATUSES).stream()
                .map(segment -> new BookingDtos.TimelineEntry(segment.getBooking().getId(),
                        segment.getBooking().getBookingCode(), segment.getId(),
                        segment.getRoom() == null ? null : segment.getRoom().getId(),
                        segment.getRoom() == null ? "Unassigned" : segment.getRoom().getRoomNumber(),
                        segment.getBooking().getGuest().getFullName(), segment.getBooking().getGuest().getMobile(),
                        segment.getCheckInDate(), segment.getCheckOutDate(), segment.getNights(),
                        segment.getBooking().getStatus(), segment.getBooking().getPaymentStatus(),
                        segment.getBooking().getTotalAmount(), segment.getBooking().getPendingAmount(),
                        segment.getBooking().getAdults(), segment.getBooking().getChildren()))
                .toList();
        return new BookingDtos.CalendarResponse(scopeHotel, start, end, rooms, entries);
    }

    @Transactional(readOnly = true)
    public BookingDtos.DayOperations dayOperations(Long hotelId, LocalDate date) {
        accessService.assertPermission(Permission.BOOKING_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate target = date == null ? LocalDate.now() : date;
        List<BookingDtos.Summary> arrivals = bookingRepository.findUpcomingCheckIns(scope, target).stream()
                .map(BookingDtos.Summary::from).toList();
        List<BookingDtos.Summary> departures = bookingRepository.findDeparturesOn(scope, target).stream()
                .map(BookingDtos.Summary::from).toList();
        List<BookingDtos.Summary> inHouse = bookingRepository.findInHouse(scope).stream()
                .map(BookingDtos.Summary::from).toList();
        return new BookingDtos.DayOperations(target, arrivals, departures, inHouse);
    }

    @Transactional(readOnly = true)
    public byte[] receiptPdf(Long id) {
        Booking booking = requireBooking(id);
        List<String> headers = List.of("Field", "Details");
        List<List<String>> rows = new ArrayList<>();
        rows.add(List.of("Booking code", booking.getBookingCode()));
        rows.add(List.of("Hotel", booking.getHotel().getName()));
        rows.add(List.of("Guest", booking.getGuest().getFullName()));
        rows.add(List.of("Mobile", booking.getGuest().getMobile()));
        rows.add(List.of("Check-in", booking.getCheckInDate().toString()));
        rows.add(List.of("Check-out", booking.getCheckOutDate().toString()));
        rows.add(List.of("Nights", String.valueOf(booking.getNights())));
        rows.add(List.of("Rooms", roomNumbers(booking)));
        rows.add(List.of("Adults / Children", booking.getAdults() + " / " + booking.getChildren()));
        rows.add(List.of("Status", booking.getStatus().name()));
        rows.add(List.of("Room charges", booking.getRoomChargeTotal().toPlainString()));
        rows.add(List.of("Extra charges", booking.getExtraCharges().toPlainString()));
        rows.add(List.of("Discount", booking.getDiscountAmount().toPlainString()));
        rows.add(List.of("Tax", booking.getTaxAmount().toPlainString()));
        rows.add(List.of("Total", "INR " + booking.getTotalAmount().toPlainString()));
        rows.add(List.of("Paid", booking.getPaidAmount().toPlainString()));
        rows.add(List.of("Pending", booking.getPendingAmount().toPlainString()));
        return receiptDocument(booking, headers, rows);
    }

    private byte[] receiptDocument(Booking booking, List<String> headers, List<List<String>> rows) {
        return documentService.reportPdf("Booking confirmation - " + booking.getBookingCode(),
                booking.getHotel().getName() + "  |  " + booking.getHotel().getContactNumber(), headers, rows);
    }

    @Transactional(readOnly = true)
    public Booking requireBooking(Long id) {
        Booking booking = bookingRepository.findDetailedById(id)
                .orElseThrow(() -> NotFoundException.of("Booking", id));
        accessService.assertHotelAccess(booking.getHotel().getId());
        return booking;
    }

    @Transactional(readOnly = true)
    public List<OpsDtos.ServiceOrderResponse> services(Long bookingId) {
        requireBooking(bookingId);
        return serviceOrderRepository.findByBookingIdOrderByOrderedAtDesc(bookingId).stream()
                .map(OpsDtos.ServiceOrderResponse::from).toList();
    }

    /* -------------------------------- helpers ------------------------------- */

    private BookingRoom buildSegment(Booking booking, RoomCategory category, Room room, LocalDate checkIn,
                                     LocalDate checkOut, BookingDtos.RoomLineRequest line, int adults, int children) {
        PricingService.StayPricing pricing = pricingService.computeStay(booking.getHotel().getId(), room, category,
                checkIn, checkOut, adults, children, line.extraBeds() == null ? 0 : line.extraBeds());
        BigDecimal rate = line.ratePerNight() != null ? MoneyUtils.scale(line.ratePerNight()) : pricing.averageNightly();
        long nights = ChronoUnit.DAYS.between(checkIn, checkOut);
        BigDecimal total = line.ratePerNight() != null
                ? MoneyUtils.multiply(rate, BigDecimal.valueOf(nights))
                : pricing.roomTotal();
        total = MoneyUtils.add(total, pricing.extraPersonTotal(), pricing.extraBedTotal());
        return BookingRoom.builder()
                .booking(booking)
                .room(room)
                .category(category)
                .checkInDate(checkIn)
                .checkOutDate(checkOut)
                .nights((int) nights)
                .ratePerNight(rate)
                .extraPersonCharge(pricing.extraPersonTotal())
                .extraBedCount(line.extraBeds() == null ? 0 : line.extraBeds())
                .totalAmount(MoneyUtils.scale(total))
                .status(BookingRoomStatus.RESERVED)
                .build();
    }

    private void recalculateTotals(Booking booking) {
        BigDecimal roomCharge = booking.getRooms().stream()
                .map(segment -> MoneyUtils.nullToZero(segment.getTotalAmount()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        booking.setRoomChargeTotal(MoneyUtils.scale(roomCharge));
        BigDecimal discount = MoneyUtils.nullToZero(booking.getDiscountAmount());
        if (discount.compareTo(roomCharge) > 0) {
            discount = roomCharge;
            booking.setDiscountAmount(discount);
        }
        BigDecimal taxable = MoneyUtils.subtract(MoneyUtils.add(roomCharge, booking.getExtraCharges()), discount);
        BigDecimal tax = MoneyUtils.percentOf(taxable, booking.getHotel().getTaxRate());
        BigDecimal total = MoneyUtils.add(taxable, tax);
        booking.setTaxAmount(tax);
        booking.setTotalAmount(total);
        BigDecimal paid = MoneyUtils.nullToZero(booking.getPaidAmount());
        BigDecimal pending = MoneyUtils.subtract(total, paid);
        booking.setPendingAmount(pending.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : pending);
    }

    /**
     * Locks the physical room row (SELECT ... FOR UPDATE) and re-checks for overlapping reservations
     * inside the same transaction. Two concurrent requests for the same room therefore serialise and
     * the second one fails with 409 instead of double booking.
     */
    private Room lockAndValidateRoom(Long roomId, Long hotelId, LocalDate checkIn, LocalDate checkOut,
                                     Long excludeBookingId) {
        Room room = roomRepository.findByIdForUpdate(roomId)
                .orElseThrow(() -> NotFoundException.of("Room", roomId));
        if (!room.getHotel().getId().equals(hotelId)) {
            throw new BusinessException("Room " + room.getRoomNumber() + " does not belong to this hotel");
        }
        if (!Boolean.TRUE.equals(room.getActive()) || room.getStatus() == RoomStatus.OUT_OF_SERVICE) {
            throw new BusinessException("Room " + room.getRoomNumber() + " is out of service");
        }
        if (room.getStatus() == RoomStatus.MAINTENANCE) {
            throw new BusinessException("Room " + room.getRoomNumber() + " is under maintenance");
        }
        long overlaps = bookingRoomRepository.countOverlapping(roomId, checkIn, checkOut, HOLDING_STATUSES,
                excludeBookingId == null ? -1L : excludeBookingId);
        if (overlaps > 0) {
            throw new ConflictException("Room " + room.getRoomNumber()
                    + " is already reserved for the selected dates. Choose another room or dates.");
        }
        return room;
    }

    private Room findAvailableRoom(Long hotelId, Long categoryId, LocalDate checkIn, LocalDate checkOut,
                                   Long excludeBookingId) {
        List<Room> candidates = roomRepository.findAllByHotelId(hotelId).stream()
                .filter(room -> room.getCategory().getId().equals(categoryId))
                .filter(room -> Boolean.TRUE.equals(room.getActive()))
                .filter(room -> room.getStatus() != RoomStatus.MAINTENANCE && room.getStatus() != RoomStatus.OUT_OF_SERVICE)
                .sorted(java.util.Comparator.comparing(Room::getRoomNumber))
                .toList();
        for (Room candidate : candidates) {
            Room locked = roomRepository.findByIdForUpdate(candidate.getId()).orElse(null);
            if (locked == null) {
                continue;
            }
            long overlaps = bookingRoomRepository.countOverlapping(locked.getId(), checkIn, checkOut,
                    HOLDING_STATUSES, excludeBookingId == null ? -1L : excludeBookingId);
            if (overlaps == 0) {
                return locked;
            }
        }
        return null;
    }

    private Guest resolveGuest(BookingDtos.Request request, Hotel hotel) {
        if (request.guestId() != null) {
            return guestRepository.findById(request.guestId())
                    .orElseThrow(() -> NotFoundException.of("Guest", request.guestId()));
        }
        if (request.newGuest() != null) {
            BookingDtos.NewGuestRequest newGuest = request.newGuest();
            return guestRepository.findByMobile(newGuest.mobile().trim()).orElseGet(() -> {
                Guest guest = Guest.builder()
                        .hotel(hotel)
                        .fullName(newGuest.fullName().trim())
                        .mobile(newGuest.mobile().trim())
                        .email(newGuest.email())
                        .address(newGuest.address())
                        .city(newGuest.city())
                        .state(newGuest.state())
                        .country(newGuest.country())
                        .idProofType(parseIdProof(newGuest.idProofType()))
                        .idProofNumber(newGuest.idProofNumber())
                        .idProofLast4(com.hotelcrm.util.FieldCipher.last4(newGuest.idProofNumber()))
                        .category(Boolean.TRUE.equals(newGuest.vip()) ? GuestCategory.VIP : GuestCategory.REGULAR)
                        .vip(Boolean.TRUE.equals(newGuest.vip()))
                        .blacklisted(Boolean.FALSE)
                        .specialRequests(newGuest.specialRequests())
                        .loyaltyPoints(0)
                        .build();
                return guestRepository.save(guest);
            });
        }
        throw new BusinessException("Select an existing guest or provide guest details");
    }

    private IdProofType parseIdProof(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return IdProofType.valueOf(value.trim().toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            return IdProofType.OTHER;
        }
    }

    private Coupon findCoupon(String code, Hotel hotel, BigDecimal amount) {
        Coupon coupon = couponRepository.findByCodeIgnoreCase(code.trim())
                .orElseThrow(() -> new BusinessException("Coupon " + code + " is not valid"));
        if (!Boolean.TRUE.equals(coupon.getActive())) {
            throw new BusinessException("This coupon is no longer active");
        }
        if (coupon.getHotel() != null && !coupon.getHotel().getId().equals(hotel.getId())) {
            throw new BusinessException("This coupon is not valid for the selected hotel");
        }
        LocalDate today = LocalDate.now();
        if (coupon.getValidFrom() != null && today.isBefore(coupon.getValidFrom())) {
            throw new BusinessException("This coupon is not active yet");
        }
        if (coupon.getValidTo() != null && today.isAfter(coupon.getValidTo())) {
            throw new BusinessException("This coupon has expired");
        }
        if (coupon.getUsageLimit() != null && coupon.getUsedCount() >= coupon.getUsageLimit()) {
            throw new BusinessException("This coupon has reached its usage limit");
        }
        if (amount.compareTo(MoneyUtils.nullToZero(coupon.getMinAmount())) < 0) {
            throw new BusinessException("This coupon requires a minimum booking value of " + coupon.getMinAmount());
        }
        return coupon;
    }

    private BigDecimal couponDiscount(Coupon coupon, BigDecimal amount) {
        BigDecimal discount = coupon.getDiscountType() == DiscountType.PERCENTAGE
                ? MoneyUtils.percentOf(amount, coupon.getValue())
                : MoneyUtils.scale(coupon.getValue());
        if (coupon.getMaxDiscount() != null && discount.compareTo(coupon.getMaxDiscount()) > 0) {
            discount = MoneyUtils.scale(coupon.getMaxDiscount());
        }
        if (discount.compareTo(amount) > 0) {
            discount = amount;
        }
        return discount;
    }

    private void validateDates(LocalDate checkIn, LocalDate checkOut, boolean newBooking) {
        if (checkIn == null || checkOut == null) {
            throw new BusinessException("Check-in and check-out dates are required");
        }
        if (!checkOut.isAfter(checkIn)) {
            throw new BusinessException("Check-out date must be after the check-in date");
        }
        if (newBooking && checkIn.isBefore(LocalDate.now())) {
            throw new BusinessException("Check-in date cannot be in the past");
        }
        if (newBooking && checkIn.isAfter(LocalDate.now().plusYears(2))) {
            throw new BusinessException("Reservations can only be made up to two years in advance");
        }
    }

    private void validateOccupancy(int capacity, int adults, int children) {
        if (adults + children > capacity) {
            throw new BusinessException("The selected rooms accommodate up to " + capacity
                    + " guests. Add another room or reduce the guest count.");
        }
    }

    private String nextBookingCode(Hotel hotel) {
        long sequence = bookingRepository.countByHotelId(hotel.getId()) + 1;
        for (int attempt = 0; attempt < 25; attempt++) {
            String code = CodeGenerator.bookingCode(hotel.getCode(), sequence + attempt);
            if (!bookingRepository.existsByBookingCodeIgnoreCase(code)) {
                return code;
            }
        }
        return CodeGenerator.bookingCode(hotel.getCode(), System.currentTimeMillis() % 100000);
    }

    private String roomNumbers(Booking booking) {
        return booking.getRooms().stream()
                .map(segment -> segment.getRoom() == null ? "TBA" : segment.getRoom().getRoomNumber())
                .reduce((a, b) -> a + ", " + b).orElse("-");
    }

    private BookingDtos.Response buildResponse(Booking booking) {
        List<PaymentDtos.Response> payments = paymentService.forBooking(booking.getId());
        List<OpsDtos.ServiceOrderResponse> services = serviceOrderRepository
                .findByBookingIdOrderByOrderedAtDesc(booking.getId()).stream()
                .map(OpsDtos.ServiceOrderResponse::from).toList();
        List<Invoice> invoices = invoiceRepository.findByBookingId(booking.getId());
        Invoice invoice = invoices.isEmpty() ? null : invoices.get(0);
        String idProof = booking.getGuest().getIdProofLast4() == null ? null
                : "XXXX XXXX " + booking.getGuest().getIdProofLast4();
        return new BookingDtos.Response(BookingDtos.Summary.from(booking),
                booking.getRooms().stream().map(BookingDtos.RoomSegment::from).toList(),
                payments, services, booking.getSpecialRequests(), booking.getInternalNotes(),
                booking.getCancellationReason(), booking.getCancelledAt(), booking.getRoomChargeTotal(),
                booking.getExtraCharges(), booking.getDiscountAmount(), booking.getTaxAmount(),
                booking.getAdvanceAmount(),
                booking.getCoupon() == null ? null : booking.getCoupon().getCode(),
                invoice == null ? null : invoice.getId(), invoice == null ? null : invoice.getInvoiceNumber(),
                booking.getGuest().getEmail(), idProof,
                userDirectoryService.nameOf(booking.getCheckedInBy()),
                userDirectoryService.nameOf(booking.getCheckedOutBy()));
    }
}
