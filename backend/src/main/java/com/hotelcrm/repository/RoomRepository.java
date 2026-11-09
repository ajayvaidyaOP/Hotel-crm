package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.RoomStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Long>, JpaSpecificationExecutor<Room> {

    /**
     * Row level pessimistic lock used to serialise concurrent bookings for the same physical room.
     * Combined with the overlap check inside the same transaction this makes double booking impossible.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select r from Room r where r.id = :id")
    Optional<Room> findByIdForUpdate(@Param("id") Long id);

    @Query("select r from Room r join fetch r.category where r.hotel.id = :hotelId order by r.roomNumber")
    List<Room> findAllByHotelId(@Param("hotelId") Long hotelId);

    List<Room> findByHotelIdAndStatus(Long hotelId, RoomStatus status);

    Optional<Room> findByIdAndHotelId(Long id, Long hotelId);

    Optional<Room> findByHotelIdAndRoomNumberIgnoreCase(Long hotelId, String roomNumber);

    boolean existsByHotelIdAndRoomNumberIgnoreCase(Long hotelId, String roomNumber);

    long countByHotelIdAndActiveTrue(Long hotelId);

    long countByHotelIdInAndStatus(List<Long> hotelIds, RoomStatus status);

    long countByHotelIdInAndHousekeepingStatus(List<Long> hotelIds, HousekeepingCondition condition);

    @Query("select count(r) from Room r where r.hotel.id in :hotelIds and r.active = true")
    long countActiveByHotels(@Param("hotelIds") List<Long> hotelIds);

    @Query("select r from Room r join fetch r.category c where r.hotel.id in :hotelIds and r.active = true order by r.hotel.id, r.roomNumber")
    List<Room> findActiveByHotels(@Param("hotelIds") List<Long> hotelIds);
}
