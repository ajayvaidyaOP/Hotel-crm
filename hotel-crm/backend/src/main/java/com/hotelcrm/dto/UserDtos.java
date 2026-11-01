package com.hotelcrm.dto;

import com.hotelcrm.domain.enums.AttendanceStatus;
import com.hotelcrm.domain.enums.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public final class UserDtos {

    private UserDtos() {
    }

    public record Request(
            @NotBlank(message = "Full name is required") @Size(max = 120) String fullName,
            @NotBlank(message = "Email is required") @Email(message = "Enter a valid email") @Size(max = 160) String email,
            @Size(max = 30) String phone,
            @Size(min = 8, max = 72, message = "Password must be between 8 and 72 characters") String password,
            @NotNull(message = "Role is required") Role role,
            @Size(max = 80) String designation,
            @NotEmpty(message = "Assign at least one hotel") List<Long> hotelIds,
            Boolean active,
            @Size(max = 30) String employeeCode,
            @Size(max = 60) String department,
            @Size(max = 30) String shiftName,
            LocalTime shiftStart,
            LocalTime shiftEnd,
            LocalDate joinedOn) {
    }

    public record UpdateRequest(
            @NotBlank(message = "Full name is required") @Size(max = 120) String fullName,
            @Size(max = 30) String phone,
            @NotNull(message = "Role is required") Role role,
            @Size(max = 80) String designation,
            @NotEmpty(message = "Assign at least one hotel") List<Long> hotelIds,
            Boolean active,
            @Size(max = 30) String employeeCode,
            @Size(max = 60) String department,
            @Size(max = 30) String shiftName,
            LocalTime shiftStart,
            LocalTime shiftEnd,
            LocalDate joinedOn) {
    }

    public record StatusRequest(@NotNull Boolean active) {
    }

    public record PasswordResetByAdminRequest(
            @NotBlank(message = "Password is required")
            @Size(min = 8, max = 72, message = "Password must be between 8 and 72 characters") String newPassword) {
    }

    public record Response(
            Long id,
            String fullName,
            String email,
            String phone,
            Role role,
            String roleLabel,
            String designation,
            boolean active,
            Instant lastLoginAt,
            Instant createdAt,
            List<HotelDtos.Summary> hotels,
            String employeeCode,
            String department,
            String shiftName,
            LocalTime shiftStart,
            LocalTime shiftEnd,
            LocalDate joinedOn) {
    }

    public record AttendanceRequest(
            @NotNull(message = "Hotel is required") Long hotelId,
            @NotNull(message = "Employee is required") Long userId,
            @NotNull(message = "Date is required") LocalDate attendanceDate,
            @NotNull(message = "Status is required") AttendanceStatus status,
            String shiftName,
            String notes) {
    }

    public record AttendanceResponse(
            Long id,
            Long hotelId,
            Long userId,
            String userName,
            String role,
            LocalDate attendanceDate,
            AttendanceStatus status,
            String shiftName,
            Instant checkInTime,
            Instant checkOutTime,
            String notes) {
    }

    public record AttendanceSummary(
            long present,
            long absent,
            long leave,
            long halfDay,
            long weekOff,
            long totalStaff) {
    }
}
