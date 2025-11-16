#!/bin/bash

set -e

echo "=== Server Start Script ==="
echo "Datum: $(date)"
echo ""

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log-Datei
LOG_DIR="/workspaces/virgin/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/server-$(date +%Y%m%d-%H%M%S).log"

echo -e "${BLUE}Log-Datei: $LOG_FILE${NC}"

# Funktion zum Loggen
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log "${YELLOW}=== 1. System-Prüfung ===${NC}"

# Prüfe Node.js
if ! command -v node &> /dev/null; then
    log "${RED}FEHLER: Node.js ist nicht installiert!${NC}"
    exit 1
fi
log "${GREEN}✓${NC} Node.js Version: $(node --version)"

# Prüfe npm
if ! command -v npm &> /dev/null; then
    log "${RED}FEHLER: npm ist nicht installiert!${NC}"
    exit 1
fi
log "${GREEN}✓${NC} npm Version: $(npm --version)"

log "\n${YELLOW}=== 2. Projekt-Prüfung ===${NC}"

# Prüfe ob server.js existiert
if [ ! -f "/workspaces/virgin/server.js" ]; then
    log "${RED}FEHLER: server.js nicht gefunden!${NC}"
    exit 1
fi
log "${GREEN}✓${NC} server.js gefunden"

# Prüfe package.json
if [ ! -f "/workspaces/virgin/package.json" ]; then
    log "${RED}FEHLER: package.json nicht gefunden!${NC}"
    exit 1
fi
log "${GREEN}✓${NC} package.json gefunden"

# Zeige package.json Inhalt
log "\npackage.json Inhalt:"
cat /workspaces/virgin/package.json | tee -a "$LOG_FILE"

log "\n${YELLOW}=== 3. Abhängigkeiten prüfen ===${NC}"

cd /workspaces/virgin

# Prüfe node_modules
if [ ! -d "node_modules" ]; then
    log "${YELLOW}⚠${NC} node_modules nicht gefunden. Installiere Abhängigkeiten..."
    npm install 2>&1 | tee -a "$LOG_FILE"
else
    log "${GREEN}✓${NC} node_modules vorhanden ($(ls node_modules | wc -l) Pakete)"
fi

# Prüfe erforderliche Module
REQUIRED_MODULES=("express" "express-rate-limit")
for MODULE in "${REQUIRED_MODULES[@]}"; do
    if [ -d "node_modules/$MODULE" ]; then
        log "${GREEN}✓${NC} $MODULE installiert"
    else
        log "${RED}✗${NC} $MODULE fehlt!"
        log "Installiere $MODULE..."
        npm install $MODULE 2>&1 | tee -a "$LOG_FILE"
    fi
done

log "\n${YELLOW}=== 4. Port-Prüfung ===${NC}"

PORT=${PORT:-3000}
log "Ziel-Port: $PORT"

if lsof -i :$PORT >/dev/null 2>&1; then
    log "${RED}✗${NC} Port $PORT ist bereits belegt:"
    lsof -i :$PORT | tee -a "$LOG_FILE"
    log "\n${YELLOW}Beende Prozess auf Port $PORT...${NC}"
    PID=$(lsof -t -i :$PORT)
    kill -9 $PID 2>/dev/null || true
    sleep 1
    log "${GREEN}✓${NC} Port freigegeben"
else
    log "${GREEN}✓${NC} Port $PORT ist frei"
fi

log "\n${YELLOW}=== 5. Verzeichnisstruktur ===${NC}"

# Prüfe erforderliche Verzeichnisse
REQUIRED_DIRS=("public" "views")
for DIR in "${REQUIRED_DIRS[@]}"; do
    if [ -d "/workspaces/virgin/$DIR" ]; then
        log "${GREEN}✓${NC} $DIR/ vorhanden"
        log "   Dateien: $(find /workspaces/virgin/$DIR -type f | wc -l)"
    else
        log "${YELLOW}⚠${NC} $DIR/ nicht gefunden - erstelle Verzeichnis"
        mkdir -p "/workspaces/virgin/$DIR"
    fi
done

# Prüfe index.html
if [ -f "/workspaces/virgin/views/index.html" ]; then
    log "${GREEN}✓${NC} views/index.html vorhanden"
else
    log "${YELLOW}⚠${NC} views/index.html nicht gefunden"
fi

log "\n${YELLOW}=== 6. Umgebungsvariablen ===${NC}"
log "PORT: ${PORT:-3000}"
log "NODE_ENV: ${NODE_ENV:-development}"
log "Working Directory: $(pwd)"

log "\n${YELLOW}=== 7. Server starten ===${NC}"

# Speichere PID für späteres Beenden
PID_FILE="/workspaces/virgin/server.pid"

log "${GREEN}Starte Server...${NC}\n"

# Starte Server im Hintergrund und leite Output um
nohup node server.js > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

# Speichere PID
echo $SERVER_PID > "$PID_FILE"

sleep 2

# Prüfe ob Server läuft
if ps -p $SERVER_PID > /dev/null; then
    log "${GREEN}✓ Server erfolgreich gestartet!${NC}"
    log "  PID: $SERVER_PID"
    log "  URL: http://localhost:${PORT:-3000}"
    log "  Health: http://localhost:${PORT:-3000}/healthz"
    log "  Logs: $LOG_FILE"
    log "  PID-Datei: $PID_FILE"
    
    # Teste Health-Endpoint
    sleep 1
    if command -v curl &> /dev/null; then
        log "\n${YELLOW}Teste Health-Endpoint...${NC}"
        curl -s http://localhost:${PORT:-3000}/healthz | tee -a "$LOG_FILE" || log "${RED}Health-Check fehlgeschlagen${NC}"
    fi
    
    log "\n${BLUE}Verwende './kill-server.sh' zum Beenden${NC}"
else
    log "${RED}✗ Server konkonnte nicht gestartet werden!${NC}"
    log "Prüfe die Logs: $LOG_FILE"
    exit 1
fi
