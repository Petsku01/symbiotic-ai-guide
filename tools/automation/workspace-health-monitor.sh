#!/bin/bash
# Workspace Health Monitoring Automation
# Maintains professional workspace organization

WORKSPACE="/home/ette/.openclaw/workspace"
LOG_FILE="/tmp/workspace-health.log"

echo "🗂️ Workspace Health Monitor - $(date)" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE

# Function: Check root directory cleanliness
check_root_directory() {
    echo "" | tee -a $LOG_FILE
    echo "📁 ROOT DIRECTORY HEALTH:" | tee -a $LOG_FILE
    
    cd "$WORKSPACE"
    
    # Count files that should be in root (configuration files)
    CONFIG_FILES=("SOUL.md" "IDENTITY.md" "BOOTSTRAP.md" "AGENTS.md" "HEARTBEAT.md" "TOOLS.md" "USER.md" "MEMORY.md")
    EXPECTED_COUNT=${#CONFIG_FILES[@]}
    
    # Count actual markdown files in root
    ACTUAL_MD_COUNT=$(ls -1 *.md 2>/dev/null | wc -l)
    
    if [ $ACTUAL_MD_COUNT -eq $EXPECTED_COUNT ]; then
        echo "   ✅ Root directory optimal ($ACTUAL_MD_COUNT config files)" | tee -a $LOG_FILE
    elif [ $ACTUAL_MD_COUNT -lt $EXPECTED_COUNT ]; then
        echo "   ⚠️  Missing configuration files (expected $EXPECTED_COUNT, found $ACTUAL_MD_COUNT)" | tee -a $LOG_FILE
    else
        echo "   🔴 Root directory cluttered (found $ACTUAL_MD_COUNT files, expected $EXPECTED_COUNT)" | tee -a $LOG_FILE
        echo "   💡 Move non-config files to appropriate project directories" | tee -a $LOG_FILE
        
        # List unexpected files
        ls -1 *.md 2>/dev/null | while read file; do
            if [[ ! " ${CONFIG_FILES[@]} " =~ " ${file} " ]]; then
                echo "      📄 Unexpected: $file" | tee -a $LOG_FILE
            fi
        done
    fi
    
    # Check for other file types that shouldn't be in root
    OTHER_FILES=$(ls -1 *.yaml *.json *.txt 2>/dev/null | wc -l)
    if [ $OTHER_FILES -gt 0 ]; then
        echo "   ⚠️  Non-markdown files in root: $OTHER_FILES files" | tee -a $LOG_FILE
        ls -1 *.yaml *.json *.txt 2>/dev/null | while read file; do
            echo "      📄 Consider relocating: $file" | tee -a $LOG_FILE
        done
    fi
}

# Function: Verify project organization
check_project_organization() {
    echo "" | tee -a $LOG_FILE
    echo "📊 PROJECT ORGANIZATION STATUS:" | tee -a $LOG_FILE
    
    PROJECTS_DIR="$WORKSPACE/projects"
    
    if [ -d "$PROJECTS_DIR" ]; then
        PROJECT_CATEGORIES=$(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
        PROJECT_FILES=$(find "$PROJECTS_DIR" -type f | wc -l)
        
        echo "   📈 Project metrics:" | tee -a $LOG_FILE
        echo "      Project categories: $PROJECT_CATEGORIES" | tee -a $LOG_FILE
        echo "      Total project files: $PROJECT_FILES" | tee -a $LOG_FILE
        
        # Check each project category
        for category in "$PROJECTS_DIR"/*; do
            if [ -d "$category" ]; then
                CATEGORY_NAME=$(basename "$category")
                CATEGORY_FILES=$(find "$category" -type f | wc -l)
                echo "      📁 $CATEGORY_NAME: $CATEGORY_FILES files" | tee -a $LOG_FILE
                
                # Check if category has README
                if [ -f "$category/README.md" ]; then
                    echo "         ✅ Has README documentation" | tee -a $LOG_FILE
                else
                    echo "         💡 Consider adding README.md for navigation" | tee -a $LOG_FILE
                fi
            fi
        done
        
        # Check for projects README
        if [ -f "$PROJECTS_DIR/README.md" ]; then
            echo "   ✅ Projects directory has navigation README" | tee -a $LOG_FILE
        else
            echo "   💡 Consider adding projects/README.md for overview" | tee -a $LOG_FILE
        fi
    else
        echo "   🔴 Projects directory missing - workspace organization may be incomplete" | tee -a $LOG_FILE
    fi
}

# Function: Check archive organization
check_archive_health() {
    echo "" | tee -a $LOG_FILE
    echo "📚 ARCHIVE STATUS:" | tee -a $LOG_FILE
    
    ARCHIVE_DIR="$WORKSPACE/archive"
    
    if [ -d "$ARCHIVE_DIR" ]; then
        ARCHIVED_ITEMS=$(find "$ARCHIVE_DIR" -type f | wc -l)
        echo "   📊 Archived items: $ARCHIVED_ITEMS files" | tee -a $LOG_FILE
        
        # Check archive categories
        for category in "$ARCHIVE_DIR"/*; do
            if [ -d "$category" ]; then
                CATEGORY_NAME=$(basename "$category")
                CATEGORY_FILES=$(find "$category" -type f | wc -l)
                echo "      📁 $CATEGORY_NAME: $CATEGORY_FILES files" | tee -a $LOG_FILE
            fi
        done
        
        # Check for very old files that might need archiving
        OLD_FILES=$(find "$WORKSPACE" -maxdepth 1 -name "*.md" -mtime +60 2>/dev/null | wc -l)
        if [ $OLD_FILES -gt 0 ]; then
            echo "   💡 Found $OLD_FILES files >60 days old that might need archiving" | tee -a $LOG_FILE
        fi
    else
        echo "   💡 No archive directory - consider creating for completed projects" | tee -a $LOG_FILE
    fi
}

# Function: Check documentation organization
check_documentation_status() {
    echo "" | tee -a $LOG_FILE
    echo "📖 DOCUMENTATION ORGANIZATION:" | tee -a $LOG_FILE
    
    DOCS_DIR="$WORKSPACE/documentation"
    
    if [ -d "$DOCS_DIR" ]; then
        DOC_FILES=$(find "$DOCS_DIR" -type f | wc -l)
        echo "   📊 Documentation files: $DOC_FILES" | tee -a $LOG_FILE
        
        if [ $DOC_FILES -eq 0 ]; then
            echo "   💡 Documentation directory empty - consider consolidating reports here" | tee -a $LOG_FILE
        else
            echo "   ✅ Documentation directory active" | tee -a $LOG_FILE
        fi
    else
        echo "   💡 Consider creating documentation/ directory for reports and findings" | tee -a $LOG_FILE
    fi
}

# Function: Detect workspace drift
detect_workspace_drift() {
    echo "" | tee -a $LOG_FILE
    echo "🔍 WORKSPACE DRIFT DETECTION:" | tee -a $LOG_FILE
    
    # Look for files that might be in wrong locations
    
    # Check for project files in root
    PROJECT_KEYWORDS=("bounty" "guide" "setup" "config" "install")
    ROOT_PROJECT_FILES=0
    
    for keyword in "${PROJECT_KEYWORDS[@]}"; do
        MATCHES=$(find "$WORKSPACE" -maxdepth 1 -name "*$keyword*" -type f 2>/dev/null | wc -l)
        ROOT_PROJECT_FILES=$((ROOT_PROJECT_FILES + MATCHES))
    done
    
    if [ $ROOT_PROJECT_FILES -gt 0 ]; then
        echo "   ⚠️  Potential project files in root: $ROOT_PROJECT_FILES files" | tee -a $LOG_FILE
        echo "   💡 Consider moving to appropriate project directories" | tee -a $LOG_FILE
    else
        echo "   ✅ No obvious project files misplaced in root" | tee -a $LOG_FILE
    fi
    
    # Check for scattered configuration files
    CONFIG_IN_PROJECTS=$(find "$WORKSPACE/projects" -name "*.md" -exec grep -l "SOUL\|IDENTITY\|BOOTSTRAP" {} \; 2>/dev/null | wc -l)
    if [ $CONFIG_IN_PROJECTS -gt 0 ]; then
        echo "   ⚠️  Configuration content found in project files" | tee -a $LOG_FILE
    fi
}

# Function: Generate workspace optimization recommendations
generate_workspace_recommendations() {
    echo "" | tee -a $LOG_FILE
    echo "🎯 WORKSPACE OPTIMIZATION RECOMMENDATIONS:" | tee -a $LOG_FILE
    
    # Size-based recommendations
    TOTAL_FILES=$(find "$WORKSPACE" -type f -not -path "*/.git/*" | wc -l)
    WORKSPACE_SIZE=$(du -sh "$WORKSPACE" 2>/dev/null | cut -f1)
    
    echo "   📊 Workspace metrics:" | tee -a $LOG_FILE
    echo "      Total files: $TOTAL_FILES" | tee -a $LOG_FILE
    echo "      Workspace size: $WORKSPACE_SIZE" | tee -a $LOG_FILE
    
    # Maintenance recommendations
    echo "   📋 Regular maintenance tasks:" | tee -a $LOG_FILE
    echo "      • Run this health check weekly" | tee -a $LOG_FILE
    echo "      • Archive completed projects monthly" | tee -a $LOG_FILE
    echo "      • Clean up temporary files regularly" | tee -a $LOG_FILE
    echo "      • Update project READMEs when adding new files" | tee -a $LOG_FILE
    echo "      • Review root directory for misplaced files" | tee -a $LOG_FILE
    
    # Performance recommendations
    if [ $TOTAL_FILES -gt 200 ]; then
        echo "   💡 Consider archiving older projects (>$TOTAL_FILES files total)" | tee -a $LOG_FILE
    fi
}

# Function: Integration check with memory system
check_memory_integration() {
    echo "" | tee -a $LOG_FILE
    echo "🧠 MEMORY-WORKSPACE INTEGRATION:" | tee -a $LOG_FILE
    
    # Check if workspace organization aligns with memory organization
    if [ -f "$WORKSPACE/memory/CROSS-REFERENCE-INDEX.md" ]; then
        echo "   ✅ Cross-reference index available for workspace navigation" | tee -a $LOG_FILE
    else
        echo "   💡 Consider creating memory cross-references for workspace navigation" | tee -a $LOG_FILE
    fi
    
    # Check if project directories have corresponding memory documentation
    PROJECT_DIRS=$(find "$WORKSPACE/projects" -mindepth 1 -maxdepth 1 -type d | wc -l)
    PROJECT_MEMORY_DOCS=$(find "$WORKSPACE/memory/projects" -name "*.md" 2>/dev/null | wc -l)
    
    if [ $PROJECT_DIRS -gt $PROJECT_MEMORY_DOCS ]; then
        echo "   💡 Some projects may need memory documentation ($PROJECT_DIRS dirs, $PROJECT_MEMORY_DOCS memory docs)" | tee -a $LOG_FILE
    else
        echo "   ✅ Project work has corresponding memory documentation" | tee -a $LOG_FILE
    fi
}

# Main execution
echo "Starting workspace health monitoring..." | tee -a $LOG_FILE

check_root_directory
check_project_organization
check_archive_health
check_documentation_status
detect_workspace_drift
check_memory_integration
generate_workspace_recommendations

echo "" | tee -a $LOG_FILE
echo "🏁 WORKSPACE HEALTH CHECK COMPLETE - $(date)" | tee -a $LOG_FILE
echo "📄 Full log available at: $LOG_FILE" | tee -a $LOG_FILE
echo "================================================" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE