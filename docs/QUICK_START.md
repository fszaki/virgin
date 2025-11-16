# 🚀 Quick Start Guide - Virgin Project

Schnellanleitung zum Starten des Servers nach einem Neustart des Containers.

## 📋 Voraussetzungen

- Dev Container läuft
- Node.js ist installiert
- Alle Abhängigkeiten sind installiert

## ⚡ Schnellstart (3 Schritte)

### 1️⃣ Alle Server beenden

```bash
cd /workspaces/virgin
./scripts/server/kill-server.sh
```

### 2️⃣ Server starten

```bash
cd backend && npm start
```

### 3️⃣ Browser öffnen

```bash
"$BROWSER" http://localhost:3000
```

---

## 🔧 Detaillierte Schritte

### Erstmaliges Setup

Wenn du das Projekt zum ersten Mal startest:

```bash
cd /workspaces/virgin/backend

# 1. Abhängigkeiten installieren
npm install

# 2. Server starten
npm start
```

### Nach Container-Neustart

```bash
cd /workspaces/virgin/backend
npm start
```

---

## 📝 Verfügbare Scripts

| Script | Befehl | Beschreibung |
|--------|--------|--------------|
| **Server starten** | `cd backend && npm start` | Startet den Server |
| **Server (Dev)** | `cd backend && npm run dev` | Start mit Hot-Reload |
| **Server beenden** | `./scripts/server/kill-server.sh` | Beendet laufende Server |
| **Environment testen** | `./scripts/utils/test-environment.sh` | Prüft die Umgebung |
| **Struktur anzeigen** | `./scripts/utils/show-structure.sh` | Zeigt Projektstruktur |
| **Struktur erstellen** | `./scripts/setup/setup-structure.sh` | Erstellt Ordnerstruktur |

### NPM Scripts

```bash
# Backend starten
cd backend && npm start

# Entwicklungsmodus (Hot-Reload)
cd backend && npm run dev
```

---

## 🔍 Troubleshooting

### Port bereits belegt

```bash
# Zeige Prozess auf Port 3000
lsof -i :3000

# Beende automatisch
./scripts/server/kill-server.sh
```

### Server startet nicht

```bash
# 1. Prüfe Umgebung
./scripts/utils/test-environment.sh

# 2. Prüfe Logs
cat logs/server-*.log | tail -50

# 3. Installiere Abhängigkeiten neu
rm -rf node_modules
npm install

# 4. Starte neu
cd backend && npm start
```

### Abhängigkeiten fehlen

```bash
# Installiere alle Abhängigkeiten
npm install

# Prüfe spezifisches Paket
npm list express express-rate-limit

# Installiere fehlendes Paket
npm install express express-rate-limit
```

---

## 🌐 URLs & Endpoints

Nach erfolgreichem Start sind folgende URLs verfügbar:

| URL | Beschreibung |
|-----|--------------|
| `http://localhost:3000` | Hauptanwendung |
| `http://localhost:3000/healthz` | Health-Check Endpoint |

---

## 📊 Status prüfen

### Server läuft?

```bash
# Methode 1: PID-Datei
cat server.pid

# Methode 2: Prozessliste
ps aux | grep "node.*server.js"

# Methode 3: Port prüfen
lsof -i :3000

# Methode 4: Health-Check
curl http://localhost:3000/healthz
```

### Logs ansehen

```bash
# Neueste Logs
tail -f logs/server-*.log

# Letzte 50 Zeilen
tail -50 logs/server-$(ls -t logs/server-*.log | head -1)

# Alle Logs
cat logs/server-*.log
```

---

## 🎯 Typische Workflows

### Development Workflow

```bash
# 1. Container starten (in VS Code)
# 2. Terminal öffnen
cd /workspaces/virgin

# 3. Server starten
./start-server.sh

# 4. Entwickeln...
# 5. Bei Änderungen: Server neu starten
./kill-server.sh && ./start-server.sh
```

### Debugging Workflow

```bash
# 1. Umgebung testen
./test-environment.sh

# 2. Server mit Logging starten
./start-server.sh

# 3. Logs in separatem Terminal beobachten
tail -f logs/server-*.log

# 4. Fehler analysieren
grep -i error logs/server-*.log
```

---

## 💡 Tipps

1. **Automatischer Start**: Konfiguriere automatischen Server-Start
2. **Aliases**: Erstelle Aliases für häufige Befehle
3. **VS Code Tasks**: Konfiguriere Tasks für Start/Stop
4. **Git Hooks**: Nutze Pre-Commit Hooks für Tests

### Automatischer Server-Start einrichten

Führe das Setup-Script aus:

```bash
# Aliases hinzufügen (empfohlen zuerst)
./scripts/setup/setup-aliases.sh

# Autostart konfigurieren
./scripts/setup/setup-autostart.sh
```

Wähle einen Modus:

- **Vollautomatisch**: Server startet bei jedem Terminal-Start
- **Einmalig**: Server startet nur einmal nach Container-Neustart
- **Manuell mit Hinweis**: Zeigt nur eine Erinnerung an

Nach dem Setup:

```bash
# Aktiviere die Konfiguration
source ~/.bashrc

# Oder öffne ein neues Terminal
```

### Nützliche Aliases

Nach Ausführung von `./setup-aliases.sh` stehen folgende Aliases zur Verfügung:

```bash
# Server Management
srv-start       # Server starten
srv-stop        # Server beenden
srv-restart     # Server neu starten
srv-logs        # Logs live anzeigen
srv-test        # Umgebung testen
srv-status      # Server-Status prüfen

# Quick Navigation
virgin          # Zu /workspaces/virgin
v              # Kurz-Alias für virgin

# Projekt Management
v-structure     # Projektstruktur anzeigen
v-setup         # Struktur einrichten
v-install       # Dependencies installieren
v-clean         # node_modules neu installieren

# Logs & Debugging
v-logs          # Log-Dateien auflisten
v-log-latest    # Neueste Logs anzeigen
v-log-errors    # Fehler in Logs suchen
v-ps            # Node-Prozesse anzeigen
v-ports         # Offene Ports anzeigen
v-health        # Health-Check durchführen
```

### Autostart deaktivieren

```bash
# Autostart entfernen
sed -i '/# Virgin Project Autostart/,/# End Virgin Project Autostart/d' ~/.bashrc

# Aliases entfernen
sed -i '/# Virgin Project Aliases/,/# End Virgin Project Aliases/d' ~/.bashrc

# Änderungen aktivieren
source ~/.bashrc
```

---

## 📞 Support

Bei Problemen:

1. Prüfe `./test-environment.sh`
2. Sieh in die Logs: `logs/server-*.log`
3. Prüfe die README.md
4. Prüfe package.json auf korrekte Dependencies

---

**Letzte Aktualisierung**: $(date)
**Version**: 1.0.0
