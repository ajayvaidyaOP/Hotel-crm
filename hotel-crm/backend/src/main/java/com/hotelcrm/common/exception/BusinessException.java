package com.hotelcrm.common.exception;

/** Raised when a business rule is violated (HTTP 400). */
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
