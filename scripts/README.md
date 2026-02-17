# Scripts

Practical shell scripts for managing an OpenClaw setup.

## Quick Start

```bash
# Make scripts executable
chmod +x *.sh

# Run quick setup (creates workspace structure; no auto-commit by default)
./quick-setup.sh

# Optional: include initial git commit for a new workspace
./quick-setup.sh --auto-commit
```

## Available Scripts

| Script | Purpose |
|--------|---------|
| `quick-setup.sh` | Create workspace structure and identity templates (optional `--auto-commit`) |
| `security-audit.sh` | Check file permissions and exposed secrets |
| `backup-workspace.sh` | Backup workspace to external location (private destination directory required) |
| `session-stats.sh` | Display session and token usage stats |
| `memory-search-test.sh` | Test memory search quality |

## Usage Examples

```bash
# Initial setup
./quick-setup.sh

# Run security check
./security-audit.sh

# Backup to cloud folder (dry-run)
./backup-workspace.sh ~/Dropbox/ai-backup

# Apply destructive sync only with explicit confirmation flags
./backup-workspace.sh ~/Dropbox/ai-backup --delete --confirm-delete

# Check session status
./session-stats.sh

# Test memory search
./memory-search-test.sh
```

## Requirements

- OpenClaw installed (`npm install -g openclaw`)
- Bash shell
- Standard Unix tools (grep, stat, rsync)

## Notes

- Scripts assume default OpenClaw paths (`~/.openclaw`)
- Set `OPENCLAW_STATE_DIR` environment variable to override
- All scripts are non-destructive (won't overwrite existing files)
