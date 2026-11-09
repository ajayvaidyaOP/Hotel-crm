package com.hotelcrm.controller;

import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.CouponService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Coupons")
@RestController
@RequestMapping("/api/coupons")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;

    @GetMapping
    public List<OpsDtos.CouponResponse> list(@RequestParam Long hotelId) {
        return couponService.list(hotelId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OpsDtos.CouponResponse create(@Valid @RequestBody OpsDtos.CouponRequest request) {
        return couponService.create(request);
    }

    @PutMapping("/{id}")
    public OpsDtos.CouponResponse update(@PathVariable Long id, @Valid @RequestBody OpsDtos.CouponRequest request) {
        return couponService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        couponService.delete(id);
    }
}
