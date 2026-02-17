#!/usr/bin/env bash
# DEPRECATION NOTICE: This is a legacy wrapper. Use memory-maintenance-improved.sh.
# Legacy wrapper: use memory-maintenance-improved.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/memory-maintenance-improved.sh"

if [[ ! -x "$TARGET" ]]; then
  echo "❌ Canonical script not found or not executable: $TARGET" >&2
  exit 1
fi

echo "⚠️  DEPRECATED: tools/automation/memory-maintenance.sh is legacy." >&2
echo "   Please migrate to: tools/automation/memory-maintenance-improved.sh" >&2

exec "$TARGET" "$@"
