# Automation Scripts (Canonical vs Legacy)

Path: `tools/automation/`

Use only the `*-improved.sh` scripts for active automation. Non-improved scripts are legacy compatibility shims and should be treated as deprecated.

## Canonical vs Legacy Matrix

| Capability | Canonical (active) | Legacy (deprecated) | Migration action |
|---|---|---|---|
| Orchestration | `automation-orchestrator-improved.sh` | `automation-orchestrator.sh` | Replace invocations/cron entries with canonical script |
| Memory maintenance | `memory-maintenance-improved.sh` | `memory-maintenance.sh` | Update scheduler + docs references |
| Workspace health | `workspace-health-monitor-improved.sh` | `workspace-health-monitor.sh` | Switch direct calls to improved variant |
| System monitor | `intelligent-system-monitor-improved.sh` | `intelligent-system-monitor.sh` | Repoint monitoring jobs to improved variant |

## Migration Notes (Lightweight)

1. Search for legacy references in cron/systemd/docs:
   - `automation-orchestrator.sh`
   - `memory-maintenance.sh`
   - `workspace-health-monitor.sh`
   - `intelligent-system-monitor.sh`
2. Replace each reference with the matching `*-improved.sh` script.
3. Run one manual execution of each canonical script to confirm behavior.
4. Keep legacy scripts only for short-term rollback; do not add new dependencies on them.


## Legacy removal target

Legacy (non-improved) scripts are scheduled for removal by **v0.2.0 (2026-07-31)**.

Track policy details in [docs/reference/SCRIPT-DEPRECATION-POLICY.md](../../docs/reference/SCRIPT-DEPRECATION-POLICY.md).

## Hermes-native automation alternatives

Hermes v0.17.0 provides native CLI tools that can replace shell-based automation:

- **Cron** (`hermes cron list/create/edit/pause/resume/run/remove`): native scheduled tasks - no need for system crontab entries
- **Curator** (`hermes curator status/run/pin/unpin`): automated skill and memory maintenance
- **Skills** (`hermes skills list/search/install/config`): installable workflow packages that encapsulate common automation patterns

Consider migrating to these native tools for long-term maintainability.
