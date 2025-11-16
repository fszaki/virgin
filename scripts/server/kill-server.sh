#!/bin/bash

echo "=== Server Stop (Docker Compose) ==="
echo "Datum: $(date)"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v docker >/dev/null; then
  echo -e "${RED}✗ Docker ist nicht installiert/verfügbar${NC}"
  exit 1
fi

pushd /workspaces/virgin >/dev/null
docker compose down || true
popd >/dev/null

echo -e "${GREEN}✓ Alle Services gestoppt${NC}"
echo ""
echo -e "${YELLOW}Ports prüfen:${NC}"
for PORT in 3000 8080; do
  if lsof -i :$PORT >/dev/null 2>&1; then
    echo -e "${RED}✗ Port $PORT belegt${NC}"
  else
    echo -e "${GREEN}✓ Port $PORT frei${NC}"
  fi
done
