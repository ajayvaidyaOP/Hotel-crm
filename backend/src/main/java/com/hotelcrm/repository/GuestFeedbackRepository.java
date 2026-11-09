package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.GuestFeedback;
import com.hotelcrm.domain.enums.FeedbackStatus;
import com.hotelcrm.domain.enums.FeedbackType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GuestFeedbackRepository extends JpaRepository<GuestFeedback, Long> {

    List<GuestFeedback> findByHotelIdInOrderByCreatedAtDesc(List<Long> hotelIds);

    List<GuestFeedback> findByHotelIdInAndTypeOrderByCreatedAtDesc(List<Long> hotelIds, FeedbackType type);

    long countByHotelIdInAndStatus(List<Long> hotelIds, FeedbackStatus status);

    List<GuestFeedback> findByGuestIdOrderByCreatedAtDesc(Long guestId);
}
