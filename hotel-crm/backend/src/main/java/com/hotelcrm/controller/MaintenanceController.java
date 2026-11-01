package com.hotelcrm.controller;

import com.hotelcrm.domain.enums.MaintenanceStatus;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.MaintenanceService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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

@Tag(name = "Maintenance & lost & found")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class MaintenanceController {

    private final MaintenanceService maintenanceService;

    @GetMapping("/maintenance")
    public List<OpsDtos.MaintenanceResponse> list(@RequestParam(required = false) Long hotelId,
                                                  @RequestParam(required = false) MaintenanceStatus status,
                                                  @RequestParam(required = false) String search) {
        return maintenanceService.list(hotelId, status, search);
    }

    @PostMapping("/maintenance")
    @ResponseStatus(HttpStatus.CREATED)
    public OpsDtos.MaintenanceResponse create(@Valid @RequestBody OpsDtos.MaintenanceRequestDto request) {
        return maintenanceService.create(request);
    }

    @PutMapping("/maintenance/{id}")
    public OpsDtos.MaintenanceResponse update(@PathVariable Long id,
                                              @Valid @RequestBody OpsDtos.MaintenanceUpdateRequest request) {
        return maintenanceService.update(id, request);
    }

    @GetMapping("/lost-found")
    public List<OpsDtos.LostFoundResponse> lostAndFound(@RequestParam(required = false) Long hotelId) {
        return maintenanceService.lostAndFound(hotelId);
    }

    @PostMapping("/lost-found")
    @ResponseStatus(HttpStatus.CREATED)
    public OpsDtos.LostFoundResponse createLostFound(@Valid @RequestBody OpsDtos.LostFoundRequest request) {
        return maintenanceService.createLostFound(request);
    }

    @PatchMapping("/lost-found/{id}/status")
    public OpsDtos.LostFoundResponse updateLostFound(@PathVariable Long id,
                                                     @Valid @RequestBody OpsDtos.LostFoundStatusRequest request) {
        return maintenanceService.updateLostFound(id, request);
    }
}
