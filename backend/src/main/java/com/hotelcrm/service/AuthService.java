package com.hotelcrm.service;

import com.hotelcrm.common.exception.BusinessException;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.PasswordResetToken;
import com.hotelcrm.domain.entity.User;
import com.hotelcrm.dto.AuthDtos;
import com.hotelcrm.dto.HotelDtos;
import com.hotelcrm.repository.HotelStaffRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.PasswordResetTokenRepository;
import com.hotelcrm.repository.UserRepository;
import com.hotelcrm.security.AppUserPrincipal;
import com.hotelcrm.security.CustomUserDetailsService;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.security.JwtService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;
    private final HotelStaffRepository hotelStaffRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;
    private final HotelAccessService accessService;
    private final AuditService auditService;

    @Transactional
    public AuthDtos.TokenResponse login(AuthDtos.LoginRequest request) {
        Authentication authentication;
        try {
            authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.email().trim(), request.password()));
        } catch (DisabledException ex) {
            throw new BusinessException("This account has been deactivated. Contact your administrator.");
        } catch (org.springframework.security.core.AuthenticationException ex) {
            throw new BadCredentialsException("Invalid email or password");
        }
        AppUserPrincipal principal = (AppUserPrincipal) authentication.getPrincipal();
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> NotFoundException.of("User", principal.getId()));
        user.setLastLoginAt(Instant.now());
        userRepository.save(user);

        auditService.record(principal.getHotelIds().stream().findFirst().orElse(null), "LOGIN", "User",
                principal.getId(), "Signed in");
        return tokenResponse(principal);
    }

    @Transactional(readOnly = true)
    public AuthDtos.TokenResponse refresh(AuthDtos.RefreshRequest request) {
        Claims claims;
        try {
            claims = jwtService.parseRefreshToken(request.refreshToken());
        } catch (JwtException | IllegalArgumentException ex) {
            throw new BadCredentialsException("Invalid or expired refresh token");
        }
        AppUserPrincipal principal = (AppUserPrincipal) userDetailsService.loadUserByUsername(claims.getSubject());
        Integer tokenVersion = claims.get("tv", Integer.class);
        if (tokenVersion == null || tokenVersion != principal.getTokenVersion()) {
            throw new BadCredentialsException("Session is no longer valid. Please sign in again.");
        }
        if (!principal.isEnabled()) {
            throw new BusinessException("This account has been deactivated.");
        }
        return tokenResponse(principal);
    }

    @Transactional(readOnly = true)
    public AuthDtos.MeResponse me() {
        AppUserPrincipal principal = accessService.currentUser();
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> NotFoundException.of("User", principal.getId()));
        List<HotelDtos.Summary> hotels;
        if (principal.isSuperAdmin()) {
            hotels = hotelRepository.findAllByOrderByNameAsc().stream().map(HotelDtos.Summary::from).toList();
        } else {
            hotels = hotelStaffRepository.findByUserId(user.getId()).stream()
                    .filter(assignment -> Boolean.TRUE.equals(assignment.getActive()))
                    .map(assignment -> HotelDtos.Summary.from(assignment.getHotel()))
                    .toList();
        }
        return new AuthDtos.MeResponse(user.getId(), user.getFullName(), user.getEmail(), user.getPhone(),
                principal.getRole().name(), principal.getRole().getLabel(), user.getDesignation(),
                List.copyOf(principal.getRole().getPermissionCodes()), hotels,
                Boolean.TRUE.equals(user.getMustChangePassword()));
    }

    @Transactional
    public AuthDtos.MessageResponse changePassword(AuthDtos.ChangePasswordRequest request) {
        AppUserPrincipal principal = accessService.currentUser();
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> NotFoundException.of("User", principal.getId()));
        if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw new BusinessException("Current password is incorrect");
        }
        if (passwordEncoder.matches(request.newPassword(), user.getPasswordHash())) {
            throw new BusinessException("New password must be different from the current password");
        }
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        user.setMustChangePassword(Boolean.FALSE);
        user.setTokenVersion(user.getTokenVersion() + 1);
        userRepository.save(user);
        auditService.record(null, "PASSWORD_CHANGED", "User", user.getId(), "Password changed by the user");
        return new AuthDtos.MessageResponse("Password updated successfully. Please sign in again.");
    }

    @Transactional
    public AuthDtos.MessageResponse forgotPassword(AuthDtos.ForgotPasswordRequest request) {
        userRepository.findByEmailIgnoreCase(request.email().trim()).ifPresent(user -> {
            String rawToken = com.hotelcrm.util.CodeGenerator.temporaryToken();
            passwordResetTokenRepository.save(PasswordResetToken.builder()
                    .userId(user.getId())
                    .tokenHash(hash(rawToken))
                    .expiresAt(Instant.now().plus(60, ChronoUnit.MINUTES))
                    .build());
            // Phase 2: hand this token to the email / WhatsApp provider instead of logging it.
            log.info("Password reset requested for {}. Reset token (valid 60 min): {}", user.getEmail(), rawToken);
            auditService.record(null, "PASSWORD_RESET_REQUESTED", "User", user.getId(),
                    "Password reset token issued");
        });
        return new AuthDtos.MessageResponse(
                "If an account exists for that email, a password reset link has been sent.");
    }

    @Transactional
    public AuthDtos.MessageResponse resetPassword(AuthDtos.ResetPasswordRequest request) {
        PasswordResetToken token = passwordResetTokenRepository.findByTokenHash(hash(request.token()))
                .orElseThrow(() -> new BusinessException("This reset link is invalid or has expired"));
        if (!token.isUsable()) {
            throw new BusinessException("This reset link is invalid or has expired");
        }
        User user = userRepository.findById(token.getUserId())
                .orElseThrow(() -> NotFoundException.of("User", token.getUserId()));
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        user.setTokenVersion(user.getTokenVersion() + 1);
        user.setMustChangePassword(Boolean.FALSE);
        userRepository.save(user);

        token.setUsedAt(Instant.now());
        passwordResetTokenRepository.save(token);
        auditService.record(null, "PASSWORD_RESET", "User", user.getId(), "Password reset with a one time token");
        return new AuthDtos.MessageResponse("Password has been reset. You can now sign in.");
    }

    @Transactional
    public AuthDtos.MeResponse updateProfile(AuthDtos.ProfileUpdateRequest request) {
        AppUserPrincipal principal = accessService.currentUser();
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> NotFoundException.of("User", principal.getId()));
        user.setFullName(request.fullName());
        user.setPhone(request.phone());
        user.setDesignation(request.designation());
        userRepository.save(user);
        auditService.record(null, "PROFILE_UPDATED", "User", user.getId(), "Profile details updated");
        return me();
    }

    @Transactional
    public AuthDtos.MessageResponse logout() {
        AppUserPrincipal principal = accessService.principalOptional().orElse(null);
        if (principal != null) {
            userRepository.findById(principal.getId()).ifPresent(user -> {
                user.setTokenVersion(user.getTokenVersion() + 1);
                userRepository.save(user);
            });
            auditService.record(null, "LOGOUT", "User", principal.getId(), "Signed out");
        }
        return new AuthDtos.MessageResponse("Signed out");
    }

    private AuthDtos.TokenResponse tokenResponse(AppUserPrincipal principal) {
        String accessToken = jwtService.generateAccessToken(principal);
        String refreshToken = jwtService.generateRefreshToken(principal);
        return new AuthDtos.TokenResponse(accessToken, refreshToken, "Bearer",
                jwtService.accessTokenTtlSeconds(), buildMe(principal));
    }

    private AuthDtos.MeResponse buildMe(AppUserPrincipal principal) {
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> NotFoundException.of("User", principal.getId()));
        List<HotelDtos.Summary> hotels;
        if (principal.isSuperAdmin()) {
            hotels = hotelRepository.findAllByOrderByNameAsc().stream().map(HotelDtos.Summary::from).toList();
        } else {
            hotels = hotelStaffRepository.findByUserId(user.getId()).stream()
                    .filter(a -> Boolean.TRUE.equals(a.getActive()))
                    .map(a -> HotelDtos.Summary.from(a.getHotel()))
                    .toList();
        }
        return new AuthDtos.MeResponse(user.getId(), user.getFullName(), user.getEmail(), user.getPhone(),
                principal.getRole().name(), principal.getRole().getLabel(), user.getDesignation(),
                List.copyOf(principal.getRole().getPermissionCodes()), hotels,
                Boolean.TRUE.equals(user.getMustChangePassword()));
    }

    private String hash(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashed = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hashed);
        } catch (Exception ex) {
            throw new IllegalStateException("Unable to hash reset token", ex);
        }
    }
}
