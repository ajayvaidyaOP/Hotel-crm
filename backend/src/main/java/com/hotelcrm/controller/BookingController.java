package com.hotelcrm.controller;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.domain.enums.BookingPaymentStatus;
import com.hotelcrm.domain.enums.BookingSource;
import com.hotelcrm.domain.enums.BookingStatus;
import com.hotelcrm.dto.BookingDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.service.BookingService;
import io.swagger.v3.oas.annotations.Operation;
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
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Bookings")
@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @GetMapping
    public PageResponse<BookingDtos.Summary> search(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(required = false) List<BookingStatus> status,
            @RequestParam(required = false) BookingPaymentStatus paymentStatus,
            @RequestParam(required = false) BookingSource source,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return bookingService.search(hotelId, status, paymentStatus, source, from, to, search, page, size);
    }

    @GetMapping("/calendar")
    public BookingDtos.CalendarResponse calendar(
            @RequestParam Long hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return bookingService.calendar(hotelId, from, to);
    }

    @GetMapping("/day-operations")
    public BookingDtos.DayOperations dayOperations(
            @RequestParam(required = false) Long hotelId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return bookingService.dayOperations(hotelId, date);
    }

    @GetMapping("/{id}")
    public BookingDtos.Response get(@PathVariable Long id) {
        return bookingService.get(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public BookingDtos.Response create(@Valid @RequestBody BookingDtos.Request request) {
        return bookingService.create(request);
    }

    @PutMapping("/{id}")
    public BookingDtos.Response update(@PathVariable Long id, @Valid @RequestBody BookingDtos.UpdateRequest request) {
        return bookingService.update(id, request);
    }

    @PostMapping("/{id}/cancel")
    public BookingDtos.Response cancel(@PathVariable Long id, @Valid @RequestBody BookingDtos.CancelRequest request) {
        return bookingService.cancel(id, request);
    }

    @Operation(summary = "Check a guest in (assigns rooms when needed)")
    @PostMapping("/{id}/check-in")
    public BookingDtos.Response checkIn(@PathVariable Long id,
                                        @RequestBody(required = false) BookingDtos.CheckInRequest request) {
        return bookingService.checkIn(id, request == null ? new BookingDtos.CheckInRequest(null, null, null, null) : request);
    }

    @Operation(summary = "Check a guest out, generate the invoice and release the rooms")
    @PostMapping("/{id}/check-out")
    public BookingDtos.CheckOutResponse checkOut(@PathVariable Long id,
                                                 @Valid @RequestBody BookingDtos.CheckOutRequest request) {
        return bookingService.checkOut(id, request);
    }

    @PostMapping("/{id}/transfer-room")
    public BookingDtos.Response transferRoom(@PathVariable Long id,
                                             @Valid @RequestBody BookingDtos.TransferRoomRequest request) {
        return bookingService.transferRoom(id, request);
    }

    @PostMapping("/{id}/reschedule")
    public BookingDtos.Response reschedule(@PathVariable Long id,
                                           @Valid @RequestBody BookingDtos.RescheduleRequest request) {
        return bookingService.reschedule(id, request);
    }

    @GetMapping("/{id}/services")
    public List<OpsDtos.ServiceOrderResponse> services(@PathVariable Long id) {
        return bookingService.services(id);
    }

    @GetMapping("/{id}/receipt.pdf")
    public ResponseEntity<byte[]> receipt(@PathVariable Long id) {
        byte[] pdf = bookingService.receiptPdf(id);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"booking-" + id + ".pdf\"")
                .body(pdf);
    }
}
