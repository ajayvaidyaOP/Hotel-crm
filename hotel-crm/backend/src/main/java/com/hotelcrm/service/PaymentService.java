package com.hotelcrm.service;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Invoice;
import com.hotelcrm.domain.entity.Payment;
import com.hotelcrm.domain.entity.Refund;
import com.hotelcrm.domain.enums.BookingPaymentStatus;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.InvoiceStatus;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.domain.enums.PaymentMethod;
import com.hotelcrm.domain.enums.PaymentStatus;
import com.hotelcrm.domain.enums.PaymentType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.RefundStatus;
import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.InvoiceRepository;
import com.hotelcrm.repository.PaymentRepository;
import com.hotelcrm.repository.RefundRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.CodeGenerator;
import com.hotelcrm.util.MoneyUtils;
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
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final RefundRepository refundRepository;
    private final BookingRepository bookingRepository;
    private final InvoiceRepository invoiceRepository;
    private final HotelRepository hotelRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final NotificationService notificationService;
    private final UserDirectoryService userDirectoryService;

    /* ------------------------------ recording ------------------------------ */

    @Transactional
    public PaymentDtos.Response record(PaymentDtos.Request request) {
        accessService.assertPermission(Permission.PAYMENT_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Hotel hotel = hotelRepository.findById(request.hotelId())
                .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId()));
        BigDecimal amount = MoneyUtils.scale(request.amount());
        if (!MoneyUtils.isPositive(amount)) {
            throw new BusinessException("Payment amount must be greater than zero");
        }

        Booking booking = null;
        if (request.bookingId() != null) {
            booking = bookingRepository.findById(request.bookingId())
                    .orElseThrow(() -> NotFoundException.of("Booking", request.bookingId()));
            if (!booking.getHotel().getId().equals(hotel.getId())) {
                throw new BusinessException("The booking does not belong to the selected hotel");
            }
            if (booking.getStatus() == BookingStatus.CANCELLED) {
                throw new BusinessException("Cannot record a payment against a cancelled booking");
            }
            BigDecimal netPaid = netPaid(booking.getId());
            BigDecimal outstanding = MoneyUtils.subtract(booking.getTotalAmount(), netPaid);
            if (amount.compareTo(outstanding) > 0 && outstanding.compareTo(BigDecimal.ZERO) > 0) {
                throw new BusinessException("Payment of " + amount + " exceeds the outstanding balance of " + outstanding);
            }
        }

        Invoice invoice = null;
        if (request.invoiceId() != null) {
            invoice = invoiceRepository.findById(request.invoiceId())
                    .orElseThrow(() -> NotFoundException.of("Invoice", request.invoiceId()));
            if (!invoice.getHotel().getId().equals(hotel.getId())) {
                throw new BusinessException("The invoice does not belong to the selected hotel");
            }
            if (invoice.getStatus() == InvoiceStatus.CANCELLED) {
                throw new BusinessException("Cannot record a payment against a cancelled invoice");
            }
        }

        PaymentType type = request.paymentType() != null ? request.paymentType() : deriveType(booking, amount);
        Payment payment = Payment.builder()
                .paymentCode(CodeGenerator.paymentCode(hotel.getCode()))
                .hotel(hotel)
                .booking(booking)
                .invoice(invoice)
                .amount(amount)
                .method(request.method())
                .paymentType(type)
                .status(PaymentStatus.SUCCESS)
                .referenceNo(request.referenceNo())
                .notes(request.notes())
                .paidAt(request.paidAt() == null ? Instant.now() : request.paidAt())
                .receivedBy(accessService.currentUserId())
                .build();
        paymentRepository.save(payment);

        if (booking != null) {
            recalculateBooking(booking);
        }
        if (invoice != null) {
            recalculateInvoice(invoice);
        }
        auditService.record(hotel.getId(), "PAYMENT_RECORDED", "Payment", payment.getId(),
                "Payment of " + amount + " via " + request.method()
                        + (booking == null ? "" : " for booking " + booking.getBookingCode()));
        if (booking != null && booking.getPendingAmount().compareTo(BigDecimal.ZERO) > 0) {
            notificationService.dispatch(hotel, null, NotificationType.PAYMENT_PENDING,
                    NotificationSeverity.WARNING, "Pending payment",
                    "Booking " + booking.getBookingCode() + " still has " + booking.getPendingAmount() + " pending.",
                    "/payments");
        }
        return PaymentDtos.Response.from(payment, userDirectoryService.nameOf(payment.getReceivedBy()));
    }

    private PaymentType deriveType(Booking booking, BigDecimal amount) {
        if (booking == null) {
            return PaymentType.SETTLEMENT;
        }
        BigDecimal netPaid = netPaid(booking.getId());
        if (netPaid.compareTo(BigDecimal.ZERO) <= 0) {
            return PaymentType.ADVANCE;
        }
        BigDecimal remaining = MoneyUtils.subtract(booking.getTotalAmount(), MoneyUtils.add(netPaid, amount));
        return remaining.compareTo(BigDecimal.ZERO) <= 0 ? PaymentType.FULL : PaymentType.PARTIAL;
    }

    /* ------------------------------- refunds ------------------------------- */

    @Transactional
    public PaymentDtos.RefundResponse refund(PaymentDtos.RefundRequest request) {
        accessService.assertPermission(Permission.REFUND_WRITE);
        Booking booking = bookingRepository.findById(request.bookingId())
                .orElseThrow(() -> NotFoundException.of("Booking", request.bookingId()));
        accessService.assertHotelAccess(booking.getHotel().getId());
        BigDecimal amount = MoneyUtils.scale(request.amount());
        BigDecimal netPaid = netPaid(booking.getId());
        if (amount.compareTo(netPaid) > 0) {
            throw new BusinessException("Refund of " + amount + " exceeds the amount collected (" + netPaid + ")");
        }
        Payment payment = null;
        if (request.paymentId() != null) {
            payment = paymentRepository.findById(request.paymentId())
                    .orElseThrow(() -> NotFoundException.of("Payment", request.paymentId()));
        }
        Refund refund = Refund.builder()
                .hotel(booking.getHotel())
                .booking(booking)
                .payment(payment)
                .amount(amount)
                .reason(request.reason())
                .method(request.method() == null ? PaymentMethod.CASH : request.method())
                .status(RefundStatus.COMPLETED)
                .processedBy(accessService.currentUserId())
                .processedAt(Instant.now())
                .build();
        refundRepository.save(refund);
        recalculateBooking(booking);
        auditService.record(booking.getHotel().getId(), "REFUND_PROCESSED", "Refund", refund.getId(),
                "Refund of " + amount + " for booking " + booking.getBookingCode() + ": " + request.reason());
        notificationService.dispatch(booking.getHotel(), null, NotificationType.PAYMENT_PENDING,
                NotificationSeverity.INFO, "Refund processed",
                "Refund of " + amount + " issued for " + booking.getBookingCode() + ".", "/payments");
        return PaymentDtos.RefundResponse.from(refund, userDirectoryService.nameOf(refund.getProcessedBy()));
    }

    /* ----------------------------- recalculation ---------------------------- */

    @Transactional
    public void recalculateBooking(Booking booking) {
        BigDecimal paid = MoneyUtils.nullToZero(paymentRepository.sumPaidForBooking(booking.getId()));
        BigDecimal refunded = MoneyUtils.nullToZero(refundRepository.sumRefundedForBooking(booking.getId()));
        BigDecimal net = MoneyUtils.subtract(paid, refunded);
        BigDecimal total = MoneyUtils.nullToZero(booking.getTotalAmount());
        BigDecimal pending = MoneyUtils.subtract(total, net);
        if (pending.compareTo(BigDecimal.ZERO) < 0) {
            pending = BigDecimal.ZERO;
        }
        booking.setPaidAmount(MoneyUtils.scale(net));
        booking.setPendingAmount(MoneyUtils.scale(pending));
        BookingPaymentStatus status;
        if (booking.getStatus() == BookingStatus.CANCELLED && refunded.compareTo(BigDecimal.ZERO) > 0) {
            status = BookingPaymentStatus.REFUNDED;
        } else if (net.compareTo(BigDecimal.ZERO) <= 0) {
            status = BookingPaymentStatus.UNPAID;
        } else if (pending.compareTo(BigDecimal.ZERO) <= 0) {
            status = BookingPaymentStatus.PAID;
        } else {
            status = BookingPaymentStatus.PARTIALLY_PAID;
        }
        booking.setPaymentStatus(status);
        bookingRepository.save(booking);
    }

    @Transactional
    public void recalculateInvoice(Invoice invoice) {
        BigDecimal paid = MoneyUtils.nullToZero(paymentRepository.sumPaidForInvoice(invoice.getId()));
        BigDecimal balance = MoneyUtils.subtract(invoice.getTotal(), paid);
        if (balance.compareTo(BigDecimal.ZERO) < 0) {
            balance = BigDecimal.ZERO;
        }
        invoice.setAmountPaid(MoneyUtils.scale(paid));
        invoice.setBalance(MoneyUtils.scale(balance));
        if (invoice.getStatus() != InvoiceStatus.CANCELLED && invoice.getStatus() != InvoiceStatus.DRAFT) {
            invoice.setStatus(balance.compareTo(BigDecimal.ZERO) <= 0 ? InvoiceStatus.PAID
                    : paid.compareTo(BigDecimal.ZERO) > 0 ? InvoiceStatus.PARTIALLY_PAID : InvoiceStatus.ISSUED);
        }
        invoiceRepository.save(invoice);
    }

    private BigDecimal netPaid(Long bookingId) {
        BigDecimal paid = MoneyUtils.nullToZero(paymentRepository.sumPaidForBooking(bookingId));
        BigDecimal refunded = MoneyUtils.nullToZero(refundRepository.sumRefundedForBooking(bookingId));
        return MoneyUtils.subtract(paid, refunded);
    }

    /* -------------------------------- queries ------------------------------- */

    @Transactional(readOnly = true)
    public PageResponse<PaymentDtos.Response> list(Long hotelId, LocalDate from, LocalDate to, PaymentMethod method,
                                                  String search, int page, int size) {
        accessService.assertPermission(Permission.PAYMENT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        Instant fromInstant = (from == null ? LocalDate.now().minusMonths(1) : from).atStartOfDay(ZoneOffset.UTC).toInstant();
        Instant toInstant = (to == null ? LocalDate.now().plusDays(1) : to.plusDays(1)).atStartOfDay(ZoneOffset.UTC).toInstant();
        Specification<Payment> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(root.get("hotel").get("id").in(scope));
            predicates.add(cb.between(root.get("paidAt"), fromInstant, toInstant));
            if (method != null) {
                predicates.add(cb.equal(root.get("method"), method));
            }
            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("paymentCode")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("referenceNo"), "")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("booking").get("bookingCode"), "")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("booking").get("guest").get("fullName"), "")), like)));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        Page<Payment> result = paymentRepository.findAll(spec, PageRequest.of(Math.max(page, 0),
                Math.min(Math.max(size, 1), 200), Sort.by(Sort.Direction.DESC, "paidAt")));
        java.util.Map<Long, String> names = userDirectoryService.names(
                result.getContent().stream().map(Payment::getReceivedBy).toList());
        return PageResponse.of(result, payment -> PaymentDtos.Response.from(payment, names.get(payment.getReceivedBy())));
    }

    @Transactional(readOnly = true)
    public List<PaymentDtos.PendingPaymentRow> pendingPayments(Long hotelId) {
        accessService.assertPermission(Permission.PAYMENT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        List<Booking> bookings = bookingRepository.findWithPendingPayments(scope);
        LocalDate today = LocalDate.now();
        return bookings.stream().map(booking -> new PaymentDtos.PendingPaymentRow(
                booking.getId(), booking.getBookingCode(), booking.getHotel().getId(), booking.getHotel().getName(),
                booking.getGuest().getFullName(), booking.getGuest().getMobile(), booking.getCheckInDate(),
                booking.getCheckOutDate(), booking.getTotalAmount(), booking.getPaidAmount(),
                booking.getPendingAmount(),
                Math.max(0, ChronoUnit.DAYS.between(booking.getCheckOutDate(), today)),
                booking.getStatus().name())).toList();
    }

    @Transactional(readOnly = true)
    public List<PaymentDtos.RefundResponse> refunds(Long hotelId) {
        accessService.assertPermission(Permission.PAYMENT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        return refundRepository.findAll().stream()
                .filter(r -> scope.contains(r.getHotel().getId()))
                .sorted((a, b) -> b.getProcessedAt().compareTo(a.getProcessedAt()))
                .map(r -> PaymentDtos.RefundResponse.from(r, userDirectoryService.nameOf(r.getProcessedBy())))
                .toList();
    }

    @Transactional(readOnly = true)
    public PaymentDtos.FinancialSummary summary(Long hotelId, LocalDate from, LocalDate to) {
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        Instant fromInstant = from.atStartOfDay(ZoneOffset.UTC).toInstant();
        Instant toInstant = to.plusDays(1).atStartOfDay(ZoneOffset.UTC).toInstant();
        BigDecimal collected = MoneyUtils.nullToZero(paymentRepository.sumCollected(scope, fromInstant, toInstant));
        BigDecimal refunded = MoneyUtils.nullToZero(refundRepository.sumRefunds(scope, fromInstant, toInstant));
        BigDecimal invoiced = MoneyUtils.nullToZero(invoiceRepository.sumInvoiced(scope, from, to));
        BigDecimal outstanding = MoneyUtils.nullToZero(invoiceRepository.sumOutstanding(scope));
        BigDecimal net = MoneyUtils.subtract(collected, refunded);
        return new PaymentDtos.FinancialSummary(collected, refunded, net, invoiced, outstanding,
                BigDecimal.ZERO, net, BigDecimal.ZERO, BigDecimal.ZERO);
    }

    @Transactional(readOnly = true)
    public List<PaymentDtos.Response> forBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> NotFoundException.of("Booking", bookingId));
        accessService.assertHotelAccess(booking.getHotel().getId());
        return paymentRepository.findByBookingIdOrderByPaidAtDesc(bookingId).stream()
                .map(p -> PaymentDtos.Response.from(p, userDirectoryService.nameOf(p.getReceivedBy())))
                .toList();
    }
}
