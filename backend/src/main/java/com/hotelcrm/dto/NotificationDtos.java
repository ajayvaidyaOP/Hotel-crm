package com.hotelcrm.dto;

import com.hotelcrm.domain.entity.Notification;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;

import java.time.Instant;

public final class NotificationDtos {

    private NotificationDtos() {
    }

    public record Response(
            Long id,
            Long hotelId,
            String hotelName,
            String title,
            String message,
            NotificationType type,
            NotificationSeverity severity,
            String link,
            boolean isRead,
            Instant readAt,
            Instant createdAt) {

        public static Response from(Notification notification) {
            return new Response(notification.getId(),
                    notification.getHotel() == null ? null : notification.getHotel().getId(),
                    notification.getHotel() == null ? null : notification.getHotel().getName(),
                    notification.getTitle(), notification.getMessage(), notification.getType(),
                    notification.getSeverity(), notification.getLink(),
                    Boolean.TRUE.equals(notification.getIsRead()), notification.getReadAt(),
                    notification.getCreatedAt());
        }
    }

    public record CountResponse(long unread) {
    }

    public record GlobalSearchResult(
            String type,
            Long id,
            String title,
            String subtitle,
            String hotelName,
            String link) {
    }
}
