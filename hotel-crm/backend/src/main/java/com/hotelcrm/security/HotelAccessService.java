package com.hotelcrm.security;

import com.hotelcrm.common.exception.ForbiddenException;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.repository.HotelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Server side authorization for tenant (hotel) isolation.
 * Never trust a hotel id, role or permission sent by the browser: every service call funnels
 * through these helpers before touching hotel scoped data.
 */
@Service
@RequiredArgsConstructor
public class HotelAccessService {

    private final HotelRepository hotelRepository;

    public Optional<AppUserPrincipal> principalOptional() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof AppUserPrincipal principal) {
            return Optional.of(principal);
        }
        return Optional.empty();
    }

    public AppUserPrincipal currentUser() {
        return principalOptional().orElseThrow(() -> new ForbiddenException("Authentication required"));
    }

    public Long currentUserId() {
        return currentUser().getId();
    }

    public boolean isSuperAdmin() {
        return principalOptional().map(AppUserPrincipal::isSuperAdmin).orElse(false);
    }

    /** All hotels the caller may read, optionally narrowed to a single requested hotel. */
    @Transactional(readOnly = true)
    public List<Long> resolveHotelScope(Long requestedHotelId) {
        AppUserPrincipal principal = currentUser();
        if (requestedHotelId != null) {
            assertHotelAccess(requestedHotelId);
            return List.of(requestedHotelId);
        }
        if (principal.isSuperAdmin()) {
            List<Long> all = hotelRepository.findAll().stream().map(h -> h.getId()).toList();
            return all.isEmpty() ? List.of(-1L) : new ArrayList<>(all);
        }
        List<Long> assigned = new ArrayList<>(principal.getHotelIds());
        return assigned.isEmpty() ? List.of(-1L) : assigned;
    }

    @Transactional(readOnly = true)
    public List<Long> accessibleHotelIds() {
        return resolveHotelScope(null);
    }

    public boolean canAccessHotel(Long hotelId) {
        if (hotelId == null) {
            return false;
        }
        Optional<AppUserPrincipal> maybe = principalOptional();
        if (maybe.isEmpty()) {
            return false;
        }
        AppUserPrincipal principal = maybe.get();
        return principal.isSuperAdmin() || principal.getHotelIds().contains(hotelId);
    }

    public void assertHotelAccess(Long hotelId) {
        AppUserPrincipal principal = currentUser();
        if (principal.isSuperAdmin()) {
            return;
        }
        if (hotelId == null || !principal.getHotelIds().contains(hotelId)) {
            throw new ForbiddenException("You do not have access to this hotel");
        }
    }

    public void assertPermission(Permission permission) {
        AppUserPrincipal principal = currentUser();
        if (!principal.getRole().has(permission)) {
            throw new ForbiddenException("Your role does not allow this action: " + permission.getCode());
        }
    }

    public void assertSuperAdmin() {
        if (!currentUser().isSuperAdmin()) {
            throw new ForbiddenException("Only the owner can perform this action");
        }
    }

    public void assertHotelWrite() {
        assertPermission(Permission.HOTEL_WRITE);
    }

    /** Validates that the given hotel id belongs to the caller and returns it. */
    @Transactional(readOnly = true)
    public Long requireHotel(Long hotelId) {
        if (hotelId == null) {
            throw new ForbiddenException("A hotel must be selected for this operation");
        }
        assertHotelAccess(hotelId);
        return hotelId;
    }
}
