#!/bin/bash

set -e

echo "=== Server Neustart (Docker Compose) ==="
echo "Datum: $(date)"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LOG_FILE="/workspaces/virgin/logs/compose-restart-$(date +%Y%m%d-%H%M%S).log"
echo "Log-Datei: $LOG_FILE"

if ! command -v docker >/dev/null; then
  echo -e "${RED}✗ Docker ist nicht installiert/verfügbar${NC}"
  exit 1
fi

pushd /workspaces/virgin >/dev/null
echo -e "${YELLOW}Stoppe aktuelle Services...${NC}"
docker compose down 2>&1 | tee -a "$LOG_FILE" || true

echo -e "${YELLOW}Baue und starte Services...${NC}"
DOCKER_BUILDKIT=1 docker compose up -d --build 2>&1 | tee -a "$LOG_FILE"
popd >/dev/null

sleep 2

# Health-Checks
set +e
HEALTH_BACK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
HEALTH_FRONT=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
set -e

echo ""
echo "Ergebnisse:"
if [ "$HEALTH_BACK" = "200" ]; then
  echo -e "${GREEN}✓ Backend OK:${NC} http://localhost:3000/api/health (200)"
else
  echo -e "${RED}✗ Backend Problem${NC} (Status: $HEALTH_BACK)"
fi
if [ "$HEALTH_FRONT" = "200" ]; then
  echo -e "${GREEN}✓ Frontend OK:${NC} http://localhost:8080/ (200)"
else
  echo -e "${RED}✗ Frontend Problem${NC} (Status: $HEALTH_FRONT)"
fi

echo ""
echo -e "${GREEN}Fertig.${NC} Logs: $LOG_FILE"
