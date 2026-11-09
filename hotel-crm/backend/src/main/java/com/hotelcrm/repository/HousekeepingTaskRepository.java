package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.HousekeepingTask;
import com.hotelcrm.domain.enums.HousekeepingTaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface HousekeepingTaskRepository extends JpaRepository<HousekeepingTask, Long>, JpaSpecificationExecutor<HousekeepingTask> {

    List<HousekeepingTask> findByHotelIdIn(List<Long> hotelIds);

    long countByHotelIdInAndStatus(List<Long> hotelIds, HousekeepingTaskStatus status);

    long countByAssignedToAndStatusNot(Long userId, HousekeepingTaskStatus status);

    @Query("select t from HousekeepingTask t join fetch t.room left join fetch t.hotel where t.assignedTo = :userId " +
            " and t.status in :statuses order by t.priority desc, t.scheduledDate")
    List<HousekeepingTask> findForStaff(@Param("userId") Long userId,
                                        @Param("statuses") List<HousekeepingTaskStatus> statuses);

    @Query("select count(t) from HousekeepingTask t where t.hotel.id in :hotelIds and t.status = :status")
    long countOpen(@Param("hotelIds") List<Long> hotelIds, @Param("status") HousekeepingTaskStatus status);
}
