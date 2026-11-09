package com.hotelcrm.dto;

import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.enums.BookingPaymentStatus;
import com.hotelcrm.domain.enums.BookingSource;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.PaymentMethod;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

public final class BookingDtos {

    private BookingDtos() {
    }

    public record RoomLineRequest(
            Long roomId,
            @NotNull(message = "Room category is required") Long categoryId,
            @DecimalMin(value = "0.0", message = "Rate cannot be negative") BigDecimal ratePerNight,
            @Min(value = 0, message = "Extra beds cannot be negative") Integer extraBeds) {
    }

    /** Inline guest details, used by walk-in / quick booking flows. */
    public record NewGuestRequest(
            @NotBlank(message = "Guest name is required") @Size(max = 120) String fullName,
            @NotBlank(message = "Mobile number is required") @Size(max = 30) String mobile,
            @Email(message = "Enter a valid email") String email,
            String address,
            String city,
            String state,
            String country,
            String idProofType,
            String idProofNumber,
            String specialRequests,
            Boolean vip) {
    }

    public record Request(
            @NotNull(message = "Hotel is required") Long hotelId,
            Long guestId,
            @Valid NewGuestRequest newGuest,
            @NotNull(message = "Check-in date is required") LocalDate checkInDate,
            @NotNull(message = "Check-out date is required") LocalDate checkOutDate,
            @NotNull(message = "Number of adults is required") @Min(value = 1, message = "At least one adult is required") Integer adults,
            @Min(value = 0, message = "Children cannot be negative") Integer children,
            BookingSource bookingSource,
            BookingStatus status,
            @NotEmpty(message = "At least one room is required") @Valid List<RoomLineRequest> rooms,
            String couponCode,
            @DecimalMin(value = "0.0", message = "Discount cannot be negative") BigDecimal discountAmount,
            @DecimalMin(value = "0.0", message = "Advance cannot be negative") BigDecimal advanceAmount,
            PaymentMethod advanceMethod,
            @Size(max = 1000) String specialRequests,
            @Size(max = 1000) String internalNotes) {
    }

    public record UpdateRequest(
            @NotNull(message = "Check-in date is required") LocalDate checkInDate,
            @NotNull(message = "Check-out date is required") LocalDate checkOutDate,
            @NotNull @Min(1) Integer adults,
            @Min(0) Integer children,
            BookingSource bookingSource,
            @NotEmpty @Valid List<RoomLineRequest> rooms,
            String couponCode,
            @DecimalMin(value = "0.0") BigDecimal discountAmount,
            @Size(max = 1000) String specialRequests,
            @Size(max = 1000) String internalNotes) {
    }

    public record RoomSegment(
            Long id,
            Long roomId,
            String roomNumber,
            Long categoryId,
            String categoryName,
            LocalDate checkInDate,
            LocalDate checkOutDate,
            int nights,
            BigDecimal ratePerNight,
            BigDecimal totalAmount,
            String status) {

        public static RoomSegment from(com.hotelcrm.domain.entity.BookingRoom segment) {
            return new RoomSegment(segment.getId(), segment.getRoomId(), segment.getRoomNumber(),
                    segment.getCategory().getId(), segment.getCategory().getName(),
                    segment.getCheckInDate(), segment.getCheckOutDate(), segment.getNights(),
                    segment.getRatePerNight(), segment.getTotalAmount(), segment.getStatus().name());
        }
    }

    public record Summary(
            Long id,
            String bookingCode,
            Long hotelId,
            String hotelName,
            Long guestId,
            String guestName,
            String guestMobile,
            LocalDate checkInDate,
            LocalDate checkOutDate,
            int nights,
            int adults,
            int children,
            BookingStatus status,
            BookingPaymentStatus paymentStatus,
            BigDecimal totalAmount,
            BigDecimal paidAmount,
            BigDecimal pendingAmount,
            BookingSource bookingSource,
            List<String> roomNumbers,
            Instant createdAt,
            Instant actualCheckInAt,
            Instant actualCheckOutAt) {

        public static Summary from(Booking booking) {
            List<String> rooms = booking.getRooms() == null ? List.of()
                    : booking.getRooms().stream().map(r -> r.getRoomNumber() == null ? "Unassigned" : r.getRoomNumber()).toList();
            return new Summary(booking.getId(), booking.getBookingCode(), booking.getHotel().getId(),
                    booking.getHotel().getName(), booking.getGuest().getId(), booking.getGuest().getFullName(),
                    booking.getGuest().getMobile(), booking.getCheckInDate(), booking.getCheckOutDate(),
                    booking.getNights(), booking.getAdults(), booking.getChildren(), booking.getStatus(),
                    booking.getPaymentStatus(), booking.getTotalAmount(), booking.getPaidAmount(),
                    booking.getPendingAmount(), booking.getBookingSource(), rooms, booking.getCreatedAt(),
                    booking.getActualCheckInAt(), booking.getActualCheckOutAt());
        }
    }

    public record Response(
            Summary summary,
            List<RoomSegment> rooms,
            List<PaymentDtos.Response> payments,
            List<OpsDtos.ServiceOrderResponse> services,
            String specialRequests,
            String internalNotes,
            String cancellationReason,
            Instant cancelledAt,
            BigDecimal roomChargeTotal,
            BigDecimal extraCharges,
            BigDecimal discountAmount,
            BigDecimal taxAmount,
            BigDecimal advanceAmount,
            String couponCode,
            Long invoiceId,
            String invoiceNumber,
            String guestEmail,
            String guestIdProofMasked,
            String checkedInByName,
            String checkedOutByName) {
    }

    public record CheckInRequest(
            List<RoomAssignment> assignments,
            @DecimalMin(value = "0.0", message = "Charge cannot be negative") BigDecimal earlyCheckInCharge,
            @Size(max = 500) String notes,
            Boolean idVerified) {
    }

    public record RoomAssignment(Long segmentId, Long roomId) {
    }

    public record CheckOutRequest(
            @DecimalMin(value = "0.0") BigDecimal extraCharges,
            @DecimalMin(value = "0.0") BigDecimal lateCheckOutCharge,
            @DecimalMin(value = "0.0") BigDecimal discount,
            Boolean collectPayment,
            PaymentMethod paymentMethod,
            String paymentReference,
            @Size(max = 500) String notes) {
    }

    public record CheckOutResponse(Summary booking, PaymentDtos.InvoiceResponse invoice, BigDecimal settledAmount) {
    }

    public record CancelRequest(
            @NotBlank(message = "Cancellation reason is required") @Size(max = 500) String reason,
            @DecimalMin(value = "0.0", message = "Refund cannot be negative") BigDecimal refundAmount,
            PaymentMethod refundMethod) {
    }

    public record TransferRoomRequest(
            @NotNull(message = "Segment is required") Long segmentId,
            @NotNull(message = "New room is required") Long newRoomId,
            @Size(max = 300) String reason) {
    }

    public record RescheduleRequest(
            @NotNull(message = "Check-in date is required") LocalDate checkInDate,
            @NotNull(message = "Check-out date is required") LocalDate checkOutDate,
            Long roomId,
            Long segmentId) {
    }

    public record TimelineRoom(
            Long roomId,
            String roomNumber,
            Integer floor,
            String categoryName,
            String status,
            String housekeepingStatus,
            BigDecimal basePrice) {
    }

    public record TimelineEntry(
            Long bookingId,
            String bookingCode,
            Long segmentId,
            Long roomId,
            String roomNumber,
            String guestName,
            String guestMobile,
            LocalDate checkInDate,
            LocalDate checkOutDate,
            int nights,
            BookingStatus status,
            BookingPaymentStatus paymentStatus,
            BigDecimal totalAmount,
            BigDecimal pendingAmount,
            int adults,
            int children) {
    }

    public record CalendarResponse(
            Long hotelId,
            LocalDate from,
            LocalDate to,
            List<TimelineRoom> rooms,
            List<TimelineEntry> entries) {
    }

    public record DayOperations(
            LocalDate date,
            List<Summary> arrivals,
            List<Summary> departures,
            List<Summary> inHouse) {
    }

    public record UpcomingBooking(
            Long id,
            String bookingCode,
            String guestName,
            String guestMobile,
            LocalDate checkInDate,
            LocalDate checkOutDate,
            int rooms,
            BookingStatus status,
            BookingPaymentStatus paymentStatus) {
    }
}
