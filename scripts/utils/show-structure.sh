#!/bin/bash
#
# Zeigt die Projektstruktur in verschiedenen Formaten
#

PROJECT_ROOT="/workspaces/virgin"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           VIRGIN PROJECT - ORDNERSTRUKTUR                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Farben
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Projekt-Root:${NC} $PROJECT_ROOT"
echo ""

# Methode 1: Mit tree (wenn verfügbar)
if command -v tree &> /dev/null; then
    echo -e "${GREEN}=== Detaillierte Ansicht (tree) ===${NC}"
    tree -L 3 -a -I 'app/node_modules|.git' "$PROJECT_ROOT"
    echo ""
fi

# Methode 2: Mit find und formatierter Ausgabe
echo -e "${GREEN}=== Strukturierte Übersicht ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# Zähle Dateien pro Verzeichnis
count_files() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo $(find "$dir" -type f 2>/dev/null | wc -l)
    else
        echo "0"
    fi
}

# Hauptverzeichnisse
echo "📁 /"
echo "├── 📄 server.js (Hauptserver-Datei)"
echo "├── 📄 package.json (NPM-Konfiguration)"
echo "├── 📁 public/ ($(count_files public) Dateien) - Statische Assets"
echo "│   ├── 📁 css/ - Stylesheets"
echo "│   ├── 📁 js/ - Client JavaScript"
echo "│   ├── 📁 images/ - Bilder"
echo "│   └── 📁 fonts/ - Schriftarten"
echo "├── 📁 views/ ($(count_files views) Dateien) - HTML Templates"
echo "│   ├── 📄 index.html"
echo "│   ├── 📁 partials/ - Wiederverwendbare Teile"
echo "│   └── 📁 layouts/ - Layout-Templates"
echo "├── 📁 src/ ($(count_files src) Dateien) - Quellcode"
echo "│   ├── 📁 controllers/ - Request-Handler"
echo "│   ├── 📁 models/ - Datenmodelle"
echo "│   ├── 📁 routes/ - Route-Definitionen"
echo "│   ├── 📁 middleware/ - Express Middleware"
echo "│   └── 📁 utils/ - Hilfsfunktionen"
echo "├── 📁 tests/ ($(count_files tests) Dateien) - Test-Dateien"
echo "│   ├── 📁 unit/ - Unit-Tests"
echo "│   ├── 📁 integration/ - Integrationstests"
echo "│   └── 📁 e2e/ - End-to-End Tests"
echo "├── 📁 config/ ($(count_files config) Dateien) - Konfigurationsdateien"
echo "├── 📁 logs/ ($(count_files logs) Dateien) - Log-Dateien"
echo "├── 📁 scripts/ - Build & Deployment Scripts"
echo "│   ├── 📄 start-server.sh"
echo "│   ├── 📄 kill-server.sh"
echo "│   ├── 📄 test-environment.sh"
echo "│   └── 📄 show-structure.sh"
echo "├── 📁 docs/ ($(count_files docs) Dateien) - Dokumentation"
echo "├── 📁 data/ - Daten-Dateien"
echo "└── 📁 app/node_modules/ ($(count_files app/node_modules 2>/dev/null || echo 0) Dateien) - NPM Pakete"

echo ""
echo -e "${YELLOW}=== Statistiken ===${NC}"
echo "Gesamt Verzeichnisse: $(find . -type d -not -path '*/app/node_modules/*' -not -path '*/.git/*' | wc -l)"
echo "Gesamt Dateien: $(find . -type f -not -path '*/app/node_modules/*' -not -path '*/.git/*' | wc -l)"
echo "Projekt-Größe: $(du -sh . 2>/dev/null | cut -f1)"

if [ -d "app/node_modules" ]; then
    echo "app/node_modules Größe: $(du -sh app/node_modules 2>/dev/null | cut -f1)"
fi

echo ""
echo -e "${GREEN}=== Wichtige Dateien ===${NC}"
ls -lh server.js package.json 2>/dev/null | tail -n +2

echo ""
echo -e "${GREEN}=== Scripts ===${NC}"
ls -lh *.sh 2>/dev/null | tail -n +2
