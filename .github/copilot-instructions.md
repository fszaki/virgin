# Copilot Instructions for This Repo

Purpose: Give AI coding agents the minimum, concrete context to be productive here. Document actual patterns used in this codebase, not aspirations.

## Big Picture
- **Frontend-first setup:** nginx (via Docker Compose) serves static site from `web/public/` on port 8080
- **Backend (optional):** Express on port 3000 for API endpoints only
- Static site runs independently without backend
- API endpoints (when backend runs):
  - JSON under `/api/*` (e.g., `/api/health`, `/api/stats`, session endpoints)
  - Static: `web/public` served at `/` via `express.static(...)`
  - Legacy UI: `backend/public` mounted under `/ui/`
- No server-side views - single `web/public/index.html` homepage

Key files:
- Backend entry: `backend/src/server.js` (ESM)
- Session logic & validation: `backend/src/session.js`
- Static assets: `web/public/`
- Legacy static: `backend/public/` (served at `/ui/...`)
- Scripts (Docker Compose start/stop): `scripts/server/*.sh`

## Run & Debug
- Frontend only (recommended for static site):
  ```bash
  docker compose up -d  # nginx on port 8080
  ```
- Backend (optional, for API):
  ```bash
  cd backend
  npm install
  npm run dev   # node --watch src/server.js (port 3000)
  ```
- Health checks (backend only):
  - `GET /api/health` → `{ status: "ok" }`
  - `GET /healthz` → `{ status, uptime, timestamp }`
- Helper scripts:
  ```bash
  ./scripts/server/start-server.sh     # Start frontend via Compose
  ./scripts/server/kill-server.sh      # Stop all services
  ./scripts/utils/check-ports.sh       # Check port availability
  ```

## API Essentials
- Patterns (see `backend/src/server.js`):
  - JSON responses for success; errors respond with HTTP 400 and `{ error: message }`
  - Request counting and basic logging via `morgan('dev')`
- Endpoints implemented:
  - `GET /api/hello` → greeting with timestamp
  - `GET /api/health` and `GET /healthz` → health status
  - `GET /api/stats` → process/server stats (reads version from `backend/package.json` if present)
  - `POST /api/session/end` → uses `session_end(sessionId, { reason })`
  - `POST /api/session/audit` → uses `session_audit(sessionId, { docs, structures, statistics|rows|data })`
- Validation utilities (in `backend/src/session.js`):
  - `validate_documentations(docs)` enforces `{ title, version (semver), lastUpdated (ISO), sections[] }`
  - `validate_structures(structures)` validates tree nodes `{ id, name, children[] }`
  - `compute_statistics(rows)` aggregates numeric fields across rows

## Conventions
- **Static site:** All assets in `web/public/` (HTML, CSS, images) served by nginx on port 8080
- **Backend (optional):** ES Modules in `backend/` (`type: module`), use `import ... from`
- Routing style: API handlers in `backend/src/server.js`, no separate routers
- Static files:
  - Primary: `web/public/` → served by nginx and express.static
  - Legacy demo UI: `backend/public` under `/ui/*`
- Errors: HTTP 400 with `{ error: string }` for validation failures
- Ports: Frontend 8080 (nginx), Backend 3000 (Express, optional)

## What NOT to use
- `app/` is legacy (CommonJS + interactive prompt). `app/package.json` intentionally exits for `start/dev`.
- Top-level `src/`, `bin/`, `frontend/` are deprecated and removed. Use `backend/src/` and `web/` instead.

## Adding Features (Examples)
- New static page: add `web/public/xyz.html` → reachable at `/xyz.html` (no code change needed).
- New view route: add `web/views/landing.html` and a route in `backend/src/server.js`:
  ```js
  app.get('/landing', (_req, res) => res.sendFile(path.join(__dirname, '..', '..', 'web', 'views', 'landing.html')));
  ```
- New API route: define handler in `backend/src/server.js`, return JSON; log in startup banner.
- Session validation: reuse `validate_documentations`, `validate_structures`, `compute_statistics` helpers; see how `session_audit` composes them.

## Dependencies (actual)
- Node >= 18, Express ^4.21, `morgan`, `cors` (see `backend/package.json`). Prefer actual `package.json` over docs if they diverge.

## Testing
- Uses Node's built-in test runner. Example:
  ```bash
  cd backend
  npm test
  ```
- Sample tests live in `backend/test/session.test.js` covering `session.js` helpers.

## Troubleshooting
- Port busy: `lsof -i :3000` then `./scripts/server/kill-server.sh`
- Server not reachable: ensure `npm run dev` or `npm start` is running in `backend/`; check `/api/health`.
- Views 404: if `web/views` files are missing, open `/index.html` from `web/public` or add the missing view files.
