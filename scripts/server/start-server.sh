#!/bin/bash
#
# Server Start Script (Docker Compose)
# Verwendung: chmod +x start-server.sh && ./start-server.sh
#

set -e

echo "=== Server Start (Docker Compose) ==="
echo "Datum: $(date)"
echo ""

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="/workspaces/virgin"
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/compose-start-$(date +%Y%m%d-%H%M%S).log"

echo -e "${BLUE}Log-Datei: $LOG_FILE${NC}"

if ! command -v docker >/dev/null; then
  echo -e "${RED}✗ Docker ist nicht installiert/verfügbar${NC}"
  exit 1
fi

echo -e "${YELLOW}Hinweis:${NC} Die alte app/ Node-Startlogik ist veraltet."
echo -e "${YELLOW}→${NC} Starte Backend (3000) und/oder Frontend (8080) via Docker Compose."

pushd "$PROJECT_DIR" >/dev/null

# Prüfe, ob ein Backend bereits lokal läuft (z. B. "npm run dev")
set +e
HEALTH_BACK_PRE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
set -e

if [ "$HEALTH_BACK_PRE" = "200" ]; then
  echo -e "${YELLOW}Backend läuft bereits lokal (Port 3000). Starte nur Frontend (nginx).${NC}"
  DOCKER_BUILDKIT=1 docker compose up -d --build frontend 2>&1 | tee -a "$LOG_FILE"
else
  echo -e "${BLUE}Backend nicht gefunden. Starte Backend und Frontend via Compose.${NC}"
  DOCKER_BUILDKIT=1 docker compose up -d --build 2>&1 | tee -a "$LOG_FILE"
fi

popd >/dev/null

sleep 2

# Health-Checks
set +e
HEALTH_BACK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
HEALTH_FRONT=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
set -e

if [ "$HEALTH_BACK" = "200" ]; then
  echo -e "${GREEN}✓ Backend erreichbar:${NC} http://localhost:3000/api/health (200)"
else
  echo -e "${YELLOW}• Backend nicht per Compose gestartet oder (noch) nicht erreichbar${NC} (Status: $HEALTH_BACK)"
fi

if [ "$HEALTH_FRONT" = "200" ]; then
  echo -e "${GREEN}✓ Frontend erreichbar:${NC} http://localhost:8080/ (200)"
else
  echo -e "${RED}✗ Frontend nicht erreichbar${NC} (Status: $HEALTH_FRONT)"
fi

echo ""
echo -e "${BLUE}URLs:${NC}"
echo "  Frontend: http://localhost:8080"
echo "  Backend:  http://localhost:3000"
echo ""
echo -e "${GREEN}Fertig.${NC} Mit 'docker compose logs -f' Logs ansehen."
