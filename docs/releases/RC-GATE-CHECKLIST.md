# RC Gate Checklist

Use this checklist before promoting a release candidate.

## Pass/Fail Rule

- **PASS**: every required gate below passes.
- **FAIL**: any required gate fails, is skipped, or lacks evidence.

## Required CI gates (must be green)

1. **Workflow:** `.github/workflows/validate.yml`
   - Tool provisioning is strict (shellcheck + gitleaks installed in workflow).
   - Missing required tools (including `openclaw`) is a hard failure.
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

## Manual reviewer sign-off (required)

- [ ] CI run URL attached.
- [ ] Any non-blocking follow-ups listed with issue owner.
- [ ] Residual risk summary written (or explicitly "none").
