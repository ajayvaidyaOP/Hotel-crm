package com.hotelcrm.service;

import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Notification;
import com.hotelcrm.domain.enums.NotificationSeverity;
import com.hotelcrm.domain.enums.NotificationType;
import com.hotelcrm.dto.NotificationDtos;
import com.hotelcrm.repository.NotificationRepository;
import com.hotelcrm.security.HotelAccessService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

/** In-app notification centre. Email/WhatsApp channels can be plugged in behind {@link #dispatch}. */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final HotelAccessService accessService;

    @Transactional
    public void dispatch(Hotel hotel, Long userId, NotificationType type, NotificationSeverity severity,
                         String title, String message, String link) {
        Notification notification = Notification.builder()
                .hotel(hotel)
                .userId(userId)
                .type(type)
                .severity(severity)
                .title(title)
                .message(message)
                .link(link)
                .isRead(Boolean.FALSE)
                .build();
        notificationRepository.save(notification);
        log.debug("Notification dispatched: {} - {}", type, title);
    }

    @Transactional(readOnly = true)
    public List<NotificationDtos.Response> list(int limit) {
        Long userId = accessService.currentUserId();
        List<Long> hotelIds = accessService.accessibleHotelIds();
        return notificationRepository.findForUser(userId, hotelIds, PageRequest.of(0, Math.min(Math.max(limit, 1), 100)))
                .stream().map(NotificationDtos.Response::from).toList();
    }

    @Transactional(readOnly = true)
    public long unreadCount() {
        return notificationRepository.countUnread(accessService.currentUserId(), accessService.accessibleHotelIds());
    }

    @Transactional
    public void markRead(Long id) {
        notificationRepository.markRead(id, accessService.currentUserId(), Instant.now());
    }

    @Transactional
    public int markAllRead() {
        return notificationRepository.markAllRead(accessService.currentUserId(),
                accessService.accessibleHotelIds(), Instant.now());
    }
}
