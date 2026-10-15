# ARCHITECTURE.md — layer map with measured sizes

as_of 15.10.2026 (EEST). Jokainen luku on ajettu tuotannosta — ei arvioita.
Laskentasäännöt + evidence-polut inline-rivinä (Grok-auditti vaatimus):
"mitattu" tarkoittaa levyltä/sqlite-laskua tänä päivänä.

## Kerros A — HOT (tiedot, Hermes natiivi)

| Artefakti | Mitattu | Katto | Kirjoittajat |
|---|---|---|---|
| memories/MEMORY.md | 7 881 merkkiä (78,8 %) | 10 000 | memory_tool / write_file / skriptit (flock) |
| memories/USER.md | 2 690 merkkiä (89,7 %) | 3 000 | sama |
| ~/.hermes/MISTAKES.md | 7 entryä | 15 aktiivista / 30 pv | reflektioketju |

Rakenne: entry = 1 rivi, §-erottimet rivien välissä (kaksi monirivistä lohkoa
havaittu inventoinnissa — kanoninen parseri = aukko P1).

## Kerros B — WARM (episoodimuisti)

cortext_memory.db: **82,5 MB** SQLite + WAL — 36 taulua (+sqlite_sequence=37),
45 indeksiä (+12 autoindex), 4 näkymää, vektorit 256-ulotteisia:

| Taulu | Rivit (as_of) |
|---|---|
| memories | 5 997 (5939 LONG_TERM + 32 ASSOCIATION + 26 WORKING) |
| signals | 9 029 (write_decision: 5 928 hyväksyttyä) |
| associations | 8 810 (edge_type + weight + decay — hakupolussaVielä käyttämättä) |
| episodes | 5 962 |
| memory_reconstructions | 10 443 |
| embeddings (kaikki + current) | 10 501 + 5 967 (256-dim) |

Historia: 30.7. → nykyhetki; kuorma/kk: 07:38, 08:1901, 09:2605, 10:1448 (15 pv).

## Kerros C — COLD (arkisto)

| Tiedosto | Mitattu |
|---|---|
| memory-archive/2026-09.md | 5,4 kb |
| memory-archive/2026-10.md | 22,1 kb |
| memory-archive/2026-10-user.md | 3,4 kb |
| quarantine.jsonl | 9 riviä (2,8 kb) |
| evictions.jsonl | 1 rivi (23.8) |

Canary: ARCHIVAL_canary_29.9 löytyy tiedostosta (rajoitettu todiste — ei recall-komentotestiä).

## Kerros C2 — jev spill

~/.hermes/jev-spill: **1 973 tiedostoa, 5,05 MB** — GC shadow 03:15, TTL 14 pv.

## Kerros D — Kompressio

- engine: jev_compaction (ContextEngine-plugin) — politikkan omistaja
- trigger: threshold_tokens 524 288 = 0,5 × 1 048 576 (glm-5.3-flash)
- cache-guard: skipaa kun share ≥ 0,8 JA pressure < 0,49 (FIX 14.10; vanha 0,85
  = ristiriita triggerin kanssa — lessons §1)
- daemit: hermes-jev-local-primary (service+socket, on-demand), hermes-jev-reranker

## Kerros E — Hakupolut

1. cortext_recall (semanttinen, plugin prefetch)
2. BM25-hybridi (keyword + sem; rrf-fusio) — 578 riviä skripti
3. session_search (state.db — EI cortext)
4. memory_search — HYPOTEESI (toteutusta ei VARMENTED)
5. arkistohaku — pointerit + grep

## Kerros F — Cron-fleet

**35 jobia (30 enabled / 5 disabled)** — täysi manifest examples/cron-manifest/.
Keskeiset: auto-archive (10:35/22:35), promotion-gate (10:45/22:45), operator-shadow
(09:00), health-check (10:00), drift-watch (03:00), offsite (su 04:00), EOD (21:10).

## Kerros G2 — kirjoituspolut + lukot

| Reitti | Turva | Tila |
|---|---|---|
| memory_tool | flock + atomi + drift-guard | todistettu (rev 2.1 + regressiotestit) |
| write_file/patch | file_state + advisory flock | CAS = HYPOTEESI (ei suljettu) |
| memory-write.py | CAS + flock + bak + audit | valmis, kytkeytyminen odottaa |
| operator | EI muistia — vain plugin-kansio | MITATTU |

## Kerros G3 — state.db (sessiohistoria)

~1,2 GB — sessiot + FTS-viestihaku. Eri kerros WARM:sta (ei episoodia).

## Kerros H — profiilit

~/.hermes/profiles/ = EI ole. Default-profiili kaikkiin poluihin. Multi-profile = ei käytössä.

## Kerros I — vanhahermes (kylmäkopio, EI tuotanto)

~/Documents/vanhahermes/: 14 GB WSL2-era-snapshot (22.9) — vanha cortex-kanta
(47,6 MB) + dokumentit. Palautuslähde, ei tuotantopolku.

## Kerros J — Operaattori (repot tässä: operator/)

v0.3.0 — 6 komentoa (manifest/health/diff/verify/audit/restore-check) + 10 punatestiä.
Shadow-cron 09:00. EI omista muistia. Restore-check = aito ajettava palautusketju
(temp-hakemistoon, SHA-identtiset artefaktit, 8 s / 7 GB).