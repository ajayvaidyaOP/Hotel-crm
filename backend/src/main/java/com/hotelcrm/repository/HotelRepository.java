package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.enums.HotelStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;
import java.util.Optional;

public interface HotelRepository extends JpaRepository<Hotel, Long>, JpaSpecificationExecutor<Hotel> {

    Optional<Hotel> findByCodeIgnoreCase(String code);

    boolean existsByCodeIgnoreCase(String code);

    List<Hotel> findAllByOrderByNameAsc();

    List<Hotel> findByStatusOrderByNameAsc(HotelStatus status);

    long countByStatus(HotelStatus status);
}
