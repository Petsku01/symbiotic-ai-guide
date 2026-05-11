#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

pass() {
  echo "[OK] $*"
}

if ! command -v hermes >/dev/null 2>&1; then
  fail "hermes CLI not found in PATH. Install it before running onboarding smoke tests."
fi

check_help() {
  local cmd="$1"
  local output

  if ! output="$(bash -lc "$cmd" 2>&1)"; then
  fail "Command failed: $cmd\n$output"
  fi

  if [[ -z "${output//[[:space:]]/}" ]]; then
  fail "Command returned empty output (unexpected): $cmd"
  fi

  pass "$cmd"
}

check_help "hermes --help"
check_help "hermes gateway --help"
check_help "hermes config --help"
check_help "hermes logs --help"

echo "[OK] Onboarding command smoke tests passed"
