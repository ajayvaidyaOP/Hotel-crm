package com.hotelcrm.util;

import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/** Human friendly, unique-enough business identifiers (booking / payment / invoice numbers). */
public final class CodeGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final DateTimeFormatter YY = DateTimeFormatter.ofPattern("yy");

    private CodeGenerator() {
    }

    public static String bookingCode(String hotelCode, long sequence) {
        String prefix = hotelCode == null ? "HTL" : hotelCode.replace("HTL-", "").replace("HTS-", "");
        return prefix + "-" + LocalDate.now().format(YY) + String.format("%05d", sequence % 100000);
    }

    public static String paymentCode(String hotelCode) {
        return "PAY-" + shortCode(hotelCode) + "-" + System.currentTimeMillis() % 1000000
                + RANDOM.nextInt(90) + 10;
    }

    public static String invoiceNumber(String hotelCode, long sequence) {
        return "INV-" + shortCode(hotelCode) + "-" + LocalDate.now().format(YY) + String.format("%05d", sequence % 100000);
    }

    public static String temporaryToken() {
        byte[] bytes = new byte[24];
        RANDOM.nextBytes(bytes);
        return java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static String shortCode(String hotelCode) {
        if (hotelCode == null || hotelCode.isBlank()) {
            return "HTL";
        }
        String cleaned = hotelCode.replace("HTL-", "").replace("HTS-", "");
        return cleaned.length() > 4 ? cleaned.substring(0, 4) : cleaned;
    }
}
