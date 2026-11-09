package com.hotelcrm.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

public final class DashboardDtos {

    private DashboardDtos() {
    }

    public record NamedValue(String name, BigDecimal value, long count) {
    }

    public record TimePoint(String label, LocalDate date, BigDecimal revenue, long bookings, BigDecimal occupancyPercent) {
    }

    public record ActivityRow(Instant at, String actor, String action, String description, String hotelName, String ipAddress) {
    }

    public record DashboardResponse(
            Long hotelId,
            String scope,
            LocalDate from,
            LocalDate to,
            Instant generatedAt,
            long hotelCount,
            long totalRooms,
            long availableRooms,
            long occupiedRooms,
            long reservedRooms,
            long maintenanceRooms,
            long cleaningRooms,
            long outOfServiceRooms,
            long dirtyRooms,
            long inHouseGuests,
            long todayCheckIns,
            long todayCheckOuts,
            long todayBookings,
            long pendingHousekeeping,
            long openMaintenance,
            BigDecimal occupancyPercent,
            BigDecimal monthlyRevenue,
            BigDecimal yearlyRevenue,
            BigDecimal todayRevenue,
            BigDecimal pendingPayments,
            BigDecimal outstandingInvoices,
            BigDecimal monthlyExpenses,
            BigDecimal monthlyProfit,
            BigDecimal adr,
            BigDecimal revpar,
            BigDecimal serviceRevenueMonth,
            List<HotelDtos.HotelStats> hotels,
            List<TimePoint> revenueTrend,
            List<NamedValue> revenueByHotel,
            List<NamedValue> bookingSourceBreakdown,
            List<NamedValue> roomStatusBreakdown,
            List<NamedValue> paymentMethodBreakdown,
            List<ActivityRow> recentActivities,
            List<BookingDtos.UpcomingBooking> upcomingCheckIns,
            List<BookingDtos.Summary> recentBookings) {
    }
}
