# 📁 Projektstruktur - Virgin Project

Detaillierte Übersicht über die Dateiorganisation.

## 🎯 Designprinzipien

1. **Trennung nach Funktion** - Scripts, Docs, Code getrennt
2. **Symlinks für Kompatibilität** - Alle Scripts im Root als Symlinks
3. **Klare Hierarchie** - Logische Gruppierung
4. **Einfache Navigation** - Intuitive Pfade

---

## 📂 Verzeichnisstruktur

```
virgin/
│
├── 📄 server.js              # Haupt-Server-Datei
├── 📄 package.json           # Dependencies & Scripts
├── 📄 LICENSE                # MIT Lizenz
├── 📄 README.md              # Haupt-Dokumentation
│
├── 📁 scripts/               # ALLE SCRIPTS ORGANISIERT
│   ├── 📄 README.md
│   │
│   ├── 📁 server/           # Server-Management
│   │   ├── start-server.sh      # Detaillierter Start
│   │   ├── kill-server.sh       # Sicheres Stoppen
│   │   ├── restart-servers.sh   # Schneller Neustart
│   │   └── safe-restart.sh      # 5-Schritt Neustart
│   │
│   ├── 📁 setup/            # Setup & Konfiguration
│   │   ├── setup-structure.sh   # Projektstruktur
│   │   ├── setup-aliases.sh     # Bash-Aliases
│   │   └── setup-autostart.sh   # Autostart Config
│   │
│   └── 📁 utils/            # Hilfsprogramme
│       ├── test-environment.sh  # Umgebung testen
│       └── show-structure.sh    # Struktur anzeigen
│
├── 📁 docs/                  # DOKUMENTATION
│   ├── README.main.md           # Vollständige Docs
│   ├── QUICK_START.md           # Schnellstart
│   └── SAFE_RESTART.md          # Safe Restart Guide
│
├── 📁 views/                 # HTML TEMPLATES
│   ├── index.html               # Hauptseite
│   ├── landing.html             # Landing Page
│   └── statistik.html           # Statistiken
│
├── 📁 public/                # STATISCHE DATEIEN
│   └── styles.css               # CSS Stylesheet
│
├── 📁 logs/                  # LOG-DATEIEN
│   ├── .gitkeep
│   ├── server-*.log             # Aktuelle Server-Logs
│   └── 📁 archive/              # Alte Logs
│       ├── .gitkeep
│       └── server-restart-*.log
│
├── 📁 config/                # KONFIGURATION
│   └── (leer - für zukünftige Configs)
│
├── 📁 bin/                   # BINARIES
│   └── start.sh                 # Alternative Start
│
├── 📁 content/               # CONTENT
│   └── test.html                # Test-Inhalte
│
├── 📁 .vscode/               # VS CODE CONFIG
│   ├── extensions.json
│   ├── settings.json
│   └── mcp.json
│
└── 🔗 SYMLINKS (Root)        # Rückwärtskompatibilität
    ├── start-server.sh -> scripts/server/start-server.sh
    ├── kill-server.sh -> scripts/server/kill-server.sh
    ├── restart-servers.sh -> scripts/server/restart-servers.sh
    ├── safe-restart.sh -> scripts/server/safe-restart.sh
    ├── setup-structure.sh -> scripts/setup/setup-structure.sh
    ├── setup-aliases.sh -> scripts/setup/setup-aliases.sh
    ├── setup-autostart.sh -> scripts/setup/setup-autostart.sh
    ├── test-environment.sh -> scripts/utils/test-environment.sh
    └── show-structure.sh -> scripts/utils/show-structure.sh
```

---

## 🔗 Symlink-Strategie

### Warum Symlinks?

1. **Rückwärtskompatibilität** - Alte Befehle funktionieren weiter
2. **Einfacher Zugriff** - `./start-server.sh` statt `./scripts/server/start-server.sh`
3. **Dokumentation bleibt gültig** - Keine Pfad-Updates nötig
4. **Flexibilität** - Interne Organisation kann sich ändern

### Überprüfung

```bash
# Zeige alle Symlinks
ls -la *.sh

# Zeige Symlink-Ziele
readlink start-server.sh
```

---

## 📋 Datei-Kategorien

### Core-Dateien (Root)

- `server.js` - Haupt-Server
- `package.json` - Node.js Config
- `LICENSE` - MIT Lizenz
- `README.md` - Hauptdokumentation
- `.gitignore` - Git-Ausschlüsse

### Scripts (`scripts/`)

#### Server-Management (`scripts/server/`)

| Datei | Zweck | Besonderheiten |
|-------|-------|----------------|
| `start-server.sh` | Server starten | Vollständige Validierung |
| `kill-server.sh` | Server stoppen | Graceful Shutdown |
| `restart-servers.sh` | Neustart | Schnell, keine Validierung |
| `safe-restart.sh` | Sicherer Neustart | 5-Schritt-Prozess, interaktiv |

#### Setup (`scripts/setup/`)

| Datei | Zweck | Wann verwenden |
|-------|-------|----------------|
| `setup-structure.sh` | Verzeichnisse erstellen | Einmalig bei Setup |
| `setup-aliases.sh` | Bash-Aliases | Optional, sehr empfohlen |
| `setup-autostart.sh` | Autostart config | Optional, für Convenience |

#### Utils (`scripts/utils/`)

| Datei | Zweck | Verwendung |
|-------|-------|------------|
| `test-environment.sh` | Umgebung prüfen | Bei Problemen |
| `show-structure.sh` | Struktur anzeigen | Dokumentation |

### Dokumentation (`docs/`)

| Datei | Zielgruppe | Inhalt |
|-------|------------|--------|
| `README.main.md` | Alle | Vollständige Dokumentation |
| `QUICK_START.md` | Einsteiger | Schnellstart |
| `SAFE_RESTART.md` | DevOps | Safe Restart Details |

### Web-Dateien

#### Views (`views/`)

- HTML-Templates
- Server-seitig gerendert
- Express Template Engine

#### Public (`public/`)

- Statische Assets
- Direkt ausgeliefert
- CSS, JS, Bilder

### Logs (`logs/`)

```
logs/
├── server-20251116-130822.log    # Aktuell
├── safe-restart-*.log             # Restart-Logs
└── archive/
    └── server-restart-*.log       # Alte Logs
```

**Rotation:**

- Automatisch bei jedem Start
- Zeitstempel im Namen
- Archiv für alte Logs

---

## 🎨 Namenskonventionen

### Scripts

- **Format:** `action-object.sh`
- **Beispiele:**
  - `start-server.sh` (Start den Server)
  - `kill-server.sh` (Kill den Server)
  - `setup-aliases.sh` (Setup die Aliases)

### Logs

- **Format:** `type-YYYYMMDD-HHMMSS.log`
- **Beispiele:**
  - `server-20251116-130822.log`
  - `safe-restart-20251116-130744.log`

### Directories

- **Kleinbuchstaben**
- **Plural für Collections** (`scripts/`, `docs/`, `logs/`)
- **Singular für Kategorien** (`server/`, `setup/`, `utils/`)

---

## 🔍 Suche & Navigation

### Häufige Aufgaben

#### Script finden

```bash
# Liste alle Scripts
ls scripts/*/*.sh

# Suche nach Namen
find scripts/ -name "*server*"
```

#### Dokumentation finden

```bash
# Liste alle Docs
ls docs/

# Durchsuchen
grep -r "keyword" docs/
```

#### Logs finden

```bash
# Neueste Logs
ls -lt logs/*.log | head -5

# Nach Datum
ls logs/server-20251116-*.log
```

---

## 📊 Statistiken

```bash
# Anzahl Scripts
find scripts/ -name "*.sh" | wc -l
# → 9 Scripts

# Anzahl Docs
find docs/ -name "*.md" | wc -l
# → 3 Dokumentationen

# Anzahl HTML-Dateien
find views/ -name "*.html" | wc -l
# → 3 Views
```

---

## 🚀 Best Practices

### 1. Verwende Symlinks

```bash
# Gut
./start-server.sh

# Auch gut (direkter Zugriff)
./scripts/server/start-server.sh
```

### 2. Organisiere neue Scripts richtig

```bash
# Server-Script
scripts/server/new-server-task.sh

# Setup-Script
scripts/setup/setup-new-feature.sh

# Utility
scripts/utils/utility-name.sh
```

### 3. Dokumentiere in docs/

```bash
# Neue Dokumentation
docs/NEW_FEATURE.md

# Update Hauptdokumentation
docs/README.main.md
```

### 4. Logs archivieren

```bash
# Alte Logs verschieben
mv logs/old-*.log logs/archive/
```

---

## 🔄 Migration von alter Struktur

Die alte Struktur (alle Scripts im Root) wurde umorganisiert:

```
ALT:                          NEU:
├── start-server.sh     →    ├── scripts/server/start-server.sh
├── kill-server.sh      →    ├── scripts/server/kill-server.sh
├── setup-aliases.sh    →    ├── scripts/setup/setup-aliases.sh
├── QUICK_START.md      →    ├── docs/QUICK_START.md
└── README.md           →    ├── docs/README.main.md
                             └── README.md (neu, kompakt)
```

**Symlinks sorgen für Kompatibilität!**

---

## 📝 Wartung

### Regelmäßig

- Log-Archiv aufräumen (alte Logs löschen)
- Dokumentation aktualisieren
- Scripts testen

### Bei Updates

- Symlinks prüfen
- Pfade in Scripts validieren
- Dokumentation anpassen

### Backup

```bash
# Wichtige Dateien sichern
tar -czf backup-$(date +%Y%m%d).tar.gz \
  server.js package.json scripts/ docs/ views/
```

---

## 🆘 Troubleshooting

### Symlink defekt

```bash
# Prüfen
ls -la start-server.sh

# Neu erstellen
ln -sf scripts/server/start-server.sh start-server.sh
```

### Script nicht ausführbar

```bash
# Rechte setzen
chmod +x scripts/server/start-server.sh
```

### Struktur anzeigen

```bash
# Tree-Ansicht
tree -L 3 -I node_modules

# Oder eigenes Script
./show-structure.sh
```

---

**Diese Struktur optimiert Organisation, Wartbarkeit und Entwicklererfahrung.**
