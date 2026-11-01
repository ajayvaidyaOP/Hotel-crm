package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.LostAndFound;
import com.hotelcrm.domain.entity.MaintenanceRequest;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.MaintenanceStatus;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.repository.GuestRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.LostAndFoundRepository;
import com.hotelcrm.repository.MaintenanceRequestRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MaintenanceService {

    private final MaintenanceRequestRepository maintenanceRepository;
    private final LostAndFoundRepository lostAndFoundRepository;
    private final RoomRepository roomRepository;
    private final HotelRepository hotelRepository;
    private final GuestRepository guestRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final NotificationService notificationService;
    private final UserDirectoryService userDirectoryService;

    /* ----------------------------- maintenance ------------------------------ */

    @Transactional(readOnly = true)
    public List<OpsDtos.MaintenanceResponse> list(Long hotelId, MaintenanceStatus status, String search) {
        accessService.assertPermission(Permission.MAINTENANCE_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        Specification<MaintenanceRequest> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(root.get("hotel").get("id").in(scope));
            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("title")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("description"), "")), like)));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        List<MaintenanceRequest> requests = maintenanceRepository.findAll(spec,
                PageRequest.of(0, 300, Sort.by(Sort.Direction.DESC, "reportedAt"))).getContent();
        java.util.Map<Long, String> names = userDirectoryService.names(
                requests.stream().flatMap(r -> java.util.stream.Stream.of(r.getReportedBy(), r.getAssignedTo()))
                        .toList());
        return requests.stream()
                .map(request -> OpsDtos.MaintenanceResponse.from(request,
                        names.get(request.getReportedBy()), names.get(request.getAssignedTo())))
                .toList();
    }

    @Transactional
    public OpsDtos.MaintenanceResponse create(OpsDtos.MaintenanceRequestDto request) {
        accessService.assertPermission(Permission.MAINTENANCE_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Hotel hotel = hotelRepository.findById(request.hotelId())
                .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId()));
        Room room = null;
        if (request.roomId() != null) {
            room = roomRepository.findById(request.roomId())
                    .orElseThrow(() -> NotFoundException.of("Room", request.roomId()));
            if (!room.getHotel().getId().equals(hotel.getId())) {
                throw new BusinessException("The room does not belong to the selected hotel");
            }
            if (room.getStatus() == RoomStatus.OCCUPIED) {
                throw new BusinessException("Room " + room.getRoomNumber()
                        + " is occupied. Move the guest before taking the room out of service.");
            }
            room.setStatus(RoomStatus.MAINTENANCE);
            room.setHousekeepingStatus(HousekeepingCondition.DIRTY);
            roomRepository.save(room);
        }
        MaintenanceRequest entity = MaintenanceRequest.builder()
                .hotel(hotel)
                .room(room)
                .title(request.title().trim())
                .description(request.description())
                .category(request.category() == null ? "GENERAL" : request.category())
                .priority(request.priority() == null ? com.hotelcrm.domain.enums.TaskPriority.NORMAL : request.priority())
                .status(MaintenanceStatus.OPEN)
                .reportedBy(accessService.currentUserId())
                .assignedTo(request.assignedTo())
                .reportedAt(Instant.now())
                .build();
        maintenanceRepository.save(entity);
        notificationService.dispatch(hotel, null, NotificationType.MAINTENANCE, NotificationSeverity.WARNING,
                "Maintenance request raised",
                entity.getTitle() + (room == null ? "" : " (room " + room.getRoomNumber() + ")"), "/maintenance");
        auditService.record(hotel.getId(), "MAINTENANCE_CREATED", "MaintenanceRequest", entity.getId(),
                "Maintenance request: " + entity.getTitle());
        return OpsDtos.MaintenanceResponse.from(entity,
                userDirectoryService.nameOf(entity.getReportedBy()),
                userDirectoryService.nameOf(entity.getAssignedTo()));
    }

    @Transactional
    public OpsDtos.MaintenanceResponse update(Long id, OpsDtos.MaintenanceUpdateRequest request) {
        accessService.assertPermission(Permission.MAINTENANCE_WRITE);
        MaintenanceRequest entity = maintenanceRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Maintenance request", id));
        accessService.assertHotelAccess(entity.getHotel().getId());
        if (request.status() != null) {
            entity.setStatus(request.status());
        }
        if (request.assignedTo() != null) {
            entity.setAssignedTo(request.assignedTo());
        }
        if (request.cost() != null) {
            entity.setCost(MoneyUtils.scale(request.cost()));
        }
        if (request.resolutionNote() != null) {
            entity.setResolutionNote(request.resolutionNote());
        }
        if (entity.getStatus() == MaintenanceStatus.RESOLVED || entity.getStatus() == MaintenanceStatus.CLOSED) {
            entity.setResolvedAt(entity.getResolvedAt() == null ? Instant.now() : entity.getResolvedAt());
            Room room = entity.getRoom();
            if (room != null && room.getStatus() == RoomStatus.MAINTENANCE) {
                room.setStatus(RoomStatus.AVAILABLE);
                room.setHousekeepingStatus(HousekeepingCondition.DIRTY);
                roomRepository.save(room);
                notificationService.dispatch(entity.getHotel(), null, NotificationType.HOUSEKEEPING,
                        NotificationSeverity.INFO, "Room released from maintenance",
                        "Room " + room.getRoomNumber() + " needs cleaning before it can be sold.", "/housekeeping");
            }
        }
        maintenanceRepository.save(entity);
        auditService.record(entity.getHotel().getId(), "MAINTENANCE_UPDATED", "MaintenanceRequest", entity.getId(),
                "Maintenance request set to " + entity.getStatus());
        return OpsDtos.MaintenanceResponse.from(entity,
                userDirectoryService.nameOf(entity.getReportedBy()),
                userDirectoryService.nameOf(entity.getAssignedTo()));
    }

    /* ----------------------------- lost & found ----------------------------- */

    @Transactional(readOnly = true)
    public List<OpsDtos.LostFoundResponse> lostAndFound(Long hotelId) {
        accessService.assertPermission(Permission.MAINTENANCE_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        List<LostAndFound> items = lostAndFoundRepository.findByHotelIdInOrderByFoundAtDesc(scope);
        java.util.Map<Long, String> names = userDirectoryService.names(items.stream().map(LostAndFound::getFoundBy).toList());
        return items.stream().map(item -> OpsDtos.LostFoundResponse.from(item, names.get(item.getFoundBy()))).toList();
    }

    @Transactional
    public OpsDtos.LostFoundResponse createLostFound(OpsDtos.LostFoundRequest request) {
        accessService.assertPermission(Permission.MAINTENANCE_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Hotel hotel = hotelRepository.findById(request.hotelId())
                .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId()));
        Room room = request.roomId() == null ? null : roomRepository.findById(request.roomId()).orElse(null);
        var guest = request.guestId() == null ? null : guestRepository.findById(request.guestId()).orElse(null);
        LostAndFound item = LostAndFound.builder()
                .hotel(hotel)
                .room(room)
                .guest(guest)
                .itemDescription(request.itemDescription().trim())
                .foundBy(accessService.currentUserId())
                .foundAt(request.foundAt() == null ? Instant.now() : request.foundAt())
                .status(com.hotelcrm.domain.enums.LostFoundStatus.STORED)
                .storageLocation(request.storageLocation())
                .notes(request.notes())
                .build();
        lostAndFoundRepository.save(item);
        auditService.record(hotel.getId(), "LOST_FOUND_LOGGED", "LostAndFound", item.getId(),
                "Item logged: " + item.getItemDescription());
        return OpsDtos.LostFoundResponse.from(item, userDirectoryService.nameOf(item.getFoundBy()));
    }

    @Transactional
    public OpsDtos.LostFoundResponse updateLostFound(Long id, OpsDtos.LostFoundStatusRequest request) {
        accessService.assertPermission(Permission.MAINTENANCE_WRITE);
        LostAndFound item = lostAndFoundRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Lost & found item", id));
        accessService.assertHotelAccess(item.getHotel().getId());
        item.setStatus(request.status());
        lostAndFoundRepository.save(item);
        return OpsDtos.LostFoundResponse.from(item, userDirectoryService.nameOf(item.getFoundBy()));
    }
}
