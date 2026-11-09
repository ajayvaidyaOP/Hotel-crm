package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.MaintenanceRequest;
import com.hotelcrm.domain.enums.MaintenanceStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public interface MaintenanceRequestRepository extends JpaRepository<MaintenanceRequest, Long>, JpaSpecificationExecutor<MaintenanceRequest> {

    long countByHotelIdInAndStatusIn(List<Long> hotelIds, List<MaintenanceStatus> statuses);

    @Query("select coalesce(sum(m.cost), 0) from MaintenanceRequest m where m.hotel.id in :hotelIds " +
            " and m.reportedAt >= :from and m.reportedAt < :to")
    BigDecimal sumCost(@Param("hotelIds") List<Long> hotelIds,
                       @Param("from") Instant from, @Param("to") Instant to);
}
