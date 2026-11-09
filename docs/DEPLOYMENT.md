# Deployment guide

Three supported shapes:

| Shape | Use case |
|---|---|
| **A. Local development** | Local MySQL 8, API via `./gradlew bootRun`, SPA via `npm run dev` |
| **B. Single server / VM** | MySQL 8 + Spring Boot JAR (`systemd`) + Nginx serving `dist/` and proxying `/api` |
| **C. Split / Cloud deployment** | Managed MySQL, API on an app server/JVM platform, static SPA on a CDN or Nginx |

---

## A. Local development

1. Create the MySQL 8 database and user:

```sql
CREATE DATABASE hotel_crm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'hotel_crm'@'localhost' IDENTIFIED BY 'hotel_crm';
GRANT ALL PRIVILEGES ON hotel_crm.* TO 'hotel_crm'@'localhost';
FLUSH PRIVILEGES;
```

2. Run the backend and frontend:

```bash
cd backend && ./gradlew bootRun                # :8080 · Flyway migrates + seeds
cd ../frontend && npm install && npm run dev   # :5173, proxies /api to :8080
```

* Swagger UI: <http://localhost:8080/swagger-ui.html>
* Health: <http://localhost:8080/actuator/health>
* If the login page shows “API server not reachable”, the backend (or MySQL) is not up yet.

---

## B. Single server / VM (systemd + Nginx)

### 1. Build artifacts

```bash
cd backend && ./gradlew clean bootJar -x test
cd ../frontend && npm ci && VITE_API_BASE_URL=/api npm run build
```

### 2. Required production environment (`/etc/hotel-crm/backend.env`)

```bash
SPRING_PROFILES_ACTIVE=prod
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=hotel_crm
DB_USERNAME=hotel_crm
DB_PASSWORD=...
JWT_SECRET=$(openssl rand -base64 48)          # >= 32 bytes
APP_ENCRYPTION_KEY=$(openssl rand -base64 32)  # 32-byte AES key for ID proofs
CORS_ALLOWED_ORIGINS=https://crm.example.com
APP_SEED_ENABLED=false
```

### 3. Run the API via `systemd` (`/etc/systemd/system/hotel-crm-backend.service`)

```ini
[Unit]
Description=Hotel CRM Spring Boot API
After=network.target mysql.service

[Service]
User=hotelcrm
WorkingDirectory=/opt/hotel-crm
EnvironmentFile=/etc/hotel-crm/backend.env
ExecStart=/usr/bin/java -XX:MaxRAMPercentage=75 -XX:+UseG1GC -jar /opt/hotel-crm/hotel-crm-backend-1.0.0.jar
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 4. Serve the SPA and reverse-proxy `/api` with Nginx

Copy `frontend/dist/*` to `/var/www/hotel-crm/` and configure Nginx:

```nginx
server {
    listen 80;
    server_name crm.example.com;
    root /var/www/hotel-crm;
    index index.html;

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location = /index.html {
        add_header Cache-Control "no-store";
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
        client_max_body_size 10m;
    }

    location /actuator/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

Because Nginx proxies `/api` to `127.0.0.1:8080`, the browser talks to one origin — no CORS setup is needed in this
shape. Terminate TLS with Certbot / Let's Encrypt or a cloud load balancer.

---

## C. Split / Cloud deployment

### Database
Managed MySQL 8 (RDS, Cloud SQL, Azure Database, etc.). Requirements:

* `utf8mb4` / `utf8mb4_unicode_ci`
* Timezone UTC
* A user with DDL rights for the first Flyway run (Flyway owns all schema changes; `ddl-auto=validate`)
* Backups: nightly snapshot + binlog/PITR

### API (JVM host)
```bash
cd backend
./gradlew clean bootJar -x test
java -XX:MaxRAMPercentage=75 -jar build/libs/hotel-crm-backend-*.jar
```
Set the environment variables from `backend/.env.example`, run with `SPRING_PROFILES_ACTIVE=prod`, and expose port 8080
only to your reverse proxy / load balancer.

Reverse proxy expectations:
* Forward `X-Forwarded-For` / `X-Forwarded-Proto` (Spring Boot runs with `forward-headers-strategy=framework`).
* Set `CORS_ALLOWED_ORIGINS` to the exact SPA origin (scheme + host, no trailing slash) when SPA and API are on different
  hosts — or serve both from the same origin and skip CORS entirely.

### SPA
```bash
cd frontend
VITE_API_BASE_URL=https://api.example.com/api npm run build   # or /api when proxied
# upload dist/ to Nginx / S3+CloudFront / Netlify / Vercel
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
| View API logs | `journalctl -u hotel-crm-backend -f` |
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
| `Communications link failure` at boot | MySQL down / wrong host | `sudo systemctl status mysql`, check `DB_HOST` and `DB_PORT` |
| `Schema-validation: missing table` | migrations not applied | ensure Flyway is enabled and `db/migration` is on the classpath |
| Login returns 401 for demo users | seeding disabled or profile `prod` | set `APP_SEED_ENABLED=true` for a demo environment |
| 403 on a screen that works for the owner | role lacks the permission or the hotel isn't assigned | adjust role/hotel assignment in Staff |
| 409 when booking | overlapping stay for that room | pick another room, or leave the room unassigned (auto-assign at check-in) |
| CORS error in the browser | SPA origin missing from `CORS_ALLOWED_ORIGINS` | add the exact origin and restart |
| PDF/Excel export opens garbage | endpoint requires the JWT header | use the app buttons or `curl -H "Authorization: Bearer …" -o file` |
