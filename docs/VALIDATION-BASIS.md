# Validation Basis

This repository's onboarding and safety documentation is validated against the following baseline:

- **Date:** 2026-02-17
- **Platform:** OpenClaw configuration and workspace conventions used by this repo
- **Scope:**
  - least-privilege defaults in onboarding docs
  - explicit advanced sections for higher-risk/full-access examples
  - safe-by-default backup workflow and destructive-action confirmation
  - lightweight docs safety checks in CI (`scripts/validate-docs-safety.sh`)

## Validation markers

Core onboarding docs must include a `Validated against` block:

- `README.md`
- `OPENCLAW-CONFIGURATION.md`
- `KUU-AI-SETUP-GUIDE.md`

These markers are checked by CI.
