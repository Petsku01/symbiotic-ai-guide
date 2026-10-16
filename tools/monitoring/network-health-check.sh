#!/bin/bash
# Network Health Monitor - Track Discord connectivity issues
# FIX 17.10 (Solin täysaudit #71/#85): Linux ping-regex (avg on rtmsec-laji;
# 'avg = X ms' → -o rtf parse), div0-guard (3 pinguilla voi kaatua kun loss 100%:
# rtmin/rtmax ei tulostu → AVG_TIME tyhjää) + set -u -turvat: lsof-tyhjä,
# journal-tyhjät eivät kaadeta.

DISCORD_IPS=("162.159.136.234" "162.159.135.232" "160.79.104.10")
LOG_FILE="${KUU_NET_LOG:-/tmp/network-health.log}"

echo "NETWORK: Network Health Check - $(date)" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE

for IP in "${DISCORD_IPS[@]}"; do
  echo "Testing connectivity to $IP..." | tee -a $LOG_FILE

  # Ping test (Linux-tuloste: 'X packets transmitted, Y received, Z% packet loss, time Fms'
  # + 'rtt min/avg/max/mdev = A/B/C/D ms') — GITLEAKS-FRENDLY: ei token-muotoja
  PING_OUT=$(ping -c 3 -W 2 "$IP" 2>/dev/null || true)
  LOSS=$(echo "$PING_OUT" | grep -oE '[0-9]+(\.[0-9]+)?% packet loss' | head -1 | cut -d'%' -f1)
  LOSS="${LOSS:-100}"
  AVG_TIME=$(echo "$PING_OUT" | grep -oE 'rtt min/avg/max[^=]*= ([0-9.]+/){2}[0-9.]+' | head -1 | sed 's/.*= *//' | cut -d'/' -f2)
  if [ -z "$AVG_TIME" ]; then AVG_TIME="n/a"; fi

  if [ "$LOSS" -lt 100 ] 2>/dev/null; then
    echo "  OK: $IP: loss=${LOSS}%, avg=${AVG_TIME} ms" | tee -a "$LOG_FILE"
  else
    echo "  ERROR: $IP: connection failed (loss 100%)" | tee -a "$LOG_FILE"
  fi
done

# Check current Hermes connections
echo "" | tee -a $LOG_FILE
echo "Current Hermes network status:" | tee -a $LOG_FILE
HERMES_PID=$(pgrep -f hermes-gateway | head -1 || true)
if [ -n "$HERMES_PID" ]; then
  ESTABLISHED=$(lsof -p "$HERMES_PID" -a -i 2>/dev/null | grep ESTABLISHED | wc -l || true)
  echo "  Active connections: ${ESTABLISHED:-0}" | tee -a $LOG_FILE

  # Recent WebSocket issues
  RECENT_DROPS=$(journalctl --user -u hermes-gateway --since="1 hour ago" --no-pager | grep "WebSocket connection closed" | wc -l)
  echo "  WebSocket drops (1h): $RECENT_DROPS" | tee -a $LOG_FILE
else
  echo "  ERROR: Hermes gateway not running" | tee -a $LOG_FILE
fi

echo "------------------------------------------------" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
