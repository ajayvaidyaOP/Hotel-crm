package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.RoomCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoomCategoryRepository extends JpaRepository<RoomCategory, Long> {

    List<RoomCategory> findByHotelIdOrderBySortOrderAsc(Long hotelId);

    List<RoomCategory> findByHotelIdAndActiveTrueOrderBySortOrderAsc(Long hotelId);

    Optional<RoomCategory> findByIdAndHotelId(Long id, Long hotelId);

    boolean existsByHotelIdAndCodeIgnoreCase(Long hotelId, String code);

    long countByHotelId(Long hotelId);
}
