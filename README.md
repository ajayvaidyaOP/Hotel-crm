# Hotel-crm

Multi-hotel management CRM — a production-shaped **Spring Boot 3 (Java 21)** API plus a **React 18 + Vite + TypeScript** console for running five (or fifty) properties from one account.

```
Hotel-crm/
└── hotel-crm/
    ├── backend/    Spring Boot 3.3 · Java 21 · MySQL 8 · Flyway · JWT · Gradle
    ├── frontend/   React 18 · Vite 5 · TypeScript · Tailwind · TanStack Query · Recharts
    ├── docs/       API reference, deployment and architecture notes
    └── docker-compose.yml
```

👉 **Start here: [`hotel-crm/README.md`](hotel-crm/README.md)** — features, quick start, demo accounts and configuration.

## TL;DR

```bash
cd hotel-crm
docker compose up -d                     # MySQL 8 on :3306
cd backend && ./gradlew bootRun          # API on :8080 (Flyway migrations + demo seed)
cd ../frontend && npm install && npm run dev   # UI on :5173
```

Sign in with `owner@hotelgroup.com` / `Owner@123` (owner of all five demo hotels) or `manager.goa@hotelgroup.com` / `Hotel@123` (restricted to one hotel).

## What is inside

- **Multi-hotel isolation** — every query is scoped by `hotel_id`; a hotel manager can only ever touch assigned properties (enforced in the service layer, not the UI).
- **Front desk** — bookings with double-booking prevention (date-overlap check + pessimistic room lock), check-in/out, room transfer, reschedule, receipts, drag-and-drop calendar.
- **Billing** — GST invoices, partial payments, refunds, expense tracking, PDF/Excel/CSV exports.
- **Operations** — housekeeping board, maintenance, lost & found, staff attendance, audit logs, notifications, global search.
- **Analytics** — dashboard KPIs (occupancy, ADR, RevPAR, revenue, profit) computed live from MySQL.

Full documentation: [`hotel-crm/README.md`](hotel-crm/README.md) · API: [`hotel-crm/docs/API.md`](hotel-crm/docs/API.md) · Deployment: [`hotel-crm/docs/DEPLOYMENT.md`](hotel-crm/docs/DEPLOYMENT.md)
