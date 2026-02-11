# Symbiotic AI Guide 🌙

*One human-AI partnership's approach to collaboration over control*

## What This Is

Documentation from a single human-AI partnership experiment running since January 2026. Not a proven methodology - a case study you can learn from or adapt.

**Scope:** One person, one AI (Kuu/Claude on OpenClaw), ~2 weeks of active development. Your results may differ.

## Quick Start

1. **[OPENCLAW-INSTALLATION.md](OPENCLAW-INSTALLATION.md)** - Get OpenClaw running
2. **Run `./scripts/quick-setup.sh`** - Creates workspace structure and templates
3. **[OPENCLAW-CONFIGURATION.md](OPENCLAW-CONFIGURATION.md)** - Configure it properly
4. **[LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md)** - Set up local memory (privacy-focused)

That's it. The rest is optional reading.

## Core Files

| File | What it is |
|------|------------|
| [OPENCLAW-INSTALLATION.md](OPENCLAW-INSTALLATION.md) | Step-by-step install guide |
| [OPENCLAW-CONFIGURATION.md](OPENCLAW-CONFIGURATION.md) | Detailed config walkthrough |
| [LOCAL-EMBEDDINGS-SETUP.md](LOCAL-EMBEDDINGS-SETUP.md) | Privacy-respecting AI memory |
| [KUU-AI-SETUP-GUIDE.md](KUU-AI-SETUP-GUIDE.md) | Philosophy and approach |
| [FAQ.md](FAQ.md) | Common questions |
| [SECURITY-IMPROVEMENTS.md](SECURITY-IMPROVEMENTS.md) | Security hardening notes |
| [INTERNAL-SKEPTIC-COMPACT.md](INTERNAL-SKEPTIC-COMPACT.md) | Anti-overconfidence rules |
| [EXTERNAL-LLM-SAFETY.md](EXTERNAL-LLM-SAFETY.md) | AI-to-AI safety guidelines |

## Scripts

Practical shell scripts in `scripts/`:

| Script | Purpose |
|--------|---------|
| `quick-setup.sh` | Create workspace structure and identity templates |
| `security-audit.sh` | Check file permissions and exposed secrets |
| `backup-workspace.sh` | Backup workspace to external location |
| `session-stats.sh` | Display session and token usage stats |
| `memory-search-test.sh` | Test memory search quality |

```bash
cd scripts && chmod +x *.sh
./quick-setup.sh
```

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

*Last updated: 2026-02-11*
