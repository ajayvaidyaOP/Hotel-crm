package com.hotelcrm.controller;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.domain.enums.ExpenseCategory;
import com.hotelcrm.dto.DashboardDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.ExpenseService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
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

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Expenses")
@RestController
@RequestMapping("/api/expenses")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;

    @GetMapping
    public PageResponse<OpsDtos.ExpenseResponse> list(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) ExpenseCategory category,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return expenseService.list(hotelId, from, to, category, search, page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OpsDtos.ExpenseResponse create(@Valid @RequestBody OpsDtos.ExpenseRequest request) {
        return expenseService.create(request);
    }

    @PutMapping("/{id}")
    public OpsDtos.ExpenseResponse update(@PathVariable Long id, @Valid @RequestBody OpsDtos.ExpenseRequest request) {
        return expenseService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        expenseService.delete(id);
    }

    @GetMapping("/summary")
    public List<DashboardDtos.NamedValue> summary(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return expenseService.summaryByCategory(hotelId, from, to);
    }
}
