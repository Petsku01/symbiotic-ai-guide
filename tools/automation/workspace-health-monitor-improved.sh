#!/bin/bash

# Workspace Health Monitor - Improved Version
# Maintains professional workspace organization with enhanced security and portability

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
TMPDIR=$(get_secure_tmpdir)
LOG_FILE="$TMPDIR/workspace-health.log"
LOCK_FILE="$TMPDIR/workspace-health.lock"

# Global cleanup function
cleanup_and_exit() {
  local exit_code=${1:-0}
  release_lock "$LOCK_FILE" 2>/dev/null || true
  exit "$exit_code"
}

# Setup cleanup on script termination
setup_cleanup_trap cleanup_and_exit

# Initialize secure environment
initialize_environment() {
  echo "WORKSPACE: Workspace Health Monitor - $(date)"
  
  # Validate configuration
  if ! validate_config "$WORKSPACE"; then
  echo "ERROR: Environment validation failed" >&2
  return 1
  fi
  
  # Create secure log file
  if ! create_secure_log "$LOG_FILE"; then
  echo "ERROR: Failed to create secure log file" >&2
  return 1
  fi
  
  # Acquire lock to prevent concurrent execution
  if ! acquire_lock "$LOCK_FILE" 30; then
  echo "ERROR: Another workspace health monitor is already running" >&2
  return 1
  fi
  
  echo "================================================" | tee "$LOG_FILE"
  echo "Starting workspace health monitoring..." | tee -a "$LOG_FILE"
  
  return 0
}

# Function: Check root directory health with improved safety
check_root_directory_health() {
  echo "" | tee -a "$LOG_FILE"
  echo "DIR: ROOT DIRECTORY HEALTH:" | tee -a "$LOG_FILE"
  
  local root_files config_files unexpected_files
  
  # Safely count files with error handling
  if ! root_files=$(find "$WORKSPACE" -maxdepth 1 -type f 2>/dev/null); then
  echo "  ERROR: Cannot access workspace root directory" | tee -a "$LOG_FILE"
  return 1
  fi
  
  local total_files=0
  local -a config_patterns=("*.md" "*.yaml" "*.yml" "*.json" "*.toml")
  local -a unexpected_list=()
  
  while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  ((total_files++))
  
  local basename_file
  basename_file=$(basename "$file")
  
  # Check if it's a known config file pattern
  local is_config=false
  for pattern in "${config_patterns[@]}"; do
  # Safe pattern matching
  if [[ "$basename_file" == $pattern ]]; then
  is_config=true
  break
  fi
  done
  
  # Special cases for expected files
  case "$basename_file" in
  AGENTS.md|SOUL.md|TOOLS.md|IDENTITY.md|USER.md|BOOTSTRAP.md|MEMORY.md|HEARTBEAT.md)
  is_config=true
  ;;
  esac
  
  if [[ "$is_config" == false ]]; then
  unexpected_list+=("$basename_file")
  fi
  done <<< "$root_files"
  
  # Report results safely
  if (( total_files <= 8 )) && (( ${#unexpected_list[@]} == 0 )); then
  echo "  OK: Root directory optimal ($total_files config files)" | tee -a "$LOG_FILE"
  else
  if (( ${#unexpected_list[@]} > 0 )); then
  echo "  CRITICAL: Root directory cluttered (found $total_files files, expected 8)" | tee -a "$LOG_FILE"
  echo "  TIP: Move non-config files to appropriate project directories" | tee -a "$LOG_FILE"
  for unexpected in "${unexpected_list[@]}"; do
  echo "  LOG: Unexpected: $unexpected" | tee -a "$LOG_FILE"
  done
  else
  echo "  OK: Root directory clean but has $total_files files" | tee -a "$LOG_FILE"
  fi
  fi
  
  return 0
}

# Function: Analyze project organization with enhanced safety
analyze_project_organization() {
  echo "" | tee -a "$LOG_FILE"
  echo "METRICS: PROJECT ORGANIZATION STATUS:" | tee -a "$LOG_FILE"
  
  local projects_dir="$WORKSPACE/projects"
  
  if [[ ! -d "$projects_dir" ]]; then
  echo "  WARNING:  Projects directory not found: $projects_dir" | tee -a "$LOG_FILE"
  echo "  TIP: Consider creating project organization structure" | tee -a "$LOG_FILE"
  return 1
  fi
  
  local project_categories project_files
  
  # Safely count project structure
  if ! project_categories=$(find "$projects_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null); then
  echo "  WARNING:  Cannot analyze project structure" | tee -a "$LOG_FILE"
  return 1
  fi
  
  if ! project_files=$(find "$projects_dir" -type f 2>/dev/null); then
  echo "  WARNING:  Cannot count project files" | tee -a "$LOG_FILE"
  return 1
  fi
  
  local category_count file_count
  category_count=$(echo "$project_categories" | grep -c . || echo 0)
  file_count=$(echo "$project_files" | grep -c . || echo 0)
  
  echo "  TREND: Project metrics:" | tee -a "$LOG_FILE"
  echo "  Project categories: $category_count" | tee -a "$LOG_FILE"
  echo "  Total project files: $file_count" | tee -a "$LOG_FILE"
  
  # Analyze each category with error handling
  while IFS= read -r category_dir; do
  [[ -z "$category_dir" ]] && continue
  
  local category_name
  category_name=$(basename "$category_dir")
  
  local category_file_count
  if category_file_count=$(find "$category_dir" -type f 2>/dev/null | wc -l); then
  echo "  DIR: $category_name: $category_file_count files" | tee -a "$LOG_FILE"
  
  # Check for README
  if [[ ! -f "$category_dir/README.md" ]]; then
  echo "  TIP: Consider adding README.md for navigation" | tee -a "$LOG_FILE"
  fi
  else
  echo "  DIR: $category_name: Cannot analyze" | tee -a "$LOG_FILE"
  fi
  done <<< "$project_categories"
  
  return 0
}

# Function: Check archive system status with safety
check_archive_status() {
  echo "" | tee -a "$LOG_FILE"
  echo "ARCHIVE: ARCHIVE SYSTEM STATUS:" | tee -a "$LOG_FILE"
  
  local archive_dir="$WORKSPACE/archive"
  
  if [[ -d "$archive_dir" ]]; then
  local archive_size
  if archive_size=$(du -sh "$archive_dir" 2>/dev/null | cut -f1); then
  echo "  OK: Archive system active (size: $archive_size)" | tee -a "$LOG_FILE"
  
  # Check for old content that should be archived
  local old_content
  if old_content=$(find "$WORKSPACE" -name "*.md" -type f -mtime +60 2>/dev/null | grep -v archive | wc -l); then
  if (( old_content > 0 )); then
  echo "  TIP: Found $old_content files >60 days old that could be archived" | tee -a "$LOG_FILE"
  fi
  fi
  else
  echo "  WARNING:  Archive directory exists but cannot analyze" | tee -a "$LOG_FILE"
  fi
  else
  echo "  TIP: No archive system - consider creating for historical content" | tee -a "$LOG_FILE"
  fi
  
  return 0
}

# Function: Verify documentation completeness safely
verify_documentation_completeness() {
  echo "" | tee -a "$LOG_FILE"
  echo "DOCS: DOCUMENTATION COMPLETENESS:" | tee -a "$LOG_FILE"
  
  local -a critical_docs=("README.md" "BOOTSTRAP.md" "IDENTITY.md" "USER.md")
  local missing_docs=0
  
  for doc in "${critical_docs[@]}"; do
  local doc_path="$WORKSPACE/$doc"
  if [[ ! -f "$doc_path" ]]; then
  echo "  ERROR: Missing critical documentation: $doc" | tee -a "$LOG_FILE"
  ((missing_docs++))
  elif [[ ! -r "$doc_path" ]]; then
  echo "  WARNING:  Cannot read documentation: $doc" | tee -a "$LOG_FILE"
  ((missing_docs++))
  fi
  done
  
  if (( missing_docs == 0 )); then
  echo "  OK: All critical documentation present" | tee -a "$LOG_FILE"
  else
  echo "  CRITICAL: $missing_docs critical documentation files missing or unreadable" | tee -a "$LOG_FILE"
  fi
  
  return 0
}

# Function: Check memory integration with safety
check_memory_integration() {
  echo "" | tee -a "$LOG_FILE"
  echo "ANALYSIS: MEMORY-WORKSPACE INTEGRATION:" | tee -a "$LOG_FILE"
  
  local memory_dir="$WORKSPACE/memory"
  
  if [[ ! -d "$memory_dir" ]]; then
  echo "  ERROR: Memory system not found" | tee -a "$LOG_FILE"
  return 1
  fi
  
  # Check if projects are documented in memory
  local projects_dir="$WORKSPACE/projects"
  if [[ -d "$projects_dir" ]]; then
  local undocumented_projects=0
  
  while IFS= read -r project_dir; do
  [[ -z "$project_dir" ]] && continue
  
  local project_name
  project_name=$(basename "$project_dir")
  
  # Check if project is mentioned in memory files
  local mentioned_count
  if mentioned_count=$(grep -l -i "$project_name" "$memory_dir"/*.md 2>/dev/null | wc -l); then
  if (( mentioned_count == 0 )); then
  echo "  TIP: Project '$project_name' lacks memory documentation" | tee -a "$LOG_FILE"
  ((undocumented_projects++))
  fi
  fi
  done <<< "$(find "$projects_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)"
  
  if (( undocumented_projects == 0 )); then
  echo "  OK: All projects have memory documentation" | tee -a "$LOG_FILE"
  else
  echo "  TIP: $undocumented_projects projects could benefit from memory documentation" | tee -a "$LOG_FILE"
  fi
  fi
  
  return 0
}

# Function: Generate health recommendations
generate_health_recommendations() {
  echo "" | tee -a "$LOG_FILE"
  echo "STRATEGY: HEALTH MAINTENANCE RECOMMENDATIONS:" | tee -a "$LOG_FILE"
  
  echo "  Regular workspace health tasks:" | tee -a "$LOG_FILE"
  echo "  • Keep root directory to 8 configuration files" | tee -a "$LOG_FILE"
  echo "  • Move project files to appropriate categories" | tee -a "$LOG_FILE"
  echo "  • Create README.md files for project navigation" | tee -a "$LOG_FILE"
  echo "  • Archive content >60 days old" | tee -a "$LOG_FILE"
  echo "  • Update memory documentation for active projects" | tee -a "$LOG_FILE"
  
  return 0
}

# Main execution with comprehensive error handling
main() {
  # Initialize secure environment
  if ! initialize_environment; then
  echo "ERROR: Failed to initialize environment" >&2
  cleanup_and_exit 1
  fi
  
  # Execute health check functions
  local -a health_functions=(
  "check_root_directory_health"
  "analyze_project_organization"
  "check_archive_status"
  "verify_documentation_completeness"
  "check_memory_integration"
  "generate_health_recommendations"
  )
  
  local failed_functions=0
  for func in "${health_functions[@]}"; do
  echo "  Executing: $func..." >&2
  if ! "$func"; then
  echo "  WARNING:  Function $func completed with warnings" >&2
  ((failed_functions++))
  fi
  done
  
  # Final status
  echo "" | tee -a "$LOG_FILE"
  if (( failed_functions == 0 )); then
  echo " WORKSPACE HEALTH CHECK COMPLETE - $(date)" | tee -a "$LOG_FILE"
  else
  echo " WORKSPACE HEALTH CHECK COMPLETE WITH $failed_functions WARNINGS - $(date)" | tee -a "$LOG_FILE"
  fi
  echo "LOG: Full log available at: $LOG_FILE" | tee -a "$LOG_FILE"
  echo "================================================" | tee -a "$LOG_FILE"
  
  cleanup_and_exit 0
}

# Execute main function
main "$@"