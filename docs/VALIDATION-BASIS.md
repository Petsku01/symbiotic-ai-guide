# Validation Basis

This repository's onboarding and safety documentation is validated against the following baseline:

- **Date:** 2026-07-01
- **Platform:** Hermes configuration and workspace conventions used by this repo
- **Scope:**
  - least-privilege defaults in onboarding docs
  - explicit advanced sections for higher-risk/full-access examples
  - safe-by-default backup workflow and destructive-action confirmation
  - denylist enforcement for known-invalid Hermes command patterns in core onboarding docs
  - lightweight docs safety checks in CI (`scripts/validate-docs-safety.sh`)
  - non-destructive onboarding command smoke tests (`scripts/smoke-test-onboarding-commands.sh`)
  - fail-closed CI provisioning of pinned `hermes@0.17.0` before onboarding smoke checks

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

## v0.17.0 CLI surface smoke tests

Additional smoke test commands for v0.17.0 feature coverage:

- `hermes auth --help`
- `hermes skills --help`
- `hermes mcp --help`
- `hermes cron --help`
- `hermes dashboard --help`
- `hermes profile --help`
- `hermes curator --help`
- `hermes webhook --help`

## v0.17.0 config field validation

The following config fields must be present or accounted for in `config.yaml`:

- `config_version`: must be `30`
- `agent.system_prompt`: optional string for TASK MODE (prepends to every session)
- `security.redact_secrets`: boolean, default `true` since v0.13.0
- `privacy.redact_pii`: boolean, default `false`
- `approvals.mode`: enum `manual` (default) / `smart` / `off`
