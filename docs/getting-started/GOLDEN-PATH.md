# GOLDEN PATH (Tested Quickstart)

## Validation scope

- **Tested in this repo:** 2026-02-17 (non-destructive command/documentation validation)
- **Tested commands:**
  - `./scripts/validate-docs-safety.sh`
  - `./scripts/smoke-test-onboarding-commands.sh`
- **Untested in this document (must be validated per machine):** OS package installation steps and provider-specific API provisioning.

## 10-minute onboarding path

1. **Install OpenClaw CLI**
   - Follow: [OPENCLAW-INSTALLATION.md](../../OPENCLAW-INSTALLATION.md)
   - If any command differs on your version, run:
     ```bash
     openclaw --help
     openclaw gateway --help
     openclaw config --help
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
   - Follow: [OPENCLAW-CONFIGURATION.md](../../OPENCLAW-CONFIGURATION.md)
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
   openclaw gateway status
   openclaw --help
   ```

## Expected outcomes

- Safety/doc check returns: `[OK] Documentation and script safety checks passed`
- Smoke test returns: `[OK] Onboarding command smoke tests passed`
- CLI help commands print non-empty output
- Gateway status command returns a valid status response (running or stopped, but no command-not-found drift)

## If something fails

- Re-check command surface with `openclaw --help` and subcommand help.
- Use [docs/VALIDATION-RUNTIME-PLAYBOOK.md](../VALIDATION-RUNTIME-PLAYBOOK.md) for structured pass/fail triage.
- Publish your run evidence with [docs/validation-runs/README.md](../validation-runs/README.md).
- Review [docs/reference/FAQ.md](../reference/FAQ.md).
