# Architecture notes

## Layers

```
Controller  →  DTO mapping + Bean Validation + @Tag docs
   ↓
Service     →  authorisation (permission + hotel scope), transactions, business rules
   ↓
Repository  →  Spring Data JPA (derived queries, @Query aggregates, Specifications for search)
   ↓
Entity      →  JPA mappings, BaseEntity (id, createdAt, updatedAt, optimistic-safe updates)
   ↓
MySQL 8     →  Flyway-owned schema (28 tables), utf8mb4, InnoDB, FK constraints
```

Controllers never touch entities directly except read-only audit payloads; services own every mutation and always call
`HotelAccessService` first. This is why the API — not the UI — is the security boundary.

## Multi-tenancy by hotel

* Every tenant-owned table carries `hotel_id` (directly or through its booking/room parent).
* `HotelAccessService` resolves the caller's hotel scope once per request:
  `SUPER_ADMIN → all hotels`, everyone else → the rows in `hotel_staff` for that user.
* Reads pass `List<Long> hotelIds` into queries; writes call `assertHotelAccess(hotelId)`.
* Cross-hotel IDs are reported as **404**, so a manager cannot probe other properties' record ids.
* Aggregate queries accept `hotelIds` and use `IN (:hotelIds)`; group-level screens pass the full accessible set.

## Concurrency & data integrity

| Risk | Mitigation |
|---|---|
| Double booking | overlap query **plus** `RoomRepository.findByIdForUpdate` (`PESSIMISTIC_WRITE`) inside the same transaction; unique room-number constraint per hotel |
| Concurrent payments | amounts are recomputed from the ledger inside the transaction, never from the request body |
| Lost updates on counters | coupon `usedCount` and booking totals are mutated only inside transactional services |
| Stale JWT after offboarding | `users.token_version` is embedded in the token; bumping it invalidates refresh tokens |
| Schema drift | `ddl-auto=validate` + Flyway: startup fails instead of silently altering columns |

## Money handling

`BigDecimal` everywhere with `MoneyUtils` (2 dp, HALF_UP). Rates, taxes, discounts and refunds never pass through
`double`. `RateMath` centralises percentage/ratio maths for ADR, RevPAR, occupancy and margins.

## Booking model

```
Booking (1) ──< BookingRoom (segment, 0..n rooms per booking)
                     │
                     ├── room      (nullable until assignment)
                     ├── category  (what was sold)
                     ├── checkIn/checkOut (may differ per segment → room moves)
                     └── ratePerNight, totalAmount  (snapshotted)
```

* A room may be left unassigned; availability is validated on save and re-validated at check-in/transfer.
* Changing rooms mid-stay adds/edits a segment instead of rewriting history, so invoices and receipts stay truthful.
* `HOLDING_STATUSES = PENDING, CONFIRMED, CHECKED_IN` are the statuses that participate in overlap checks.

## Pricing engine

`PricingService.quote(category, from, to, adults, children)` walks **each night** independently:

1. Start from the category base rate (or room override).
2. Apply weekend rate when the night is Fri/Sat (hotel timezone).
3. Apply matching rate plans (date window, days-of-week, category/room scope) ordered by `priority`; the first match wins.
4. Add extra-person charges above base occupancy.
5. Return a per-night breakdown plus totals — the UI shows exactly how the number was produced, and the booking stores the
   resolved nightly rates.

## Documents

`DocumentService` renders PDFs with OpenPDF (booking receipt, GST invoice, report exports) and XLSX with Apache POI.
Exports stream as `byte[]` with `Content-Disposition` filenames and are permission-checked like any other read.

## Frontend architecture

* **TanStack Query** owns server state (caching, invalidation, retries); local component state is UI-only.
* Query keys are hierarchical (`['bookings', filters]`, `['booking', id]`), so mutations invalidate precisely.
* **Axios interceptor** attaches the bearer token and performs a single-flight refresh on `401`, then retries the request.
* **AuthContext** restores the session on reload via `/auth/me`; **HotelContext** persists the selected hotel (or group
  view) and re-scopes every page.
* Route guards (`ProtectedRoute`) check the permission code from `MeResponse.permissions`; the same codes are enforced by
  the API.
* Design system: navy/white/blue tokens in `index.css` + `tailwind.config.ts`, shadcn-style primitives on Radix, Recharts
  for analytics, Sonner for toasts, and consistent loading / empty / error states on every data surface.

## Why these choices

| Decision | Reason |
|---|---|
| Separate frontend and backend apps | independent deploys, cacheable static assets, strict API contract |
| Flyway over Hibernate DDL | reviewable, repeatable migrations; `validate` catches drift in CI and at boot |
| Service-layer RBAC | the browser is untrusted; every endpoint re-checks permission + hotel scope |
| Segment-per-room bookings | real hotels move guests between rooms; history and invoices must remain accurate |
| Derived billing | invoice balances and payment statuses are computed from the ledger, so they cannot desynchronise |
