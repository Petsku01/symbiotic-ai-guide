# Changelog

All notable documentation and safety hardening changes are tracked here.

## 2026-07-01

### v0.17.0 documentation alignment
- Updated all validation baseline dates from 2026-05 to 2026-07 baseline.
- Updated `hermes@2026.2.17` pins to `hermes@0.17.0` across docs.
- Updated "Last validated" and "Last updated" dates to 2026-07-01.

### README.md
- Added "What's New in v0.17.0" section with feature table covering: Skills, MCP servers, Dashboard, Profiles, Credential Pools, Fallback Providers, Curator, Cron CLI, Webhooks, TASK MODE, Voice STT/TTS, Vision fallback, Delegation, One-shot mode, Worktree mode, Compression, Checkpoints, Honcho memory, Plugins, Scrapling.
- Added navigation links for v0.17.0 features and security/privacy config.
- Noted `hermes auth add` replaces `hermes configure` and `hermes login`.

### docs/getting-started/GOLDEN-PATH.md
- Updated test date to 2026-07-01.
- Added `hermes auth add` as the auth step in onboarding.
- Added step 7 for exploring v0.17.0 features (Dashboard, Skills).

### docs/reference/KUU-AI-SETUP-GUIDE.md
- Updated validation baseline dates.
- Added `agent.system_prompt` (TASK MODE) mention near system prompt section.
- Added `approvals.mode` (manual/smart/off) in Full Access Profile section.
- Added `hermes profile create/use` in Multi-Agent Setup section.
- Added MCP servers, Skills, and Curator mentions in Tool Access Configuration section.

### docs/reference/FAQ.md
- Updated "Can I have multiple AIs?" answer to mention `hermes profile create/use/list`.
- Added new "v0.17.0 Feature Questions" section with FAQ entries for: Skills, MCP, Dashboard, Credential Pools, Fallback, TASK MODE, Voice, Vision fallback, Delegation, Cron, Webhooks.
- Fixed `hermes status | grep Memory` to `hermes status`.

### docs/VALIDATION-BASIS.md
- Updated date to 2026-07-01.
- Updated `hermes@2026.2.17` to `hermes@0.17.0`.
- Added v0.17.0 CLI surface smoke test commands (auth, skills, mcp, cron, dashboard, profile, curator, webhook).
- Added v0.17.0 config field validation (config_version, agent.system_prompt, security.redact_secrets, privacy.redact_pii, approvals.mode).

### docs/VALIDATION-RUNTIME-PLAYBOOK.md
- Added v0.17.0 CLI surface checks (auth, skills, mcp, cron, dashboard, profile, curator, webhook) to Step 1 and Pass/Fail checklist.

### docs/security/SECURITY-IMPROVEMENTS.md
- Updated "Last Updated" from February 9, 2026 to July 1, 2026.
- Added section on `security.redact_secrets` (default true since v0.13.0).
- Added section on `privacy.redact_pii` (default false).
- Added section on `approvals.mode` (manual/smart/off).
- Added section on Credential Pools (`hermes auth add/list/remove/reset`).
- Added section on Fallback Providers (`hermes fallback add/remove`).

### docs/releases/RC-GATE-CHECKLIST.md
- Updated `hermes@2026.2.17` to `hermes@0.17.0`.
- Added gate for v0.17.0 feature coverage check.
- Added gate for verifying `hermes auth add` replaces `hermes configure`.

### docs/roadmap/ISSUE-STACK.md
- Updated `hermes@2026.2.17` to `hermes@0.17.0`.
- Added issue 13: v0.17.0 feature coverage across all docs.
- Added issue 14: deprecation timeline update (2026-04-30 passed, extended to 2026-07-31).

### docs/reference/SCRIPT-DEPRECATION-POLICY.md
- Extended target removal date from 2026-04-30 to 2026-07-31.
- Added Hermes-native alternatives section (Cron, Curator, Skills).

### tools/automation/README.md
- Updated legacy removal target from v0.2.0 (2026-04-30) to v0.2.0 (2026-07-31).
- Added Hermes-native automation alternatives section (Cron, Curator, Skills).

### LOCAL-EMBEDDINGS-SETUP.md
- Updated validation baseline dates.
- Updated "Hermes 2026.2.3-1" to "Hermes 0.17.0".
- Added Honcho memory integration mention as alternative.

## 2026-02-18

### RC hardening
- CI fail-closed pass:
  - `.github/workflows/validate.yml` now installs pinned `shellcheck`, `gitleaks`, and `hermes@2026.2.17` in CI.
  - strict onboarding smoke check remains hard-required and fails when `hermes` is unavailable after provisioning (no CI skip path).
- Added adversarial safety test runner:
  - `scripts/run-adversarial-checks.sh`
  - checks prompt-injection response expectations, external-LLM approval-gate markers, and secret-pattern sanity with explicit thresholding.
- Script reliability hardening:
  - improved permission-stat handling in `scripts/security-audit.sh` with safer fallback behavior.
- Governance sync:
  - updated status reality in `docs/roadmap/ISSUE-STACK.md` (issues 9 and 12 now marked done).
- RC release gate documentation:
  - added `docs/releases/RC-GATE-CHECKLIST.md`
  - linked from `README.md` and beta draft release notes.

## 2026-02-17

### Release framing
- Added beta framing draft: `docs/releases/v0.1.0-beta-draft.md`

### Process & policy
- Added status sync requirement policy: `docs/operations/STATUS-SYNC-POLICY.md`
- Added public validation run workflow and template:
  - `docs/validation-runs/README.md`
  - `docs/validation-runs/EXAMPLE-RUN.md`
- Added script deprecation policy with explicit removal target (`v0.2.0` / `2026-07-31`):
  - `docs/reference/SCRIPT-DEPRECATION-POLICY.md`


### Added
- `CHANGELOG.md` with explicit milestone tracking.
- `docs/getting-started/GOLDEN-PATH.md` as the single tested onboarding path.
- `docs/VALIDATION-RUNTIME-PLAYBOOK.md` for non-destructive runtime validation.

### Changed
- Reduced root-document clutter; moved non-core docs into `docs/`:
  - `docs/reference/KUU-AI-SETUP-GUIDE.md`
  - `docs/reference/FAQ.md`
  - `docs/security/SECURITY-IMPROVEMENTS.md`
  - `docs/security/INTERNAL-SKEPTIC-COMPACT.md`
  - `docs/security/EXTERNAL-LLM-SAFETY.md`
  - `docs/roadmap/ISSUE-STACK.md`
- Updated links/references across README, installation docs, validation basis, PR template, and docs safety checks.
- Updated issue stack statuses to reflect completed hardening/drift fixes and remaining open items.

### Safety & uncertainty toolkit milestones
- Drift/hardening baseline documented and validated through:
  - `scripts/validate-docs-safety.sh`
  - `scripts/smoke-test-onboarding-commands.sh`
- Uncertainty-method reference kept in `docs/DECISION_GRADE_UNCERTAINTY.md` and linked from organized docs flow.
- Added uncertainty toolkit implementation under `tools/uncertainty/`:
  - `score-task.js`
  - `decide-action.js`
  - `log-result.js`
  - `review-week.js`
  - `README.md`
- Upgraded uncertainty toolkit with MVE/quick mode and calibration reporting.

### Additional hardening completed
- Backup hardening updates:
  - dry-run default
  - destructive sync gated by `--delete --confirm-delete` + typed confirmation
  - destination safety checks and private permission defaults (`umask 077`)
- `quick-setup.sh` auto-commit changed to opt-in (`--auto-commit`).
- Expanded CI/validation coverage:
  - command denylist checks for known-invalid Hermes examples
  - onboarding command smoke tests
  - shellcheck-if-available and lightweight secret-scan flow

### External LLM safety + deprecation enforcement
- Added explicit outbound safety workflow:
  - `docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md`
- Updated references from `README.md` and `docs/security/EXTERNAL-LLM-SAFETY.md`.
- Finalized legacy automation deprecation controls:
  - canonical-vs-legacy matrix + migration notes in `tools/automation/README.md`
  - deprecation notices in legacy automation scripts
  - validator checks enforcing deprecation markers and canonical target references

### Honesty / scope notes
- Runtime validation playbook is validated for **non-destructive command checks only**.
- Full OS-by-OS install walkthrough execution remains environment-dependent and should be treated as untested unless locally re-run.
