package com.hotelcrm.domain.entity;

import com.hotelcrm.common.BaseEntity;
import com.hotelcrm.domain.enums.BookingPaymentStatus;
import com.hotelcrm.domain.enums.BookingSource;
import com.hotelcrm.domain.enums.BookingStatus;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "bookings")
public class Booking extends BaseEntity {

    @Column(name = "booking_code", nullable = false, length = 24, unique = true)
    private String bookingCode;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "hotel_id", nullable = false)
    private Hotel hotel;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "guest_id", nullable = false)
    private Guest guest;

    @Column(name = "check_in_date", nullable = false)
    private LocalDate checkInDate;

    @Column(name = "check_out_date", nullable = false)
    private LocalDate checkOutDate;

    @Builder.Default
    @Column(nullable = false)
    private Integer adults = 1;

    @Builder.Default
    @Column(nullable = false)
    private Integer children = 0;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "booking_source", nullable = false, length = 20)
    private BookingSource bookingSource = BookingSource.DIRECT;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private BookingStatus status = BookingStatus.PENDING;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false, length = 20)
    private BookingPaymentStatus paymentStatus = BookingPaymentStatus.UNPAID;

    @Builder.Default
    @Column(name = "room_charge_total", nullable = false, precision = 12, scale = 2)
    private BigDecimal roomChargeTotal = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "extra_charges", nullable = false, precision = 12, scale = 2)
    private BigDecimal extraCharges = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "discount_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "tax_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal taxAmount = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "advance_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal advanceAmount = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "paid_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal paidAmount = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "pending_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal pendingAmount = BigDecimal.ZERO;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id")
    private Coupon coupon;

    @Builder.Default
    @Column(nullable = false, length = 3)
    private String currency = "INR";

    @Column(name = "special_requests", length = 1000)
    private String specialRequests;

    @Column(name = "internal_notes", length = 1000)
    private String internalNotes;

    @Column(name = "cancellation_reason", length = 500)
    private String cancellationReason;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "actual_check_in_at")
    private Instant actualCheckInAt;

    @Column(name = "actual_check_out_at")
    private Instant actualCheckOutAt;

    @Column(name = "checked_in_by")
    private Long checkedInBy;

    @Column(name = "checked_out_by")
    private Long checkedOutBy;

    @Column(name = "created_by")
    private Long createdBy;

    @Builder.Default
    @OneToMany(mappedBy = "booking", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<BookingRoom> rooms = new ArrayList<>();

    public void addRoom(BookingRoom bookingRoom) {
        bookingRoom.setBooking(this);
        this.rooms.add(bookingRoom);
    }

    /** Statuses that block inventory for a room. */
    public boolean holdsInventory() {
        return status == BookingStatus.PENDING || status == BookingStatus.CONFIRMED
                || status == BookingStatus.CHECKED_IN;
    }

    public int getNights() {
        if (checkInDate == null || checkOutDate == null) {
            return 0;
        }
        return (int) java.time.temporal.ChronoUnit.DAYS.between(checkInDate, checkOutDate);
    }
}
