# Changelog

All notable documentation and safety hardening changes are tracked here.

## 2026-02-17

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
  - command denylist checks for known-invalid OpenClaw examples
  - onboarding command smoke tests
  - shellcheck-if-available and lightweight secret-scan flow
- Added CI-safe behavior for onboarding smoke tests when `openclaw` CLI is unavailable in CI runners.

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
