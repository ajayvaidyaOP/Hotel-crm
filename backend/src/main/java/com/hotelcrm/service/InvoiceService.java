package com.hotelcrm.service;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.entity.BookingRoom;
import com.hotelcrm.domain.entity.Invoice;
import com.hotelcrm.domain.entity.InvoiceLine;
import com.hotelcrm.domain.entity.Payment;
import com.hotelcrm.domain.entity.ServiceOrder;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.InvoiceLineType;
import com.hotelcrm.domain.enums.InvoiceStatus;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.ServiceOrderStatus;
import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.InvoiceRepository;
import com.hotelcrm.repository.PaymentRepository;
import com.hotelcrm.repository.ServiceOrderRepository;
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
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final ServiceOrderRepository serviceOrderRepository;
    private final PaymentService paymentService;
    private final DocumentService documentService;
    private final HotelAccessService accessService;
    private final AuditService auditService;

    /** Builds (or returns) the GST invoice for a booking, freezing all charges at checkout time. */
    @Transactional
    public PaymentDtos.InvoiceResponse generateForBooking(PaymentDtos.GenerateInvoiceRequest request) {
        accessService.assertPermission(Permission.INVOICE_WRITE);
        Booking booking = bookingRepository.findDetailedById(request.bookingId())
                .orElseThrow(() -> NotFoundException.of("Booking", request.bookingId()));
        accessService.assertHotelAccess(booking.getHotel().getId());
        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new BusinessException("Cancelled bookings cannot be invoiced");
        }
        List<Invoice> existing = invoiceRepository.findByBookingId(booking.getId());
        if (!existing.isEmpty()) {
            Invoice invoice = invoiceRepository.findWithLines(existing.get(0).getId())
                    .orElse(existing.get(0));
            return PaymentDtos.InvoiceResponse.from(invoice);
        }
        return PaymentDtos.InvoiceResponse.from(createInvoice(booking, request.taxRate(), request.notes(),
                request.includeServices() == null || request.includeServices()));
    }

    @Transactional
    public Invoice createInvoice(Booking booking, BigDecimal taxRate, String notes, boolean includeServices) {
        Invoice invoice = Invoice.builder()
                .invoiceNumber(CodeGenerator.invoiceNumber(booking.getHotel().getCode(),
                        invoiceRepository.countByHotelId(booking.getHotel().getId()) + 1))
                .hotel(booking.getHotel())
                .booking(booking)
                .guest(booking.getGuest())
                .issueDate(LocalDate.now())
                .dueDate(LocalDate.now().plusDays(7))
                .gstin(booking.getHotel().getGstNumber())
                .billToName(booking.getGuest().getFullName())
                .billToAddress(buildGuestAddress(booking))
                .notes(notes)
                .createdBy(accessService.currentUserId())
                .status(InvoiceStatus.ISSUED)
                .build();

        BigDecimal subtotal = BigDecimal.ZERO;
        for (BookingRoom segment : booking.getRooms()) {
            String description = segment.getCategory().getName()
                    + (segment.getRoom() == null ? "" : " - Room " + segment.getRoom().getRoomNumber())
                    + ", " + segment.getNights() + " night(s)";
            BigDecimal amount = MoneyUtils.scale(segment.getTotalAmount());
            invoice.addLine(InvoiceLine.builder()
                    .lineType(InvoiceLineType.ROOM)
                    .description(description)
                    .quantity(BigDecimal.valueOf(segment.getNights()))
                    .unitPrice(MoneyUtils.scale(segment.getRatePerNight()))
                    .amount(amount)
                    .build());
            subtotal = subtotal.add(amount);
        }
        if (includeServices && booking.getId() != null) {
            for (ServiceOrder order : serviceOrderRepository.findByBookingIdOrderByOrderedAtDesc(booking.getId())) {
                if (order.getStatus() == ServiceOrderStatus.CANCELLED || order.getStatus() == ServiceOrderStatus.BILLED) {
                    continue;
                }
                BigDecimal amount = MoneyUtils.multiply(order.getAmount(),
                        BigDecimal.valueOf(order.getQuantity() == null ? 1 : order.getQuantity()));
                invoice.addLine(InvoiceLine.builder()
                        .lineType(InvoiceLineType.SERVICE)
                        .description(order.getOrderType().getLabel() + ": " + order.getDescription())
                        .quantity(BigDecimal.valueOf(order.getQuantity() == null ? 1 : order.getQuantity()))
                        .unitPrice(MoneyUtils.scale(order.getAmount()))
                        .amount(amount)
                        .build());
                subtotal = subtotal.add(amount);
                order.setStatus(ServiceOrderStatus.BILLED);
                serviceOrderRepository.save(order);
            }
        }
        if (booking.getExtraCharges() != null && booking.getExtraCharges().compareTo(BigDecimal.ZERO) > 0) {
            invoice.addLine(InvoiceLine.builder()
                    .lineType(InvoiceLineType.EXTRA)
                    .description("Additional charges (early check-in / late check-out / extras)")
                    .quantity(BigDecimal.ONE)
                    .unitPrice(MoneyUtils.scale(booking.getExtraCharges()))
                    .amount(MoneyUtils.scale(booking.getExtraCharges()))
                    .build());
            subtotal = subtotal.add(booking.getExtraCharges());
        }

        BigDecimal discount = MoneyUtils.nullToZero(booking.getDiscountAmount());
        if (discount.compareTo(subtotal) > 0) {
            discount = subtotal;
        }
        BigDecimal rate = taxRate == null ? MoneyUtils.nullToZero(booking.getHotel().getTaxRate()) : taxRate;
        BigDecimal taxable = MoneyUtils.subtract(subtotal, discount);
        BigDecimal tax = MoneyUtils.percentOf(taxable, rate);
        BigDecimal total = MoneyUtils.add(taxable, tax);

        invoice.setSubtotal(MoneyUtils.scale(subtotal));
        invoice.setDiscount(MoneyUtils.scale(discount));
        invoice.setTaxRate(rate);
        invoice.setTaxAmount(tax);
        invoice.setTotal(total);
        invoice.setAmountPaid(BigDecimal.ZERO);
        invoice.setBalance(total);
        invoiceRepository.save(invoice);

        // attach already collected booking payments to this invoice so the ledger stays auditable
        for (Payment payment : paymentRepository.findByBookingIdOrderByPaidAtDesc(booking.getId())) {
            if (payment.getInvoice() == null) {
                payment.setInvoice(invoice);
                paymentRepository.save(payment);
            }
        }
        paymentService.recalculateInvoice(invoice);
        auditService.record(booking.getHotel().getId(), "INVOICE_ISSUED", "Invoice", invoice.getId(),
                "Invoice " + invoice.getInvoiceNumber() + " issued for " + booking.getBookingCode());
        return invoice;
    }

    @Transactional(readOnly = true)
    public PaymentDtos.InvoiceResponse get(Long id) {
        accessService.assertPermission(Permission.INVOICE_READ);
        Invoice invoice = invoiceRepository.findWithLines(id)
                .orElseThrow(() -> NotFoundException.of("Invoice", id));
        accessService.assertHotelAccess(invoice.getHotel().getId());
        return PaymentDtos.InvoiceResponse.from(invoice);
    }

    @Transactional(readOnly = true)
    public PageResponse<PaymentDtos.InvoiceResponse> list(Long hotelId, LocalDate from, LocalDate to,
                                                          InvoiceStatus status, String search, int page, int size) {
        accessService.assertPermission(Permission.INVOICE_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        Specification<Invoice> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(root.get("hotel").get("id").in(scope));
            predicates.add(cb.between(root.get("issueDate"), start, end));
            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("invoiceNumber")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("billToName"), "")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("booking").get("bookingCode"), "")), like)));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        Page<Invoice> result = invoiceRepository.findAll(spec, PageRequest.of(Math.max(page, 0),
                Math.min(Math.max(size, 1), 100), Sort.by(Sort.Direction.DESC, "issueDate", "id")));
        return PageResponse.of(result, PaymentDtos.InvoiceResponse::from);
    }

    @Transactional
    public PaymentDtos.InvoiceResponse settle(Long invoiceId, PaymentDtos.SettleInvoiceRequest request) {
        accessService.assertPermission(Permission.PAYMENT_WRITE);
        Invoice invoice = invoiceRepository.findWithLines(invoiceId)
                .orElseThrow(() -> NotFoundException.of("Invoice", invoiceId));
        accessService.assertHotelAccess(invoice.getHotel().getId());
        if (invoice.getStatus() == InvoiceStatus.CANCELLED) {
            throw new BusinessException("This invoice has been cancelled");
        }
        paymentService.record(new PaymentDtos.Request(invoice.getHotel().getId(),
                invoice.getBooking() == null ? null : invoice.getBooking().getId(), invoice.getId(),
                request.amount(), request.method(), com.hotelcrm.domain.enums.PaymentType.SETTLEMENT,
                request.referenceNo(), request.notes(), null));
        Invoice refreshed = invoiceRepository.findWithLines(invoiceId).orElse(invoice);
        return PaymentDtos.InvoiceResponse.from(refreshed);
    }

    @Transactional
    public PaymentDtos.InvoiceResponse cancel(Long invoiceId) {
        accessService.assertPermission(Permission.INVOICE_WRITE);
        Invoice invoice = invoiceRepository.findWithLines(invoiceId)
                .orElseThrow(() -> NotFoundException.of("Invoice", invoiceId));
        accessService.assertHotelAccess(invoice.getHotel().getId());
        if (invoice.getAmountPaid().compareTo(BigDecimal.ZERO) > 0) {
            throw new BusinessException("Cannot cancel an invoice that already has payments. Refund the payment first.");
        }
        invoice.setStatus(InvoiceStatus.CANCELLED);
        invoiceRepository.save(invoice);
        auditService.record(invoice.getHotel().getId(), "INVOICE_CANCELLED", "Invoice", invoice.getId(),
                "Invoice " + invoice.getInvoiceNumber() + " cancelled");
        return PaymentDtos.InvoiceResponse.from(invoice);
    }

    @Transactional(readOnly = true)
    public List<PaymentDtos.InvoiceResponse> forBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> NotFoundException.of("Booking", bookingId));
        accessService.assertHotelAccess(booking.getHotel().getId());
        return invoiceRepository.findByBookingId(bookingId).stream()
                .map(invoice -> invoiceRepository.findWithLines(invoice.getId()).orElse(invoice))
                .map(PaymentDtos.InvoiceResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public byte[] pdf(Long invoiceId) {
        Invoice invoice = invoiceRepository.findWithLines(invoiceId)
                .orElseThrow(() -> NotFoundException.of("Invoice", invoiceId));
        accessService.assertHotelAccess(invoice.getHotel().getId());
        return documentService.invoicePdf(invoice);
    }

    @Transactional(readOnly = true)
    public Invoice requireInvoice(Long id) {
        return invoiceRepository.findById(id).orElseThrow(() -> NotFoundException.of("Invoice", id));
    }

    private String buildGuestAddress(Booking booking) {
        StringBuilder sb = new StringBuilder();
        if (booking.getGuest().getAddress() != null) {
            sb.append(booking.getGuest().getAddress());
        }
        if (booking.getGuest().getCity() != null) {
            sb.append(sb.length() > 0 ? ", " : "").append(booking.getGuest().getCity());
        }
        if (booking.getGuest().getCountry() != null) {
            sb.append(sb.length() > 0 ? ", " : "").append(booking.getGuest().getCountry());
        }
        return sb.toString();
    }
}
