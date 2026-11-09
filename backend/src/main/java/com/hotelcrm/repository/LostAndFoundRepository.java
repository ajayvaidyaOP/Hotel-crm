package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.LostAndFound;
import com.hotelcrm.domain.enums.LostFoundStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LostAndFoundRepository extends JpaRepository<LostAndFound, Long> {

    List<LostAndFound> findByHotelIdInOrderByFoundAtDesc(List<Long> hotelIds);

    long countByHotelIdInAndStatus(List<Long> hotelIds, LostFoundStatus status);
}
