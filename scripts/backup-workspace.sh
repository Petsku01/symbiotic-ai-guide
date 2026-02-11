#!/bin/bash
# Backup OpenClaw workspace to a specified location
# Usage: ./backup-workspace.sh /path/to/backup/dir

set -euo pipefail

OPENCLAW_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
WORKSPACE="$OPENCLAW_DIR/workspace"
BACKUP_DIR="${1:-}"
DATE=$(date +%Y-%m-%d)

if [[ -z "$BACKUP_DIR" ]]; then
    echo "Usage: $0 /path/to/backup/dir"
    echo ""
    echo "Example: $0 ~/Dropbox/kuu-backup"
    exit 1
fi

if [[ ! -d "$WORKSPACE" ]]; then
    echo "ERROR: Workspace not found at $WORKSPACE"
    exit 1
fi

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

echo "=== Workspace Backup ==="
echo "Source: $WORKSPACE"
echo "Destination: $BACKUP_DIR"
echo ""

# Use rsync for efficient sync
if command -v rsync &> /dev/null; then
    echo "Syncing with rsync..."
    rsync -av --delete \
        --exclude='.git' \
        --exclude='*.tmp' \
        --exclude='node_modules' \
        "$WORKSPACE/" "$BACKUP_DIR/"
else
    echo "rsync not found, using cp..."
    cp -r "$WORKSPACE"/* "$BACKUP_DIR/"
fi

# Create dated snapshot (optional)
SNAPSHOT="$BACKUP_DIR/../workspace-snapshot-$DATE.tar.gz"
if [[ ! -f "$SNAPSHOT" ]]; then
    echo ""
    echo "Creating dated snapshot..."
    tar -czf "$SNAPSHOT" -C "$OPENCLAW_DIR" workspace
    echo "Snapshot: $SNAPSHOT"
fi

echo ""
echo "Backup complete!"
echo "Files: $(find "$BACKUP_DIR" -type f | wc -l)"
echo "Size: $(du -sh "$BACKUP_DIR" | cut -f1)"
