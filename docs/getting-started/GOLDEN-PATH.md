# GOLDEN PATH (Tested Quickstart)

> This is the **canonical onboarding path** for this repository. Use this first; treat installation/configuration docs as supporting reference.

## Validation scope

- **Tested in this repo:** 2026-05-11 (non-destructive command/documentation validation)
- **Tested commands:**
  - `./scripts/validate-docs-safety.sh`
  - `./scripts/smoke-test-onboarding-commands.sh`
- **Untested in this document (must be validated per machine):** OS package installation steps and provider-specific API provisioning.

## 10-minute onboarding path

1. **Install Hermes CLI**
  - Follow: [HERMES-INSTALLATION.md](../../HERMES-INSTALLATION.md)
  - If any command differs on your version, run:
  ```bash
  hermes --help
  hermes gateway --help
  hermes config --help
  ```

2. **Initialize workspace files**
  ```bash
  ./scripts/quick-setup.sh
  ```
  Optional (explicit opt-in only):
  ```bash
  ./scripts/quick-setup.sh --auto-commit
  ```

3. **Apply safe baseline config**
  - Follow: [HERMES-CONFIGURATION.md](../../HERMES-CONFIGURATION.md)
  - Use least-privilege defaults first; avoid full-access profiles unless you intentionally move to advanced trust stage.

4. **Enable local memory (recommended)**
  - Follow: [LOCAL-EMBEDDINGS-SETUP.md](../../LOCAL-EMBEDDINGS-SETUP.md)

5. **Run non-destructive validation checks**
  ```bash
  ./scripts/validate-docs-safety.sh
  ./scripts/smoke-test-onboarding-commands.sh
  ```

6. **First safe runtime check**
  ```bash
  hermes gateway status
  hermes --help
  ```

## Expected outcomes

- Safety/doc check returns: `[OK] Documentation and script safety checks passed`
- Smoke test returns: `[OK] Onboarding command smoke tests passed`
- CLI help commands print non-empty output
- Gateway status command returns a valid status response (running or stopped, but no command-not-found drift)

## If something fails

- Re-check command surface with `hermes --help` and subcommand help.
- Use [docs/VALIDATION-RUNTIME-PLAYBOOK.md](../VALIDATION-RUNTIME-PLAYBOOK.md) for structured pass/fail triage.
- Publish your run evidence with [docs/validation-runs/README.md](../validation-runs/README.md).
- Review [docs/reference/FAQ.md](../reference/FAQ.md).
