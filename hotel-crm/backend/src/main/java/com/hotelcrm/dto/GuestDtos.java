package com.hotelcrm.dto;

import com.hotelcrm.domain.entity.Guest;
import com.hotelcrm.domain.enums.FeedbackStatus;
import com.hotelcrm.domain.enums.FeedbackType;
import com.hotelcrm.domain.enums.GuestCategory;
import com.hotelcrm.domain.enums.IdProofType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

public final class GuestDtos {

    private GuestDtos() {
    }

    public record Request(
            @NotBlank(message = "Guest name is required") @Size(max = 120) String fullName,
            @NotBlank(message = "Mobile number is required") @Size(max = 30) String mobile,
            @Email(message = "Enter a valid email") @Size(max = 160) String email,
            @Size(max = 255) String address,
            @Size(max = 80) String city,
            @Size(max = 80) String state,
            @Size(max = 80) String country,
            IdProofType idProofType,
            @Size(max = 60) String idProofNumber,
            GuestCategory category,
            Boolean vip,
            Boolean blacklisted,
            @Size(max = 1000) String notes,
            @Size(max = 1000) String specialRequests,
            Long hotelId) {
    }

    public record Response(
            Long id,
            String fullName,
            String mobile,
            String email,
            String address,
            String city,
            String state,
            String country,
            IdProofType idProofType,
            String idProofMasked,
            GuestCategory category,
            boolean vip,
            boolean blacklisted,
            String notes,
            String specialRequests,
            Integer loyaltyPoints,
            long totalBookings,
            long completedStays,
            BigDecimal totalSpending,
            BigDecimal outstanding,
            LocalDate lastStayDate,
            Instant createdAt,
            String hotelName) {

        public static Response from(Guest guest) {
            String masked = guest.getIdProofLast4() == null ? null
                    : "XXXX XXXX " + guest.getIdProofLast4();
            return new Response(guest.getId(), guest.getFullName(), guest.getMobile(), guest.getEmail(),
                    guest.getAddress(), guest.getCity(), guest.getState(), guest.getCountry(),
                    guest.getIdProofType(), masked, guest.getCategory(),
                    Boolean.TRUE.equals(guest.getVip()), Boolean.TRUE.equals(guest.getBlacklisted()),
                    guest.getNotes(), guest.getSpecialRequests(), guest.getLoyaltyPoints(),
                    0, 0, BigDecimal.ZERO, BigDecimal.ZERO, null, guest.getCreatedAt(),
                    guest.getHotel() == null ? null : guest.getHotel().getName());
        }
    }

    public record Detail(
            Response guest,
            List<BookingDtos.Summary> bookings,
            List<PaymentDtos.Response> payments,
            List<OpsDtos.FeedbackRow> feedback,
            List<OpsDtos.ServiceOrderResponse> services) {
    }

    public record FeedbackRequest(
            @NotBlank(message = "Hotel is required") Long hotelId,
            Long guestId,
            Long bookingId,
            FeedbackType type,
            @Min(value = 1, message = "Rating must be between 1 and 5")
            @Max(value = 5, message = "Rating must be between 1 and 5") Integer rating,
            @NotBlank(message = "Comments are required") @Size(max = 1500) String comments) {
    }

    public record FeedbackResolveRequest(
            @NotBlank(message = "Resolution is required") @Size(max = 1000) String resolution) {
    }

    public record FeedbackResponse(
            Long id,
            Long hotelId,
            String hotelName,
            Long guestId,
            String guestName,
            Long bookingId,
            String bookingCode,
            FeedbackType type,
            Integer rating,
            String comments,
            FeedbackStatus status,
            String resolution,
            Instant resolvedAt,
            Instant createdAt) {
    }
}
