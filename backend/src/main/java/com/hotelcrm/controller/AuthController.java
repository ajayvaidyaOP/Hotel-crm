package com.hotelcrm.controller;

import com.hotelcrm.dto.AuthDtos;
import com.hotelcrm.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Authentication")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "Sign in and obtain access + refresh tokens")
    @PostMapping("/login")
    public AuthDtos.TokenResponse login(@Valid @RequestBody AuthDtos.LoginRequest request) {
        return authService.login(request);
    }

    @Operation(summary = "Exchange a refresh token for a new access token")
    @PostMapping("/refresh")
    public AuthDtos.TokenResponse refresh(@Valid @RequestBody AuthDtos.RefreshRequest request) {
        return authService.refresh(request);
    }

    @Operation(summary = "Current user profile, role, permissions and hotels")
    @GetMapping("/me")
    public AuthDtos.MeResponse me() {
        return authService.me();
    }

    @Operation(summary = "Update the signed-in user's profile")
    @PutMapping("/me")
    public AuthDtos.MeResponse updateProfile(@Valid @RequestBody AuthDtos.ProfileUpdateRequest request) {
        return authService.updateProfile(request);
    }

    @Operation(summary = "Change password (invalidates existing sessions)")
    @PostMapping("/change-password")
    public AuthDtos.MessageResponse changePassword(@Valid @RequestBody AuthDtos.ChangePasswordRequest request) {
        return authService.changePassword(request);
    }

    @Operation(summary = "Request a password reset token")
    @PostMapping("/forgot-password")
    public AuthDtos.MessageResponse forgotPassword(@Valid @RequestBody AuthDtos.ForgotPasswordRequest request) {
        return authService.forgotPassword(request);
    }

    @Operation(summary = "Reset password with a one time token")
    @PostMapping("/reset-password")
    public AuthDtos.MessageResponse resetPassword(@Valid @RequestBody AuthDtos.ResetPasswordRequest request) {
        return authService.resetPassword(request);
    }

    @Operation(summary = "Sign out (revokes refresh tokens)")
    @PostMapping("/logout")
    public ResponseEntity<AuthDtos.MessageResponse> logout() {
        return ResponseEntity.ok(authService.logout());
    }
}
