package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.HotelStaff;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface HotelStaffRepository extends JpaRepository<HotelStaff, Long> {

    List<HotelStaff> findByUserId(Long userId);

    List<HotelStaff> findByHotelId(Long hotelId);

    Optional<HotelStaff> findByHotelIdAndUserId(Long hotelId, Long userId);

    boolean existsByHotelIdAndUserId(Long hotelId, Long userId);

    long countByHotelIdAndActiveTrue(Long hotelId);

    @Query("select hs.user.id from HotelStaff hs where hs.user.id = :userId and hs.active = true")
    List<Long> findAssignedUserIds(@Param("userId") Long userId);

    @Query("select hs.hotel.id from HotelStaff hs where hs.user.id = :userId and hs.active = true")
    List<Long> findActiveHotelIdsForUser(@Param("userId") Long userId);

    @Query("select hs from HotelStaff hs join fetch hs.user join fetch hs.hotel where hs.hotel.id in :hotelIds and hs.active = true")
    List<HotelStaff> findActiveByHotelIds(@Param("hotelIds") List<Long> hotelIds);

    @Modifying
    @Query("delete from HotelStaff hs where hs.user.id = :userId")
    void deleteByUserId(@Param("userId") Long userId);
}
