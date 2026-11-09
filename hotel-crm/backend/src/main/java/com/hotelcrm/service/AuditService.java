package com.hotelcrm.service;

import com.hotelcrm.domain.entity.AuditLog;
import com.hotelcrm.repository.AuditLogRepository;
import com.hotelcrm.security.AppUserPrincipal;
import com.hotelcrm.security.HotelAccessService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.Instant;

/** Append-only audit trail of security and money related operations. */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final HotelAccessService accessService;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(Long hotelId, String action, String entityType, Long entityId, String description) {
        try {
            AppUserPrincipal principal = accessService.principalOptional().orElse(null);
            AuditLog entry = AuditLog.builder()
                    .hotelId(hotelId)
                    .userId(principal == null ? null : principal.getId())
                    .actorEmail(principal == null ? "system" : principal.getEmail())
                    .action(action)
                    .entityType(entityType)
                    .entityId(entityId)
                    .description(description)
                    .ipAddress(clientIp())
                    .build();
            auditLogRepository.save(entry);
        } catch (RuntimeException ex) {
            // auditing must never break the business transaction
            log.warn("Unable to write audit log for {}: {}", action, ex.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public Page<AuditLog> search(Long hotelId, String action, Pageable pageable) {
        return auditLogRepository.search(accessService.resolveHotelScope(hotelId), action, pageable);
    }

    private String clientIp() {
        try {
            ServletRequestAttributes attributes =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) {
                return null;
            }
            HttpServletRequest request = attributes.getRequest();
            String forwarded = request.getHeader("X-Forwarded-For");
            if (forwarded != null && !forwarded.isBlank()) {
                return forwarded.split(",")[0].trim();
            }
            return request.getRemoteAddr();
        } catch (RuntimeException ex) {
            return null;
        }
    }

    @SuppressWarnings("unused")
    private Instant now() {
        return Instant.now();
    }
}
