# Public Validation Runs

Use this folder to publish reproducible runtime validation evidence.

## Why this exists

- Make validation claims auditable.
- Keep pass/fail evidence in one predictable location.
- Show exactly what was run, where, and with what outcome.

## File naming

Create one file per run, for example:

- `RUN-2026-02-17-local-linux.md`
- `RUN-2026-03-01-wsl2.md`

Keep `EXAMPLE-RUN.md` as the reference template.

## Required fields (must be present)

1. Run metadata
   - Date/time (timezone)
   - Runner
   - Environment (OS, shell, OpenClaw version)
   - Repo commit hash
2. Scope
   - What was validated
   - What was explicitly out of scope
3. Commands executed
   - Exact commands (copy/paste-able)
4. Results
   - Command-by-command pass/fail
   - Exit codes when available
5. Evidence
   - Relevant output excerpts
   - Failure traces (if any)
6. Final verdict
   - PASS / PARTIAL / FAIL
   - Follow-up actions

## Minimal template

```md
# Validation Run: <id>

## Metadata
- Date:
- Runner:
- Environment:
- OpenClaw version:
- Commit:

## Scope
- In scope:
- Out of scope:

## Commands
```bash
# paste exact commands
```

## Results
- [ ] <command 1> — pass/fail
- [ ] <command 2> — pass/fail

## Evidence
- Output snippet:
```
<paste key output>
```

## Verdict
- Status: PASS | PARTIAL | FAIL
- Follow-up:
```
