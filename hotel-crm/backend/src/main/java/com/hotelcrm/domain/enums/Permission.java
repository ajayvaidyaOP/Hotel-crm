package com.hotelcrm.domain.enums;

/**
 * Fine grained permission codes. The authoritative mapping of role -> permissions lives in
 * {@link Role#permissions()} (backend enforced); the same codes are also persisted in the
 * roles / permissions / role_permissions tables so they can be inspected and audited.
 */
public enum Permission {
    HOTEL_READ("hotel:read"),
    HOTEL_WRITE("hotel:write"),
    ROOM_READ("room:read"),
    ROOM_WRITE("room:write"),
    PRICING_READ("pricing:read"),
    PRICING_WRITE("pricing:write"),
    BOOKING_READ("booking:read"),
    BOOKING_WRITE("booking:write"),
    BOOKING_CANCEL("booking:cancel"),
    CHECKIN_WRITE("checkin:write"),
    CHECKOUT_WRITE("checkout:write"),
    GUEST_READ("guest:read"),
    GUEST_WRITE("guest:write"),
    PAYMENT_READ("payment:read"),
    PAYMENT_WRITE("payment:write"),
    INVOICE_READ("invoice:read"),
    INVOICE_WRITE("invoice:write"),
    REFUND_WRITE("refund:write"),
    EXPENSE_READ("expense:read"),
    EXPENSE_WRITE("expense:write"),
    HOUSEKEEPING_READ("housekeeping:read"),
    HOUSEKEEPING_WRITE("housekeeping:write"),
    MAINTENANCE_READ("maintenance:read"),
    MAINTENANCE_WRITE("maintenance:write"),
    STAFF_READ("staff:read"),
    STAFF_WRITE("staff:write"),
    REPORT_READ("report:read"),
    ANALYTICS_READ("analytics:read"),
    NOTIFICATION_READ("notification:read"),
    AUDIT_READ("audit:read"),
    COUPON_WRITE("coupon:write"),
    SERVICE_READ("service:read"),
    SERVICE_WRITE("service:write");

    private final String code;

    Permission(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }
}
