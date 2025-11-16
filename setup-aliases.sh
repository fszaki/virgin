#!/bin/bash
#
# Setup Aliases - Fügt nützliche Aliases zur .bashrc hinzu
#

set -e

echo "=== Alias Setup für Virgin Project ==="
echo ""

BASHRC="$HOME/.bashrc"
BACKUP="$HOME/.bashrc.backup-$(date +%Y%m%d-%H%M%S)"

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Prüfe ob .bashrc existiert
if [ ! -f "$BASHRC" ]; then
    echo -e "${YELLOW}⚠ .bashrc nicht gefunden. Erstelle neue Datei...${NC}"
    touch "$BASHRC"
fi

# Backup erstellen
echo -e "${BLUE}Erstelle Backup: $BACKUP${NC}"
cp "$BASHRC" "$BACKUP"

# Prüfe ob Aliases bereits existieren
if grep -q "# Virgin Project Aliases" "$BASHRC"; then
    echo -e "${YELLOW}⚠ Aliases bereits vorhanden. Überspringe...${NC}"
    echo ""
    echo "Zum Entfernen führe aus:"
    echo "  sed -i '/# Virgin Project Aliases/,/# End Virgin Project Aliases/d' $BASHRC"
    exit 0
fi

# Füge Aliases hinzu
cat >> "$BASHRC" << 'EOF'

# Virgin Project Aliases
# Automatisch hinzugefügt am $(date)
# ============================================

# Server Management
alias srv-start='cd /workspaces/virgin && ./start-server.sh'
alias srv-stop='cd /workspaces/virgin && ./kill-server.sh'
alias srv-restart='cd /workspaces/virgin && ./kill-server.sh && ./start-server.sh'
alias srv-logs='tail -f /workspaces/virgin/logs/server-*.log'
alias srv-test='cd /workspaces/virgin && ./test-environment.sh'
alias srv-status='lsof -i :3000 || echo "Server läuft nicht"'

# Quick Navigation
alias virgin='cd /workspaces/virgin'
alias v='cd /workspaces/virgin'

# Project Management
alias v-structure='cd /workspaces/virgin && ./show-structure.sh'
alias v-setup='cd /workspaces/virgin && ./setup-structure.sh'
alias v-install='cd /workspaces/virgin && npm install'
alias v-clean='cd /workspaces/virgin && rm -rf node_modules && npm install'

# Logs & Debugging
alias v-logs='ls -lt /workspaces/virgin/logs/'
alias v-log-latest='tail -50 $(ls -t /workspaces/virgin/logs/server-*.log | head -1)'
alias v-log-errors='grep -i error /workspaces/virgin/logs/server-*.log'

# Git Shortcuts (optional)
alias v-git-status='cd /workspaces/virgin && git status'
alias v-git-log='cd /workspaces/virgin && git log --oneline --graph --decorate --all -10'

# Development Helpers
alias v-ps='ps aux | grep -E "node|npm" | grep -v grep'
alias v-ports='lsof -i -P -n | grep LISTEN'
alias v-health='curl -s http://localhost:3000/healthz | jq || curl -s http://localhost:3000/healthz'

# End Virgin Project Aliases
# ============================================

EOF

echo -e "${GREEN}✓ Aliases erfolgreich hinzugefügt!${NC}"
echo ""
echo "Verfügbare Aliases:"
echo ""
echo -e "${BLUE}Server Management:${NC}"
echo "  srv-start      - Server starten"
echo "  srv-stop       - Server beenden"
echo "  srv-restart    - Server neu starten"
echo "  srv-logs       - Logs live anzeigen"
echo "  srv-test       - Umgebung testen"
echo "  srv-status     - Server-Status prüfen"
echo ""
echo -e "${BLUE}Navigation:${NC}"
echo "  virgin / v     - Zu /workspaces/virgin wechseln"
echo ""
echo -e "${BLUE}Projekt:${NC}"
echo "  v-structure    - Projektstruktur anzeigen"
echo "  v-setup        - Struktur einrichten"
echo "  v-install      - Dependencies installieren"
echo "  v-clean        - node_modules neu installieren"
echo ""
echo -e "${BLUE}Logs & Debug:${NC}"
echo "  v-logs         - Log-Dateien auflisten"
echo "  v-log-latest   - Neueste Logs anzeigen"
echo "  v-log-errors   - Fehler in Logs suchen"
echo "  v-ps           - Node-Prozesse anzeigen"
echo "  v-ports        - Offene Ports anzeigen"
echo "  v-health       - Health-Check durchführen"
echo ""
echo -e "${YELLOW}Aktiviere die Aliases mit:${NC}"
echo "  source ~/.bashrc"
echo ""
echo -e "${BLUE}Oder öffne ein neues Terminal${NC}"
