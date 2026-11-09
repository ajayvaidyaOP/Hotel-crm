package com.hotelcrm.controller;

import com.hotelcrm.dto.PaymentDtos;
import com.hotelcrm.dto.ReportDtos;
import com.hotelcrm.service.ReportService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Reports & analytics")
@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/kpi")
    public ReportDtos.KpiResponse kpi(@RequestParam(required = false) Long hotelId,
                                      @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                      @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.kpi(hotelId, from, to);
    }

    @GetMapping("/revenue")
    public List<ReportDtos.RevenueRow> revenue(@RequestParam(required = false) Long hotelId,
                                               @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                               @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.revenue(hotelId, from, to);
    }

    @GetMapping("/occupancy")
    public List<ReportDtos.OccupancyRow> occupancy(@RequestParam(required = false) Long hotelId,
                                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.occupancy(hotelId, from, to);
    }

    @GetMapping("/categories")
    public List<ReportDtos.CategoryRow> categories(@RequestParam(required = false) Long hotelId,
                                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                                   @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.topCategories(hotelId, from, to);
    }

    @GetMapping("/expenses")
    public List<ReportDtos.ExpenseRow> expenses(@RequestParam(required = false) Long hotelId,
                                                @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                                @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.expenses(hotelId, from, to);
    }

    @GetMapping("/profit")
    public List<ReportDtos.ProfitRow> profit(@RequestParam(required = false) Long hotelId,
                                             @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                             @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.profit(hotelId, from, to);
    }

    @GetMapping("/cancellations")
    public List<ReportDtos.CancellationRow> cancellations(@RequestParam(required = false) Long hotelId,
                                                          @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                                          @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.cancellations(hotelId, from, to);
    }

    @GetMapping("/pending-payments")
    public List<PaymentDtos.PendingPaymentRow> pending(@RequestParam(required = false) Long hotelId) {
        return reportService.pendingPayments(hotelId);
    }

    @GetMapping("/bundle")
    public ReportDtos.ReportBundle bundle(@RequestParam(required = false) Long hotelId,
                                          @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                          @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return reportService.bundle(hotelId, from, to);
    }

    @GetMapping("/export")
    public ResponseEntity<byte[]> export(@RequestParam(defaultValue = "revenue") String report,
                                         @RequestParam(defaultValue = "csv") String format,
                                         @RequestParam(required = false) Long hotelId,
                                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        ReportService.ExportFile file = reportService.export(report, format, hotelId, from, to);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(file.contentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + file.fileName() + "\"")
                .body(file.content());
    }
}
