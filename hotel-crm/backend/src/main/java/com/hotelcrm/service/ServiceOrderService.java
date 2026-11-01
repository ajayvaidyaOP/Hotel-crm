package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.entity.ServiceOrder;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.ServiceOrderStatus;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.repository.ServiceOrderRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;

/** Restaurant, room service, laundry and minibar charges posted against a guest stay. */
@Service
@RequiredArgsConstructor
public class ServiceOrderService {

    private final ServiceOrderRepository serviceOrderRepository;
    private final BookingRepository bookingRepository;
    private final RoomRepository roomRepository;
    private final HotelRepository hotelRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final NotificationService notificationService;

    @Transactional(readOnly = true)
    public List<OpsDtos.ServiceOrderResponse> list(Long hotelId, LocalDate date, ServiceOrderStatus status) {
        accessService.assertPermission(Permission.SERVICE_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate target = date == null ? LocalDate.now() : date;
        Instant from = target.atStartOfDay(ZoneOffset.UTC).toInstant();
        Instant to = target.plusDays(1).atStartOfDay(ZoneOffset.UTC).toInstant();
        return serviceOrderRepository.findByHotelIdInAndOrderedAtBetweenOrderByOrderedAtDesc(scope, from, to).stream()
                .filter(order -> status == null || order.getStatus() == status)
                .map(OpsDtos.ServiceOrderResponse::from)
                .toList();
    }

    @Transactional
    public OpsDtos.ServiceOrderResponse create(OpsDtos.ServiceOrderRequest request) {
        accessService.assertPermission(Permission.SERVICE_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Hotel hotel = hotelRepository.findById(request.hotelId())
                .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId()));
        Booking booking = null;
        if (request.bookingId() != null) {
            booking = bookingRepository.findById(request.bookingId())
                    .orElseThrow(() -> NotFoundException.of("Booking", request.bookingId()));
            if (!booking.getHotel().getId().equals(hotel.getId())) {
                throw new BusinessException("The booking does not belong to the selected hotel");
            }
            if (booking.getStatus() != com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN) {
                throw new BusinessException("Services can only be posted to an in-house guest");
            }
        }
        Room room = null;
        if (request.roomId() != null) {
            room = roomRepository.findById(request.roomId())
                    .orElseThrow(() -> NotFoundException.of("Room", request.roomId()));
        } else if (booking != null && !booking.getRooms().isEmpty()) {
            room = booking.getRooms().get(0).getRoom();
        }
        ServiceOrder order = ServiceOrder.builder()
                .hotel(hotel)
                .booking(booking)
                .room(room)
                .guestId(booking == null ? null : booking.getGuest().getId())
                .orderType(request.orderType() == null
                        ? com.hotelcrm.domain.enums.ServiceOrderType.ROOM_SERVICE : request.orderType())
                .description(request.description().trim())
                .amount(MoneyUtils.scale(request.amount()))
                .quantity(request.quantity() == null ? 1 : request.quantity())
                .status(request.status() == null ? ServiceOrderStatus.PENDING : request.status())
                .billedToRoom(request.billedToRoom() == null || request.billedToRoom())
                .orderedAt(Instant.now())
                .createdBy(accessService.currentUserId())
                .build();
        serviceOrderRepository.save(order);
        auditService.record(hotel.getId(), "SERVICE_ORDER_CREATED", "ServiceOrder", order.getId(),
                order.getOrderType() + " order of " + order.getAmount() + " posted");
        notificationService.dispatch(hotel, null, NotificationType.SYSTEM, NotificationSeverity.INFO,
                "New " + order.getOrderType().getLabel().toLowerCase() + " order",
                order.getDescription() + (room == null ? "" : " - room " + room.getRoomNumber()), "/services");
        return OpsDtos.ServiceOrderResponse.from(order);
    }

    @Transactional
    public OpsDtos.ServiceOrderResponse updateStatus(Long id, ServiceOrderStatus status) {
        accessService.assertPermission(Permission.SERVICE_WRITE);
        ServiceOrder order = serviceOrderRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Service order", id));
        accessService.assertHotelAccess(order.getHotel().getId());
        order.setStatus(status);
        if (status == ServiceOrderStatus.DELIVERED || status == ServiceOrderStatus.SERVED) {
            order.setDeliveredAt(Instant.now());
        }
        serviceOrderRepository.save(order);
        return OpsDtos.ServiceOrderResponse.from(order);
    }

    @Transactional
    public void delete(Long id) {
        accessService.assertPermission(Permission.SERVICE_WRITE);
        ServiceOrder order = serviceOrderRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Service order", id));
        accessService.assertHotelAccess(order.getHotel().getId());
        if (order.getStatus() == ServiceOrderStatus.BILLED) {
            throw new BusinessException("Billed orders cannot be deleted");
        }
        serviceOrderRepository.delete(order);
    }
}
