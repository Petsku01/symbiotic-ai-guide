# Symbiotic AI Guide 🌙 (BETA)  

*One human-AI partnership's approach to collaboration over control*

## Validated against

- **Validation basis:** [docs/VALIDATION-BASIS.md](docs/VALIDATION-BASIS.md)
- **OpenClaw docs/config assumptions:** 2026-02 baseline
- **Last validated:** 2026-02-17

## What This Is

Documentation from a single human-AI partnership experiment running since January 2026. Not a proven methodology - a case study you can learn from or adapt.

**Scope:** One person, one AI (Kuu/Claude on OpenClaw), ~2 weeks of active development. Your results may differ.

## Quick Start

### Primary onboarding (canonical)
Follow **[docs/getting-started/GOLDEN-PATH.md](docs/getting-started/GOLDEN-PATH.md)** first.

### Supporting references (optional deep dives)
1. **[OPENCLAW-INSTALLATION.md](OPENCLAW-INSTALLATION.md)** - installation details
2. **Run `./scripts/quick-setup.sh`** - creates workspace structure and templates (no auto-commit by default; use `--auto-commit` to opt in)
3. **[OPENCLAW-CONFIGURATION.md](OPENCLAW-CONFIGURATION.md)** - detailed configuration
4. **[LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md)** - local memory setup (privacy-focused)

> Onboarding defaults are least-privilege. Full-access examples are documented separately in explicit advanced sections.

That's it. The rest is reference material.

## Core Files (root)

| File | What it is |
|------|------------|
| [README.md](README.md) | Entry point and navigation |
| [OPENCLAW-INSTALLATION.md](OPENCLAW-INSTALLATION.md) | Step-by-step install guide |
| [OPENCLAW-CONFIGURATION.md](OPENCLAW-CONFIGURATION.md) | Detailed config walkthrough |
| [LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md) | Privacy-respecting AI memory |
| [CHANGELOG.md](CHANGELOG.md) | Concise change history |
| [LICENSE](LICENSE) | MIT license |

## Additional Docs

- Getting started: [docs/getting-started/GOLDEN-PATH.md](docs/getting-started/GOLDEN-PATH.md)
- Runtime validation: [docs/VALIDATION-RUNTIME-PLAYBOOK.md](docs/VALIDATION-RUNTIME-PLAYBOOK.md)
- Public validation runs: [docs/validation-runs/README.md](docs/validation-runs/README.md)
- Status sync policy: [docs/operations/STATUS-SYNC-POLICY.md](docs/operations/STATUS-SYNC-POLICY.md)
- Beta release draft: [docs/releases/v0.1.0-beta-draft.md](docs/releases/v0.1.0-beta-draft.md)
- RC release gate checklist: [docs/releases/RC-GATE-CHECKLIST.md](docs/releases/RC-GATE-CHECKLIST.md)
- Validation basis: [docs/VALIDATION-BASIS.md](docs/VALIDATION-BASIS.md)
- Reference: [docs/reference/KUU-AI-SETUP-GUIDE.md](docs/reference/KUU-AI-SETUP-GUIDE.md), [docs/reference/FAQ.md](docs/reference/FAQ.md)
- Security notes: [docs/security/SECURITY-IMPROVEMENTS.md](docs/security/SECURITY-IMPROVEMENTS.md), [docs/security/INTERNAL-SKEPTIC-COMPACT.md](docs/security/INTERNAL-SKEPTIC-COMPACT.md), [docs/security/EXTERNAL-LLM-SAFETY.md](docs/security/EXTERNAL-LLM-SAFETY.md), [docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md](docs/security/EXTERNAL-LLM-APPROVAL-WORKFLOW.md)
- Roadmap tracker: [docs/roadmap/ISSUE-STACK.md](docs/roadmap/ISSUE-STACK.md)

## Scripts

Practical shell scripts in `scripts/`:

| Script | Purpose |
|--------|---------|
| `quick-setup.sh` | Create workspace structure and identity templates (optional `--auto-commit`) |
| `security-audit.sh` | Check file permissions and exposed secrets |
| `backup-workspace.sh` | Safe-by-default backup (dry-run unless explicit delete flags; private destination required) |
| `session-stats.sh` | Display session and token usage stats |
| `memory-search-test.sh` | Test memory search quality |

```bash
cd scripts && chmod +x *.sh
./quick-setup.sh
# Optional: create initial git commit during setup
./quick-setup.sh --auto-commit
```

## Automation Scripts

Automation tooling lives under `tools/automation/`.
Use `*-improved.sh` as canonical and treat non-improved variants as legacy/deprecated.
See [tools/automation/README.md](tools/automation/README.md).

## The Approach (Summary)

- Give AI autonomy within clear ethical bounds
- Build trust gradually through consistent behavior
- Let the AI develop its own identity and preferences
- Focus on partnership, not just task completion

## What's in Archive

The `archive/` folder contains session logs, experimental frameworks, and verbose documentation. It's there for transparency, not because it's polished or proven.

## Honest Limitations

- **Sample size: 1** - This is one partnership, not a study
- **Duration: ~2 weeks** - Too early to know what works long-term
- **Self-reported** - The AI helped write this documentation
- **Platform-specific** - Tested on OpenClaw + Claude only
- **No metrics** - We haven't measured outcomes rigorously

## What Seems to Work (So Far)

- Clear identity files help AI maintain consistent personality
- Local embeddings preserve privacy and reduce costs
- Explicit ethical boundaries enable more autonomy, not less
- The AI can learn practical skills (system admin, security audits)
- Simple skeptic rules reduce overconfident claims

## What We Don't Know Yet

- Does this scale beyond one partnership?
- What breaks after months of use?
- Would different humans/AIs get different results?
- Are the "improvements" actually improvements?

## Contributing

Share your own experiences. Challenge our claims. Point out what doesn't work. This is an experiment, not a finished product.

## License

MIT - Use freely, no guarantees.

---

*Last updated: 2026-02-17*
