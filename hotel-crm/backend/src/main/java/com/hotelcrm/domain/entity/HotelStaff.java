package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import jakarta.persistence.Column;
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

import java.time.LocalDate;
import java.time.LocalTime;

/** Assignment of a user account to a hotel (a user may serve more than one property). */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "hotel_staff")
public class HotelStaff extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "hotel_id", nullable = false)
    private Hotel hotel;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(length = 80)
    private String designation;

    @Column(name = "employee_code", length = 30)
    private String employeeCode;

    @Column(length = 60)
    private String department;

    @Column(name = "shift_name", length = 30)
    private String shiftName;

    @Column(name = "shift_start")
    private LocalTime shiftStart;

    @Column(name = "shift_end")
    private LocalTime shiftEnd;

    @Column(name = "joined_on")
    private LocalDate joinedOn;

    @Builder.Default
    @Column(nullable = false)
    private Boolean active = Boolean.TRUE;
}
