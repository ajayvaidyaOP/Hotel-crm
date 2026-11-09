package com.hotelcrm.controller;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.domain.entity.AuditLog;
import com.hotelcrm.domain.enums.Role;
import com.hotelcrm.dto.AuthDtos;
import com.hotelcrm.dto.UserDtos;
import com.hotelcrm.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Staff management")
@RestController
@RequestMapping("/api/staff")
@RequiredArgsConstructor
public class StaffController {

    private final UserService userService;

    @GetMapping
    public List<UserDtos.Response> list(@RequestParam(required = false) Long hotelId,
                                        @RequestParam(required = false) Role role,
                                        @RequestParam(required = false) Boolean active,
                                        @RequestParam(required = false) String search) {
        return userService.list(hotelId, role, active, search);
    }

    @GetMapping("/{id}")
    public UserDtos.Response get(@PathVariable Long id) {
        return userService.get(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserDtos.Response create(@Valid @RequestBody UserDtos.Request request) {
        return userService.create(request);
    }

    @PutMapping("/{id}")
    public UserDtos.Response update(@PathVariable Long id, @Valid @RequestBody UserDtos.UpdateRequest request) {
        return userService.update(id, request);
    }

    @PatchMapping("/{id}/status")
    public UserDtos.Response setActive(@PathVariable Long id, @Valid @RequestBody UserDtos.StatusRequest request) {
        return userService.setActive(id, request.active());
    }

    @PostMapping("/{id}/reset-password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void resetPassword(@PathVariable Long id,
                              @Valid @RequestBody UserDtos.PasswordResetByAdminRequest request) {
        userService.resetPassword(id, request.newPassword());
    }

    @GetMapping("/{id}/activity")
    public PageResponse<AuditLog> activity(@PathVariable Long id,
                                           @RequestParam(defaultValue = "0") int page,
                                           @RequestParam(defaultValue = "20") int size) {
        return userService.activity(id, page, size);
    }

    @GetMapping("/attendance")
    public List<UserDtos.AttendanceResponse> attendance(@RequestParam(required = false) Long hotelId,
                                                        @RequestParam(required = false)
                                                        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return userService.attendance(hotelId, date);
    }

    @PostMapping("/attendance")
    @ResponseStatus(HttpStatus.CREATED)
    public UserDtos.AttendanceResponse markAttendance(@Valid @RequestBody UserDtos.AttendanceRequest request) {
        return userService.upsertAttendance(request);
    }

    @GetMapping("/attendance/summary")
    public UserDtos.AttendanceSummary attendanceSummary(
            @RequestParam Long hotelId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return userService.attendanceSummary(hotelId, from, to);
    }
}
