package com.hotelcrm.dto;

import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.entity.RoomCategory;
import com.hotelcrm.domain.entity.RoomPricing;
import com.hotelcrm.domain.enums.AdjustmentType;
import com.hotelcrm.domain.enums.BedType;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.PricingType;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.domain.enums.RoomType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public final class RoomDtos {

    private RoomDtos() {
    }

    public record CategoryRequest(
            @NotBlank(message = "Category name is required") @Size(max = 80) String name,
            @NotBlank(message = "Category code is required") @Size(max = 20) String code,
            @Size(max = 1000) String description,
            @NotNull(message = "Base price is required") @DecimalMin(value = "0.0", message = "Base price cannot be negative") BigDecimal basePrice,
            @DecimalMin(value = "0.0") BigDecimal weekendPrice,
            @DecimalMin(value = "0.0") BigDecimal extraPersonCharge,
            @DecimalMin(value = "0.0") BigDecimal extraBedCharge,
            @DecimalMin(value = "0.0") BigDecimal earlyCheckinCharge,
            @DecimalMin(value = "0.0") BigDecimal lateCheckoutCharge,
            @Min(value = 1, message = "Maximum occupancy must be at least 1") Integer maxOccupancy,
            List<String> amenities,
            List<String> imageUrls,
            Integer sortOrder,
            Boolean active) {
    }

    public record CategoryResponse(
            Long id,
            Long hotelId,
            String name,
            String code,
            String description,
            BigDecimal basePrice,
            BigDecimal weekendPrice,
            BigDecimal extraPersonCharge,
            BigDecimal extraBedCharge,
            BigDecimal earlyCheckinCharge,
            BigDecimal lateCheckoutCharge,
            Integer maxOccupancy,
            List<String> amenities,
            List<String> imageUrls,
            Integer sortOrder,
            boolean active,
            long roomCount) {

        public static CategoryResponse from(RoomCategory category, long roomCount) {
            return new CategoryResponse(category.getId(), category.getHotel().getId(), category.getName(),
                    category.getCode(), category.getDescription(), category.getBasePrice(),
                    category.getWeekendPrice(), category.getExtraPersonCharge(), category.getExtraBedCharge(),
                    category.getEarlyCheckinCharge(), category.getLateCheckoutCharge(),
                    category.getMaxOccupancy(), category.getAmenities(), category.getImageUrls(),
                    category.getSortOrder(), Boolean.TRUE.equals(category.getActive()), roomCount);
        }
    }

    public record RoomRequest(
            @NotNull(message = "Room category is required") Long categoryId,
            @NotBlank(message = "Room number is required") @Size(max = 20) String roomNumber,
            @Min(value = 0, message = "Floor cannot be negative") Integer floor,
            RoomType roomType,
            BedType bedType,
            @Min(value = 1, message = "Maximum occupancy must be at least 1") Integer maxOccupancy,
            Boolean ac,
            @Size(max = 1000) String description,
            List<String> imageUrls,
            List<String> amenities,
            @NotNull(message = "Base price is required") @DecimalMin(value = "0.0", message = "Base price cannot be negative") BigDecimal basePrice,
            @DecimalMin(value = "0.0") BigDecimal weekendPrice,
            @DecimalMin(value = "0.0") BigDecimal extraPersonCharge,
            RoomStatus status,
            HousekeepingCondition housekeepingStatus,
            Boolean active) {
    }

    public record RoomResponse(
            Long id,
            Long hotelId,
            String hotelName,
            Long categoryId,
            String categoryName,
            String categoryCode,
            String roomNumber,
            Integer floor,
            RoomType roomType,
            BedType bedType,
            Integer maxOccupancy,
            boolean ac,
            String description,
            List<String> imageUrls,
            List<String> amenities,
            BigDecimal basePrice,
            BigDecimal weekendPrice,
            BigDecimal extraPersonCharge,
            RoomStatus status,
            HousekeepingCondition housekeepingStatus,
            boolean active,
            BookingDtos.RoomSegment currentStay) {

        public static RoomResponse from(Room room) {
            return new RoomResponse(room.getId(), room.getHotel().getId(), room.getHotel().getName(),
                    room.getCategory().getId(), room.getCategory().getName(), room.getCategory().getCode(),
                    room.getRoomNumber(), room.getFloor(), room.getRoomType(), room.getBedType(),
                    room.getMaxOccupancy(), Boolean.TRUE.equals(room.getAc()), room.getDescription(),
                    room.getImageUrls(), room.getAmenities(), room.getBasePrice(), room.getWeekendPrice(),
                    room.getExtraPersonCharge(), room.getStatus(), room.getHousekeepingStatus(),
                    Boolean.TRUE.equals(room.getActive()), null);
        }
    }

    public record StatusRequest(
            RoomStatus status,
            HousekeepingCondition housekeepingStatus) {
    }

    public record RatePlanRequest(
            @NotBlank(message = "Plan name is required") @Size(max = 120) String name,
            @NotNull(message = "Pricing type is required") PricingType pricingType,
            @NotNull(message = "Adjustment type is required") AdjustmentType adjustmentType,
            @NotNull(message = "Amount is required") BigDecimal amount,
            LocalDate startDate,
            LocalDate endDate,
            @Size(max = 20) String daysOfWeek,
            Integer priority,
            Boolean active,
            Long categoryId,
            Long roomId) {
    }

    public record RatePlanResponse(
            Long id,
            Long hotelId,
            Long categoryId,
            String categoryName,
            Long roomId,
            String roomNumber,
            String name,
            PricingType pricingType,
            AdjustmentType adjustmentType,
            BigDecimal amount,
            LocalDate startDate,
            LocalDate endDate,
            String daysOfWeek,
            Integer priority,
            boolean active) {

        public static RatePlanResponse from(RoomPricing plan) {
            return new RatePlanResponse(plan.getId(), plan.getHotel().getId(),
                    plan.getCategory() == null ? null : plan.getCategory().getId(),
                    plan.getCategory() == null ? null : plan.getCategory().getName(),
                    plan.getRoom() == null ? null : plan.getRoom().getId(),
                    plan.getRoom() == null ? null : plan.getRoom().getRoomNumber(),
                    plan.getName(), plan.getPricingType(), plan.getAdjustmentType(), plan.getAmount(),
                    plan.getStartDate(), plan.getEndDate(), plan.getDaysOfWeek(), plan.getPriority(),
                    Boolean.TRUE.equals(plan.getActive()));
        }
    }

    public record QuoteRequest(
            @NotNull(message = "Category is required") Long categoryId,
            Long roomId,
            @NotNull(message = "Check-in date is required") LocalDate checkIn,
            @NotNull(message = "Check-out date is required") LocalDate checkOut,
            @Min(1) Integer adults,
            @Min(0) Integer children) {
    }

    public record NightlyRate(LocalDate date, BigDecimal rate, String appliedPlan) {
    }

    public record QuoteResponse(
            Long categoryId,
            String categoryName,
            LocalDate checkIn,
            LocalDate checkOut,
            int nights,
            BigDecimal averageRate,
            BigDecimal roomTotal,
            BigDecimal extraPersonCharge,
            BigDecimal total,
            List<NightlyRate> breakdown) {
    }

    public record AvailabilityResponse(
            Long roomId,
            String roomNumber,
            Long categoryId,
            String categoryName,
            BigDecimal basePrice,
            int availableCount) {
    }
}
