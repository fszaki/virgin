#!/bin/bash
#
# Umgebungs-Test Script
# Testet alle Aspekte der Entwicklungsumgebung
#

set +e  # Fahre fort auch bei Fehlern

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     UMFASSENDER UMGEBUNGS-TEST                             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Datum: $(date)"
echo "Hostname: $(hostname)"
echo ""

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Log-Datei
LOG_DIR="/workspaces/virgin/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/env-test-$(date +%Y%m%d-%H%M%S).log"

echo -e "${BLUE}Log-Datei: $LOG_FILE${NC}\n"

# Zähler
PASSED=0
FAILED=0
WARNINGS=0

# Test-Funktion
test_check() {
    local name=$1
    local result=$2
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $name" | tee -a "$LOG_FILE"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name" | tee -a "$LOG_FILE"
        ((FAILED++))
        return 1
    fi
}

test_warning() {
    local msg=$1
    echo -e "${YELLOW}⚠${NC} $msg" | tee -a "$LOG_FILE"
    ((WARNINGS++))
}

section() {
    echo "" | tee -a "$LOG_FILE"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
}

# ============================================================
section "1. BETRIEBSSYSTEM & KERNEL"
# ============================================================

echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" | tee -a "$LOG_FILE"
echo "Kernel: $(uname -r)" | tee -a "$LOG_FILE"
echo "Architektur: $(uname -m)" | tee -a "$LOG_FILE"
echo "Uptime: $(uptime -p)" | tee -a "$LOG_FILE"

# ============================================================
section "2. SYSTEM-RESSOURCEN"
# ============================================================

echo "CPU Info:" | tee -a "$LOG_FILE"
echo "  Cores: $(nproc)" | tee -a "$LOG_FILE"
echo "  Model: $(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Memory Info:" | tee -a "$LOG_FILE"
free -h | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Disk Space:" | tee -a "$LOG_FILE"
df -h / | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Load Average: $(cat /proc/loadavg)" | tee -a "$LOG_FILE"

# ============================================================
section "3. ENTWICKLUNGS-TOOLS"
# ============================================================

# Node.js
if command -v node &> /dev/null; then
    test_check "Node.js installiert ($(node --version))" 0
    node --version >> "$LOG_FILE" 2>&1
else
    test_check "Node.js installiert" 1
fi

# npm
if command -v npm &> /dev/null; then
    test_check "npm installiert ($(npm --version))" 0
    npm --version >> "$LOG_FILE" 2>&1
else
    test_check "npm installiert" 1
fi

# Git
if command -v git &> /dev/null; then
    test_check "Git installiert ($(git --version | cut -d' ' -f3))" 0
else
    test_check "Git installiert" 1
fi

# curl
if command -v curl &> /dev/null; then
    test_check "curl installiert" 0
else
    test_check "curl installiert" 1
fi

# wget
if command -v wget &> /dev/null; then
    test_check "wget installiert" 0
else
    test_check "wget installiert" 1
fi

# Docker
if command -v docker &> /dev/null; then
    test_check "Docker installiert ($(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ','))" 0
else
    test_warning "Docker nicht installiert (optional)"
fi

# ============================================================
section "4. NETZWERK-KONFIGURATION"
# ============================================================

echo "Netzwerk-Interfaces:" | tee -a "$LOG_FILE"
ip addr show | grep -E "^[0-9]|inet " | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Routing-Tabelle:" | tee -a "$LOG_FILE"
ip route | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "DNS-Konfiguration:" | tee -a "$LOG_FILE"
cat /etc/resolv.conf | grep -v "^#" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Teste Internet-Verbindung:" | tee -a "$LOG_FILE"
if ping -c 1 8.8.8.8 &> /dev/null; then
    test_check "Internet-Verbindung (8.8.8.8)" 0
else
    test_check "Internet-Verbindung (8.8.8.8)" 1
fi

if curl -s --connect-timeout 5 https://www.google.com > /dev/null; then
    test_check "HTTPS-Verbindung (google.com)" 0
else
    test_check "HTTPS-Verbindung (google.com)" 1
fi

# ============================================================
section "5. PORTS & DIENSTE"
# ============================================================

echo "Offene Ports:" | tee -a "$LOG_FILE"
if command -v netstat &> /dev/null; then
    netstat -tuln | grep LISTEN | tee -a "$LOG_FILE"
else
    ss -tuln | grep LISTEN | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
COMMON_PORTS=(80 443 3000 3001 5000 5001 8000 8080 8443 4200)
echo "Prüfe Standard-Entwicklungsports:" | tee -a "$LOG_FILE"
for PORT in "${COMMON_PORTS[@]}"; do
    if lsof -i :$PORT &> /dev/null; then
        echo -e "${YELLOW}  Port $PORT: BELEGT${NC}" | tee -a "$LOG_FILE"
        lsof -i :$PORT | tee -a "$LOG_FILE"
    else
        echo -e "${GREEN}  Port $PORT: FREI${NC}" | tee -a "$LOG_FILE"
    fi
done

# ============================================================
section "6. PROZESSE"
# ============================================================

echo "Node.js Prozesse:" | tee -a "$LOG_FILE"
NODE_PROCS=$(pgrep -a node || echo "Keine")
echo "$NODE_PROCS" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Top 10 CPU-intensive Prozesse:" | tee -a "$LOG_FILE"
ps aux --sort=-%cpu | head -11 | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "Top 10 Memory-intensive Prozesse:" | tee -a "$LOG_FILE"
ps aux --sort=-%mem | head -11 | tee -a "$LOG_FILE"

# ============================================================
section "7. PROJEKT-STRUKTUR"
# ============================================================

PROJECT_DIR="/workspaces/virgin"

echo "Projekt-Verzeichnis: $PROJECT_DIR" | tee -a "$LOG_FILE"
if [ -d "$PROJECT_DIR" ]; then
    test_check "Projekt-Verzeichnis existiert" 0
    echo "" | tee -a "$LOG_FILE"
    echo "Verzeichnis-Struktur:" | tee -a "$LOG_FILE"
    tree -L 2 -a "$PROJECT_DIR" 2>/dev/null | tee -a "$LOG_FILE" || ls -la "$PROJECT_DIR" | tee -a "$LOG_FILE"
else
    test_check "Projekt-Verzeichnis existiert" 1
fi

echo "" | tee -a "$LOG_FILE"
REQUIRED_FILES=("package.json" "server.js" "start-server.sh" "kill-server.sh")
for FILE in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$FILE" ]; then
        test_check "$FILE existiert" 0
        if [ "$FILE" == "package.json" ]; then
            echo "  Inhalt:" | tee -a "$LOG_FILE"
            cat "$PROJECT_DIR/$FILE" | tee -a "$LOG_FILE"
        fi
    else
        test_check "$FILE existiert" 1
    fi
done

echo "" | tee -a "$LOG_FILE"
REQUIRED_DIRS=("public" "views" "logs" "app/node_modules")
for DIR in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$PROJECT_DIR/$DIR" ]; then
        FILE_COUNT=$(find "$PROJECT_DIR/$DIR" -type f 2>/dev/null | wc -l)
        test_check "$DIR/ Verzeichnis existiert ($FILE_COUNT Dateien)" 0
    else
        test_check "$DIR/ Verzeichnis existiert" 1
    fi
done

# ============================================================
section "8. NPM ABHÄNGIGKEITEN"
# ============================================================

cd "$PROJECT_DIR"

if [ -f "package.json" ]; then
    echo "Definierte Abhängigkeiten:" | tee -a "$LOG_FILE"
    node -e "const pkg = require('./package.json'); console.log(JSON.stringify(pkg.dependencies || {}, null, 2));" 2>/dev/null | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    if [ -d "app/node_modules" ]; then
        INSTALLED=$(ls app/node_modules 2>/dev/null | wc -l)
        test_check "app/node_modules vorhanden ($INSTALLED Pakete)" 0
        
        # Prüfe kritische Module
        CRITICAL_MODULES=("express" "express-rate-limit")
        for MODULE in "${CRITICAL_MODULES[@]}"; do
            if [ -d "app/node_modules/$MODULE" ]; then
                VERSION=$(node -e "console.log(require('./app/node_modules/$MODULE/package.json').version)" 2>/dev/null || echo "unknown")
                test_check "$MODULE installiert (v$VERSION)" 0
            else
                test_check "$MODULE installiert" 1
            fi
        done
        
        echo "" | tee -a "$LOG_FILE"
        echo "Prüfe auf veraltete Pakete:" | tee -a "$LOG_FILE"
        npm outdated 2>&1 | tee -a "$LOG_FILE" || echo "Alle Pakete aktuell" | tee -a "$LOG_FILE"
        
        echo "" | tee -a "$LOG_FILE"
        echo "Prüfe auf Sicherheitslücken:" | tee -a "$LOG_FILE"
        npm audit 2>&1 | head -20 | tee -a "$LOG_FILE"
    else
        test_check "app/node_modules vorhanden" 1
    fi
fi

# ============================================================
section "9. UMGEBUNGSVARIABLEN"
# ============================================================

echo "Relevante Umgebungsvariablen:" | tee -a "$LOG_FILE"
echo "  HOME: $HOME" | tee -a "$LOG_FILE"
echo "  USER: $USER" | tee -a "$LOG_FILE"
echo "  SHELL: $SHELL" | tee -a "$LOG_FILE"
echo "  PATH: $PATH" | tee -a "$LOG_FILE"
echo "  NODE_ENV: ${NODE_ENV:-nicht gesetzt}" | tee -a "$LOG_FILE"
echo "  PORT: ${PORT:-nicht gesetzt}" | tee -a "$LOG_FILE"
echo "  PWD: $PWD" | tee -a "$LOG_FILE"

# ============================================================
section "10. DATEISYSTEM-BERECHTIGUNGEN"
# ============================================================

echo "Berechtigungen im Projekt-Verzeichnis:" | tee -a "$LOG_FILE"
ls -la "$PROJECT_DIR" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
for SCRIPT in start-server.sh kill-server.sh; do
    if [ -f "$PROJECT_DIR/$SCRIPT" ]; then
        if [ -x "$PROJECT_DIR/$SCRIPT" ]; then
            test_check "$SCRIPT ist ausführbar" 0
        else
            test_warning "$SCRIPT ist nicht ausführbar (führe 'chmod +x $SCRIPT' aus)"
        fi
    fi
done

# ============================================================
section "11. SERVER-TEST (falls läuft)"
# ============================================================

PID_FILE="$PROJECT_DIR/server.pid"
if [ -f "$PID_FILE" ]; then
    SERVER_PID=$(cat "$PID_FILE")
    if ps -p $SERVER_PID > /dev/null; then
        test_check "Server läuft (PID: $SERVER_PID)" 0
        
        echo "" | tee -a "$LOG_FILE"
        echo "Teste Server-Endpoints:" | tee -a "$LOG_FILE"
        
        # Test Root
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|404"; then
            test_check "Root-Endpoint erreichbar" 0
        else
            test_check "Root-Endpoint erreichbar" 1
        fi
        
        # Test Health
        HEALTH_RESPONSE=$(curl -s http://localhost:3000/healthz)
        if echo "$HEALTH_RESPONSE" | grep -q "ok"; then
            test_check "Health-Endpoint funktioniert" 0
            echo "  Response: $HEALTH_RESPONSE" | tee -a "$LOG_FILE"
        else
            test_check "Health-Endpoint funktioniert" 1
        fi
    else
        test_warning "PID-Datei vorhanden, aber Prozess läuft nicht"
    fi
else
    echo "Server läuft nicht (keine PID-Datei)" | tee -a "$LOG_FILE"
fi

# ============================================================
section "12. LOG-DATEIEN"
# ============================================================

if [ -d "$PROJECT_DIR/logs" ]; then
    echo "Verfügbare Log-Dateien:" | tee -a "$LOG_FILE"
    ls -lh "$PROJECT_DIR/logs" | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    LATEST_LOG=$(ls -t "$PROJECT_DIR/logs"/server-*.log 2>/dev/null | head -1)
    if [ -f "$LATEST_LOG" ]; then
        echo "Letzte 20 Zeilen vom neuesten Server-Log:" | tee -a "$LOG_FILE"
        tail -20 "$LATEST_LOG" | tee -a "$LOG_FILE"
    fi
fi

# ============================================================
section "ZUSAMMENFASSUNG"
# ============================================================

echo "" | tee -a "$LOG_FILE"
echo "╔════════════════════════════════════════════════════════════╗" | tee -a "$LOG_FILE"
echo "║                    TEST-ERGEBNISSE                         ║" | tee -a "$LOG_FILE"
echo "╠════════════════════════════════════════════════════════════╣" | tee -a "$LOG_FILE"
printf "║  ${GREEN}Erfolgreich:${NC} %-42s ║\n" "$PASSED" | tee -a "$LOG_FILE"
printf "║  ${RED}Fehlgeschlagen:${NC} %-39s ║\n" "$FAILED" | tee -a "$LOG_FILE"
printf "║  ${YELLOW}Warnungen:${NC} %-45s ║\n" "$WARNINGS" | tee -a "$LOG_FILE"
echo "╚════════════════════════════════════════════════════════════╝" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Umgebung ist bereit!${NC}" | tee -a "$LOG_FILE"
    exit 0
else
    echo -e "${RED}✗ Es wurden Probleme gefunden. Bitte prüfe die Fehler.${NC}" | tee -a "$LOG_FILE"
    exit 1
fi
