package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    @Query("select n from Notification n where (n.userId = :userId or n.userId is null) " +
            " and (n.hotel is null or n.hotel.id in :hotelIds) order by n.createdAt desc")
    List<Notification> findForUser(@Param("userId") Long userId,
                                   @Param("hotelIds") List<Long> hotelIds,
                                   org.springframework.data.domain.Pageable pageable);

    @Query("select count(n) from Notification n where (n.userId = :userId or n.userId is null) " +
            " and (n.hotel is null or n.hotel.id in :hotelIds) and n.isRead = false")
    long countUnread(@Param("userId") Long userId, @Param("hotelIds") List<Long> hotelIds);

    @Modifying
    @Query("update Notification n set n.isRead = true, n.readAt = :now where n.id = :id " +
            " and (n.userId = :userId or n.userId is null)")
    int markRead(@Param("id") Long id, @Param("userId") Long userId, @Param("now") Instant now);

    @Modifying
    @Query("update Notification n set n.isRead = true, n.readAt = :now where n.isRead = false " +
            " and (n.userId = :userId or n.userId is null) and (n.hotel is null or n.hotel.id in :hotelIds)")
    int markAllRead(@Param("userId") Long userId, @Param("hotelIds") List<Long> hotelIds, @Param("now") Instant now);
}
