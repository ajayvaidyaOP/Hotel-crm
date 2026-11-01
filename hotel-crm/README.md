# Hotel CRM — Multi-Hotel Management Suite

A production-shaped multi-property hotel management CRM. An owner runs **five hotels from a single account**, while
managers, receptionists, housekeeping staff and accountants each see only what their role and hotel assignment allow.

Everything is real: React talks to a Spring Boot REST API over JWT, and every record lives in MySQL. There is no mock
data layer, no client-side faking and no TODO placeholders in the core flows.

```
hotel-crm/
├── backend/          Spring Boot 3.3 · Java 21 · Gradle · MySQL 8 · Flyway
├── frontend/         React 18 · Vite 5 · TypeScript · Tailwind · shadcn-style UI
├── docs/             API reference · deployment · architecture
└── docker-compose.yml
```

---

## 1. Feature map

### Multi-hotel core
| Capability | Where |
|---|---|
| Hotel CRUD (unlimited properties), activate/deactivate, GSTIN & tax rate | `Hotels` page → `/api/hotels` |
| Global hotel switcher (group view or single property) in the top bar | `Topbar` + `HotelContext` |
| Row-level isolation: every query filtered by the hotels you are assigned to | `HotelAccessService.resolveHotelScope` |
| Room categories (Standard, Deluxe, Premium, Suite, Family…) with base/weekend/extra-bed/extra-person/early/late charges | `Rooms & rates → Categories` |
| Room inventory, bulk creation, floor & amenities, operational status separate from housekeeping condition | `Rooms & rates → Inventory` |
| Dynamic pricing: weekend, seasonal, holiday, promo plans with priority + per-night quote preview | `Rooms & rates → Rate plans`, `/hotels/{id}/pricing/quote` |

### Front desk
* **Bookings** — walk-in, phone, OTA, corporate; multi-room; guest created inline; coupon; discount; advance payment.
* **Double-booking prevention** — date-overlap query *and* a `PESSIMISTIC_WRITE` lock on the room row inside one
  transaction; conflicts return HTTP **409** with a readable message. Rooms may stay unassigned ("TBA") and are
  auto-assigned at check-in.
* **Status machine** — Pending → Confirmed → Checked In → Checked Out, plus Cancelled and No Show.
* **Check-in** — segment→room assignment, early check-in charge, ID verification.
* **Check-out** — extra charges, late check-out, discount, optional settlement, automatic GST invoice, room flipped to
  `CLEANING`/`DIRTY` with an auto-created housekeeping task.
* **Transfer room** and **reschedule** with server-side availability validation; receipt PDF per booking.
* **Visual calendar** — day / week / 2-week / month, rooms as rows, drag a reservation to another room or date and the
  API re-validates before saving.

### Guests, billing, operations
* **Guest CRM** — profiles, VIP & blacklist flags, loyalty points, stay history, lifetime value, outstanding balance,
  feedback & service history. ID proof numbers are encrypted with **AES-GCM** (only the last 4 digits are ever returned).
* **Payments** — cash / UPI / card / bank transfer / cheque / online; advance, partial, settlement; refunds; no card data
  stored (method + reference only). Ledger invariant: `paid = Σ successful payments − Σ completed refunds`.
* **Invoices** — sequential GST invoices, line items (room nights, services, extras, discounts), settle, cancel, PDF.
* **Expenses** — categorised operational spend feeding profit reports.
* **Housekeeping** — task board (Pending → In progress → Completed → Inspected), assignment, auto tasks from checkout,
  room condition sync; **maintenance** requests that block a room; **lost & found** register.
* **Services** — restaurant, room service, laundry, minibar charged to the folio (only while the guest is checked in).
* **Staff** — accounts, roles, hotel assignment, shifts, activate/deactivate, admin password reset, per-user activity log,
  attendance register with daily summary.
* **Notifications** — in-app feed with unread badge, severities, mark read/all.
* **Audit log** — append-only trail for logins, bookings, payments, refunds, staff changes.
* **Global search** — one box searching hotels, bookings, guests, rooms and staff.
* **Reports** — KPI (revenue, net revenue, ADR, RevPAR, occupancy, ALOS, cancellation rate), revenue trend, occupancy by
  hotel, category mix, expenses, profit by hotel, cancellations, pending dues, with **CSV / XLSX / PDF** export.
* **Security** — JWT access + rotating refresh tokens, token versioning (password change revokes sessions), login and API
  rate limiting, BCrypt hashes, Bean Validation on every write, RBAC enforced in services.
* **Account self-service** — profile edit, password change, and a token-based **forgot / reset password** flow
  (`/reset-password?token=…`; in development the single-use token is written to the API log until an email or WhatsApp
  provider is plugged into `AuthService`).

---

## 2. Quick start

### Prerequisites
| Tool | Version |
|---|---|
| JDK | 21 |
| Node.js | ≥ 18 (tested on 22) |
| MySQL | 8.0 (or Docker) |

### 2.1 Database

```bash
cd hotel-crm
docker compose up -d          # MySQL 8 with database hotel_crm / user hotel_crm
```

No Docker? Create the schema manually:

```sql
CREATE DATABASE hotel_crm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'hotel_crm'@'localhost' IDENTIFIED BY 'hotel_crm';
GRANT ALL PRIVILEGES ON hotel_crm.* TO 'hotel_crm'@'localhost';
```

Flyway creates all 28 tables and (when seeding is enabled) inserts the demo portfolio.

### 2.2 Backend

```bash
cd hotel-crm/backend
cp .env.example .env          # optional: export these variables instead
./gradlew bootRun             # http://localhost:8080
```

* Swagger UI → <http://localhost:8080/swagger-ui.html>
* Health → <http://localhost:8080/actuator/health>

### 2.3 Frontend

```bash
cd hotel-crm/frontend
cp .env.example .env
npm install
npm run dev                   # http://localhost:5173
```

The Vite dev server proxies `/api` and `/actuator` to `http://localhost:8080`, so no CORS setup is needed in development.
The login screen shows a live API status indicator.

### 2.4 Production build

```bash
cd hotel-crm/backend && ./gradlew clean build        # -> build/libs/hotel-crm-backend-1.0.0.jar
cd hotel-crm/frontend && npm run build               # -> dist/
```

---

## 3. Demo accounts

Seeded by `V900__demo_seed.sql` (loaded only when `APP_SEED_ENABLED=true`, the default in `dev`).

| Role | Email | Password | Scope |
|---|---|---|---|
| Owner / Super Admin | `owner@hotelgroup.com` | `Owner@123` | All 5 hotels |
| Hotel Manager (Mumbai) | `manager.mumbai@hotelgroup.com` | `Hotel@123` | Grand Vista Mumbai |
| Hotel Manager (Goa) | `manager.goa@hotelgroup.com` | `Hotel@123` | Palm Bay Resort Goa |
| Hotel Manager (Jaipur / Manali / Pune) | `manager.jaipur@…`, `manager.manali@…`, `manager.pune@…` | `Hotel@123` | Their hotel only |
| Receptionist | `reception.mumbai@hotelgroup.com`, `reception.goa@…`, `reception.jaipur@…` | `Hotel@123` | Front desk of one hotel |
| Housekeeping | `housekeeping.mumbai@hotelgroup.com`, `…goa@…`, `…pune@…` | `Hotel@123` | Task board |
| Accountant | `accounts@hotelgroup.com`, `billing@hotelgroup.com` | `Hotel@123` | Money & reports |

Seeded portfolio: **5 hotels · 25 room categories · 100 rooms · 20 guests · 40 bookings** (mixed statuses), 29 payments,
19 invoices, 24 housekeeping tasks, 10 maintenance requests, 120 expenses, attendance, service orders, coupons
(`WELCOME10`, `STAYLONG`, `GOASUN20`), notifications and audit entries.

| Hotel | Code | City |
|---|---|---|
| Grand Vista Mumbai | HTL-MUM | Mumbai |
| Palm Bay Resort Goa | HTL-GOA | Candolim, Goa |
| Heritage Palace Jaipur | HTL-JAI | Jaipur |
| Alpine Crest Manali | HTL-MNL | Manali |
| Urban Nest Pune | HTL-PNQ | Pune |

> ⚠️ Change `JWT_SECRET`, `APP_ENCRYPTION_KEY`, database credentials and the demo passwords before exposing this
> deployment to the internet. Set `APP_SEED_ENABLED=false` in production.

---

## 4. Configuration

All backend settings are environment variables (see `backend/.env.example`).

| Variable | Default | Purpose |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | `dev` | `prod` disables seeding and quiet logging |
| `DB_HOST` / `DB_PORT` / `DB_NAME` / `DB_USERNAME` / `DB_PASSWORD` | localhost / 3306 / hotel_crm / hotel_crm / hotel_crm | MySQL connection |
| `JWT_SECRET` | dev value | HMAC key — **must be ≥ 32 bytes** in production |
| `JWT_ACCESS_TTL_MINUTES` / `JWT_REFRESH_TTL_DAYS` | 60 / 7 | Token lifetimes |
| `APP_ENCRYPTION_KEY` | dev value | AES key for guest ID proofs |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:5173` | Comma-separated browser origins |
| `LOGIN_RATE_LIMIT` / `API_RATE_LIMIT` | 10 / 600 | Requests per minute |
| `APP_SEED_ENABLED` | `true` | Load the demo portfolio through Flyway |
| `SERVER_PORT` | 8080 | API port |

Frontend (`frontend/.env`):

| Variable | Default | Purpose |
|---|---|---|
| `VITE_API_BASE_URL` | `/api` | Base URL for the REST API |
| `VITE_PROXY_TARGET` | `http://localhost:8080` | Dev-server proxy target |

---

## 5. Database & migrations

* `db/migration/V1__schema.sql` — 28 tables, InnoDB, `utf8mb4`, FK constraints, indexes, audit columns.
* `db/migration/V2__password_reset_tokens.sql` — single-use hashed reset tokens.
* `db/seed/V900__demo_seed.sql` — demo portfolio (only registered when seeding is enabled).

`spring.jpa.hibernate.ddl-auto=validate`, so any entity/schema drift fails fast at startup instead of silently altering
tables. Flyway owns all DDL.

Key invariants enforced in code:

* One `booking_rooms` row per physical room segment, with its own dates, nightly rate and total → allows mid-stay room
  changes without corrupting the folio.
* Overlap test: `existing.checkIn < new.checkOut AND existing.checkOut > new.checkIn` over statuses
  `PENDING / CONFIRMED / CHECKED_IN`.
* Payments and refunds are append-only; invoice balances are derived, never typed in.

---

## 6. Roles & permissions

`Role` maps to a permission set in `domain/enums/Role.java`; `Permission` codes look like `booking:write`, `payment:read`.
Services call `accessService.assertPermission(...)` before mutations and `resolveHotelScope(...)` before reads, so the API
is authoritative — the UI only hides what it knows you cannot do.

| Role | Hotels | Highlights |
|---|---|---|
| `SUPER_ADMIN` | all | every permission, hotel CRUD, staff, audit |
| `HOTEL_MANAGER` | assigned | bookings, rooms, pricing, housekeeping, staff (own hotel), reports |
| `RECEPTIONIST` | assigned | front desk, check-in/out, guests, payments, services |
| `HOUSEKEEPING` | assigned | task board, room condition, maintenance, notifications |
| `ACCOUNTANT` | assigned | payments, invoices, refunds, expenses, reports |

Hotel-scope violations return **403**; cross-hotel record IDs return **404** (no existence leak).

---

## 7. Project layout

```
backend/src/main/java/com/hotelcrm/
├── common/      BaseEntity · PageResponse · ApiError · GlobalExceptionHandler · exceptions
├── config/      SecurityConfig · OpenApiConfig · FlywayConfig
├── controller/  20 REST controllers (122 endpoints)
├── domain/      25 entities + 36 enums (roles, permissions, statuses)
├── dto/         12 DTO holders with Bean Validation
├── repository/  24 Spring Data interfaces (+ Specifications for search)
├── security/    JWT filter, token service, user details, hotel access service, rate limiter
├── service/     21 transactional service classes (business rules live here)
└── util/        money/decimal math, rate math, AES field cipher, code generator

frontend/src/
├── components/  ui primitives · common widgets · layout (sidebar, topbar, guards) · booking dialogs
├── context/     AuthContext (JWT session) · HotelContext (hotel switcher)
├── lib/         axios client + refresh interceptor · typed endpoints · types · formatting · permissions
└── pages/       20 pages (dashboard, hotels, rooms, bookings, calendar, guests, payments, invoices,
                 expenses, housekeeping, staff, reports, notifications, audit, settings, login, 404)
```

---

## 8. Testing & quality gates

```bash
cd backend  && ./gradlew test        # JUnit 5 (money/rate math, context wiring)
cd frontend && npm run build         # tsc --noEmit + vite production build
```

The API surface is documented in [`docs/API.md`](docs/API.md); deployment (Docker, nginx, TLS, backups) in
[`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md); design decisions in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## 9. Roadmap hooks

Deliberate extension points, not missing features: notification delivery adapters (email/WhatsApp) behind
`NotificationService.dispatch`, OTA/channel-manager sync behind `BookingSource`, and multi-currency behind `MoneyUtils`.
