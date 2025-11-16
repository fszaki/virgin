# Scripts Verzeichnis

Organisierte Scripts für das Virgin Project.

## Struktur

### `/scripts/server/`
Server-Management Scripts:
- `start-server.sh` - Server starten
- `kill-server.sh` - Server stoppen
- `restart-servers.sh` - Server neu starten
- `safe-restart.sh` - Abgesicherter Neustart

### `/scripts/setup/`
Setup und Konfiguration:
- `setup-structure.sh` - Projektstruktur erstellen
- `setup-aliases.sh` - Bash-Aliases einrichten
- `setup-autostart.sh` - Autostart konfigurieren

### `/scripts/utils/`
Hilfsprogramme:
- `test-environment.sh` - Umgebung testen
- `show-structure.sh` - Struktur anzeigen

## Verwendung

Alle Scripts können direkt aus dem Hauptverzeichnis aufgerufen werden:

```bash
./scripts/server/start-server.sh
./scripts/setup/setup-aliases.sh
./scripts/utils/test-environment.sh
```

Oder über Symlinks im Root-Verzeichnis.
