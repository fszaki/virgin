#!/usr/bin/env bash
set -Eeuo pipefail

# Simple, robust start routine for the app
# - Ensures dependencies are installed
# - Chooses a free PORT (defaults to 3000)
# - Starts the server as the foreground process

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
cd "$root"

log() { echo "[start] $*"; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Fehlender Befehl: $1" >&2
    exit 127
  fi
}

require_cmd node
require_cmd npm

# Install dependencies if node_modules missing or outdated
if [ ! -d node_modules ]; then
  log "Installiere Abhängigkeiten (node_modules fehlt)..."
  if [ -f package-lock.json ]; then
    npm ci
  else
    npm install
  fi
fi

# Determine a free port
pick_port() {
  local candidate
  candidate="${PORT:-3000}"
  for p in $(seq "$candidate" $((candidate+10))); do
    if ! ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${p}$"; then
      echo "$p"
      return 0
    fi
  done
  echo "$candidate"
}

PORT="${PORT:-}"
if [ -z "${PORT}" ]; then
  PORT="$(pick_port)"
  export PORT
  log "PORT nicht gesetzt. Verwende freien Port: $PORT"
else
  # Wenn gesetzter PORT belegt ist, abbrechen mit Hinweis
  if ss -ltn 2>/dev/null | awk '{print $4}' | grep -qE ":${PORT}$"; then
    log "Gewählter PORT ${PORT} ist belegt. Setze eine andere PORT-Variable und starte erneut."
    exit 1
  fi
fi

log "Starte Server auf http://localhost:${PORT}"

# Optional: Browser öffnen, falls gewünscht und verfügbar
if [ "${AUTO_OPEN:-0}" = "1" ] && [ -n "${BROWSER:-}" ]; then
  log "Öffne Browser über $BROWSER ..."
  "$BROWSER" "http://localhost:${PORT}" >/dev/null 2>&1 &
fi

exec node server.js
