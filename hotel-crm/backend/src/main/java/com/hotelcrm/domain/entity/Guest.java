package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import com.hotelcrm.domain.enums.GuestCategory;
import com.hotelcrm.domain.enums.IdProofType;
import com.hotelcrm.util.EncryptedStringConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Central guest CRM record shared across hotels. The id proof number is encrypted at rest
 * (AES-GCM) and only the last four characters are stored / displayed in clear text.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "guests")
public class Guest extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hotel_id")
    private Hotel hotel;

    @Column(name = "full_name", nullable = false, length = 120)
    private String fullName;

    @Column(nullable = false, length = 30)
    private String mobile;

    @Column(length = 160)
    private String email;

    @Column(length = 255)
    private String address;

    @Column(length = 80)
    private String city;

    @Column(length = 80)
    private String state;

    @Column(length = 80)
    private String country;

    @Enumerated(EnumType.STRING)
    @Column(name = "id_proof_type", length = 30)
    private IdProofType idProofType;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "id_proof_number", length = 500)
    private String idProofNumber;

    @Column(name = "id_proof_last4", length = 4)
    private String idProofLast4;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private GuestCategory category = GuestCategory.REGULAR;

    @Builder.Default
    @Column(nullable = false)
    private Boolean vip = Boolean.FALSE;

    @Builder.Default
    @Column(nullable = false)
    private Boolean blacklisted = Boolean.FALSE;

    @Column(length = 1000)
    private String notes;

    @Column(name = "special_requests", length = 1000)
    private String specialRequests;

    @Builder.Default
    @Column(name = "loyalty_points", nullable = false)
    private Integer loyaltyPoints = 0;
}
