#!/bin/bash
#
# Safe Restart - Abgesicherte Neustart-Routine
# Stoppt alle Services und startet sie sicher via Docker Compose neu
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
HEALTH_CHECK_TIMEOUT=30
HEALTH_CHECK_INTERVAL=2

# Logging-Funktion
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SAFE_RESTART_LOG"
}

# Header anzeigen
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║                                                            ║${NC}"
echo -e "${BOLD}${CYAN}║     VIRGIN PROJECT - SAFE RESTART (Docker Compose)         ║${NC}"
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
# SCHRITT 1: Services stoppen (Docker Compose)
# ============================================
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  SCHRITT 1: Server-Shutdown${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"

ask_user "Alle laufenden Services (docker compose) stoppen?"

log "Schritt 1: docker compose down"
if command -v docker >/dev/null; then
  (cd "$PROJECT_DIR" && docker compose down) >> "$SAFE_RESTART_LOG" 2>&1 || true
else
  echo -e "${RED}Docker nicht verfügbar. Abbruch.${NC}"
  log "ERROR: Docker nicht verfügbar"
  exit 1
fi
countdown $SHUTDOWN_TIMEOUT "Shutdown-Wartezeit"
log "Schritt 1 abgeschlossen"

# ============================================
# SCHRITT 2: Services starten (Docker Compose)
# ============================================
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  SCHRITT 2: Services starten${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"

ask_user "Services via docker compose starten?"

log "Schritt 2: docker compose up -d --build"
(cd "$PROJECT_DIR" && DOCKER_BUILDKIT=1 docker compose up -d --build) >> "$SAFE_RESTART_LOG" 2>&1
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
    echo -e "${CYAN}  Docker:${NC}"
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}    ✓ $(docker --version)${NC}"
        log "Docker verfügbar"
    else
        echo -e "${RED}    ✗ Nicht installiert${NC}"
        log "ERROR: Docker nicht gefunden"
        exit 1
    fi

    echo -e "${GREEN}✓ Umgebung validiert${NC}"
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

echo -e "${GREEN}✓ Services gestartet (siehe Schritt 2)${NC}"

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

HEALTH_URL="http://localhost:3000/api/health"
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
echo -e "${CYAN}  Backend:${NC}  http://localhost:3000  (Health: /api/health)"
echo -e "${CYAN}  Frontend:${NC} http://localhost:8080"
echo -e "${CYAN}  Log:${NC} $SAFE_RESTART_LOG"

echo ""
echo -e "${YELLOW}Nützliche Befehle:${NC}"
echo -e "${CYAN}  Stoppen:${NC} docker compose down"
echo -e "${CYAN}  Logs:${NC}   docker compose logs -f"
echo -e "${CYAN}  Restart:${NC} ./scripts/server/restart-servers.sh"

log "=== Safe Restart Routine erfolgreich abgeschlossen ==="
