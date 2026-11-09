package com.hotelcrm.controller;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.domain.enums.PaymentMethod;
import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.service.PaymentService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Payments")
@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @GetMapping
    public PageResponse<PaymentDtos.Response> list(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) PaymentMethod method,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return paymentService.list(hotelId, from, to, method, search, page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PaymentDtos.Response record(@Valid @RequestBody PaymentDtos.Request request) {
        return paymentService.record(request);
    }

    @GetMapping("/pending")
    public List<PaymentDtos.PendingPaymentRow> pending(@RequestParam(required = false) Long hotelId) {
        return paymentService.pendingPayments(hotelId);
    }

    @GetMapping("/refunds")
    public List<PaymentDtos.RefundResponse> refunds(@RequestParam(required = false) Long hotelId) {
        return paymentService.refunds(hotelId);
    }

    @PostMapping("/refunds")
    @ResponseStatus(HttpStatus.CREATED)
    public PaymentDtos.RefundResponse refund(@Valid @RequestBody PaymentDtos.RefundRequest request) {
        return paymentService.refund(request);
    }

    @GetMapping("/summary")
    public PaymentDtos.FinancialSummary summary(@RequestParam(required = false) Long hotelId,
                                                @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                                @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return paymentService.summary(hotelId, from, to);
    }

    @GetMapping("/booking/{bookingId}")
    public List<PaymentDtos.Response> forBooking(@PathVariable Long bookingId) {
        return paymentService.forBooking(bookingId);
    }
}
