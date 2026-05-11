# Validation Run: RUN-YYYY-MM-DD-ENV

## Metadata
- Date: 2026-02-17 19:00 Europe/Helsinki
- Runner: <name-or-handle>
- Environment: <OS / distro / shell>
- Hermes version: <version>
- Commit: `<git-sha>`

## Scope
- In scope:
  - `./scripts/validate-docs-safety.sh`
  - `./scripts/smoke-test-onboarding-commands.sh`
- Out of scope:
  - Destructive backup operations
  - Provider billing/runtime production behavior

## Commands
```bash
./scripts/validate-docs-safety.sh
./scripts/smoke-test-onboarding-commands.sh
```

## Results
- [ ] `./scripts/validate-docs-safety.sh` — PASS/FAIL
- [ ] `./scripts/smoke-test-onboarding-commands.sh` — PASS/FAIL

## Evidence
### Pass evidence example
```
[OK] Documentation and script safety checks passed
[OK] Onboarding command smoke tests passed
```

### Fail evidence example
```
[FAIL] Missing required file: docs/operations/STATUS-SYNC-POLICY.md
exit code: 1
```

## Verdict
- Status: PASS | PARTIAL | FAIL
- Follow-up actions:
  - <action 1>
  - <action 2>
