#!/bin/bash
# Automated Monitoring Setup for OpenClaw

echo "IMPLEMENTATION:  Setting up OpenClaw monitoring automation..."

# Prefer explicit workspace, then inferred repo root, then default OpenClaw workspace.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKSPACE="${OPENCLAW_WORKSPACE:-$REPO_ROOT}"
TOOLS_DIR="$WORKSPACE/tools/monitoring"

# Create systemd user timer for performance monitoring
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/openclaw-monitor.service << SYSTEMD_EOF
[Unit]
Description=OpenClaw Performance Monitor
After=openclaw-gateway.service

[Service]
Type=oneshot
ExecStart=$TOOLS_DIR/openclaw-monitor.sh
StandardOutput=journal
StandardError=journal
SYSTEMD_EOF

cat > ~/.config/systemd/user/openclaw-monitor.timer << TIMER_EOF
[Unit]
Description=Run OpenClaw monitor every 15 minutes
Requires=openclaw-monitor.service

[Timer]
OnCalendar=*:0/15
Persistent=true

[Install]
WantedBy=timers.target
TIMER_EOF

echo "OK: Created systemd monitoring service and timer"

# Reload and enable
systemctl --user daemon-reload
systemctl --user enable openclaw-monitor.timer
systemctl --user start openclaw-monitor.timer

echo "OK: Automated monitoring enabled - runs every 15 minutes"
echo "METRICS: Check status with: systemctl --user status openclaw-monitor.timer"
echo ""
echo "FIX: Manual monitoring commands:"
echo "  Performance: $TOOLS_DIR/openclaw-monitor.sh"
echo "  Network: $TOOLS_DIR/network-health-check.sh"  
echo "  Optimization: $TOOLS_DIR/openclaw-optimizer.sh"
