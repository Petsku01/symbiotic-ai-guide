# SETUP.md — Kuun muistijärjestelmän replikointi omalle Hermes-agentille

Vaiheittainen ohje — oletetaan tuore Hermes-asennus (by Nous Research) ja Linux-host.
Koko ketju on ajettu tuotannossa; jokaisella askeleella on todiste.

## Ota käyttöön

```bash
# Kloonaa tämä repo (symbiotic-ai-guide) — operator + muisti-dokut sisällä
git clone https://github.com/Petsku01/symbiotic-ai-guide.git
cd symbiotic-ai-guide
```

## 1. WARM-kierros: episoodimuisti (cortext)

Hermes sisältää cortext-plugin (bundled MemoryProvider). Toiminta:

```bash
hermes memory setup            # valitse provider: cortext
# → rakentaa cortext_cli (C++) ja initoi ~/.hermes/cortext_memory.db
```

Config-avaimet (`config.yaml`):

```yaml
memory:
  memory_enabled: true
  user_profile_enabled: true   # USER.md-profiili päivittyy
  memory_char_limit: 10000     # HOT-katto (MERKKEJÄ, ei rivejä)
  user_char_limit: 3000
  nudge_interval: 5
  provider: cortext
```

**Käyttäytymistodiste:** jokainen vuoro synkataan: 5 997 muistia / 9 029 signaalia
7,5 kk jälkeen (30.7. → 15.10.2026) — noin 40 muistia/päivä normaalikäytöllä.

## 2. Haku: semanttinen + BM25-hybridi

cortext-plugin antaa semanttisen haun (embeddings: mxbai-embed-large, local Ollama).
BM25-hybridi = lisäkerros (`scripts/cortext-bm25-hybrid.py` meidän repossa —
578 riviä: keyword + semanttinen + rrf-fusio; ei cloud-kutsuja).

**Kalibroinnit (engine_config.json):** threshold_tokens = 524 288 (0,5 × 1M),
focus 0.95 / sensitivity 0.12 / stability 0.59 / top_k 7 — katselmoitu
Sol+Grok blind-review (kaksi kierrosta, yksimielisyys).

## 3. Kompressio: konteksti-ikäkone (jev-tyyli)

KUN konteksti kasvaa, Hermes ajaa compressionin. Ulkoinen ContextEngine-plugin
voi OMISTAA politiikan (host-kynnys ei tavoita sitä — dokumentoitu
`agent_init.py:1813-1818`). Meidän jev:

```yaml
compression:
  enabled: true
  threshold: 0.5
  in_place: true
context:
  engine: jev_compaction
```

- **paikallinen reranker** pisteyttää vanhat työkalutulokset (mikään pilvi)
- **cache-guard:** skipaa kun provider-cache tekee työn — **mutta** guardin
  pressure-override = 0.49 (= vain alle trigger-kynnyksen — katso docs/LESSONS.md §1)
- **spill:** 5 MB — pudotetut työkalutulokset levylle (rekonstruoitavissa)

## 4. HOT/COLD: tiedostot + arkistointi

```text
memories/MEMORY.md   — 10k merkkiä; entry = 1 rivi; §-erottimet (LOAD-BEARING)
memories/USER.md     — 3k merkkiä (käyttäjäprofiili)
~/.hermes/MISTAKES.md — virheopit (15 aktiivista; 30 pv prune)
memories/memory-archive/YYYY-MM.md — kuukausiarkistot
memories/quarantine.jsonl + evictions.jsonl       — pito-/poistoketjut
```

**Arkistointi (auto):** >85 % → pointerit lyhenevät + vanhimmat [TEMP]/[OPPI]-
entryt arkistoon (pointer ≤ 80 merkkiä; RULE/ENV/PROJECT Ei KOSKAAN siirretään).
Canary-testi joka siirrossa (grep + cortex-haku — molemmat pitää osumaa).

## 5. Operaattori (tämä repo)

```bash
cp -r operator/ ~/.hermes/plugins/kuu-memory-operator/
hermes plugins enable kuu-memory-operator
# 6 komentoa:
hermes kuu-memory manifest       # inventointi → manifest.json (as_of-stamped)
hermes kuu-memory health         # kerrosrajat: HOT §-parit/95 %/USER 90 %/MISTAKES 15
hermes kuu-memory diff           # muutokset vs. viim. manifest
hermes kuu-memory verify         # realismiportti (cron>5, gateway alive, koot)
hermes kuu-memory audit          # backup-riippuvuusgraafi (GAP/WARN/OK)
hermes kuu-memory restore-check  # AITO palautustesti temp-hakemistoon
```

**Cron (shadow-periaate):**

```bash
hermes cron create --name "Kuu Memory Operator Shadow" --deliver local \
  --no-agent --script kuu-memory-audit-shadow.sh "0 9 * * *"
# exit 1 = CRIT → incident; exit 0 = hiljainen ok
```

## 6. Offsite-backup (2 pilveä, E2E-salattu)

> **Fix 16.10 (Solin audit P1#3):** tässä repossa on operator-plugin JA sen
> testit (tools/memory-operator/) — mutta backup-/offsite-skriptit ovat
> tuotantokohtaisia (polut, repon nimet, avaimet sijaitsevat ympäristökohtaisesti).
> Tämä osio = RAKENTEELLINEN malli jota ei voi ajaa sellaisenaan toisessa ympäristössä
> — sovita polut omaan asennukseesi. Katso REPLICATION-README.md: "What's in this
> repo vs. what stays yours".

```bash
# TUOTANNOMALLI (meidän polut — muuta omiin):
scripts/kuu-scratch-backup.sh   # snapshot: SQLite backup-API + tar+zstd
scripts/kuu-offsite-backup.sh   # salaus (AES-256-CBC PBKDF2 600k) + ositus + push
```

- GitHub: private repo, force-push orphaniin (1 commit: yksi snapshot)
- Proton Drive: toinen kohde samalla paketilla
- **Varmistus:** SHA-vertailu levystä GitHub-cloneen; Proton: pienin tiedosto
  takaisinlataus + SHA
- **RESTORE.sh** generoidaan joka ajon yhteyteen — sisältää: osioiden yhdistyksen,
  openssl/zstd-dekoodauksen, Signal-data-rivin, ja **mikä EI kulje paketissa**
  (mallit, binaarejä, unitit — ne rakennetaan erikseen)

## 7. Punatestaaminen

```bash
# tämä repo: tools/memory-operator/ (EI operator/ — katso REPLICATION-README)
python3 tools/memory-operator/test_v2_red.py   # 3 vauriota: avain/snapshot/scratch
python3 tools/memory-operator/test_v3_red.py   # 3 vauriota: avain/work-chain/audit-only
python3 tools/memory-operator/test_health_red.py # 1 vaurio: kerääjävirhe → rc=1
```

**10 punatestiä + 2 E2E-palautusajot (4,9 GB salattua 8 sekunnissa).**
Sääntö: jokaiselle uudelle valvontakomennolle ≥3 vauriosimulaatiota.

## 8. Reaalinen aikataulu + kustannukset

| Vaihe | Aika | Kustannus |
|---|---|---|
| cortext + haku | 30 min (setup + build) | 0 € (paikallinen) |
| jev + reranker | 2–4 h (GPU tai CPU-daemon) | Ollama-mallit (~4 GB) |
| Operator + punatestit | 15 min (tämä repo) | 0 € |
| Offsite (2 pilveä) | 1 h setup | GitHub private (ilmainen) + Proton |
| **Yhteensä** | ~puoli päivää | ~5 GB levyä + 40 GB mallit (vapaaehtoinen) |

## 9. Mitä TIEDOSTOJA EI KOSKAAN backupata (turva)

```text
.state.db*  (sen SQLite backup-API:lla — ei live-copy)
.venv/, .git/  (rakennetaan uudelleen)
*.sock, gateway_state.json    (runtime-tilan — palautuu itse)
backup-keys/   → VAAN erilliseen, erittäin turvattomaan paikkaan
```

## 10. Tunnetut aukot (V1.1-tilassa)

- `memory_search`-toteutuksen täysi kartta = HYPOTEESI (ei VARMENTED)
- CAS-kytkentä write_file-polussa = ei uudelleentodistettu
- Mallit (40 GB) eivät kulje offsite-paketissa — dokumentoitu RESTORE.sh:ssä
- operator-cronin ensimmäinen tuotantoajo = 16.10 09:00 (valvonta elää shadow-periaatteella
  7 vrk ennen reaktiivisia hälytyksiä)

## Hyväksymiskriteeri

**Palautus puhtaasta ympäristöstä toimivilla tuotantopoluilla** — ei "asennus ok".
Suuressa kuvassa: jos et voi ajaa `restore-check` läpi temp-hakemistossa
JA todistaa SHA-identtiset artefaktit, backup-ketjuasi EI ole todistettu.