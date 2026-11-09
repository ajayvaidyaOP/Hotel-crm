package com.hotelcrm.domain.enums;

/** CRM segmentation of a guest. */
public enum GuestCategory {
    REGULAR, CORPORATE, VIP, LOYALTY, BLACKLISTED;

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
