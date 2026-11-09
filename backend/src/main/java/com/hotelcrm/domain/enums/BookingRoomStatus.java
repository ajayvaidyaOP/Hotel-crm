package com.hotelcrm.domain.enums;

/** Per-room segment state inside a booking. */
public enum BookingRoomStatus {
    RESERVED, CHECKED_IN, CHECKED_OUT, CANCELLED, NO_SHOW;

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
