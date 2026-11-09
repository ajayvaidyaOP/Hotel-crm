package com.hotelcrm.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

public final class ReportDtos {

    private ReportDtos() {
    }

    public record RevenueRow(
            String period,
            LocalDate date,
            BigDecimal roomRevenue,
            BigDecimal serviceRevenue,
            BigDecimal tax,
            BigDecimal total,
            BigDecimal refunds,
            long bookings) {
    }

    public record OccupancyRow(
            Long hotelId,
            String hotelName,
            long totalRooms,
            long roomNights,
            long occupiedNights,
            BigDecimal occupancyPercent,
            BigDecimal revenue,
            BigDecimal adr,
            BigDecimal revpar) {
    }

    public record CategoryRow(String category, long bookings, BigDecimal revenue, BigDecimal sharePercent) {
    }

    public record ExpenseRow(String category, BigDecimal amount, BigDecimal sharePercent, long entries) {
    }

    public record ProfitRow(
            Long hotelId,
            String hotelName,
            BigDecimal revenue,
            BigDecimal refunds,
            BigDecimal expenses,
            BigDecimal profit,
            BigDecimal marginPercent) {
    }

    public record CancellationRow(
            Long bookingId,
            String bookingCode,
            String hotelName,
            String guestName,
            BigDecimal amount,
            Instant cancelledAt,
            String reason) {
    }

    public record KpiResponse(
            LocalDate from,
            LocalDate to,
            List<Long> hotelIds,
            BigDecimal revenue,
            BigDecimal roomRevenue,
            BigDecimal serviceRevenue,
            BigDecimal refunds,
            BigDecimal netRevenue,
            BigDecimal expenses,
            BigDecimal profit,
            BigDecimal pendingPayments,
            long bookings,
            long cancelledBookings,
            long completedStays,
            long roomNightsSold,
            long roomNightsAvailable,
            BigDecimal occupancyPercent,
            BigDecimal adr,
            BigDecimal revpar,
            BigDecimal cancellationPercent,
            BigDecimal averageLengthOfStay) {
    }

    public record ReportBundle(
            KpiResponse kpi,
            List<RevenueRow> revenueTrend,
            List<OccupancyRow> occupancyByHotel,
            List<CategoryRow> topCategories,
            List<ExpenseRow> expensesByCategory,
            List<ProfitRow> profitByHotel) {
    }
}
