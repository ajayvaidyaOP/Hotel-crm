package com.hotelcrm.controller;

import com.hotelcrm.domain.enums.FeedbackStatus;
import com.hotelcrm.domain.enums.FeedbackType;
import com.hotelcrm.dto.GuestDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.FeedbackService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Guest feedback")
@RestController
@RequestMapping("/api/feedback")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    @GetMapping
    public List<OpsDtos.FeedbackRow> list(@RequestParam(required = false) Long hotelId,
                                          @RequestParam(required = false) FeedbackType type,
                                          @RequestParam(required = false) FeedbackStatus status) {
        return feedbackService.list(hotelId, type, status);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OpsDtos.FeedbackRow create(@Valid @RequestBody GuestDtos.FeedbackRequest request) {
        return feedbackService.create(request);
    }

    @PostMapping("/{id}/resolve")
    public OpsDtos.FeedbackRow resolve(@PathVariable Long id,
                                       @Valid @RequestBody GuestDtos.FeedbackResolveRequest request) {
        return feedbackService.resolve(id, request);
    }
}
