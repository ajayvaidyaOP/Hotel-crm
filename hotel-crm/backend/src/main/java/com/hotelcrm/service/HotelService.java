package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.HotelStatus;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.dto.HotelDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.HotelStaffRepository;
import com.hotelcrm.repository.PaymentRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import com.hotelcrm.util.RateMath;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class HotelService {

    private final HotelRepository hotelRepository;
    private final RoomRepository roomRepository;
    private final HotelStaffRepository hotelStaffRepository;
    private final BookingRepository bookingRepository;
    private final PaymentRepository paymentRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final NotificationService notificationService;

    @Transactional(readOnly = true)
    public List<HotelDtos.Response> list(HotelStatus status, String search) {
        List<Hotel> hotels;
        if (accessService.isSuperAdmin()) {
            hotels = hotelRepository.findAllByOrderByNameAsc();
        } else {
            List<Long> ids = accessService.accessibleHotelIds();
            hotels = hotelRepository.findAllById(ids);
            hotels.sort(java.util.Comparator.comparing(Hotel::getName));
        }
        String term = search == null ? null : search.trim().toLowerCase();
        return hotels.stream()
                .filter(h -> status == null || h.getStatus() == status)
                .filter(h -> term == null || term.isEmpty() || h.getName().toLowerCase().contains(term)
                        || h.getCode().toLowerCase().contains(term) || (h.getCity() != null && h.getCity().toLowerCase().contains(term)))
                .map(this::enrich)
                .toList();
    }

    @Transactional(readOnly = true)
    public HotelDtos.Response get(Long id) {
        accessService.assertHotelAccess(id);
        return enrich(requireHotel(id));
    }

    @Transactional
    public HotelDtos.Response create(HotelDtos.Request request) {
        accessService.assertHotelWrite();
        if (hotelRepository.existsByCodeIgnoreCase(request.code().trim())) {
            throw new BusinessException("A hotel with code " + request.code() + " already exists");
        }
        Hotel hotel = Hotel.builder()
                .name(request.name().trim())
                .code(request.code().trim().toUpperCase())
                .address(request.address())
                .city(request.city())
                .state(request.state())
                .country(request.country() == null || request.country().isBlank() ? "India" : request.country())
                .postalCode(request.postalCode())
                .contactNumber(request.contactNumber())
                .email(request.email())
                .description(request.description())
                .imageUrls(request.imageUrls() == null ? new ArrayList<>() : new ArrayList<>(request.imageUrls()))
                .facilities(request.facilities() == null ? new ArrayList<>() : new ArrayList<>(request.facilities()))
                .checkInTime(request.checkInTime() == null ? LocalTime.of(14, 0) : request.checkInTime())
                .checkOutTime(request.checkOutTime() == null ? LocalTime.of(11, 0) : request.checkOutTime())
                .timezone(request.timezone() == null || request.timezone().isBlank() ? "Asia/Kolkata" : request.timezone())
                .starRating(request.starRating())
                .gstNumber(request.gstNumber())
                .taxRate(request.taxRate() == null ? new BigDecimal("12.00") : MoneyUtils.scale(request.taxRate()))
                .status(request.status() == null ? HotelStatus.ACTIVE : request.status())
                .build();
        hotelRepository.save(hotel);
        auditService.record(hotel.getId(), "HOTEL_CREATED", "Hotel", hotel.getId(),
                "Hotel " + hotel.getName() + " created");
        notificationService.dispatch(hotel, null, NotificationType.SYSTEM, NotificationSeverity.SUCCESS,
                "New hotel added", hotel.getName() + " is now part of the portfolio.", "/hotels");
        return enrich(hotel);
    }

    @Transactional
    public HotelDtos.Response update(Long id, HotelDtos.Request request) {
        accessService.assertHotelWrite();
        Hotel hotel = requireHotel(id);
        accessService.assertHotelAccess(hotel.getId());
        if (!hotel.getCode().equalsIgnoreCase(request.code().trim())
                && hotelRepository.existsByCodeIgnoreCase(request.code().trim())) {
            throw new BusinessException("A hotel with code " + request.code() + " already exists");
        }
        hotel.setName(request.name().trim());
        hotel.setCode(request.code().trim().toUpperCase());
        hotel.setAddress(request.address());
        hotel.setCity(request.city());
        hotel.setState(request.state());
        if (request.country() != null && !request.country().isBlank()) {
            hotel.setCountry(request.country());
        }
        hotel.setPostalCode(request.postalCode());
        hotel.setContactNumber(request.contactNumber());
        hotel.setEmail(request.email());
        hotel.setDescription(request.description());
        hotel.setImageUrls(request.imageUrls() == null ? new ArrayList<>() : new ArrayList<>(request.imageUrls()));
        hotel.setFacilities(request.facilities() == null ? new ArrayList<>() : new ArrayList<>(request.facilities()));
        if (request.checkInTime() != null) {
            hotel.setCheckInTime(request.checkInTime());
        }
        if (request.checkOutTime() != null) {
            hotel.setCheckOutTime(request.checkOutTime());
        }
        if (request.timezone() != null && !request.timezone().isBlank()) {
            hotel.setTimezone(request.timezone());
        }
        hotel.setStarRating(request.starRating());
        hotel.setGstNumber(request.gstNumber());
        if (request.taxRate() != null) {
            hotel.setTaxRate(MoneyUtils.scale(request.taxRate()));
        }
        if (request.status() != null) {
            hotel.setStatus(request.status());
        }
        hotelRepository.save(hotel);
        auditService.record(hotel.getId(), "HOTEL_UPDATED", "Hotel", hotel.getId(),
                "Hotel " + hotel.getName() + " updated");
        return enrich(hotel);
    }

    @Transactional
    public HotelDtos.Response updateStatus(Long id, HotelStatus status) {
        accessService.assertHotelWrite();
        Hotel hotel = requireHotel(id);
        hotel.setStatus(status);
        hotelRepository.save(hotel);
        auditService.record(hotel.getId(), "HOTEL_STATUS_CHANGED", "Hotel", hotel.getId(),
                "Hotel " + hotel.getName() + " set to " + status);
        return enrich(hotel);
    }

    @Transactional
    public void delete(Long id) {
        accessService.assertHotelWrite();
        Hotel hotel = requireHotel(id);
        long bookings = bookingRepository.countByHotelId(id);
        if (bookings > 0) {
            throw new BusinessException("This hotel has " + bookings
                    + " booking(s) and cannot be deleted. Deactivate it instead.");
        }
        hotelRepository.delete(hotel);
        auditService.record(id, "HOTEL_DELETED", "Hotel", id, "Hotel " + hotel.getName() + " deleted");
    }

    @Transactional(readOnly = true)
    public List<HotelDtos.HotelStats> stats(List<Long> hotelIds, LocalDate from, LocalDate to) {
        List<Hotel> hotels = hotelRepository.findAllById(hotelIds);
        LocalDate monthStart = LocalDate.now().withDayOfMonth(1);
        LocalDate today = LocalDate.now();
        List<HotelDtos.HotelStats> result = new ArrayList<>();
        for (Hotel hotel : hotels) {
            long totalRooms = roomRepository.countByHotelIdAndActiveTrue(hotel.getId());
            long available = roomRepository.findByHotelIdAndStatus(hotel.getId(), RoomStatus.AVAILABLE).size();
            long occupied = roomRepository.findByHotelIdAndStatus(hotel.getId(), RoomStatus.OCCUPIED).size();
            BigDecimal monthRevenue = paymentRepository.sumCollected(List.of(hotel.getId()),
                    startOfDay(monthStart), startOfDay(monthStart.plusMonths(1)));
            BigDecimal yearRevenue = paymentRepository.sumCollected(List.of(hotel.getId()),
                    startOfDay(LocalDate.of(today.getYear(), 1, 1)),
                    startOfDay(LocalDate.of(today.getYear() + 1, 1, 1)));
            BigDecimal pending = bookingRepository.sumPendingPayments(List.of(hotel.getId()));
            long sold = bookingRepository.countByHotelIdInAndStatus(List.of(hotel.getId()), BookingStatus.CHECKED_IN);
            BigDecimal occupancy = RateMath.percentage(occupied, totalRooms);
            BigDecimal adr = sold == 0 ? BigDecimal.ZERO
                    : MoneyUtils.scale(monthRevenue.divide(BigDecimal.valueOf(Math.max(1, sold)), 2, java.math.RoundingMode.HALF_UP));
            result.add(new HotelDtos.HotelStats(hotel.getId(), hotel.getName(), totalRooms, available, occupied,
                    monthRevenue, yearRevenue, pending, occupancy, adr));
        }
        result.sort((a, b) -> b.revenueThisMonth().compareTo(a.revenueThisMonth()));
        return result;
    }

    @Transactional(readOnly = true)
    public Hotel requireHotel(Long id) {
        return hotelRepository.findById(id).orElseThrow(() -> NotFoundException.of("Hotel", id));
    }

    public HotelDtos.Response enrich(Hotel hotel) {
        long roomCount = roomRepository.countByHotelIdAndActiveTrue(hotel.getId());
        long staffCount = hotelStaffRepository.countByHotelIdAndActiveTrue(hotel.getId());
        long activeBookings = bookingRepository.countByHotelIdInAndStatus(List.of(hotel.getId()), BookingStatus.CHECKED_IN);
        BigDecimal revenue = paymentRepository.sumCollected(List.of(hotel.getId()),
                startOfDay(LocalDate.now().withDayOfMonth(1)),
                startOfDay(LocalDate.now().withDayOfMonth(1).plusMonths(1)));
        HotelDtos.Response base = HotelDtos.Response.from(hotel);
        return new HotelDtos.Response(base.id(), base.name(), base.code(), base.address(), base.city(),
                base.state(), base.country(), base.postalCode(), base.contactNumber(), base.email(),
                base.description(), base.imageUrls(), base.facilities(), base.checkInTime(),
                base.checkOutTime(), base.timezone(), base.starRating(), base.gstNumber(), base.taxRate(),
                base.status(), roomCount, staffCount, activeBookings, revenue, base.createdAt());
    }

    private Instant startOfDay(LocalDate date) {
        return date.atStartOfDay(ZoneOffset.UTC).toInstant();
    }
}
