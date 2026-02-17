#!/bin/bash
# DEPRECATION NOTICE: This is a legacy script. Use memory-maintenance-improved.sh instead.
# CANONICAL SCRIPT: tools/automation/memory-maintenance-improved.sh
# Migration: update any direct call/cron/systemd entry to the canonical script.

# Memory System Maintenance Automation
# Keeps optimized memory system in peak condition

WORKSPACE="/home/ette/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
LOG_FILE="/tmp/memory-maintenance.log"

echo "🧠 Memory System Maintenance - $(date)" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE

# Function: Analyze memory file sizes and suggest consolidation
analyze_memory_growth() {
    echo "" | tee -a $LOG_FILE
    echo "📊 MEMORY GROWTH ANALYSIS:" | tee -a $LOG_FILE
    
    # Find large daily memory files that might need topic promotion
    LARGE_DAILY_FILES=$(find $MEMORY_DIR -name "2026-*.md" -exec wc -w {} \; | awk '$1 > 500 {print $2}' | wc -l)
    
    if [ $LARGE_DAILY_FILES -gt 0 ]; then
        echo "   ⚠️  Large daily files found: $LARGE_DAILY_FILES files >500 words" | tee -a $LOG_FILE
        echo "   💡 Consider promoting substantial content to topical files" | tee -a $LOG_FILE
        
        # List specific large files
        find $MEMORY_DIR -name "2026-*.md" -exec wc -w {} \; | awk '$1 > 500 {print "      📄 " $2 ": " $1 " words"}' | tee -a $LOG_FILE
    else
        echo "   ✅ Daily file sizes are optimal" | tee -a $LOG_FILE
    fi
}

# Function: Check cross-reference index freshness
check_cross_reference_freshness() {
    echo "" | tee -a $LOG_FILE
    echo "🔗 CROSS-REFERENCE INDEX STATUS:" | tee -a $LOG_FILE
    
    INDEX_FILE="$MEMORY_DIR/CROSS-REFERENCE-INDEX.md"
    INDEX_AGE=$(find "$INDEX_FILE" -mtime +7 2>/dev/null | wc -l)
    
    if [ $INDEX_AGE -gt 0 ]; then
        echo "   ⚠️  Cross-reference index is >7 days old" | tee -a $LOG_FILE
        echo "   💡 Consider updating with recent memory additions" | tee -a $LOG_FILE
    else
        echo "   ✅ Cross-reference index is current" | tee -a $LOG_FILE
    fi
    
    # Count recent memory files not in index
    RECENT_FILES=$(find $MEMORY_DIR -name "*.md" -newer "$INDEX_FILE" 2>/dev/null | wc -l)
    if [ $RECENT_FILES -gt 1 ]; then
        echo "   📝 $RECENT_FILES memory files created since last index update" | tee -a $LOG_FILE
    fi
}

# Function: Detect content duplication opportunities
detect_content_duplication() {
    echo "" | tee -a $LOG_FILE
    echo "🔄 CONTENT CONSOLIDATION OPPORTUNITIES:" | tee -a $LOG_FILE
    
    # Look for repeated topics across multiple files
    OPENCLAW_REFS=$(grep -l "OpenClaw" $MEMORY_DIR/*.md $MEMORY_DIR/*/*.md 2>/dev/null | wc -l)
    NETWORK_REFS=$(grep -l -i "network\|WSL2\|performance" $MEMORY_DIR/*.md $MEMORY_DIR/*/*.md 2>/dev/null | wc -l)
    PARTNERSHIP_REFS=$(grep -l -i "partnership\|trust\|collaboration" $MEMORY_DIR/*.md $MEMORY_DIR/*/*.md 2>/dev/null | wc -l)
    
    echo "   📈 Topic distribution analysis:" | tee -a $LOG_FILE
    echo "      OpenClaw references: $OPENCLAW_REFS files" | tee -a $LOG_FILE
    echo "      Network/performance: $NETWORK_REFS files" | tee -a $LOG_FILE
    echo "      Partnership topics: $PARTNERSHIP_REFS files" | tee -a $LOG_FILE
    
    # Suggest consolidation if topics are spread across many files
    if [ $OPENCLAW_REFS -gt 8 ]; then
        echo "   💡 Consider consolidating OpenClaw content (spread across $OPENCLAW_REFS files)" | tee -a $LOG_FILE
    fi
}

# Function: Memory search performance check
check_memory_search_performance() {
    echo "" | tee -a $LOG_FILE
    echo "⚡ MEMORY SEARCH PERFORMANCE:" | tee -a $LOG_FILE
    
    TOTAL_MEMORY_FILES=$(find $MEMORY_DIR -name "*.md" | wc -l)
    TOTAL_MEMORY_SIZE=$(du -sh $MEMORY_DIR | cut -f1)
    
    echo "   📊 Memory system metrics:" | tee -a $LOG_FILE
    echo "      Total memory files: $TOTAL_MEMORY_FILES" | tee -a $LOG_FILE
    echo "      Total memory size: $TOTAL_MEMORY_SIZE" | tee -a $LOG_FILE
    
    # Performance recommendations based on size
    if [ $TOTAL_MEMORY_FILES -gt 25 ]; then
        echo "   💡 Consider memory archiving for files >30 days old" | tee -a $LOG_FILE
    else
        echo "   ✅ Memory file count optimal for search performance" | tee -a $LOG_FILE
    fi
}

# Function: Generate memory maintenance recommendations
generate_recommendations() {
    echo "" | tee -a $LOG_FILE
    echo "🎯 MAINTENANCE RECOMMENDATIONS:" | tee -a $LOG_FILE
    
    # Check when last major optimization occurred
    LAST_OPTIMIZATION=$(find $MEMORY_DIR -name "*OPTIMIZATION*" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f1 | cut -d'.' -f1)
    CURRENT_TIME=$(date +%s)
    DAYS_SINCE_OPTIMIZATION=$(( (CURRENT_TIME - ${LAST_OPTIMIZATION:-0}) / 86400 ))
    
    if [ $DAYS_SINCE_OPTIMIZATION -gt 14 ]; then
        echo "   🔧 Consider comprehensive memory system review (${DAYS_SINCE_OPTIMIZATION} days since last optimization)" | tee -a $LOG_FILE
    fi
    
    # General maintenance suggestions
    echo "   📋 Regular maintenance tasks:" | tee -a $LOG_FILE
    echo "      • Update cross-reference index weekly" | tee -a $LOG_FILE
    echo "      • Promote substantial daily content to topical files" | tee -a $LOG_FILE
    echo "      • Review and consolidate related technical content" | tee -a $LOG_FILE
    echo "      • Archive memories >60 days old to maintain search speed" | tee -a $LOG_FILE
}

# Function: Check integration with workspace organization
check_workspace_integration() {
    echo "" | tee -a $LOG_FILE
    echo "🔗 WORKSPACE INTEGRATION STATUS:" | tee -a $LOG_FILE
    
    # Check if memory organization aligns with project organization
    PROJECT_TOPICS=$(find $WORKSPACE/projects -type d -mindepth 1 -maxdepth 1 | wc -l)
    MEMORY_PROJECT_REFS=$(find $MEMORY_DIR/projects -name "*.md" 2>/dev/null | wc -l)
    
    echo "   📊 Integration metrics:" | tee -a $LOG_FILE
    echo "      Active project categories: $PROJECT_TOPICS" | tee -a $LOG_FILE
    echo "      Project memory files: $MEMORY_PROJECT_REFS" | tee -a $LOG_FILE
    
    if [ $PROJECT_TOPICS -gt $MEMORY_PROJECT_REFS ]; then
        echo "   💡 Some project categories may need memory documentation" | tee -a $LOG_FILE
    else
        echo "   ✅ Memory system covers active project areas" | tee -a $LOG_FILE
    fi
}

# Main execution
echo "Starting automated memory system maintenance..." | tee -a $LOG_FILE

analyze_memory_growth
check_cross_reference_freshness  
detect_content_duplication
check_memory_search_performance
check_workspace_integration
generate_recommendations

echo "" | tee -a $LOG_FILE
echo "🏁 MAINTENANCE COMPLETE - $(date)" | tee -a $LOG_FILE
echo "📄 Full log available at: $LOG_FILE" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
