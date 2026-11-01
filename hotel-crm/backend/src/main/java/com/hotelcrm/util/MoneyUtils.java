package com.hotelcrm.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** All monetary arithmetic goes through here: BigDecimal, 2 decimals, HALF_UP. */
public final class MoneyUtils {

    public static final BigDecimal ZERO = scale(BigDecimal.ZERO);

    private MoneyUtils() {
    }

    public static BigDecimal scale(BigDecimal value) {
        return (value == null ? BigDecimal.ZERO : value).setScale(2, RoundingMode.HALF_UP);
    }

    public static BigDecimal add(BigDecimal... values) {
        BigDecimal total = BigDecimal.ZERO;
        for (BigDecimal v : values) {
            if (v != null) {
                total = total.add(v);
            }
        }
        return scale(total);
    }

    public static BigDecimal subtract(BigDecimal a, BigDecimal b) {
        return scale(nullToZero(a).subtract(nullToZero(b)));
    }

    public static BigDecimal multiply(BigDecimal a, BigDecimal b) {
        return scale(nullToZero(a).multiply(nullToZero(b)));
    }

    public static BigDecimal percentOf(BigDecimal amount, BigDecimal percent) {
        if (amount == null || percent == null) {
            return ZERO;
        }
        return scale(amount.multiply(percent).divide(BigDecimal.valueOf(100), 6, RoundingMode.HALF_UP));
    }

    public static BigDecimal nullToZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    public static boolean isPositive(BigDecimal value) {
        return value != null && value.compareTo(BigDecimal.ZERO) > 0;
    }

    /** Splits a total into equal monthly-safe instalments (unused by core flows, handy for reports). */
    public static BigDecimal divide(BigDecimal amount, int divisor) {
        if (divisor == 0) {
            return ZERO;
        }
        return scale(nullToZero(amount).divide(BigDecimal.valueOf(divisor), 4, RoundingMode.HALF_UP));
    }
}
