# Virgin Projekt (API + UI)

Ordnerstruktur:
- backend: Express-API + statische UI (HTML/JS/CSS)
- docker-compose.yml: Startet den Server (Hot-Reload in Container)
- .gitignore: Ignoriert Node-Outputs

Schnellstart (ohne Docker):
1) cd backend
2) npm install
3) npm run dev
4) $BROWSER http://localhost:3000

API:
- GET /api/hello
- GET /api/health
