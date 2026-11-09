package com.hotelcrm.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Percentage / ratio helpers used by dashboards and reports. */
public final class RateMath {

    private RateMath() {
    }

    public static BigDecimal percentage(long numerator, long denominator) {
        if (denominator <= 0) {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        return BigDecimal.valueOf(numerator)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(denominator), 2, RoundingMode.HALF_UP);
    }

    public static BigDecimal ratio(BigDecimal numerator, BigDecimal denominator) {
        if (denominator == null || denominator.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        return numerator.divide(denominator, 2, RoundingMode.HALF_UP);
    }
}
