#!/bin/bash
# OpenClaw Performance Monitor - Real-time system health tracking

OPENCLAW_PID=$(pgrep -f openclaw-gateway)

if [ -z "$OPENCLAW_PID" ]; then
  echo "ERROR: OpenClaw gateway not running"
  exit 1
fi

echo "CHECK: OpenClaw Performance Monitor - $(date)"
echo "PID: $OPENCLAW_PID"
echo "==============================================="

# Memory and CPU tracking
echo "METRICS: RESOURCE USAGE:"
ps -p $OPENCLAW_PID -o pid,pcpu,pmem,rss,vsz,etime --no-headers | \
  awk '{printf "  CPU: %s%%  Memory: %s%% (%s MB)  Runtime: %s\n", $2, $3, $4/1024, $6}'

# Network connection health
echo ""
echo "NETWORK: NETWORK CONNECTIONS:"
CONNECTIONS=$(lsof -p $OPENCLAW_PID -a -i | wc -l)
echo "  Active connections: $CONNECTIONS"

# Discord-specific connections
DISCORD_CONNS=$(lsof -p $OPENCLAW_PID -a -i | grep -E "(162\.159|discord)" | wc -l)
echo "  Discord connections: $DISCORD_CONNS"

# Recent performance issues
echo ""
echo "WARNING:  RECENT SLOW EVENTS (last 1 hour):"
journalctl --user -u openclaw-gateway --since="1 hour ago" --no-pager | \
  grep "Slow listener" | tail -3 | \
  sed 's/.*Slow listener detected: DiscordMessageListener took /  TIME:  /' | \
  sed 's/ for event MESSAGE_CREATE//'

# System load context
echo ""
echo "SYSTEM:  SYSTEM CONTEXT:"
echo "  Load average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo "  Available RAM: $(free -h | grep Mem | awk '{print $7}')"
echo ""
