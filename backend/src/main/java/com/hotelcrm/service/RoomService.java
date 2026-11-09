package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.BookingRoom;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.entity.RoomCategory;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.dto.BookingDtos;
import com.hotelcrm.dto.RoomDtos;
import com.hotelcrm.repository.BookingRoomRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.RoomCategoryRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoomService {

    private static final List<BookingStatus> HOLDING_STATUSES =
            List.of(BookingStatus.PENDING, BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN);

    private final RoomRepository roomRepository;
    private final RoomCategoryRepository categoryRepository;
    private final HotelRepository hotelRepository;
    private final BookingRoomRepository bookingRoomRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;

    /* --------------------------- room categories --------------------------- */

    @Transactional(readOnly = true)
    public List<RoomDtos.CategoryResponse> categories(Long hotelId) {
        accessService.assertPermission(Permission.ROOM_READ);
        Long scope = accessService.requireHotel(hotelId);
        return categoryRepository.findByHotelIdOrderBySortOrderAsc(scope).stream()
                .map(category -> RoomDtos.CategoryResponse.from(category,
                        bookingRoomRepository.countByRoomCategoryId(category.getId())))
                .toList();
    }

    @Transactional
    public RoomDtos.CategoryResponse createCategory(Long hotelId, RoomDtos.CategoryRequest request) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Long scope = accessService.requireHotel(hotelId);
        Hotel hotel = hotelRepository.findById(scope).orElseThrow(() -> NotFoundException.of("Hotel", scope));
        if (categoryRepository.existsByHotelIdAndCodeIgnoreCase(scope, request.code().trim())) {
            throw new BusinessException("A category with code " + request.code() + " already exists for this hotel");
        }
        RoomCategory category = RoomCategory.builder()
                .hotel(hotel)
                .name(request.name().trim())
                .code(request.code().trim().toUpperCase(Locale.ROOT))
                .description(request.description())
                .basePrice(MoneyUtils.scale(request.basePrice()))
                .weekendPrice(request.weekendPrice() == null ? null : MoneyUtils.scale(request.weekendPrice()))
                .extraPersonCharge(MoneyUtils.scale(request.extraPersonCharge()))
                .extraBedCharge(MoneyUtils.scale(request.extraBedCharge()))
                .earlyCheckinCharge(MoneyUtils.scale(request.earlyCheckinCharge()))
                .lateCheckoutCharge(MoneyUtils.scale(request.lateCheckoutCharge()))
                .maxOccupancy(request.maxOccupancy() == null ? 2 : request.maxOccupancy())
                .amenities(request.amenities() == null ? new ArrayList<>() : new ArrayList<>(request.amenities()))
                .imageUrls(request.imageUrls() == null ? new ArrayList<>() : new ArrayList<>(request.imageUrls()))
                .sortOrder(request.sortOrder() == null ? 0 : request.sortOrder())
                .active(request.active() == null || request.active())
                .build();
        categoryRepository.save(category);
        auditService.record(scope, "ROOM_CATEGORY_CREATED", "RoomCategory", category.getId(),
                "Category " + category.getName() + " created");
        return RoomDtos.CategoryResponse.from(category, 0);
    }

    @Transactional
    public RoomDtos.CategoryResponse updateCategory(Long hotelId, Long categoryId, RoomDtos.CategoryRequest request) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Long scope = accessService.requireHotel(hotelId);
        RoomCategory category = categoryRepository.findByIdAndHotelId(categoryId, scope)
                .orElseThrow(() -> NotFoundException.of("Room category", categoryId));
        if (!category.getCode().equalsIgnoreCase(request.code().trim())
                && categoryRepository.existsByHotelIdAndCodeIgnoreCase(scope, request.code().trim())) {
            throw new BusinessException("A category with code " + request.code() + " already exists for this hotel");
        }
        category.setName(request.name().trim());
        category.setCode(request.code().trim().toUpperCase(Locale.ROOT));
        category.setDescription(request.description());
        category.setBasePrice(MoneyUtils.scale(request.basePrice()));
        category.setWeekendPrice(request.weekendPrice() == null ? null : MoneyUtils.scale(request.weekendPrice()));
        category.setExtraPersonCharge(MoneyUtils.scale(request.extraPersonCharge()));
        category.setExtraBedCharge(MoneyUtils.scale(request.extraBedCharge()));
        category.setEarlyCheckinCharge(MoneyUtils.scale(request.earlyCheckinCharge()));
        category.setLateCheckoutCharge(MoneyUtils.scale(request.lateCheckoutCharge()));
        if (request.maxOccupancy() != null) {
            category.setMaxOccupancy(request.maxOccupancy());
        }
        category.setAmenities(request.amenities() == null ? new ArrayList<>() : new ArrayList<>(request.amenities()));
        category.setImageUrls(request.imageUrls() == null ? new ArrayList<>() : new ArrayList<>(request.imageUrls()));
        if (request.sortOrder() != null) {
            category.setSortOrder(request.sortOrder());
        }
        if (request.active() != null) {
            category.setActive(request.active());
        }
        categoryRepository.save(category);
        auditService.record(scope, "ROOM_CATEGORY_UPDATED", "RoomCategory", category.getId(),
                "Category " + category.getName() + " updated");
        return RoomDtos.CategoryResponse.from(category, bookingRoomRepository.countByRoomCategoryId(categoryId));
    }

    @Transactional
    public void deleteCategory(Long hotelId, Long categoryId) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Long scope = accessService.requireHotel(hotelId);
        RoomCategory category = categoryRepository.findByIdAndHotelId(categoryId, scope)
                .orElseThrow(() -> NotFoundException.of("Room category", categoryId));
        long rooms = roomRepository.findAllByHotelId(scope).stream()
                .filter(room -> room.getCategory().getId().equals(categoryId)).count();
        if (rooms > 0) {
            throw new BusinessException("This category still has rooms. Move or delete those rooms first.");
        }
        categoryRepository.delete(category);
        auditService.record(scope, "ROOM_CATEGORY_DELETED", "RoomCategory", categoryId, "Category deleted");
    }

    /* -------------------------------- rooms -------------------------------- */

    @Transactional(readOnly = true)
    public List<RoomDtos.RoomResponse> rooms(Long hotelId, Long categoryId, RoomStatus status,
                                             HousekeepingCondition housekeeping, Integer floor, String search) {
        accessService.assertPermission(Permission.ROOM_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        List<Room> rooms = roomRepository.findActiveByHotels(scope);
        Map<Long, BookingDtos.RoomSegment> inHouse = currentStays(scope);
        String term = search == null ? null : search.trim().toLowerCase(Locale.ROOT);
        return rooms.stream()
                .filter(room -> categoryId == null || room.getCategory().getId().equals(categoryId))
                .filter(room -> status == null || room.getStatus() == status)
                .filter(room -> housekeeping == null || room.getHousekeepingStatus() == housekeeping)
                .filter(room -> floor == null || room.getFloor().equals(floor))
                .filter(room -> term == null || term.isEmpty()
                        || room.getRoomNumber().toLowerCase(Locale.ROOT).contains(term)
                        || room.getCategory().getName().toLowerCase(Locale.ROOT).contains(term))
                .sorted(Comparator.comparing((Room r) -> r.getHotel().getId())
                        .thenComparing(Room::getFloor).thenComparing(Room::getRoomNumber))
                .map(room -> withStay(RoomDtos.RoomResponse.from(room), inHouse.get(room.getId())))
                .toList();
    }

    @Transactional(readOnly = true)
    public RoomDtos.RoomResponse get(Long roomId) {
        accessService.assertPermission(Permission.ROOM_READ);
        Room room = requireRoom(roomId);
        return withStay(RoomDtos.RoomResponse.from(room), currentStays(List.of(room.getHotel().getId())).get(roomId));
    }

    @Transactional
    public RoomDtos.RoomResponse create(Long hotelId, RoomDtos.RoomRequest request) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Long scope = accessService.requireHotel(hotelId);
        Hotel hotel = hotelRepository.findById(scope).orElseThrow(() -> NotFoundException.of("Hotel", scope));
        RoomCategory category = categoryRepository.findByIdAndHotelId(request.categoryId(), scope)
                .orElseThrow(() -> NotFoundException.of("Room category", request.categoryId()));
        if (roomRepository.existsByHotelIdAndRoomNumberIgnoreCase(scope, request.roomNumber().trim())) {
            throw new BusinessException("Room number " + request.roomNumber() + " already exists in this hotel");
        }
        Room room = buildRoom(hotel, category, request);
        roomRepository.save(room);
        auditService.record(scope, "ROOM_CREATED", "Room", room.getId(),
                "Room " + room.getRoomNumber() + " created");
        return RoomDtos.RoomResponse.from(room);
    }

    @Transactional
    public List<RoomDtos.RoomResponse> bulkCreate(Long hotelId, Long categoryId, Integer floor, Integer count,
                                                  Integer startNumber) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Long scope = accessService.requireHotel(hotelId);
        Hotel hotel = hotelRepository.findById(scope).orElseThrow(() -> NotFoundException.of("Hotel", scope));
        RoomCategory category = categoryRepository.findByIdAndHotelId(categoryId, scope)
                .orElseThrow(() -> NotFoundException.of("Room category", categoryId));
        if (count == null || count < 1 || count > 100) {
            throw new BusinessException("Number of rooms to create must be between 1 and 100");
        }
        int floorValue = floor == null ? 1 : floor;
        int start = startNumber == null ? floorValue * 100 + 1 : startNumber;
        List<RoomDtos.RoomResponse> created = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            String number = String.valueOf(start + i);
            if (roomRepository.existsByHotelIdAndRoomNumberIgnoreCase(scope, number)) {
                continue;
            }
            Room room = Room.builder()
                    .hotel(hotel)
                    .category(category)
                    .roomNumber(number)
                    .floor(floorValue)
                    .maxOccupancy(category.getMaxOccupancy())
                    .basePrice(category.getBasePrice())
                    .weekendPrice(category.getWeekendPrice())
                    .extraPersonCharge(category.getExtraPersonCharge())
                    .amenities(new ArrayList<>(category.getAmenities()))
                    .status(RoomStatus.AVAILABLE)
                    .housekeepingStatus(HousekeepingCondition.CLEAN)
                    .build();
            roomRepository.save(room);
            created.add(RoomDtos.RoomResponse.from(room));
        }
        auditService.record(scope, "ROOM_BULK_CREATED", "Room", null,
                created.size() + " rooms created for category " + category.getName());
        return created;
    }

    @Transactional
    public RoomDtos.RoomResponse update(Long roomId, RoomDtos.RoomRequest request) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Room room = requireRoom(roomId);
        Long hotelId = room.getHotel().getId();
        RoomCategory category = categoryRepository.findByIdAndHotelId(request.categoryId(), hotelId)
                .orElseThrow(() -> NotFoundException.of("Room category", request.categoryId()));
        if (!room.getRoomNumber().equalsIgnoreCase(request.roomNumber().trim())
                && roomRepository.existsByHotelIdAndRoomNumberIgnoreCase(hotelId, request.roomNumber().trim())) {
            throw new BusinessException("Room number " + request.roomNumber() + " already exists in this hotel");
        }
        room.setCategory(category);
        room.setRoomNumber(request.roomNumber().trim());
        room.setFloor(request.floor() == null ? room.getFloor() : request.floor());
        if (request.roomType() != null) {
            room.setRoomType(request.roomType());
        }
        if (request.bedType() != null) {
            room.setBedType(request.bedType());
        }
        if (request.maxOccupancy() != null) {
            room.setMaxOccupancy(request.maxOccupancy());
        }
        if (request.ac() != null) {
            room.setAc(request.ac());
        }
        room.setDescription(request.description());
        room.setImageUrls(request.imageUrls() == null ? new ArrayList<>() : new ArrayList<>(request.imageUrls()));
        room.setAmenities(request.amenities() == null ? new ArrayList<>() : new ArrayList<>(request.amenities()));
        room.setBasePrice(MoneyUtils.scale(request.basePrice()));
        room.setWeekendPrice(request.weekendPrice() == null ? null : MoneyUtils.scale(request.weekendPrice()));
        room.setExtraPersonCharge(MoneyUtils.scale(request.extraPersonCharge()));
        if (request.status() != null) {
            room.setStatus(request.status());
        }
        if (request.housekeepingStatus() != null) {
            room.setHousekeepingStatus(request.housekeepingStatus());
        }
        if (request.active() != null) {
            room.setActive(request.active());
        }
        roomRepository.save(room);
        auditService.record(hotelId, "ROOM_UPDATED", "Room", room.getId(),
                "Room " + room.getRoomNumber() + " updated");
        return RoomDtos.RoomResponse.from(room);
    }

    @Transactional
    public RoomDtos.RoomResponse updateStatus(Long roomId, RoomDtos.StatusRequest request) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Room room = requireRoom(roomId);
        if (room.getStatus() == RoomStatus.OCCUPIED && request.status() != null
                && request.status() != RoomStatus.OCCUPIED) {
            throw new BusinessException("This room is occupied. Check the guest out before changing its status.");
        }
        if (request.status() != null) {
            room.setStatus(request.status());
        }
        if (request.housekeepingStatus() != null) {
            room.setHousekeepingStatus(request.housekeepingStatus());
        }
        roomRepository.save(room);
        auditService.record(room.getHotel().getId(), "ROOM_STATUS_CHANGED", "Room", room.getId(),
                "Room " + room.getRoomNumber() + " set to " + room.getStatus()
                        + " / " + room.getHousekeepingStatus());
        return RoomDtos.RoomResponse.from(room);
    }

    @Transactional
    public void delete(Long roomId) {
        accessService.assertPermission(Permission.ROOM_WRITE);
        Room room = requireRoom(roomId);
        if (bookingRoomRepository.existsByRoom_Id(roomId)) {
            throw new BusinessException("This room has booking history and cannot be deleted. "
                    + "Mark it out of service instead.");
        }
        roomRepository.delete(room);
        auditService.record(room.getHotel().getId(), "ROOM_DELETED", "Room", roomId, "Room deleted");
    }

    @Transactional(readOnly = true)
    public List<BookingDtos.TimelineEntry> history(Long roomId) {
        accessService.assertPermission(Permission.ROOM_READ);
        Room room = requireRoom(roomId);
        return bookingRoomRepository.findHistoryForRoom(roomId, HOLDING_STATUSES).stream()
                .map(segment -> new BookingDtos.TimelineEntry(segment.getBooking().getId(),
                        segment.getBooking().getBookingCode(), segment.getId(), room.getId(), room.getRoomNumber(),
                        segment.getBooking().getGuest().getFullName(), segment.getBooking().getGuest().getMobile(),
                        segment.getCheckInDate(), segment.getCheckOutDate(), segment.getNights(),
                        segment.getBooking().getStatus(), segment.getBooking().getPaymentStatus(),
                        segment.getBooking().getTotalAmount(), segment.getBooking().getPendingAmount(),
                        segment.getBooking().getAdults(), segment.getBooking().getChildren()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<RoomDtos.AvailabilityResponse> availability(Long hotelId, Long categoryId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.ROOM_READ);
        Long scope = accessService.requireHotel(hotelId);
        List<Room> rooms = roomRepository.findAllByHotelId(scope).stream()
                .filter(room -> room.getCategory() != null && (categoryId == null || room.getCategory().getId().equals(categoryId)))
                .filter(room -> Boolean.TRUE.equals(room.getActive()))
                .filter(room -> room.getStatus() != RoomStatus.OUT_OF_SERVICE && room.getStatus() != RoomStatus.MAINTENANCE)
                .toList();
        Map<String, Integer> counter = new HashMap<>();
        Map<Long, Room> byId = new HashMap<>();
        for (Room room : rooms) {
            boolean blocked = from != null && to != null
                    && bookingRoomRepository.countOverlapping(room.getId(), from, to, HOLDING_STATUSES, -1L) > 0;
            if (blocked) {
                continue;
            }
            counter.merge(room.getCategory().getId().toString(), 1, Integer::sum);
            byId.putIfAbsent(room.getCategory().getId(), room);
        }
        return counter.entrySet().stream().map(entry -> {
            Room sample = byId.get(Long.valueOf(entry.getKey()));
            return new RoomDtos.AvailabilityResponse(entry.getValue() > 0 ? sample.getId() : null,
                    entry.getValue() > 0 ? sample.getRoomNumber() : null,
                    sample.getCategory().getId(), sample.getCategory().getName(),
                    sample.getCategory().getBasePrice(), entry.getValue());
        }).toList();
    }

    /* -------------------------------- helpers -------------------------------- */

    @Transactional(readOnly = true)
    public Room requireRoom(Long roomId) {
        Room room = roomRepository.findById(roomId).orElseThrow(() -> NotFoundException.of("Room", roomId));
        accessService.assertHotelAccess(room.getHotel().getId());
        return room;
    }

    private Map<Long, BookingDtos.RoomSegment> currentStays(List<Long> hotelIds) {
        Map<Long, BookingDtos.RoomSegment> map = new HashMap<>();
        bookingRoomRepository.findInHouseSegments(hotelIds).forEach(segment -> {
            if (segment.getRoom() != null) {
                map.putIfAbsent(segment.getRoom().getId(), BookingDtos.RoomSegment.from(segment));
            }
        });
        return map;
    }

    private RoomDtos.RoomResponse withStay(RoomDtos.RoomResponse base, BookingDtos.RoomSegment stay) {
        return new RoomDtos.RoomResponse(base.id(), base.hotelId(), base.hotelName(), base.categoryId(),
                base.categoryName(), base.categoryCode(), base.roomNumber(), base.floor(), base.roomType(),
                base.bedType(), base.maxOccupancy(), base.ac(), base.description(), base.imageUrls(),
                base.amenities(), base.basePrice(), base.weekendPrice(), base.extraPersonCharge(),
                base.status(), base.housekeepingStatus(), base.active(), stay);
    }

    private Room buildRoom(Hotel hotel, RoomCategory category, RoomDtos.RoomRequest request) {
        BigDecimal base = request.basePrice() == null ? category.getBasePrice() : MoneyUtils.scale(request.basePrice());
        return Room.builder()
                .hotel(hotel)
                .category(category)
                .roomNumber(request.roomNumber().trim())
                .floor(request.floor() == null ? 0 : request.floor())
                .roomType(request.roomType() == null ? com.hotelcrm.domain.enums.RoomType.DOUBLE : request.roomType())
                .bedType(request.bedType() == null ? com.hotelcrm.domain.enums.BedType.DOUBLE : request.bedType())
                .maxOccupancy(request.maxOccupancy() == null ? category.getMaxOccupancy() : request.maxOccupancy())
                .ac(request.ac() == null || request.ac())
                .description(request.description())
                .imageUrls(request.imageUrls() == null ? new ArrayList<>() : new ArrayList<>(request.imageUrls()))
                .amenities(request.amenities() == null ? new ArrayList<>(category.getAmenities())
                        : new ArrayList<>(request.amenities()))
                .basePrice(base)
                .weekendPrice(request.weekendPrice() == null ? category.getWeekendPrice()
                        : MoneyUtils.scale(request.weekendPrice()))
                .extraPersonCharge(MoneyUtils.scale(request.extraPersonCharge()))
                .status(request.status() == null ? RoomStatus.AVAILABLE : request.status())
                .housekeepingStatus(request.housekeepingStatus() == null
                        ? HousekeepingCondition.CLEAN : request.housekeepingStatus())
                .active(request.active() == null || request.active())
                .build();
    }
}
