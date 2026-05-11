#!/bin/bash

# Automation Orchestrator - Improved Version
# Coordinates all automation systems with enhanced security, error handling, and reliability

# Load shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh" || {
  echo "ERROR: Failed to load shared functions" >&2
  exit 1
}

# Error handling configuration
set -euo pipefail
trap 'echo "ERROR: Error on line $LINENO. Exit code: $?" >&2; cleanup_and_exit 1' ERR

# Configuration with portable defaults
WORKSPACE="${HERMES_WORKSPACE:-${HOME}/.hermes/workspace}"
AUTOMATION_DIR="$WORKSPACE/tools/automation"
TMPDIR=$(get_secure_tmpdir)
LOG_FILE="$TMPDIR/automation-orchestrator.log"
LOCK_FILE="$TMPDIR/automation-orchestrator.lock"

# Tool configuration with improved versions prioritized
declare -A AUTOMATION_TOOLS=(
  ["memory"]="memory-maintenance-improved.sh"
  ["workspace"]="workspace-health-monitor-improved.sh"
  ["system"]="intelligent-system-monitor-improved.sh"
)

# Global cleanup function
cleanup_and_exit() {
  local exit_code=${1:-0}
  release_lock "$LOCK_FILE" 2>/dev/null || true
  exit "$exit_code"
}

# Setup cleanup on script termination
setup_cleanup_trap cleanup_and_exit

# Initialize secure orchestration environment
initialize_orchestration() {
  echo "ORCHESTRATOR: Automation Orchestrator - $(date)"

  # Validate configuration
  if ! validate_config "$WORKSPACE"; then
  echo "ERROR: Environment validation failed" >&2
  return 1
  fi

  # Verify automation directory
  if [[ ! -d "$AUTOMATION_DIR" ]]; then
  echo "ERROR: Automation directory not found: $AUTOMATION_DIR" >&2
  return 1
  fi

  # Create secure log file
  if ! create_secure_log "$LOG_FILE"; then
  echo "ERROR: Failed to create secure log file" >&2
  return 1
  fi

  # Acquire lock to prevent concurrent orchestration
  if ! acquire_lock "$LOCK_FILE" 60; then  # Longer timeout for orchestration
  echo "ERROR: Another orchestrator is already running" >&2
  return 1
  fi

  echo "================================================" | tee "$LOG_FILE"
  echo "Starting coordinated automation orchestration..." | tee -a "$LOG_FILE"

  return 0
}

# Function: Verify automation prerequisites safely
check_automation_prerequisites() {
  echo "" | tee -a "$LOG_FILE"
  echo "CHECK: CHECKING AUTOMATION PREREQUISITES:" | tee -a "$LOG_FILE"

  local available_tools=0
  local total_tools=${#AUTOMATION_TOOLS[@]}
  local missing_tools=()

  for tool_name in "${!AUTOMATION_TOOLS[@]}"; do
  local tool_script="${AUTOMATION_TOOLS[$tool_name]}"
  local tool_path="$AUTOMATION_DIR/$tool_script"

  if [[ -f "$tool_path" && -x "$tool_path" ]]; then
  ((available_tools++))
  echo "  OK: $tool_name: $tool_script available" | tee -a "$LOG_FILE"
  else
  missing_tools+=("$tool_name:$tool_script")
  echo "  ERROR: $tool_name: $tool_script not found or not executable" | tee -a "$LOG_FILE"
  fi
  done

  echo "  METRICS: Tool availability: $available_tools/$total_tools tools ready" | tee -a "$LOG_FILE"

  if (( available_tools == 0 )); then
  echo "  CRITICAL: Critical: No automation tools available" | tee -a "$LOG_FILE"
  return 1
  elif (( ${#missing_tools[@]} > 0 )); then
  echo "  WARNING:  Missing tools detected, continuing with available tools" | tee -a "$LOG_FILE"
  fi

  # Check shared functions
  if [[ ! -f "$AUTOMATION_DIR/shared-functions.sh" ]]; then
  echo "  WARNING:  Shared functions not available - tools may have limited safety features" | tee -a "$LOG_FILE"
  else
  echo "  OK: Shared functions available" | tee -a "$LOG_FILE"
  fi

  return 0
}

# Function: Execute automation tool safely with comprehensive error handling
execute_automation_tool() {
  local tool_name="$1"
  local tool_script="${AUTOMATION_TOOLS[$tool_name]}"
  local tool_path="$AUTOMATION_DIR/$tool_script"

  echo "" | tee -a "$LOG_FILE"
  echo "AUTOMATION: EXECUTING $(echo "$tool_name" | tr '[:lower:]' '[:upper:]') AUTOMATION:" | tee -a "$LOG_FILE"

  # Verify tool availability
  if [[ ! -f "$tool_path" ]]; then
  echo "  ERROR: Tool not found: $tool_path" | tee -a "$LOG_FILE"
  return 1
  fi

  if [[ ! -x "$tool_path" ]]; then
  echo "  ERROR: Tool not executable: $tool_path" | tee -a "$LOG_FILE"
  return 1
  fi

  # Create isolated environment for tool execution
  local tool_env=(
  "HERMES_WORKSPACE=$WORKSPACE"
  "PATH=$PATH"
  "HOME=$HOME"
  )

  # Execute tool with timeout and error handling
  local tool_output tool_exit_code
  echo "  START:  Starting $tool_name automation..." | tee -a "$LOG_FILE"

  if tool_output=$(timeout 300 env "${tool_env[@]}" "$tool_path" 2>&1); then
  tool_exit_code=0
  echo "  OK: $tool_name automation completed successfully" | tee -a "$LOG_FILE"
  else
  tool_exit_code=$?
  if (( tool_exit_code == 124 )); then
  echo "  ERROR: $tool_name automation timed out (5 minutes)" | tee -a "$LOG_FILE"
  else
  echo "  ERROR: $tool_name automation failed with exit code: $tool_exit_code" | tee -a "$LOG_FILE"
  fi
  fi

  # Extract key findings from tool output safely
  echo "  METRICS: Key findings:" | tee -a "$LOG_FILE"

  # Safe output analysis with error handling
  if [[ -n "$tool_output" ]]; then
  # Extract completion status
  if echo "$tool_output" | grep -q "COMPLETE"; then
  local completion_line
  completion_line=$(echo "$tool_output" | grep "COMPLETE" | tail -1 | sed 's/^[^A-Z]*//')
  echo "  • Status: $completion_line" | tee -a "$LOG_FILE"
  fi

  # Extract warnings/alerts
  local warnings
  warnings=$(echo "$tool_output" | grep -c "WARNING:\|CRITICAL:" || echo 0)
  if (( warnings > 0 )); then
  echo "  • Warnings/alerts detected: $warnings" | tee -a "$LOG_FILE"
  fi

  # Tool-specific extractions with error handling
  case "$tool_name" in
  "memory")
  local memory_findings
  if memory_findings=$(echo "$tool_output" | grep -o "Cross-reference.*current\|Hermes.*files" | head -2); then
  while IFS= read -r finding; do
  [[ -n "$finding" ]] && echo "  • $finding" | tee -a "$LOG_FILE"
  done <<< "$memory_findings"
  fi
  ;;
  "workspace")
  local workspace_findings
  if workspace_findings=$(echo "$tool_output" | grep -o "Root directory.*optimal\|Project.*: [0-9]* files" | head -2); then
  while IFS= read -r finding; do
  [[ -n "$finding" ]] && echo "  • $finding" | tee -a "$LOG_FILE"
  done <<< "$workspace_findings"
  fi
  ;;
  "system")
  local system_findings
  if system_findings=$(echo "$tool_output" | grep -o "Memory trend:.*\|WebSocket.*detected" | head -2); then
  while IFS= read -r finding; do
  [[ -n "$finding" ]] && echo "  • $finding" | tee -a "$LOG_FILE"
  done <<< "$system_findings"
  fi
  ;;
  esac
  else
  echo "  • No output captured from tool execution" | tee -a "$LOG_FILE"
  fi

  return $tool_exit_code
}

# Function: Generate integrated analysis from all tool results
generate_integrated_analysis() {
  echo "" | tee -a "$LOG_FILE"
  echo "ANALYSIS: INTEGRATED CROSS-SYSTEM ANALYSIS:" | tee -a "$LOG_FILE"

  # Analyze log files from individual tools safely
  local tmpdir_pattern="$TMPDIR"
  local available_logs=()

  # Collect available tool logs
  for log_type in "memory-maintenance" "workspace-health" "intelligent-system-monitor"; do
  local log_file="$tmpdir_pattern/$log_type.log"
  if [[ -f "$log_file" && -r "$log_file" ]]; then
  available_logs+=("$log_file")
  fi
  done

  echo "  METRICS: Analyzing ${#available_logs[@]} automation log files..." | tee -a "$LOG_FILE"

  if (( ${#available_logs[@]} == 0 )); then
  echo "  WARNING:  No automation logs available for integrated analysis" | tee -a "$LOG_FILE"
  return 1
  fi

  # Cross-system pattern recognition
  local total_warnings total_optimizations
  total_warnings=0
  total_optimizations=0

  for log_file in "${available_logs[@]}"; do
  local log_warnings log_optimizations

  if log_warnings=$(grep -c "WARNING:\|CRITICAL:" "$log_file" 2>/dev/null || echo 0); then
  ((total_warnings += log_warnings))
  fi

  if log_optimizations=$(grep -c "OK:.*optimal\|OK:.*successful" "$log_file" 2>/dev/null || echo 0); then
  ((total_optimizations += log_optimizations))
  fi
  done

  echo "  STRATEGY: Cross-system insights:" | tee -a "$LOG_FILE"
  echo "  • Total optimization successes: $total_optimizations" | tee -a "$LOG_FILE"
  echo "  • Total warnings across systems: $total_warnings" | tee -a "$LOG_FILE"

  # System health assessment
  if (( total_warnings == 0 )); then
  echo "  • Overall system health: EXCELLENT" | tee -a "$LOG_FILE"
  elif (( total_warnings <= 3 )); then
  echo "  • Overall system health: GOOD (minor issues)" | tee -a "$LOG_FILE"
  elif (( total_warnings <= 10 )); then
  echo "  • Overall system health: FAIR (attention needed)" | tee -a "$LOG_FILE"
  else
  echo "  • Overall system health: POOR (multiple issues)" | tee -a "$LOG_FILE"
  fi

  return 0
}

# Function: Generate coordinated recommendations
generate_coordinated_recommendations() {
  echo "" | tee -a "$LOG_FILE"
  echo "STRATEGY: COORDINATED OPTIMIZATION STRATEGY:" | tee -a "$LOG_FILE"

  # Time-based recommendations
  local current_hour current_day
  current_hour=$(date +%H)
  current_day=$(date +%u)  # 1=Monday, 7=Sunday

  echo "  SCHEDULE: Context-aware scheduling:" | tee -a "$LOG_FILE"

  if (( current_day == 7 )); then  # Sunday
  echo "  • Sunday: Ideal for comprehensive maintenance" | tee -a "$LOG_FILE"
  echo "  • Recommended: Full orchestration run" | tee -a "$LOG_FILE"
  elif (( current_hour >= 18 || current_hour <= 7 )); then
  echo "  • Off-hours: Safe for maintenance operations" | tee -a "$LOG_FILE"
  echo "  • Recommended: System optimization tasks" | tee -a "$LOG_FILE"
  else
  echo "  • Work hours: Focus on monitoring and light maintenance" | tee -a "$LOG_FILE"
  echo "  • Recommended: Performance monitoring only" | tee -a "$LOG_FILE"
  fi

  # Implementation recommendations
  echo "  IMPLEMENTATION: IMPLEMENTATION:" | tee -a "$LOG_FILE"
  echo "  • Create systemd user timers for each tool" | tee -a "$LOG_FILE"
  echo "  • Set up log rotation for automation outputs" | tee -a "$LOG_FILE"
  echo "  • Configure alert thresholds for critical issues" | tee -a "$LOG_FILE"
  echo "  • Integrate with existing Hermes monitoring" | tee -a "$LOG_FILE"

  return 0
}

# Main orchestration execution
main() {
  # Initialize secure environment
  if ! initialize_orchestration; then
  echo "ERROR: Failed to initialize orchestration environment" >&2
  cleanup_and_exit 1
  fi

  # Check prerequisites
  if ! check_automation_prerequisites; then
  echo "ERROR: Prerequisites check failed" >&2
  cleanup_and_exit 1
  fi

  # Execute automation tools in optimal sequence
  local execution_order=("memory" "workspace" "system")
  local successful_executions=0
  local failed_executions=0

  for tool_name in "${execution_order[@]}"; do
  if [[ -n "${AUTOMATION_TOOLS[$tool_name]:-}" ]]; then
  local tool_script="${AUTOMATION_TOOLS[$tool_name]}"
  if [[ -f "$AUTOMATION_DIR/$tool_script" && -x "$AUTOMATION_DIR/$tool_script" ]]; then
  echo "  Orchestrating: $tool_name..." >&2
  if execute_automation_tool "$tool_name"; then
  ((successful_executions++))
  else
  ((failed_executions++))
  fi

  # Brief pause between tools to prevent resource contention
  sleep 2
  else
  echo "  Skipping unavailable tool: $tool_name" >&2
  fi
  fi
  done

  # Generate integrated analysis
  if ! generate_integrated_analysis; then
  echo "  WARNING:  Integrated analysis completed with warnings" >&2
  fi

  # Generate coordinated recommendations
  if ! generate_coordinated_recommendations; then
  echo "  WARNING:  Recommendations generation completed with warnings" >&2
  fi

  # Final orchestration status
  echo "" | tee -a "$LOG_FILE"
  echo "METRICS: ORCHESTRATION SUMMARY:" | tee -a "$LOG_FILE"
  echo "  • Successful executions: $successful_executions" | tee -a "$LOG_FILE"
  echo "  • Failed executions: $failed_executions" | tee -a "$LOG_FILE"
  echo "  • Total tools orchestrated: $((successful_executions + failed_executions))" | tee -a "$LOG_FILE"

  if (( failed_executions == 0 )); then
  echo " AUTOMATION ORCHESTRATION COMPLETE - $(date)" | tee -a "$LOG_FILE"
  cleanup_and_exit 0
  else
  echo " AUTOMATION ORCHESTRATION COMPLETE WITH $failed_executions FAILURES - $(date)" | tee -a "$LOG_FILE"
  cleanup_and_exit 1
  fi

  echo "LOG: Complete orchestration log: $LOG_FILE" | tee -a "$LOG_FILE"
  echo "================================================" | tee -a "$LOG_FILE"
}

# Execute main function
main "$@"
