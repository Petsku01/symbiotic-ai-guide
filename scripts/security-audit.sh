#!/bin/bash
# Security audit for OpenClaw setup
# Checks file permissions, exposed secrets, and common issues

set -euo pipefail

OPENCLAW_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== OpenClaw Security Audit ==="
echo ""

ISSUES=0
WARNINGS=0

# Check if OpenClaw directory exists
if [[ ! -d "$OPENCLAW_DIR" ]]; then
    echo -e "${RED}ERROR: OpenClaw directory not found at $OPENCLAW_DIR${NC}"
    exit 1
fi

get_perm_mode() {
    local path="$1"
    if stat -c "%a" "$path" >/dev/null 2>&1; then
        stat -c "%a" "$path"
    elif stat -f "%Lp" "$path" >/dev/null 2>&1; then
        stat -f "%Lp" "$path"
    else
        return 1
    fi
}

# Check directory permissions
echo "Checking directory permissions..."
check_dir_perms() {
    local dir="$1"
    local expected="$2"
    local name="$3"
    local perms

    if [[ -d "$dir" ]]; then
        if ! perms="$(get_perm_mode "$dir")"; then
            echo -e "${YELLOW}  WARN: Could not read permissions for $name${NC}"
            ((WARNINGS++))
            return
        fi

        if [[ "$perms" != "$expected" ]]; then
            echo -e "${YELLOW}  WARN: $name has permissions $perms (expected $expected)${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}  OK: $name ($perms)${NC}"
        fi
    fi
}

check_dir_perms "$OPENCLAW_DIR" "700" "OpenClaw root"
check_dir_perms "$OPENCLAW_DIR/credentials" "700" "Credentials dir"
check_dir_perms "$OPENCLAW_DIR/agents" "700" "Agents dir"

# Check file permissions
echo ""
echo "Checking sensitive file permissions..."
check_file_perms() {
    local file="$1"
    local expected="$2"
    local name="$3"
    local perms

    if [[ -f "$file" ]]; then
        if ! perms="$(get_perm_mode "$file")"; then
            echo -e "${YELLOW}  WARN: Could not read permissions for $name${NC}"
            ((WARNINGS++))
            return
        fi

        if [[ "$perms" != "$expected" ]]; then
            echo -e "${YELLOW}  WARN: $name has permissions $perms (expected $expected)${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}  OK: $name ($perms)${NC}"
        fi
    fi
}

check_file_perms "$OPENCLAW_DIR/openclaw.json" "600" "Main config"
check_file_perms "$OPENCLAW_DIR/exec-approvals.json" "600" "Exec approvals"

# Check for exposed secrets in workspace
echo ""
echo "Checking for exposed secrets in workspace..."
WORKSPACE="$OPENCLAW_DIR/workspace"
if [[ -d "$WORKSPACE" ]]; then
    # Look for API keys, tokens (but not in .git)
    SECRETS_FOUND=$(grep -r --include="*.md" --include="*.json" --include="*.sh" \
        -E "(sk-ant-api|sk-proj-|ghp_[a-zA-Z0-9]{36}|[a-f0-9]{64})" \
        "$WORKSPACE" 2>/dev/null | grep -v ".git" | grep -v "example" | grep -v "placeholder" | head -5 || true)
    
    if [[ -n "$SECRETS_FOUND" ]]; then
        echo -e "${RED}  CRITICAL: Possible secrets found in workspace:${NC}"
        echo "$SECRETS_FOUND" | head -3
        ((ISSUES++))
    else
        echo -e "${GREEN}  OK: No obvious secrets in workspace${NC}"
    fi
fi

# Check OpenClaw's own audit
echo ""
echo "Running OpenClaw security audit..."
if command -v openclaw &> /dev/null; then
    AUDIT_OUTPUT=$(openclaw security audit 2>&1 || true)
    if echo "$AUDIT_OUTPUT" | grep -q "0 critical"; then
        echo -e "${GREEN}  OK: OpenClaw audit passed${NC}"
    else
        echo -e "${YELLOW}  WARN: OpenClaw audit found issues:${NC}"
        echo "$AUDIT_OUTPUT" | grep -E "(CRITICAL|WARN)" | head -5
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}  SKIP: openclaw command not found${NC}"
fi

# Summary
echo ""
echo "=== Summary ==="
if [[ $ISSUES -gt 0 ]]; then
    echo -e "${RED}Critical issues: $ISSUES${NC}"
fi
if [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
fi
if [[ $ISSUES -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}All checks passed!${NC}"
fi

exit $ISSUES
