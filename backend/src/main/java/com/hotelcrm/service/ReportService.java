package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.entity.BookingRoom;
import com.hotelcrm.domain.entity.Expense;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Invoice;
import com.hotelcrm.domain.entity.Payment;
import com.hotelcrm.domain.entity.Refund;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.entity.ServiceOrder;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.ExpenseCategory;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.dto.ReportDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.BookingRoomRepository;
import com.hotelcrm.repository.ExpenseRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.InvoiceRepository;
import com.hotelcrm.repository.PaymentRepository;
import com.hotelcrm.repository.RefundRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.repository.ServiceOrderRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import com.hotelcrm.util.RateMath;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ReportService {

    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("dd MMM");
    private static final DateTimeFormatter MONTH = DateTimeFormatter.ofPattern("MMM yyyy");

    private final BookingRepository bookingRepository;
    private final BookingRoomRepository bookingRoomRepository;
    private final PaymentRepository paymentRepository;
    private final RefundRepository refundRepository;
    private final InvoiceRepository invoiceRepository;
    private final ExpenseRepository expenseRepository;
    private final ServiceOrderRepository serviceOrderRepository;
    private final RoomRepository roomRepository;
    private final HotelRepository hotelRepository;
    private final HotelAccessService accessService;
    private final DocumentService documentService;
    private final PaymentService paymentService;

    @Transactional(readOnly = true)
    public ReportDtos.KpiResponse kpi(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.REPORT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;

        Scope scopeData = load(scope, start, end);
        long totalRooms = scopeData.rooms.size();
        long days = ChronoUnit.DAYS.between(start, end) + 1;
        long roomNightsAvailable = totalRooms * days;
        long roomNightsSold = occupiedNights(scopeData.segments, start, end);
        BigDecimal collected = scopeData.collected;
        BigDecimal netRevenue = MoneyUtils.subtract(collected, scopeData.refunds);
        BigDecimal roomRevenue = MoneyUtils.subtract(collected, scopeData.serviceRevenue);
        long bookings = scopeData.bookings.size();
        long cancelled = scopeData.bookings.stream()
                .filter(b -> b.getStatus() == BookingStatus.CANCELLED).count();
        long completed = scopeData.bookings.stream()
                .filter(b -> b.getStatus() == BookingStatus.CHECKED_OUT).count();
        double avgLos = scopeData.bookings.stream()
                .filter(b -> b.getStatus() == BookingStatus.CHECKED_OUT)
                .mapToLong(Booking::getNights).average().orElse(0);
        BigDecimal adr = roomNightsSold == 0 ? BigDecimal.ZERO
                : netRevenue.divide(BigDecimal.valueOf(roomNightsSold), 2, RoundingMode.HALF_UP);
        BigDecimal revpar = roomNightsAvailable == 0 ? BigDecimal.ZERO
                : netRevenue.divide(BigDecimal.valueOf(roomNightsAvailable), 2, RoundingMode.HALF_UP);

        return new ReportDtos.KpiResponse(start, end, scope, collected, roomRevenue, scopeData.serviceRevenue,
                scopeData.refunds, netRevenue, scopeData.expenses,
                MoneyUtils.subtract(netRevenue, scopeData.expenses),
                scopeData.pendingPayments, bookings, cancelled, completed, roomNightsSold, roomNightsAvailable,
                RateMath.percentage(roomNightsSold, Math.max(1, roomNightsAvailable)), adr, revpar,
                RateMath.percentage(cancelled, Math.max(1, bookings)),
                BigDecimal.valueOf(avgLos).setScale(2, RoundingMode.HALF_UP));
    }

    @Transactional(readOnly = true)
    public List<ReportDtos.RevenueRow> revenue(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.REPORT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        boolean monthly = ChronoUnit.DAYS.between(start, end) > 62;

        Scope data = load(scope, start, end);
        Map<String, ReportDtos.RevenueRow> rows = new LinkedHashMap<>();
        for (Payment payment : data.payments) {
            LocalDate date = payment.getPaidAt().atZone(ZoneOffset.UTC).toLocalDate();
            String key = monthly ? date.format(MONTH) : date.format(DAY);
            ReportDtos.RevenueRow row = rows.getOrDefault(key, new ReportDtos.RevenueRow(key,
                    monthly ? date.withDayOfMonth(1) : date, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0));
            rows.put(key, new ReportDtos.RevenueRow(row.period(), row.date(), row.roomRevenue(),
                    row.serviceRevenue(), row.tax(), MoneyUtils.add(row.total(), payment.getAmount()),
                    row.refunds(), row.bookings()));
        }
        for (Refund refund : data.refundsList) {
            LocalDate date = refund.getProcessedAt().atZone(ZoneOffset.UTC).toLocalDate();
            String key = monthly ? date.format(MONTH) : date.format(DAY);
            ReportDtos.RevenueRow row = rows.getOrDefault(key, new ReportDtos.RevenueRow(key,
                    monthly ? date.withDayOfMonth(1) : date, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0));
            rows.put(key, new ReportDtos.RevenueRow(row.period(), row.date(), row.roomRevenue(),
                    row.serviceRevenue(), row.tax(), row.total(), MoneyUtils.add(row.refunds(), refund.getAmount()),
                    row.bookings()));
        }
        for (ServiceOrder order : data.serviceOrders) {
            LocalDate date = order.getOrderedAt().atZone(ZoneOffset.UTC).toLocalDate();
            String key = monthly ? date.format(MONTH) : date.format(DAY);
            ReportDtos.RevenueRow row = rows.getOrDefault(key, new ReportDtos.RevenueRow(key,
                    monthly ? date.withDayOfMonth(1) : date, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0));
            BigDecimal amount = MoneyUtils.multiply(order.getAmount(), BigDecimal.valueOf(
                    order.getQuantity() == null ? 1 : order.getQuantity()));
            rows.put(key, new ReportDtos.RevenueRow(row.period(), row.date(), row.roomRevenue(),
                    MoneyUtils.add(row.serviceRevenue(), amount), row.tax(), row.total(), row.refunds(),
                    row.bookings()));
        }
        for (Invoice invoice : data.invoices) {
            LocalDate date = invoice.getIssueDate();
            String key = monthly ? date.format(MONTH) : date.format(DAY);
            ReportDtos.RevenueRow row = rows.getOrDefault(key, new ReportDtos.RevenueRow(key,
                    monthly ? date.withDayOfMonth(1) : date, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0));
            rows.put(key, new ReportDtos.RevenueRow(row.period(), row.date(), row.roomRevenue(),
                    row.serviceRevenue(), MoneyUtils.add(row.tax(), invoice.getTaxAmount()), row.total(),
                    row.refunds(), row.bookings()));
        }
        for (Booking booking : data.bookings) {
            LocalDate date = booking.getCheckInDate();
            String key = monthly ? date.format(MONTH) : date.format(DAY);
            ReportDtos.RevenueRow row = rows.getOrDefault(key, new ReportDtos.RevenueRow(key,
                    monthly ? date.withDayOfMonth(1) : date, BigDecimal.ZERO, BigDecimal.ZERO,
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, 0));
            rows.put(key, new ReportDtos.RevenueRow(row.period(), row.date(), row.roomRevenue(),
                    row.serviceRevenue(), row.tax(), row.total(), row.refunds(), row.bookings() + 1));
        }
        // room revenue = total collected (net of services) per period
        return rows.values().stream()
                .map(row -> new ReportDtos.RevenueRow(row.period(), row.date(),
                        MoneyUtils.subtract(row.total(), row.serviceRevenue()), row.serviceRevenue(),
                        row.tax(), row.total(), row.refunds(), row.bookings()))
                .sorted((a, b) -> a.date().compareTo(b.date()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ReportDtos.OccupancyRow> occupancy(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.REPORT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        long days = ChronoUnit.DAYS.between(start, end) + 1;
        List<Hotel> hotels = hotelRepository.findAllById(scope);
        List<ReportDtos.OccupancyRow> rows = new ArrayList<>();
        for (Hotel hotel : hotels) {
            List<Room> rooms = roomRepository.findAllByHotelId(hotel.getId()).stream()
                    .filter(r -> Boolean.TRUE.equals(r.getActive())).toList();
            List<BookingRoom> segments = bookingRoomRepository.findForCalendar(List.of(hotel.getId()),
                    start, end.plusDays(1),
                    List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.CHECKED_OUT));
            long occupied = occupiedNights(segments, start, end);
            long available = (long) rooms.size() * days;
            BigDecimal revenue = MoneyUtils.nullToZero(paymentRepository.sumCollected(List.of(hotel.getId()),
                    startOfDay(start), startOfDay(end.plusDays(1))));
            BigDecimal adr = occupied == 0 ? BigDecimal.ZERO
                    : revenue.divide(BigDecimal.valueOf(occupied), 2, RoundingMode.HALF_UP);
            BigDecimal revpar = available == 0 ? BigDecimal.ZERO
                    : revenue.divide(BigDecimal.valueOf(available), 2, RoundingMode.HALF_UP);
            rows.add(new ReportDtos.OccupancyRow(hotel.getId(), hotel.getName(), rooms.size(), available,
                    occupied, RateMath.percentage(occupied, Math.max(1, available)), revenue, adr, revpar));
        }
        rows.sort((a, b) -> b.revenue().compareTo(a.revenue()));
        return rows;
    }

    @Transactional(readOnly = true)
    public List<ReportDtos.CategoryRow> topCategories(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.ANALYTICS_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withMonth(1).withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        List<BookingRoom> segments = bookingRoomRepository.findForCalendar(scope, start, end.plusDays(1),
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.CHECKED_OUT));
        Map<String, BigDecimal> revenue = new LinkedHashMap<>();
        Map<String, java.util.Set<Long>> bookings = new LinkedHashMap<>();
        segments.forEach(segment -> {
            String name = segment.getCategory().getName();
            revenue.merge(name, MoneyUtils.nullToZero(segment.getTotalAmount()), BigDecimal::add);
            bookings.computeIfAbsent(name, k -> new java.util.HashSet<>()).add(segment.getBooking().getId());
        });
        BigDecimal total = revenue.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        return revenue.entrySet().stream()
                .map(entry -> new ReportDtos.CategoryRow(entry.getKey(),
                        bookings.get(entry.getKey()).size(), MoneyUtils.scale(entry.getValue()),
                        RateMath.percentage(entry.getValue().longValue(), Math.max(1, total.longValue()))))
                .sorted((a, b) -> b.revenue().compareTo(a.revenue()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ReportDtos.ExpenseRow> expenses(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.EXPENSE_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        List<ExpenseCategory> categories = List.of(ExpenseCategory.values());
        List<Expense> all = expenseRepository.findAll((Specification<Expense>) (root, query, cb) -> cb.and(
                root.get("hotel").get("id").in(scope), cb.between(root.get("expenseDate"), start, end)),
                PageRequest.of(0, 5000, Sort.by("expenseDate"))).getContent();
        BigDecimal total = all.stream().map(Expense::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
        List<ReportDtos.ExpenseRow> rows = new ArrayList<>();
        for (ExpenseCategory category : categories) {
            List<Expense> matching = all.stream().filter(e -> e.getCategory() == category).toList();
            if (matching.isEmpty()) {
                continue;
            }
            BigDecimal amount = matching.stream().map(Expense::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
            rows.add(new ReportDtos.ExpenseRow(category.getLabel(), MoneyUtils.scale(amount),
                    RateMath.percentage(amount.longValue(), Math.max(1, total.longValue())), matching.size()));
        }
        rows.sort((a, b) -> b.amount().compareTo(a.amount()));
        return rows;
    }

    @Transactional(readOnly = true)
    public List<ReportDtos.ProfitRow> profit(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.REPORT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        List<Hotel> hotels = hotelRepository.findAllById(scope);
        List<ReportDtos.ProfitRow> rows = new ArrayList<>();
        for (Hotel hotel : hotels) {
            BigDecimal revenue = MoneyUtils.nullToZero(paymentRepository.sumCollected(List.of(hotel.getId()),
                    startOfDay(start), startOfDay(end.plusDays(1))));
            BigDecimal refunds = MoneyUtils.nullToZero(refundRepository.sumRefunds(List.of(hotel.getId()),
                    startOfDay(start), startOfDay(end.plusDays(1))));
            BigDecimal expenses = MoneyUtils.nullToZero(expenseRepository.sumExpenses(List.of(hotel.getId()), start, end));
            BigDecimal profit = MoneyUtils.subtract(MoneyUtils.subtract(revenue, refunds), expenses);
            rows.add(new ReportDtos.ProfitRow(hotel.getId(), hotel.getName(), revenue, refunds, expenses, profit,
                    RateMath.percentage(profit.longValue(), Math.max(1, revenue.longValue()))));
        }
        rows.sort((a, b) -> b.profit().compareTo(a.profit()));
        return rows;
    }

    @Transactional(readOnly = true)
    public List<ReportDtos.CancellationRow> cancellations(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.REPORT_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        Instant fromInstant = startOfDay(start);
        Instant toInstant = startOfDay(end.plusDays(1));
        return bookingRepository.findCancelled(scope).stream()
                .filter(booking -> booking.getCancelledAt() != null
                        && !booking.getCancelledAt().isBefore(fromInstant)
                        && booking.getCancelledAt().isBefore(toInstant))
                .map(booking -> new ReportDtos.CancellationRow(booking.getId(), booking.getBookingCode(),
                        booking.getHotel().getName(), booking.getGuest().getFullName(),
                        booking.getTotalAmount(), booking.getCancelledAt(), booking.getCancellationReason()))
                .toList();
    }

    @Transactional(readOnly = true)
    public ReportDtos.ReportBundle bundle(Long hotelId, LocalDate from, LocalDate to) {
        return new ReportDtos.ReportBundle(kpi(hotelId, from, to), revenue(hotelId, from, to),
                occupancy(hotelId, from, to), topCategories(hotelId, from, to),
                expenses(hotelId, from, to), profit(hotelId, from, to));
    }

    @Transactional(readOnly = true)
    public List<PaymentDtos.PendingPaymentRow> pendingPayments(Long hotelId) {
        return paymentService.pendingPayments(hotelId);
    }

    /* --------------------------------- export -------------------------------- */

    @Transactional(readOnly = true)
    public ExportFile export(String report, String format, Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.REPORT_READ);
        String type = report == null ? "revenue" : report.toLowerCase();
        String fmt = format == null ? "csv" : format.toLowerCase();
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        String title;
        List<String> headers;
        List<List<String>> rows = new ArrayList<>();

        switch (type) {
            case "occupancy" -> {
                title = "Occupancy report";
                headers = List.of("Hotel", "Total rooms", "Room nights", "Occupied nights", "Occupancy %",
                        "Revenue", "ADR", "RevPAR");
                occupancy(hotelId, start, end).forEach(row -> rows.add(List.of(row.hotelName(),
                        String.valueOf(row.totalRooms()), String.valueOf(row.roomNights()),
                        String.valueOf(row.occupiedNights()), row.occupancyPercent().toPlainString(),
                        row.revenue().toPlainString(), row.adr().toPlainString(), row.revpar().toPlainString())));
            }
            case "expenses" -> {
                title = "Expense report";
                headers = List.of("Category", "Amount", "Share %", "Entries");
                expenses(hotelId, start, end).forEach(row -> rows.add(List.of(row.category(),
                        row.amount().toPlainString(), row.sharePercent().toPlainString(),
                        String.valueOf(row.entries()))));
            }
            case "profit" -> {
                title = "Profit estimate";
                headers = List.of("Hotel", "Revenue", "Refunds", "Expenses", "Profit", "Margin %");
                profit(hotelId, start, end).forEach(row -> rows.add(List.of(row.hotelName(),
                        row.revenue().toPlainString(), row.refunds().toPlainString(), row.expenses().toPlainString(),
                        row.profit().toPlainString(), row.marginPercent().toPlainString())));
            }
            case "bookings" -> {
                title = "Booking history";
                headers = List.of("Booking", "Hotel", "Guest", "Check-in", "Check-out", "Nights", "Status",
                        "Payment", "Total", "Paid", "Pending");
                List<Long> scope = accessService.resolveHotelScope(hotelId);
                bookingRepository.findAll((Specification<Booking>) (root, query, cb) -> cb.and(
                                root.get("hotel").get("id").in(scope),
                                cb.greaterThanOrEqualTo(root.get("checkOutDate"), start),
                                cb.lessThanOrEqualTo(root.get("checkInDate"), end)),
                        Sort.by(Sort.Direction.ASC, "checkInDate")).forEach(booking -> rows.add(List.of(
                        booking.getBookingCode(), booking.getHotel().getName(), booking.getGuest().getFullName(),
                        booking.getCheckInDate().toString(), booking.getCheckOutDate().toString(),
                        String.valueOf(booking.getNights()), booking.getStatus().name(),
                        booking.getPaymentStatus().name(), booking.getTotalAmount().toPlainString(),
                        booking.getPaidAmount().toPlainString(), booking.getPendingAmount().toPlainString())));
            }
            case "payments" -> {
                title = "Payment history";
                headers = List.of("Payment", "Date", "Hotel", "Booking", "Amount", "Method", "Type", "Reference");
                List<Long> scope = accessService.resolveHotelScope(hotelId);
                paymentRepository.findByHotelIdInAndPaidAtBetweenOrderByPaidAtDesc(scope, startOfDay(start),
                        startOfDay(end.plusDays(1))).forEach(payment -> rows.add(List.of(
                        payment.getPaymentCode(), payment.getPaidAt().atZone(ZoneOffset.UTC).toLocalDate().toString(),
                        payment.getHotel().getName(),
                        payment.getBooking() == null ? "-" : payment.getBooking().getBookingCode(),
                        payment.getAmount().toPlainString(), payment.getMethod().name(),
                        payment.getPaymentType().name(),
                        payment.getReferenceNo() == null ? "-" : payment.getReferenceNo())));
            }
            case "pending-payments" -> {
                title = "Pending payments";
                headers = List.of("Booking", "Hotel", "Guest", "Mobile", "Check-out", "Total", "Paid", "Pending", "Days overdue");
                paymentService.pendingPayments(hotelId).forEach(row -> rows.add(List.of(row.bookingCode(),
                        row.hotelName(), row.guestName(), row.guestMobile(), row.checkOutDate().toString(),
                        row.totalAmount().toPlainString(), row.paidAmount().toPlainString(),
                        row.pendingAmount().toPlainString(), String.valueOf(row.daysOverdue()))));
            }
            case "categories" -> {
                title = "Most booked room categories";
                headers = List.of("Category", "Bookings", "Revenue", "Share %");
                topCategories(hotelId, start, end).forEach(row -> rows.add(List.of(row.category(),
                        String.valueOf(row.bookings()), row.revenue().toPlainString(),
                        row.sharePercent().toPlainString())));
            }
            case "cancellations" -> {
                title = "Cancellation report";
                headers = List.of("Booking", "Hotel", "Guest", "Amount", "Cancelled at", "Reason");
                cancellations(hotelId, start, end).forEach(row -> rows.add(List.of(row.bookingCode(),
                        row.hotelName(), row.guestName(), row.amount().toPlainString(),
                        row.cancelledAt().toString(), row.reason() == null ? "-" : row.reason())));
            }
            default -> {
                title = "Revenue report";
                headers = List.of("Period", "Room revenue", "Service revenue", "Tax", "Total collected",
                        "Refunds", "Bookings");
                revenue(hotelId, start, end).forEach(row -> rows.add(List.of(row.period(),
                        row.roomRevenue().toPlainString(), row.serviceRevenue().toPlainString(),
                        row.tax().toPlainString(), row.total().toPlainString(), row.refunds().toPlainString(),
                        String.valueOf(row.bookings()))));
            }
        }

        String subtitle = "Period " + start + " to " + end + "  |  Generated "
                + java.time.LocalDateTime.now().withNano(0);
        byte[] content;
        String extension;
        String contentType;
        switch (fmt) {
            case "xlsx" -> {
                content = documentService.excel(title, headers, rows);
                extension = "xlsx";
                contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            }
            case "pdf" -> {
                content = documentService.reportPdf(title, subtitle, headers, rows);
                extension = "pdf";
                contentType = "application/pdf";
            }
            default -> {
                content = documentService.csv(headers, rows);
                extension = "csv";
                contentType = "text/csv";
            }
        }
        String fileName = type + "-report-" + start + "-to-" + end + "." + extension;
        return new ExportFile(fileName, contentType, content);
    }

    public record ExportFile(String fileName, String contentType, byte[] content) {
    }

    /* -------------------------------- internals ------------------------------ */

    private record Scope(List<Room> rooms, List<Booking> bookings, List<BookingRoom> segments,
                         List<Payment> payments, List<Refund> refundsList, List<Invoice> invoices,
                         List<ServiceOrder> serviceOrders, BigDecimal collected, BigDecimal refunds,
                         BigDecimal expenses, BigDecimal serviceRevenue, BigDecimal pendingPayments) {
    }

    private Scope load(List<Long> scope, LocalDate start, LocalDate end) {
        List<Room> rooms = roomRepository.findActiveByHotels(scope);
        List<Booking> bookings = bookingRepository.findAll((Specification<Booking>) (root, query, cb) -> cb.and(
                        root.get("hotel").get("id").in(scope),
                        cb.greaterThanOrEqualTo(root.get("checkOutDate"), start),
                        cb.lessThanOrEqualTo(root.get("checkInDate"), end)),
                Sort.by(Sort.Direction.ASC, "checkInDate"));
        List<BookingRoom> segments = bookingRoomRepository.findForCalendar(scope, start, end.plusDays(1),
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.CHECKED_OUT));
        List<Payment> payments = paymentRepository.findByHotelIdInAndStatusAndPaidAtBetweenOrderByPaidAtAsc(scope,
                com.hotelcrm.domain.enums.PaymentStatus.SUCCESS, startOfDay(start), startOfDay(end.plusDays(1)));
        List<Refund> refundsList = refundRepository.findAll((Specification<Refund>) (root, query, cb) -> cb.and(
                root.get("hotel").get("id").in(scope),
                cb.between(root.get("processedAt"), startOfDay(start), startOfDay(end.plusDays(1)))));
        List<Invoice> invoices = invoiceRepository.findAll((Specification<Invoice>) (root, query, cb) -> cb.and(
                root.get("hotel").get("id").in(scope),
                cb.between(root.get("issueDate"), start, end)));
        List<ServiceOrder> serviceOrders = serviceOrderRepository
                .findByHotelIdInAndOrderedAtBetweenOrderByOrderedAtDesc(scope, startOfDay(start),
                        startOfDay(end.plusDays(1))).stream()
                .filter(order -> order.getStatus() != com.hotelcrm.domain.enums.ServiceOrderStatus.CANCELLED)
                .toList();
        BigDecimal collected = payments.stream().map(Payment::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal refunded = refundsList.stream()
                .filter(r -> r.getStatus() == com.hotelcrm.domain.enums.RefundStatus.COMPLETED)
                .map(Refund::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal expenses = money(expenseRepository.sumExpenses(scope, start, end));
        BigDecimal serviceRevenue = serviceOrders.stream()
                .map(order -> MoneyUtils.multiply(order.getAmount(),
                        BigDecimal.valueOf(order.getQuantity() == null ? 1 : order.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal pending = money(bookingRepository.sumPendingPayments(scope));
        return new Scope(rooms, bookings, segments, payments, refundsList, invoices, serviceOrders,
                MoneyUtils.scale(collected), MoneyUtils.scale(refunded), expenses,
                MoneyUtils.scale(serviceRevenue), pending);
    }

    private long occupiedNights(List<BookingRoom> segments, LocalDate start, LocalDate end) {
        long nights = 0;
        for (BookingRoom segment : segments) {
            LocalDate from = segment.getCheckInDate().isBefore(start) ? start : segment.getCheckInDate();
            LocalDate to = segment.getCheckOutDate().isAfter(end.plusDays(1)) ? end.plusDays(1) : segment.getCheckOutDate();
            nights += Math.max(0, ChronoUnit.DAYS.between(from, to));
        }
        return nights;
    }

    private BigDecimal money(BigDecimal value) {
        return MoneyUtils.scale(MoneyUtils.nullToZero(value));
    }

    private Instant startOfDay(LocalDate date) {
        return date.atStartOfDay(ZoneOffset.UTC).toInstant();
    }

    @SuppressWarnings("unused")
    private void assertRange(LocalDate from, LocalDate to) {
        if (to.isBefore(from)) {
            throw new BusinessException("The end date must be after the start date");
        }
    }
}
