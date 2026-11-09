package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Refund;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public interface RefundRepository extends JpaRepository<Refund, Long>, JpaSpecificationExecutor<Refund> {

    List<Refund> findByBookingIdOrderByProcessedAtDesc(Long bookingId);

    @Query("select coalesce(sum(r.amount), 0) from Refund r where r.hotel.id in :hotelIds " +
            " and r.status = com.hotelcrm.domain.enums.RefundStatus.COMPLETED and r.processedAt >= :from and r.processedAt < :to")
    BigDecimal sumRefunds(@Param("hotelIds") List<Long> hotelIds,
                          @Param("from") Instant from, @Param("to") Instant to);

    @Query("select coalesce(sum(r.amount), 0) from Refund r where r.booking.id = :bookingId " +
            " and r.status = com.hotelcrm.domain.enums.RefundStatus.COMPLETED")
    BigDecimal sumRefundedForBooking(@Param("bookingId") Long bookingId);

    @Query("select r.hotel.id, coalesce(sum(r.amount), 0) from Refund r where r.hotel.id in :hotelIds " +
            " and r.status = com.hotelcrm.domain.enums.RefundStatus.COMPLETED group by r.hotel.id")
    List<Object[]> sumRefundsByHotel(@Param("hotelIds") List<Long> hotelIds);
}
