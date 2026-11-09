package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.BookingRoom;
import com.hotelcrm.domain.enums.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface BookingRoomRepository extends JpaRepository<BookingRoom, Long> {

    /**
     * Core double-booking guard: counts room segments that overlap the requested date range
     * while their booking still holds inventory.
     */
    @Query("select count(br) from BookingRoom br where br.room.id = :roomId " +
            " and br.booking.id <> :excludeBookingId " +
            " and br.booking.status in :statuses " +
            " and br.checkInDate < :checkOut and br.checkOutDate > :checkIn")
    long countOverlapping(@Param("roomId") Long roomId,
                          @Param("checkIn") LocalDate checkIn,
                          @Param("checkOut") LocalDate checkOut,
                          @Param("statuses") List<BookingStatus> statuses,
                          @Param("excludeBookingId") Long excludeBookingId);

    List<BookingRoom> findByBookingId(Long bookingId);

    boolean existsByRoom_Id(Long roomId);

    long countByRoom_Id(Long roomId);

    long countByRoomCategoryId(Long categoryId);

    @Query("select br from BookingRoom br join fetch br.booking b join fetch b.guest join fetch br.room " +
            "where b.hotel.id in :hotelIds and br.checkInDate < :to and br.checkOutDate > :from " +
            "and b.status in :statuses order by br.room.roomNumber, br.checkInDate")
    List<BookingRoom> findForCalendar(@Param("hotelIds") List<Long> hotelIds,
                                      @Param("from") LocalDate from,
                                      @Param("to") LocalDate to,
                                      @Param("statuses") List<BookingStatus> statuses);

    @Query("select br from BookingRoom br join fetch br.booking b join fetch b.guest join fetch br.room " +
            "where b.hotel.id in :hotelIds and b.status = com.hotelcrm.domain.enums.BookingStatus.CHECKED_IN")
    List<BookingRoom> findInHouseSegments(@Param("hotelIds") List<Long> hotelIds);

    @Query("select br from BookingRoom br join fetch br.booking b join fetch b.guest where br.room.id = :roomId " +
            " and b.status in :statuses order by br.checkInDate desc")
    List<BookingRoom> findHistoryForRoom(@Param("roomId") Long roomId, @Param("statuses") List<BookingStatus> statuses);
}
