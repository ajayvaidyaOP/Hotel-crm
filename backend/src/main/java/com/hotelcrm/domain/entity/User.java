package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import com.hotelcrm.domain.enums.Role;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "users")
public class User extends BaseEntity {

    @Column(name = "full_name", nullable = false, length = 120)
    private String fullName;

    @Column(nullable = false, length = 160, unique = true)
    private String email;

    @Column(length = 30)
    private String phone;

    @Column(name = "password_hash", nullable = false, length = 100)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "primary_role", nullable = false, length = 40)
    private Role primaryRole;

    @Column(nullable = false)
    private Boolean enabled;

    @Column(name = "must_change_password", nullable = false)
    private Boolean mustChangePassword;

    @Column(name = "token_version", nullable = false)
    private Integer tokenVersion;

    @Column(name = "last_login_at")
    private Instant lastLoginAt;

    @Column(length = 80)
    private String designation;

    public boolean isActive() {
        return Boolean.TRUE.equals(enabled);
    }
}
