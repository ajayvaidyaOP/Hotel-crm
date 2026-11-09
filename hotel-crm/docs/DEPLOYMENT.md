# Deployment guide

Three supported shapes:

| Shape | Use case |
|---|---|
| **A. Local development** | MySQL in Docker, API via `./gradlew bootRun`, SPA via `npm run dev` |
| **B. Single host (Docker Compose)** | MySQL + API + nginx in one `docker compose up` |
| **C. Split deployment** | Managed MySQL, API on an app server/JVM platform, static SPA on a CDN or nginx |

---

## A. Local development

```bash
cd hotel-crm
docker compose up -d                     # MySQL 8 (hotel_crm / hotel_crm)
cd backend && ./gradlew bootRun          # :8080 · Flyway migrates + seeds
cd ../frontend && npm install && npm run dev   # :5173, proxies /api to :8080
```

* Swagger UI: <http://localhost:8080/swagger-ui.html>
* Health: <http://localhost:8080/actuator/health>
* If the login page shows “API server not reachable”, the backend (or MySQL) is not up yet.

---

## B. Single host with Docker Compose

```bash
cd hotel-crm
cp backend/.env.example .env        # then edit the secrets below
docker compose -f docker-compose.full.yml up -d --build
# SPA on http://<host>/  ·  API behind the same origin at /api
```

Required secrets in `.env`:

```bash
JWT_SECRET=$(openssl rand -base64 48)          # >= 32 bytes
APP_ENCRYPTION_KEY=$(openssl rand -base64 32)  # 32-byte AES key for ID proofs
DB_ROOT_PASSWORD=...      DB_PASSWORD=...
CORS_ALLOWED_ORIGINS=https://crm.example.com
APP_SEED_ENABLED=false
```

Because nginx proxies `/api` to the `backend` service, the browser only talks to one origin — no CORS at all in this
shape. TLS terminates in front (Caddy/Traefik/cloud LB) or by adding certificates to nginx.

### What the Compose file does

1. `mysql` — MySQL 8, `utf8mb4`, UTC, persistent named volume, healthcheck.
2. `backend` — multi-stage build (`eclipse-temurin:21-jdk` → `21-jre`), waits for MySQL health, runs as a non-root user,
   `prod` profile (no demo seed), healthcheck on `/actuator/health`.
3. `frontend` — `npm ci && npm run build` then nginx serving `dist/` with SPA fallback, gzip, immutable asset caching and
   an `/api` reverse proxy.

---

## C. Split deployment

### Database
Managed MySQL 8 (RDS, Cloud SQL, Azure Database, PlanetScale-like). Requirements:

* `utf8mb4` / `utf8mb4_unicode_ci`
* Timezone UTC
* A user with DDL rights for the first Flyway run (Flyway owns all schema changes; `ddl-auto=validate`)
* Backups: nightly snapshot + binlog/PITR

### API (JVM host)
```bash
./gradlew clean bootJar -x test
java -XX:MaxRAMPercentage=75 -jar build/libs/hotel-crm-backend-*.jar
```
Set the environment variables from `backend/.env.example`, run with `SPRING_PROFILES_ACTIVE=prod`, and expose only 8080.

Reverse proxy expectations:
* Forward `X-Forwarded-For` / `X-Forwarded-Proto` (Spring Boot runs with `forward-headers-strategy=framework`).
* Set `CORS_ALLOWED_ORIGINS` to the exact SPA origin (scheme + host, no trailing slash) when SPA and API are on different
  hosts — or serve both from the same origin and skip CORS entirely.

### SPA
```bash
cd frontend
VITE_API_BASE_URL=https://api.example.com/api npm run build   # or /api when proxied
# upload dist/ to nginx / S3+CloudFront / Netlify / Vercel
```
Configure SPA fallback (`try_files $uri /index.html`) and cache `assets/*` immutably while serving `index.html` with
`no-store`.

---

## Hardening checklist

- [ ] `JWT_SECRET` and `APP_ENCRYPTION_KEY` are unique, ≥ 32 bytes, stored in a secret manager
- [ ] `APP_SEED_ENABLED=false` in production (otherwise demo users exist)
- [ ] Demo passwords rotated or demo users disabled (`PATCH /api/staff/{id}/status {"active":false}`)
- [ ] MySQL reachable only from the API subnet; strong password; least-privilege user
- [ ] TLS everywhere; HSTS at the edge
- [ ] `CORS_ALLOWED_ORIGINS` restricted to real origins
- [ ] Rate limits sized for the property (`LOGIN_RATE_LIMIT`, `API_RATE_LIMIT`)
- [ ] Automated MySQL backups + restore drill
- [ ] Log shipping; alert on 5xx rate and `/actuator/health` failures
- [ ] Audit log retention policy (append-only table, export quarterly)

---

## Operations

| Task | Command |
|---|---|
| View API logs | `docker compose -f docker-compose.full.yml logs -f backend` |
| Apply a new migration | add `V3__*.sql` to `backend/src/main/resources/db/migration`, redeploy (Flyway runs at boot) |
| Check schema drift | startup fails fast when `ddl-auto=validate` disagrees with Flyway — never "fix" it by switching to `update` |
| Rotate all sessions | `UPDATE users SET token_version = token_version + 1;` |
| Backup | `mysqldump --single-transaction --routines hotel_crm > backup-$(date +%F).sql` |
| Restore | `mysql hotel_crm < backup-2026-01-31.sql` then restart the API |

### Scaling notes

* The API is stateless (JWT), so run N instances behind a load balancer.
* Room locking uses row-level `SELECT … FOR UPDATE`, which is safe across instances sharing one MySQL.
* Reports aggregate in Java from indexed range queries; add covering indexes on
  `bookings(hotel_id, check_in_date, check_out_date)` if a property exceeds millions of bookings.
* Move notification delivery to a queue (the `NotificationService.dispatch` seam) when adding email/WhatsApp providers.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Communications link failure` at boot | MySQL down / wrong host | `docker compose ps`, check `DB_HOST` |
| `Schema-validation: missing table` | migrations not applied | ensure Flyway is enabled and `db/migration` is on the classpath |
| Login returns 401 for demo users | seeding disabled or profile `prod` | set `APP_SEED_ENABLED=true` for a demo environment |
| 403 on a screen that works for the owner | role lacks the permission or the hotel isn't assigned | adjust role/hotel assignment in Staff |
| 409 when booking | overlapping stay for that room | pick another room, or leave the room unassigned (auto-assign at check-in) |
| CORS error in the browser | SPA origin missing from `CORS_ALLOWED_ORIGINS` | add the exact origin and restart |
| PDF/Excel export opens garbage | endpoint requires the JWT header | use the app buttons or `curl -H "Authorization: Bearer …" -o file` |
