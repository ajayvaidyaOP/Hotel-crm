package com.hotelcrm.domain.enums;

/** Government id proof type (number is encrypted). */
public enum IdProofType {
    AADHAAR, PASSPORT, DRIVING_LICENSE, VOTER_ID, PAN, OTHER;

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
