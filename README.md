# Virgin Web Server

Ein einfacher Web-Server zur Erstellung und Bereitstellung von Webseiten.

## Funktionen

- Express.js basierter Web-Server
- Statische Datei-Bereitstellung
- HTML-Seiten-Rendering
- Einfach zu erweitern und anzupassen

## Installation

1. Repository klonen:
```bash
git clone https://github.com/fszaki/virgin.git
cd virgin
```

2. Abhängigkeiten installieren:
```bash
npm install
```

## Verwendung

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

## Projektstruktur

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

## Entwicklung

### Live-Reload (Entwicklung)

Nutze den integrierten Node Watch-Mode:

```bash
npm run dev
```

### Neue Seiten hinzufügen

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

1. Erstellen Sie HTML-Dateien im `views/` Verzeichnis
2. Fügen Sie entsprechende Routen in `server.js` hinzu

### Statische Dateien

Alle Dateien im `public/` Verzeichnis sind über den Root-Pfad erreichbar:
- `public/styles.css` → `http://localhost:3000/styles.css`
- `public/script.js` → `http://localhost:3000/script.js`

## Lizenz

MIT License - siehe [LICENSE](LICENSE) Datei für Details
