package com.hotelcrm.dto;

import com.hotelcrm.domain.entity.Invoice;
import com.hotelcrm.domain.entity.InvoiceLine;
import com.hotelcrm.domain.entity.Payment;
import com.hotelcrm.domain.entity.Refund;
import com.hotelcrm.domain.enums.InvoiceLineType;
import com.hotelcrm.domain.enums.InvoiceStatus;
import com.hotelcrm.domain.enums.PaymentMethod;
import com.hotelcrm.domain.enums.PaymentStatus;
import com.hotelcrm.domain.enums.PaymentType;
import com.hotelcrm.domain.enums.RefundStatus;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

public final class PaymentDtos {

    private PaymentDtos() {
    }

    public record Request(
            @NotNull(message = "Hotel is required") Long hotelId,
            Long bookingId,
            Long invoiceId,
            @NotNull(message = "Amount is required")
            @DecimalMin(value = "0.01", message = "Amount must be greater than zero") BigDecimal amount,
            @NotNull(message = "Payment method is required") PaymentMethod method,
            PaymentType paymentType,
            @Size(max = 80) String referenceNo,
            @Size(max = 500) String notes,
            Instant paidAt) {
    }

    public record Response(
            Long id,
            String paymentCode,
            Long hotelId,
            String hotelName,
            Long bookingId,
            String bookingCode,
            Long invoiceId,
            String invoiceNumber,
            String guestName,
            BigDecimal amount,
            PaymentMethod method,
            PaymentType paymentType,
            PaymentStatus status,
            String referenceNo,
            String notes,
            Instant paidAt,
            String receivedByName) {

        public static Response from(Payment payment, String receivedByName) {
            return new Response(payment.getId(), payment.getPaymentCode(),
                    payment.getHotel().getId(), payment.getHotel().getName(),
                    payment.getBooking() == null ? null : payment.getBooking().getId(),
                    payment.getBooking() == null ? null : payment.getBooking().getBookingCode(),
                    payment.getInvoice() == null ? null : payment.getInvoice().getId(),
                    payment.getInvoice() == null ? null : payment.getInvoice().getInvoiceNumber(),
                    payment.getBooking() == null ? null : payment.getBooking().getGuest().getFullName(),
                    payment.getAmount(), payment.getMethod(), payment.getPaymentType(), payment.getStatus(),
                    payment.getReferenceNo(), payment.getNotes(), payment.getPaidAt(), receivedByName);
        }
    }

    public record RefundRequest(
            Long paymentId,
            @NotNull(message = "Booking is required") Long bookingId,
            @NotNull(message = "Amount is required")
            @DecimalMin(value = "0.01", message = "Refund must be greater than zero") BigDecimal amount,
            @NotBlank(message = "Reason is required") @Size(max = 300) String reason,
            PaymentMethod method) {
    }

    public record RefundResponse(
            Long id,
            Long hotelId,
            Long bookingId,
            String bookingCode,
            Long paymentId,
            BigDecimal amount,
            String reason,
            PaymentMethod method,
            RefundStatus status,
            Instant processedAt,
            String processedByName) {

        public static RefundResponse from(Refund refund, String processedByName) {
            return new RefundResponse(refund.getId(), refund.getHotel().getId(),
                    refund.getBooking() == null ? null : refund.getBooking().getId(),
                    refund.getBooking() == null ? null : refund.getBooking().getBookingCode(),
                    refund.getPayment() == null ? null : refund.getPayment().getId(),
                    refund.getAmount(), refund.getReason(), refund.getMethod(), refund.getStatus(),
                    refund.getProcessedAt(), processedByName);
        }
    }

    public record InvoiceLineResponse(
            Long id,
            InvoiceLineType lineType,
            String description,
            BigDecimal quantity,
            BigDecimal unitPrice,
            BigDecimal amount) {

        public static InvoiceLineResponse from(InvoiceLine line) {
            return new InvoiceLineResponse(line.getId(), line.getLineType(), line.getDescription(),
                    line.getQuantity(), line.getUnitPrice(), line.getAmount());
        }
    }

    public record InvoiceResponse(
            Long id,
            String invoiceNumber,
            Long hotelId,
            String hotelName,
            String hotelAddress,
            String hotelGstin,
            Long bookingId,
            String bookingCode,
            Long guestId,
            String guestName,
            String billToAddress,
            LocalDate issueDate,
            LocalDate dueDate,
            BigDecimal subtotal,
            BigDecimal discount,
            BigDecimal taxRate,
            BigDecimal taxAmount,
            BigDecimal total,
            BigDecimal amountPaid,
            BigDecimal balance,
            InvoiceStatus status,
            String notes,
            List<InvoiceLineResponse> lines) {

        public static InvoiceResponse from(Invoice invoice) {
            return new InvoiceResponse(invoice.getId(), invoice.getInvoiceNumber(),
                    invoice.getHotel().getId(), invoice.getHotel().getName(),
                    buildAddress(invoice.getHotel().getAddress(), invoice.getHotel().getCity(), invoice.getHotel().getState()),
                    invoice.getGstin(),
                    invoice.getBooking() == null ? null : invoice.getBooking().getId(),
                    invoice.getBooking() == null ? null : invoice.getBooking().getBookingCode(),
                    invoice.getGuest() == null ? null : invoice.getGuest().getId(),
                    invoice.getBillToName() != null ? invoice.getBillToName()
                            : (invoice.getGuest() == null ? null : invoice.getGuest().getFullName()),
                    invoice.getBillToAddress(), invoice.getIssueDate(), invoice.getDueDate(),
                    invoice.getSubtotal(), invoice.getDiscount(), invoice.getTaxRate(), invoice.getTaxAmount(),
                    invoice.getTotal(), invoice.getAmountPaid(), invoice.getBalance(), invoice.getStatus(),
                    invoice.getNotes(),
                    invoice.getLines() == null ? List.of()
                            : invoice.getLines().stream().map(InvoiceLineResponse::from).toList());
        }

        private static String buildAddress(String address, String city, String state) {
            StringBuilder sb = new StringBuilder();
            if (address != null) {
                sb.append(address);
            }
            if (city != null) {
                sb.append(sb.length() > 0 ? ", " : "").append(city);
            }
            if (state != null) {
                sb.append(sb.length() > 0 ? ", " : "").append(state);
            }
            return sb.toString();
        }
    }

    public record GenerateInvoiceRequest(
            @NotNull(message = "Booking is required") Long bookingId,
            BigDecimal taxRate,
            @Size(max = 500) String notes,
            Boolean includeServices) {
    }

    public record SettleInvoiceRequest(
            @NotNull(message = "Amount is required")
            @DecimalMin(value = "0.01", message = "Amount must be greater than zero") BigDecimal amount,
            @NotNull(message = "Payment method is required") PaymentMethod method,
            @Size(max = 80) String referenceNo,
            @Size(max = 500) String notes) {
    }

    public record PendingPaymentRow(
            Long bookingId,
            String bookingCode,
            Long hotelId,
            String hotelName,
            String guestName,
            String guestMobile,
            LocalDate checkInDate,
            LocalDate checkOutDate,
            BigDecimal totalAmount,
            BigDecimal paidAmount,
            BigDecimal pendingAmount,
            long daysOverdue,
            String status) {
    }

    public record FinancialSummary(
            BigDecimal collected,
            BigDecimal refunded,
            BigDecimal netCollected,
            BigDecimal invoiced,
            BigDecimal outstanding,
            BigDecimal expenses,
            BigDecimal profit,
            BigDecimal taxCollected,
            BigDecimal serviceRevenue) {
    }
}
