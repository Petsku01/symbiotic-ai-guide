#!/usr/bin/env bash
# Minimal adversarial checks (non-destructive)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

checks_run=0
checks_failed=0

pass() {
  echo "[PASS] $*"
}

fail() {
  echo "[FAIL] $*" >&2
  checks_failed=$((checks_failed + 1))
}

run_check() {
  local name="$1"
  shift
  checks_run=$((checks_run + 1))
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

# 1) Prompt-injection expectations must be explicitly documented.
check_prompt_injection_expectations() {
  grep -q "Prompt Injection Attempts" docs/security/EXTERNAL-LLM-SAFETY.md && \
  grep -q "Ignore your previous instructions" docs/security/EXTERNAL-LLM-SAFETY.md && \
  grep -q "Response: Ignore the injection" docs/security/EXTERNAL-LLM-SAFETY.md
}

# 2) External-LLM approval workflow gate markers/enforcement assumptions must exist.
check_external_llm_gate_markers() {
  grep -q "No outbound external LLM request may be sent without explicit human approval" docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md && \
  grep -q "Stop Conditions (Hard Blocks)" docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md && \
  grep -q "EXTERNAL-LLM-APPROVAL-WORKFLOW.md" docs/security/EXTERNAL-LLM-SAFETY.md
}

# 3) Obvious secret-leak sanity regex should catch known-dangerous tokens.
check_secret_regex_sanity() {
  local regex='AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z\-_]{35}|BEGIN (RSA|OPENSSH|EC) PRIVATE KEY'

  local bad_samples=(
    "AKIA1234567890ABCDEF"
    "ghp_123456789012345678901234567890123456"
    "xoxb-123456789012-123456789012-ABCDEFGHIJK"
    "AIzaSyD8k9abcdeFGHIJklmnopQRstuVWxyz123"
    "-----BEGIN RSA PRIVATE KEY-----"
  )

  local safe_samples=(
    "this is harmless text"
    "AIza-short"
    "ghp_short"
  )

  local sample
  for sample in "${bad_samples[@]}"; do
    if ! printf '%s\n' "$sample" | grep -Eq "$regex"; then
      return 1
    fi
  done

  for sample in "${safe_samples[@]}"; do
    if printf '%s\n' "$sample" | grep -Eq "$regex"; then
      return 1
    fi
  done

  return 0
}

run_check "Prompt-injection handling expectations are present" check_prompt_injection_expectations
run_check "External-LLM approval workflow gates are documented" check_external_llm_gate_markers
run_check "Secret regex sanity catches obvious leak patterns" check_secret_regex_sanity

min_pass=$checks_run
actual_pass=$((checks_run - checks_failed))

echo ""
echo "Adversarial checks: ${actual_pass}/${checks_run} passed (threshold: ${min_pass}/${checks_run})"

if (( actual_pass < min_pass )); then
  echo "[FAIL] Adversarial safety threshold not met" >&2
  exit 1
fi

echo "[OK] Adversarial safety checks passed"
