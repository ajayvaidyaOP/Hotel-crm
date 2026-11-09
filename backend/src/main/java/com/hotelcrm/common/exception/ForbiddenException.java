package com.hotelcrm.common.exception;

/** Raised when a caller tries to touch data outside of their hotel scope (HTTP 403). */
public class ForbiddenException extends RuntimeException {
    public ForbiddenException(String message) {
        super(message);
    }
}
