# Symbiotic AI Guide — Issue Stack (Status)

## Epic

### EPIC: Stabilize onboarding, safety defaults, and repo structure
**Goal:** Make first-run success reliable, eliminate unsafe defaults, and reduce maintenance drag.

**Success criteria:**
- New user can complete setup in <15 minutes using one canonical path.
- No destructive operation runs without explicit confirmation.
- Backup/security defaults are least-privilege.
- Legacy vs current scripts/docs are unambiguous.

---

## P0 Issues

### 1) OK: DONE — Fix command drift in core docs (canonical CLI surface)
**Status notes:** Validation markers + denylist checks are in place; smoke-test script added for non-destructive CLI help commands.

### 2) OK: DONE — Harden backup script destructive behavior
**Status notes:** destructive mode is gated; explicit confirmation required for delete flow; unsafe destinations blocked.

### 3) OK: DONE — Enforce private backup defaults
**Status notes:** private umask and destination permission checks are enforced.

### 4) OK: DONE — Make auto-commit opt-in only
**Status notes:** setup defaults to no auto-commit; explicit flag required.

### 5) OK: DONE — Apply least-privilege defaults in docs and examples
**Status notes:** onboarding path documents least-privilege baseline; higher-risk examples are scoped to advanced sections.

---

## P1 Issues

### 6) OK: DONE — Rebuild README quickstart into one linear happy path
**Status notes:** README now points prominently to one tested quickstart at `docs/getting-started/GOLDEN-PATH.md`.

### 7) OPEN: OPEN — Standardize templates and clarify required vs optional files
**Remaining work:** explicit required/optional matrix across docs + examples, and final contradiction pass vs `quick-setup.sh` output.

### 8) OPEN: OPEN — Resolve legacy vs improved script ambiguity
**Remaining work:** publish a script status matrix and deprecation timeline for non-canonical variants.

### 9) OK: DONE — Add explicit external-LLM outbound approval gate
**Status notes:** mandatory approval workflow published in `docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md`, linked from safety guidance, and covered by adversarial gate checks.

---

## P2 Issues

### 10) OK: DONE — Move long docs into `/docs` information architecture
**Status notes:** non-core root docs moved under `docs/` with updated references.

### 11) OK: DONE — Add release hygiene (CHANGELOG + tags)
**Status notes:** `CHANGELOG.md` added.
**Remaining work:** create first semver tag and add PR checklist item for breaking changes.

### 12) OK: DONE — Expand secret scanning and CI guardrails
**Status notes:** CI now pins and installs shellcheck + gitleaks + `hermes@0.17.0`, fails closed on missing required tooling, runs strict onboarding smoke checks, and includes an adversarial safety test pack with explicit thresholding.

---

## Milestones

### Milestone A — "Safety Baseline"
**State:** OK: Complete (Issues 1–5)

### Milestone B — "Clarity & Consistency"
**State:** OPEN: In progress (Issues 6 and 9 complete; 7–8 open)

### Milestone C — "Scale & Governance"
**State:** OPEN: In progress (Issues 10-12 complete; release tagging follow-up remains)

---

## P1 Issues (v0.17.0 feature coverage)

### 13) OPEN: OPEN - Document v0.17.0 feature coverage across all docs
**Remaining work:** Ensure all onboarding and reference docs mention v0.17.0 features where relevant. Coverage gaps identified:
- Skills (`hermes skills`) - added to README, KUU guide, FAQ
- MCP servers (`hermes mcp`) - added to README, KUU guide, FAQ
- Dashboard (`hermes dashboard`, port 9119) - added to README, Golden Path, FAQ
- Profiles (`hermes profile`) - added to README, KUU guide, FAQ
- Credential Pools (`hermes auth`) - added to Golden Path, Security, FAQ, RC gate
- Fallback Providers (`hermes fallback`) - added to README, Security, FAQ
- Curator (`hermes curator`) - added to README, KUU guide, FAQ
- Cron CLI (`hermes cron`) - added to README, FAQ
- Webhooks (`hermes webhook`) - added to README, FAQ
- TASK MODE (`agent.system_prompt`) - added to KUU guide, FAQ, Validation Basis
- Voice STT/TTS - added to README, FAQ
- Vision fallback - added to README, FAQ
- Delegation (`delegate_task`) - added to README, FAQ
- One-shot mode (`hermes -z`) - added to README
- Worktree mode (`hermes -w`) - added to README
- Compression - added to README
- Checkpoints - added to README
- Honcho memory - added to README, Local Embeddings setup
- Plugins (`hermes plugins`) - added to README
- Scrapling (MCP server) - added to README, FAQ
- `approvals.mode` (manual/smart/off) - added to KUU guide, Security, Validation Basis
- `security.redact_secrets` - added to Security, Validation Basis
- `privacy.redact_pii` - added to Security, Validation Basis
- `config_version: 30` - added to Validation Basis

### 14) OPEN: OPEN - Update deprecation timeline (2026-04-30 has passed)
**Remaining work:** The original target removal date of 2026-04-30 for legacy scripts has passed. Extended to 2026-07-31 per `docs/reference/SCRIPT-DEPRECATION-POLICY.md`. Hermes-native alternatives (Cron, Curator, Skills) should be documented as replacement paths for legacy automation scripts.
