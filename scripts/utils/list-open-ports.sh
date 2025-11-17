#!/usr/bin/env bash
set -euo pipefail

echo "== Offene Ports (LISTEN) =="
# IPv4/IPv6 TCP/UDP Listener
sudo lsof -nP -iTCP -iUDP -sTCP:LISTEN 2>/dev/null | awk 'NR==1 || /LISTEN/'

echo
echo "== Vereinfachte Übersicht =="
sudo lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print $1"\t"$2"\t"$9}' | sort -u

echo
echo "== Erwartete Ports (Soll) =="
echo "8080 : nginx (Static Frontend)"
echo "3000 : Express (optional API)"
echo
echo "== Abgleich =="
mapfile -t current < <(sudo lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {split($9,a,":"); print a[length(a)]}' | sort -u)
declare -A expected=([8080]=1 [3000]=1)
unexpected=()
for p in "${current[@]}"; do
  [[ -n "${expected[$p]:-}" ]] || unexpected+=("$p")
done

if ((${#unexpected[@]})); then
  echo "Unerwartete Ports: ${unexpected[*]}"
  echo "Empfehlung: Prozess identifizieren und schließen falls nicht benötigt:"
  for p in "${unexpected[@]}"; do
    echo "  Port $p:"
    sudo lsof -nP -iTCP:${p} -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print "    PID="$2" CMD="$1}'
  done
else
  echo "Keine unerwarteten Ports."
fi

echo
echo "== Docker Container Port-Mapping =="
if command -v docker &>/dev/null; then
  docker ps --format 'table {{.Names}}\t{{.Ports}}'
else
  echo "Docker nicht verfügbar."
fi

echo
echo "== Hinweise =="
echo "- Stoppe optionalen Backend-Server: pkill -f src/server.js (oder Docker Compose down)."
echo "- Prüfe sicherheitskritische Ports (z.B. 22, 2375) nur falls wirklich exponiert."
echo "- Skript regelmäßig ausführen: ./scripts/utils/list-open-ports.sh"
