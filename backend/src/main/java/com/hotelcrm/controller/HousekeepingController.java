package com.hotelcrm.controller;

import com.hotelcrm.domain.enums.HousekeepingTaskStatus;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.HousekeepingService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
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

import java.util.List;

@Tag(name = "Housekeeping")
@RestController
@RequestMapping("/api/housekeeping")
@RequiredArgsConstructor
public class HousekeepingController {

    private final HousekeepingService housekeepingService;

    @GetMapping
    public List<OpsDtos.HousekeepingResponse> list(@RequestParam(required = false) Long hotelId,
                                                   @RequestParam(required = false) HousekeepingTaskStatus status,
                                                   @RequestParam(required = false) Long assignedTo,
                                                   @RequestParam(required = false) Long roomId,
                                                   @RequestParam(required = false) String search) {
        return housekeepingService.list(hotelId, status, assignedTo, roomId, search);
    }

    @GetMapping("/my-tasks")
    public List<OpsDtos.HousekeepingResponse> myTasks() {
        return housekeepingService.myTasks();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OpsDtos.HousekeepingResponse create(@Valid @RequestBody OpsDtos.HousekeepingRequest request) {
        return housekeepingService.create(request);
    }

    @PatchMapping("/{id}/status")
    public OpsDtos.HousekeepingResponse updateStatus(@PathVariable Long id,
                                                     @Valid @RequestBody OpsDtos.HousekeepingStatusRequest request) {
        return housekeepingService.updateStatus(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        housekeepingService.delete(id);
    }
}
