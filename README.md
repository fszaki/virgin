# Virgin Projekt (API + UI)

Ordnerstruktur:
- backend: Express-API + statische UI (HTML/JS/CSS)
- scripts: Server-Management-Skripte
- .gitignore: Ignoriert Node-Outputs

## Web-Struktur (neu)

- `web/views/` – serverseitig ausgelieferte Seiten: `/, /landing, /statistik`
- `web/public/` – statische Assets (HTML/CSS/JS)
- `frontend/` – veraltet (nur noch README vorhanden)

## Schnellstart

```bash
cd /workspaces/virgin/backend
npm install
npm start
```

Optional: `"$BROWSER" http://localhost:3000` öffnen

Direktaufrufe:
- Views: `http://localhost:3000/`, `http://localhost:3000/landing`, `http://localhost:3000/statistik`
- Legacy-UI (Backend Demo): `http://localhost:3000/ui/`

## Verfügbare Commands

```bash
npm run dev      # Entwicklung mit Hot-Reload
npm start        # Start (Standardport 3000)
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
