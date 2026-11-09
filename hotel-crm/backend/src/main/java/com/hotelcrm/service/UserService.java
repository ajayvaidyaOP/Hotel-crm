package com.hotelcrm.service;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.ForbiddenException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.AuditLog;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.HotelStaff;
import com.hotelcrm.domain.entity.StaffAttendance;
import com.hotelcrm.domain.entity.User;
import com.hotelcrm.domain.enums.AttendanceStatus;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.domain.enums.Role;
import com.hotelcrm.dto.HotelDtos;
import com.hotelcrm.dto.UserDtos;
import com.hotelcrm.repository.AuditLogRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.HotelStaffRepository;
import com.hotelcrm.repository.StaffAttendanceRepository;
import com.hotelcrm.repository.UserRepository;
import com.hotelcrm.security.AppUserPrincipal;
import com.hotelcrm.security.HotelAccessService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;
    private final HotelStaffRepository hotelStaffRepository;
    private final StaffAttendanceRepository attendanceRepository;
    private final AuditLogRepository auditLogRepository;
    private final PasswordEncoder passwordEncoder;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final NotificationService notificationService;
    private final UserDirectoryService userDirectoryService;

    /* ------------------------------- staff CRUD ------------------------------- */

    @Transactional(readOnly = true)
    public List<UserDtos.Response> list(Long hotelId, Role role, Boolean active, String search) {
        accessService.assertPermission(Permission.STAFF_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        List<HotelStaff> assignments = hotelStaffRepository.findActiveByHotelIds(scope);
        Map<Long, List<HotelStaff>> byUser = new java.util.HashMap<>();
        assignments.forEach(a -> byUser.computeIfAbsent(a.getUser().getId(), k -> new ArrayList<>()).add(a));

        String term = search == null ? null : search.trim().toLowerCase();
        return byUser.values().stream()
                .map(list -> list.get(0).getUser())
                .filter(user -> role == null || user.getPrimaryRole() == role)
                .filter(user -> active == null || Boolean.valueOf(user.isActive()).equals(active))
                .filter(user -> term == null || term.isEmpty()
                        || user.getFullName().toLowerCase().contains(term)
                        || user.getEmail().toLowerCase().contains(term))
                .sorted(Comparator.comparing(User::getFullName))
                .map(user -> toResponse(user, byUser.get(user.getId())))
                .toList();
    }

    @Transactional(readOnly = true)
    public UserDtos.Response get(Long id) {
        accessService.assertPermission(Permission.STAFF_READ);
        User user = userDirectoryService.require(id);
        List<HotelStaff> assignments = hotelStaffRepository.findByUserId(id);
        boolean allowed = accessService.isSuperAdmin() || assignments.stream()
                .anyMatch(a -> accessService.canAccessHotel(a.getHotel().getId()));
        if (!allowed) {
            throw new ForbiddenException("You do not have access to this staff member");
        }
        return toResponse(user, assignments);
    }

    @Transactional
    public UserDtos.Response create(UserDtos.Request request) {
        assertManageable(request.role(), request.hotelIds());
        if (userRepository.existsByEmailIgnoreCase(request.email().trim())) {
            throw new BusinessException("Another account already uses this email address");
        }
        if (request.password() == null || request.password().isBlank()) {
            throw new BusinessException("A temporary password is required for new staff accounts");
        }
        User user = User.builder()
                .fullName(request.fullName().trim())
                .email(request.email().trim().toLowerCase())
                .phone(request.phone())
                .passwordHash(passwordEncoder.encode(request.password()))
                .primaryRole(request.role())
                .enabled(request.active() == null || request.active())
                .mustChangePassword(Boolean.TRUE)
                .tokenVersion(0)
                .designation(request.designation())
                .build();
        userRepository.save(user);
        saveAssignments(user, request.hotelIds(), request);
        auditService.record(request.hotelIds().get(0), "STAFF_CREATED", "User", user.getId(),
                "Staff account created for " + user.getFullName() + " (" + request.role() + ")");
        notificationService.dispatch(hotelRepository.findById(request.hotelIds().get(0)).orElse(null), null,
                NotificationType.STAFF, NotificationSeverity.INFO, "New team member",
                user.getFullName() + " joined as " + request.role().getLabel(), "/staff");
        return toResponse(user, hotelStaffRepository.findByUserId(user.getId()));
    }

    @Transactional
    public UserDtos.Response update(Long id, UserDtos.UpdateRequest request) {
        User user = userDirectoryService.require(id);
        assertManageable(request.role(), request.hotelIds());
        assertNotSelfRoleChange(user, request.role());
        user.setFullName(request.fullName().trim());
        user.setPhone(request.phone());
        user.setDesignation(request.designation());
        user.setPrimaryRole(request.role());
        if (request.active() != null) {
            if (user.getId().equals(accessService.currentUserId()) && !request.active()) {
                throw new BusinessException("You cannot deactivate your own account");
            }
            user.setEnabled(request.active());
        }
        userRepository.save(user);

        List<HotelStaff> existing = hotelStaffRepository.findByUserId(id);
        for (HotelStaff assignment : existing) {
            if (!request.hotelIds().contains(assignment.getHotel().getId())) {
                hotelStaffRepository.delete(assignment);
            }
        }
        saveAssignments(user, request.hotelIds(), new UserDtos.Request(request.fullName(), user.getEmail(),
                request.phone(), null, request.role(), request.designation(), request.hotelIds(), request.active(),
                request.employeeCode(), request.department(), request.shiftName(), request.shiftStart(),
                request.shiftEnd(), request.joinedOn()));
        auditService.record(request.hotelIds().get(0), "STAFF_UPDATED", "User", user.getId(),
                "Staff account updated for " + user.getFullName());
        return toResponse(user, hotelStaffRepository.findByUserId(id));
    }

    @Transactional
    public UserDtos.Response setActive(Long id, boolean active) {
        accessService.assertPermission(Permission.STAFF_WRITE);
        User user = userDirectoryService.require(id);
        if (user.getId().equals(accessService.currentUserId()) && !active) {
            throw new BusinessException("You cannot deactivate your own account");
        }
        if (!accessService.isSuperAdmin()) {
            if (user.getPrimaryRole() == Role.SUPER_ADMIN || user.getPrimaryRole() == Role.HOTEL_MANAGER) {
                throw new ForbiddenException("Only the owner can manage manager accounts");
            }
            hotelStaffRepository.findByUserId(id).forEach(a -> accessService.assertHotelAccess(a.getHotel().getId()));
        }
        user.setEnabled(active);
        if (!active) {
            user.setTokenVersion(user.getTokenVersion() + 1);
        }
        userRepository.save(user);
        auditService.record(null, active ? "STAFF_ACTIVATED" : "STAFF_DEACTIVATED", "User", user.getId(),
                user.getFullName() + (active ? " activated" : " deactivated"));
        return toResponse(user, hotelStaffRepository.findByUserId(id));
    }

    @Transactional
    public void resetPassword(Long id, String newPassword) {
        accessService.assertPermission(Permission.STAFF_WRITE);
        User user = userDirectoryService.require(id);
        if (!accessService.isSuperAdmin() && user.getPrimaryRole() == Role.SUPER_ADMIN) {
            throw new ForbiddenException("Only the owner can reset another owner account");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setMustChangePassword(Boolean.TRUE);
        user.setTokenVersion(user.getTokenVersion() + 1);
        userRepository.save(user);
        auditService.record(null, "STAFF_PASSWORD_RESET", "User", user.getId(),
                "Password reset by an administrator");
    }

    @Transactional(readOnly = true)
    public PageResponse<AuditLog> activity(Long userId, int page, int size) {
        accessService.assertPermission(Permission.STAFF_READ);
        userDirectoryService.require(userId);
        return PageResponse.of(auditLogRepository.findByUserIdOrderByCreatedAtDesc(userId,
                PageRequest.of(page, size)));
    }

    /* ------------------------------- attendance ------------------------------- */

    @Transactional
    public UserDtos.AttendanceResponse upsertAttendance(UserDtos.AttendanceRequest request) {
        accessService.assertPermission(Permission.STAFF_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Hotel hotel = hotelRepository.findById(request.hotelId())
                .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId()));
        if (!hotelStaffRepository.existsByHotelIdAndUserId(request.hotelId(), request.userId())) {
            throw new BusinessException("This employee is not assigned to the selected hotel");
        }
        StaffAttendance attendance = attendanceRepository
                .findByHotelIdAndUserIdAndAttendanceDate(request.hotelId(), request.userId(), request.attendanceDate())
                .orElseGet(() -> StaffAttendance.builder()
                        .hotel(hotel)
                        .userId(request.userId())
                        .attendanceDate(request.attendanceDate())
                        .build());
        attendance.setStatus(request.status());
        attendance.setShiftName(request.shiftName());
        attendance.setNotes(request.notes());
        if (request.status() == AttendanceStatus.PRESENT || request.status() == AttendanceStatus.HALF_DAY) {
            if (attendance.getCheckInTime() == null) {
                attendance.setCheckInTime(Instant.now());
            }
            if (attendance.getCheckOutTime() == null) {
                attendance.setCheckOutTime(Instant.now());
            }
        }
        attendanceRepository.save(attendance);
        auditService.record(request.hotelId(), "ATTENDANCE_MARKED", "StaffAttendance", attendance.getId(),
                "Attendance " + request.status() + " for user " + request.userId() + " on " + request.attendanceDate());
        return toAttendanceResponse(attendance, userDirectoryService.nameOf(request.userId()),
                userDirectoryService.require(request.userId()).getPrimaryRole().name());
    }

    @Transactional(readOnly = true)
    public List<UserDtos.AttendanceResponse> attendance(Long hotelId, LocalDate date) {
        accessService.assertPermission(Permission.STAFF_READ);
        LocalDate target = date == null ? LocalDate.now() : date;
        List<Long> scope = hotelId == null ? accessService.accessibleHotelIds() : List.of(accessService.requireHotel(hotelId));
        List<StaffAttendance> records = new ArrayList<>();
        for (Long id : scope) {
            records.addAll(attendanceRepository.findByHotelIdAndAttendanceDate(id, target));
        }
        Map<Long, User> users = userDirectoryService.usersById(records.stream().map(StaffAttendance::getUserId).toList());
        return records.stream()
                .sorted(Comparator.comparing(StaffAttendance::getAttendanceDate).reversed())
                .map(record -> {
                    User user = users.get(record.getUserId());
                    return toAttendanceResponse(record, user == null ? "Unknown" : user.getFullName(),
                            user == null ? null : user.getPrimaryRole().name());
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public UserDtos.AttendanceSummary attendanceSummary(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.STAFF_READ);
        Long scopeHotel = accessService.requireHotel(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        List<Object[]> rows = attendanceRepository.countByStatus(scopeHotel, start, end);
        long present = 0;
        long absent = 0;
        long leave = 0;
        long halfDay = 0;
        long weekOff = 0;
        for (Object[] row : rows) {
            AttendanceStatus status = (AttendanceStatus) row[0];
            long count = ((Number) row[1]).longValue();
            switch (status) {
                case PRESENT -> present += count;
                case ABSENT -> absent += count;
                case LEAVE -> leave += count;
                case HALF_DAY -> halfDay += count;
                case WEEK_OFF -> weekOff += count;
                default -> {
                }
            }
        }
        return new UserDtos.AttendanceSummary(present, absent, leave, halfDay, weekOff,
                hotelStaffRepository.countByHotelIdAndActiveTrue(scopeHotel));
    }

    /* -------------------------------- helpers -------------------------------- */

    private void assertManageable(Role targetRole, List<Long> hotelIds) {
        accessService.assertPermission(Permission.STAFF_WRITE);
        if (hotelIds == null || hotelIds.isEmpty()) {
            throw new BusinessException("Assign the staff member to at least one hotel");
        }
        hotelIds.forEach(accessService::assertHotelAccess);
        if (!accessService.isSuperAdmin() && (targetRole == Role.SUPER_ADMIN || targetRole == Role.HOTEL_MANAGER)) {
            throw new ForbiddenException("Only the owner can create or modify owner and manager accounts");
        }
    }

    private void assertNotSelfRoleChange(User user, Role newRole) {
        AppUserPrincipal principal = accessService.currentUser();
        if (user.getId().equals(principal.getId()) && user.getPrimaryRole() != newRole) {
            throw new BusinessException("You cannot change your own role");
        }
    }

    private void saveAssignments(User user, List<Long> hotelIds, UserDtos.Request request) {
        for (Long hotelId : hotelIds) {
            Hotel hotel = hotelRepository.findById(hotelId)
                    .orElseThrow(() -> NotFoundException.of("Hotel", hotelId));
            HotelStaff assignment = hotelStaffRepository.findByHotelIdAndUserId(hotelId, user.getId())
                    .orElseGet(() -> HotelStaff.builder().hotel(hotel).user(user).build());
            assignment.setDesignation(request.designation());
            assignment.setDepartment(request.department());
            assignment.setShiftName(request.shiftName());
            assignment.setShiftStart(request.shiftStart());
            assignment.setShiftEnd(request.shiftEnd());
            assignment.setJoinedOn(request.joinedOn());
            assignment.setEmployeeCode(request.employeeCode() != null && !request.employeeCode().isBlank()
                    ? request.employeeCode()
                    : assignment.getEmployeeCode() != null ? assignment.getEmployeeCode()
                    : hotel.getCode() + "-EMP-" + String.format("%03d", user.getId()));
            assignment.setActive(Boolean.TRUE);
            hotelStaffRepository.save(assignment);
        }
    }

    private UserDtos.Response toResponse(User user, List<HotelStaff> assignments) {
        List<HotelStaff> active = assignments == null ? List.of()
                : assignments.stream().filter(a -> Boolean.TRUE.equals(a.getActive())).toList();
        List<HotelDtos.Summary> hotels = active.stream()
                .map(a -> HotelDtos.Summary.from(a.getHotel()))
                .toList();
        HotelStaff primary = active.stream().filter(Objects::nonNull).findFirst().orElse(null);
        return new UserDtos.Response(user.getId(), user.getFullName(), user.getEmail(), user.getPhone(),
                user.getPrimaryRole(), user.getPrimaryRole().getLabel(), user.getDesignation(),
                user.isActive(), user.getLastLoginAt(), user.getCreatedAt(), hotels,
                primary == null ? null : primary.getEmployeeCode(),
                primary == null ? null : primary.getDepartment(),
                primary == null ? null : primary.getShiftName(),
                primary == null ? null : primary.getShiftStart(),
                primary == null ? null : primary.getShiftEnd(),
                primary == null ? null : primary.getJoinedOn());
    }

    private UserDtos.AttendanceResponse toAttendanceResponse(StaffAttendance record, String userName, String role) {
        return new UserDtos.AttendanceResponse(record.getId(), record.getHotel().getId(), record.getUserId(),
                userName, role, record.getAttendanceDate(), record.getStatus(), record.getShiftName(),
                record.getCheckInTime(), record.getCheckOutTime(), record.getNotes());
    }
}
