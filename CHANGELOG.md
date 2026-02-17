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

### Honesty / scope notes
- Runtime validation playbook is validated for **non-destructive command checks only**.
- Full OS-by-OS install walkthrough execution remains environment-dependent and should be treated as untested unless locally re-run.
