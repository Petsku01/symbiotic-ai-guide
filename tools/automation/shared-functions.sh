#!/bin/bash

# Shared Functions for Automation Scripts
# Provides secure file operations, locking, and error handling

# File locking implementation
acquire_lock() {
  local lock_file="$1"
  local timeout="${2:-30}"  # 30 second default timeout
  local wait_time=0
  
  # Create lock directory atomically
  while ! mkdir "$lock_file" 2>/dev/null; do
  if (( wait_time >= timeout )); then
  echo "ERROR: Failed to acquire lock: $lock_file (timeout after ${timeout}s)" >&2
  return 1
  fi
  
  # Check if lock is stale (older than 10 minutes)
  if [[ -d "$lock_file" ]]; then
  local lock_age
  if lock_age=$(( $(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0) )); then
  if (( lock_age > 600 )); then  # 10 minutes
  echo "WARNING:  Removing stale lock (${lock_age}s old): $lock_file" >&2
  rmdir "$lock_file" 2>/dev/null || true
  fi
  fi
  fi
  
  sleep 1
  ((wait_time++))
  done
  
  # Store lock holder info
  echo "$$:$(date +%s):$(id -un)" > "$lock_file/info" 2>/dev/null || true
  echo "OK: Lock acquired: $lock_file (PID: $$)" >&2
  return 0
}

# Release file lock
release_lock() {
  local lock_file="$1"
  
  if [[ -d "$lock_file" ]]; then
  rm -f "$lock_file/info" 2>/dev/null
  if rmdir "$lock_file" 2>/dev/null; then
  echo "OK: Lock released: $lock_file" >&2
  else
  echo "WARNING:  Failed to release lock: $lock_file" >&2
  return 1
  fi
  fi
  return 0
}

# Secure log file creation
create_secure_log() {
  local log_file="$1"
  local log_dir
  log_dir=$(dirname "$log_file")
  
  # Create log directory if needed
  if [[ ! -d "$log_dir" ]]; then
  if ! mkdir -p "$log_dir"; then
  echo "ERROR: Failed to create log directory: $log_dir" >&2
  return 1
  fi
  fi
  
  # Create log file with secure permissions
  if ! touch "$log_file"; then
  echo "ERROR: Failed to create log file: $log_file" >&2
  return 1
  fi
  
  # Set restrictive permissions (owner read/write only)
  if ! chmod 600 "$log_file"; then
  echo "ERROR: Failed to set secure permissions on: $log_file" >&2
  return 1
  fi
  
  return 0
}

# Safe atomic file write
atomic_write() {
  local target_file="$1"
  local content="$2"
  local temp_file
  
  temp_file=$(mktemp "${target_file}.XXXXXX") || {
  echo "ERROR: Failed to create temporary file for: $target_file" >&2
  return 1
  }
  
  # Write content to temp file
  if ! echo "$content" > "$temp_file"; then
  rm -f "$temp_file"
  echo "ERROR: Failed to write temporary file: $temp_file" >&2
  return 1
  fi
  
  # Atomic move
  if ! mv "$temp_file" "$target_file"; then
  rm -f "$temp_file"
  echo "ERROR: Failed to move temporary file to target: $target_file" >&2
  return 1
  fi
  
  return 0
}

# Safe atomic append to log
atomic_log_append() {
  local log_file="$1"
  local message="$2"
  local temp_file
  
  temp_file=$(mktemp "${log_file}.append.XXXXXX") || {
  echo "ERROR: Failed to create temporary file for log append" >&2
  return 1
  }
  
  # Atomic append operation
  {
  [[ -f "$log_file" ]] && cat "$log_file"
  echo "$message"
  } > "$temp_file" && mv "$temp_file" "$log_file" || {
  rm -f "$temp_file"
  echo "ERROR: Failed to append to log: $log_file" >&2
  return 1
  }
  
  return 0
}

# Variable escaping for shell safety
escape_shell_arg() {
  local arg="$1"
  # Use printf %q for proper shell escaping
  printf '%q' "$arg"
}

# Safe command execution with timeout
safe_execute() {
  local timeout_seconds="$1"
  shift
  local cmd=("$@")
  
  if ! timeout "$timeout_seconds" "${cmd[@]}"; then
  local exit_code=$?
  if (( exit_code == 124 )); then
  echo "ERROR: Command timed out after ${timeout_seconds}s: ${cmd[*]}" >&2
  else
  echo "ERROR: Command failed with exit code $exit_code: ${cmd[*]}" >&2
  fi
  return $exit_code
  fi
  
  return 0
}

# Cleanup function for script termination
setup_cleanup_trap() {
  local cleanup_function="$1"
  trap "$cleanup_function" EXIT INT TERM
}

# Configuration validation
validate_config() {
  local workspace="$1"
  local errors=0
  
  if [[ ! -d "$workspace" ]]; then
  echo "ERROR: Workspace directory not found: $workspace" >&2
  ((errors++))
  elif [[ ! -r "$workspace" ]]; then
  echo "ERROR: Workspace directory not readable: $workspace" >&2
  ((errors++))
  elif [[ ! -w "$workspace" ]]; then
  echo "ERROR: Workspace directory not writable: $workspace" >&2
  ((errors++))
  fi
  
  return $errors
}

# Get secure temporary directory
get_secure_tmpdir() {
  local tmpdir
  
  # Try user runtime directory first, then fall back to /tmp
  if [[ -n "${XDG_RUNTIME_DIR:-}" && -d "$XDG_RUNTIME_DIR" && -w "$XDG_RUNTIME_DIR" ]]; then
  tmpdir="$XDG_RUNTIME_DIR"
  else
  tmpdir="/tmp"
  fi
  
  echo "$tmpdir"
}