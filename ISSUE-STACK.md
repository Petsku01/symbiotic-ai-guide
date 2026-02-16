# Symbiotic AI Guide — GitHub Issue Stack

## Epic

### EPIC: Stabilize onboarding, safety defaults, and repo structure
**Goal:** Make first-run success reliable, eliminate unsafe defaults, and reduce maintenance drag.

**Success criteria:**
- New user can complete setup in <15 minutes using one canonical path.
- No destructive operation runs without explicit confirmation.
- Backup/security defaults are least-privilege.
- Legacy vs current scripts/docs are unambiguous.

---

## P0 Issues (do first)

### 1) Fix command drift in core docs (canonical CLI surface)
**Labels:** `priority:P0`, `docs`, `onboarding`

**Description**
Update `OPENCLAW-INSTALLATION.md`, `OPENCLAW-CONFIGURATION.md`, `LOCAL-EMBEDDINGS-SETUP.md`, and `README.md` to one validated command path.

**Tasks**
- Add "Validated against OpenClaw version X.Y.Z" note.
- Replace outdated commands with currently supported ones.
- Add a short "If command differs, run `openclaw help`" fallback note.

**Acceptance Criteria**
- Grep audit shows no deprecated command examples in core docs.
- Fresh user can follow docs without command-not-found errors.

---

### 2) Harden backup script destructive behavior
**Labels:** `priority:P0`, `security`, `scripts`

**Description**
Add guardrails to backup flow (`--delete` behavior): default dry-run, explicit confirmation, unsafe destination checks.

**Tasks**
- Default to `--dry-run`.
- Require `--confirm-delete` + typed prompt for destructive sync.
- Block unsafe destinations (`/`, `$HOME`, source dir, subpaths of source).

**Acceptance Criteria**
- Destructive mode cannot run accidentally.
- Script exits non-zero for unsafe destination.

---

### 3) Enforce private backup defaults
**Labels:** `priority:P0`, `security`, `ops`

**Description**
Ensure backups are private by default and warn/fail for insecure destinations.

**Tasks**
- Enforce `umask 077`.
- Ensure backup dir/file perms are private (`700/600`).
- Redact sensitive paths/tokens in logs.

**Acceptance Criteria**
- Backups are not world-readable by default.
- Security check catches insecure backup perms.

---

### 4) Make auto-commit opt-in only
**Labels:** `priority:P0`, `security`, `scripts`

**Description**
Disable automatic workspace commits by default in setup scripts.

**Tasks**
- Set `AUTO_COMMIT=false` default.
- Add explicit opt-in flag for auto-commit.
- If enabled, require message template + branch safety check.

**Acceptance Criteria**
- No automatic commit happens unless explicitly requested.

---

### 5) Apply least-privilege defaults in docs and examples
**Labels:** `priority:P0`, `security`, `docs`

**Description**
Change baseline examples from broad/full permissions to minimal-safe defaults.

**Tasks**
- Add "Safe baseline" JSON snippets first.
- Move broad/full permissions to "Advanced trust stage" sections.

**Acceptance Criteria**
- Default docs path does not encourage broad privileges.

---

## P1 Issues

### 6) Rebuild README quickstart into one linear happy path
**Labels:** `priority:P1`, `docs`, `onboarding`

**Tasks**
- 10-minute path with exact sequence: install → verify → first safe run.
- Move optional/advanced paths lower.

**Acceptance Criteria**
- One clear primary path exists, optional paths explicitly marked.

---

### 7) Standardize templates and clarify required vs optional files
**Labels:** `priority:P1`, `docs`, `examples`

**Tasks**
- Canonical template source in `examples/`.
- Docs state which files are mandatory, optional, and auto-generated.
- Align `quick-setup.sh` behavior with docs.

**Acceptance Criteria**
- No contradictions between docs and setup script output.

---

### 8) Resolve legacy vs improved script ambiguity
**Labels:** `priority:P1`, `ops`, `refactor`

**Tasks**
- Mark one script path as canonical.
- Move legacy scripts to archive or deprecate with timeline.
- Add script status matrix doc.

**Acceptance Criteria**
- Users can always tell which script to run now.

---

### 9) Add explicit external-LLM outbound approval gate
**Labels:** `priority:P1`, `security`, `policy`

**Tasks**
- Update `EXTERNAL-LLM-SAFETY.md` with concrete pre-send checklist.
- Require explicit approval when data is sensitive.

**Acceptance Criteria**
- Policy is actionable/testable, not just principles.

---

## P2 Issues

### 10) Move long docs into `/docs` information architecture
**Labels:** `priority:P2`, `docs`, `structure`

**Tasks**
- Create `/docs/getting-started`, `/docs/security`, `/docs/operations`, `/docs/reference`.
- Keep root minimal (README, LICENSE, CONTRIBUTING, CHANGELOG).

**Acceptance Criteria**
- Root clutter reduced; navigation improved.

---

### 11) Add release hygiene (CHANGELOG + tags)
**Labels:** `priority:P2`, `release`, `governance`

**Tasks**
- Add `CHANGELOG.md` and first semver-style tag.
- Add PR checklist for breaking changes.

**Acceptance Criteria**
- Clear historical record of what changed and why.

---

### 12) Expand secret scanning and CI guardrails
**Labels:** `priority:P2`, `security`, `ci`

**Tasks**
- Add secret scan coverage for more file types + history.
- Add shell lint checks for risky patterns.

**Acceptance Criteria**
- CI blocks obvious leak/risky script regressions.

---

## Suggested Milestones

### Milestone A — "Safety Baseline" (P0)
Issues: 1–5

### Milestone B — "Clarity & Consistency" (P1)
Issues: 6–9

### Milestone C — "Scale & Governance" (P2)
Issues: 10–12
