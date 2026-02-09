#!/bin/bash
# Automation Orchestrator - Coordinated System Optimization
# Runs all automation systems in optimal sequence

WORKSPACE="/home/ette/.openclaw/workspace"
AUTOMATION_DIR="$WORKSPACE/tools/automation"
LOG_FILE="/tmp/automation-orchestrator.log"

echo "🎼 Automation Orchestrator - $(date)" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE

# Function: Check automation prerequisites
check_prerequisites() {
    echo "" | tee -a $LOG_FILE
    echo "🔍 CHECKING AUTOMATION PREREQUISITES:" | tee -a $LOG_FILE
    
    # Check if automation tools exist
    MEMORY_TOOL="$AUTOMATION_DIR/memory-maintenance.sh"
    WORKSPACE_TOOL="$AUTOMATION_DIR/workspace-health-monitor.sh"
    SYSTEM_TOOL="$AUTOMATION_DIR/intelligent-system-monitor.sh"
    
    TOOLS_AVAILABLE=0
    
    if [ -f "$MEMORY_TOOL" ] && [ -x "$MEMORY_TOOL" ]; then
        echo "   ✅ Memory maintenance tool ready" | tee -a $LOG_FILE
        TOOLS_AVAILABLE=$((TOOLS_AVAILABLE + 1))
    else
        echo "   ❌ Memory maintenance tool missing or not executable" | tee -a $LOG_FILE
    fi
    
    if [ -f "$WORKSPACE_TOOL" ] && [ -x "$WORKSPACE_TOOL" ]; then
        echo "   ✅ Workspace health monitor ready" | tee -a $LOG_FILE
        TOOLS_AVAILABLE=$((TOOLS_AVAILABLE + 1))
    else
        echo "   ❌ Workspace health monitor missing or not executable" | tee -a $LOG_FILE
    fi
    
    if [ -f "$SYSTEM_TOOL" ] && [ -x "$SYSTEM_TOOL" ]; then
        echo "   ✅ Intelligent system monitor ready" | tee -a $LOG_FILE
        TOOLS_AVAILABLE=$((TOOLS_AVAILABLE + 1))
    else
        echo "   ❌ Intelligent system monitor missing or not executable" | tee -a $LOG_FILE
    fi
    
    echo "   📊 Available tools: $TOOLS_AVAILABLE/3" | tee -a $LOG_FILE
    
    if [ $TOOLS_AVAILABLE -lt 3 ]; then
        echo "   ⚠️  Some automation tools are missing - proceeding with available tools" | tee -a $LOG_FILE
    fi
    
    return $TOOLS_AVAILABLE
}

# Function: Run memory system maintenance
run_memory_maintenance() {
    if [ -f "$AUTOMATION_DIR/memory-maintenance.sh" ] && [ -x "$AUTOMATION_DIR/memory-maintenance.sh" ]; then
        echo "" | tee -a $LOG_FILE
        echo "🧠 EXECUTING MEMORY SYSTEM MAINTENANCE:" | tee -a $LOG_FILE
        
        # Run memory maintenance and capture key findings
        MEMORY_OUTPUT=$("$AUTOMATION_DIR/memory-maintenance.sh" 2>&1)
        MEMORY_EXIT_CODE=$?
        
        if [ $MEMORY_EXIT_CODE -eq 0 ]; then
            echo "   ✅ Memory maintenance completed successfully" | tee -a $LOG_FILE
            
            # Extract key insights
            LARGE_FILES=$(echo "$MEMORY_OUTPUT" | grep -c "files >500 words" || echo 0)
            CROSS_REF_STATUS=$(echo "$MEMORY_OUTPUT" | grep -o "Cross-reference index is.*" | head -1)
            OPENCLAW_REFS=$(echo "$MEMORY_OUTPUT" | grep -o "OpenClaw references: [0-9]* files" | grep -o "[0-9]*")
            
            echo "   📊 Key findings:" | tee -a $LOG_FILE
            [ ! -z "$CROSS_REF_STATUS" ] && echo "      • $CROSS_REF_STATUS" | tee -a $LOG_FILE
            [ ! -z "$OPENCLAW_REFS" ] && echo "      • OpenClaw content spans $OPENCLAW_REFS files" | tee -a $LOG_FILE
        else
            echo "   ❌ Memory maintenance encountered issues (exit code: $MEMORY_EXIT_CODE)" | tee -a $LOG_FILE
        fi
    else
        echo "   ⏭️  Memory maintenance tool not available - skipping" | tee -a $LOG_FILE
    fi
}

# Function: Run workspace health monitoring
run_workspace_monitoring() {
    if [ -f "$AUTOMATION_DIR/workspace-health-monitor.sh" ] && [ -x "$AUTOMATION_DIR/workspace-health-monitor.sh" ]; then
        echo "" | tee -a $LOG_FILE
        echo "🗂️ EXECUTING WORKSPACE HEALTH MONITORING:" | tee -a $LOG_FILE
        
        # Run workspace monitoring and capture key findings
        WORKSPACE_OUTPUT=$("$AUTOMATION_DIR/workspace-health-monitor.sh" 2>&1)
        WORKSPACE_EXIT_CODE=$?
        
        if [ $WORKSPACE_EXIT_CODE -eq 0 ]; then
            echo "   ✅ Workspace health check completed successfully" | tee -a $LOG_FILE
            
            # Extract key insights
            ROOT_STATUS=$(echo "$WORKSPACE_OUTPUT" | grep -o "Root directory.*" | head -1)
            PROJECT_COUNT=$(echo "$WORKSPACE_OUTPUT" | grep -o "Project categories: [0-9]*" | grep -o "[0-9]*")
            ARCHIVE_COUNT=$(echo "$WORKSPACE_OUTPUT" | grep -o "Archived items: [0-9]* files" | grep -o "[0-9]*")
            
            echo "   📊 Key findings:" | tee -a $LOG_FILE
            [ ! -z "$ROOT_STATUS" ] && echo "      • $ROOT_STATUS" | tee -a $LOG_FILE
            [ ! -z "$PROJECT_COUNT" ] && echo "      • Active project categories: $PROJECT_COUNT" | tee -a $LOG_FILE
            [ ! -z "$ARCHIVE_COUNT" ] && echo "      • Archived files: $ARCHIVE_COUNT" | tee -a $LOG_FILE
        else
            echo "   ❌ Workspace monitoring encountered issues (exit code: $WORKSPACE_EXIT_CODE)" | tee -a $LOG_FILE
        fi
    else
        echo "   ⏭️  Workspace health monitor not available - skipping" | tee -a $LOG_FILE
    fi
}

# Function: Run intelligent system monitoring
run_system_monitoring() {
    if [ -f "$AUTOMATION_DIR/intelligent-system-monitor.sh" ] && [ -x "$AUTOMATION_DIR/intelligent-system-monitor.sh" ]; then
        echo "" | tee -a $LOG_FILE
        echo "🤖 EXECUTING INTELLIGENT SYSTEM MONITORING:" | tee -a $LOG_FILE
        
        # Run system monitoring and capture key findings
        SYSTEM_OUTPUT=$("$AUTOMATION_DIR/intelligent-system-monitor.sh" 2>&1)
        SYSTEM_EXIT_CODE=$?
        
        if [ $SYSTEM_EXIT_CODE -eq 0 ]; then
            echo "   ✅ Intelligent system monitoring completed successfully" | tee -a $LOG_FILE
            
            # Extract key insights
            ALERTS=$(echo "$SYSTEM_OUTPUT" | grep -c "ALERT:" || echo 0)
            WARNINGS=$(echo "$SYSTEM_OUTPUT" | grep -c "WARNING:" || echo 0)
            PREDICTIONS=$(echo "$SYSTEM_OUTPUT" | grep -c "PREDICTION:" || echo 0)
            
            echo "   📊 Key findings:" | tee -a $LOG_FILE
            echo "      • Alerts detected: $ALERTS" | tee -a $LOG_FILE
            echo "      • Warnings detected: $WARNINGS" | tee -a $LOG_FILE
            echo "      • Predictions generated: $PREDICTIONS" | tee -a $LOG_FILE
            
            # Show critical alerts if any
            if [ $ALERTS -gt 0 ]; then
                echo "   🚨 Critical alerts:" | tee -a $LOG_FILE
                echo "$SYSTEM_OUTPUT" | grep "ALERT:" | sed 's/^/      /' | tee -a $LOG_FILE
            fi
        else
            echo "   ❌ System monitoring encountered issues (exit code: $SYSTEM_EXIT_CODE)" | tee -a $LOG_FILE
        fi
    else
        echo "   ⏭️  Intelligent system monitor not available - skipping" | tee -a $LOG_FILE
    fi
}

# Function: Generate orchestrated recommendations
generate_orchestrated_recommendations() {
    echo "" | tee -a $LOG_FILE
    echo "🎯 ORCHESTRATED RECOMMENDATIONS:" | tee -a $LOG_FILE
    
    # Analyze results from all automation systems
    echo "   📋 Integrated optimization strategy:" | tee -a $LOG_FILE
    echo ""
    echo "   🧠 MEMORY SYSTEM:" | tee -a $LOG_FILE
    echo "      • Regular cross-reference index updates" | tee -a $LOG_FILE
    echo "      • Monitor for content consolidation opportunities" | tee -a $LOG_FILE
    echo "      • Maintain optimal file sizes for search performance" | tee -a $LOG_FILE
    echo ""
    echo "   🗂️ WORKSPACE:" | tee -a $LOG_FILE
    echo "      • Keep root directory clean (8 config files only)" | tee -a $LOG_FILE
    echo "      • Add READMEs to project categories for navigation" | tee -a $LOG_FILE
    echo "      • Archive completed projects to maintain organization" | tee -a $LOG_FILE
    echo ""
    echo "   🖥️ SYSTEM:" | tee -a $LOG_FILE
    echo "      • Continue monitoring WSL2 network stability" | tee -a $LOG_FILE
    echo "      • Track OpenClaw memory growth patterns" | tee -a $LOG_FILE
    echo "      • Implement predictive maintenance scheduling" | tee -a $LOG_FILE
    echo ""
    echo "   🔄 AUTOMATION:" | tee -a $LOG_FILE
    echo "      • Run this orchestrator weekly for comprehensive analysis" | tee -a $LOG_FILE
    echo "      • Set up individual tool timers for continuous monitoring" | tee -a $LOG_FILE
    echo "      • Integrate findings with decision-making processes" | tee -a $LOG_FILE
}

# Function: Setup automation scheduling
suggest_automation_scheduling() {
    echo "" | tee -a $LOG_FILE
    echo "⏰ AUTOMATION SCHEDULING SUGGESTIONS:" | tee -a $LOG_FILE
    echo ""
    echo "   📅 RECOMMENDED SCHEDULE:" | tee -a $LOG_FILE
    echo "      • Memory maintenance: Weekly (Sunday mornings)" | tee -a $LOG_FILE
    echo "      • Workspace health: Daily (evening)" | tee -a $LOG_FILE
    echo "      • System monitoring: Every 15 minutes (continuous)" | tee -a $LOG_FILE
    echo "      • Full orchestration: Weekly (Sunday)" | tee -a $LOG_FILE
    echo ""
    echo "   🛠️ IMPLEMENTATION:" | tee -a $LOG_FILE
    echo "      • Create systemd user timers for each tool" | tee -a $LOG_FILE
    echo "      • Set up log rotation for automation outputs" | tee -a $LOG_FILE
    echo "      • Configure alert thresholds for critical issues" | tee -a $LOG_FILE
    echo "      • Integrate with existing OpenClaw monitoring" | tee -a $LOG_FILE
}

# Main orchestration execution
echo "Starting coordinated automation sequence..." | tee -a $LOG_FILE

# Check prerequisites
check_prerequisites
AVAILABLE_TOOLS=$?

if [ $AVAILABLE_TOOLS -eq 0 ]; then
    echo "" | tee -a $LOG_FILE
    echo "❌ No automation tools available - cannot proceed with orchestration" | tee -a $LOG_FILE
    exit 1
fi

# Execute automation sequence in optimal order
echo "" | tee -a $LOG_FILE
echo "🚀 BEGINNING AUTOMATION SEQUENCE (${AVAILABLE_TOOLS}/3 tools available):" | tee -a $LOG_FILE

# 1. Memory maintenance (foundation for other analyses)
run_memory_maintenance

# 2. Workspace health monitoring (builds on memory insights)
run_workspace_monitoring

# 3. System monitoring (provides context for all optimizations)
run_system_monitoring

# Generate integrated recommendations
generate_orchestrated_recommendations

# Suggest scheduling for ongoing automation
suggest_automation_scheduling

echo "" | tee -a $LOG_FILE
echo "🏁 AUTOMATION ORCHESTRATION COMPLETE - $(date)" | tee -a $LOG_FILE
echo "📄 Complete orchestration log: $LOG_FILE" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE