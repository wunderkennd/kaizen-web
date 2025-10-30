#!/bin/bash

# Generate Epic Progress Report
# This script creates detailed progress reports for each epic and overall epic health

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Load configuration if available
if [[ -f "$ROOT_DIR/config.sh" ]]; then
    source "$ROOT_DIR/config.sh"
fi

# Default configuration
GITHUB_OWNER="${GITHUB_OWNER:-}"
GITHUB_REPO="${GITHUB_REPO:-}"
PROJECT_NAME="${PROJECT_NAME:-Project Name}"
OUTPUT_FILE="${OUTPUT_FILE:-${ROOT_DIR}/epic-progress-report.md}"
INCLUDE_CHARTS="${INCLUDE_CHARTS:-true}"
TIME_PERIOD="${TIME_PERIOD:-30}"  # Days to look back for activity

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed!"
        log_info "Install from: https://cli.github.com/"
        exit 1
    fi
    
    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub!"
        log_info "Run: gh auth login"
        exit 1
    fi
    
    # Check if repo is specified
    if [[ -z "$GITHUB_OWNER" ]] || [[ -z "$GITHUB_REPO" ]]; then
        log_error "GitHub repository not specified!"
        log_info "Set GITHUB_OWNER and GITHUB_REPO in config.sh or environment variables."
        exit 1
    fi
    
    # Verify repository exists
    if ! gh repo view "$GITHUB_OWNER/$GITHUB_REPO" &> /dev/null; then
        log_error "Repository $GITHUB_OWNER/$GITHUB_REPO not found or not accessible!"
        exit 1
    fi
    
    log_success "Prerequisites checked"
}

# Function to get epic data with detailed metrics
get_epic_detailed_data() {
    local epic="$1"
    
    log_info "Analyzing epic: $epic"
    
    # Get all issues for this epic
    local epic_issues
    epic_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --label "epic:$epic" --state all --json number,title,state,createdAt,closedAt,labels,milestone,assignees --limit 1000 2>/dev/null || echo "[]")
    
    # Basic counts
    local total_count
    total_count=$(echo "$epic_issues" | jq length)
    local open_count
    open_count=$(echo "$epic_issues" | jq '[.[] | select(.state == "open")] | length')
    local closed_count
    closed_count=$(echo "$epic_issues" | jq '[.[] | select(.state == "closed")] | length')
    
    # Progress calculation
    local progress_percentage=0
    if [[ $total_count -gt 0 ]]; then
        progress_percentage=$((closed_count * 100 / total_count))
    fi
    
    # Recent activity (issues closed in last TIME_PERIOD days)
    local cutoff_date
    cutoff_date=$(date -d "${TIME_PERIOD} days ago" -u +%Y-%m-%dT%H:%M:%SZ)
    local recent_completed
    recent_completed=$(echo "$epic_issues" | jq --arg cutoff "$cutoff_date" '[.[] | select(.state == "closed" and .closedAt > $cutoff)] | length')
    
    # Priority distribution
    local p0_count
    p0_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "P0-critical")] | length')
    local p1_count
    p1_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "P1-high")] | length')
    local p2_count
    p2_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "P2-medium")] | length')
    local p3_count
    p3_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "P3-low")] | length')
    
    # Size distribution
    local xs_count
    xs_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "size:XS")] | length')
    local s_count
    s_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "size:S")] | length')
    local m_count
    m_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "size:M")] | length')
    local l_count
    l_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "size:L")] | length')
    local xl_count
    xl_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "size:XL")] | length')
    
    # Milestone distribution
    local milestone_breakdown
    milestone_breakdown=$(echo "$epic_issues" | jq -r 'group_by(.milestone.title // "No Milestone") | .[] | "\(.[0].milestone.title // "No Milestone"):\(length)"' | head -5)
    
    # Team assignment (assignees)
    local assigned_count
    assigned_count=$(echo "$epic_issues" | jq '[.[] | select(.assignees | length > 0)] | length')
    local unassigned_count
    unassigned_count=$((total_count - assigned_count))
    
    # Blocked issues (assuming status:blocked label)
    local blocked_count
    blocked_count=$(echo "$epic_issues" | jq '[.[] | select(.labels[]?.name == "status:blocked")] | length')
    
    # Create comprehensive epic data object
    jq -n \
        --arg epic "$epic" \
        --argjson total "$total_count" \
        --argjson open "$open_count" \
        --argjson closed "$closed_count" \
        --argjson progress "$progress_percentage" \
        --argjson recent "$recent_completed" \
        --argjson p0 "$p0_count" \
        --argjson p1 "$p1_count" \
        --argjson p2 "$p2_count" \
        --argjson p3 "$p3_count" \
        --argjson xs "$xs_count" \
        --argjson s "$s_count" \
        --argjson m "$m_count" \
        --argjson l "$l_count" \
        --argjson xl "$xl_count" \
        --argjson assigned "$assigned_count" \
        --argjson unassigned "$unassigned_count" \
        --argjson blocked "$blocked_count" \
        --arg milestones "$milestone_breakdown" \
        --argjson issues "$epic_issues" \
        '{
            name: $epic,
            total_issues: $total,
            open_issues: $open,
            closed_issues: $closed,
            progress_percentage: $progress,
            recent_completed: $recent,
            priority_distribution: {
                p0: $p0,
                p1: $p1, 
                p2: $p2,
                p3: $p3
            },
            size_distribution: {
                xs: $xs,
                s: $s,
                m: $m,
                l: $l,
                xl: $xl
            },
            assignment: {
                assigned: $assigned,
                unassigned: $unassigned
            },
            blocked_issues: $blocked,
            milestone_breakdown: $milestones,
            issues: $issues
        }'
}

# Function to calculate epic health score
calculate_epic_health() {
    local epic_data="$1"
    
    local progress
    progress=$(echo "$epic_data" | jq -r '.progress_percentage')
    local recent_activity
    recent_activity=$(echo "$epic_data" | jq -r '.recent_completed')
    local blocked
    blocked=$(echo "$epic_data" | jq -r '.blocked_issues')
    local total
    total=$(echo "$epic_data" | jq -r '.total_issues')
    local unassigned
    unassigned=$(echo "$epic_data" | jq -r '.assignment.unassigned')
    
    local health_score=100
    
    # Deduct points for low progress
    if [[ $progress -lt 25 ]]; then
        health_score=$((health_score - 20))
    elif [[ $progress -lt 50 ]]; then
        health_score=$((health_score - 10))
    fi
    
    # Deduct points for lack of recent activity
    if [[ $total -gt 0 && $recent_activity -eq 0 ]]; then
        health_score=$((health_score - 15))
    fi
    
    # Deduct points for blocked issues
    if [[ $blocked -gt 0 && $total -gt 0 ]]; then
        local blocked_percentage=$((blocked * 100 / total))
        if [[ $blocked_percentage -gt 20 ]]; then
            health_score=$((health_score - 25))
        elif [[ $blocked_percentage -gt 10 ]]; then
            health_score=$((health_score - 15))
        fi
    fi
    
    # Deduct points for unassigned work
    if [[ $unassigned -gt 0 && $total -gt 0 ]]; then
        local unassigned_percentage=$((unassigned * 100 / total))
        if [[ $unassigned_percentage -gt 30 ]]; then
            health_score=$((health_score - 20))
        elif [[ $unassigned_percentage -gt 15 ]]; then
            health_score=$((health_score - 10))
        fi
    fi
    
    # Ensure health score doesn't go below 0
    if [[ $health_score -lt 0 ]]; then
        health_score=0
    fi
    
    echo "$health_score"
}

# Function to get health status emoji and text
get_health_status() {
    local health_score="$1"
    
    if [[ $health_score -ge 80 ]]; then
        echo "🟢 Excellent"
    elif [[ $health_score -ge 60 ]]; then
        echo "🟡 Good"
    elif [[ $health_score -ge 40 ]]; then
        echo "🟠 Attention Needed"
    else
        echo "🔴 Critical"
    fi
}

# Function to generate report header
generate_report_header() {
    cat << EOF
# $PROJECT_NAME - Epic Progress Report

**Generated**: $(date)  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)  
**Reporting Period**: Last $TIME_PERIOD days

---

## 📊 Executive Summary

This report provides detailed analysis of epic progress, health metrics, and team performance across all project epics.

EOF
}

# Function to generate epic health dashboard
generate_health_dashboard() {
    local epic_data_array="$1"
    
    cat << EOF
## 🎯 Epic Health Dashboard

| Epic | Progress | Health | Recent Activity | Blocked | Action Required |
|------|----------|--------|-----------------|---------|-----------------|
EOF
    
    echo "$epic_data_array" | jq -r '.[] | @base64' | while read -r epic_b64; do
        local epic_data
        epic_data=$(echo "$epic_b64" | base64 -d)
        
        local name
        name=$(echo "$epic_data" | jq -r '.name')
        local progress
        progress=$(echo "$epic_data" | jq -r '.progress_percentage')
        local recent
        recent=$(echo "$epic_data" | jq -r '.recent_completed')
        local blocked
        blocked=$(echo "$epic_data" | jq -r '.blocked_issues')
        
        local health_score
        health_score=$(calculate_epic_health "$epic_data")
        local health_status
        health_status=$(get_health_status "$health_score")
        
        # Determine action required
        local action="✅ On Track"
        if [[ $health_score -lt 60 ]]; then
            action="⚠️ Review Required"
        fi
        if [[ $blocked -gt 0 ]]; then
            action="🚫 Unblock Issues"
        fi
        if [[ $recent -eq 0 && $progress -lt 100 ]]; then
            action="🔄 Increase Activity"
        fi
        
        printf "| **%s** | %d%% | %s (%d) | %d tasks | %d | %s |\n" \
            "$name" "$progress" "$health_status" "$health_score" "$recent" "$blocked" "$action"
    done
    
    echo ""
}

# Function to generate detailed epic analysis
generate_epic_analysis() {
    local epic_data_array="$1"
    
    cat << EOF
## 🔍 Detailed Epic Analysis

EOF
    
    echo "$epic_data_array" | jq -r '.[] | @base64' | while read -r epic_b64; do
        local epic_data
        epic_data=$(echo "$epic_b64" | base64 -d)
        
        local name
        name=$(echo "$epic_data" | jq -r '.name')
        local total
        total=$(echo "$epic_data" | jq -r '.total_issues')
        local open
        open=$(echo "$epic_data" | jq -r '.open_issues')
        local closed
        closed=$(echo "$epic_data" | jq -r '.closed_issues')
        local progress
        progress=$(echo "$epic_data" | jq -r '.progress_percentage')
        local recent
        recent=$(echo "$epic_data" | jq -r '.recent_completed')
        local blocked
        blocked=$(echo "$epic_data" | jq -r '.blocked_issues')
        
        local health_score
        health_score=$(calculate_epic_health "$epic_data")
        local health_status
        health_status=$(get_health_status "$health_score")
        
        # Get epic description
        local epic_description=""
        case "$name" in
            "foundation") epic_description="Core infrastructure, development environment, and foundational services" ;;
            "data-layer") epic_description="Database design, data models, and data access layer implementation" ;;
            "core-services") epic_description="Backend services, API endpoints, and core business logic" ;;
            "frontend") epic_description="User interface, frontend components, and user experience implementation" ;;
            "testing") epic_description="Comprehensive testing strategy, test automation, and quality assurance" ;;
            "operations") epic_description="Production deployment, monitoring, operations, and maintenance" ;;
            "cicd") epic_description="Continuous integration, deployment automation, and DevOps practices" ;;
            "experimentation") epic_description="A/B testing, analytics, machine learning, and advanced features" ;;
            "documentation") epic_description="User documentation, training materials, and knowledge management" ;;
            *) epic_description="Epic focused on $name functionality" ;;
        esac
        
        cat << EOF
### Epic: $name

**Description**: $epic_description  
**Health Status**: $health_status (Score: $health_score/100)

#### Progress Overview
- **Total Tasks**: $total
- **Completed**: $closed ($progress%)
- **Remaining**: $open
- **Recent Activity**: $recent tasks completed in last $TIME_PERIOD days
- **Blocked**: $blocked tasks

EOF
        
        # Progress bar visualization
        local progress_bar=""
        local filled_blocks=$((progress / 5))
        for ((i=1; i<=20; i++)); do
            if [[ $i -le $filled_blocks ]]; then
                progress_bar+="█"
            else
                progress_bar+="░"
            fi
        done
        echo "**Progress**: [$progress_bar] $progress%"
        echo ""
        
        # Priority breakdown
        local p0
        p0=$(echo "$epic_data" | jq -r '.priority_distribution.p0')
        local p1
        p1=$(echo "$epic_data" | jq -r '.priority_distribution.p1')
        local p2
        p2=$(echo "$epic_data" | jq -r '.priority_distribution.p2')
        local p3
        p3=$(echo "$epic_data" | jq -r '.priority_distribution.p3')
        
        cat << EOF
#### Priority Distribution
- **P0 Critical**: $p0 tasks
- **P1 High**: $p1 tasks  
- **P2 Medium**: $p2 tasks
- **P3 Low**: $p3 tasks

EOF
        
        # Size distribution
        local xs
        xs=$(echo "$epic_data" | jq -r '.size_distribution.xs')
        local s
        s=$(echo "$epic_data" | jq -r '.size_distribution.s')
        local m
        m=$(echo "$epic_data" | jq -r '.size_distribution.m')
        local l
        l=$(echo "$epic_data" | jq -r '.size_distribution.l')
        local xl
        xl=$(echo "$epic_data" | jq -r '.size_distribution.xl')
        
        cat << EOF
#### Size Distribution
- **XS (1-2 pts)**: $xs tasks
- **S (3-5 pts)**: $s tasks
- **M (5-8 pts)**: $m tasks
- **L (8-13 pts)**: $l tasks
- **XL (13+ pts)**: $xl tasks

EOF
        
        # Team assignment
        local assigned
        assigned=$(echo "$epic_data" | jq -r '.assignment.assigned')
        local unassigned
        unassigned=$(echo "$epic_data" | jq -r '.assignment.unassigned')
        
        cat << EOF
#### Team Assignment
- **Assigned**: $assigned tasks
- **Unassigned**: $unassigned tasks

EOF
        
        # Recent completed tasks
        local recent_completed_tasks
        recent_completed_tasks=$(echo "$epic_data" | jq -r --arg cutoff "$(date -d "${TIME_PERIOD} days ago" -u +%Y-%m-%dT%H:%M:%SZ)" '.issues[] | select(.state == "closed" and .closedAt > $cutoff) | .title' | head -5)
        
        if [[ -n "$recent_completed_tasks" ]]; then
            echo "#### Recently Completed (Last $TIME_PERIOD days)"
            echo "$recent_completed_tasks" | sed 's/^/- /'
            echo ""
        fi
        
        # Current high-priority open tasks
        local high_priority_open
        high_priority_open=$(echo "$epic_data" | jq -r '.issues[] | select(.state == "open" and (.labels[]?.name == "P0-critical" or .labels[]?.name == "P1-high")) | .title' | head -5)
        
        if [[ -n "$high_priority_open" ]]; then
            echo "#### High Priority Open Tasks"
            echo "$high_priority_open" | sed 's/^/- /'
            echo ""
        fi
        
        # Blocked issues
        if [[ $blocked -gt 0 ]]; then
            local blocked_tasks
            blocked_tasks=$(echo "$epic_data" | jq -r '.issues[] | select(.labels[]?.name == "status:blocked") | .title' | head -3)
            
            echo "#### 🚫 Blocked Issues"
            echo "$blocked_tasks" | sed 's/^/- /'
            echo ""
        fi
        
        # Health analysis and recommendations
        echo "#### 💡 Recommendations"
        
        if [[ $health_score -ge 80 ]]; then
            echo "- ✅ Epic is performing well, maintain current pace"
        elif [[ $health_score -ge 60 ]]; then
            echo "- 🔄 Good progress, consider accelerating completion"
        else
            echo "- ⚠️ Epic needs attention:"
            
            if [[ $progress -lt 25 ]]; then
                echo "  - Low completion rate - review scope and resources"
            fi
            
            if [[ $recent -eq 0 ]]; then
                echo "  - No recent activity - ensure tasks are prioritized"
            fi
            
            if [[ $blocked -gt 0 ]]; then
                echo "  - $blocked blocked tasks - immediate unblocking required"
            fi
            
            if [[ $unassigned -gt 0 ]]; then
                local unassigned_pct=$((unassigned * 100 / total))
                if [[ $unassigned_pct -gt 15 ]]; then
                    echo "  - $unassigned_pct% unassigned tasks - assign team members"
                fi
            fi
        fi
        
        echo ""
        echo "---"
        echo ""
    done
}

# Function to generate trends analysis
generate_trends_analysis() {
    local epic_data_array="$1"
    
    cat << EOF
## 📈 Trends & Insights

### Overall Epic Performance

EOF
    
    # Calculate overall metrics
    local total_epics
    total_epics=$(echo "$epic_data_array" | jq length)
    local healthy_epics
    healthy_epics=$(echo "$epic_data_array" | jq '[.[] | select((.progress_percentage >= 50) or (.recent_completed > 0))] | length')
    local critical_epics
    critical_epics=0
    
    # Count critical epics
    echo "$epic_data_array" | jq -r '.[] | @base64' | while read -r epic_b64; do
        local epic_data
        epic_data=$(echo "$epic_b64" | base64 -d)
        local health_score
        health_score=$(calculate_epic_health "$epic_data")
        if [[ $health_score -lt 40 ]]; then
            critical_epics=$((critical_epics + 1))
        fi
    done
    
    cat << EOF
- **Total Epics**: $total_epics
- **Healthy Progress**: $healthy_epics epics
- **Need Attention**: $((total_epics - healthy_epics)) epics

### Top Performing Epics

EOF
    
    # Show best performing epics
    echo "$epic_data_array" | jq -r 'sort_by(.progress_percentage) | reverse | .[] | select(.progress_percentage > 0) | "- **\(.name)**: \(.progress_percentage)% complete, \(.recent_completed) recent tasks"' | head -3
    
    cat << EOF

### Epics Needing Attention

EOF
    
    # Show epics needing attention
    echo "$epic_data_array" | jq -r '.[] | select(.progress_percentage < 50 and .total_issues > 0) | "- **\(.name)**: \(.progress_percentage)% complete, \(.blocked_issues) blocked, \(.assignment.unassigned) unassigned"'
    
    cat << EOF

### Key Insights

EOF
    
    # Generate insights based on data
    local total_tasks
    total_tasks=$(echo "$epic_data_array" | jq '[.[].total_issues] | add')
    local total_completed
    total_completed=$(echo "$epic_data_array" | jq '[.[].closed_issues] | add')
    local total_blocked
    total_blocked=$(echo "$epic_data_array" | jq '[.[].blocked_issues] | add')
    local total_recent
    total_recent=$(echo "$epic_data_array" | jq '[.[].recent_completed] | add')
    
    local overall_progress=0
    if [[ $total_tasks -gt 0 ]]; then
        overall_progress=$((total_completed * 100 / total_tasks))
    fi
    
    echo "- **Overall Project Progress**: $overall_progress% ($total_completed/$total_tasks tasks)"
    echo "- **Recent Activity**: $total_recent tasks completed in last $TIME_PERIOD days"
    
    if [[ $total_blocked -gt 0 ]]; then
        echo "- **⚠️ Blockers**: $total_blocked total blocked tasks across all epics"
    fi
    
    local velocity=0
    if [[ $TIME_PERIOD -gt 0 ]]; then
        velocity=$((total_recent * 7 / TIME_PERIOD))  # Tasks per week
    fi
    echo "- **Team Velocity**: ~$velocity tasks per week"
    
    echo ""
}

# Function to generate action items
generate_action_items() {
    local epic_data_array="$1"
    
    cat << EOF
## 🚀 Action Items & Next Steps

### Immediate Actions Required

EOF
    
    # Generate action items based on epic health
    echo "$epic_data_array" | jq -r '.[] | @base64' | while read -r epic_b64; do
        local epic_data
        epic_data=$(echo "$epic_b64" | base64 -d)
        
        local name
        name=$(echo "$epic_data" | jq -r '.name')
        local blocked
        blocked=$(echo "$epic_data" | jq -r '.blocked_issues')
        local unassigned
        unassigned=$(echo "$epic_data" | jq -r '.assignment.unassigned')
        local recent
        recent=$(echo "$epic_data" | jq -r '.recent_completed')
        local progress
        progress=$(echo "$epic_data" | jq -r '.progress_percentage')
        local total
        total=$(echo "$epic_data" | jq -r '.total_issues')
        
        local health_score
        health_score=$(calculate_epic_health "$epic_data")
        
        if [[ $health_score -lt 60 ]] || [[ $blocked -gt 0 ]] || [[ $unassigned -gt 2 ]]; then
            echo "#### Epic: $name"
            
            if [[ $blocked -gt 0 ]]; then
                echo "- **🚫 URGENT**: Unblock $blocked tasks immediately"
            fi
            
            if [[ $unassigned -gt 2 ]]; then
                echo "- **👥 Assign**: $unassigned tasks need team member assignment"
            fi
            
            if [[ $recent -eq 0 && $progress -lt 100 && $total -gt 0 ]]; then
                echo "- **🔄 Activate**: No recent progress, review priorities"
            fi
            
            if [[ $progress -lt 25 && $total -gt 0 ]]; then
                echo "- **📊 Review**: Low progress rate, assess scope and resources"
            fi
            
            echo ""
        fi
    done
    
    cat << EOF
### Weekly Recommended Actions

1. **Epic Review Meeting**: Schedule weekly epic health review
2. **Blocker Resolution**: Daily standup focus on removing blockers
3. **Resource Allocation**: Ensure critical epics have adequate staffing
4. **Progress Tracking**: Update task status and epic labels regularly
5. **Stakeholder Updates**: Share epic progress with stakeholders

### Success Metrics to Track

- **Epic Health Score**: Target >70 for all active epics
- **Completion Velocity**: Maintain consistent weekly task completion
- **Blocker Resolution**: Resolve blocked tasks within 48 hours
- **Team Utilization**: Keep unassigned work below 20%

EOF
}

# Function to generate footer
generate_report_footer() {
    cat << EOF
---

## 📊 Report Information

**Generated By**: Spec-Kit Epic Progress Analyzer  
**Generated On**: $(date)  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)  
**Epic Labels**: [View All Epic Issues](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/issues?q=label%3Aepic*)

### How to Use This Report

1. **Focus on Health Dashboard**: Prioritize epics with low health scores
2. **Address Blockers**: Unblock issues immediately to maintain momentum
3. **Balance Workload**: Assign unassigned tasks to available team members
4. **Track Trends**: Monitor progress over time and adjust resources
5. **Regular Updates**: Regenerate weekly for accurate tracking

### Automation

This report is automatically generated from your GitHub issues and labels. To update:

\`\`\`bash
./05-reporting/epic-progress.sh
\`\`\`

For epic assignment automation:
\`\`\`bash
./04-organization/assign-to-epics.sh
\`\`\`

---
*Epic progress report generated automatically by spec-kit tools*
EOF
}

# Main function to generate epic progress report
generate_epic_progress_report() {
    log_info "Generating epic progress report..."
    
    local epics=("foundation" "data-layer" "core-services" "frontend" "testing" "operations" "cicd" "experimentation" "documentation")
    local epic_data_array="[]"
    
    # Collect data for all epics
    for epic in "${epics[@]}"; do
        local epic_data
        epic_data=$(get_epic_detailed_data "$epic")
        epic_data_array=$(echo "$epic_data_array" | jq ". + [$epic_data]")
    done
    
    log_info "Generating report sections..."
    
    # Generate complete report
    {
        generate_report_header
        generate_health_dashboard "$epic_data_array"
        generate_epic_analysis "$epic_data_array"
        generate_trends_analysis "$epic_data_array"
        generate_action_items "$epic_data_array"
        generate_report_footer
    } > "$OUTPUT_FILE"
    
    log_success "Epic progress report generated: $OUTPUT_FILE"
}

# Function to generate CSV export
generate_csv_export() {
    log_info "Generating CSV export..."
    
    local csv_file="${ROOT_DIR}/epic-progress-data.csv"
    local epics=("foundation" "data-layer" "core-services" "frontend" "testing" "operations" "cicd" "experimentation" "documentation")
    
    # CSV header
    echo "epic,total_tasks,completed_tasks,open_tasks,progress_percentage,recent_completed,blocked_tasks,unassigned_tasks,health_score" > "$csv_file"
    
    # Data rows
    for epic in "${epics[@]}"; do
        local epic_data
        epic_data=$(get_epic_detailed_data "$epic")
        
        local total
        total=$(echo "$epic_data" | jq -r '.total_issues')
        local closed
        closed=$(echo "$epic_data" | jq -r '.closed_issues')
        local open
        open=$(echo "$epic_data" | jq -r '.open_issues')
        local progress
        progress=$(echo "$epic_data" | jq -r '.progress_percentage')
        local recent
        recent=$(echo "$epic_data" | jq -r '.recent_completed')
        local blocked
        blocked=$(echo "$epic_data" | jq -r '.blocked_issues')
        local unassigned
        unassigned=$(echo "$epic_data" | jq -r '.assignment.unassigned')
        local health_score
        health_score=$(calculate_epic_health "$epic_data")
        
        echo "$epic,$total,$closed,$open,$progress,$recent,$blocked,$unassigned,$health_score" >> "$csv_file"
    done
    
    log_success "CSV export generated: $csv_file"
}

# Main function
main() {
    log_info "Starting epic progress analysis..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Project: $PROJECT_NAME"
    log_info "Output file: $OUTPUT_FILE"
    log_info "Time period: $TIME_PERIOD days"
    echo ""
    
    # Generate report
    generate_epic_progress_report
    
    # Generate CSV export
    generate_csv_export
    
    echo ""
    log_success "Epic progress analysis completed!"
    log_info "Files generated:"
    echo "  - Progress report: $OUTPUT_FILE"
    echo "  - CSV data: ${ROOT_DIR}/epic-progress-data.csv"
    echo ""
    log_info "Next steps:"
    echo "  1. Review epic health scores and take action on critical issues"
    echo "  2. Address blocked tasks immediately"
    echo "  3. Assign unassigned tasks to team members"
    echo "  4. Share report with team leads and stakeholders"
    echo "  5. Schedule weekly epic review meetings"
}

# Help function
show_help() {
    echo "Generate Epic Progress Report"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -o, --output FILE       Specify output file (default: ../epic-progress-report.md)"
    echo "  -p, --project NAME      Specify project name"
    echo "  -t, --time-period DAYS  Days to look back for activity (default: 30)"
    echo "  --csv-only              Generate only CSV export"
    echo "  --repo OWNER/REPO       Specify GitHub repository"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_OWNER            GitHub repository owner"
    echo "  GITHUB_REPO             GitHub repository name"
    echo "  PROJECT_NAME            Project name for report"
    echo "  TIME_PERIOD             Days to analyze for recent activity"
    echo ""
    echo "This script generates comprehensive epic analysis including:"
    echo "  • Epic health dashboard with scores"
    echo "  • Detailed progress breakdown per epic"
    echo "  • Priority and size distribution analysis"
    echo "  • Team assignment tracking"
    echo "  • Blocked issue identification"
    echo "  • Trends and insights"
    echo "  • Action items and recommendations"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Generate standard report"
    echo "  $0 --time-period 7                   # Analyze last 7 days"
    echo "  $0 --project \"My Project\"             # Set custom project name"
    echo "  $0 --csv-only                        # Generate only CSV data"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -t|--time-period)
            TIME_PERIOD="$2"
            shift 2
            ;;
        --csv-only)
            check_prerequisites
            generate_csv_export
            exit 0
            ;;
        --repo)
            if [[ "$2" =~ ^([^/]+)/([^/]+)$ ]]; then
                GITHUB_OWNER="${BASH_REMATCH[1]}"
                GITHUB_REPO="${BASH_REMATCH[2]}"
                shift 2
            else
                log_error "Invalid repository format. Use: owner/repo"
                exit 1
            fi
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main "$@"