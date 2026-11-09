package com.hotelcrm.dto;

import com.hotelcrm.domain.entity.Expense;
import com.hotelcrm.domain.entity.GuestFeedback;
import com.hotelcrm.domain.entity.HousekeepingTask;
import com.hotelcrm.domain.entity.LostAndFound;
import com.hotelcrm.domain.entity.MaintenanceRequest;
import com.hotelcrm.domain.entity.ServiceOrder;
import com.hotelcrm.domain.enums.ExpenseCategory;
import com.hotelcrm.domain.enums.FeedbackStatus;
import com.hotelcrm.domain.enums.FeedbackType;
import com.hotelcrm.domain.enums.HousekeepingTaskStatus;
import com.hotelcrm.domain.enums.HousekeepingTaskType;
import com.hotelcrm.domain.enums.LostFoundStatus;
import com.hotelcrm.domain.enums.MaintenanceStatus;
import com.hotelcrm.domain.enums.PaymentMethod;
import com.hotelcrm.domain.enums.ServiceOrderStatus;
import com.hotelcrm.domain.enums.ServiceOrderType;
import com.hotelcrm.domain.enums.TaskPriority;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

public final class OpsDtos {

    private OpsDtos() {
    }

    /* ------------------------------ expenses ------------------------------ */
    public record ExpenseRequest(
            @NotNull(message = "Hotel is required") Long hotelId,
            @NotNull(message = "Category is required") ExpenseCategory category,
            @NotBlank(message = "Description is required") @Size(max = 300) String description,
            @NotNull(message = "Amount is required")
            @DecimalMin(value = "0.01", message = "Amount must be greater than zero") BigDecimal amount,
            @NotNull(message = "Expense date is required") LocalDate expenseDate,
            @Size(max = 160) String vendor,
            PaymentMethod paymentMethod,
            @Size(max = 80) String referenceNo) {
    }

    public record ExpenseResponse(
            Long id,
            Long hotelId,
            String hotelName,
            ExpenseCategory category,
            String description,
            BigDecimal amount,
            LocalDate expenseDate,
            String vendor,
            PaymentMethod paymentMethod,
            String referenceNo,
            String createdByName,
            Instant createdAt) {

        public static ExpenseResponse from(Expense expense, String createdByName) {
            return new ExpenseResponse(expense.getId(), expense.getHotel().getId(),
                    expense.getHotel().getName(), expense.getCategory(), expense.getDescription(),
                    expense.getAmount(), expense.getExpenseDate(), expense.getVendor(),
                    expense.getPaymentMethod(), expense.getReferenceNo(), createdByName, expense.getCreatedAt());
        }
    }

    /* --------------------------- housekeeping ----------------------------- */
    public record HousekeepingRequest(
            @NotNull(message = "Hotel is required") Long hotelId,
            Long roomId,
            HousekeepingTaskType taskType,
            HousekeepingTaskStatus status,
            TaskPriority priority,
            Long assignedTo,
            @Size(max = 1000) String notes,
            LocalDate scheduledDate) {
    }

    public record HousekeepingStatusRequest(
            @NotNull(message = "Status is required") HousekeepingTaskStatus status,
            Long assignedTo,
            @Size(max = 500) String notes) {
    }

    public record HousekeepingResponse(
            Long id,
            Long hotelId,
            String hotelName,
            Long roomId,
            String roomNumber,
            String roomCategory,
            HousekeepingTaskType taskType,
            HousekeepingTaskStatus status,
            TaskPriority priority,
            Long assignedTo,
            String assignedToName,
            String notes,
            LocalDate scheduledDate,
            Instant startedAt,
            Instant completedAt,
            Instant inspectedAt,
            Instant createdAt) {

        public static HousekeepingResponse from(HousekeepingTask task, String assignedToName) {
            return new HousekeepingResponse(task.getId(), task.getHotel().getId(), task.getHotel().getName(),
                    task.getRoom() == null ? null : task.getRoom().getId(),
                    task.getRoom() == null ? null : task.getRoom().getRoomNumber(),
                    task.getRoom() == null ? null : task.getRoom().getCategory().getName(),
                    task.getTaskType(), task.getStatus(), task.getPriority(), task.getAssignedTo(),
                    assignedToName, task.getNotes(), task.getScheduledDate(), task.getStartedAt(),
                    task.getCompletedAt(), task.getInspectedAt(), task.getCreatedAt());
        }
    }

    /* ---------------------------- maintenance ----------------------------- */
    public record MaintenanceRequestDto(
            @NotNull(message = "Hotel is required") Long hotelId,
            Long roomId,
            @NotBlank(message = "Title is required") @Size(max = 160) String title,
            @Size(max = 1000) String description,
            @Size(max = 40) String category,
            TaskPriority priority,
            Long assignedTo) {
    }

    public record MaintenanceUpdateRequest(
            MaintenanceStatus status,
            Long assignedTo,
            @DecimalMin(value = "0.0") BigDecimal cost,
            @Size(max = 500) String resolutionNote) {
    }

    public record MaintenanceResponse(
            Long id,
            Long hotelId,
            String hotelName,
            Long roomId,
            String roomNumber,
            String title,
            String description,
            String category,
            TaskPriority priority,
            MaintenanceStatus status,
            String reportedByName,
            String assignedToName,
            BigDecimal cost,
            Instant reportedAt,
            Instant resolvedAt,
            String resolutionNote) {

        public static MaintenanceResponse from(MaintenanceRequest request, String reportedByName, String assignedToName) {
            return new MaintenanceResponse(request.getId(), request.getHotel().getId(),
                    request.getHotel().getName(),
                    request.getRoom() == null ? null : request.getRoom().getId(),
                    request.getRoom() == null ? null : request.getRoom().getRoomNumber(),
                    request.getTitle(), request.getDescription(), request.getCategory(), request.getPriority(),
                    request.getStatus(), reportedByName, assignedToName, request.getCost(),
                    request.getReportedAt(), request.getResolvedAt(), request.getResolutionNote());
        }
    }

    /* --------------------------- lost & found ----------------------------- */
    public record LostFoundRequest(
            @NotNull(message = "Hotel is required") Long hotelId,
            Long roomId,
            Long guestId,
            @NotBlank(message = "Item description is required") @Size(max = 500) String itemDescription,
            @Size(max = 120) String storageLocation,
            @Size(max = 500) String notes,
            Instant foundAt) {
    }

    public record LostFoundStatusRequest(@NotNull LostFoundStatus status) {
    }

    public record LostFoundResponse(
            Long id,
            Long hotelId,
            String hotelName,
            Long roomId,
            String roomNumber,
            Long guestId,
            String guestName,
            String itemDescription,
            String foundByName,
            Instant foundAt,
            LostFoundStatus status,
            String storageLocation,
            String notes) {

        public static LostFoundResponse from(LostAndFound item, String foundByName) {
            return new LostFoundResponse(item.getId(), item.getHotel().getId(), item.getHotel().getName(),
                    item.getRoom() == null ? null : item.getRoom().getId(),
                    item.getRoom() == null ? null : item.getRoom().getRoomNumber(),
                    item.getGuest() == null ? null : item.getGuest().getId(),
                    item.getGuest() == null ? null : item.getGuest().getFullName(),
                    item.getItemDescription(), foundByName, item.getFoundAt(), item.getStatus(),
                    item.getStorageLocation(), item.getNotes());
        }
    }

    /* --------------------------- service orders --------------------------- */
    public record ServiceOrderRequest(
            @NotNull(message = "Hotel is required") Long hotelId,
            Long bookingId,
            Long roomId,
            ServiceOrderType orderType,
            @NotBlank(message = "Description is required") @Size(max = 500) String description,
            @NotNull(message = "Amount is required")
            @DecimalMin(value = "0.01", message = "Amount must be greater than zero") BigDecimal amount,
            @Min(1) Integer quantity,
            ServiceOrderStatus status,
            Boolean billedToRoom) {
    }

    public record ServiceOrderResponse(
            Long id,
            Long hotelId,
            String hotelName,
            Long bookingId,
            String bookingCode,
            Long roomId,
            String roomNumber,
            String guestName,
            ServiceOrderType orderType,
            String description,
            BigDecimal amount,
            Integer quantity,
            BigDecimal lineTotal,
            ServiceOrderStatus status,
            boolean billedToRoom,
            Instant orderedAt,
            Instant deliveredAt) {

        public static ServiceOrderResponse from(ServiceOrder order) {
            BigDecimal qty = BigDecimal.valueOf(order.getQuantity() == null ? 1 : order.getQuantity());
            return new ServiceOrderResponse(order.getId(), order.getHotel().getId(), order.getHotel().getName(),
                    order.getBooking() == null ? null : order.getBooking().getId(),
                    order.getBooking() == null ? null : order.getBooking().getBookingCode(),
                    order.getRoom() == null ? null : order.getRoom().getId(),
                    order.getRoom() == null ? null : order.getRoom().getRoomNumber(),
                    order.getBooking() == null ? null : order.getBooking().getGuest().getFullName(),
                    order.getOrderType(), order.getDescription(), order.getAmount(), order.getQuantity(),
                    order.getAmount().multiply(qty), order.getStatus(),
                    Boolean.TRUE.equals(order.getBilledToRoom()), order.getOrderedAt(), order.getDeliveredAt());
        }
    }

    /* ------------------------------ feedback ------------------------------ */
    public record FeedbackRow(
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

        public static FeedbackRow from(GuestFeedback feedback) {
            return new FeedbackRow(feedback.getId(), feedback.getHotel().getId(), feedback.getHotel().getName(),
                    feedback.getGuest() == null ? null : feedback.getGuest().getId(),
                    feedback.getGuest() == null ? null : feedback.getGuest().getFullName(),
                    feedback.getBooking() == null ? null : feedback.getBooking().getId(),
                    feedback.getBooking() == null ? null : feedback.getBooking().getBookingCode(),
                    feedback.getType(), feedback.getRating(), feedback.getComments(), feedback.getStatus(),
                    feedback.getResolution(), feedback.getResolvedAt(), feedback.getCreatedAt());
        }
    }

    /* ------------------------------- coupons ------------------------------ */
    public record CouponRequest(
            @NotNull Long hotelId,
            @NotBlank @Size(max = 40) String code,
            @Size(max = 255) String description,
            @NotNull(message = "Discount type is required") com.hotelcrm.domain.enums.DiscountType discountType,
            @NotNull @DecimalMin(value = "0.0") BigDecimal value,
            @DecimalMin(value = "0.0") BigDecimal minAmount,
            @DecimalMin(value = "0.0") BigDecimal maxDiscount,
            LocalDate validFrom,
            LocalDate validTo,
            @Min(1) Integer usageLimit,
            Boolean active) {
    }

    public record CouponResponse(
            Long id,
            Long hotelId,
            String code,
            String description,
            String discountType,
            BigDecimal value,
            BigDecimal minAmount,
            BigDecimal maxDiscount,
            LocalDate validFrom,
            LocalDate validTo,
            Integer usageLimit,
            Integer usedCount,
            boolean active) {
    }

    /* -------------------------- validation helper ------------------------- */
    public record RatingRequest(@NotNull @Min(1) @Max(5) Integer rating) {
    }
}
