# Virgin Projekt

> Status: Beta – Diese Codebasis befindet sich derzeit im Beta-Zustand. Änderungen können brechend sein; Workflows und Struktur werden aktiv stabilisiert.

**Autor:** Felix Szakinnis

## Architektur

- **Frontend:** nginx (Docker Compose) serviert `web/public/` auf Port 8080
- **Backend (optional):** Express-API auf Port 3000 für `/api/*` Endpoints
- Statische Website läuft ohne Backend

## Quick Start

**Statische Website (nur Frontend):**
```bash
docker compose up -d
# Frontend (nginx): http://localhost:8080
```

**Optional: Backend für API-Endpoints:**
```bash
cd backend
npm install
npm run dev     # Dev-Server mit Hot-Reload auf Port 3000
```

## Verfügbare Seiten

- Homepage: `http://localhost:8080/` (statisch via nginx)
- API (optional, wenn Backend läuft): `http://localhost:3000/api/*`
- Legacy UI: `http://localhost:3000/ui/` (nur wenn Backend läuft)

## Backend Commands (optional)

```bash
cd backend
npm run dev      # Entwicklung mit Hot-Reload
npm start        # Start (Standardport 3000)
npm test         # Backend-Tests (Node built-in)
npm run info     # Projekt-Info anzeigen
```

## API Endpoints

- `GET  /api/hello` - Test-Endpoint
- `GET  /api/health` - Health-Check
- `POST /api/session/end` - Session beenden
- `POST /api/session/audit` - Session-Audit durchführen

## Troubleshooting

### Server läuft nicht

```bash
# Port prüfen
lsof -i :3000

# Prozesse beenden
bash /workspaces/virgin/scripts/server/kill-server.sh

# Neu starten
cd backend && npm run dev
```

### Keine Logs/Hinweise

- Stelle sicher, dass `npm run dev` (nicht `npm start`) läuft
- Prüfe ob `--watch` Flag aktiv ist
- Terminal-Ausgabe sollte Startup-Banner zeigen

### Browser öffnet nicht

```bash
# Manuell öffnen
$BROWSER http://localhost:3000

# Oder curl testen
curl http://localhost:3000/api/health
```

## Entwicklung

- Hot-Reload: Änderungen in `/src` und `/public` werden automatisch erkannt
- Logs: Morgan middleware zeigt alle Requests
- Session-Store: In-Memory (flüchtig, nur für Dev)

## Weitere Infos

- CHANGELOG: [CHANGELOG.md](CHANGELOG.md)
