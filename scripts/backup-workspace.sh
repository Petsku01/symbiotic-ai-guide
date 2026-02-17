#!/bin/bash
# Backup OpenClaw workspace to a specified location (safe by default)
#
# Default behavior is DRY-RUN (non-destructive preview).
# Destructive sync requires BOTH:
#   --delete --confirm-delete
# and an interactive typed confirmation prompt.
#
# Usage:
#   ./backup-workspace.sh /path/to/backup/dir
#   ./backup-workspace.sh /path/to/backup/dir --delete --confirm-delete

set -euo pipefail

OPENCLAW_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
WORKSPACE_RAW="$OPENCLAW_DIR/workspace"
DATE="$(date +%Y-%m-%d)"

DELETE_MODE=false
CONFIRM_DELETE=false
BACKUP_DIR_INPUT=""

usage() {
    cat <<'EOF'
Usage:
  backup-workspace.sh <destination> [--delete --confirm-delete]

Modes:
  Default: Dry-run preview only (safe, no file changes)
  Delete mode: Real sync with destination deletions (requires --delete --confirm-delete)

Examples:
  backup-workspace.sh ~/Dropbox/kuu-backup
  backup-workspace.sh ~/Dropbox/kuu-backup --delete --confirm-delete
EOF
}

error() {
    echo "ERROR: $*" >&2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --delete)
            DELETE_MODE=true
            ;;
        --confirm-delete)
            CONFIRM_DELETE=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --*)
            error "Unknown flag: $1"
            usage
            exit 2
            ;;
        *)
            if [[ -z "$BACKUP_DIR_INPUT" ]]; then
                BACKUP_DIR_INPUT="$1"
            else
                error "Unexpected argument: $1"
                usage
                exit 2
            fi
            ;;
    esac
    shift
done

if [[ -z "$BACKUP_DIR_INPUT" ]]; then
    error "Destination path is required"
    usage
    exit 2
fi

if [[ "$CONFIRM_DELETE" == true && "$DELETE_MODE" == false ]]; then
    error "--confirm-delete requires --delete"
    exit 2
fi

if [[ "$DELETE_MODE" == true && "$CONFIRM_DELETE" == false ]]; then
    error "Destructive mode blocked: --delete requires --confirm-delete"
    exit 2
fi

if [[ ! -d "$WORKSPACE_RAW" ]]; then
    error "Workspace not found at $WORKSPACE_RAW"
    exit 1
fi

if ! command -v realpath >/dev/null 2>&1; then
    error "realpath command not found; cannot validate paths safely"
    exit 1
fi

WORKSPACE="$(realpath "$WORKSPACE_RAW")"
HOME_REAL="$(realpath "$HOME")"
BACKUP_DIR="$(realpath -m "$BACKUP_DIR_INPUT")"

# Safety checks for destination path
if [[ "$BACKUP_DIR" == "/" ]]; then
    error "Refusing to use '/' as backup destination"
    exit 2
fi

if [[ "$BACKUP_DIR" == "$HOME_REAL" ]]; then
    error "Refusing to use HOME directory as backup destination: $HOME_REAL"
    exit 2
fi

if [[ "$BACKUP_DIR" == "$WORKSPACE" ]]; then
    error "Refusing to backup workspace into itself"
    exit 2
fi

if [[ "$BACKUP_DIR" == "$WORKSPACE"/* ]]; then
    error "Refusing to backup into a subpath of source workspace: $BACKUP_DIR"
    exit 2
fi

# Ensure destination exists after safety checks
mkdir -p "$BACKUP_DIR"

MODE_LABEL="DRY-RUN"
if [[ "$DELETE_MODE" == true ]]; then
    MODE_LABEL="DELETE (destructive)"
fi

echo "=== Workspace Backup ==="
echo "Mode: $MODE_LABEL"
echo "Source: $WORKSPACE"
echo "Destination: $BACKUP_DIR"
echo ""

if [[ "$DELETE_MODE" == true ]]; then
    echo "⚠️  DESTRUCTIVE SYNC ENABLED (--delete)."
    echo "Type exactly: DELETE $BACKUP_DIR"
    read -r typed_confirmation
    if [[ "$typed_confirmation" != "DELETE $BACKUP_DIR" ]]; then
        error "Confirmation mismatch. Aborting destructive sync."
        exit 2
    fi
fi

# Use rsync for efficient sync (required for safe dry-run + delete semantics)
if ! command -v rsync >/dev/null 2>&1; then
    error "rsync not found. Install rsync to use this script safely."
    exit 1
fi

RSYNC_ARGS=(
    -av
    --exclude='.git'
    --exclude='*.tmp'
    --exclude='node_modules'
)

if [[ "$DELETE_MODE" == true ]]; then
    RSYNC_ARGS+=(--delete)
else
    RSYNC_ARGS+=(--dry-run --itemize-changes)
fi

echo "Running rsync..."
rsync "${RSYNC_ARGS[@]}" "$WORKSPACE/" "$BACKUP_DIR/"

if [[ "$DELETE_MODE" == true ]]; then
    SNAPSHOT="$(realpath -m "$BACKUP_DIR/../workspace-snapshot-$DATE.tar.gz")"
    if [[ ! -f "$SNAPSHOT" ]]; then
        echo ""
        echo "Creating dated snapshot..."
        tar -czf "$SNAPSHOT" -C "$OPENCLAW_DIR" workspace
        echo "Snapshot: $SNAPSHOT"
    fi
fi

echo ""
if [[ "$DELETE_MODE" == true ]]; then
    echo "Backup complete!"
    echo "Files: $(find "$BACKUP_DIR" -type f | wc -l)"
    echo "Size: $(du -sh "$BACKUP_DIR" | cut -f1)"
else
    echo "Dry-run complete (no files changed)."
    echo "To apply changes with deletions, re-run with: --delete --confirm-delete"
fi
