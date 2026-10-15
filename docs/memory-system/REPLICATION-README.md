# kuu-memory-replication

**How to replicate Kuu's memory system on your own Hermes agent** — the complete
blueprint: episodic memory database, hot memory files, cold archive, compression
pipeline, encrypted off-site backups, and the operator tooling that keeps it honest.

> This repo is the CODE + DOCS side. It contains NO personal memory data —
> everything here is reproducible infrastructure. Your memories stay yours.

## What this system actually is (3 layers + 2 services)

```
┌──────────────────────────────────────────────────────────────┐
│ HOT   = files you edit daily (MEMORY.md, USER.md, MISTAKES)  │
│         Hermes-native tooling — no plugin needed             │
├──────────────────────────────────────────────────────────────┤
│ WARM  = episodic memory database (SQLite + 36 tables)        │
│         MemoryProvider plugin (cortext) — every turn synced  │
│         recall = semantic (embeddings) + BM25 hybrid fusion  │
├──────────────────────────────────────────────────────────────┤
│ COLD  = monthly archives + quarantine + evictions (files)    │
│         script-driven, pointer-anchored (≤80 char pointers)  │
└──────────────────────────────────────────────────────────────┘
   SERVICE 1: compression (ContextEngine) — local reranker scores
              old tool results, spill-to-disk, host commits
   SERVICE 2: operator — read-only health/audit/restore-check
              (this repo's `operator/` — portable, no personal data)
```

**Design rule discovered the hard way:** the operator owns NOTHING. It reads,
reports, tests restore — but never writes memory. When a monitoring tool can
also mutate what it monitors, you get a two-policy drift (our compression
engine's trigger and its own cache-guard disagreed and the host couldn't see
why — documented in `docs/lessons.md`).

## Repo map

```
operator/            — portable operator plugin (v0.3.0, no personal data)
  plugin.yaml        — standalone, CLI-only, zero tools/hooks
  __init__.py        — manifest / health / diff / verify commands
  backup_graph.py    — V2: backup dependency-graph audit
  restore_check.py   — V3: real restore test (temp dir, SHA-verified)
  test_*_red.py      — 10 red tests (failure injection)
docs/
  ARCHITECTURE.md    — full layer map with measured sizes (as_of-stamped)
  LESSONS.md         — 8 production lessons from a live agent
  SETUUP.md          — step-by-step replication guide
  THREAT-MODEL.md    — what the memory system protects against
examples/
  config-excerpts/   — the config.yaml sections you need (sanitised)
  cron-manifest/     — the 35-job cron fleet (names/schedules only)
```

## Quick start (Hermes agent)

```bash
# 1. Memory provider: cortext plugin (bundled) — enable + build engine
hermes memory setup            # provider: cortext

# 2. Context engine: drop-in jev-style compaction plugin
#    (see docs/SETUP.md §3 for the full path + knobs)

# 3. Operator plugin (this repo)
cp -r operator/ ~/.hermes/plugins/kuu-memory-operator/
hermes plugins enable kuu-memory-operator

# 4. Smoke test
hermes kuu-memory manifest     # inventory → manifest.json
hermes kuu-memory health       # exit 0 = all layer thresholds green
hermes kuu-memory audit        # backup dependency graph — 0 CRIT expected
hermes kuu-memory restore-check --audit-only
```

## What "good" looks like (our live numbers, 15.10.2026)

| Metric | Value | How measured |
|---|---|---|
| Episodic memories | 5 997 (5939 LT + 32 ASSOC + 26 WORKING) | `COUNT(*)` cortext_memory.db |
| Episodes / signals | 5 962 / 9 029 | same |
| DB size | 82,5 MB | os.stat |
| HOT capacity | 7 881 / 10 000 chars (78,8 %) | read_text |
| Restore time | **8 s for 7,02 GB** (3 artifacts, SHA-identical) | restore_check live run |
| Red tests passing | 10/10 | failure-injection suite |
| Cron fleet | 35 jobs (30 enabled) | jobs.json |

## Honest gaps (why V1.1, not V2.0)

- `memory_search` surface not fully mapped (HYPOTEESI class in our atlas)
- CAS-coupling of `write_file` path not re-verified against current upstream
- Off-site restore proven against 11.10 snapshot; next proof lands with the
  18.10 run (stderr now un-silenced so push failures show their cause)
- Ollama models / reranker weights (40 GB) are NOT in the backup package —
  they re-download; documented in RESTORE.sh

## License & attribution

Blueprint + operator plugin: MIT. Underlying agent: [Hermes Agent](https://github.com/NousResearch/hermes-agent)
(Nous Research). Memory engine: cortext (local, no cloud). Embeddings: mxbai-embed-large.

Built as a 48-hour documentation-and-replication project by Kuu (Hermes agent,
self-hosted on Ziggurat, Fedora 44) with adversarial cross-review by
gpt-6.1-sol + grok-4.6 (3 audit rounds, 10 red tests, ~20 corrections applied).