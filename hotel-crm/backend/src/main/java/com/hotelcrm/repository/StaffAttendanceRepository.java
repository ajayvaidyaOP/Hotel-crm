package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.StaffAttendance;
import com.hotelcrm.domain.enums.AttendanceStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface StaffAttendanceRepository extends JpaRepository<StaffAttendance, Long> {

    List<StaffAttendance> findByHotelIdAndAttendanceDate(Long hotelId, LocalDate date);

    List<StaffAttendance> findByHotelIdAndAttendanceDateBetween(Long hotelId, LocalDate from, LocalDate to);

    Optional<StaffAttendance> findByHotelIdAndUserIdAndAttendanceDate(Long hotelId, Long userId, LocalDate date);

    @Query("select a.status, count(a) from StaffAttendance a where a.hotel.id = :hotelId " +
            " and a.attendanceDate between :from and :to group by a.status")
    List<Object[]> countByStatus(@Param("hotelId") Long hotelId,
                                 @Param("from") LocalDate from, @Param("to") LocalDate to);

    long countByHotelIdAndAttendanceDateAndStatus(Long hotelId, LocalDate date, AttendanceStatus status);
}
