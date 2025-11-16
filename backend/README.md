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

- `GET  /` → `web/views/index.html`
- `GET  /landing` → `web/views/landing.html`
- `GET  /statistik` → `web/views/statistik.html`
- `GET  /ui/` → Legacy Backend UI (statisch aus `backend/public`)
- `GET  /api/hello`
- `GET  /api/health`
- `GET  /healthz`
- `GET  /api/stats`
- `POST /api/session/end`
- `POST /api/session/audit`

## 📂 Relevante Pfade

- Statisch: `../web/public` (über Root erreichbar, z. B. `/styles.css`)
- Views: `../web/views` (werden durch Routen ausgeliefert)

## 🧪 Tipps

- Portkonflikt? Mit `PORT=3001 npm start` ausweichen
- Health-Check: `curl http://localhost:3000/healthz`
