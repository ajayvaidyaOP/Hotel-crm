package com.hotelcrm.domain.enums;

/** Kind of housekeeping task. */
public enum HousekeepingTaskType {
    CLEANING, DEEP_CLEAN, INSPECTION, LINEN_CHANGE, MAINTENANCE_FOLLOWUP;

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
