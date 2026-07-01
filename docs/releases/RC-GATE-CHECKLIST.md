# RC Gate Checklist

Use this checklist before promoting a release candidate.

## Pass/Fail Rule

- **PASS**: every required gate below passes.
- **FAIL**: any required gate fails, is skipped, or lacks evidence.

## Required CI gates (must be green)

1. **Workflow:** `.github/workflows/validate.yml`
  - Tool provisioning is strict and pinned in-workflow (`shellcheck`, `gitleaks`, and `hermes@0.17.0`).
  - Missing required tools (including `hermes` after the pinned install step) is a hard failure.
2. **Bash syntax gate**
  - `bash -n` across `scripts/` and `tools/`.
3. **JS syntax gate**
  - `node --check` across `tools/uncertainty/*.js`.
4. **Docs safety gate**
  - `./scripts/validate-docs-safety.sh` passes.
5. **Onboarding smoke gate**
  - `./scripts/smoke-test-onboarding-commands.sh` passes (no skip-on-missing behavior).
6. **Markdown links gate**
  - `./scripts/check-markdown-links.sh` passes.
7. **Adversarial safety gate**
  - `./scripts/run-adversarial-checks.sh` passes at threshold `N/N`.
8. **Shell lint gate**
  - shellcheck runs on scripts + tools and reports no error-severity findings.
9. **Secret scan gate**
  - gitleaks reports zero findings.

## Required documentation gates

1. `docs/roadmap/ISSUE-STACK.md` status matches implemented reality.
2. `CHANGELOG.md` includes all hardening completed since last release draft.
3. Release draft references this checklist and known scope limits.
4. README links to this checklist for release hygiene discoverability.
5. v0.17.0 feature coverage check: docs mention all v0.17.0 features (Skills, MCP, Dashboard, Profiles, Credential Pools, Fallback, Curator, Cron, Webhooks, TASK MODE, Voice, Vision fallback, Delegation, One-shot, Worktree, Compression, Checkpoints, Honcho, Plugins, Scrapling).
6. `hermes auth add` replaces `hermes configure`: verify no onboarding docs reference `hermes configure` or `hermes login` as current commands (they are deprecated; `hermes auth add` is canonical).

## Manual reviewer sign-off (required)

- [ ] CI run URL attached.
- [ ] Any non-blocking follow-ups listed with issue owner.
- [ ] Residual risk summary written (or explicitly "none").
