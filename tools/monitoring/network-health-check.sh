#!/bin/bash
# Network Health Monitor - Track Discord connectivity issues

DISCORD_IPS=("162.159.136.234" "162.159.135.232" "160.79.104.10")
LOG_FILE="/tmp/network-health.log"

echo "NETWORK: Network Health Check - $(date)" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE

for IP in "${DISCORD_IPS[@]}"; do
  echo "Testing connectivity to $IP..." | tee -a $LOG_FILE
  
  # Ping test
  PING_RESULT=$(ping -c 3 -W 2 $IP 2>/dev/null | grep "packet loss")
  if [ $? -eq 0 ]; then
  LOSS=$(echo $PING_RESULT | grep -o '[0-9]*% packet loss')
  AVG_TIME=$(ping -c 3 -W 2 $IP 2>/dev/null | tail -1 | grep -o 'avg = [0-9.]*' | cut -d'=' -f2 | tr -d ' ')
  echo "  OK: $IP: $LOSS, avg latency: ${AVG_TIME}ms" | tee -a $LOG_FILE
  else
  echo "  ERROR: $IP: Connection failed" | tee -a $LOG_FILE
  fi
done

# Check current OpenClaw connections
echo "" | tee -a $LOG_FILE
echo "Current OpenClaw network status:" | tee -a $LOG_FILE
OPENCLAW_PID=$(pgrep -f openclaw-gateway)
if [ ! -z "$OPENCLAW_PID" ]; then
  ESTABLISHED=$(lsof -p $OPENCLAW_PID -a -i | grep ESTABLISHED | wc -l)
  echo "  Active connections: $ESTABLISHED" | tee -a $LOG_FILE
  
  # Recent WebSocket issues
  RECENT_DROPS=$(journalctl --user -u openclaw-gateway --since="1 hour ago" --no-pager | grep "WebSocket connection closed" | wc -l)
  echo "  WebSocket drops (1h): $RECENT_DROPS" | tee -a $LOG_FILE
else
  echo "  ERROR: OpenClaw gateway not running" | tee -a $LOG_FILE
fi

echo "------------------------------------------------" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
