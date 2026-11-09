package com.hotelcrm.controller;

import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.dto.NotificationDtos;
import com.hotelcrm.service.NotificationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;

@Tag(name = "Notifications")
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public List<NotificationDtos.Response> list(@RequestParam(defaultValue = "30") int limit) {
        return notificationService.list(limit);
    }

    @GetMapping("/unread-count")
    public NotificationDtos.CountResponse unread() {
        return new NotificationDtos.CountResponse(notificationService.unreadCount());
    }

    @PostMapping("/{id}/read")
    public NotificationDtos.CountResponse markRead(@PathVariable Long id) {
        notificationService.markRead(id);
        return new NotificationDtos.CountResponse(notificationService.unreadCount());
    }

    @PostMapping("/read-all")
    public NotificationDtos.CountResponse markAllRead() {
        return new NotificationDtos.CountResponse(notificationService.markAllRead());
    }

    @GetMapping("/types")
    public List<String> types() {
        return Arrays.stream(NotificationType.values()).map(Enum::name).toList();
    }

    @GetMapping("/severities")
    public List<String> severities() {
        return Arrays.stream(NotificationSeverity.values()).map(Enum::name).toList();
    }
}
