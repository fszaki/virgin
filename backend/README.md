# 🧰 Backend (Express)

Kurze Anleitung und Referenz für den Express-Server.

## 🚀 Quick Start

```bash
cd /workspaces/virgin/backend
npm install
npm start
```

Entwicklung mit Hot-Reload:

```bash
cd /workspaces/virgin/backend
npm run dev
```

Optional: Browser öffnen

```bash
"$BROWSER" http://localhost:3000
```

## 📜 Scripts

- `npm start`: Server starten
- `npm run dev`: Entwicklung mit Watch-Mode
- `npm run info`: Projektinfo ausgeben

## 🌐 Endpoints

- `GET  /` → Statische Dateien aus `web/public` (via express.static)
- `GET  /ui/` → Legacy Backend UI (statisch aus `backend/public`)
- `GET  /api/hello` → Test-Endpoint
- `GET  /api/health` → Health-Check (JSON)
- `GET  /healthz` → Health-Check mit Uptime
- `GET  /api/stats` → Server-Statistiken
- `POST /api/session/end` → Session beenden
- `POST /api/session/audit` → Session-Audit

## 📂 Relevante Pfade

- Statisch: `../web/public` (über Root erreichbar, z. B. `/styles.css`)
- Views: `../web/views` (werden durch Routen ausgeliefert)

## 🧪 Tipps

- Portkonflikt? Mit `PORT=3001 npm start` ausweichen
- Health-Check: `curl http://localhost:3000/healthz`
