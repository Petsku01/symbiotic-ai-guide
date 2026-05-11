#!/bin/bash
# Automated Monitoring Setup for Hermes

echo "IMPLEMENTATION:  Setting up Hermes monitoring automation..."

# Prefer explicit workspace, then inferred repo root, then default Hermes workspace.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKSPACE="${HERMES_WORKSPACE:-$REPO_ROOT}"
TOOLS_DIR="$WORKSPACE/tools/monitoring"

# Create systemd user timer for performance monitoring
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/hermes-monitor.service << SYSTEMD_EOF
[Unit]
Description=Hermes Performance Monitor
After=hermes-gateway.service

[Service]
Type=oneshot
ExecStart=$TOOLS_DIR/hermes-monitor.sh
StandardOutput=journal
StandardError=journal
SYSTEMD_EOF

cat > ~/.config/systemd/user/hermes-monitor.timer << TIMER_EOF
[Unit]
Description=Run Hermes monitor every 15 minutes
Requires=hermes-monitor.service

[Timer]
OnCalendar=*:0/15
Persistent=true

[Install]
WantedBy=timers.target
TIMER_EOF

echo "OK: Created systemd monitoring service and timer"

# Reload and enable
systemctl --user daemon-reload
systemctl --user enable hermes-monitor.timer
systemctl --user start hermes-monitor.timer

echo "OK: Automated monitoring enabled - runs every 15 minutes"
echo "METRICS: Check status with: systemctl --user status hermes-monitor.timer"
echo ""
echo "FIX: Manual monitoring commands:"
echo "  Performance: $TOOLS_DIR/hermes-monitor.sh"
echo "  Network: $TOOLS_DIR/network-health-check.sh"
echo "  Optimization: $TOOLS_DIR/hermes-optimizer.sh"
