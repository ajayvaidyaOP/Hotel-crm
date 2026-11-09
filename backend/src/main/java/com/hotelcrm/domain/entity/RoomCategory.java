package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import com.hotelcrm.util.StringListConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "room_categories")
public class RoomCategory extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "hotel_id", nullable = false)
    private Hotel hotel;

    @Column(nullable = false, length = 80)
    private String name;

    @Column(nullable = false, length = 20)
    private String code;

    @Column(length = 1000)
    private String description;

    @Column(name = "base_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal basePrice;

    @Column(name = "weekend_price", precision = 12, scale = 2)
    private BigDecimal weekendPrice;

    @Builder.Default
    @Column(name = "extra_person_charge", nullable = false, precision = 12, scale = 2)
    private BigDecimal extraPersonCharge = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "extra_bed_charge", nullable = false, precision = 12, scale = 2)
    private BigDecimal extraBedCharge = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "early_checkin_charge", nullable = false, precision = 12, scale = 2)
    private BigDecimal earlyCheckinCharge = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "late_checkout_charge", nullable = false, precision = 12, scale = 2)
    private BigDecimal lateCheckoutCharge = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "max_occupancy", nullable = false)
    private Integer maxOccupancy = 2;

    @Builder.Default
    @Convert(converter = StringListConverter.class)
    @Column(length = 4000)
    private List<String> amenities = new ArrayList<>();

    @Builder.Default
    @Convert(converter = StringListConverter.class)
    @Column(name = "image_urls", length = 4000)
    private List<String> imageUrls = new ArrayList<>();

    @Builder.Default
    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    @Builder.Default
    @Column(nullable = false)
    private Boolean active = Boolean.TRUE;
}
