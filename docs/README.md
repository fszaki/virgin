# 🌟 Virgin Project

Ein modernes Express.js Web-Server-Projekt mit vollständiger Entwicklungsumgebung.

[![Node.js](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/express-5.x-blue.svg)](https://expressjs.com/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🚀 Quick Start

```bash
# Server starten
./start-server.sh

# Server stoppen
./kill-server.sh

# Abgesicherter Neustart
./safe-restart.sh
```

**Für detaillierte Anleitung siehe:** [docs/QUICK_START.md](docs/QUICK_START.md)

---

## 📁 Projektstruktur

```
virgin/
├── server.js                 # Haupt-Server-Datei
├── package.json              # Node.js Abhängigkeiten
│
├── scripts/                  # Alle Scripts organisiert
│   ├── server/              # Server-Management
│   │   ├── start-server.sh
│   │   ├── kill-server.sh
│   │   ├── restart-servers.sh
│   │   └── safe-restart.sh
│   ├── setup/               # Setup & Konfiguration
│   │   ├── setup-structure.sh
│   │   ├── setup-aliases.sh
│   │   └── setup-autostart.sh
│   └── utils/               # Hilfsprogramme
│       ├── test-environment.sh
│       └── show-structure.sh
│
├── docs/                     # Dokumentation
│   ├── README.main.md       # Vollständige Dokumentation
│   ├── QUICK_START.md       # Schnellstart-Anleitung
│   └── SAFE_RESTART.md      # Safe Restart Dokumentation
│
├── views/                    # HTML Templates
│   ├── index.html
│   ├── landing.html
│   └── statistik.html
│
├── public/                   # Statische Dateien
│   └── styles.css
│
├── logs/                     # Log-Dateien
│   └── archive/             # Archivierte Logs
│
└── config/                   # Konfigurationsdateien
```

---

## 🎯 Features

- ✅ **Express.js 5.x** - Moderner Web-Server
- ✅ **Rate Limiting** - Schutz vor Überlastung
- ✅ **Health Checks** - `/healthz` Endpoint
- ✅ **Strukturierte Scripts** - Organisiert in Unterordnern
- ✅ **Safe Restart** - Abgesicherte Neustart-Routine
- ✅ **Autostart** - Automatischer Server-Start
- ✅ **Umfassendes Logging** - Mit Archivierung
- ✅ **Dev Container Support** - Containerisierte Entwicklung

---

## 📋 Verfügbare Commands

### Server Management

```bash
./start-server.sh          # Server starten (mit Validierung)
./kill-server.sh           # Server stoppen
./restart-servers.sh       # Schneller Neustart
./safe-restart.sh          # Abgesicherter Neustart (5-Schritt-Prozess)
```

### Setup & Konfiguration

```bash
./setup-structure.sh       # Projektstruktur erstellen
./setup-aliases.sh         # Bash-Aliases einrichten
./setup-autostart.sh       # Autostart konfigurieren
```

### Utilities

```bash
./test-environment.sh      # Umgebung validieren
./show-structure.sh        # Projektstruktur anzeigen
```

### Aliases (nach `./setup-aliases.sh`)

```bash
srv-start              # Server starten
srv-stop               # Server stoppen
srv-restart            # Server neu starten
srv-safe-restart       # Abgesicherter Neustart
srv-logs               # Live-Logs anzeigen
srv-status             # Server-Status prüfen

v / virgin             # Zu /workspaces/virgin wechseln
v-structure            # Struktur anzeigen
v-health               # Health Check
```

---

## 📚 Dokumentation

| Dokument | Beschreibung |
|----------|-------------|
| [docs/QUICK_START.md](docs/QUICK_START.md) | Schnellstart-Anleitung für Einsteiger |
| [docs/README.main.md](docs/README.main.md) | Vollständige Projekt-Dokumentation |
| [docs/SAFE_RESTART.md](docs/SAFE_RESTART.md) | Safe Restart Routine Details |
| [scripts/README.md](scripts/README.md) | Script-Verzeichnis Übersicht |

---

## ⚙️ Konfiguration

### Umgebungsvariablen

```bash
PORT=3000              # Server-Port (Standard: 3000)
NODE_ENV=development   # Umgebung (development/production)
```

### Server-Konfiguration

Passe `server.js` an für:
- Port-Einstellungen
- Rate-Limiting
- Routen
- Middleware

---

## 🔧 Installation

```bash
# 1. Repository klonen
git clone <repository-url>
cd virgin

# 2. Abhängigkeiten installieren
npm install

# 3. Server starten
./start-server.sh

# 4. Optional: Aliases einrichten
./setup-aliases.sh
source ~/.bashrc
```

---

## 🚦 Health Check

Der Server stellt einen Health-Endpoint bereit:

```bash
curl http://localhost:3000/healthz
```

**Antwort:**
```json
{
  "status": "ok",
  "uptime": 123.45,
  "timestamp": "2025-11-16T12:00:00.000Z",
  "version": "1.0.0"
}
```

---

## 📊 Logs

Logs werden im `logs/` Verzeichnis gespeichert:

```bash
# Live-Logs anzeigen
tail -f logs/server-*.log

# Oder mit Alias
srv-logs

# Archivierte Logs
ls logs/archive/
```

---

## 🛠️ Troubleshooting

### Server startet nicht

```bash
# Umgebung testen
./test-environment.sh

# Port prüfen
lsof -i :3000

# Logs überprüfen
tail -50 logs/server-*.log
```

### Port bereits belegt

```bash
# Prozess finden und beenden
lsof -ti :3000 | xargs kill -9

# Oder Server-Script nutzen
./kill-server.sh
```

### Abgesicherter Neustart

Bei Problemen mit hängenden Prozessen oder unklarem Status:

```bash
./safe-restart.sh
```

Dies führt einen vollständigen 5-Schritt-Neustart durch.

---

## 📦 Abhängigkeiten

- **Node.js** >= 18.0.0
- **Express** 5.x
- **express-rate-limit** 8.x

```bash
# Abhängigkeiten neu installieren
npm install

# Oder mit Alias
v-clean
```

---

## 🤝 Contributing

Contributions sind willkommen! Bitte:

1. Fork das Repository
2. Erstelle einen Feature-Branch
3. Committe deine Änderungen
4. Push zum Branch
5. Erstelle einen Pull Request

---

## 📄 License

Dieses Projekt ist unter der [MIT License](LICENSE) lizenziert.

---

## 🔗 Links

- [Express.js Dokumentation](https://expressjs.com/)
- [Node.js Dokumentation](https://nodejs.org/)
- [GitHub Repository](https://github.com/fszaki/virgin)

---

## 📞 Support

Bei Fragen oder Problemen:

1. Überprüfe die [Dokumentation](docs/)
2. Führe `./test-environment.sh` aus
3. Überprüfe die [Logs](logs/)
4. Erstelle ein Issue auf GitHub

---

**Entwickelt mit ❤️ für effiziente Web-Entwicklung**
