# 🌟 Virgin Project

Ein modernes Express.js Web-Server-Projekt mit vollständiger Entwicklungsumgebung.

[![Node.js](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/express-4.x-blue.svg)](https://expressjs.com/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📚 Inhaltsverzeichnis

- [🌟 Virgin Project](#-virgin-project)
	- [📚 Inhaltsverzeichnis](#-inhaltsverzeichnis)
	- [🎯 Übersicht](#-übersicht)
	- [🚀 Quick Start](#-quick-start)
	- [📁 Projektstruktur](#-projektstruktur)
	- [🔧 Installation](#-installation)
	- [🚀 Verwendung](#-verwendung)
		- [Server starten](#server-starten)
		- [Port ändern](#port-ändern)
	- [🛠️ Scripts](#️-scripts)
		- [npm Scripts](#npm-scripts)
		- [Shell Scripts](#shell-scripts)
		- [Aliases (nach setup-aliases.sh)](#aliases-nach-setup-aliasessh)
	- [⚙️ Konfiguration](#️-konfiguration)
	- [🧪 Entwicklung](#-entwicklung)
		- [Live-Reload (Entwicklung)](#live-reload-entwicklung)
		- [Neue Seiten hinzufügen](#neue-seiten-hinzufügen)
		- [Health-Check](#health-check)
		- [Statische Dateien](#statische-dateien)
	- [🧪 Testing](#-testing)
	- [🚀 Deployment](#-deployment)
	- [❓ Troubleshooting](#-troubleshooting)
	- [📜 Lizenz](#-lizenz)

---

## 🎯 Übersicht

Virgin Project ist ein vollständig konfiguriertes Express.js Server-Template mit:

- ✅ Express.js Web-Server
- ✅ Rate Limiting
- ✅ Statische Datei-Bereitstellung
- ✅ Health-Check Endpoint
- ✅ Umfassendes Logging
- ✅ Automatisierte Scripts
- ✅ Dev Container Support
- ✅ Strukturierte Projekt-Organisation

---

## 🚀 Quick Start

**Für sofortigen Start siehe:** [QUICK_START.md](QUICK_START.md)

```bash
# 1. In Projektverzeichnis wechseln
cd /workspaces/virgin

# 2. Abhängigkeiten installieren
npm install

# 3. Server starten
./start-server.sh

# 4. Browser öffnen
"$BROWSER" http://localhost:3000
```

---

## 📁 Projektstruktur

```
virgin/
├── server.js           # Haupt-Server-Datei
├── package.json        # Node.js Projekt-Konfiguration
├── views/             # HTML-Seiten
│   └── index.html     # Startseite
├── public/            # Statische Dateien (CSS, JS, Bilder)
│   └── styles.css     # Stylesheet
└── README.md          # Diese Datei
```

---

## 🔧 Installation

1. Repository klonen:

```bash
git clone https://github.com/fszaki/virgin.git
cd virgin
```

2. Abhängigkeiten installieren:

```bash
npm install
```

---

## 🚀 Verwendung

### Server starten

```bash
npm start
```

Der Server läuft standardmäßig auf `http://localhost:3000`

Hinweise zur Startroutine:

- Prüft und installiert Abhängigkeiten automatisch (`npm ci`/`npm install`).
- Nutzt `PORT` falls gesetzt; sonst wird ein freier Port ab `3000` gesucht.
- Startet den Server im Vordergrund.

Optional Browser öffnen (falls `$BROWSER` gesetzt):

```bash
npm run open
```

Oder automatisch beim Start (wenn `$BROWSER` verfügbar):

```bash
AUTO_OPEN=1 npm start
```

### Port ändern

Sie können den Port über eine Umgebungsvariable ändern:

```bash
PORT=8080 npm start
```

---

## 🛠️ Scripts

### npm Scripts

- `npm start`: Starte den Server
- `npm run dev`: Starte den Server im Entwicklungsmodus
- `npm test`: Führe die Tests aus
- `npm run lint`: Führe den Linter aus

### Shell Scripts

- `./start-server.sh`: Detaillierter Server-Start mit Validierung
- `./kill-server.sh`: Sichere Server-Beendigung
- `./restart-servers.sh`: Schneller Server-Neustart
- `./safe-restart.sh`: **Abgesicherte Neustart-Routine** (siehe [SAFE_RESTART.md](SAFE_RESTART.md))
- `./test-environment.sh`: Umgebung validieren
- `./setup-structure.sh`: Projektstruktur erstellen
- `./setup-aliases.sh`: Bash-Aliases einrichten
- `./setup-autostart.sh`: Automatischen Start konfigurieren

### Aliases (nach setup-aliases.sh)

- `srv-start`: Server starten
- `srv-stop`: Server stoppen
- `srv-restart`: Server neu starten
- `srv-safe-restart`: **Abgesicherter Neustart mit Validierung**
- `srv-logs`: Live-Logs anzeigen
- `srv-status`: Server-Status prüfen

---

## ⚙️ Konfiguration

Umgebungsvariablen für die Konfiguration:

- `PORT`: Der Port, auf dem der Server läuft (Standard: `3000`)
- `NODE_ENV`: Die Umgebung, in der die Anwendung läuft (z.B. `development`, `production`)

Beispiel `.env` Datei:

```
PORT=3000
NODE_ENV=development
```

---

## 🧪 Entwicklung

### Live-Reload (Entwicklung)

Nutze den integrierten Node Watch-Mode:

```bash
npm run dev
```

### Neue Seiten hinzufügen

1. Erstellen Sie HTML-Dateien im `views/` Verzeichnis
2. Fügen Sie entsprechende Routen in `server.js` hinzu

### Health-Check

Der Server stellt einen Health-Endpoint bereit:

```text
GET /healthz
```

Antwort (Beispiel):

```json
{
 "status": "ok",
 "uptime": 12.34,
 "timestamp": "2025-11-16T12:34:56.789Z",
 "version": "1.0.0"
}
```

### Statische Dateien

Alle Dateien im `public/` Verzeichnis sind über den Root-Pfad erreichbar:

- `public/styles.css` → `http://localhost:3000/styles.css`
- `public/script.js` → `http://localhost:3000/script.js`

---

## 🧪 Testing

Um die Tests auszuführen, verwenden Sie:

```bash
npm test
```

---

## 🚀 Deployment

Für das Deployment in Produktionsumgebungen:

1. Setzen Sie die Umgebungsvariablen für die Produktion.
2. Führen Sie `npm run build` aus, um die Anwendung zu erstellen.
3. Starten Sie die Anwendung mit `npm start`.

---

## ❓ Troubleshooting

Häufige Probleme und Lösungen:

- **Problem:** Der Server startet nicht.
  - **Lösung:** Stellen Sie sicher, dass alle Abhängigkeiten installiert sind und der richtige Node.js Version verwendet wird.
- **Problem:** Port ist bereits belegt.
  - **Lösung:** Ändern Sie den Port in der `.env` Datei oder beenden Sie den Prozess, der den Port verwendet.

---

## 📜 Lizenz

MIT License - siehe [LICENSE](LICENSE) Datei für Details
