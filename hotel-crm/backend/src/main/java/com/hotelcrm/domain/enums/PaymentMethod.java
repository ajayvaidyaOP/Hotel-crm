package com.hotelcrm.domain.enums;

/** How money was received. Card credentials are never stored. */
public enum PaymentMethod {
    CASH, UPI, CARD, BANK_TRANSFER, CHEQUE, ONLINE;

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
