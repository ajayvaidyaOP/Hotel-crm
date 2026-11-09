package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import com.hotelcrm.domain.enums.BedType;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.domain.enums.RoomType;
import com.hotelcrm.util.StringListConverter;
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

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "rooms")
public class Room extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "hotel_id", nullable = false)
    private Hotel hotel;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "room_category_id", nullable = false)
    private RoomCategory category;

    @Column(name = "room_number", nullable = false, length = 20)
    private String roomNumber;

    @Builder.Default
    @Column(nullable = false)
    private Integer floor = 0;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "room_type", nullable = false, length = 20)
    private RoomType roomType = RoomType.DOUBLE;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "bed_type", nullable = false, length = 20)
    private BedType bedType = BedType.DOUBLE;

    @Builder.Default
    @Column(name = "max_occupancy", nullable = false)
    private Integer maxOccupancy = 2;

    @Builder.Default
    @Column(name = "is_ac", nullable = false)
    private Boolean ac = Boolean.TRUE;

    @Column(length = 1000)
    private String description;

    @Builder.Default
    @Convert(converter = StringListConverter.class)
    @Column(name = "image_urls", length = 4000)
    private List<String> imageUrls = new ArrayList<>();

    @Builder.Default
    @Convert(converter = StringListConverter.class)
    @Column(length = 4000)
    private List<String> amenities = new ArrayList<>();

    @Column(name = "base_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal basePrice;

    @Column(name = "weekend_price", precision = 12, scale = 2)
    private BigDecimal weekendPrice;

    @Builder.Default
    @Column(name = "extra_person_charge", nullable = false, precision = 12, scale = 2)
    private BigDecimal extraPersonCharge = BigDecimal.ZERO;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RoomStatus status = RoomStatus.AVAILABLE;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "housekeeping_status", nullable = false, length = 20)
    private HousekeepingCondition housekeepingStatus = HousekeepingCondition.CLEAN;

    @Builder.Default
    @Column(nullable = false)
    private Boolean active = Boolean.TRUE;
}
