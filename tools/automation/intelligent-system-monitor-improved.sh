#!/bin/bash

# Intelligent System Monitor - Improved Version
# Advanced monitoring with enhanced security, error handling, and portability

# Load shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh" || {
    echo "❌ Failed to load shared functions" >&2
    exit 1
}

# Error handling configuration
set -euo pipefail
trap 'echo "❌ Error on line $LINENO. Exit code: $?" >&2; cleanup_and_exit 1' ERR

# Configuration with portable defaults
WORKSPACE="${OPENCLAW_WORKSPACE:-${HOME}/.openclaw/workspace}"
TMPDIR=$(get_secure_tmpdir)
LOG_FILE="$TMPDIR/intelligent-system-monitor.log"
LOCK_FILE="$TMPDIR/intelligent-system-monitor.lock"
METRICS_FILE="$TMPDIR/system-metrics.csv"

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
    echo "🤖 Intelligent System Monitor - $(date)"
    
    # Validate configuration
    if ! validate_config "$WORKSPACE"; then
        echo "❌ Environment validation failed" >&2
        return 1
    fi
    
    # Create secure log file
    if ! create_secure_log "$LOG_FILE"; then
        echo "❌ Failed to create secure log file" >&2
        return 1
    fi
    
    # Acquire lock to prevent concurrent execution
    if ! acquire_lock "$LOCK_FILE" 30; then
        echo "❌ Another system monitor is already running" >&2
        return 1
    fi
    
    # Create secure metrics file if it doesn't exist
    if [[ ! -f "$METRICS_FILE" ]]; then
        if ! create_secure_log "$METRICS_FILE"; then
            echo "❌ Failed to create metrics file" >&2
            return 1
        fi
        
        # Add CSV header
        echo "timestamp,cpu_load,memory_percent,memory_mb,disk_percent,openclaw_pid,openclaw_memory_mb,connections,slow_events_1h,websocket_drops_1h" > "$METRICS_FILE"
    fi
    
    echo "================================================" | tee "$LOG_FILE"
    echo "Starting intelligent system monitoring..." | tee -a "$LOG_FILE"
    
    return 0
}

# Function: Collect comprehensive system metrics safely
collect_system_metrics() {
    echo "" | tee -a "$LOG_FILE"
    echo "📊 COLLECTING SYSTEM METRICS:" | tee -a "$LOG_FILE"
    
    local timestamp cpu_load memory_percent memory_mb disk_percent
    local openclaw_pid openclaw_memory_mb connections slow_events_1h websocket_drops_1h
    
    # Safe timestamp
    timestamp=$(date +%s)
    
    # CPU load average (1 minute) with error handling
    if ! cpu_load=$(uptime | awk '{print $10}' | sed 's/,$//' 2>/dev/null); then
        cpu_load="0.00"
        echo "   ⚠️  Could not determine CPU load" | tee -a "$LOG_FILE"
    fi
    
    # Memory usage with error handling
    if ! memory_info=$(free | awk '/^Mem:/ {printf "%.1f %.0f", ($3/$2)*100, $3/1024}' 2>/dev/null); then
        memory_percent="0.0"
        memory_mb="0"
        echo "   ⚠️  Could not determine memory usage" | tee -a "$LOG_FILE"
    else
        memory_percent=$(echo "$memory_info" | cut -d' ' -f1)
        memory_mb=$(echo "$memory_info" | cut -d' ' -f2)
    fi
    
    # Disk usage with error handling  
    if ! disk_percent=$(df "$WORKSPACE" | tail -1 | awk '{print $5}' | sed 's/%$//' 2>/dev/null); then
        disk_percent="0"
        echo "   ⚠️  Could not determine disk usage" | tee -a "$LOG_FILE"
    fi
    
    # OpenClaw specific metrics with enhanced error handling
    if openclaw_pid=$(pgrep -f "openclaw-gateway" 2>/dev/null | head -1); then
        # OpenClaw memory usage
        if ! openclaw_memory_mb=$(ps -p "$openclaw_pid" -o rss --no-headers 2>/dev/null | awk '{print $1/1024}'); then
            openclaw_memory_mb="0"
        fi
        
        # Network connections with timeout
        if ! connections=$(timeout 5 lsof -p "$openclaw_pid" -a -i 2>/dev/null | wc -l); then
            connections="0"
        fi
        
        # Journal analysis with proper error handling and timeout
        if command -v journalctl >/dev/null 2>&1; then
            if ! slow_events_1h=$(timeout 10 journalctl --user -u openclaw-gateway --since="1 hour ago" --no-pager -q 2>/dev/null | grep -c "Slow listener" || echo "0"); then
                slow_events_1h="0"
            fi
            
            if ! websocket_drops_1h=$(timeout 10 journalctl --user -u openclaw-gateway --since="1 hour ago" --no-pager -q 2>/dev/null | grep -c "WebSocket connection closed" || echo "0"); then
                websocket_drops_1h="0"
            fi
        else
            slow_events_1h="0"
            websocket_drops_1h="0"
            echo "   ⚠️  journalctl not available for OpenClaw analysis" | tee -a "$LOG_FILE"
        fi
    else
        openclaw_pid="0"
        openclaw_memory_mb="0"
        connections="0"
        slow_events_1h="0"
        websocket_drops_1h="0"
        echo "   ⚠️  OpenClaw not running - limited metrics available" | tee -a "$LOG_FILE"
    fi
    
    # Store metrics securely
    local metrics_line="$timestamp,$cpu_load,$memory_percent,$memory_mb,$disk_percent,$openclaw_pid,$openclaw_memory_mb,$connections,$slow_events_1h,$websocket_drops_1h"
    
    if ! atomic_log_append "$METRICS_FILE" "$metrics_line"; then
        echo "   ⚠️  Failed to store metrics data" | tee -a "$LOG_FILE"
    fi
    
    echo "   ✅ Metrics collected and stored" | tee -a "$LOG_FILE"
    
    # Export current metrics for other functions
    export CURRENT_METRICS="$timestamp,$cpu_load,$memory_percent,$memory_mb,$disk_percent,$openclaw_pid,$openclaw_memory_mb,$connections,$slow_events_1h,$websocket_drops_1h"
    
    return 0
}

# Function: Analyze performance trends safely
analyze_performance_trends() {
    echo "" | tee -a "$LOG_FILE"
    echo "📈 PERFORMANCE TREND ANALYSIS:" | tee -a "$LOG_FILE"
    
    local data_points
    if ! data_points=$(tail -n +2 "$METRICS_FILE" 2>/dev/null | wc -l); then
        echo "   ⚠️  Cannot analyze trends - no historical data" | tee -a "$LOG_FILE"
        return 1
    fi
    
    echo "   📊 Analyzing last $data_points data points..." | tee -a "$LOG_FILE"
    
    if (( data_points < 2 )); then
        echo "   💡 Insufficient data for trend analysis" | tee -a "$LOG_FILE"
        return 0
    fi
    
    # Safe trend analysis with error handling
    local recent_data
    if ! recent_data=$(tail -10 "$METRICS_FILE" 2>/dev/null); then
        echo "   ⚠️  Cannot read recent metrics data" | tee -a "$LOG_FILE"
        return 1
    fi
    
    # Analyze memory usage trend
    local memory_trend
    if memory_trend=$(echo "$recent_data" | tail -5 | cut -d',' -f3 | awk '
        NR==1 {first=$1} 
        END {
            if (NR>1) {
                diff = $1 - first;
                if (diff > 5) print "INCREASING";
                else if (diff < -5) print "DECREASING";  
                else print "STABLE"
            } else print "INSUFFICIENT_DATA"
        }
    ' 2>/dev/null); then
        echo "   📊 Memory trend: $memory_trend" | tee -a "$LOG_FILE"
    fi
    
    # Analyze WebSocket connection stability
    local websocket_issues
    if websocket_issues=$(echo "$recent_data" | tail -5 | cut -d',' -f10 | awk '
        {sum+=$1; count++} 
        END {
            avg = (count>0) ? sum/count : 0;
            if (avg > 10) print "HIGH";
            else if (avg > 2) print "MODERATE";
            else print "LOW"
        }
    ' 2>/dev/null); then
        case "$websocket_issues" in
            "HIGH")
                echo "   🔴 ALERT: High WebSocket instability detected" | tee -a "$LOG_FILE"
                ;;
            "MODERATE")  
                echo "   ⚠️  CAUTION: Moderate WebSocket issues detected" | tee -a "$LOG_FILE"
                ;;
            "LOW"|*)
                echo "   ✅ WebSocket connections stable" | tee -a "$LOG_FILE"
                ;;
        esac
    fi
    
    return 0
}

# Function: Generate predictive analysis safely  
generate_predictive_analysis() {
    echo "" | tee -a "$LOG_FILE"
    echo "🔮 PREDICTIVE ANALYSIS:" | tee -a "$LOG_FILE"
    
    # Parse current metrics safely
    if [[ -z "${CURRENT_METRICS:-}" ]]; then
        echo "   ⚠️  Current metrics not available for prediction" | tee -a "$LOG_FILE"
        return 1
    fi
    
    local current_memory_percent current_disk_percent current_openclaw_memory
    if ! IFS=',' read -r _ _ current_memory_percent _ current_disk_percent _ current_openclaw_memory _ _ _ <<< "$CURRENT_METRICS"; then
        echo "   ⚠️  Cannot parse current metrics for prediction" | tee -a "$LOG_FILE"
        return 1
    fi
    
    echo "   📊 Current system state:" | tee -a "$LOG_FILE"
    echo "      Memory usage: ${current_memory_percent}%" | tee -a "$LOG_FILE"
    echo "      Disk usage: ${current_disk_percent}%" | tee -a "$LOG_FILE"  
    echo "      OpenClaw memory: ${current_openclaw_memory}MB" | tee -a "$LOG_FILE"
    
    # Predictive warnings with safe arithmetic
    if (( $(echo "$current_memory_percent > 80" | bc -l 2>/dev/null || echo 0) )); then
        echo "   🔴 PREDICTION: Memory usage approaching critical levels" | tee -a "$LOG_FILE"
    elif (( $(echo "$current_memory_percent > 60" | bc -l 2>/dev/null || echo 0) )); then
        echo "   ⚠️  PREDICTION: Monitor memory usage - trending upward" | tee -a "$LOG_FILE"
    fi
    
    if (( current_disk_percent > 85 )); then
        echo "   🔴 PREDICTION: Disk space approaching critical levels" | tee -a "$LOG_FILE"
    elif (( current_disk_percent > 70 )); then
        echo "   ⚠️  PREDICTION: Consider cleanup - disk usage elevated" | tee -a "$LOG_FILE"
    fi
    
    # OpenClaw-specific predictions
    if (( $(echo "$current_openclaw_memory > 2000" | bc -l 2>/dev/null || echo 0) )); then
        echo "   ⚠️  PREDICTION: OpenClaw memory usage high - monitor for leaks" | tee -a "$LOG_FILE"
    fi
    
    return 0
}

# Function: Generate intelligent recommendations
generate_intelligent_recommendations() {
    echo "" | tee -a "$LOG_FILE"
    echo "🎯 OPTIMIZATION OPPORTUNITIES:" | tee -a "$LOG_FILE"
    
    # Context-aware recommendations
    local current_hour
    current_hour=$(date +%H)
    
    if (( current_hour >= 8 && current_hour <= 17 )); then
        echo "   ⏰ Work hours context: Focus on performance optimization" | tee -a "$LOG_FILE"
    else
        echo "   🌙 Off-hours context: Safe time for maintenance operations" | tee -a "$LOG_FILE"
    fi
    
    # Standard recommendations
    echo "   📋 System optimization suggestions:" | tee -a "$LOG_FILE"
    echo "      • Monitor OpenClaw memory growth patterns" | tee -a "$LOG_FILE"
    echo "      • Track network stability trends" | tee -a "$LOG_FILE"
    echo "      • Review log files for recurring issues" | tee -a "$LOG_FILE"
    echo "      • Consider cleanup if disk usage >70%" | tee -a "$LOG_FILE"
    
    return 0
}

# Function: Check integration with existing monitoring
check_monitoring_integration() {
    echo "" | tee -a "$LOG_FILE"
    echo "🔗 MONITORING INTEGRATION:" | tee -a "$LOG_FILE"
    
    # Check for existing monitoring tools
    local existing_monitor="$WORKSPACE/tools/monitoring/openclaw-monitor.sh"
    
    if [[ -x "$existing_monitor" ]]; then
        echo "   ✅ Integration with existing OpenClaw monitor available" | tee -a "$LOG_FILE"
        
        # Check systemd timer status safely
        local timer_status
        if timer_status=$(timeout 5 systemctl --user is-active openclaw-monitor.timer 2>/dev/null || echo "inactive"); then
            echo "   📊 Monitoring timer status: $timer_status" | tee -a "$LOG_FILE"
        else
            echo "   ⚠️  Cannot determine monitoring timer status" | tee -a "$LOG_FILE"
        fi
    else
        echo "   💡 Standalone monitoring - consider integration with existing tools" | tee -a "$LOG_FILE"
    fi
    
    return 0
}

# Function: Generate deployment recommendations
generate_deployment_recommendations() {
    echo "" | tee -a "$LOG_FILE"
    echo "🚀 DEPLOYMENT RECOMMENDATIONS:" | tee -a "$LOG_FILE"
    
    echo "   🛠️ IMPLEMENTATION:" | tee -a "$LOG_FILE"
    echo "      • Create systemd user timers for each tool" | tee -a "$LOG_FILE"
    echo "      • Set up log rotation for automation outputs" | tee -a "$LOG_FILE"
    echo "      • Configure alert thresholds for critical issues" | tee -a "$LOG_FILE"
    echo "      • Integrate with existing OpenClaw monitoring" | tee -a "$LOG_FILE"
    
    return 0
}

# Main execution with comprehensive error handling
main() {
    # Initialize secure environment
    if ! initialize_environment; then
        echo "❌ Failed to initialize environment" >&2
        cleanup_and_exit 1
    fi
    
    # Execute monitoring functions
    local -a monitor_functions=(
        "collect_system_metrics"
        "analyze_performance_trends"
        "generate_predictive_analysis"
        "generate_intelligent_recommendations"
        "check_monitoring_integration"
        "generate_deployment_recommendations"
    )
    
    local failed_functions=0
    for func in "${monitor_functions[@]}"; do
        echo "   Executing: $func..." >&2
        if ! "$func"; then
            echo "   ⚠️  Function $func completed with warnings" >&2
            ((failed_functions++))
        fi
    done
    
    # Final status
    echo "" | tee -a "$LOG_FILE"
    if (( failed_functions == 0 )); then
        echo "🏁 INTELLIGENT MONITORING COMPLETE - $(date)" | tee -a "$LOG_FILE"
    else
        echo "🏁 INTELLIGENT MONITORING COMPLETE WITH $failed_functions WARNINGS - $(date)" | tee -a "$LOG_FILE"
    fi
    echo "📄 Full log available at: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "📊 Metrics stored at: $METRICS_FILE" | tee -a "$LOG_FILE"
    echo "================================================" | tee -a "$LOG_FILE"
    
    cleanup_and_exit 0
}

# Execute main function
main "$@"