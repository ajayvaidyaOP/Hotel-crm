package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.ServiceOrder;
import com.hotelcrm.domain.enums.ServiceOrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public interface ServiceOrderRepository extends JpaRepository<ServiceOrder, Long> {

    List<ServiceOrder> findByBookingIdOrderByOrderedAtDesc(Long bookingId);

    List<ServiceOrder> findByHotelIdInAndOrderedAtBetweenOrderByOrderedAtDesc(List<Long> hotelIds, Instant from, Instant to);

    @Query("select coalesce(sum(s.amount * s.quantity), 0) from ServiceOrder s where s.hotel.id in :hotelIds " +
            " and s.status <> com.hotelcrm.domain.enums.ServiceOrderStatus.CANCELLED" +
            " and s.orderedAt >= :from and s.orderedAt < :to")
    BigDecimal sumOrderRevenue(@Param("hotelIds") List<Long> hotelIds,
                               @Param("from") Instant from, @Param("to") Instant to);

    long countByHotelIdInAndStatus(List<Long> hotelIds, ServiceOrderStatus status);

    @Query("select s from ServiceOrder s where s.booking.guest.id = :guestId order by s.orderedAt desc")
    List<ServiceOrder> findByGuestIdOrderByOrderedAtDesc(@Param("guestId") Long guestId);
}
