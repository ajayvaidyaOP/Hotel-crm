package com.hotelcrm.domain.enums;

import java.util.Collections;
import java.util.EnumSet;
import java.util.Set;

/**
 * Application roles. A user has exactly one primary role (users.primary_role) which drives
 * authorization; hotel level isolation is enforced separately through hotel_staff assignments.
 */
public enum Role {
    SUPER_ADMIN("Owner / Super Admin", EnumSet.allOf(Permission.class)),
    HOTEL_MANAGER("Hotel Manager", EnumSet.of(
            Permission.HOTEL_READ, Permission.ROOM_READ, Permission.ROOM_WRITE,
            Permission.PRICING_READ, Permission.PRICING_WRITE,
            Permission.BOOKING_READ, Permission.BOOKING_WRITE, Permission.BOOKING_CANCEL,
            Permission.CHECKIN_WRITE, Permission.CHECKOUT_WRITE,
            Permission.GUEST_READ, Permission.GUEST_WRITE,
            Permission.PAYMENT_READ, Permission.PAYMENT_WRITE,
            Permission.INVOICE_READ, Permission.INVOICE_WRITE, Permission.REFUND_WRITE,
            Permission.EXPENSE_READ, Permission.EXPENSE_WRITE,
            Permission.HOUSEKEEPING_READ, Permission.HOUSEKEEPING_WRITE,
            Permission.MAINTENANCE_READ, Permission.MAINTENANCE_WRITE,
            Permission.STAFF_READ, Permission.STAFF_WRITE,
            Permission.REPORT_READ, Permission.ANALYTICS_READ,
            Permission.NOTIFICATION_READ, Permission.SERVICE_READ, Permission.SERVICE_WRITE)),
    RECEPTIONIST("Receptionist", EnumSet.of(
            Permission.HOTEL_READ, Permission.ROOM_READ, Permission.ROOM_WRITE,
            Permission.PRICING_READ,
            Permission.BOOKING_READ, Permission.BOOKING_WRITE, Permission.BOOKING_CANCEL,
            Permission.CHECKIN_WRITE, Permission.CHECKOUT_WRITE,
            Permission.GUEST_READ, Permission.GUEST_WRITE,
            Permission.PAYMENT_READ, Permission.PAYMENT_WRITE,
            Permission.INVOICE_READ, Permission.INVOICE_WRITE,
            Permission.HOUSEKEEPING_READ, Permission.NOTIFICATION_READ,
            Permission.SERVICE_READ, Permission.SERVICE_WRITE)),
    HOUSEKEEPING("Housekeeping", EnumSet.of(
            Permission.HOTEL_READ, Permission.ROOM_READ,
            Permission.HOUSEKEEPING_READ, Permission.HOUSEKEEPING_WRITE,
            Permission.MAINTENANCE_READ, Permission.MAINTENANCE_WRITE,
            Permission.NOTIFICATION_READ)),
    ACCOUNTANT("Accountant", EnumSet.of(
            Permission.HOTEL_READ, Permission.BOOKING_READ, Permission.GUEST_READ,
            Permission.PAYMENT_READ, Permission.PAYMENT_WRITE,
            Permission.INVOICE_READ, Permission.INVOICE_WRITE, Permission.REFUND_WRITE,
            Permission.EXPENSE_READ, Permission.EXPENSE_WRITE,
            Permission.REPORT_READ, Permission.ANALYTICS_READ, Permission.NOTIFICATION_READ));

    private final String label;
    private final Set<Permission> permissions;

    Role(String label, Set<Permission> permissions) {
        this.label = label;
        this.permissions = Collections.unmodifiableSet(permissions);
    }

    public String getLabel() {
        return label;
    }

    public Set<Permission> getPermissions() {
        return permissions;
    }

    public Set<String> getPermissionCodes() {
        Set<String> codes = new java.util.LinkedHashSet<>();
        permissions.forEach(p -> codes.add(p.getCode()));
        return codes;
    }

    public boolean has(Permission permission) {
        return permissions.contains(permission);
    }

    public boolean isSuperAdmin() {
        return this == SUPER_ADMIN;
    }
}
