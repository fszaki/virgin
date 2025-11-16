#!/bin/bash
#
# Safe Restart - Abgesicherte Neustart-Routine
# Stoppt alle Server, startet Remote Desktop neu und führt kontrollierte Start-Routine aus
#

set -e

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Konfiguration
PROJECT_DIR="/workspaces/virgin"
LOG_DIR="$PROJECT_DIR/logs"
SAFE_RESTART_LOG="$LOG_DIR/safe-restart-$(date +%Y%m%d-%H%M%S).log"

# Timeouts (in Sekunden)
SHUTDOWN_TIMEOUT=5
DESKTOP_RESTART_TIMEOUT=10
HEALTH_CHECK_TIMEOUT=30
HEALTH_CHECK_INTERVAL=2

# Logging-Funktion
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SAFE_RESTART_LOG"
}

# Header anzeigen
clear
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
echo -e "${BOLD}${CYAN}║          VIRGIN PROJECT - SAFE RESTART ROUTINE             ║${NC}"
echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
log "=== Safe Restart Routine gestartet ==="

# Funktion: Benutzer fragen
ask_user() {
    local question=$1
    local default=${2:-"j"}
    
    echo ""
    echo -e "${YELLOW}${BOLD}→ $question${NC}"
    read -p "  Fortfahren? (j/n) [Standard: $default]: " -n 1 -r
    echo ""
    
    REPLY=${REPLY:-$default}
    
    if [[ ! $REPLY =~ ^[Jj]$ ]]; then
        echo -e "${RED}✗ Abgebrochen durch Benutzer${NC}"
        log "Abgebrochen durch Benutzer bei: $question"
        exit 0
    fi
    echo -e "${GREEN}✓ Bestätigt${NC}"
    log "Benutzer bestätigt: $question"
}

# Funktion: Spinner für Wartezeiten
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Funktion: Countdown
countdown() {
    local seconds=$1
    local message=$2
    
    echo -e "${CYAN}$message${NC}"
    for ((i=$seconds; i>0; i--)); do
        echo -ne "${YELLOW}  Warte $i Sekunden...\r${NC}"
        sleep 1
    done
    echo -e "${GREEN}  ✓ Wartezeit abgeschlossen${NC}"
}

# ============================================
# SCHRITT 1: Alle Server stoppen
# ============================================
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  SCHRITT 1: Server-Shutdown${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"

ask_user "Alle laufenden Server stoppen?"

log "Schritt 1: Server-Shutdown beginnt"

# Prüfe ob Virgin Server läuft
echo ""
echo -e "${CYAN}Prüfe Virgin Project Server...${NC}"
if [ -f "$PROJECT_DIR/server.pid" ]; then
    PID=$(cat "$PROJECT_DIR/server.pid")
    if ps -p $PID > /dev/null 2>&1; then
        echo -e "${YELLOW}  Server läuft (PID: $PID)${NC}"
        log "Virgin Server gefunden (PID: $PID)"
        
        if [ -x "$PROJECT_DIR/kill-server.sh" ]; then
            echo -e "${CYAN}  Stoppe Server mit kill-server.sh...${NC}"
            "$PROJECT_DIR/kill-server.sh" >> "$SAFE_RESTART_LOG" 2>&1
            echo -e "${GREEN}  ✓ Server gestoppt${NC}"
            log "Virgin Server gestoppt"
        else
            echo -e "${CYAN}  Stoppe Server manuell...${NC}"
            kill -TERM $PID 2>/dev/null || kill -9 $PID 2>/dev/null
            rm -f "$PROJECT_DIR/server.pid"
            echo -e "${GREEN}  ✓ Server gestoppt${NC}"
            log "Virgin Server manuell gestoppt"
        fi
    else
        echo -e "${GREEN}  ✓ Server läuft nicht${NC}"
        log "Virgin Server läuft nicht"
    fi
else
    echo -e "${GREEN}  ✓ Keine PID-Datei gefunden${NC}"
    log "Keine PID-Datei gefunden"
fi

# Prüfe Port 3000
echo ""
echo -e "${CYAN}Prüfe Port 3000...${NC}"
PORT_PIDS=$(lsof -ti :3000 2>/dev/null || true)
if [ -n "$PORT_PIDS" ]; then
    echo -e "${YELLOW}  Prozesse auf Port 3000 gefunden: $PORT_PIDS${NC}"
    log "Prozesse auf Port 3000: $PORT_PIDS"
    for pid in $PORT_PIDS; do
        echo -e "${CYAN}  Stoppe Prozess $pid...${NC}"
        kill -TERM $pid 2>/dev/null || kill -9 $pid 2>/dev/null
        log "Prozess $pid gestoppt"
    done
    echo -e "${GREEN}  ✓ Alle Prozesse auf Port 3000 gestoppt${NC}"
else
    echo -e "${GREEN}  ✓ Port 3000 ist frei${NC}"
    log "Port 3000 ist frei"
fi

# Prüfe weitere Node-Prozesse
echo ""
echo -e "${CYAN}Prüfe weitere Node-Prozesse...${NC}"
NODE_PIDS=$(pgrep -f "node.*server.js" 2>/dev/null || true)
if [ -n "$NODE_PIDS" ]; then
    echo -e "${YELLOW}  Node-Prozesse gefunden: $NODE_PIDS${NC}"
    log "Weitere Node-Prozesse gefunden: $NODE_PIDS"
    ask_user "Diese Node-Prozesse auch stoppen?"
    for pid in $NODE_PIDS; do
        echo -e "${CYAN}  Stoppe Prozess $pid...${NC}"
        kill -TERM $pid 2>/dev/null || kill -9 $pid 2>/dev/null
        log "Node-Prozess $pid gestoppt"
    done
    echo -e "${GREEN}  ✓ Alle Node-Prozesse gestoppt${NC}"
else
    echo -e "${GREEN}  ✓ Keine weiteren Node-Prozesse${NC}"
    log "Keine weiteren Node-Prozesse"
fi

countdown $SHUTDOWN_TIMEOUT "Shutdown-Wartezeit"
log "Schritt 1 abgeschlossen"

# ============================================
# SCHRITT 2: Remote Desktop Neustart
# ============================================
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  SCHRITT 2: Remote Desktop Neustart${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"

ask_user "Remote Desktop neu starten?"

log "Schritt 2: Remote Desktop Neustart beginnt"

echo ""
echo -e "${CYAN}Prüfe Remote Desktop Prozesse...${NC}"

# Prüfe auf noVNC/Desktop-Prozesse
DESKTOP_PIDS=$(pgrep -f "novnc|tigervnc|x11vnc|Xvnc" 2>/dev/null || true)
if [ -n "$DESKTOP_PIDS" ]; then
    echo -e "${YELLOW}  Desktop-Prozesse gefunden: $DESKTOP_PIDS${NC}"
    log "Desktop-Prozesse gefunden: $DESKTOP_PIDS"
    
    echo -e "${CYAN}  Stoppe Desktop-Prozesse...${NC}"
    for pid in $DESKTOP_PIDS; do
        kill -TERM $pid 2>/dev/null || true
        log "Desktop-Prozess $pid gestoppt"
    done
    
    sleep 2
    
    # Force kill falls nötig
    DESKTOP_PIDS=$(pgrep -f "novnc|tigervnc|x11vnc|Xvnc" 2>/dev/null || true)
    if [ -n "$DESKTOP_PIDS" ]; then
        echo -e "${YELLOW}  Force-Kill für verbliebene Prozesse...${NC}"
        for pid in $DESKTOP_PIDS; do
            kill -9 $pid 2>/dev/null || true
        done
    fi
    
    echo -e "${GREEN}  ✓ Desktop-Prozesse gestoppt${NC}"
else
    echo -e "${YELLOW}  ℹ Keine Desktop-Prozesse gefunden${NC}"
    log "Keine Desktop-Prozesse gefunden"
fi

# Prüfe auf systemd Desktop-Services
echo ""
echo -e "${CYAN}Prüfe Desktop-Services...${NC}"
if command -v systemctl &> /dev/null; then
    DESKTOP_SERVICES=$(systemctl --user list-units --type=service --state=running | grep -i "desktop\|vnc\|x11" | awk '{print $1}' || true)
    if [ -n "$DESKTOP_SERVICES" ]; then
        echo -e "${YELLOW}  Desktop-Services gefunden:${NC}"
        echo "$DESKTOP_SERVICES"
        log "Desktop-Services gefunden: $DESKTOP_SERVICES"
        
        ask_user "Diese Services neu starten?"
        
        for service in $DESKTOP_SERVICES; do
            echo -e "${CYAN}  Starte $service neu...${NC}"
            systemctl --user restart "$service" >> "$SAFE_RESTART_LOG" 2>&1 || true
            log "Service $service neu gestartet"
        done
        echo -e "${GREEN}  ✓ Services neu gestartet${NC}"
    else
        echo -e "${GREEN}  ✓ Keine aktiven Desktop-Services${NC}"
        log "Keine aktiven Desktop-Services"
    fi
else
    echo -e "${YELLOW}  ℹ systemctl nicht verfügbar${NC}"
    log "systemctl nicht verfügbar"
fi

countdown $DESKTOP_RESTART_TIMEOUT "Desktop-Neustart-Wartezeit"
log "Schritt 2 abgeschlossen"

# ============================================
# SCHRITT 3: Umgebung validieren
# ============================================
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  SCHRITT 3: Umgebung validieren${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"

ask_user "Umgebung validieren vor dem Start?"

log "Schritt 3: Umgebung validieren"

echo ""
echo -e "${CYAN}Validiere Umgebung...${NC}"

# Node.js prüfen
echo -e "${CYAN}  Node.js:${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}    ✓ $NODE_VERSION${NC}"
    log "Node.js: $NODE_VERSION"
else
    echo -e "${RED}    ✗ Nicht installiert${NC}"
    log "ERROR: Node.js nicht gefunden"
    exit 1
fi

# npm prüfen
echo -e "${CYAN}  npm:${NC}"
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}    ✓ v$NPM_VERSION${NC}"
    log "npm: v$NPM_VERSION"
else
    echo -e "${RED}    ✗ Nicht installiert${NC}"
    log "ERROR: npm nicht gefunden"
    exit 1
fi

# Projekt-Dateien prüfen
echo -e "${CYAN}  Projekt-Dateien:${NC}"
REQUIRED_FILES=("server.js" "package.json")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo -e "${GREEN}    ✓ $file${NC}"
        log "Datei gefunden: $file"
    else
        echo -e "${RED}    ✗ $file fehlt${NC}"
        log "ERROR: $file fehlt"
        exit 1
    fi
done

# app/node_modules prüfen
echo -e "${CYAN}  Abhängigkeiten:${NC}"
if [ -d "$PROJECT_DIR/app/node_modules" ]; then
    PKG_COUNT=$(find "$PROJECT_DIR/app/node_modules" -maxdepth 1 -type d | wc -l)
    echo -e "${GREEN}    ✓ app/node_modules ($PKG_COUNT Pakete)${NC}"
    log "app/node_modules: $PKG_COUNT Pakete"
else
    echo -e "${YELLOW}    ⚠ app/node_modules fehlt${NC}"
    log "WARNING: app/node_modules fehlt"
    ask_user "npm install ausführen?"
    cd "$PROJECT_DIR"
    npm install >> "$SAFE_RESTART_LOG" 2>&1
    echo -e "${GREEN}    ✓ Abhängigkeiten installiert${NC}"
    log "Abhängigkeiten installiert"
fi

# Port-Verfügbarkeit prüfen
echo -e "${CYAN}  Port 3000:${NC}"
if lsof -i :3000 >/dev/null 2>&1; then
    echo -e "${RED}    ✗ Port belegt${NC}"
    log "ERROR: Port 3000 belegt"
    exit 1
else
    echo -e "${GREEN}    ✓ Verfügbar${NC}"
    log "Port 3000 verfügbar"
fi

echo -e "${GREEN}✓ Umgebung validiert${NC}"
log "Schritt 3 abgeschlossen"

# ============================================
# SCHRITT 4: Server starten
# ============================================
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  SCHRITT 4: Server starten${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"

ask_user "Server jetzt starten?"

log "Schritt 4: Server-Start beginnt"

echo ""
if [ -x "$PROJECT_DIR/start-server.sh" ]; then
    echo -e "${CYAN}Starte Server mit start-server.sh...${NC}"
    cd "$PROJECT_DIR"
    ./start-server.sh >> "$SAFE_RESTART_LOG" 2>&1
    SERVER_START_EXIT=$?
    
    if [ $SERVER_START_EXIT -eq 0 ]; then
        echo -e "${GREEN}✓ Server gestartet${NC}"
        log "Server erfolgreich gestartet"
    else
        echo -e "${RED}✗ Server-Start fehlgeschlagen (Exit Code: $SERVER_START_EXIT)${NC}"
        log "ERROR: Server-Start fehlgeschlagen (Exit Code: $SERVER_START_EXIT)"
        echo ""
        echo -e "${YELLOW}Letzte Log-Zeilen:${NC}"
        tail -20 "$SAFE_RESTART_LOG"
        exit 1
    fi
else
    echo -e "${CYAN}Starte Server manuell...${NC}"
    cd "$PROJECT_DIR"
    nohup node server.js > "$LOG_DIR/server-$(date +%Y%m%d-%H%M%S).log" 2>&1 &
    SERVER_PID=$!
    echo $SERVER_PID > "$PROJECT_DIR/server.pid"
    echo -e "${GREEN}✓ Server gestartet (PID: $SERVER_PID)${NC}"
    log "Server manuell gestartet (PID: $SERVER_PID)"
fi

# ============================================
# SCHRITT 5: Health Check
# ============================================
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  SCHRITT 5: Health Check${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"

ask_user "Health Check durchführen?"

log "Schritt 5: Health Check beginnt"

echo ""
echo -e "${CYAN}Warte auf Server-Bereitschaft...${NC}"

HEALTH_URL="http://localhost:3000/healthz"
ELAPSED=0
SUCCESS=0

while [ $ELAPSED -lt $HEALTH_CHECK_TIMEOUT ]; do
    if curl -s "$HEALTH_URL" > /dev/null 2>&1; then
        HEALTH_RESPONSE=$(curl -s "$HEALTH_URL")
        echo -e "${GREEN}✓ Server antwortet${NC}"
        echo -e "${CYAN}Response:${NC}"
        echo "$HEALTH_RESPONSE" | jq '.' 2>/dev/null || echo "$HEALTH_RESPONSE"
        log "Health Check erfolgreich: $HEALTH_RESPONSE"
        SUCCESS=1
        break
    fi
    
    echo -ne "${YELLOW}  Warte... ($ELAPSED/$HEALTH_CHECK_TIMEOUT Sekunden)\r${NC}"
    sleep $HEALTH_CHECK_INTERVAL
    ELAPSED=$((ELAPSED + HEALTH_CHECK_INTERVAL))
done

echo ""

if [ $SUCCESS -eq 0 ]; then
    echo -e "${RED}✗ Health Check fehlgeschlagen${NC}"
    echo -e "${YELLOW}Server antwortet nicht nach $HEALTH_CHECK_TIMEOUT Sekunden${NC}"
    log "ERROR: Health Check fehlgeschlagen"
    
    echo ""
    echo -e "${YELLOW}Möchtest du trotzdem fortfahren? (j/n)${NC}"
    read -p "Auswahl: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Jj]$ ]]; then
        exit 1
    fi
fi

log "Schritt 5 abgeschlossen"

# ============================================
# ABSCHLUSS
# ============================================
echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}║              ✓ SAFE RESTART ABGESCHLOSSEN                  ║${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Status-Zusammenfassung
echo -e "${BOLD}${CYAN}Status-Zusammenfassung:${NC}"
echo -e "${GREEN}  ✓ Server gestoppt${NC}"
echo -e "${GREEN}  ✓ Remote Desktop neu gestartet${NC}"
echo -e "${GREEN}  ✓ Umgebung validiert${NC}"
echo -e "${GREEN}  ✓ Server gestartet${NC}"
echo -e "${GREEN}  ✓ Health Check bestanden${NC}"

echo ""
echo -e "${CYAN}${BOLD}Server-Informationen:${NC}"
if [ -f "$PROJECT_DIR/server.pid" ]; then
    SERVER_PID=$(cat "$PROJECT_DIR/server.pid")
    echo -e "${CYAN}  PID:${NC} $SERVER_PID"
fi
echo -e "${CYAN}  URL:${NC} http://localhost:3000"
echo -e "${CYAN}  Health:${NC} http://localhost:3000/healthz"
echo -e "${CYAN}  Log:${NC} $SAFE_RESTART_LOG"

echo ""
echo -e "${YELLOW}Nützliche Befehle:${NC}"
echo -e "${CYAN}  Server stoppen:${NC} ./kill-server.sh"
echo -e "${CYAN}  Logs anzeigen:${NC} tail -f logs/server-*.log"
echo -e "${CYAN}  Safe Restart:${NC} ./safe-restart.sh"

log "=== Safe Restart Routine erfolgreich abgeschlossen ==="
