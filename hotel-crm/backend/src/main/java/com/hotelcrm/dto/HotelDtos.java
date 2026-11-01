package com.hotelcrm.dto;

import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.enums.HotelStatus;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalTime;
import java.util.List;

public final class HotelDtos {

    private HotelDtos() {
    }

    public record Request(
            @NotBlank(message = "Hotel name is required") @Size(max = 160) String name,
            @NotBlank(message = "Hotel code is required") @Size(max = 20) String code,
            @Size(max = 255) String address,
            @Size(max = 80) String city,
            @Size(max = 80) String state,
            @Size(max = 80) String country,
            @Size(max = 20) String postalCode,
            @Size(max = 30) String contactNumber,
            @Email(message = "Enter a valid email") @Size(max = 160) String email,
            @Size(max = 2000) String description,
            List<String> imageUrls,
            List<String> facilities,
            LocalTime checkInTime,
            LocalTime checkOutTime,
            @Size(max = 60) String timezone,
            @Min(value = 1, message = "Star rating must be between 1 and 5")
            @Max(value = 5, message = "Star rating must be between 1 and 5") Integer starRating,
            @Size(max = 30) String gstNumber,
            @DecimalMin(value = "0.0", message = "Tax rate cannot be negative")
            @DecimalMax(value = "28.0", message = "Tax rate cannot exceed 28%") BigDecimal taxRate,
            HotelStatus status) {
    }

    public record Response(
            Long id,
            String name,
            String code,
            String address,
            String city,
            String state,
            String country,
            String postalCode,
            String contactNumber,
            String email,
            String description,
            List<String> imageUrls,
            List<String> facilities,
            LocalTime checkInTime,
            LocalTime checkOutTime,
            String timezone,
            Integer starRating,
            String gstNumber,
            BigDecimal taxRate,
            HotelStatus status,
            long roomCount,
            long staffCount,
            long activeBookings,
            BigDecimal revenueThisMonth,
            Instant createdAt) {

        public static Response from(Hotel hotel) {
            return new Response(hotel.getId(), hotel.getName(), hotel.getCode(), hotel.getAddress(),
                    hotel.getCity(), hotel.getState(), hotel.getCountry(), hotel.getPostalCode(),
                    hotel.getContactNumber(), hotel.getEmail(), hotel.getDescription(),
                    hotel.getImageUrls(), hotel.getFacilities(), hotel.getCheckInTime(),
                    hotel.getCheckOutTime(), hotel.getTimezone(), hotel.getStarRating(),
                    hotel.getGstNumber(), hotel.getTaxRate(), hotel.getStatus(),
                    0, 0, 0, BigDecimal.ZERO, hotel.getCreatedAt());
        }
    }

    public record Summary(
            Long id,
            String name,
            String code,
            String city,
            String state,
            String imageUrl,
            Integer starRating,
            HotelStatus status,
            String timezone,
            BigDecimal taxRate) {

        public static Summary from(Hotel hotel) {
            String image = hotel.getImageUrls() == null || hotel.getImageUrls().isEmpty()
                    ? null : hotel.getImageUrls().get(0);
            return new Summary(hotel.getId(), hotel.getName(), hotel.getCode(), hotel.getCity(),
                    hotel.getState(), image, hotel.getStarRating(), hotel.getStatus(),
                    hotel.getTimezone(), hotel.getTaxRate());
        }
    }

    public record StatusRequest(@NotNull(message = "Status is required") HotelStatus status) {
    }

    public record HotelStats(
            Long hotelId,
            String hotelName,
            long totalRooms,
            long availableRooms,
            long occupiedRooms,
            BigDecimal revenueThisMonth,
            BigDecimal revenueThisYear,
            BigDecimal pendingPayments,
            BigDecimal occupancyPercent,
            BigDecimal adr) {
    }
}
