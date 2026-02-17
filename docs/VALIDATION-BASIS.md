# Validation Basis

This repository's onboarding and safety documentation is validated against the following baseline:

- **Date:** 2026-02-17
- **Platform:** OpenClaw configuration and workspace conventions used by this repo
- **Scope:**
  - least-privilege defaults in onboarding docs
  - explicit advanced sections for higher-risk/full-access examples
  - safe-by-default backup workflow and destructive-action confirmation
  - denylist enforcement for known-invalid OpenClaw command patterns in core onboarding docs
  - lightweight docs safety checks in CI (`scripts/validate-docs-safety.sh`)
  - non-destructive onboarding command smoke tests (`scripts/smoke-test-onboarding-commands.sh`)

## Validation markers

Core onboarding docs must include a `Validated against` block:

- `README.md`
- `OPENCLAW-CONFIGURATION.md`
- `KUU-AI-SETUP-GUIDE.md`

These markers are checked by CI.

## Safeguards added

- `scripts/validate-docs-safety.sh` blocks known-invalid onboarding command patterns:
  - `openclaw config init`
  - `openclaw config patch`
  - `openclaw gateway logs`
  - `openclaw chat`
  - `openclaw gateway start --watch`
  - `openclaw config path`
- `scripts/smoke-test-onboarding-commands.sh` verifies non-destructive command help paths are available:
  - `openclaw --help`
  - `openclaw gateway --help`
  - `openclaw config --help`
  - `openclaw logs --help`
