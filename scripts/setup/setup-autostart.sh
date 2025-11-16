#!/bin/bash
#
# Setup Autostart - Konfiguriert automatischen Server-Start
#

set -e

echo "=== Autostart Setup für Virgin Project ==="
echo ""

BASHRC="$HOME/.bashrc"
BACKUP="$HOME/.bashrc.backup-autostart-$(date +%Y%m%d-%H%M%S)"

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Prüfe ob .bashrc existiert
if [ ! -f "$BASHRC" ]; then
    echo -e "${RED}✗ .bashrc nicht gefunden!${NC}"
    exit 1
fi

# Backup erstellen
echo -e "${BLUE}Erstelle Backup: $BACKUP${NC}"
cp "$BASHRC" "$BACKUP"

# Prüfe ob Autostart bereits konfiguriert
if grep -q "# Virgin Project Autostart" "$BASHRC"; then
    echo -e "${YELLOW}⚠ Autostart bereits konfiguriert${NC}"
    echo ""
    read -p "Möchtest du die Konfiguration ersetzen? (j/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Jj]$ ]]; then
        sed -i '/# Virgin Project Autostart/,/# End Virgin Project Autostart/d' "$BASHRC"
    else
        exit 0
    fi
fi

# Frage Benutzer nach Präferenz
echo ""
echo "Wähle Autostart-Modus:"
echo ""
echo "1) Vollautomatisch - Server startet bei jedem Terminal-Start"
echo "2) Einmalig - Server startet nur beim ersten Terminal nach Neustart"
echo "3) Manuell mit Hinweis - Zeigt nur Hinweis zum manuellen Start"
echo "4) Abbrechen"
echo ""
read -p "Auswahl (1-4): " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}Konfiguriere vollautomatischen Start...${NC}"
        cat >> "$BASHRC" << 'EOF'

# Virgin Project Autostart
# Vollautomatischer Modus
# ============================================
if [ -f /workspaces/virgin/server.js ]; then
    # Prüfe ob Server bereits läuft
    if ! lsof -i :3000 >/dev/null 2>&1; then
        echo "🚀 Starte Virgin Project Server..."
        cd /workspaces/virgin && ./start-server.sh
    else
        echo "✓ Virgin Project Server läuft bereits"
    fi
fi
# End Virgin Project Autostart
# ============================================

EOF
        echo -e "${GREEN}✓ Vollautomatischer Start konfiguriert${NC}"
        ;;
    
    2)
        echo ""
        echo -e "${BLUE}Konfiguriere einmaligen Start...${NC}"
        cat >> "$BASHRC" << 'EOF'

# Virgin Project Autostart
# Einmaliger Modus (nur nach Neustart)
# ============================================
VIRGIN_AUTOSTART_FLAG="/tmp/virgin-autostart-done"
if [ -f /workspaces/virgin/server.js ] && [ ! -f "$VIRGIN_AUTOSTART_FLAG" ]; then
    if ! lsof -i :3000 >/dev/null 2>&1; then
        echo "🚀 Starte Virgin Project Server (einmalig)..."
        cd /workspaces/virgin && ./start-server.sh
        touch "$VIRGIN_AUTOSTART_FLAG"
    fi
elif [ -f "$VIRGIN_AUTOSTART_FLAG" ]; then
    echo "✓ Virgin Project Server bereits gestartet"
fi
# End Virgin Project Autostart
# ============================================

EOF
        echo -e "${GREEN}✓ Einmaliger Start konfiguriert${NC}"
        ;;
    
    3)
        echo ""
        echo -e "${BLUE}Konfiguriere manuellen Start mit Hinweis...${NC}"
        cat >> "$BASHRC" << 'EOF'

# Virgin Project Autostart
# Manueller Modus mit Hinweis
# ============================================
if [ -f /workspaces/virgin/server.js ]; then
    if ! lsof -i :3000 >/dev/null 2>&1; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║          Virgin Project - Server nicht aktiv              ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Starte den Server mit:"
        echo "  srv-start     oder"
        echo "  ./start-server.sh"
        echo ""
    else
        echo "✓ Virgin Project Server läuft auf http://localhost:3000"
    fi
fi
# End Virgin Project Autostart
# ============================================

EOF
        echo -e "${GREEN}✓ Manueller Start mit Hinweis konfiguriert${NC}"
        ;;
    
    4|*)
        echo ""
        echo -e "${YELLOW}Abgebrochen${NC}"
        exit 0
        ;;
esac

echo ""
echo -e "${GREEN}✓ Konfiguration abgeschlossen!${NC}"
echo ""
echo "Aktiviere mit:"
echo "  source ~/.bashrc"
echo ""
echo "Zum Deaktivieren:"
echo "  sed -i '/# Virgin Project Autostart/,/# End Virgin Project Autostart/d' ~/.bashrc"
