package com.hotelcrm.domain.enums;

/** Physical state of a room (tracked separately from booking state). */
public enum RoomStatus {
    AVAILABLE, OCCUPIED, CLEANING, MAINTENANCE, OUT_OF_SERVICE;

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
