# Symbiotic AI Guide — Issue Stack (Status)

## Epic

### EPIC: Stabilize onboarding, safety defaults, and repo structure
**Goal:** Make first-run success reliable, eliminate unsafe defaults, and reduce maintenance drag.

**Success criteria:**
- New user can complete setup in <15 minutes using one canonical path.
- No destructive operation runs without explicit confirmation.
- Backup/security defaults are least-privilege.
- Legacy vs current scripts/docs are unambiguous.

---

## P0 Issues

### 1) ✅ DONE — Fix command drift in core docs (canonical CLI surface)
**Status notes:** Validation markers + denylist checks are in place; smoke-test script added for non-destructive CLI help commands.

### 2) ✅ DONE — Harden backup script destructive behavior
**Status notes:** destructive mode is gated; explicit confirmation required for delete flow; unsafe destinations blocked.

### 3) ✅ DONE — Enforce private backup defaults
**Status notes:** private umask and destination permission checks are enforced.

### 4) ✅ DONE — Make auto-commit opt-in only
**Status notes:** setup defaults to no auto-commit; explicit flag required.

### 5) ✅ DONE — Apply least-privilege defaults in docs and examples
**Status notes:** onboarding path documents least-privilege baseline; higher-risk examples are scoped to advanced sections.

---

## P1 Issues

### 6) ✅ DONE — Rebuild README quickstart into one linear happy path
**Status notes:** README now points prominently to one tested quickstart at `docs/getting-started/GOLDEN-PATH.md`.

### 7) 🟡 OPEN — Standardize templates and clarify required vs optional files
**Remaining work:** explicit required/optional matrix across docs + examples, and final contradiction pass vs `quick-setup.sh` output.

### 8) 🟡 OPEN — Resolve legacy vs improved script ambiguity
**Remaining work:** publish a script status matrix and deprecation timeline for non-canonical variants.

### 9) 🟡 OPEN — Add explicit external-LLM outbound approval gate
**Remaining work:** add concrete, testable pre-send checklist + sensitive-data approval flow to `docs/security/EXTERNAL-LLM-SAFETY.md`.

---

## P2 Issues

### 10) ✅ DONE — Move long docs into `/docs` information architecture
**Status notes:** non-core root docs moved under `docs/` with updated references.

### 11) ✅ DONE — Add release hygiene (CHANGELOG + tags)
**Status notes:** `CHANGELOG.md` added.  
**Remaining work:** create first semver tag and add PR checklist item for breaking changes.

### 12) 🟡 OPEN — Expand secret scanning and CI guardrails
**Remaining work:** broaden secret scan/file coverage and add shell lint checks for risky patterns.

---

## Milestones

### Milestone A — "Safety Baseline"
**State:** ✅ Complete (Issues 1–5)

### Milestone B — "Clarity & Consistency"
**State:** 🟡 In progress (Issue 6 complete; 7–9 open)

### Milestone C — "Scale & Governance"
**State:** 🟡 In progress (Issues 10–11 complete; 12 open + tagging follow-up)
