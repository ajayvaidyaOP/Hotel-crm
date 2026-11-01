package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.HousekeepingTask;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.HousekeepingTaskStatus;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.HousekeepingTaskRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.security.HotelAccessService;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HousekeepingService {

    private final HousekeepingTaskRepository taskRepository;
    private final RoomRepository roomRepository;
    private final HotelRepository hotelRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final NotificationService notificationService;
    private final UserDirectoryService userDirectoryService;

    @Transactional(readOnly = true)
    public List<OpsDtos.HousekeepingResponse> list(Long hotelId, HousekeepingTaskStatus status, Long assignedTo,
                                                   Long roomId, String search) {
        accessService.assertPermission(Permission.HOUSEKEEPING_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        Specification<HousekeepingTask> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(root.get("hotel").get("id").in(scope));
            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (assignedTo != null) {
                predicates.add(cb.equal(root.get("assignedTo"), assignedTo));
            }
            if (roomId != null) {
                predicates.add(cb.equal(root.get("room").get("id"), roomId));
            }
            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase() + "%";
                predicates.add(cb.or(cb.like(cb.lower(cb.coalesce(root.get("notes"), "")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("room").get("roomNumber"), "")), like)));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        List<HousekeepingTask> tasks = taskRepository.findAll(spec,
                PageRequest.of(0, 300, Sort.by(Sort.Direction.DESC, "createdAt"))).getContent();
        java.util.Map<Long, String> names = userDirectoryService.names(
                tasks.stream().map(HousekeepingTask::getAssignedTo).toList());
        return tasks.stream()
                .map(task -> OpsDtos.HousekeepingResponse.from(task, names.get(task.getAssignedTo())))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<OpsDtos.HousekeepingResponse> myTasks() {
        accessService.assertPermission(Permission.HOUSEKEEPING_READ);
        List<Long> scope = accessService.accessibleHotelIds();
        List<HousekeepingTask> tasks = taskRepository.findForStaff(accessService.currentUserId(),
                        List.of(HousekeepingTaskStatus.PENDING, HousekeepingTaskStatus.IN_PROGRESS,
                                HousekeepingTaskStatus.COMPLETED))
                .stream().filter(task -> scope.contains(task.getHotel().getId())).toList();
        return tasks.stream()
                .map(task -> OpsDtos.HousekeepingResponse.from(task,
                        userDirectoryService.nameOf(task.getAssignedTo())))
                .toList();
    }

    @Transactional
    public OpsDtos.HousekeepingResponse create(OpsDtos.HousekeepingRequest request) {
        accessService.assertPermission(Permission.HOUSEKEEPING_WRITE);
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
        }
        HousekeepingTask task = HousekeepingTask.builder()
                .hotel(hotel)
                .room(room)
                .taskType(request.taskType() == null
                        ? com.hotelcrm.domain.enums.HousekeepingTaskType.CLEANING : request.taskType())
                .status(request.status() == null ? HousekeepingTaskStatus.PENDING : request.status())
                .priority(request.priority() == null ? com.hotelcrm.domain.enums.TaskPriority.NORMAL : request.priority())
                .assignedTo(request.assignedTo())
                .notes(request.notes())
                .scheduledDate(request.scheduledDate() == null ? LocalDate.now() : request.scheduledDate())
                .createdBy(accessService.currentUserId())
                .build();
        taskRepository.save(task);
        if (room != null) {
            room.setHousekeepingStatus(HousekeepingCondition.DIRTY);
            if (room.getStatus() == RoomStatus.AVAILABLE) {
                room.setStatus(RoomStatus.CLEANING);
            }
            roomRepository.save(room);
        }
        auditService.record(hotel.getId(), "HOUSEKEEPING_TASK_CREATED", "HousekeepingTask", task.getId(),
                "Cleaning task created" + (room == null ? "" : " for room " + room.getRoomNumber()));
        if (request.assignedTo() != null) {
            notificationService.dispatch(hotel, request.assignedTo(), NotificationType.HOUSEKEEPING,
                    NotificationSeverity.INFO, "New cleaning task",
                    "You have been assigned a cleaning task"
                            + (room == null ? "" : " for room " + room.getRoomNumber()) + ".", "/housekeeping");
        }
        return OpsDtos.HousekeepingResponse.from(task, userDirectoryService.nameOf(task.getAssignedTo()));
    }

    @Transactional
    public OpsDtos.HousekeepingResponse updateStatus(Long id, OpsDtos.HousekeepingStatusRequest request) {
        accessService.assertPermission(Permission.HOUSEKEEPING_WRITE);
        HousekeepingTask task = taskRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Housekeeping task", id));
        accessService.assertHotelAccess(task.getHotel().getId());
        if (task.getStatus() == HousekeepingTaskStatus.CANCELLED) {
            throw new BusinessException("This task was cancelled");
        }
        HousekeepingTaskStatus next = request.status();
        task.setStatus(next);
        if (request.assignedTo() != null) {
            task.setAssignedTo(request.assignedTo());
        }
        if (request.notes() != null) {
            task.setNotes(request.notes());
        }
        if (next == HousekeepingTaskStatus.IN_PROGRESS && task.getStartedAt() == null) {
            task.setStartedAt(Instant.now());
        }
        if (next == HousekeepingTaskStatus.COMPLETED || next == HousekeepingTaskStatus.INSPECTED) {
            task.setCompletedAt(Instant.now());
        }
        if (next == HousekeepingTaskStatus.INSPECTED) {
            task.setInspectedBy(accessService.currentUserId());
            task.setInspectedAt(Instant.now());
        }
        taskRepository.save(task);

        Room room = task.getRoom();
        if (room != null) {
            if (next == HousekeepingTaskStatus.IN_PROGRESS) {
                room.setHousekeepingStatus(HousekeepingCondition.DIRTY);
            }
            if (next == HousekeepingTaskStatus.COMPLETED) {
                room.setHousekeepingStatus(HousekeepingCondition.CLEAN);
                if (room.getStatus() == RoomStatus.CLEANING) {
                    room.setStatus(RoomStatus.AVAILABLE);
                }
            }
            if (next == HousekeepingTaskStatus.INSPECTED) {
                room.setHousekeepingStatus(HousekeepingCondition.INSPECTED);
                if (room.getStatus() == RoomStatus.CLEANING) {
                    room.setStatus(RoomStatus.AVAILABLE);
                }
            }
            roomRepository.save(room);
        }
        if (next == HousekeepingTaskStatus.COMPLETED || next == HousekeepingTaskStatus.INSPECTED) {
            notificationService.dispatch(task.getHotel(), null, NotificationType.HOUSEKEEPING,
                    NotificationSeverity.SUCCESS, "Room ready",
                    (room == null ? "Cleaning task" : "Room " + room.getRoomNumber())
                            + " is ready for guests.", "/rooms");
        }
        auditService.record(task.getHotel().getId(), "HOUSEKEEPING_STATUS_CHANGED", "HousekeepingTask",
                task.getId(), "Task set to " + next);
        return OpsDtos.HousekeepingResponse.from(task, userDirectoryService.nameOf(task.getAssignedTo()));
    }

    @Transactional
    public void delete(Long id) {
        accessService.assertPermission(Permission.HOUSEKEEPING_WRITE);
        HousekeepingTask task = taskRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Housekeeping task", id));
        accessService.assertHotelAccess(task.getHotel().getId());
        taskRepository.delete(task);
    }

    @Transactional(readOnly = true)
    public long pendingCount(Long hotelId) {
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        return taskRepository.countOpen(scope, HousekeepingTaskStatus.PENDING);
    }
}
