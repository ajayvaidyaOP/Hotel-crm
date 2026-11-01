package com.hotelcrm.domain.enums;

/** Classification of a printed invoice line. */
public enum InvoiceLineType {
    ROOM, SERVICE, EXTRA, TAX, DISCOUNT;

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
