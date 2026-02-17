#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

check_file_exists() {
  local file="$1"
  [[ -f "$file" ]] || fail "Missing required file: $file"
}

CORE_DOCS=(
  "README.md"
  "OPENCLAW-CONFIGURATION.md"
  "KUU-AI-SETUP-GUIDE.md"
)

for file in "${CORE_DOCS[@]}"; do
  check_file_exists "$file"
  grep -q "Validated against" "$file" || fail "$file is missing validation stamp marker ('Validated against')"
done

DENYLIST_PATTERNS=(
  "openclaw config init"
  "openclaw config patch"
  "openclaw gateway logs"
  "openclaw chat"
  "openclaw gateway start --watch"
  "openclaw config path"
)

for pattern in "${DENYLIST_PATTERNS[@]}"; do
  if grep -nF "$pattern" "${CORE_DOCS[@]}" >/dev/null; then
    matches="$(grep -nF "$pattern" "${CORE_DOCS[@]}")"
    fail "Found denied onboarding command pattern '$pattern' in core docs:\n$matches"
  fi
done

check_file_exists "docs/VALIDATION-BASIS.md"
check_file_exists "scripts/quick-setup.sh"
check_file_exists "scripts/backup-workspace.sh"

# Unsafe backup examples (must not encourage single-flag destructive mode)
if grep -RInE "backup-workspace\.sh[^\n]*--delete(\s|$)" README.md OPENCLAW-CONFIGURATION.md KUU-AI-SETUP-GUIDE.md docs scripts/README.md | grep -v -- "--confirm-delete" >/dev/null; then
  fail "Found unsafe backup example using --delete without --confirm-delete"
fi

# README should remain least-privilege only (no full profile snippets)
if grep -q '"profile"[[:space:]]*:[[:space:]]*"full"' README.md; then
  fail "README.md contains permissive full profile snippet"
fi

# Full profile is allowed in detailed docs only when explicitly marked advanced
for file in OPENCLAW-CONFIGURATION.md KUU-AI-SETUP-GUIDE.md; do
  if grep -q '"profile"[[:space:]]*:[[:space:]]*"full"' "$file"; then
    grep -q "Advanced / Higher Risk" "$file" || fail "$file contains full profile but no explicit advanced risk marker"
  fi
done

# quick-setup auto-commit must be opt-in only
if ! grep -q -- '--auto-commit' scripts/quick-setup.sh; then
  fail "quick-setup.sh must expose an explicit --auto-commit flag"
fi

if grep -q 'git commit -m "Initial workspace setup"' scripts/quick-setup.sh; then
  # shellcheck disable=SC2016 # Intentional literal pattern match against script source
  if ! grep -q 'if \[\[ "\$AUTO_COMMIT" == true \]\]; then' scripts/quick-setup.sh; then
    fail "quick-setup.sh appears to commit without explicit --auto-commit gating"
  fi
fi

# backup hardening: private defaults + permission enforcement
grep -q '^umask 077$' scripts/backup-workspace.sh || fail "backup-workspace.sh must set umask 077"
grep -q 'check_private_directory_permissions' scripts/backup-workspace.sh || fail "backup-workspace.sh missing destination permission enforcement"

echo "[OK] Documentation and script safety checks passed"