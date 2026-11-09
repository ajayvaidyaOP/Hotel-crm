package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CouponRepository extends JpaRepository<Coupon, Long> {

    Optional<Coupon> findByCodeIgnoreCase(String code);

    @Query("select c from Coupon c where c.hotel is null or c.hotel.id = :hotelId order by c.createdAt desc")
    List<Coupon> findForHotel(@Param("hotelId") Long hotelId);
}
