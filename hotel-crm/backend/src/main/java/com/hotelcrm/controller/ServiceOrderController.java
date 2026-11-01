package com.hotelcrm.controller;

import com.hotelcrm.domain.enums.ServiceOrderStatus;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.ServiceOrderService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Services (restaurant, laundry, minibar)")
@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
public class ServiceOrderController {

    private final ServiceOrderService serviceOrderService;

    @GetMapping
    public List<OpsDtos.ServiceOrderResponse> list(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(required = false) ServiceOrderStatus status) {
        return serviceOrderService.list(hotelId, date, status);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OpsDtos.ServiceOrderResponse create(@Valid @RequestBody OpsDtos.ServiceOrderRequest request) {
        return serviceOrderService.create(request);
    }

    @PatchMapping("/{id}/status")
    public OpsDtos.ServiceOrderResponse updateStatus(@PathVariable Long id,
                                                    @RequestParam ServiceOrderStatus status) {
        return serviceOrderService.updateStatus(id, status);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        serviceOrderService.delete(id);
    }
}
