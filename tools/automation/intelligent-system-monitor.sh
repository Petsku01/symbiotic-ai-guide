#!/usr/bin/env bash
# DEPRECATION NOTICE: This is a legacy wrapper. Use intelligent-system-monitor-improved.sh.
# Legacy wrapper: use intelligent-system-monitor-improved.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/intelligent-system-monitor-improved.sh"

if [[ ! -x "$TARGET" ]]; then
  echo "❌ Canonical script not found or not executable: $TARGET" >&2
  exit 1
fi

echo "⚠️  DEPRECATED: tools/automation/intelligent-system-monitor.sh is legacy." >&2
echo "   Please migrate to: tools/automation/intelligent-system-monitor-improved.sh" >&2

exec "$TARGET" "$@"
