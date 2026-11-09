package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** Append only audit trail for security relevant and financial operations. */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "audit_logs")
public class AuditLog extends BaseEntity {

    @Column(name = "hotel_id")
    private Long hotelId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "actor_email", length = 160)
    private String actorEmail;

    @Column(nullable = false, length = 60)
    private String action;

    @Column(name = "entity_type", length = 60)
    private String entityType;

    @Column(name = "entity_id")
    private Long entityId;

    @Column(length = 1000)
    private String description;

    @Column(name = "ip_address", length = 60)
    private String ipAddress;
}
