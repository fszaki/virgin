# Safe Restart - Abgesicherte Neustart-Routine

## Übersicht

Das `safe-restart.sh` Skript führt einen kontrollierten und abgesicherten Neustart des Virgin Project Servers durch. Es kombiniert mehrere kritische Schritte und fordert bei jedem Schritt eine Benutzerbestätigung an.

## Features

✅ **5-Schritt-Prozess mit Benutzerinteraktion**
- Jeder Schritt muss vom Benutzer bestätigt werden
- Sicheres Abbrechen jederzeit möglich
- Detailliertes Logging aller Aktionen

✅ **Umfassende Server-Bereinigung**
- Stoppt Virgin Project Server
- Prüft und bereinigt Port 3000
- Findet und beendet alle Node-Prozesse

✅ **Remote Desktop Integration**
- Erkennt Desktop-Prozesse (noVNC, VNC, X11)
- Neustart von Desktop-Services
- Konfigurierbare Wartezeiten

✅ **Umgebungsvalidierung**
- Prüft Node.js und npm
- Validiert Projekt-Dateien
- Installiert fehlende Dependencies
- Stellt Port-Verfügbarkeit sicher

✅ **Health Monitoring**
- Automatischer Health Check nach Start
- Timeout-basierte Überwachung
- JSON-formatierte Statusanzeige

## Verwendung

### Direkt ausführen
```bash
./safe-restart.sh
```

### Mit Alias (nach setup-aliases.sh)
```bash
srv-safe-restart
```

## Die 5 Schritte im Detail

### Schritt 1: Server-Shutdown
- Stoppt Virgin Project Server (via kill-server.sh)
- Bereinigt Port 3000
- Beendet weitere Node-Prozesse
- Wartezeit: 5 Sekunden

**Benutzer-Bestätigung:** "Alle laufenden Server stoppen?"

### Schritt 2: Remote Desktop Neustart
- Findet Desktop-Prozesse (noVNC, VNC, X11, Xvnc)
- Stoppt Prozesse gracefully (SIGTERM, dann SIGKILL)
- Startet systemd Desktop-Services neu
- Wartezeit: 10 Sekunden

**Benutzer-Bestätigung:** "Remote Desktop neu starten?"

### Schritt 3: Umgebung validieren
- ✓ Node.js Version
- ✓ npm Version
- ✓ Projekt-Dateien (server.js, package.json)
- ✓ node_modules (mit Auto-Install bei Fehlen)
- ✓ Port 3000 Verfügbarkeit

**Benutzer-Bestätigung:** "Umgebung validieren vor dem Start?"

### Schritt 4: Server starten
- Verwendet start-server.sh wenn vorhanden
- Fallback auf manuellen Start
- Erstellt PID-Datei
- Leitet Output ins Log

**Benutzer-Bestätigung:** "Server jetzt starten?"

### Schritt 5: Health Check
- Wartet auf Server-Bereitschaft
- Testet http://localhost:3000/healthz
- Timeout: 30 Sekunden
- Intervall: 2 Sekunden
- Zeigt JSON-Response

**Benutzer-Bestätigung:** "Health Check durchführen?"

## Konfiguration

### Timeouts anpassen

Öffne `safe-restart.sh` und bearbeite die Variablen:

```bash
# Timeouts (in Sekunden)
SHUTDOWN_TIMEOUT=5              # Wartezeit nach Server-Shutdown
DESKTOP_RESTART_TIMEOUT=10      # Wartezeit nach Desktop-Neustart
HEALTH_CHECK_TIMEOUT=30         # Max. Wartezeit für Health Check
HEALTH_CHECK_INTERVAL=2         # Prüfintervall für Health Check
```

### Log-Verzeichnis

Logs werden gespeichert in:
```
/workspaces/virgin/logs/safe-restart-YYYYMMDD-HHMMSS.log
```

## Beispiel-Ablauf

```
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║          VIRGIN PROJECT - SAFE RESTART ROUTINE             ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════
  SCHRITT 1: Server-Shutdown
═══════════════════════════════════════════════════════

→ Alle laufenden Server stoppen?
  Fortfahren? (j/n) [Standard: j]: j
✓ Bestätigt

Prüfe Virgin Project Server...
  Server läuft (PID: 1234)
  Stoppe Server mit kill-server.sh...
  ✓ Server gestoppt

Prüfe Port 3000...
  ✓ Port 3000 ist frei

Prüfe weitere Node-Prozesse...
  ✓ Keine weiteren Node-Prozesse

Shutdown-Wartezeit
  ✓ Wartezeit abgeschlossen

═══════════════════════════════════════════════════════
  SCHRITT 2: Remote Desktop Neustart
═══════════════════════════════════════════════════════

→ Remote Desktop neu starten?
  Fortfahren? (j/n) [Standard: j]: j
✓ Bestätigt

[... weitere Schritte ...]

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              ✓ SAFE RESTART ABGESCHLOSSEN                  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

Status-Zusammenfassung:
  ✓ Server gestoppt
  ✓ Remote Desktop neu gestartet
  ✓ Umgebung validiert
  ✓ Server gestartet
  ✓ Health Check bestanden

Server-Informationen:
  PID: 5678
  URL: http://localhost:3000
  Health: http://localhost:3000/healthz
  Log: /workspaces/virgin/logs/safe-restart-20251116-130000.log
```

## Fehlerbehandlung

### Abbruch durch Benutzer
Bei Eingabe von "n" wird der Prozess sofort gestoppt:
```
✗ Abgebrochen durch Benutzer
```

### Fehlende Umgebung
Bei fehlenden Requirements (Node.js, npm, Dateien):
```
ERROR: Node.js nicht gefunden
```
Script beendet sich mit Exit Code 1.

### Port belegt
Wenn Port 3000 vor dem Start belegt ist:
```
✗ Port belegt
```
Script beendet sich mit Exit Code 1.

### Health Check fehlgeschlagen
Bei Timeout wird gefragt:
```
✗ Health Check fehlgeschlagen
Server antwortet nicht nach 30 Sekunden

Möchtest du trotzdem fortfahren? (j/n)
```

## Best Practices

### Wann verwenden?

✅ **Verwende Safe Restart bei:**
- Problemen mit hängenden Prozessen
- Remote Desktop Issues
- Nach Systemupdates
- Bei unklarem Server-Status
- Vor wichtigen Demos/Tests

❌ **Nicht nötig bei:**
- Einfachem Server-Neustart (nutze `srv-restart`)
- Code-Änderungen (Server erkennt diese automatisch bei nodemon)
- Nur Log-Überprüfung

### Regelmäßige Wartung

Führe Safe Restart aus:
- Nach längerer Inaktivität
- Bei Speicherproblemen
- Nach Desktop-Neustart
- Vor wichtigen Präsentationen

## Integration mit anderen Scripts

### setup-autostart.sh
Safe Restart kann mit Autostart kombiniert werden:
```bash
# In .bashrc nach Autostart-Setup
alias morning-start='srv-safe-restart'
```

### Cron-Job (nicht empfohlen für interaktive Routine)
Für automatische Neustarts ohne Interaktion müsste das Skript angepasst werden.

## Troubleshooting

### "Permission denied"
```bash
chmod +x safe-restart.sh
```

### Desktop-Prozesse nicht gefunden
Normal in Umgebungen ohne GUI/Remote Desktop. Schritt wird übersprungen.

### systemctl nicht verfügbar
Normal in einigen Container-Umgebungen. Wird automatisch erkannt.

### Logs zu groß
Alte Logs löschen:
```bash
rm /workspaces/virgin/logs/safe-restart-*.log
```

## Exit Codes

- `0` - Erfolgreich abgeschlossen
- `1` - Fehler (fehlende Dependencies, Port belegt, etc.)

## Log-Format

Jede Aktion wird geloggt:
```
[2025-11-16 13:00:00] === Safe Restart Routine gestartet ===
[2025-11-16 13:00:01] Benutzer bestätigt: Alle laufenden Server stoppen?
[2025-11-16 13:00:02] Virgin Server gefunden (PID: 1234)
[2025-11-16 13:00:03] Virgin Server gestoppt
...
[2025-11-16 13:00:45] === Safe Restart Routine erfolgreich abgeschlossen ===
```

## Siehe auch

- [QUICK_START.md](QUICK_START.md) - Schnellstart-Anleitung
- [README.md](README.md) - Projekt-Dokumentation
- `start-server.sh` - Einfacher Server-Start
- `kill-server.sh` - Server stoppen
- `restart-servers.sh` - Schneller Neustart
