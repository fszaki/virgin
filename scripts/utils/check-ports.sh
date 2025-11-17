#!/bin/bash
#
# Port-Check-Utility für Virgin Project
# Prüft Standard-Ports und zeigt belegte Ports an
#

set +e

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              PORT-CHECK - Virgin Project                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Standard-Ports
PORTS=(3000 8080 5501)
PORT_NAMES=("Backend" "Frontend/nginx" "Live Server")

echo -e "${YELLOW}Prüfe Standard-Ports...${NC}"
echo ""

for i in "${!PORTS[@]}"; do
  PORT="${PORTS[$i]}"
  NAME="${PORT_NAMES[$i]}"
  
  if lsof -i :$PORT >/dev/null 2>&1; then
    echo -e "${RED}✗ Port $PORT ($NAME): BELEGT${NC}"
    echo "  Prozess:"
    lsof -i :$PORT | tail -n +2 | awk '{printf "    PID: %-8s User: %-10s Command: %s\n", $2, $3, $1}'
    echo ""
  else
    echo -e "${GREEN}✓ Port $PORT ($NAME): FREI${NC}"
  fi
done

echo ""
echo -e "${BLUE}Alternative Ports nutzen:${NC}"
echo "  Backend:  PORT=3001 npm start (oder docker compose)"
echo "  Frontend: docker-compose.yml ports anpassen"
echo "  Live Server: .vscode/settings.json → liveServer.settings.port"
echo ""
echo -e "${YELLOW}Alle Prozesse auf Port beenden:${NC}"
echo "  lsof -ti :3000 | xargs -r kill -9"
echo ""
