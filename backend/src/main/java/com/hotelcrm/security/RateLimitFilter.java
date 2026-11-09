package com.hotelcrm.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Lightweight in-memory fixed window rate limiter.
 * Auth endpoints get a strict per-IP budget, the rest of the API a generous one.
 * For multi-instance deployments swap the store for Redis (same interface).
 */
@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private final int loginLimit;
    private final int apiLimit;
    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    public RateLimitFilter(@Value("${app.security.max-login-attempts-per-minute:10}") int loginLimit,
                           @Value("${app.security.max-requests-per-minute:600}") int apiLimit) {
        this.loginLimit = loginLimit;
        this.apiLimit = apiLimit;
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        String path = request.getRequestURI();
        if (!path.startsWith("/api/")) {
            filterChain.doFilter(request, response);
            return;
        }
        boolean authEndpoint = path.startsWith("/api/auth/login") || path.startsWith("/api/auth/refresh")
                || path.startsWith("/api/auth/forgot-password") || path.startsWith("/api/auth/reset-password");
        int limit = authEndpoint ? loginLimit : apiLimit;
        String key = (authEndpoint ? "auth:" : "api:") + clientIp(request);
        if (!allow(key, limit)) {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":429,\"error\":\"Too Many Requests\","
                    + "\"message\":\"Too many requests. Please slow down and try again in a minute.\"}");
            return;
        }
        filterChain.doFilter(request, response);
    }

    private boolean allow(String key, int limit) {
        long now = System.currentTimeMillis();
        Window window = windows.computeIfAbsent(key, k -> new Window(now));
        synchronized (window) {
            if (now - window.start > 60_000L) {
                window.start = now;
                window.count.set(0);
            }
            if (window.count.incrementAndGet() > limit) {
                return false;
            }
        }
        if (windows.size() > 10_000) {
            windows.entrySet().removeIf(e -> now - e.getValue().start > 300_000L);
        }
        return true;
    }

    private String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private static final class Window {
        private volatile long start;
        private final AtomicInteger count = new AtomicInteger();

        private Window(long start) {
            this.start = start;
        }
    }
}
