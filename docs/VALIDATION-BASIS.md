# Validation Basis

This repository's onboarding and safety documentation is validated against the following baseline:

- **Date:** 2026-05-11
- **Platform:** Hermes configuration and workspace conventions used by this repo
- **Scope:**
  - least-privilege defaults in onboarding docs
  - explicit advanced sections for higher-risk/full-access examples
  - safe-by-default backup workflow and destructive-action confirmation
  - denylist enforcement for known-invalid Hermes command patterns in core onboarding docs
  - lightweight docs safety checks in CI (`scripts/validate-docs-safety.sh`)
  - non-destructive onboarding command smoke tests (`scripts/smoke-test-onboarding-commands.sh`)
  - fail-closed CI provisioning of pinned `hermes@2026.2.17` before onboarding smoke checks

## Validation markers

Core onboarding docs must include a `Validated against` block:

- `README.md`
- `HERMES-CONFIGURATION.md`
- `docs/reference/KUU-AI-SETUP-GUIDE.md`
- `HERMES-INSTALLATION.md`
- `LOCAL-EMBEDDINGS-SETUP.md`

These markers are checked by CI.

## Safeguards added

- `scripts/validate-docs-safety.sh` blocks known-invalid onboarding command patterns:
  - `hermes config init`
  - `hermes config patch`
  - `hermes gateway logs`
  - `hermes chat`
  - `hermes gateway start --watch`
  - `hermes config path`
  - `hermes config get` (without a required path argument)
- `scripts/smoke-test-onboarding-commands.sh` verifies non-destructive command help paths are available:
  - `hermes --help`
  - `hermes gateway --help`
  - `hermes config --help`
  - `hermes logs --help`
