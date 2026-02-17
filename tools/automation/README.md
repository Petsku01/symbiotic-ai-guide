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
