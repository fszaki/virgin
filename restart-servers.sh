#!/bin/bash

set -e

echo "=== Server Neustart Script ==="
echo "Datum: $(date)"
echo ""

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log-Datei
LOG_FILE="/workspaces/virgin/server-restart-$(date +%Y%m%d-%H%M%S).log"
echo "Log-Datei: $LOG_FILE"

# Funktion zum Loggen
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log "${YELLOW}=== 1. Beende alle laufenden Server ===${NC}"

# Finde und beende Node.js Prozesse
log "Suche nach Node.js Prozessen..."
NODE_PIDS=$(pgrep -f "node" || true)
if [ ! -z "$NODE_PIDS" ]; then
    log "Gefundene Node.js PIDs: $NODE_PIDS"
    for PID in $NODE_PIDS; do
        log "Beende Prozess $PID: $(ps -p $PID -o command= || echo 'Prozess nicht mehr aktiv')"
        kill -15 $PID 2>/dev/null || true
    done
    sleep 2
    # Force kill falls noch aktiv
    pkill -9 -f "node" 2>/dev/null || true
    log "${GREEN}Node.js Prozesse beendet${NC}"
else
    log "Keine Node.js Prozesse gefunden"
fi

# Finde und beende npm Prozesse
log "Suche nach npm Prozessen..."
NPM_PIDS=$(pgrep -f "npm" || true)
if [ ! -z "$NPM_PIDS" ]; then
    log "Gefundene npm PIDs: $NPM_PIDS"
    pkill -9 -f "npm" 2>/dev/null || true
    log "${GREEN}npm Prozesse beendet${NC}"
else
    log "Keine npm Prozesse gefunden"
fi

# Prüfe belegte Ports
log "\n${YELLOW}=== 2. Prüfe belegte Ports ===${NC}"
for PORT in 3000 3001 5000 5001 8000 8080 4200; do
    if lsof -i :$PORT >/dev/null 2>&1; then
        log "${RED}Port $PORT ist belegt:${NC}"
        lsof -i :$PORT | tee -a "$LOG_FILE"
        PID=$(lsof -t -i :$PORT || true)
        if [ ! -z "$PID" ]; then
            log "Beende Prozess auf Port $PORT (PID: $PID)"
            kill -9 $PID 2>/dev/null || true
        fi
    else
        log "${GREEN}Port $PORT ist frei${NC}"
    fi
done

sleep 2

log "\n${YELLOW}=== 3. Prüfe Projektstruktur und Abhängigkeiten ===${NC}"

# Prüfe Workspace-Struktur
log "Workspace-Verzeichnis: /workspaces/virgin"
log "Inhalt:"
ls -la /workspaces/virgin | tee -a "$LOG_FILE"

# Prüfe auf package.json Dateien
log "\nSuche nach package.json Dateien:"
find /workspaces/virgin -name "package.json" -type f 2>/dev/null | tee -a "$LOG_FILE"

# Prüfe Node.js und npm Versionen
log "\n${YELLOW}=== 4. System-Informationen ===${NC}"
log "Node.js Version:"
node --version 2>&1 | tee -a "$LOG_FILE" || log "${RED}Node.js nicht gefunden!${NC}"

log "\nnpm Version:"
npm --version 2>&1 | tee -a "$LOG_FILE" || log "${RED}npm nicht gefunden!${NC}"

# Prüfe auf fehlende Abhängigkeiten
log "\n${YELLOW}=== 5. Prüfe fehlende Abhängigkeiten ===${NC}"

check_dependencies() {
    local DIR=$1
    if [ -f "$DIR/package.json" ]; then
        log "\nPrüfe: $DIR"
        cd "$DIR"
        
        if [ ! -d "node_modules" ]; then
            log "${RED}node_modules Ordner fehlt!${NC}"
            log "Installiere Abhängigkeiten..."
            npm install 2>&1 | tee -a "$LOG_FILE"
        else
            log "${GREEN}node_modules vorhanden${NC}"
            log "Anzahl installierter Pakete: $(ls node_modules | wc -l)"
        fi
        
        # Prüfe package.json auf Fehler
        if ! node -e "JSON.parse(require('fs').readFileSync('package.json'))" 2>/dev/null; then
            log "${RED}package.json hat Syntax-Fehler!${NC}"
            cat package.json | tee -a "$LOG_FILE"
        fi
    fi
}

# Prüfe alle Verzeichnisse mit package.json
for PKG in $(find /workspaces/virgin -name "package.json" -type f 2>/dev/null); do
    check_dependencies "$(dirname $PKG)"
done

log "\n${YELLOW}=== 6. Starte Server mit Logging ===${NC}"

# Zurück zum Hauptverzeichnis
cd /workspaces/virgin

# Starte Server (anpassen je nach Projekt)
if [ -f "package.json" ]; then
    log "Starte Hauptprojekt..."
    log "package.json Inhalt:"
    cat package.json | tee -a "$LOG_FILE"
    
    log "\nVerfügbare Scripts:"
    npm run 2>&1 | tee -a "$LOG_FILE" || true
    
    # Versuche dev/start Script zu starten
    if grep -q '"dev"' package.json; then
        log "\n${GREEN}Starte mit 'npm run dev'${NC}"
        npm run dev 2>&1 | tee -a "$LOG_FILE" &
    elif grep -q '"start"' package.json; then
        log "\n${GREEN}Starte mit 'npm start'${NC}"
        npm start 2>&1 | tee -a "$LOG_FILE" &
    else
        log "${RED}Kein start/dev Script in package.json gefunden${NC}"
    fi
else
    log "${RED}Keine package.json im Hauptverzeichnis gefunden!${NC}"
fi

log "\n${YELLOW}=== 7. Zusammenfassung ===${NC}"
log "Log-Datei gespeichert unter: $LOG_FILE"
log "\nLaufende Prozesse:"
ps aux | grep -E "node|npm" | grep -v grep | tee -a "$LOG_FILE" || log "Keine Node/npm Prozesse aktiv"

log "\n${GREEN}=== Script abgeschlossen ===${NC}"
log "Prüfe die Logs für Fehler und Warnungen."
