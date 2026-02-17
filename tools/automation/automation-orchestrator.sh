#!/usr/bin/env bash
# DEPRECATION NOTICE: This is a legacy wrapper. Use automation-orchestrator-improved.sh.
# Legacy wrapper: use automation-orchestrator-improved.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/automation-orchestrator-improved.sh"

if [[ ! -x "$TARGET" ]]; then
  echo "❌ Canonical script not found or not executable: $TARGET" >&2
  exit 1
fi

echo "⚠️  DEPRECATED: tools/automation/automation-orchestrator.sh is legacy." >&2
echo "   Please migrate to: tools/automation/automation-orchestrator-improved.sh" >&2

exec "$TARGET" "$@"
