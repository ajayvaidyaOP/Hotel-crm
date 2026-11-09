package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Long>, JpaSpecificationExecutor<Payment> {

    List<Payment> findByBookingIdOrderByPaidAtDesc(Long bookingId);

    List<Payment> findByInvoiceIdOrderByPaidAtDesc(Long invoiceId);

    @Query("select coalesce(sum(p.amount), 0) from Payment p where p.hotel.id in :hotelIds " +
            " and p.status = com.hotelcrm.domain.enums.PaymentStatus.SUCCESS and p.paidAt >= :from and p.paidAt < :to")
    BigDecimal sumCollected(@Param("hotelIds") List<Long> hotelIds,
                            @Param("from") Instant from, @Param("to") Instant to);

    @Query("select p.hotel.id, coalesce(sum(p.amount), 0) from Payment p where p.hotel.id in :hotelIds " +
            " and p.status = com.hotelcrm.domain.enums.PaymentStatus.SUCCESS and p.paidAt >= :from and p.paidAt < :to " +
            " group by p.hotel.id")
    List<Object[]> sumCollectedByHotel(@Param("hotelIds") List<Long> hotelIds,
                                       @Param("from") Instant from, @Param("to") Instant to);

    List<Payment> findByHotelIdInAndStatusAndPaidAtBetweenOrderByPaidAtAsc(
            List<Long> hotelIds, com.hotelcrm.domain.enums.PaymentStatus status, Instant from, Instant to);

    List<Payment> findByHotelIdInAndPaidAtBetweenOrderByPaidAtDesc(List<Long> hotelIds, Instant from, Instant to);

    @Query("select p from Payment p where p.booking.guest.id = :guestId order by p.paidAt desc")
    List<Payment> findByBookingGuestIdOrderByPaidAtDesc(@Param("guestId") Long guestId);

    @Query("select coalesce(sum(p.amount), 0) from Payment p where p.booking.id = :bookingId " +
            " and p.status = com.hotelcrm.domain.enums.PaymentStatus.SUCCESS")
    BigDecimal sumPaidForBooking(@Param("bookingId") Long bookingId);

    @Query("select coalesce(sum(p.amount), 0) from Payment p where p.invoice.id = :invoiceId " +
            " and p.status = com.hotelcrm.domain.enums.PaymentStatus.SUCCESS")
    BigDecimal sumPaidForInvoice(@Param("invoiceId") Long invoiceId);

    @Query("select p.method, coalesce(sum(p.amount), 0) from Payment p where p.hotel.id in :hotelIds " +
            " and p.status = com.hotelcrm.domain.enums.PaymentStatus.SUCCESS and p.paidAt >= :from and p.paidAt < :to " +
            " group by p.method")
    List<Object[]> sumByMethod(@Param("hotelIds") List<Long> hotelIds,
                               @Param("from") Instant from, @Param("to") Instant to);
}
