-- =====================================================================
--  Multi-Hotel Management CRM  |  V1 - Core relational schema
--  MySQL 8.0 / InnoDB / utf8mb4
--  Conventions:
--    * monetary values  : DECIMAL(12,2)  -> BigDecimal in Java
--    * audit timestamps : DATETIME(6) in UTC -> Instant in Java
--    * business dates   : DATE           -> LocalDate in Java
--    * business times   : TIME           -> LocalTime in Java
--    * booleans         : BIT(1)         -> Boolean in Java (Hibernate default)
--    * enums            : VARCHAR(n)     -> Java enum persisted as STRING
-- =====================================================================

-- ---------------------------------------------------------------------
-- SECURITY / IDENTITY
-- ---------------------------------------------------------------------
CREATE TABLE roles (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    code         VARCHAR(40)  NOT NULL,
    name         VARCHAR(80)  NOT NULL,
    description  VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_roles_code (code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE permissions (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    code         VARCHAR(60)  NOT NULL,
    description  VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_permissions_code (code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE role_permissions (
    role_id       BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE,
    CONSTRAINT fk_rp_permission FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE users (
    id                   BIGINT       NOT NULL AUTO_INCREMENT,
    full_name            VARCHAR(120) NOT NULL,
    email                VARCHAR(160) NOT NULL,
    phone                VARCHAR(30)  NULL,
    password_hash        VARCHAR(100) NOT NULL,
    primary_role         VARCHAR(40)  NOT NULL,
    enabled              BIT(1)       NOT NULL DEFAULT b'1',
    must_change_password BIT(1)       NOT NULL DEFAULT b'0',
    token_version        INT          NOT NULL DEFAULT 0,
    last_login_at        DATETIME(6)  NULL,
    designation          VARCHAR(80)  NULL,
    created_at           DATETIME(6)  NOT NULL,
    updated_at           DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_email (email),
    KEY idx_users_role (primary_role),
    KEY idx_users_enabled (enabled)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- HOTELS  (tenant root)
-- ---------------------------------------------------------------------
CREATE TABLE hotels (
    id             BIGINT        NOT NULL AUTO_INCREMENT,
    name           VARCHAR(160)  NOT NULL,
    code           VARCHAR(20)   NOT NULL,
    address        VARCHAR(255)  NULL,
    city           VARCHAR(80)   NULL,
    state          VARCHAR(80)   NULL,
    country        VARCHAR(80)   NOT NULL DEFAULT 'India',
    postal_code    VARCHAR(20)   NULL,
    contact_number VARCHAR(30)   NULL,
    email          VARCHAR(160)  NULL,
    description    VARCHAR(2000) NULL,
    image_urls     VARCHAR(4000) NULL,
    facilities     VARCHAR(4000) NULL,
    amenities_note VARCHAR(500)  NULL,
    check_in_time  TIME          NOT NULL DEFAULT '14:00:00',
    check_out_time TIME          NOT NULL DEFAULT '11:00:00',
    timezone       VARCHAR(60)   NOT NULL DEFAULT 'Asia/Kolkata',
    star_rating    INT           NULL,
    gst_number     VARCHAR(30)   NULL,
    tax_rate       DECIMAL(5,2)  NOT NULL DEFAULT 12.00,
    status         VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    created_at     DATETIME(6)   NOT NULL,
    updated_at     DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_hotels_code (code),
    KEY idx_hotels_status (status),
    KEY idx_hotels_city (city)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE hotel_staff (
    id            BIGINT       NOT NULL AUTO_INCREMENT,
    hotel_id      BIGINT       NOT NULL,
    user_id       BIGINT       NOT NULL,
    designation   VARCHAR(80)  NULL,
    employee_code VARCHAR(30)  NULL,
    department    VARCHAR(60)  NULL,
    shift_name    VARCHAR(30)  NULL,
    shift_start   TIME         NULL,
    shift_end     TIME         NULL,
    joined_on     DATE         NULL,
    active        BIT(1)       NOT NULL DEFAULT b'1',
    created_at    DATETIME(6)  NOT NULL,
    updated_at    DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_staff_hotel_user (hotel_id, user_id),
    UNIQUE KEY uk_staff_employee_code (hotel_id, employee_code),
    KEY idx_staff_user (user_id),
    CONSTRAINT fk_staff_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_staff_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- ROOM INVENTORY & PRICING
-- ---------------------------------------------------------------------
CREATE TABLE room_categories (
    id                 BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id           BIGINT        NOT NULL,
    name               VARCHAR(80)   NOT NULL,
    code               VARCHAR(20)   NOT NULL,
    description        VARCHAR(1000) NULL,
    base_price         DECIMAL(12,2) NOT NULL,
    weekend_price      DECIMAL(12,2) NULL,
    extra_person_charge DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    extra_bed_charge   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    early_checkin_charge DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    late_checkout_charge DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    max_occupancy      INT           NOT NULL DEFAULT 2,
    amenities          VARCHAR(4000) NULL,
    image_urls         VARCHAR(4000) NULL,
    sort_order         INT           NOT NULL DEFAULT 0,
    active             BIT(1)        NOT NULL DEFAULT b'1',
    created_at         DATETIME(6)   NOT NULL,
    updated_at         DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_category_hotel_code (hotel_id, code),
    KEY idx_category_hotel (hotel_id),
    CONSTRAINT fk_category_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE rooms (
    id                  BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id            BIGINT        NOT NULL,
    room_category_id    BIGINT        NOT NULL,
    room_number         VARCHAR(20)   NOT NULL,
    floor               INT           NOT NULL DEFAULT 0,
    room_type           VARCHAR(20)   NOT NULL DEFAULT 'DOUBLE',
    bed_type            VARCHAR(20)   NOT NULL DEFAULT 'DOUBLE',
    max_occupancy       INT           NOT NULL DEFAULT 2,
    is_ac               BIT(1)        NOT NULL DEFAULT b'1',
    description         VARCHAR(1000) NULL,
    image_urls          VARCHAR(4000) NULL,
    amenities           VARCHAR(4000) NULL,
    base_price          DECIMAL(12,2) NOT NULL,
    weekend_price       DECIMAL(12,2) NULL,
    extra_person_charge DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status              VARCHAR(20)   NOT NULL DEFAULT 'AVAILABLE',
    housekeeping_status VARCHAR(20)   NOT NULL DEFAULT 'CLEAN',
    active              BIT(1)        NOT NULL DEFAULT b'1',
    created_at          DATETIME(6)   NOT NULL,
    updated_at          DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_room_hotel_number (hotel_id, room_number),
    KEY idx_room_hotel_status (hotel_id, status),
    KEY idx_room_category (room_category_id),
    CONSTRAINT fk_room_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_room_category FOREIGN KEY (room_category_id) REFERENCES room_categories (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Seasonal / weekend / holiday / promotional rate overrides
CREATE TABLE room_pricing (
    id                BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id          BIGINT        NOT NULL,
    room_category_id  BIGINT        NULL,
    room_id           BIGINT        NULL,
    name              VARCHAR(120)  NOT NULL,
    pricing_type      VARCHAR(20)   NOT NULL,
    adjustment_type   VARCHAR(20)   NOT NULL DEFAULT 'FIXED',
    amount            DECIMAL(12,2) NOT NULL,
    start_date        DATE          NULL,
    end_date          DATE          NULL,
    days_of_week      VARCHAR(20)   NULL,
    priority          INT           NOT NULL DEFAULT 0,
    active            BIT(1)        NOT NULL DEFAULT b'1',
    created_at        DATETIME(6)   NOT NULL,
    updated_at        DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_pricing_hotel (hotel_id),
    KEY idx_pricing_range (start_date, end_date),
    KEY idx_pricing_category (room_category_id),
    KEY idx_pricing_room (room_id),
    CONSTRAINT fk_pricing_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_pricing_category FOREIGN KEY (room_category_id) REFERENCES room_categories (id) ON DELETE CASCADE,
    CONSTRAINT fk_pricing_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE coupons (
    id            BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id      BIGINT        NULL,
    code          VARCHAR(40)   NOT NULL,
    description   VARCHAR(255)  NULL,
    discount_type VARCHAR(20)   NOT NULL,
    value         DECIMAL(12,2) NOT NULL,
    min_amount    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    max_discount  DECIMAL(12,2) NULL,
    valid_from    DATE          NULL,
    valid_to      DATE          NULL,
    usage_limit   INT           NULL,
    used_count    INT           NOT NULL DEFAULT 0,
    active        BIT(1)        NOT NULL DEFAULT b'1',
    created_at    DATETIME(6)   NOT NULL,
    updated_at    DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_coupons_code (code),
    KEY idx_coupons_hotel (hotel_id),
    CONSTRAINT fk_coupon_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- GUEST CRM
-- ---------------------------------------------------------------------
CREATE TABLE guests (
    id                 BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id           BIGINT        NULL,
    full_name          VARCHAR(120)  NOT NULL,
    mobile             VARCHAR(30)   NOT NULL,
    email              VARCHAR(160)  NULL,
    address            VARCHAR(255)  NULL,
    city               VARCHAR(80)   NULL,
    state              VARCHAR(80)   NULL,
    country            VARCHAR(80)   NULL,
    id_proof_type      VARCHAR(30)   NULL,
    id_proof_number    VARCHAR(500)  NULL,   -- AES-GCM encrypted at rest
    id_proof_last4     VARCHAR(4)    NULL,   -- masked value for display/search
    category           VARCHAR(20)   NOT NULL DEFAULT 'REGULAR',
    vip                BIT(1)        NOT NULL DEFAULT b'0',
    blacklisted        BIT(1)        NOT NULL DEFAULT b'0',
    notes              VARCHAR(1000) NULL,
    special_requests   VARCHAR(1000) NULL,
    loyalty_points     INT           NOT NULL DEFAULT 0,
    created_at         DATETIME(6)   NOT NULL,
    updated_at         DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_guest_mobile (mobile),
    KEY idx_guest_email (email),
    KEY idx_guest_hotel (hotel_id),
    KEY idx_guest_name (full_name),
    CONSTRAINT fk_guest_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- BOOKINGS
-- ---------------------------------------------------------------------
CREATE TABLE bookings (
    id                 BIGINT        NOT NULL AUTO_INCREMENT,
    booking_code       VARCHAR(24)   NOT NULL,
    hotel_id           BIGINT        NOT NULL,
    guest_id           BIGINT        NOT NULL,
    check_in_date      DATE          NOT NULL,
    check_out_date     DATE          NOT NULL,
    adults             INT           NOT NULL DEFAULT 1,
    children           INT           NOT NULL DEFAULT 0,
    booking_source     VARCHAR(20)   NOT NULL DEFAULT 'DIRECT',
    status             VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    payment_status     VARCHAR(20)   NOT NULL DEFAULT 'UNPAID',
    room_charge_total      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    extra_charges          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount_amount        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_amount             DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_amount           DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    advance_amount         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    paid_amount            DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    pending_amount         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    coupon_id          BIGINT        NULL,
    currency           VARCHAR(3)    NOT NULL DEFAULT 'INR',
    special_requests   VARCHAR(1000) NULL,
    internal_notes     VARCHAR(1000) NULL,
    cancellation_reason VARCHAR(500) NULL,
    cancelled_at       DATETIME(6)   NULL,
    actual_check_in_at DATETIME(6)   NULL,
    actual_check_out_at DATETIME(6)  NULL,
    checked_in_by      BIGINT        NULL,
    checked_out_by     BIGINT        NULL,
    created_by         BIGINT        NULL,
    created_at         DATETIME(6)   NOT NULL,
    updated_at         DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_booking_code (booking_code),
    KEY idx_booking_hotel_status (hotel_id, status),
    KEY idx_booking_dates (hotel_id, check_in_date, check_out_date),
    KEY idx_booking_guest (guest_id),
    KEY idx_booking_payment_status (hotel_id, payment_status),
    CONSTRAINT fk_booking_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id),
    CONSTRAINT fk_booking_guest FOREIGN KEY (guest_id) REFERENCES guests (id),
    CONSTRAINT fk_booking_coupon FOREIGN KEY (coupon_id) REFERENCES coupons (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- One row per physical room held by a booking (a booking may hold several rooms)
CREATE TABLE booking_rooms (
    id                BIGINT        NOT NULL AUTO_INCREMENT,
    booking_id        BIGINT        NOT NULL,
    room_id           BIGINT        NULL,          -- NULL = room not assigned yet
    room_category_id  BIGINT        NOT NULL,
    check_in_date     DATE          NOT NULL,
    check_out_date    DATE          NOT NULL,
    nights            INT           NOT NULL,
    rate_per_night    DECIMAL(12,2) NOT NULL,
    extra_person_charge DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    extra_bed_count   INT           NOT NULL DEFAULT 0,
    total_amount      DECIMAL(12,2) NOT NULL,
    status            VARCHAR(20)   NOT NULL DEFAULT 'RESERVED',
    created_at        DATETIME(6)   NOT NULL,
    updated_at        DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_broom_booking (booking_id),
    KEY idx_broom_room_dates (room_id, check_in_date, check_out_date),
    CONSTRAINT fk_broom_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE,
    CONSTRAINT fk_broom_room FOREIGN KEY (room_id) REFERENCES rooms (id),
    CONSTRAINT fk_broom_category FOREIGN KEY (room_category_id) REFERENCES room_categories (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE booking_guests (
    id            BIGINT      NOT NULL AUTO_INCREMENT,
    booking_id    BIGINT      NOT NULL,
    guest_id      BIGINT      NOT NULL,
    primary_guest BIT(1)      NOT NULL DEFAULT b'0',
    created_at    DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at    DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uk_booking_guest (booking_id, guest_id),
    CONSTRAINT fk_bg_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE CASCADE,
    CONSTRAINT fk_bg_guest FOREIGN KEY (guest_id) REFERENCES guests (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- BILLING / PAYMENTS
-- ---------------------------------------------------------------------
CREATE TABLE invoices (
    id             BIGINT        NOT NULL AUTO_INCREMENT,
    invoice_number VARCHAR(30)   NOT NULL,
    hotel_id       BIGINT        NOT NULL,
    booking_id     BIGINT        NULL,
    guest_id       BIGINT        NULL,
    issue_date     DATE          NOT NULL,
    due_date       DATE          NULL,
    subtotal       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    tax_rate       DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
    tax_amount     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    amount_paid    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    balance        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status         VARCHAR(20)   NOT NULL DEFAULT 'ISSUED',
    gstin          VARCHAR(30)   NULL,
    bill_to_name   VARCHAR(160)  NULL,
    bill_to_address VARCHAR(300) NULL,
    notes          VARCHAR(500)  NULL,
    created_by     BIGINT        NULL,
    created_at     DATETIME(6)   NOT NULL,
    updated_at     DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_invoice_number (invoice_number),
    KEY idx_invoice_hotel_date (hotel_id, issue_date),
    KEY idx_invoice_booking (booking_id),
    KEY idx_invoice_status (hotel_id, status),
    CONSTRAINT fk_invoice_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id),
    CONSTRAINT fk_invoice_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL,
    CONSTRAINT fk_invoice_guest FOREIGN KEY (guest_id) REFERENCES guests (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE invoice_lines (
    id          BIGINT        NOT NULL AUTO_INCREMENT,
    invoice_id  BIGINT        NOT NULL,
    line_type   VARCHAR(20)   NOT NULL DEFAULT 'ROOM',
    description VARCHAR(255)  NOT NULL,
    quantity    DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    unit_price  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    amount      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    created_at  DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at  DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_line_invoice (invoice_id),
    CONSTRAINT fk_line_invoice FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE payments (
    id           BIGINT        NOT NULL AUTO_INCREMENT,
    payment_code VARCHAR(24)   NOT NULL,
    hotel_id     BIGINT        NOT NULL,
    booking_id   BIGINT        NULL,
    invoice_id   BIGINT        NULL,
    amount       DECIMAL(12,2) NOT NULL,
    method       VARCHAR(20)   NOT NULL,
    payment_type VARCHAR(20)   NOT NULL DEFAULT 'BOOKING',
    status       VARCHAR(20)   NOT NULL DEFAULT 'SUCCESS',
    reference_no VARCHAR(80)   NULL,
    notes        VARCHAR(500)  NULL,
    paid_at      DATETIME(6)   NOT NULL,
    received_by  BIGINT        NULL,
    created_at   DATETIME(6)   NOT NULL,
    updated_at   DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_payment_code (payment_code),
    KEY idx_payment_hotel_date (hotel_id, paid_at),
    KEY idx_payment_booking (booking_id),
    KEY idx_payment_invoice (invoice_id),
    CONSTRAINT fk_payment_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id),
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL,
    CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE refunds (
    id           BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id     BIGINT        NOT NULL,
    payment_id   BIGINT        NULL,
    booking_id   BIGINT        NULL,
    amount       DECIMAL(12,2) NOT NULL,
    reason       VARCHAR(300)  NULL,
    method       VARCHAR(20)   NULL,
    status       VARCHAR(20)   NOT NULL DEFAULT 'COMPLETED',
    processed_by BIGINT        NULL,
    processed_at DATETIME(6)   NOT NULL,
    created_at   DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at   DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_refund_hotel (hotel_id, processed_at),
    CONSTRAINT fk_refund_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id),
    CONSTRAINT fk_refund_payment FOREIGN KEY (payment_id) REFERENCES payments (id) ON DELETE SET NULL,
    CONSTRAINT fk_refund_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE expenses (
    id             BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id       BIGINT        NOT NULL,
    category       VARCHAR(30)   NOT NULL,
    description    VARCHAR(300)  NOT NULL,
    amount         DECIMAL(12,2) NOT NULL,
    expense_date   DATE          NOT NULL,
    vendor         VARCHAR(160)  NULL,
    payment_method VARCHAR(20)   NULL,
    reference_no   VARCHAR(80)   NULL,
    created_by     BIGINT        NULL,
    created_at     DATETIME(6)   NOT NULL,
    updated_at     DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_expense_hotel_date (hotel_id, expense_date),
    KEY idx_expense_category (hotel_id, category),
    CONSTRAINT fk_expense_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- HOUSEKEEPING / MAINTENANCE
-- ---------------------------------------------------------------------
CREATE TABLE housekeeping_tasks (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id        BIGINT        NOT NULL,
    room_id         BIGINT        NULL,
    task_type       VARCHAR(30)   NOT NULL DEFAULT 'CLEANING',
    status          VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    priority        VARCHAR(20)   NOT NULL DEFAULT 'NORMAL',
    assigned_to     BIGINT        NULL,
    notes           VARCHAR(1000) NULL,
    scheduled_date  DATE          NULL,
    started_at      DATETIME(6)   NULL,
    completed_at    DATETIME(6)   NULL,
    inspected_by    BIGINT        NULL,
    inspected_at    DATETIME(6)   NULL,
    created_by      BIGINT        NULL,
    created_at      DATETIME(6)   NOT NULL,
    updated_at      DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_hk_hotel_status (hotel_id, status),
    KEY idx_hk_assignee (assigned_to, status),
    KEY idx_hk_room (room_id),
    CONSTRAINT fk_hk_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_hk_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE SET NULL,
    CONSTRAINT fk_hk_assignee FOREIGN KEY (assigned_to) REFERENCES users (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE maintenance_requests (
    id           BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id     BIGINT        NOT NULL,
    room_id      BIGINT        NULL,
    title        VARCHAR(160)  NOT NULL,
    description  VARCHAR(1000) NULL,
    category     VARCHAR(40)   NOT NULL DEFAULT 'GENERAL',
    priority     VARCHAR(20)   NOT NULL DEFAULT 'NORMAL',
    status       VARCHAR(20)   NOT NULL DEFAULT 'OPEN',
    reported_by  BIGINT        NULL,
    assigned_to  BIGINT        NULL,
    cost         DECIMAL(12,2) NULL,
    reported_at  DATETIME(6)   NOT NULL,
    resolved_at  DATETIME(6)   NULL,
    resolution_note VARCHAR(500) NULL,
    created_at   DATETIME(6)   NOT NULL,
    updated_at   DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_maint_hotel_status (hotel_id, status),
    KEY idx_maint_room (room_id),
    CONSTRAINT fk_maint_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_maint_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE lost_and_found (
    id               BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id         BIGINT        NOT NULL,
    room_id          BIGINT        NULL,
    guest_id         BIGINT        NULL,
    item_description VARCHAR(500)  NOT NULL,
    found_by         BIGINT        NULL,
    found_at         DATETIME(6)   NOT NULL,
    status           VARCHAR(20)   NOT NULL DEFAULT 'STORED',
    storage_location VARCHAR(120)  NULL,
    notes            VARCHAR(500)  NULL,
    created_at       DATETIME(6)   NOT NULL,
    updated_at       DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_lf_hotel (hotel_id, status),
    CONSTRAINT fk_lf_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_lf_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE SET NULL,
    CONSTRAINT fk_lf_guest FOREIGN KEY (guest_id) REFERENCES guests (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- STAFF ATTENDANCE
-- ---------------------------------------------------------------------
CREATE TABLE staff_attendance (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id        BIGINT        NOT NULL,
    user_id         BIGINT        NOT NULL,
    attendance_date DATE          NOT NULL,
    status          VARCHAR(20)   NOT NULL DEFAULT 'PRESENT',
    shift_name      VARCHAR(30)   NULL,
    check_in_time   DATETIME(6)   NULL,
    check_out_time  DATETIME(6)   NULL,
    notes           VARCHAR(300)  NULL,
    created_at      DATETIME(6)   NOT NULL,
    updated_at      DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_attendance_hotel_user_date (hotel_id, user_id, attendance_date),
    KEY idx_attendance_date (hotel_id, attendance_date),
    CONSTRAINT fk_att_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_att_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- EXTRA SERVICES (restaurant / room service / laundry / minibar)
-- ---------------------------------------------------------------------
CREATE TABLE service_orders (
    id             BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id       BIGINT        NOT NULL,
    booking_id     BIGINT        NULL,
    room_id        BIGINT        NULL,
    guest_id       BIGINT        NULL,
    order_type     VARCHAR(20)   NOT NULL,
    description    VARCHAR(500)  NOT NULL,
    amount         DECIMAL(12,2) NOT NULL,
    quantity       INT           NOT NULL DEFAULT 1,
    status         VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    billed_to_room BIT(1)        NOT NULL DEFAULT b'1',
    ordered_at     DATETIME(6)   NOT NULL,
    delivered_at   DATETIME(6)   NULL,
    created_by     BIGINT        NULL,
    created_at     DATETIME(6)   NOT NULL,
    updated_at     DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_order_hotel_date (hotel_id, ordered_at),
    KEY idx_order_booking (booking_id),
    CONSTRAINT fk_order_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL,
    CONSTRAINT fk_order_room FOREIGN KEY (room_id) REFERENCES rooms (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- FEEDBACK / COMPLAINTS
-- ---------------------------------------------------------------------
CREATE TABLE guest_feedback (
    id          BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id    BIGINT        NOT NULL,
    guest_id    BIGINT        NULL,
    booking_id  BIGINT        NULL,
    type        VARCHAR(20)   NOT NULL DEFAULT 'FEEDBACK',
    rating      INT           NULL,
    comments    VARCHAR(1500) NULL,
    status      VARCHAR(20)   NOT NULL DEFAULT 'OPEN',
    resolution  VARCHAR(1000) NULL,
    resolved_by BIGINT        NULL,
    resolved_at DATETIME(6)   NULL,
    created_at  DATETIME(6)   NOT NULL,
    updated_at  DATETIME(6)   NOT NULL,
    PRIMARY KEY (id),
    KEY idx_feedback_hotel (hotel_id, type, status),
    CONSTRAINT fk_feedback_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_guest FOREIGN KEY (guest_id) REFERENCES guests (id) ON DELETE SET NULL,
    CONSTRAINT fk_feedback_booking FOREIGN KEY (booking_id) REFERENCES bookings (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- NOTIFICATIONS / AUDIT
-- ---------------------------------------------------------------------
CREATE TABLE notifications (
    id         BIGINT       NOT NULL AUTO_INCREMENT,
    hotel_id   BIGINT       NULL,
    user_id    BIGINT       NULL,
    title      VARCHAR(160) NOT NULL,
    message    VARCHAR(500) NOT NULL,
    type       VARCHAR(40)  NOT NULL,
    severity   VARCHAR(20)  NOT NULL DEFAULT 'INFO',
    link       VARCHAR(200) NULL,
    is_read    BIT(1)       NOT NULL DEFAULT b'0',
    read_at    DATETIME(6)  NULL,
    created_at DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_notif_user (user_id, is_read),
    KEY idx_notif_hotel (hotel_id, created_at),
    CONSTRAINT fk_notif_hotel FOREIGN KEY (hotel_id) REFERENCES hotels (id) ON DELETE CASCADE,
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
    id          BIGINT        NOT NULL AUTO_INCREMENT,
    hotel_id    BIGINT        NULL,
    user_id     BIGINT        NULL,
    actor_email VARCHAR(160)  NULL,
    action      VARCHAR(60)   NOT NULL,
    entity_type VARCHAR(60)   NULL,
    entity_id   BIGINT        NULL,
    description VARCHAR(1000) NULL,
    ip_address  VARCHAR(60)   NULL,
    created_at  DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at  DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_audit_hotel_date (hotel_id, created_at),
    KEY idx_audit_entity (entity_type, entity_id),
    KEY idx_audit_user (user_id, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
