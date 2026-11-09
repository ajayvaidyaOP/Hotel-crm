package com.hotelcrm.security;

import com.hotelcrm.domain.entity.User;
import com.hotelcrm.domain.enums.Role;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Authenticated principal. Hotel ids are loaded from hotel_staff (never from the client) and are the
 * only source of truth for hotel level data isolation.
 */
public class AppUserPrincipal implements UserDetails {

    private final Long id;
    private final String email;
    private final String password;
    private final String fullName;
    private final Role role;
    private final boolean enabled;
    private final int tokenVersion;
    private final Set<Long> hotelIds;

    public AppUserPrincipal(User user, Collection<Long> hotelIds) {
        this.id = user.getId();
        this.email = user.getEmail();
        this.password = user.getPasswordHash();
        this.fullName = user.getFullName();
        this.role = user.getPrimaryRole();
        this.enabled = user.isActive();
        this.tokenVersion = user.getTokenVersion() == null ? 0 : user.getTokenVersion();
        this.hotelIds = new LinkedHashSet<>(hotelIds);
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getFullName() {
        return fullName;
    }

    public Role getRole() {
        return role;
    }

    public Set<Long> getHotelIds() {
        return Set.copyOf(hotelIds);
    }

    public int getTokenVersion() {
        return tokenVersion;
    }

    public boolean isSuperAdmin() {
        return role == Role.SUPER_ADMIN;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        List<GrantedAuthority> authorities = new java.util.ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_" + role.name()));
        role.getPermissionCodes().forEach(code -> authorities.add(new SimpleGrantedAuthority(code)));
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
