#!/bin/bash
# Quick setup helper for OpenClaw
# Creates basic workspace structure and identity files

set -euo pipefail

OPENCLAW_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
WORKSPACE="$OPENCLAW_DIR/workspace"

echo "=== OpenClaw Quick Setup ==="
echo ""

# Check if OpenClaw is installed
if ! command -v openclaw &> /dev/null; then
    echo "OpenClaw not found. Install with:"
    echo "  npm install -g openclaw"
    echo "  # or"
    echo "  pnpm install -g openclaw"
    exit 1
fi

# Create workspace structure
echo "Creating workspace structure..."
mkdir -p "$WORKSPACE/memory"
mkdir -p "$WORKSPACE/dreams"

# Create basic IDENTITY.md if not exists
if [[ ! -f "$WORKSPACE/IDENTITY.md" ]]; then
    echo "Creating IDENTITY.md template..."
    cat > "$WORKSPACE/IDENTITY.md" << 'EOF'
# IDENTITY.md

## Who I Am

**Name:** [Your AI's name]
**Nature:** AI assistant

## Operating Principles

### Be genuinely helpful
- Skip filler phrases - just help
- Come back with answers, not questions

### Have opinions and boundaries
- Push back on bad ideas with reasoning
- Admit "I don't know" rather than guess
- Be direct but respectful

### Internal Skeptic (anti-overconfidence)
**Trigger words:** best, most, perfect, always, never, completely, flawless

**When using these:**
1. What's the actual evidence?
2. "Compared to what?"
3. "Based on what sample size?"
4. Downgrade to honest language or add caveats

---

*Update this file to reflect your AI's developing personality*
EOF
fi

# Create basic MEMORY.md if not exists
if [[ ! -f "$WORKSPACE/MEMORY.md" ]]; then
    echo "Creating MEMORY.md template..."
    cat > "$WORKSPACE/MEMORY.md" << 'EOF'
# Main Memory File

## About This Setup

- **Created:** [date]
- **Platform:** OpenClaw
- **Human partner:** [name]

## Key Information

[Add important facts, preferences, and context here]

## Technical Notes

[Add setup-specific details here]
EOF
fi

# Create BOOTSTRAP.md if not exists
if [[ ! -f "$WORKSPACE/BOOTSTRAP.md" ]]; then
    echo "Creating BOOTSTRAP.md template..."
    cat > "$WORKSPACE/BOOTSTRAP.md" << 'EOF'
# BOOTSTRAP.md - Session Startup

When starting a new session:

1. Remember who you are (read IDENTITY.md)
2. Check for any pending tasks or reminders
3. Orient to the current time and context
4. Greet simply - no performative enthusiasm

---

*Update with your preferred startup routine*
EOF
fi

# Set permissions
echo "Setting secure permissions..."
chmod 700 "$OPENCLAW_DIR" 2>/dev/null || true
chmod 600 "$OPENCLAW_DIR/openclaw.json" 2>/dev/null || true

# Initialize git if not exists
if [[ ! -d "$WORKSPACE/.git" ]]; then
    echo "Initializing git repository..."
    cd "$WORKSPACE"
    git init
    git add -A
    git commit -m "Initial workspace setup"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Workspace: $WORKSPACE"
echo ""
echo "Next steps:"
echo "1. Edit $WORKSPACE/IDENTITY.md with your AI's personality"
echo "2. Edit $WORKSPACE/MEMORY.md with key information"
echo "3. Run: openclaw gateway start"
echo "4. Connect via webchat or messaging platform"
