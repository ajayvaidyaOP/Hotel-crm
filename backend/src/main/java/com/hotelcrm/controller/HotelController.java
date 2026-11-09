package com.hotelcrm.controller;

import com.hotelcrm.domain.enums.HotelStatus;
import com.hotelcrm.dto.HotelDtos;
import com.hotelcrm.service.HotelService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Hotels")
@RestController
@RequestMapping("/api/hotels")
@RequiredArgsConstructor
public class HotelController {

    private final HotelService hotelService;

    @GetMapping
    public List<HotelDtos.Response> list(@RequestParam(required = false) HotelStatus status,
                                         @RequestParam(required = false) String search) {
        return hotelService.list(status, search);
    }

    @GetMapping("/{id}")
    public HotelDtos.Response get(@PathVariable Long id) {
        return hotelService.get(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public HotelDtos.Response create(@Valid @RequestBody HotelDtos.Request request) {
        return hotelService.create(request);
    }

    @PutMapping("/{id}")
    public HotelDtos.Response update(@PathVariable Long id, @Valid @RequestBody HotelDtos.Request request) {
        return hotelService.update(id, request);
    }

    @PatchMapping("/{id}/status")
    public HotelDtos.Response updateStatus(@PathVariable Long id, @Valid @RequestBody HotelDtos.StatusRequest request) {
        return hotelService.updateStatus(id, request.status());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        hotelService.delete(id);
    }
}
