package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.enums.BookingPaymentStatus;
import com.hotelcrm.domain.enums.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface BookingRepository extends JpaRepository<Booking, Long>, JpaSpecificationExecutor<Booking> {

    Optional<Booking> findByBookingCodeIgnoreCase(String bookingCode);

    @Query("select distinct b from Booking b join fetch b.guest left join fetch b.rooms r left join fetch r.room where b.id = :id")
    Optional<Booking> findDetailedById(@Param("id") Long id);

    long countByHotelIdInAndCheckInDate(List<Long> hotelIds, LocalDate date);

    long countByHotelIdInAndCheckOutDate(List<Long> hotelIds, LocalDate date);

    long countByHotelIdInAndCreatedAtBetween(List<Long> hotelIds, java.time.Instant from, java.time.Instant to);

    long countByHotelIdInAndStatus(List<Long> hotelIds, BookingStatus status);

    long countByHotelIdIn(List<Long> hotelIds);

    @Query("select count(b) from Booking b where b.hotel.id in :hotelIds and b.status = :status and b.checkOutDate = :date")
    long countDepartures(@Param("hotelIds") List<Long> hotelIds, @Param("status") BookingStatus status,
                         @Param("date") LocalDate date);

    @Query("select coalesce(sum(b.totalAmount), 0) from Booking b where b.hotel.id in :hotelIds " +
            " and b.status <> com.hotelcrm.domain.enums.BookingStatus.CANCELLED" +
            " and b.checkInDate < :to and b.checkOutDate > :from")
    BigDecimal sumRevenueForStayOverlap(@Param("hotelIds") List<Long> hotelIds,
                                        @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("select coalesce(sum(b.pendingAmount), 0) from Booking b where b.hotel.id in :hotelIds " +
            " and b.status not in (com.hotelcrm.domain.enums.BookingStatus.CANCELLED, com.hotelcrm.domain.enums.BookingStatus.NO_SHOW)")
    BigDecimal sumPendingPayments(@Param("hotelIds") List<Long> hotelIds);

    @Query("select coalesce(sum(b.totalAmount), 0) from Booking b where b.hotel.id in :hotelIds " +
            " and b.status <> com.hotelcrm.domain.enums.BookingStatus.CANCELLED" +
            " and b.checkInDate between :from and :to")
    BigDecimal sumBookedRevenueByCheckIn(@Param("hotelIds") List<Long> hotelIds,
                                         @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("select b from Booking b join fetch b.guest where b.hotel.id in :hotelIds and b.checkInDate = :date " +
            " and b.status in (com.hotelcrm.domain.enums.BookingStatus.PENDING, com.hotelcrm.domain.enums.BookingStatus.CONFIRMED) order by b.id")
    List<Booking> findUpcomingCheckIns(@Param("hotelIds") List<Long> hotelIds, @Param("date") LocalDate date);

    @Query("select b from Booking b join fetch b.guest where b.hotel.id in :hotelIds and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN order by b.checkOutDate")
    List<Booking> findInHouse(@Param("hotelIds") List<Long> hotelIds);

    @Query("select b.status, count(b) from Booking b where b.hotel.id in :hotelIds group by b.status")
    List<Object[]> countByStatusGrouped(@Param("hotelIds") List<Long> hotelIds);

    @Query("select count(b) from Booking b where b.hotel.id in :hotelIds and b.paymentStatus in :statuses " +
            " and b.status not in (com.hotelcrm.domain.enums.BookingStatus.CANCELLED, com.hotelcrm.domain.enums.BookingStatus.NO_SHOW)")
    long countByPaymentStatusIn(@Param("hotelIds") List<Long> hotelIds,
                               @Param("statuses") List<BookingPaymentStatus> statuses);

    long countByHotelId(Long hotelId);

    boolean existsByBookingCodeIgnoreCase(String bookingCode);

    List<Booking> findByGuestIdOrderByCheckInDateDesc(Long guestId);

    long countByGuestId(Long guestId);

    long countByGuestIdAndStatus(Long guestId, BookingStatus status);

    @Query("select distinct b.guest.id from Booking b where b.hotel.id in :hotelIds")
    List<Long> findGuestIdsForHotels(@Param("hotelIds") List<Long> hotelIds);

    @Query("select coalesce(sum(b.paidAmount), 0) from Booking b where b.guest.id = :guestId")
    BigDecimal sumPaidByGuest(@Param("guestId") Long guestId);

    @Query("select coalesce(sum(b.pendingAmount), 0) from Booking b where b.guest.id = :guestId " +
            " and b.status not in (com.hotelcrm.domain.enums.BookingStatus.CANCELLED, com.hotelcrm.domain.enums.BookingStatus.NO_SHOW)")
    BigDecimal sumPendingByGuest(@Param("guestId") Long guestId);

    @Query("select max(b.checkOutDate) from Booking b where b.guest.id = :guestId " +
            " and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_OUT")
    LocalDate findLastStayDate(@Param("guestId") Long guestId);

    @Query("select b from Booking b join fetch b.guest where b.hotel.id in :hotelIds and b.checkOutDate = :date " +
            " and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN order by b.id")
    List<Booking> findDeparturesOn(@Param("hotelIds") List<Long> hotelIds, @Param("date") LocalDate date);

    @Query("select b from Booking b join fetch b.guest where b.hotel.id in :hotelIds and b.checkInDate = :date " +
            " and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN order by b.id")
    List<Booking> findArrivalsCheckedInOn(@Param("hotelIds") List<Long> hotelIds, @Param("date") LocalDate date);

    @Query("select b from Booking b join fetch b.guest where b.hotel.id in :hotelIds " +
            " and b.status = com.hotelcrm.domain.enums.BookingStatus.CANCELLED order by b.cancelledAt desc")
    List<Booking> findCancelled(@Param("hotelIds") List<Long> hotelIds);

    @Query("select b from Booking b join fetch b.guest where b.hotel.id in :hotelIds " +
            " and b.pendingAmount > 0 and b.status in (com.hotelcrm.domain.enums.BookingStatus.PENDING, com.hotelcrm.domain.enums.BookingStatus.CONFIRMED, com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN, com.hotelcrm.domain.enums.BookingStatus.CHECKED_OUT) " +
            " order by b.checkInDate")
    List<Booking> findWithPendingPayments(@Param("hotelIds") List<Long> hotelIds);

    @Query("select b.bookingSource, count(b), coalesce(sum(b.totalAmount), 0) from Booking b " +
            " where b.hotel.id in :hotelIds and b.createdAt >= :from and b.createdAt < :to group by b.bookingSource")
    List<Object[]> sourceBreakdown(@Param("hotelIds") List<Long> hotelIds,
                                   @Param("from") java.time.Instant from, @Param("to") java.time.Instant to);

    @Query("select coalesce(avg(b.totalAmount), 0) from Booking b where b.hotel.id in :hotelIds " +
            " and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_OUT " +
            " and b.checkOutDate between :from and :to")
    BigDecimal averageBookingValue(@Param("hotelIds") List<Long> hotelIds,
                                   @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query(value = "SELECT COALESCE(AVG(DATEDIFF(check_out_date, check_in_date)), 0.0) " +
            "FROM bookings WHERE hotel_id IN (:hotelIds) " +
            "AND status = 'CHECKED_OUT' AND check_out_date BETWEEN :from AND :to",
            nativeQuery = true)
    Double averageLengthOfStay(@Param("hotelIds") List<Long> hotelIds,
                               @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("select count(b) from Booking b where b.hotel.id in :hotelIds and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN")
    long countInHouse(@Param("hotelIds") List<Long> hotelIds);

    @Query("select coalesce(sum(b.adults + b.children), 0) from Booking b where b.hotel.id in :hotelIds " +
            " and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN")
    Long sumInHouseGuests(@Param("hotelIds") List<Long> hotelIds);
}
