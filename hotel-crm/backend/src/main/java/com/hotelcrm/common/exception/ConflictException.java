package com.hotelcrm.common.exception;

/** Raised for concurrency / duplicate conflicts such as double booking (HTTP 409). */
public class ConflictException extends RuntimeException {
    public ConflictException(String message) {
        super(message);
    }
}
