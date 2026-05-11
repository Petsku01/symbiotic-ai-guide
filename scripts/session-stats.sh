#!/bin/bash
# Display Hermes session statistics
# Shows token usage, active sessions, and costs

set -euo pipefail

echo "=== Hermes Session Statistics ==="
echo ""

if ! command -v hermes &> /dev/null; then
  echo "ERROR: hermes command not found"
  exit 1
fi

# Get status
echo "Gateway Status:"
hermes status 2>&1 | grep -E "(Gateway|Agents|Sessions|Memory)" | head -10

echo ""
echo "Session Details:"
hermes status --deep 2>&1 | grep -A 20 "Sessions" | head -25 || echo "Could not get session details"

echo ""
echo "Security Status:"
hermes security audit 2>&1 | grep -E "(Summary|critical|warn)" | head -5

echo ""
echo "Cron Jobs:"
CRON_COUNT=$(hermes cron list 2>&1 | grep -c '"name"' || echo "0")
echo "Active jobs: $CRON_COUNT"
