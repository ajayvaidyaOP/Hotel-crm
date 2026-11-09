package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import com.hotelcrm.domain.enums.HotelStatus;
import com.hotelcrm.util.StringListConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "hotels")
public class Hotel extends BaseEntity {

    @Column(nullable = false, length = 160)
    private String name;

    @Column(nullable = false, length = 20, unique = true)
    private String code;

    @Column(length = 255)
    private String address;

    @Column(length = 80)
    private String city;

    @Column(length = 80)
    private String state;

    @Builder.Default
    @Column(nullable = false, length = 80)
    private String country = "India";

    @Column(name = "postal_code", length = 20)
    private String postalCode;

    @Column(name = "contact_number", length = 30)
    private String contactNumber;

    @Column(length = 160)
    private String email;

    @Column(length = 2000)
    private String description;

    @Builder.Default
    @Convert(converter = StringListConverter.class)
    @Column(name = "image_urls", length = 4000)
    private List<String> imageUrls = new ArrayList<>();

    @Builder.Default
    @Convert(converter = StringListConverter.class)
    @Column(length = 4000)
    private List<String> facilities = new ArrayList<>();

    @Column(name = "check_in_time", nullable = false)
    private LocalTime checkInTime;

    @Column(name = "check_out_time", nullable = false)
    private LocalTime checkOutTime;

    @Builder.Default
    @Column(nullable = false, length = 60)
    private String timezone = "Asia/Kolkata";

    @Column(name = "star_rating")
    private Integer starRating;

    @Column(name = "gst_number", length = 30)
    private String gstNumber;

    @Builder.Default
    @Column(name = "tax_rate", nullable = false, precision = 5, scale = 2)
    private BigDecimal taxRate = new BigDecimal("12.00");

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private HotelStatus status = HotelStatus.ACTIVE;

    public boolean isActive() {
        return status == HotelStatus.ACTIVE;
    }
}
