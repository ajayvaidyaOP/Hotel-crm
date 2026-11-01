package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    Page<AuditLog> findByHotelIdInOrderByCreatedAtDesc(List<Long> hotelIds, Pageable pageable);

    @Query(value = "select a from AuditLog a where a.hotelId in :hotelIds and (:action is null or a.action = :action) order by a.createdAt desc",
            countQuery = "select count(a) from AuditLog a where a.hotelId in :hotelIds and (:action is null or a.action = :action)")
    Page<AuditLog> search(@Param("hotelIds") List<Long> hotelIds, @Param("action") String action, Pageable pageable);

    List<AuditLog> findTop15ByHotelIdInOrderByCreatedAtDesc(List<Long> hotelIds);

    List<AuditLog> findTop10ByHotelIdOrderByCreatedAtDesc(Long hotelId);

    Page<AuditLog> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
}
