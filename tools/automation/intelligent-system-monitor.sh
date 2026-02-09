#!/bin/bash
# Intelligent System Monitor - Predictive Performance Analysis
# Advanced monitoring with trend analysis and predictive alerts

WORKSPACE="/home/ette/.openclaw/workspace"
LOG_FILE="/tmp/intelligent-system-monitor.log"
METRICS_DIR="/tmp/system-metrics"
OPENCLAW_PID=$(pgrep -f openclaw-gateway)

echo "🤖 Intelligent System Monitor - $(date)" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE

# Create metrics directory for trend tracking
mkdir -p "$METRICS_DIR"

# Function: Collect comprehensive system metrics
collect_system_metrics() {
    echo "" | tee -a $LOG_FILE
    echo "📊 COLLECTING SYSTEM METRICS:" | tee -a $LOG_FILE
    
    TIMESTAMP=$(date +%s)
    METRICS_FILE="$METRICS_DIR/metrics-$TIMESTAMP.json"
    
    # System resource metrics
    LOAD_1MIN=$(cat /proc/loadavg | awk '{print $1}')
    MEMORY_USED=$(free -m | grep Mem | awk '{print $3}')
    MEMORY_AVAILABLE=$(free -m | grep Mem | awk '{print $7}')
    DISK_USED=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    # OpenClaw specific metrics
    if [ ! -z "$OPENCLAW_PID" ]; then
        OC_MEMORY=$(ps -p $OPENCLAW_PID -o rss --no-headers 2>/dev/null || echo "0")
        OC_CONNECTIONS=$(lsof -p $OPENCLAW_PID -a -i 2>/dev/null | wc -l)
        SLOW_EVENTS_1H=$(journalctl --user -u openclaw-gateway --since="1 hour ago" --no-pager 2>/dev/null | grep "Slow listener" | wc -l)
        WEBSOCKET_DROPS_1H=$(journalctl --user -u openclaw-gateway --since="1 hour ago" --no-pager 2>/dev/null | grep "WebSocket connection closed" | wc -l)
    else
        OC_MEMORY=0
        OC_CONNECTIONS=0
        SLOW_EVENTS_1H=0
        WEBSOCKET_DROPS_1H=0
    fi
    
    # Store metrics in simple format for analysis
    echo "$TIMESTAMP,$LOAD_1MIN,$MEMORY_USED,$MEMORY_AVAILABLE,$DISK_USED,$OC_MEMORY,$OC_CONNECTIONS,$SLOW_EVENTS_1H,$WEBSOCKET_DROPS_1H" >> "$METRICS_DIR/metrics.csv"
    
    echo "   ✅ Metrics collected and stored" | tee -a $LOG_FILE
}

# Function: Analyze performance trends
analyze_performance_trends() {
    echo "" | tee -a $LOG_FILE
    echo "📈 PERFORMANCE TREND ANALYSIS:" | tee -a $LOG_FILE
    
    METRICS_FILE="$METRICS_DIR/metrics.csv"
    
    if [ ! -f "$METRICS_FILE" ] || [ $(wc -l < "$METRICS_FILE") -lt 2 ]; then
        echo "   ℹ️  Insufficient data for trend analysis" | tee -a $LOG_FILE
        echo "   💡 Run this monitor regularly to build trend data" | tee -a $LOG_FILE
        return
    fi
    
    # Simple trend analysis using last few entries
    RECENT_ENTRIES=$(tail -5 "$METRICS_FILE")
    ENTRY_COUNT=$(echo "$RECENT_ENTRIES" | wc -l)
    
    echo "   📊 Analyzing last $ENTRY_COUNT data points..." | tee -a $LOG_FILE
    
    # Check for concerning trends
    HIGH_LOAD_COUNT=$(echo "$RECENT_ENTRIES" | awk -F',' '$2 > 1.0' | wc -l)
    HIGH_MEMORY_COUNT=$(echo "$RECENT_ENTRIES" | awk -F',' '$3 > 6000' | wc -l)
    SLOW_EVENTS_COUNT=$(echo "$RECENT_ENTRIES" | awk -F',' '$8 > 0' | wc -l)
    WEBSOCKET_ISSUES_COUNT=$(echo "$RECENT_ENTRIES" | awk -F',' '$9 > 10' | wc -l)
    
    if [ $HIGH_LOAD_COUNT -gt 2 ]; then
        echo "   🔴 ALERT: High system load trend detected ($HIGH_LOAD_COUNT/$ENTRY_COUNT samples)" | tee -a $LOG_FILE
    fi
    
    if [ $HIGH_MEMORY_COUNT -gt 2 ]; then
        echo "   🟡 WARNING: High memory usage trend ($HIGH_MEMORY_COUNT/$ENTRY_COUNT samples)" | tee -a $LOG_FILE
    fi
    
    if [ $SLOW_EVENTS_COUNT -gt 0 ]; then
        echo "   🔴 ALERT: Message processing delays detected ($SLOW_EVENTS_COUNT/$ENTRY_COUNT samples)" | tee -a $LOG_FILE
    fi
    
    if [ $WEBSOCKET_ISSUES_COUNT -gt 1 ]; then
        echo "   🔴 ALERT: Network instability pattern ($WEBSOCKET_ISSUES_COUNT/$ENTRY_COUNT samples with >10 drops/hour)" | tee -a $LOG_FILE
    fi
    
    if [ $HIGH_LOAD_COUNT -eq 0 ] && [ $HIGH_MEMORY_COUNT -eq 0 ] && [ $SLOW_EVENTS_COUNT -eq 0 ] && [ $WEBSOCKET_ISSUES_COUNT -le 1 ]; then
        echo "   ✅ System performance trends are healthy" | tee -a $LOG_FILE
    fi
}

# Function: Predictive analysis and recommendations
generate_predictive_insights() {
    echo "" | tee -a $LOG_FILE
    echo "🔮 PREDICTIVE ANALYSIS:" | tee -a $LOG_FILE
    
    # Current system state analysis
    CURRENT_LOAD=$(cat /proc/loadavg | awk '{print $1}')
    CURRENT_MEMORY_PCT=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')
    
    echo "   📊 Current system state:" | tee -a $LOG_FILE
    echo "      Load average: $CURRENT_LOAD" | tee -a $LOG_FILE
    echo "      Memory usage: ${CURRENT_MEMORY_PCT}%" | tee -a $LOG_FILE
    
    # Predictive recommendations based on patterns
    if [ ! -z "$OPENCLAW_PID" ]; then
        CURRENT_OC_MEMORY=$(ps -p $OPENCLAW_PID -o rss --no-headers | awk '{print $1/1024}')
        echo "      OpenClaw memory: ${CURRENT_OC_MEMORY}MB" | tee -a $LOG_FILE
        
        # Memory growth prediction (simplified)
        if (( $(echo "$CURRENT_OC_MEMORY > 1200" | bc -l) )); then
            echo "   🔮 PREDICTION: OpenClaw memory usage approaching restart threshold" | tee -a $LOG_FILE
            echo "   💡 Consider scheduling gateway restart in next 24-48 hours" | tee -a $LOG_FILE
        fi
    fi
    
    # WSL2 network stability prediction
    if [ -f "$METRICS_DIR/metrics.csv" ]; then
        RECENT_WEBSOCKET_ISSUES=$(tail -3 "$METRICS_DIR/metrics.csv" | awk -F',' '$9 > 5' | wc -l)
        if [ $RECENT_WEBSOCKET_ISSUES -gt 1 ]; then
            echo "   🔮 PREDICTION: Network instability pattern suggests WSL2 issues" | tee -a $LOG_FILE
            echo "   💡 Consider native Linux migration or network stack optimization" | tee -a $LOG_FILE
        fi
    fi
    
    # System optimization suggestions
    echo "" | tee -a $LOG_FILE
    echo "   🎯 OPTIMIZATION OPPORTUNITIES:" | tee -a $LOG_FILE
    echo "      • Monitor OpenClaw memory growth patterns" | tee -a $LOG_FILE
    echo "      • Track network stability trends" | tee -a $LOG_FILE
    echo "      • Correlate system load with performance issues" | tee -a $LOG_FILE
    echo "      • Implement predictive restart scheduling" | tee -a $LOG_FILE
}

# Function: Integration with existing monitoring
check_monitoring_integration() {
    echo "" | tee -a $LOG_FILE
    echo "🔗 MONITORING INTEGRATION STATUS:" | tee -a $LOG_FILE
    
    # Check if other monitoring tools are active
    BASIC_MONITOR="$WORKSPACE/tools/monitoring/openclaw-monitor.sh"
    NETWORK_MONITOR="$WORKSPACE/tools/monitoring/network-health-check.sh"
    
    if [ -f "$BASIC_MONITOR" ]; then
        echo "   ✅ Basic OpenClaw monitor available" | tee -a $LOG_FILE
    fi
    
    if [ -f "$NETWORK_MONITOR" ]; then
        echo "   ✅ Network health monitor available" | tee -a $LOG_FILE
    fi
    
    # Check systemd timer status
    TIMER_STATUS=$(systemctl --user is-active openclaw-monitor.timer 2>/dev/null || echo "inactive")
    echo "   📊 Monitoring timer status: $TIMER_STATUS" | tee -a $LOG_FILE
    
    if [ "$TIMER_STATUS" = "active" ]; then
        echo "   ✅ Automated monitoring is running" | tee -a $LOG_FILE
    else
        echo "   💡 Consider enabling automated monitoring timer" | tee -a $LOG_FILE
    fi
}

# Function: Generate intelligent recommendations
generate_intelligent_recommendations() {
    echo "" | tee -a $LOG_FILE
    echo "🧠 INTELLIGENT RECOMMENDATIONS:" | tee -a $LOG_FILE
    
    # Time-based recommendations
    HOUR=$(date +%H)
    if [ $HOUR -ge 8 ] && [ $HOUR -le 17 ]; then
        echo "   ⏰ Work hours detected - prioritizing performance stability" | tee -a $LOG_FILE
    else
        echo "   🌙 Off-hours detected - good time for maintenance tasks" | tee -a $LOG_FILE
        echo "   💡 Consider running memory consolidation or system updates" | tee -a $LOG_FILE
    fi
    
    # Day of week recommendations
    DAY=$(date +%u)  # 1=Monday, 7=Sunday
    if [ $DAY -eq 7 ]; then
        echo "   📅 Sunday - ideal for comprehensive system maintenance" | tee -a $LOG_FILE
        echo "   💡 Run memory optimization, workspace cleanup, and system updates" | tee -a $LOG_FILE
    fi
    
    # Integration recommendations
    echo "" | tee -a $LOG_FILE
    echo "   🔧 NEXT STEPS:" | tee -a $LOG_FILE
    echo "      • Set up automated data collection (run every 15 minutes)" | tee -a $LOG_FILE
    echo "      • Implement alert thresholds for critical metrics" | tee -a $LOG_FILE
    echo "      • Create performance trend reports (weekly)" | tee -a $LOG_FILE
    echo "      • Integrate with memory and workspace automation" | tee -a $LOG_FILE
}

# Main execution
echo "Starting intelligent system monitoring..." | tee -a $LOG_FILE

collect_system_metrics
analyze_performance_trends
generate_predictive_insights
check_monitoring_integration
generate_intelligent_recommendations

echo "" | tee -a $LOG_FILE
echo "🏁 INTELLIGENT MONITORING COMPLETE - $(date)" | tee -a $LOG_FILE
echo "📄 Full log available at: $LOG_FILE" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE