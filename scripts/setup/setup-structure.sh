#!/bin/bash
#
# Setup Script - Erstellt die komplette Projektstruktur
#

set -e

echo "=== Projektstruktur Setup ==="
echo ""

PROJECT_ROOT="/workspaces/virgin"
cd "$PROJECT_ROOT"

# Erstelle Hauptverzeichnisse
mkdir -p public/{css,js,images,fonts}
mkdir -p views/{partials,layouts}
mkdir -p logs
mkdir -p config
mkdir -p src/{controllers,models,routes,middleware,utils}
mkdir -p tests/{unit,integration,e2e}
mkdir -p docs
mkdir -p scripts
mkdir -p data

echo "✓ Verzeichnisse erstellt"

# Erstelle .gitkeep Dateien für leere Verzeichnisse
find . -type d -empty -exec touch {}/.gitkeep \;

echo "✓ .gitkeep Dateien erstellt"

# Erstelle README Dateien für wichtige Verzeichnisse
cat > public/README.md << 'EOF'
# Public Directory

Statische Dateien die direkt vom Server ausgeliefert werden.

## Struktur

- `css/` - Stylesheets
- `js/` - Client-seitiges JavaScript
- `images/` - Bilder und Icons
- `fonts/` - Webfonts
EOF

cat > src/README.md << 'EOF'
# Source Directory

Hauptquellcode der Anwendung.

## Struktur

- `controllers/` - Request-Handler
- `models/` - Datenmodelle
- `routes/` - Route-Definitionen
- `middleware/` - Express Middleware
- `utils/` - Hilfsfunktionen
EOF

cat > tests/README.md << 'EOF'
# Tests Directory

Test-Dateien für die Anwendung.

## Struktur

- `unit/` - Unit-Tests
- `integration/` - Integrationstests
- `e2e/` - End-to-End Tests
EOF

echo "✓ README Dateien erstellt"

echo ""
echo "=== Setup abgeschlossen ==="
echo "Verwende './show-structure.sh' um die Struktur anzuzeigen"
