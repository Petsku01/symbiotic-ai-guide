# Cron fleet — ajastetut tehtävät jotka pitävät muistijärjestelmän terveenä

> Meidän tuotantofleetti (34-35 jobia); nimet + tahdit — sovita omaan ympäristöösi.
> Sisällöt (promtit/skriptit) ovat tuotantokohtaisia eivät kuulu tähän julkiseen repoon.

## Muistinevalvonta (7)

| Job | Tahti | Tehtävä |
|---|---|---|
| Memory Capacity Warning | 720 m | HOT-katto (>85%) -> arkistokandidaattilista |
| Memory Maintenance | 360 m | no_agent-orkestrointi: maintenance-aliskriptit |
| Memory Review Queue Processor | 360 m | review-jonotyökalut |
| Memory Auto-Archive | 10:35/22:35 | HOT >85% -> pointerit lyhenee + arkistointi (fail-closed) |
| Memory Promotion Gate | 10:45/22:45 | shadow-promootion apply-portti |
| Memory Lifecycle | 04:30 | TEMP >90pv -> karanteeni |
| Operator Shadow (audit+health) | 09:00 | exit 1 = CRIT-incident |

## Cortex-terveys (4)

| Job | Tahti | Tehtävä |
|---|---|---|
| Drift-Watch | 03:00 | composite-referenssi + rank-baseline |
| Episode Cleanup | 04:30 | orpo-episodit |
| Consolidate Shadow | 360 m | konsolidointivalmius |
| Prefetch Latency Watch | 07:00 | hakupolun latenssi |

## Backup + palautus (6)

| Job | Tahti | Tehtävä |
|---|---|---|
| Daily backup + EOD fallback | 23:37 | workspace-commit + push |
| EOD Memory Backup | 21:10 | muistidokumentit + arkistot + skriptit |
| Offsite backup | su 04:00 | salaus + GitHub + Proton (SHA) |
| Git Backup to GitHub | 6 h | public-repot |
| jev spill GC | 03:15 | spill-TTL |
| Daily Health Check | 10:00 | 12 checkia |

## Muut (18)

muistopohdinta, unet (dream), watchdog, gateway-sentinel, /new-request, L1-shadow,
LLM-research (3), X-scan, home cleanup, skill-graph, weekly-audit, update-check,
recurrence-audit, hybrid-consolidate-shadow, ym.

-- Yhteensä 34-35 jobia; shadow-periaate: uusi valvoja = shadow N vrkä+0 CRIT ennen promootiota.