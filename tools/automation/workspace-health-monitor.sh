#!/usr/bin/env bash
# DEPRECATION NOTICE: This is a legacy wrapper. Use workspace-health-monitor-improved.sh.
# Legacy wrapper: use workspace-health-monitor-improved.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/workspace-health-monitor-improved.sh"

if [[ ! -x "$TARGET" ]]; then
  echo "ERROR: Canonical script not found or not executable: $TARGET" >&2
  exit 1
fi

echo "WARNING:  DEPRECATED: tools/automation/workspace-health-monitor.sh is legacy." >&2
echo "  Please migrate to: tools/automation/workspace-health-monitor-improved.sh" >&2

exec "$TARGET" "$@"
