#!/bin/bash
# Display OpenClaw session statistics
# Shows token usage, active sessions, and costs

set -euo pipefail

echo "=== OpenClaw Session Statistics ==="
echo ""

if ! command -v openclaw &> /dev/null; then
  echo "ERROR: openclaw command not found"
  exit 1
fi

# Get status
echo "Gateway Status:"
openclaw status 2>&1 | grep -E "(Gateway|Agents|Sessions|Memory)" | head -10

echo ""
echo "Session Details:"
openclaw status --deep 2>&1 | grep -A 20 "Sessions" | head -25 || echo "Could not get session details"

echo ""
echo "Security Status:"
openclaw security audit 2>&1 | grep -E "(Summary|critical|warn)" | head -5

echo ""
echo "Cron Jobs:"
CRON_COUNT=$(openclaw cron list 2>&1 | grep -c '"name"' || echo "0")
echo "Active jobs: $CRON_COUNT"
