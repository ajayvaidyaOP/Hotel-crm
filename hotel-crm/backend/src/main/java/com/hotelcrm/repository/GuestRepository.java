package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Guest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface GuestRepository extends JpaRepository<Guest, Long>, JpaSpecificationExecutor<Guest> {

    Optional<Guest> findByMobile(String mobile);

    List<Guest> findTop10ByFullNameContainingIgnoreCaseOrMobileContainingIgnoreCase(String name, String mobile);

    @Query("select g from Guest g where g.id in (" +
            " select b.guest.id from Booking b where b.hotel.id = :hotelId)")
    List<Guest> findByHotelId(@Param("hotelId") Long hotelId);

    @Query("select count(g) from Guest g where g.vip = true")
    long countVip();

    List<Guest> findByVipTrue();

    @Query("select g from Guest g where lower(g.fullName) like lower(concat('%', :term, '%')) or g.mobile like concat('%', :term, '%') or lower(coalesce(g.email, '')) like lower(concat('%', :term, '%'))")
    List<Guest> search(@Param("term") String term);
}
