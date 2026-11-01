package com.hotelcrm.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;

class MoneyMathTest {

    @Test
    @DisplayName("Money is always scaled to two decimals")
    void scalesMoney() {
        assertEquals(new BigDecimal("10.00"), MoneyUtils.scale(new BigDecimal("9.995")));
        assertEquals(new BigDecimal("0.00"), MoneyUtils.scale(null));
    }

    @Test
    @DisplayName("Null-safe addition ignores missing legs")
    void addsSafely() {
        assertEquals(new BigDecimal("1500.00"),
                MoneyUtils.add(new BigDecimal("1000"), null, new BigDecimal("500")));
    }

    @Test
    @DisplayName("Percentage of amount rounds HALF_UP")
    void percentOfAmount() {
        assertEquals(new BigDecimal("180.00"),
                MoneyUtils.percentOf(new BigDecimal("1000"), new BigDecimal("18")));
    }

    @Test
    @DisplayName("Multi-night stay math stays exact")
    void multipliesRateByNights() {
        BigDecimal rate = new BigDecimal("4500.50");
        assertEquals(new BigDecimal("13501.50"), MoneyUtils.multiply(rate, new BigDecimal(3)));
    }

    @Test
    @DisplayName("Occupancy handles a zero room-night denominator")
    void occupancyGuardsZero() {
        assertEquals(new BigDecimal("0.00"), RateMath.percentage(10, 0));
        assertEquals(new BigDecimal("50.00"), RateMath.percentage(10, 20));
    }

    @Test
    @DisplayName("Subtraction treats missing operands as zero")
    void subtractHandlesNull() {
        assertEquals(new BigDecimal("0.00"), MoneyUtils.subtract(null, null));
        assertEquals(new BigDecimal("-250.00"), MoneyUtils.subtract(new BigDecimal("750"), new BigDecimal("1000")));
    }
}
