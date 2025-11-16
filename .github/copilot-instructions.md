# Copilot Instructions for This Repo

Purpose: Give AI coding agents the minimum, concrete context to be productive here. Document actual patterns used in this codebase, not aspirations.

## Big Picture
- Server-first setup. Primary runtime is `backend/` (Express on port 3000). Static assets live in `web/public/`. Legacy folders (`app/`, `frontend/`) are deprecated.
- API + static delivery in one service:
  - API: JSON under `/api/*` (e.g., `/api/health`, `/api/stats`, session endpoints)
  - Static: `web/public` is served at `/` via `express.static(...)`
  - Legacy static UI (kept for demos): `backend/public` mounted under `/ui/`
- Views: The server routes map `/`, `/landing`, `/statistik` to files in `web/views` (now present). Static homepage also exists at `web/public/index.html`.

Key files:
- Backend entry: `backend/src/server.js` (ESM)
- Session logic & validation: `backend/src/session.js`
- Static assets: `web/public/`
- Legacy static: `backend/public/` (served at `/ui/...`)
- Scripts (Docker Compose start/stop): `scripts/server/*.sh`

## Run & Debug
- Local dev (hot reload):
  ```bash
  cd backend
  npm install
  npm run dev   # node --watch src/server.js (port 3000)
  ```
- Standard start:
  ```bash
  cd backend
  npm start
  ```
- Health checks:
  - `GET /api/health` → `{ status: "ok" }`
  - `GET /healthz` → `{ status, uptime, timestamp }`
- Optional (Docker Compose, starts backend:3000 and nginx:8080):
  ```bash
  ./scripts/server/start-server.sh
  ./scripts/server/restart-servers.sh
  ./scripts/server/kill-server.sh
  ```
  Note: `frontend/` is deprecated; `docker-compose.yml` still mounts `./frontend/public` (may be empty). Prefer `web/public` in the unified structure.
  Compose is updated to mount `./web/public` for the nginx frontend.

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
- Modules: ES Modules in `backend/` (`type: module`), use `import ... from`.
- Routing style: Route handlers live in `backend/src/server.js` (no separate router modules yet). Keep endpoint list in the startup banner updated when adding routes.
- Static files:
  - Place assets in `web/public` → available directly under `/` (e.g., `/styles.css`)
  - Legacy demo UI under `/ui/*` from `backend/public`
- Errors: Use HTTP 400 with `{ error: string }` for validation failures.
- Ports: Default `PORT=3000` (can be overridden via env var).

## What NOT to use
- `app/` is legacy (CommonJS + interactive prompt). `app/package.json` intentionally exits for `start/dev`.
- `frontend/` is deprecated. Prefer `web/public` (and `web/views` if you add view files).
- The top-level `src/` (controllers/routes/etc.) is not wired into the running backend — do not place new backend code there.

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
