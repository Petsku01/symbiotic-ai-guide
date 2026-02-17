# Automation Scripts (Canonical vs Legacy)

Path: `tools/automation/`

Use the `*-improved.sh` scripts as the canonical versions.
Legacy scripts are kept for reference and are deprecated.

| Purpose | Canonical (use this) | Legacy (deprecated) |
|---|---|---|
| Orchestration | `automation-orchestrator-improved.sh` | `automation-orchestrator.sh` |
| Memory maintenance | `memory-maintenance-improved.sh` | `memory-maintenance.sh` |
| Workspace health | `workspace-health-monitor-improved.sh` | `workspace-health-monitor.sh` |
| System monitor | `intelligent-system-monitor-improved.sh` | `intelligent-system-monitor.sh` |

## Recommendation

- New setups: only wire the **canonical improved** scripts.
- Existing setups: migrate legacy references when practical.
