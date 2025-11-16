# Changelog

Alle nennenswerten Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

## [2025-11-16]

- Neu: Zentrale Startseite `index.html` im Projekt-Root als Navigation.
- Neu: Vereinheitlichte Web-Struktur unter `web/` mit `web/views/` (Seiten) und `web/public/` (statische Assets).
- Backend: Routen für `GET /`, `GET /landing`, `GET /statistik` liefern Views aus `web/views/`.
- Backend: Legacy-UI aus `backend/public` ist unter `GET /ui/` erreichbar (Kompatibilität).
- API: Endpoints `GET /healthz` und `GET /api/stats` hinzugefügt (System-/Uptime-/Memory-Infos, Request-Zähler).
- Cleanup: Verzeichnis `frontend/` auf README reduziert, `web/legacy/` entfernt.
- Docs: Quick-Start auf `cd backend && npm start` aktualisiert; Struktur- und Migration-Doku angepasst.

### Nachtrag (2025-11-16, später Commit)

- Docs: `.github/copilot-instructions.md` hinzugefügt (Architektur, Workflows, Konventionen)
- Web: Views ergänzt unter `web/views/{index,landing,statistik}.html` (Statistik-View lädt `/api/stats`)
- Compose: `frontend` mountet jetzt `web/public` statt `frontend/public`
- Scripts: `scripts/server/start-server.sh` startet nur `frontend`, wenn Backend lokal läuft
- Backend: Startup-Banner zeigt korrekten statischen Pfad `web/public`
- Tests: Minimaler Node built-in Test-Runner (`npm test`) + `backend/test/session.test.js`
