package com.hotelcrm.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

public final class AuthDtos {

    private AuthDtos() {
    }

    public record LoginRequest(
            @NotBlank(message = "Email is required") @Email(message = "Enter a valid email") String email,
            @NotBlank(message = "Password is required") String password) {
    }

    public record RefreshRequest(@NotBlank(message = "Refresh token is required") String refreshToken) {
    }

    public record TokenResponse(
            String accessToken,
            String refreshToken,
            String tokenType,
            long expiresIn,
            MeResponse user) {
    }

    public record MeResponse(
            Long id,
            String fullName,
            String email,
            String phone,
            String role,
            String roleLabel,
            String designation,
            List<String> permissions,
            List<HotelDtos.Summary> hotels,
            boolean mustChangePassword) {
    }

    public record ChangePasswordRequest(
            @NotBlank(message = "Current password is required") String currentPassword,
            @NotBlank(message = "New password is required")
            @Size(min = 8, max = 72, message = "Password must be between 8 and 72 characters") String newPassword) {
    }

    public record ForgotPasswordRequest(
            @NotBlank(message = "Email is required") @Email(message = "Enter a valid email") String email) {
    }

    public record ResetPasswordRequest(
            @NotBlank(message = "Token is required") String token,
            @NotBlank(message = "New password is required")
            @Size(min = 8, max = 72, message = "Password must be between 8 and 72 characters") String newPassword) {
    }

    public record ProfileUpdateRequest(
            @NotBlank(message = "Full name is required") @Size(max = 120) String fullName,
            @Size(max = 30) String phone,
            @Size(max = 80) String designation) {
    }

    public record MessageResponse(String message) {
    }
}
