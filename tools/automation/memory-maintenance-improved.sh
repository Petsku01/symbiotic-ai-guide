#!/bin/bash

# Memory System Maintenance Automation  
# Monitors and maintains optimized memory system health

# Error handling configuration
set -euo pipefail  # Exit on error, undefined variables, pipe failures
trap 'echo "ERROR: Error on line $LINENO. Exit code: $?" >&2; exit 1' ERR

# Configuration - Make paths configurable with fallbacks
WORKSPACE="${OPENCLAW_WORKSPACE:-${HOME}/.openclaw/workspace}"
MEMORY_DIR="$WORKSPACE/memory"
LOG_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOG_FILE="$LOG_DIR/memory-maintenance.log"

# Create secure log file with proper permissions
touch "$LOG_FILE" && chmod 600 "$LOG_FILE"

# Critical directory verification with helpful error messages
verify_environment() {
  local errors=0
  
  if [[ ! -d "$WORKSPACE" ]]; then
  echo "ERROR: Critical error: Workspace directory not found: $WORKSPACE" >&2
  echo "  Try: export OPENCLAW_WORKSPACE=/path/to/your/workspace" >&2
  ((errors++))
  fi

  if [[ ! -d "$MEMORY_DIR" ]]; then
  echo "ERROR: Critical error: Memory directory not found: $MEMORY_DIR" >&2
  echo "  Expected: $WORKSPACE/memory" >&2
  ((errors++))
  fi
  
  if [[ ! -w "$LOG_DIR" ]]; then
  echo "ERROR: Critical error: Cannot write to log directory: $LOG_DIR" >&2
  ((errors++))
  fi
  
  if [[ $errors -gt 0 ]]; then
  echo "ERROR: Environment verification failed. Cannot continue." >&2
  exit 1
  fi
}

# Enhanced file operation with atomic writes and error handling
safe_append_log() {
  local message="$1"
  local temp_file
  temp_file=$(mktemp "${LOG_FILE}.XXXXXX") || {
  echo "ERROR: Failed to create temporary file" >&2
  return 1
  }
  
  # Atomic append operation
  {
  [[ -f "$LOG_FILE" ]] && cat "$LOG_FILE"
  echo "$message"
  } > "$temp_file" && mv "$temp_file" "$LOG_FILE" || {
  rm -f "$temp_file"
  echo "ERROR: Failed to write log entry" >&2
  return 1
  }
}

# Function: Analyze memory file sizes with comprehensive error handling
analyze_memory_growth() {
  echo "" | tee -a "$LOG_FILE"
  echo "METRICS: MEMORY GROWTH ANALYSIS:" | tee -a "$LOG_FILE"
  
  local daily_files large_files
  
  # Safe file counting with error handling
  if ! daily_files=$(find "$MEMORY_DIR" -name "2026-*.md" -type f 2>/dev/null); then
  echo "  WARNING:  Could not access daily memory files" | tee -a "$LOG_FILE"
  return 1
  fi
  
  local found_large=false
  while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  
  if ! [[ -r "$file" ]]; then
  echo "  WARNING:  Cannot read file: $(basename "$file")" | tee -a "$LOG_FILE"
  continue
  fi
  
  local word_count
  if word_count=$(wc -w < "$file" 2>/dev/null); then
  if (( word_count > 500 )); then
  echo "  TREND: Large daily file: $(basename "$file") ($word_count words)" | tee -a "$LOG_FILE"
  found_large=true
  fi
  else
  echo "  WARNING:  Could not analyze: $(basename "$file")" | tee -a "$LOG_FILE"
  fi
  done <<< "$daily_files"
  
  if [[ "$found_large" == false ]]; then
  echo "  OK: Daily file sizes are optimal" | tee -a "$LOG_FILE"
  fi
}

# Function: Check cross-reference index status with error handling
check_cross_references() {
  echo "" | tee -a "$LOG_FILE"
  echo " CROSS-REFERENCE INDEX STATUS:" | tee -a "$LOG_FILE"
  
  local index_file="$MEMORY_DIR/CROSS-REFERENCE-INDEX.md"
  
  if [[ ! -f "$index_file" ]]; then
  echo "  WARNING:  Cross-reference index not found" | tee -a "$LOG_FILE"
  echo "  TIP: Consider creating index for improved navigation" | tee -a "$LOG_FILE"
  return 1
  fi
  
  local index_date files_since
  if index_date=$(stat -c %Y "$index_file" 2>/dev/null); then
  if files_since=$(find "$MEMORY_DIR" -name "*.md" -newer "$index_file" -type f 2>/dev/null | wc -l); then
  if (( files_since > 0 )); then
  echo "  NOTE: $files_since memory files created since last index update" | tee -a "$LOG_FILE"
  if (( files_since > 5 )); then
  echo "  TIP: Consider updating cross-reference index" | tee -a "$LOG_FILE"
  fi
  else
  echo "  OK: Cross-reference index is current" | tee -a "$LOG_FILE"
  fi
  else
  echo "  WARNING:  Could not check index currency" | tee -a "$LOG_FILE"
  fi
  else
  echo "  WARNING:  Could not read index file statistics" | tee -a "$LOG_FILE"
  fi
}

# Function: Analyze content consolidation opportunities
analyze_consolidation_opportunities() {
  echo "" | tee -a "$LOG_FILE"
  echo "SYNC: CONTENT CONSOLIDATION OPPORTUNITIES:" | tee -a "$LOG_FILE"
  
  local temp_analysis
  if ! temp_analysis=$(mktemp); then
  echo "  WARNING:  Could not create temporary analysis file" | tee -a "$LOG_FILE"
  return 1
  fi
  
  # Safe content analysis with error handling
  {
  echo "TREND: Topic distribution analysis:"
  
  # Count OpenClaw references safely
  local openclaw_count
  if openclaw_count=$(grep -l -i "openclaw\|gateway" "$MEMORY_DIR"/*.md 2>/dev/null | wc -l); then
  echo "  OpenClaw references: $openclaw_count files"
  fi
  
  # Count network/performance references
  local network_count  
  if network_count=$(grep -l -i "network\|performance\|wsl2\|websocket" "$MEMORY_DIR"/*.md 2>/dev/null | wc -l); then
  echo "  Network/performance: $network_count files"
  fi
  
  # Count partnership topics
  local partnership_count
  if partnership_count=$(grep -l -i "partnership\|collaboration\|petsku" "$MEMORY_DIR"/*.md 2>/dev/null | wc -l); then
  echo "  Partnership topics: $partnership_count files"
  fi
  
  # Consolidation recommendations
  if (( openclaw_count > 10 )); then
  echo "TIP: Consider consolidating OpenClaw content (spread across $openclaw_count files)"
  fi
  
  } | tee -a "$LOG_FILE" 2>/dev/null || {
  echo "  WARNING:  Content analysis failed" | tee -a "$LOG_FILE"
  }
  
  rm -f "$temp_analysis"
}

# Function: Evaluate memory search performance
evaluate_search_performance() {
  echo "" | tee -a "$LOG_FILE"
  echo "PERFORMANCE: MEMORY SEARCH PERFORMANCE:" | tee -a "$LOG_FILE"
  
  # Safe metrics collection
  local total_files total_size avg_size
  
  if total_files=$(find "$MEMORY_DIR" -name "*.md" -type f 2>/dev/null | wc -l); then
  echo "  METRICS: Memory system metrics:" | tee -a "$LOG_FILE"
  echo "  Total files: $total_files" | tee -a "$LOG_FILE"
  
  if total_size=$(du -sb "$MEMORY_DIR" 2>/dev/null | cut -f1); then
  avg_size=$((total_size / total_files))
  echo "  Total size: $total_size bytes" | tee -a "$LOG_FILE"
  echo "  Average file size: $avg_size bytes" | tee -a "$LOG_FILE"
  
  # Performance recommendations
  if (( total_files > 50 )); then
  echo "  TIP: Large file count may slow search - consider archiving old content" | tee -a "$LOG_FILE"
  elif (( total_size > 10000000 )); then  # 10MB
  echo "  TIP: Large memory size - monitor search performance" | tee -a "$LOG_FILE"  
  else
  echo "  OK: Memory system size optimal for performance" | tee -a "$LOG_FILE"
  fi
  else
  echo "  WARNING:  Could not calculate memory system size" | tee -a "$LOG_FILE"
  fi
  else
  echo "  WARNING:  Could not count memory files" | tee -a "$LOG_FILE"
  fi
}

# Function: Generate maintenance recommendations with error handling
generate_recommendations() {
  echo "" | tee -a "$LOG_FILE"
  echo "STRATEGY: MAINTENANCE RECOMMENDATIONS:" | tee -a "$LOG_FILE"
  
  # Safe optimization timestamp handling
  local last_optimization current_time days_since
  
  if last_optimization=$(find "$MEMORY_DIR" -name "*OPTIMIZATION*" -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -1 | cut -d' ' -f1 | cut -d'.' -f1); then
  current_time=$(date +%s)
  if [[ -n "$last_optimization" && "$last_optimization" -gt 0 ]]; then
  days_since=$(( (current_time - last_optimization) / 86400 ))
  
  if (( days_since > 14 )); then
  echo "  FIX: Consider comprehensive memory system review ($days_since days since last optimization)" | tee -a "$LOG_FILE"
  fi
  fi
  fi
  
  # Standard maintenance recommendations
  echo "  Regular maintenance tasks:" | tee -a "$LOG_FILE"
  echo "  • Update cross-reference index weekly" | tee -a "$LOG_FILE"
  echo "  • Promote substantial daily content to topical files" | tee -a "$LOG_FILE"  
  echo "  • Review and consolidate related technical content" | tee -a "$LOG_FILE"
  echo "  • Archive memories >60 days old to maintain search speed" | tee -a "$LOG_FILE"
}

# Main execution with comprehensive error handling
main() {
  echo "ANALYSIS: Memory System Maintenance - $(date)" | tee "$LOG_FILE"
  echo "================================================" | tee -a "$LOG_FILE"
  echo "Starting automated memory system maintenance..." | tee -a "$LOG_FILE"
  
  # Verify environment before proceeding
  verify_environment
  
  # Execute maintenance functions with error handling
  local functions=(
  "analyze_memory_growth"
  "check_cross_references" 
  "analyze_consolidation_opportunities"
  "evaluate_search_performance"
  "generate_recommendations"
  )
  
  local failed_functions=0
  for func in "${functions[@]}"; do
  echo "  Executing: $func..." >&2
  if ! "$func"; then
  echo "  WARNING:  Function $func completed with warnings" >&2
  ((failed_functions++))
  fi
  done
  
  echo "" | tee -a "$LOG_FILE"
  if (( failed_functions == 0 )); then
  echo " MAINTENANCE COMPLETE - $(date)" | tee -a "$LOG_FILE"
  else
  echo " MAINTENANCE COMPLETE WITH $failed_functions WARNINGS - $(date)" | tee -a "$LOG_FILE"
  fi
  echo "LOG: Full log available at: $LOG_FILE" | tee -a "$LOG_FILE"
  echo "================================================" | tee -a "$LOG_FILE"
}

# Execute main function
main "$@"