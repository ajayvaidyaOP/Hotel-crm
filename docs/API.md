# API reference

Base URL: `http://localhost:8080` · Interactive docs: `/swagger-ui.html` · OpenAPI JSON: `/v3/api-docs`

**122 endpoints** across 20 controllers. All routes are prefixed with `/api`, require
`Authorization: Bearer <accessToken>` (except `/api/auth/login`, `/api/auth/refresh`,
`/api/auth/forgot-password`, `/api/auth/reset-password`) and are rate limited
(`LOGIN_RATE_LIMIT` login attempts/min, `API_RATE_LIMIT` requests/min per IP+user).

---

## Authentication flow

```
POST /api/auth/login          { email, password }  ->  { accessToken, refreshToken, expiresIn, user }
GET  /api/auth/me                                   ->  profile, role, permissions[], hotels[]
POST /api/auth/refresh        { refreshToken }      ->  new access + refresh pair (rotated)
POST /api/auth/change-password{ currentPassword, newPassword } -> revokes other sessions
POST /api/auth/forgot-password{ email }             ->  always 200 (no account enumeration)
POST /api/auth/reset-password { token, newPassword }
POST /api/auth/logout                               ->  increments token version
```

* Access tokens are HMAC-SHA256 JWTs (`sub` = user id, `role`, `tv` = token version).
* Changing a password or resetting it bumps `users.token_version`, instantly invalidating every refresh token.
* The SPA stores tokens in `localStorage` and transparently refreshes once on a `401` before redirecting to `/login`.

## Response conventions

| Case | Status | Body |
|---|---|---|
| Success | 200 / 201 / 204 | resource or `MessageResponse` |
| Validation failure | 400 | `{ "status":400, "message":"Validation failed", "fieldErrors": { "mobile":"…" } }` |
| Business rule | 400 | `{ "status":400, "message":"<explanation>" }` |
| Unauthenticated | 401 | `{ "status":401, "message":"Invalid credentials" }` |
| Forbidden (role or hotel scope) | 403 | `{ "status":403, "message":"You do not have permission…" }` |
| Not found / cross-hotel access | 404 | `{ "status":404, "message":"…not found" }` |
| Double booking / duplicate | 409 | `{ "status":409, "message":"Room 204 is already booked for those dates" }` |
| Server error | 500 | `{ "status":500, "message":"Unexpected error" }` |

Paginated endpoints return:

```json
{ "content": [], "page": 0, "size": 20, "totalElements": 40, "totalPages": 2, "last": false }
```

Dates are ISO-8601 (`2026-11-01`), timestamps are ISO instants in UTC. Money is decimal (INR, 2 dp).

## Filtering cheat-sheet

| Endpoint | Query parameters |
|---|---|
| `GET /api/bookings` | `hotelId, status (repeatable), paymentStatus, source, from, to, search, page, size` |
| `GET /api/bookings/calendar` | `hotelId, from, to` (required) |
| `GET /api/bookings/day-operations` | `hotelId, date` |
| `GET /api/rooms` | `hotelId, categoryId, status, housekeeping, floor, search` |
| `GET /api/guests` | `search, category, vip, hotelId, page, size` |
| `GET /api/payments` | `hotelId, from, to, method, search, page, size` |
| `GET /api/invoices` | `hotelId, from, to, status, search, page, size` |
| `GET /api/expenses` | `hotelId, from, to, category, search, page, size` |
| `GET /api/reports/*` | `hotelId, from, to` |
| `GET /api/reports/export` | `report (revenue\|occupancy\|profit\|cancellations\|pending-payments), format (csv\|xlsx\|pdf), hotelId, from, to` |
| `GET /api/audit-logs` | `hotelId, action, page, size` |

## Financial & operational rules enforced by the API

1. **No double booking** — overlap query + `SELECT … FOR UPDATE` on the room row; conflicting requests get `409`.
2. **Rate snapshot** — the nightly rate at booking time is stored on the booking segment; later rate-plan edits never
   rewrite past folios.
3. **Billing invariant** — `paidAmount = Σ SUCCESS payments − Σ COMPLETED refunds`; overpayment and over-refund are
   rejected, cancelled bookings cannot receive payments.
4. **Check-out** — generates an invoice from room nights + services + extras − discount + GST, optionally settles it, then
   moves the room to `CLEANING` and creates a housekeeping task.
5. **Housekeeping** — `IN_PROGRESS → DIRTY`, `COMPLETED → CLEAN`, `INSPECTED → INSPECTED` (room back to `AVAILABLE` if it
   was `CLEANING`).
6. **Maintenance** — opening a request on a room marks it `MAINTENANCE` (occupied rooms rejected); resolving returns the
   room to `AVAILABLE` + `DIRTY` and notifies housekeeping.
7. **Services** — can only be added while the booking is `CHECKED_IN`; they are billed to the room and appear on the invoice.
8. **Coupons** — validated on booking creation (window, minimum amount, usage cap, max discount); deleting a used coupon
   deactivates it instead of removing history.

---

## Endpoints

### Audit logs

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/audit-logs` | `PageResponse<AuditLog>` |

### Authentication

| Method | Endpoint | Returns |
|---|---|---|
| `POST` | `/api/auth/change-password` | `AuthDtos.MessageResponse` |
| `POST` | `/api/auth/forgot-password` | `AuthDtos.MessageResponse` |
| `POST` | `/api/auth/login` | `AuthDtos.TokenResponse` |
| `POST` | `/api/auth/logout` | `ResponseEntity<AuthDtos.MessageResponse>` |
| `GET` | `/api/auth/me` | `AuthDtos.MeResponse` |
| `PUT` | `/api/auth/me` | `AuthDtos.MeResponse` |
| `POST` | `/api/auth/refresh` | `AuthDtos.TokenResponse` |
| `POST` | `/api/auth/reset-password` | `AuthDtos.MessageResponse` |

### Bookings

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/bookings` | `PageResponse<BookingDtos.Summary>` |
| `POST` | `/api/bookings` | `BookingDtos.Response` |
| `GET` | `/api/bookings/calendar` | `BookingDtos.CalendarResponse` |
| `GET` | `/api/bookings/day-operations` | `BookingDtos.DayOperations` |
| `GET` | `/api/bookings/{id}` | `BookingDtos.Response` |
| `PUT` | `/api/bookings/{id}` | `BookingDtos.Response` |
| `POST` | `/api/bookings/{id}/cancel` | `BookingDtos.Response` |
| `POST` | `/api/bookings/{id}/check-in` | `BookingDtos.Response` |
| `POST` | `/api/bookings/{id}/check-out` | `BookingDtos.CheckOutResponse` |
| `POST` | `/api/bookings/{id}/reschedule` | `BookingDtos.Response` |
| `GET` | `/api/bookings/{id}/services` | `List<OpsDtos.ServiceOrderResponse>` |
| `POST` | `/api/bookings/{id}/transfer-room` | `BookingDtos.Response` |

### Coupons

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/coupons` | `List<OpsDtos.CouponResponse>` |
| `POST` | `/api/coupons` | `OpsDtos.CouponResponse` |
| `DELETE` | `/api/coupons/{id}` | `void` |
| `PUT` | `/api/coupons/{id}` | `OpsDtos.CouponResponse` |

### Dashboard

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/dashboard` | `DashboardDtos.DashboardResponse` |
| `GET` | `/api/dashboard/hotel-comparison` | `List<HotelDtos.HotelStats>` |

### Expenses

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/expenses` | `PageResponse<OpsDtos.ExpenseResponse>` |
| `POST` | `/api/expenses` | `OpsDtos.ExpenseResponse` |
| `GET` | `/api/expenses/summary` | `List<DashboardDtos.NamedValue>` |
| `DELETE` | `/api/expenses/{id}` | `void` |
| `PUT` | `/api/expenses/{id}` | `OpsDtos.ExpenseResponse` |

### Guest feedback

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/feedback` | `List<OpsDtos.FeedbackRow>` |
| `POST` | `/api/feedback` | `OpsDtos.FeedbackRow` |
| `POST` | `/api/feedback/{id}/resolve` | `OpsDtos.FeedbackRow` |

### Global search

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/search` | `List<NotificationDtos.GlobalSearchResult>` |

### Guest CRM

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/guests` | `PageResponse<GuestDtos.Response>` |
| `POST` | `/api/guests` | `GuestDtos.Response` |
| `GET` | `/api/guests/{id}` | `GuestDtos.Detail` |
| `PUT` | `/api/guests/{id}` | `GuestDtos.Response` |
| `GET` | `/api/guests/{id}/feedback` | `List<GuestDtos.FeedbackResponse>` |
| `GET` | `/api/guests/{id}/services` | `List<OpsDtos.ServiceOrderResponse>` |

### Hotels

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/hotels` | `List<HotelDtos.Response>` |
| `POST` | `/api/hotels` | `HotelDtos.Response` |
| `DELETE` | `/api/hotels/{id}` | `void` |
| `GET` | `/api/hotels/{id}` | `HotelDtos.Response` |
| `PUT` | `/api/hotels/{id}` | `HotelDtos.Response` |
| `PATCH` | `/api/hotels/{id}/status` | `HotelDtos.Response` |

### Housekeeping

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/housekeeping` | `List<OpsDtos.HousekeepingResponse>` |
| `POST` | `/api/housekeeping` | `OpsDtos.HousekeepingResponse` |
| `GET` | `/api/housekeeping/my-tasks` | `List<OpsDtos.HousekeepingResponse>` |
| `DELETE` | `/api/housekeeping/{id}` | `void` |
| `PATCH` | `/api/housekeeping/{id}/status` | `OpsDtos.HousekeepingResponse` |

### Invoices

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/invoices` | `PageResponse<PaymentDtos.InvoiceResponse>` |
| `POST` | `/api/invoices` | `PaymentDtos.InvoiceResponse` |
| `GET` | `/api/invoices/booking/{bookingId}` | `List<PaymentDtos.InvoiceResponse>` |
| `GET` | `/api/invoices/{id}` | `PaymentDtos.InvoiceResponse` |
| `POST` | `/api/invoices/{id}/cancel` | `PaymentDtos.InvoiceResponse` |
| `POST` | `/api/invoices/{id}/settle` | `PaymentDtos.InvoiceResponse` |

### Maintenance & lost & found

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/lost-found` | `List<OpsDtos.LostFoundResponse>` |
| `POST` | `/api/lost-found` | `OpsDtos.LostFoundResponse` |
| `PATCH` | `/api/lost-found/{id}/status` | `OpsDtos.LostFoundResponse` |
| `GET` | `/api/maintenance` | `List<OpsDtos.MaintenanceResponse>` |
| `POST` | `/api/maintenance` | `OpsDtos.MaintenanceResponse` |
| `PUT` | `/api/maintenance/{id}` | `OpsDtos.MaintenanceResponse` |

### Notifications

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/notifications` | `List<NotificationDtos.Response>` |
| `POST` | `/api/notifications/read-all` | `NotificationDtos.CountResponse` |
| `GET` | `/api/notifications/severities` | `List<String>` |
| `GET` | `/api/notifications/types` | `List<String>` |
| `GET` | `/api/notifications/unread-count` | `NotificationDtos.CountResponse` |
| `POST` | `/api/notifications/{id}/read` | `NotificationDtos.CountResponse` |

### Payments

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/payments` | `PageResponse<PaymentDtos.Response>` |
| `POST` | `/api/payments` | `PaymentDtos.Response` |
| `GET` | `/api/payments/booking/{bookingId}` | `List<PaymentDtos.Response>` |
| `GET` | `/api/payments/pending` | `List<PaymentDtos.PendingPaymentRow>` |
| `GET` | `/api/payments/refunds` | `List<PaymentDtos.RefundResponse>` |
| `POST` | `/api/payments/refunds` | `PaymentDtos.RefundResponse` |
| `GET` | `/api/payments/summary` | `PaymentDtos.FinancialSummary` |

### Pricing

| Method | Endpoint | Returns |
|---|---|---|
| `POST` | `/api/hotels/{hotelId}/pricing/quote` | `RoomDtos.QuoteResponse` |
| `GET` | `/api/hotels/{hotelId}/rate-plans` | `List<RoomDtos.RatePlanResponse>` |
| `POST` | `/api/hotels/{hotelId}/rate-plans` | `RoomDtos.RatePlanResponse` |
| `DELETE` | `/api/hotels/{hotelId}/rate-plans/{id}` | `void` |
| `PUT` | `/api/hotels/{hotelId}/rate-plans/{id}` | `RoomDtos.RatePlanResponse` |

### Reports & analytics

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/reports/bundle` | `ReportDtos.ReportBundle` |
| `GET` | `/api/reports/cancellations` | `List<ReportDtos.CancellationRow>` |
| `GET` | `/api/reports/categories` | `List<ReportDtos.CategoryRow>` |
| `GET` | `/api/reports/expenses` | `List<ReportDtos.ExpenseRow>` |
| `GET` | `/api/reports/kpi` | `ReportDtos.KpiResponse` |
| `GET` | `/api/reports/occupancy` | `List<ReportDtos.OccupancyRow>` |
| `GET` | `/api/reports/pending-payments` | `List<PaymentDtos.PendingPaymentRow>` |
| `GET` | `/api/reports/profit` | `List<ReportDtos.ProfitRow>` |
| `GET` | `/api/reports/revenue` | `List<ReportDtos.RevenueRow>` |

### Rooms & categories

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/hotels/{hotelId}/room-categories` | `List<RoomDtos.CategoryResponse>` |
| `POST` | `/api/hotels/{hotelId}/room-categories` | `RoomDtos.CategoryResponse` |
| `POST` | `/api/hotels/{hotelId}/rooms` | `RoomDtos.RoomResponse` |
| `GET` | `/api/hotels/{hotelId}/rooms/availability` | `List<RoomDtos.AvailabilityResponse>` |
| `POST` | `/api/hotels/{hotelId}/rooms/bulk` | `List<RoomDtos.RoomResponse>` |
| `DELETE` | `/api/room-categories/{id}` | `void` |
| `PUT` | `/api/room-categories/{id}` | `RoomDtos.CategoryResponse` |
| `GET` | `/api/rooms` | `List<RoomDtos.RoomResponse>` |
| `DELETE` | `/api/rooms/{id}` | `void` |
| `GET` | `/api/rooms/{id}` | `RoomDtos.RoomResponse` |
| `PUT` | `/api/rooms/{id}` | `RoomDtos.RoomResponse` |
| `GET` | `/api/rooms/{id}/history` | `List<BookingDtos.TimelineEntry>` |
| `PATCH` | `/api/rooms/{id}/status` | `RoomDtos.RoomResponse` |

### Services (restaurant, laundry, minibar)

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/services` | `List<OpsDtos.ServiceOrderResponse>` |
| `POST` | `/api/services` | `OpsDtos.ServiceOrderResponse` |
| `DELETE` | `/api/services/{id}` | `void` |
| `PATCH` | `/api/services/{id}/status` | `OpsDtos.ServiceOrderResponse` |

### Staff management

| Method | Endpoint | Returns |
|---|---|---|
| `GET` | `/api/staff` | `List<UserDtos.Response>` |
| `POST` | `/api/staff` | `UserDtos.Response` |
| `GET` | `/api/staff/attendance` | `List<UserDtos.AttendanceResponse>` |
| `POST` | `/api/staff/attendance` | `UserDtos.AttendanceResponse` |
| `GET` | `/api/staff/attendance/summary` | `UserDtos.AttendanceSummary` |
| `GET` | `/api/staff/{id}` | `UserDtos.Response` |
| `PUT` | `/api/staff/{id}` | `UserDtos.Response` |
| `GET` | `/api/staff/{id}/activity` | `PageResponse<AuditLog>` |
| `POST` | `/api/staff/{id}/reset-password` | `void` |
| `PATCH` | `/api/staff/{id}/status` | `UserDtos.Response` |

---

## Example session

```bash
# 1. Sign in
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"owner@hotelgroup.com","password":"Owner@123"}' | jq -r .accessToken)

# 2. Hotel portfolio with live stats
curl -s http://localhost:8080/api/hotels -H "Authorization: Bearer $TOKEN" | jq '.[].name'

# 3. Group dashboard (last 30 days)
curl -s "http://localhost:8080/api/dashboard?from=2026-10-01&to=2026-10-31" \
  -H "Authorization: Bearer $TOKEN" | jq '{occupancyPercent, monthlyRevenue, pendingPayments}'

# 4. Nightly quote for a category
curl -s -X POST http://localhost:8080/api/hotels/1/pricing/quote \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"categoryId":1,"checkIn":"2026-11-10","checkOut":"2026-11-13","adults":2,"children":0}'

# 5. Create a booking (guest created inline, room auto-assigned)
curl -s -X POST http://localhost:8080/api/bookings \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"hotelId":1,"newGuest":{"fullName":"Asha Rao","mobile":"+919812345678"},
       "checkInDate":"2026-11-10","checkOutDate":"2026-11-13","adults":2,"children":0,
       "bookingSource":"DIRECT","status":"CONFIRMED","rooms":[{"categoryId":1,"extraBeds":0}],
       "advanceAmount":5000,"advanceMethod":"UPI"}'

# 6. Export the revenue report as Excel
curl -s -o revenue.xlsx "http://localhost:8080/api/reports/export?report=revenue&format=xlsx&from=2026-10-01&to=2026-10-31" \
  -H "Authorization: Bearer $TOKEN"
```
