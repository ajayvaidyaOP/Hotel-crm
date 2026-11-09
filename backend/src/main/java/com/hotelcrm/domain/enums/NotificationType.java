package com.hotelcrm.domain.enums;

/** Notification category. */
public enum NotificationType {
    BOOKING_CREATED, BOOKING_CANCELLED, CHECKIN_DUE, CHECKOUT_DUE, PAYMENT_PENDING, HOUSEKEEPING, MAINTENANCE, STAFF, SYSTEM;

    public String getLabel() {
        String[] parts = name().toLowerCase().split("_");
        StringBuilder sb = new StringBuilder();
        for (String p : parts) {
            if (sb.length() > 0) sb.append(' ');
            sb.append(Character.toUpperCase(p.charAt(0))).append(p.substring(1));
        }
        return sb.toString();
    }
}
