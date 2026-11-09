package com.hotelcrm.controller;

import com.hotelcrm.dto.RoomDtos;
import com.hotelcrm.service.PricingService;
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
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Pricing")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class PricingController {

    private final PricingService pricingService;

    @GetMapping("/hotels/{hotelId}/rate-plans")
    public List<RoomDtos.RatePlanResponse> list(@PathVariable Long hotelId) {
        return pricingService.listPlans(hotelId);
    }

    @PostMapping("/hotels/{hotelId}/rate-plans")
    @ResponseStatus(HttpStatus.CREATED)
    public RoomDtos.RatePlanResponse create(@PathVariable Long hotelId,
                                            @Valid @RequestBody RoomDtos.RatePlanRequest request) {
        return pricingService.createPlan(hotelId, request);
    }

    @PutMapping("/hotels/{hotelId}/rate-plans/{id}")
    public RoomDtos.RatePlanResponse update(@PathVariable Long hotelId, @PathVariable Long id,
                                            @Valid @RequestBody RoomDtos.RatePlanRequest request) {
        return pricingService.updatePlan(hotelId, id, request);
    }

    @DeleteMapping("/hotels/{hotelId}/rate-plans/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long hotelId, @PathVariable Long id) {
        pricingService.deletePlan(hotelId, id);
    }

    @PostMapping("/hotels/{hotelId}/pricing/quote")
    public RoomDtos.QuoteResponse quote(@PathVariable Long hotelId,
                                        @Valid @RequestBody RoomDtos.QuoteRequest request) {
        return pricingService.quote(hotelId, request);
    }
}
