package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.RoomPricing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RoomPricingRepository extends JpaRepository<RoomPricing, Long> {

    @Query("select p from RoomPricing p where p.hotel.id = :hotelId and p.active = true order by p.priority desc")
    List<RoomPricing> findActiveByHotel(@Param("hotelId") Long hotelId);

    Optional<RoomPricing> findByIdAndHotelId(Long id, Long hotelId);

    List<RoomPricing> findByHotelIdOrderByPriorityDesc(Long hotelId);
}
