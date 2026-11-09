package com.hotelcrm.controller;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.domain.enums.GuestCategory;
import com.hotelcrm.dto.GuestDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.FeedbackService;
import com.hotelcrm.service.GuestService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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

@Tag(name = "Guest CRM")
@RestController
@RequestMapping("/api/guests")
@RequiredArgsConstructor
public class GuestController {

    private final GuestService guestService;
    private final FeedbackService feedbackService;

    @GetMapping
    public PageResponse<GuestDtos.Response> search(@RequestParam(required = false) String search,
                                                   @RequestParam(required = false) GuestCategory category,
                                                   @RequestParam(required = false) Boolean vip,
                                                   @RequestParam(required = false) Long hotelId,
                                                   @RequestParam(defaultValue = "0") int page,
                                                   @RequestParam(defaultValue = "20") int size) {
        return guestService.search(search, category, vip, hotelId, page, size);
    }

    @GetMapping("/{id}")
    public GuestDtos.Detail get(@PathVariable Long id) {
        return guestService.get(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public GuestDtos.Response create(@Valid @RequestBody GuestDtos.Request request) {
        return guestService.create(request);
    }

    @PutMapping("/{id}")
    public GuestDtos.Response update(@PathVariable Long id, @Valid @RequestBody GuestDtos.Request request) {
        return guestService.update(id, request);
    }

    @GetMapping("/{id}/feedback")
    public List<GuestDtos.FeedbackResponse> feedback(@PathVariable Long id) {
        return feedbackService.forGuest(id);
    }

    @GetMapping("/{id}/services")
    public List<OpsDtos.ServiceOrderResponse> services(@PathVariable Long id) {
        return guestService.get(id).services();
    }
}
