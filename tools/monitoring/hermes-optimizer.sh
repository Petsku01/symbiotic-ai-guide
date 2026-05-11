#!/bin/bash
# Hermes Performance Optimizer - Actionable recommendations

echo "FIX: Hermes Performance Optimization Recommendations"
echo "===================================================="
echo ""

HERMES_PID=$(pgrep -f hermes-gateway)

if [ -z "$HERMES_PID" ]; then
  echo "ERROR: Hermes gateway not running - cannot analyze"
  exit 1
fi

# Analyze current performance metrics
MEMORY_MB=$(ps -p $HERMES_PID -o rss --no-headers)
MEMORY_MB=$((MEMORY_MB / 1024))
UPTIME=$(ps -p $HERMES_PID -o etime --no-headers | tr -d ' ')
CONNECTION_COUNT=$(lsof -p $HERMES_PID -a -i | wc -l)

echo "METRICS: CURRENT METRICS:"
echo "  Memory usage: ${MEMORY_MB}MB"
echo "  Uptime: $UPTIME"
echo "  Network connections: $CONNECTION_COUNT"
echo ""

# Recent performance issues analysis
SLOW_EVENTS=$(journalctl --user -u hermes-gateway --since="24 hours ago" --no-pager | grep "Slow listener" | wc -l)
DISCONNECTS=$(journalctl --user -u hermes-gateway --since="24 hours ago" --no-pager | grep "WebSocket connection closed" | wc -l)

echo "WARNING:  ISSUES DETECTED (24h):"
echo "  Slow message processing events: $SLOW_EVENTS"
echo "  WebSocket disconnections: $DISCONNECTS"
echo ""

echo "OPTIMIZATION: OPTIMIZATION RECOMMENDATIONS:"
echo ""

# Memory optimization
if [ $MEMORY_MB -gt 1500 ]; then
  echo "CRITICAL: HIGH PRIORITY - Memory usage over 1.5GB:"
  echo "  • Consider restarting Hermes gateway periodically"
  echo "  • Monitor for memory leaks in long-running sessions"
  echo ""
fi

# Network optimization
if [ $DISCONNECTS -gt 5 ]; then
  echo "CRITICAL: HIGH PRIORITY - Frequent network disconnections:"
  echo "  • Consider migrating from WSL2 to native Linux"
  echo "  • Implement connection pooling and retry logic"
  echo "  • Monitor Tailscale network stability"
  echo ""
fi

if [ $SLOW_EVENTS -gt 3 ]; then
  echo "OPEN: MEDIUM PRIORITY - Slow message processing:"
  echo "  • Implement timeout handling (fail-fast approach)"
  echo "  • Add performance metrics and alerting"
  echo "  • Consider async message processing queue"
  echo ""
fi

# System optimization
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1}')
if (( $(echo "$LOAD_AVG > 1.0" | bc -l) )); then
  echo "OPEN: MEDIUM PRIORITY - System load elevated:"
  echo "  • Monitor competing processes"
  echo "  • Consider CPU or resource upgrades"
  echo ""
fi

# Proactive recommendations
echo "OK: PROACTIVE IMPROVEMENTS:"
echo "  • Set up automated monitoring with alerting"
echo "  • Implement graceful degradation for network issues"
echo "  • Create performance baseline metrics tracking"
echo "  • Document incident response procedures"
echo ""

echo "TREND: MONITORING SETUP:"
echo "  • Run /tmp/hermes-monitor.sh every 15 minutes"
echo "  • Run /tmp/network-health-check.sh every hour"
echo "  • Set alerts for >60 second message processing"
echo "  • Track WebSocket disconnection frequency"
echo ""

echo "Generated: $(date)"
