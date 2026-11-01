package com.hotelcrm.controller;

import com.hotelcrm.dto.NotificationDtos;
import com.hotelcrm.service.SearchService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Global search")
@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class GlobalSearchController {

    private final SearchService searchService;

    @GetMapping
    public List<NotificationDtos.GlobalSearchResult> search(@RequestParam("q") String query) {
        return searchService.search(query);
    }
}
