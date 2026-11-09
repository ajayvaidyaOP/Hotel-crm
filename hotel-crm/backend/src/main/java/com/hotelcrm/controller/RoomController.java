package com.hotelcrm.controller;

import com.hotelcrm.domain.enums.HousekeepingCondition;
import com.hotelcrm.domain.enums.RoomStatus;
import com.hotelcrm.dto.BookingDtos;
import com.hotelcrm.dto.RoomDtos;
import com.hotelcrm.service.RoomService;
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
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Rooms & categories")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class RoomController {

    private final RoomService roomService;

    @GetMapping("/hotels/{hotelId}/room-categories")
    public List<RoomDtos.CategoryResponse> categories(@PathVariable Long hotelId) {
        return roomService.categories(hotelId);
    }

    @PostMapping("/hotels/{hotelId}/room-categories")
    @ResponseStatus(HttpStatus.CREATED)
    public RoomDtos.CategoryResponse createCategory(@PathVariable Long hotelId,
                                                    @Valid @RequestBody RoomDtos.CategoryRequest request) {
        return roomService.createCategory(hotelId, request);
    }

    @PutMapping("/room-categories/{id}")
    public RoomDtos.CategoryResponse updateCategory(@PathVariable Long id,
                                                    @RequestParam Long hotelId,
                                                    @Valid @RequestBody RoomDtos.CategoryRequest request) {
        return roomService.updateCategory(hotelId, id, request);
    }

    @DeleteMapping("/room-categories/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteCategory(@PathVariable Long id, @RequestParam Long hotelId) {
        roomService.deleteCategory(hotelId, id);
    }

    @GetMapping("/rooms")
    public List<RoomDtos.RoomResponse> rooms(@RequestParam(required = false) Long hotelId,
                                             @RequestParam(required = false) Long categoryId,
                                             @RequestParam(required = false) RoomStatus status,
                                             @RequestParam(required = false) HousekeepingCondition housekeeping,
                                             @RequestParam(required = false) Integer floor,
                                             @RequestParam(required = false) String search) {
        return roomService.rooms(hotelId, categoryId, status, housekeeping, floor, search);
    }

    @GetMapping("/rooms/{id}")
    public RoomDtos.RoomResponse get(@PathVariable Long id) {
        return roomService.get(id);
    }

    @PostMapping("/hotels/{hotelId}/rooms")
    @ResponseStatus(HttpStatus.CREATED)
    public RoomDtos.RoomResponse create(@PathVariable Long hotelId, @Valid @RequestBody RoomDtos.RoomRequest request) {
        return roomService.create(hotelId, request);
    }

    @PostMapping("/hotels/{hotelId}/rooms/bulk")
    @ResponseStatus(HttpStatus.CREATED)
    public List<RoomDtos.RoomResponse> bulkCreate(@PathVariable Long hotelId,
                                                  @RequestParam Long categoryId,
                                                  @RequestParam(defaultValue = "1") Integer floor,
                                                  @RequestParam(defaultValue = "5") Integer count,
                                                  @RequestParam(required = false) Integer startNumber) {
        return roomService.bulkCreate(hotelId, categoryId, floor, count, startNumber);
    }

    @PutMapping("/rooms/{id}")
    public RoomDtos.RoomResponse update(@PathVariable Long id, @Valid @RequestBody RoomDtos.RoomRequest request) {
        return roomService.update(id, request);
    }

    @PatchMapping("/rooms/{id}/status")
    public RoomDtos.RoomResponse updateStatus(@PathVariable Long id,
                                              @RequestBody RoomDtos.StatusRequest request) {
        return roomService.updateStatus(id, request);
    }

    @DeleteMapping("/rooms/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        roomService.delete(id);
    }

    @GetMapping("/rooms/{id}/history")
    public List<BookingDtos.TimelineEntry> history(@PathVariable Long id) {
        return roomService.history(id);
    }

    @GetMapping("/hotels/{hotelId}/rooms/availability")
    public List<RoomDtos.AvailabilityResponse> availability(
            @PathVariable Long hotelId,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return roomService.availability(hotelId, categoryId, from, to);
    }
}
