# Runtime Validation Playbook (Non-Destructive)

This playbook validates command/documentation alignment on a machine with OpenClaw installed **without performing destructive actions**.

## Honesty note

- **Validated by this repo workflow:** command/help availability and docs safety checks.
- **Not validated here:** production deployment hardening, real provider billing behavior, or destructive backup operations.

## Preconditions

- You are in repo root.
- OpenClaw CLI is installed and available in `PATH`.
- No destructive flags are used.

## Step 1 — Verify CLI surface exists

```bash
openclaw --help
openclaw gateway --help
openclaw config --help
openclaw logs --help
```

### Expected outcome
- Each command exits successfully and prints non-empty help text.

### Fail signals
- `command not found`
- non-zero exit code
- empty output

## Step 2 — Run docs safety guardrail check

```bash
./scripts/validate-docs-safety.sh
```

### Expected outcome
- Output includes: `[OK] Documentation and script safety checks passed`

### What this catches
- known-invalid onboarding commands in core docs
- unsafe backup examples (`--delete` without `--confirm-delete`)
- missing validation markers
- missing backup/privacy guardrails in scripts

## Step 3 — Run onboarding smoke test

```bash
./scripts/smoke-test-onboarding-commands.sh
```

### Expected outcome
- Output includes: `[OK] Onboarding command smoke tests passed`

### Fail signals
- any help command exits non-zero
- openclaw binary missing in PATH

## Step 4 — Verify gateway command path (safe checks only)

```bash
openclaw gateway status
openclaw gateway --help
```

### Expected outcome
- status/help commands work without command drift
- no unsupported-command errors for documented baseline path

## Pass/Fail checklist

Mark each item:

- [ ] `openclaw --help` succeeds
- [ ] `openclaw gateway --help` succeeds
- [ ] `openclaw config --help` succeeds
- [ ] `openclaw logs --help` succeeds
- [ ] `./scripts/validate-docs-safety.sh` passes
- [ ] `./scripts/smoke-test-onboarding-commands.sh` passes
- [ ] `openclaw gateway status` returns valid status output

### PASS
All items checked.

### FAIL
Any unchecked item. Capture failing command output and resolve by updating local install/config or docs references.

## Notes for operators

- If your installed CLI differs from documented subcommands, treat docs as needing update and add a note in `docs/VALIDATION-BASIS.md` before broad rollout.
- Keep this playbook non-destructive; do not add backup `--delete` or system-modifying commands here.


## Publish evidence

After completing a run, document results in `docs/validation-runs/` using:

- [docs/validation-runs/README.md](validation-runs/README.md)
- [docs/validation-runs/EXAMPLE-RUN.md](validation-runs/EXAMPLE-RUN.md)
