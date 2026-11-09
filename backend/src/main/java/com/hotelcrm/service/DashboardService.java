package com.hotelcrm.service;

import com.hotelcrm.domain.entity.BookingRoom;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.MaintenanceStatus;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.dto.BookingDtos;
import com.hotelcrm.dto.DashboardDtos;
import com.hotelcrm.dto.HotelDtos;
import com.hotelcrm.repository.AuditLogRepository;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.BookingRoomRepository;
import com.hotelcrm.repository.ExpenseRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.HousekeepingTaskRepository;
import com.hotelcrm.repository.InvoiceRepository;
import com.hotelcrm.repository.MaintenanceRequestRepository;
import com.hotelcrm.repository.PaymentRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.repository.ServiceOrderRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import com.hotelcrm.util.RateMath;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Consolidated and per-hotel analytics assembled from real database aggregates. */
@Service
@RequiredArgsConstructor
public class DashboardService {

    private final HotelRepository hotelRepository;
    private final RoomRepository roomRepository;
    private final BookingRepository bookingRepository;
    private final BookingRoomRepository bookingRoomRepository;
    private final PaymentRepository paymentRepository;
    private final InvoiceRepository invoiceRepository;
    private final ExpenseRepository expenseRepository;
    private final HousekeepingTaskRepository housekeepingTaskRepository;
    private final MaintenanceRequestRepository maintenanceRepository;
    private final ServiceOrderRepository serviceOrderRepository;
    private final AuditLogRepository auditLogRepository;
    private final HotelAccessService accessService;
    private final UserDirectoryService userDirectoryService;
    private final HotelService hotelService;

    @Transactional(readOnly = true)
    public DashboardDtos.DashboardResponse dashboard(Long hotelId, LocalDate from, LocalDate to) {
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate today = LocalDate.now();
        LocalDate rangeFrom = from == null ? today.withDayOfMonth(1) : from;
        LocalDate rangeTo = to == null ? today : to;

        List<Hotel> hotels = hotelRepository.findAllById(scope);
        List<Room> rooms = roomRepository.findActiveByHotels(scope);

        long available = rooms.stream().filter(r -> r.getStatus() == RoomStatus.AVAILABLE).count();
        long occupied = rooms.stream().filter(r -> r.getStatus() == RoomStatus.OCCUPIED).count();
        long maintenance = rooms.stream().filter(r -> r.getStatus() == RoomStatus.MAINTENANCE).count();
        long cleaning = rooms.stream().filter(r -> r.getStatus() == RoomStatus.CLEANING).count();
        long outOfService = rooms.stream().filter(r -> r.getStatus() == RoomStatus.OUT_OF_SERVICE).count();
        long dirty = rooms.stream().filter(r -> r.getHousekeepingStatus() == HousekeepingCondition.DIRTY).count();

        List<BookingRoom> todaysSegments = bookingRoomRepository.findForCalendar(scope, today, today.plusDays(1),
                List.of(BookingStatus.PENDING, BookingStatus.CONFIRMED));
        long reserved = todaysSegments.stream().filter(s -> s.getRoom() != null)
                .map(s -> s.getRoom().getId()).distinct().count();

        LocalDate monthStart = today.withDayOfMonth(1);
        LocalDate monthEnd = monthStart.plusMonths(1);
        LocalDate yearStart = LocalDate.of(today.getYear(), 1, 1);

        BigDecimal monthlyRevenue = MoneyUtils.nullToZero(paymentRepository.sumCollected(scope,
                startOfDay(monthStart), startOfDay(monthEnd)));
        BigDecimal yearlyRevenue = MoneyUtils.nullToZero(paymentRepository.sumCollected(scope,
                startOfDay(yearStart), startOfDay(yearStart.plusYears(1))));
        BigDecimal todayRevenue = MoneyUtils.nullToZero(paymentRepository.sumCollected(scope,
                startOfDay(today), startOfDay(today.plusDays(1))));
        BigDecimal pendingPayments = MoneyUtils.nullToZero(bookingRepository.sumPendingPayments(scope));
        BigDecimal outstandingInvoices = MoneyUtils.nullToZero(invoiceRepository.sumOutstanding(scope));
        BigDecimal monthlyExpenses = MoneyUtils.nullToZero(expenseRepository.sumExpenses(scope, monthStart, today));
        BigDecimal serviceRevenue = MoneyUtils.nullToZero(serviceOrderRepository.sumOrderRevenue(scope,
                startOfDay(monthStart), startOfDay(monthEnd)));

        long roomNightsSold = roomNights(scope, monthStart, monthEnd);
        long monthDays = ChronoUnit.DAYS.between(monthStart, today) + 1;
        long roomNightsAvailable = (long) rooms.size() * monthDays;
        BigDecimal occupancy = RateMath.percentage(occupied, Math.max(1, rooms.size()));
        BigDecimal adr = roomNightsSold == 0 ? BigDecimal.ZERO
                : MoneyUtils.scale(monthlyRevenue.divide(BigDecimal.valueOf(roomNightsSold), 2, RoundingMode.HALF_UP));
        BigDecimal revpar = rooms.isEmpty() || roomNightsAvailable == 0 ? BigDecimal.ZERO
                : MoneyUtils.scale(monthlyRevenue.divide(BigDecimal.valueOf(roomNightsAvailable), 2, RoundingMode.HALF_UP));

        Long inHouseGuests = bookingRepository.sumInHouseGuests(scope);
        long inHouse = inHouseGuests == null ? 0 : inHouseGuests;

        List<DashboardDtos.TimePoint> trend = buildTrend(scope, rooms.size(), today.minusDays(29), today);
        List<DashboardDtos.NamedValue> revenueByHotel = paymentRepository.sumCollectedByHotel(scope,
                        startOfDay(monthStart), startOfDay(monthEnd)).stream()
                .map(row -> new DashboardDtos.NamedValue(
                        hotels.stream().filter(h -> h.getId().equals(((Number) row[0]).longValue()))
                                .map(Hotel::getName).findFirst().orElse("Hotel"),
                        MoneyUtils.scale((BigDecimal) row[1]), 0))
                .sorted((a, b) -> b.value().compareTo(a.value()))
                .toList();

        List<DashboardDtos.NamedValue> bySource = bookingRepository.sourceBreakdown(scope,
                        startOfDay(rangeFrom), startOfDay(rangeTo.plusDays(1))).stream()
                .map(row -> new DashboardDtos.NamedValue(((com.hotelcrm.domain.enums.BookingSource) row[0]).getLabel(),
                        MoneyUtils.scale((BigDecimal) row[2]), ((Number) row[1]).longValue()))
                .toList();

        List<DashboardDtos.NamedValue> byRoomStatus = List.of(
                new DashboardDtos.NamedValue("Available", BigDecimal.valueOf(available), available),
                new DashboardDtos.NamedValue("Occupied", BigDecimal.valueOf(occupied), occupied),
                new DashboardDtos.NamedValue("Cleaning", BigDecimal.valueOf(cleaning), cleaning),
                new DashboardDtos.NamedValue("Maintenance", BigDecimal.valueOf(maintenance), maintenance),
                new DashboardDtos.NamedValue("Out of service", BigDecimal.valueOf(outOfService), outOfService));

        List<DashboardDtos.NamedValue> byMethod = paymentRepository.sumByMethod(scope,
                        startOfDay(monthStart), startOfDay(monthEnd)).stream()
                .map(row -> new DashboardDtos.NamedValue(
                        ((com.hotelcrm.domain.enums.PaymentMethod) row[0]).getLabel(),
                        MoneyUtils.scale((BigDecimal) row[1]), 0))
                .toList();

        Map<Long, String> actors = userDirectoryService.names(auditLogRepository
                .findTop15ByHotelIdInOrderByCreatedAtDesc(scope).stream().map(a ->
                        a.getUserId()).toList());
        List<DashboardDtos.ActivityRow> activities = auditLogRepository
                .findTop15ByHotelIdInOrderByCreatedAtDesc(scope).stream()
                .map(a -> new DashboardDtos.ActivityRow(a.getCreatedAt(),
                        actors.getOrDefault(a.getUserId(), a.getActorEmail()), a.getAction(),
                        a.getDescription(),
                        hotels.stream().filter(h -> h.getId().equals(a.getHotelId())).map(Hotel::getName)
                                .findFirst().orElse("Group"),
                        a.getIpAddress()))
                .toList();

        List<BookingDtos.UpcomingBooking> upcoming = bookingRepository.findUpcomingCheckIns(scope, today).stream()
                .limit(10)
                .map(booking -> new BookingDtos.UpcomingBooking(booking.getId(), booking.getBookingCode(),
                        booking.getGuest().getFullName(), booking.getGuest().getMobile(), booking.getCheckInDate(),
                        booking.getCheckOutDate(), booking.getRooms() == null ? 0 : booking.getRooms().size(),
                        booking.getStatus(), booking.getPaymentStatus()))
                .toList();

        List<BookingDtos.Summary> recentBookings = bookingRepository.findAll(
                        (root, query, cb) -> root.get("hotel").get("id").in(scope),
                        PageRequest.of(0, 8, Sort.by(Sort.Direction.DESC, "createdAt")))
                .getContent().stream().map(BookingDtos.Summary::from).toList();

        return new DashboardDtos.DashboardResponse(hotelId, hotelId == null ? "CONSOLIDATED" : "HOTEL",
                rangeFrom, rangeTo, Instant.now(), hotels.size(), rooms.size(), available, occupied, reserved,
                maintenance, cleaning, outOfService, dirty, inHouse,
                bookingRepository.countByHotelIdInAndCheckInDate(scope, today),
                bookingRepository.countByHotelIdInAndCheckOutDate(scope, today),
                bookingRepository.countByHotelIdInAndCreatedAtBetween(scope, startOfDay(today), startOfDay(today.plusDays(1))),
                housekeepingTaskRepository.countOpen(scope, com.hotelcrm.domain.enums.HousekeepingTaskStatus.PENDING),
                maintenanceRepository.countByHotelIdInAndStatusIn(scope,
                        List.of(MaintenanceStatus.OPEN, MaintenanceStatus.IN_PROGRESS)),
                occupancy, monthlyRevenue, yearlyRevenue, todayRevenue, pendingPayments, outstandingInvoices,
                monthlyExpenses, MoneyUtils.subtract(monthlyRevenue, monthlyExpenses), adr, revpar, serviceRevenue,
                hotelService.stats(scope, rangeFrom, rangeTo), trend, revenueByHotel, bySource, byRoomStatus,
                byMethod, activities, upcoming, recentBookings);
    }

    private List<DashboardDtos.TimePoint> buildTrend(List<Long> scope, int roomCount, LocalDate from, LocalDate to) {
        List<com.hotelcrm.domain.entity.Payment> payments = paymentRepository
                .findByHotelIdInAndStatusAndPaidAtBetweenOrderByPaidAtAsc(scope,
                        com.hotelcrm.domain.enums.PaymentStatus.SUCCESS,
                        startOfDay(from), startOfDay(to.plusDays(1)));
        Map<LocalDate, BigDecimal> revenueByDay = new LinkedHashMap<>();
        payments.forEach(p -> revenueByDay.merge(
                p.getPaidAt().atZone(ZoneOffset.UTC).toLocalDate(), p.getAmount(), BigDecimal::add));
        List<BookingRoom> segments = bookingRoomRepository.findForCalendar(scope, from, to.plusDays(1),
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.CHECKED_OUT));
        Map<LocalDate, Long> occupiedByDay = new LinkedHashMap<>();
        for (BookingRoom segment : segments) {
            LocalDate cursor = segment.getCheckInDate().isBefore(from) ? from : segment.getCheckInDate();
            LocalDate end = segment.getCheckOutDate().isAfter(to.plusDays(1)) ? to.plusDays(1) : segment.getCheckOutDate();
            while (cursor.isBefore(end)) {
                occupiedByDay.merge(cursor, 1L, Long::sum);
                cursor = cursor.plusDays(1);
            }
        }
        List<DashboardDtos.TimePoint> points = new ArrayList<>();
        LocalDate cursor = from;
        while (!cursor.isAfter(to)) {
            BigDecimal revenue = revenueByDay.getOrDefault(cursor, BigDecimal.ZERO);
            long occupied = occupiedByDay.getOrDefault(cursor, 0L);
            long bookings = 0;
            for (BookingRoom segment : segments) {
                if (segment.getCheckInDate().equals(cursor)) {
                    bookings++;
                }
            }
            points.add(new DashboardDtos.TimePoint(cursor.getDayOfWeek().name().substring(0, 3) + " "
                    + cursor.getDayOfMonth(), cursor, MoneyUtils.scale(revenue), bookings,
                    RateMath.percentage(occupied, Math.max(1, roomCount))));
            cursor = cursor.plusDays(1);
        }
        return points;
    }

    private long roomNights(List<Long> scope, LocalDate from, LocalDate to) {
        List<BookingRoom> segments = bookingRoomRepository.findForCalendar(scope, from, to,
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.CHECKED_OUT));
        long nights = 0;
        for (BookingRoom segment : segments) {
            LocalDate start = segment.getCheckInDate().isBefore(from) ? from : segment.getCheckInDate();
            LocalDate end = segment.getCheckOutDate().isAfter(to) ? to : segment.getCheckOutDate();
            nights += Math.max(0, ChronoUnit.DAYS.between(start, end));
        }
        return nights;
    }

    private Instant startOfDay(LocalDate date) {
        return date.atStartOfDay(ZoneOffset.UTC).toInstant();
    }

    /** Exposed for the hotel comparison widget. */
    @Transactional(readOnly = true)
    public List<HotelDtos.HotelStats> hotelComparison(LocalDate from, LocalDate to) {
        return hotelService.stats(accessService.accessibleHotelIds(),
                from == null ? LocalDate.now().withDayOfMonth(1) : from,
                to == null ? LocalDate.now() : to);
    }
}
