package com.hotelcrm.controller;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.domain.enums.InvoiceStatus;
import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.service.InvoiceService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
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

@Tag(name = "Invoices")
@RestController
@RequestMapping("/api/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;

    @GetMapping
    public PageResponse<PaymentDtos.InvoiceResponse> list(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) InvoiceStatus status,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return invoiceService.list(hotelId, from, to, status, search, page, size);
    }

    @GetMapping("/{id}")
    public PaymentDtos.InvoiceResponse get(@PathVariable Long id) {
        return invoiceService.get(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PaymentDtos.InvoiceResponse generate(@Valid @RequestBody PaymentDtos.GenerateInvoiceRequest request) {
        return invoiceService.generateForBooking(request);
    }

    @PostMapping("/{id}/settle")
    public PaymentDtos.InvoiceResponse settle(@PathVariable Long id,
                                              @Valid @RequestBody PaymentDtos.SettleInvoiceRequest request) {
        return invoiceService.settle(id, request);
    }

    @PostMapping("/{id}/cancel")
    public PaymentDtos.InvoiceResponse cancel(@PathVariable Long id) {
        return invoiceService.cancel(id);
    }

    @GetMapping("/booking/{bookingId}")
    public List<PaymentDtos.InvoiceResponse> forBooking(@PathVariable Long bookingId) {
        return invoiceService.forBooking(bookingId);
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> pdf(@PathVariable Long id) {
        byte[] pdf = invoiceService.pdf(id);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"invoice-" + id + ".pdf\"")
                .body(pdf);
    }
}
