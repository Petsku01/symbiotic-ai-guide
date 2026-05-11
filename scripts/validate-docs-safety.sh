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
  "HERMES-INSTALLATION.md"
  "HERMES-CONFIGURATION.md"
  "LOCAL-EMBEDDINGS-SETUP.md"
)

for file in "${CORE_DOCS[@]}"; do
  check_file_exists "$file"
  grep -q "Validated against" "$file" || fail "$file is missing validation stamp marker ('Validated against')"
done

DENYLIST_PATTERNS=(
  "hermes config init"
  "hermes config patch"
  "hermes gateway logs"
  "hermes chat"
  "hermes gateway start --watch"
  "hermes config path"
)

# `hermes config get` requires a path argument; block bare usage
BARE_CONFIG_GET_REGEX="hermes config get([[:space:]]*$|[[:space:]]*\|)"

for pattern in "${DENYLIST_PATTERNS[@]}"; do
  if grep -nF "$pattern" "${CORE_DOCS[@]}" >/dev/null; then
  matches="$(grep -nF "$pattern" "${CORE_DOCS[@]}")"
  fail "Found denied onboarding command pattern '$pattern' in core docs:\n$matches"
  fi
done

if grep -nRE "$BARE_CONFIG_GET_REGEX" "${CORE_DOCS[@]}" >/dev/null; then
  matches="$(grep -nRE "$BARE_CONFIG_GET_REGEX" "${CORE_DOCS[@]}")"
  fail "Found bare 'hermes config get' usage without required path in core docs:\n$matches"
fi

check_file_exists "docs/VALIDATION-BASIS.md"
check_file_exists "docs/operations/STATUS-SYNC-POLICY.md"
check_file_exists "docs/validation-runs/README.md"
check_file_exists "docs/validation-runs/EXAMPLE-RUN.md"
check_file_exists "docs/releases/v0.1.0-beta-draft.md"
check_file_exists "docs/reference/SCRIPT-DEPRECATION-POLICY.md"
check_file_exists "docs/releases/RC-GATE-CHECKLIST.md"
check_file_exists "scripts/quick-setup.sh"
check_file_exists "scripts/backup-workspace.sh"

# Unsafe backup examples (must not encourage single-flag destructive mode)
if grep -RInE "backup-workspace\.sh[^\n]*--delete(\s|$)" README.md HERMES-CONFIGURATION.md docs scripts/README.md | grep -v -- "--confirm-delete" >/dev/null; then
  fail "Found unsafe backup example using --delete without --confirm-delete"
fi

# README should remain least-privilege only (no full profile snippets)
if grep -q '"profile"[[:space:]]*:[[:space:]]*"full"' README.md; then
  fail "README.md contains permissive full profile snippet"
fi

# Full profile is allowed in detailed docs only when explicitly marked advanced
for file in HERMES-CONFIGURATION.md docs/reference/KUU-AI-SETUP-GUIDE.md; do
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

# External LLM approval workflow must exist and be linked from README + safety docs
check_file_exists "docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md"
grep -q "EXTERNAL-LLM-APPROVAL-WORKFLOW.md" README.md || fail "README.md must reference docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md"
grep -q "EXTERNAL-LLM-APPROVAL-WORKFLOW.md" docs/security/EXTERNAL-LLM-SAFETY.md || fail "docs/security/EXTERNAL-LLM-SAFETY.md must reference EXTERNAL-LLM-APPROVAL-WORKFLOW.md"

# Legacy automation scripts must carry explicit deprecation markers and canonical target references
declare -A LEGACY_CANONICAL=(
  ["tools/automation/automation-orchestrator.sh"]="automation-orchestrator-improved.sh"
  ["tools/automation/memory-maintenance.sh"]="memory-maintenance-improved.sh"
  ["tools/automation/workspace-health-monitor.sh"]="workspace-health-monitor-improved.sh"
  ["tools/automation/intelligent-system-monitor.sh"]="intelligent-system-monitor-improved.sh"
)

for legacy in "${!LEGACY_CANONICAL[@]}"; do
  check_file_exists "$legacy"
  canonical="${LEGACY_CANONICAL[$legacy]}"
  grep -q "DEPRECATION NOTICE" "$legacy" || fail "$legacy missing DEPRECATION NOTICE marker"
  grep -q "$canonical" "$legacy" || fail "$legacy must reference canonical target $canonical"
done



# Required cross-links for new docs/process controls
grep -q "STATUS-SYNC-POLICY.md" .github/pull_request_template.md || fail "PR template must include STATUS-SYNC-POLICY checklist enforcement"
grep -q "pilot-results.jsonl" .github/pull_request_template.md || fail "PR template must include artifact hygiene checklist"
grep -q "validation-runs/README.md" docs/getting-started/GOLDEN-PATH.md || fail "GOLDEN-PATH must link docs/validation-runs/README.md"
grep -q "validation-runs/README.md" docs/VALIDATION-RUNTIME-PLAYBOOK.md || fail "VALIDATION-RUNTIME-PLAYBOOK must link docs/validation-runs/README.md"
grep -q "v0.1.0-beta-draft.md" README.md || fail "README.md must reference docs/releases/v0.1.0-beta-draft.md"
grep -q "v0.1.0-beta-draft.md" CHANGELOG.md || fail "CHANGELOG.md must reference docs/releases/v0.1.0-beta-draft.md"

echo "[OK] Documentation and script safety checks passed"
