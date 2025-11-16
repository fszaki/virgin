#!/bin/bash

echo "=== Server Stop Script ==="
echo "Datum: $(date)"
echo ""

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PID_FILE="/workspaces/virgin/server.pid"

echo -e "${YELLOW}=== 1. Suche laufende Server ===${NC}"

KILLED=false

# Methode 1: Aus PID-Datei
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "PID aus Datei: $PID"
    
    if ps -p $PID > /dev/null 2>&1; then
        echo "Prozess gefunden: $(ps -p $PID -o command=)"
        echo -e "${YELLOW}Beende Prozess $PID...${NC}"
        kill -15 $PID 2>/dev/null || true
        sleep 2
        
        # Force kill falls noch aktiv
        if ps -p $PID > /dev/null 2>&1; then
            echo -e "${YELLOW}Erzwinge Beenden...${NC}"
            kill -9 $PID 2>/dev/null || true
        fi
        
        rm -f "$PID_FILE"
        echo -e "${GREEN}✓ Server beendet (PID: $PID)${NC}"
        KILLED=true
    else
        echo -e "${YELLOW}⚠ Prozess $PID läuft nicht mehr${NC}"
        rm -f "$PID_FILE"
    fi
else
    echo "Keine PID-Datei gefunden"
fi

# Methode 2: Suche nach node server.js
echo -e "\n${YELLOW}=== 2. Suche nach node server.js Prozessen ===${NC}"
PIDS=$(pgrep -f "node.*server.js" || true)

if [ ! -z "$PIDS" ]; then
    for PID in $PIDS; do
        echo "Gefunden: PID $PID - $(ps -p $PID -o command= 2>/dev/null || echo 'N/A')"
        kill -15 $PID 2>/dev/null || true
        KILLED=true
    done
    sleep 2
    
    # Force kill
    pkill -9 -f "node.*server.js" 2>/dev/null || true
    echo -e "${GREEN}✓ Alle node server.js Prozesse beendet${NC}"
else
    echo "Keine node server.js Prozesse gefunden"
fi

# Methode 3: Suche nach Prozessen auf Port 3000
echo -e "\n${YELLOW}=== 3. Prüfe Port 3000 ===${NC}"
PORT_PID=$(lsof -t -i :3000 2>/dev/null || true)

if [ ! -z "$PORT_PID" ]; then
    echo "Prozess auf Port 3000 gefunden: PID $PORT_PID"
    echo "Details: $(ps -p $PORT_PID -o command= 2>/dev/null || echo 'N/A')"
    kill -9 $PORT_PID 2>/dev/null || true
    echo -e "${GREEN}✓ Prozess auf Port 3000 beendet${NC}"
    KILLED=true
else
    echo "Kein Prozess auf Port 3000"
fi

# Zusammenfassung
echo -e "\n${YELLOW}=== Zusammenfassung ===${NC}"

if [ "$KILLED" = true ]; then
    echo -e "${GREEN}✓ Server erfolgreich beendet${NC}"
else
    echo -e "${YELLOW}⚠ Kein laufender Server gefunden${NC}"
fi

# Zeige verbleibende Node-Prozesse
REMAINING=$(pgrep -a node || true)
if [ ! -z "$REMAINING" ]; then
    echo -e "\n${YELLOW}Verbleibende Node-Prozesse:${NC}"
    echo "$REMAINING"
else
    echo -e "\n${GREEN}Keine Node-Prozesse mehr aktiv${NC}"
fi

# Prüfe Ports
echo -e "\n${YELLOW}Port-Status:${NC}"
for PORT in 3000 3001 5000 8080; do
    if lsof -i :$PORT >/dev/null 2>&1; then
        echo -e "${RED}✗${NC} Port $PORT: belegt"
    else
        echo -e "${GREEN}✓${NC} Port $PORT: frei"
    fi
done
