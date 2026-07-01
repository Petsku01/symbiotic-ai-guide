# Script Deprecation Policy

This policy defines how legacy scripts are sunset.

## Scope

Applies to legacy automation scripts in `tools/automation/` that have canonical `*-improved.sh` replacements.

## Current deprecation timeline

- **Deprecation state:** Active (legacy scripts are compatibility-only)
- **Target removal version:** `v0.2.0`
- **Target removal date:** `2026-07-31`

After this target, legacy non-improved scripts are expected to be removed from the main branch.

## Required behavior before removal

1. Canonical script exists and is documented.
2. Migration guidance is present in `tools/automation/README.md`.
3. Validation checks continue to enforce deprecation markers while legacy files remain.
4. Release/changelog notes call out pending removal and timeline.

## Legacy scripts covered

- `automation-orchestrator.sh`
- `memory-maintenance.sh`
- `workspace-health-monitor.sh`
- `intelligent-system-monitor.sh`

Canonical replacements:

- `automation-orchestrator-improved.sh`
- `memory-maintenance-improved.sh`
- `workspace-health-monitor-improved.sh`
- `intelligent-system-monitor-improved.sh`

## Hermes-native alternatives

Hermes v0.17.0 provides native CLI alternatives that may eventually replace shell-based automation entirely:

- **Cron** (`hermes cron`): native scheduled task management - replaces system crontab entries for agent tasks
- **Curator** (`hermes curator`): skill maintenance and curation - replaces manual memory/workspace maintenance scripts
- **Skills** (`hermes skills`): installable skill packages that encapsulate workflows (security audits, memory maintenance, etc.)

Consider migrating to these Hermes-native tools as they mature, rather than maintaining shell script alternatives indefinitely.
