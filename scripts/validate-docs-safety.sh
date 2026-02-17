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

check_file_exists "docs/VALIDATION-BASIS.md"

# Unsafe backup examples (must not encourage single-flag destructive mode)
if grep -RInE "backup-workspace\.sh[^\n]*--delete(\s|$)" README.md OPENCLAW-CONFIGURATION.md KUU-AI-SETUP-GUIDE.md docs | grep -v -- "--confirm-delete" >/dev/null; then
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

echo "[OK] Documentation safety checks passed"
