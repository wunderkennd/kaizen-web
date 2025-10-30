#!/bin/bash

# Generate Weekly Status Report
# This script creates a comprehensive weekly status report for the project

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
OUTPUT_FILE="${OUTPUT_FILE:-${ROOT_DIR}/weekly-status-$(date +%Y-%m-%d).md}"
WEEK_START="${WEEK_START:-7}"  # Days ago to start the week
INCLUDE_CHARTS="${INCLUDE_CHARTS:-false}"

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

# Function to calculate date ranges
calculate_date_ranges() {
    # Calculate week start and end dates
    WEEK_END_DATE=$(date +%Y-%m-%d)
    WEEK_START_DATE=$(date -d "$WEEK_START days ago" +%Y-%m-%d)
    WEEK_END_ISO=$(date -u +%Y-%m-%dT23:59:59Z)
    WEEK_START_ISO=$(date -d "$WEEK_START days ago" -u +%Y-%m-%dT00:00:00Z)
    
    # Previous week for comparison
    PREV_WEEK_START=$(date -d "$((WEEK_START + 7)) days ago" +%Y-%m-%d)
    PREV_WEEK_END=$(date -d "$((WEEK_START + 1)) days ago" +%Y-%m-%d)
    PREV_WEEK_START_ISO=$(date -d "$((WEEK_START + 7)) days ago" -u +%Y-%m-%dT00:00:00Z)
    PREV_WEEK_END_ISO=$(date -d "$((WEEK_START + 1)) days ago" -u +%Y-%m-%dT23:59:59Z)
}

# Function to get weekly activity data
get_weekly_activity() {
    log_info "Analyzing weekly activity..."
    
    # Issues created this week
    local issues_created
    issues_created=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "created:${WEEK_START_DATE}..${WEEK_END_DATE}" --json number,title,labels --limit 1000)
    
    # Issues closed this week  
    local issues_closed
    issues_closed=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "closed:${WEEK_START_DATE}..${WEEK_END_DATE}" --state closed --json number,title,labels --limit 1000)
    
    # Pull requests merged this week
    local prs_merged
    prs_merged=$(gh pr list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "merged:${WEEK_START_DATE}..${WEEK_END_DATE}" --state merged --json number,title,author --limit 1000)
    
    # Commits this week
    local commits_count
    commits_count=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/commits --paginate -f since="$WEEK_START_ISO" -f until="$WEEK_END_ISO" | jq length)
    
    # Create activity summary
    jq -n \
        --argjson issues_created "$issues_created" \
        --argjson issues_closed "$issues_closed" \
        --argjson prs_merged "$prs_merged" \
        --argjson commits_count "$commits_count" \
        '{
            issues_created: $issues_created,
            issues_closed: $issues_closed,
            prs_merged: $prs_merged,
            commits_count: $commits_count,
            issues_created_count: ($issues_created | length),
            issues_closed_count: ($issues_closed | length),
            prs_merged_count: ($prs_merged | length)
        }'
}

# Function to get previous week activity for comparison
get_previous_week_activity() {
    log_info "Analyzing previous week for comparison..."
    
    # Issues closed previous week
    local prev_issues_closed
    prev_issues_closed=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "closed:${PREV_WEEK_START}..${PREV_WEEK_END}" --state closed --json number --limit 1000)
    
    # Pull requests merged previous week
    local prev_prs_merged
    prev_prs_merged=$(gh pr list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "merged:${PREV_WEEK_START}..${PREV_WEEK_END}" --state merged --json number --limit 1000)
    
    # Commits previous week
    local prev_commits_count
    prev_commits_count=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/commits --paginate -f since="$PREV_WEEK_START_ISO" -f until="$PREV_WEEK_END_ISO" | jq length)
    
    jq -n \
        --argjson prev_issues_closed "$prev_issues_closed" \
        --argjson prev_prs_merged "$prev_prs_merged" \
        --argjson prev_commits_count "$prev_commits_count" \
        '{
            prev_issues_closed_count: ($prev_issues_closed | length),
            prev_prs_merged_count: ($prev_prs_merged | length),
            prev_commits_count: $prev_commits_count
        }'
}

# Function to get milestone progress
get_milestone_progress() {
    log_info "Analyzing milestone progress..."
    
    # Get all milestones
    local milestones
    milestones=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --paginate)
    
    # Calculate progress for each milestone
    echo "$milestones" | jq -r '.[] | @base64' | while read -r milestone_b64; do
        local milestone
        milestone=$(echo "$milestone_b64" | base64 -d)
        
        local title
        title=$(echo "$milestone" | jq -r '.title')
        local state
        state=$(echo "$milestone" | jq -r '.state')
        local open_issues
        open_issues=$(echo "$milestone" | jq -r '.open_issues')
        local closed_issues
        closed_issues=$(echo "$milestone" | jq -r '.closed_issues')
        local due_date
        due_date=$(echo "$milestone" | jq -r '.due_on // "No due date"')
        
        local total_issues=$((open_issues + closed_issues))
        local progress_percentage=0
        if [[ $total_issues -gt 0 ]]; then
            progress_percentage=$((closed_issues * 100 / total_issues))
        fi
        
        # Check if milestone has activity this week
        local recent_activity=0
        if [[ $total_issues -gt 0 ]]; then
            local milestone_number
            milestone_number=$(echo "$milestone" | jq -r '.number')
            local recent_closed
            recent_closed=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "closed:${WEEK_START_DATE}..${WEEK_END_DATE} milestone:\"$title\"" --state closed --json number --limit 1000)
            recent_activity=$(echo "$recent_closed" | jq length)
        fi
        
        jq -n \
            --arg title "$title" \
            --arg state "$state" \
            --argjson open "$open_issues" \
            --argjson closed "$closed_issues" \
            --argjson total "$total_issues" \
            --argjson progress "$progress_percentage" \
            --arg due_date "$due_date" \
            --argjson recent_activity "$recent_activity" \
            '{
                title: $title,
                state: $state,
                open_issues: $open,
                closed_issues: $closed,
                total_issues: $total,
                progress_percentage: $progress,
                due_date: $due_date,
                recent_activity: $recent_activity
            }'
    done | jq -s '.'
}

# Function to get team performance data
get_team_performance() {
    log_info "Analyzing team performance..."
    
    # Get issues closed by assignee this week
    local assignee_performance
    assignee_performance=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "closed:${WEEK_START_DATE}..${WEEK_END_DATE}" --state closed --json assignees,labels --limit 1000)
    
    # Get PR authors this week
    local pr_authors
    pr_authors=$(gh pr list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "merged:${WEEK_START_DATE}..${WEEK_END_DATE}" --state merged --json author --limit 1000)
    
    # Process assignee data
    local assignee_stats
    assignee_stats=$(echo "$assignee_performance" | jq -r '
        [.[] | .assignees[]? | .login] | 
        group_by(.) | 
        map({assignee: .[0], count: length}) | 
        sort_by(.count) | reverse
    ')
    
    # Process PR author data
    local author_stats
    author_stats=$(echo "$pr_authors" | jq -r '
        [.[] | .author.login] | 
        group_by(.) | 
        map({author: .[0], count: length}) | 
        sort_by(.count) | reverse
    ')
    
    jq -n \
        --argjson assignee_stats "$assignee_stats" \
        --argjson author_stats "$author_stats" \
        '{
            assignee_performance: $assignee_stats,
            pr_authors: $author_stats
        }'
}

# Function to identify blockers and risks
get_blockers_and_risks() {
    log_info "Identifying blockers and risks..."
    
    # Get blocked issues
    local blocked_issues
    blocked_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --label "status:blocked" --state open --json number,title,assignees,labels --limit 100)
    
    # Get overdue issues (open issues past milestone due date)
    local overdue_issues="[]"  # Simplified for now
    
    # Get high priority open issues
    local high_priority_open
    high_priority_open=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --label "P0-critical,P1-high" --state open --json number,title,assignees,labels --limit 50)
    
    # Get stale issues (no activity for 2+ weeks)
    local stale_cutoff
    stale_cutoff=$(date -d "14 days ago" +%Y-%m-%d)
    local stale_issues
    stale_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "updated:<${stale_cutoff} is:open" --json number,title,assignees --limit 20)
    
    jq -n \
        --argjson blocked "$blocked_issues" \
        --argjson overdue "$overdue_issues" \
        --argjson high_priority "$high_priority_open" \
        --argjson stale "$stale_issues" \
        '{
            blocked_issues: $blocked,
            overdue_issues: $overdue,
            high_priority_open: $high_priority,
            stale_issues: $stale,
            blocked_count: ($blocked | length),
            overdue_count: ($overdue | length),
            high_priority_count: ($high_priority | length),
            stale_count: ($stale | length)
        }'
}

# Function to generate report header
generate_report_header() {
    cat << EOF
# $PROJECT_NAME - Weekly Status Report

**Week of**: $WEEK_START_DATE to $WEEK_END_DATE  
**Generated**: $(date)  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)

---

## 📊 Executive Summary

EOF
}

# Function to generate activity summary
generate_activity_summary() {
    local activity_data="$1"
    local prev_activity_data="$2"
    
    local issues_created_count
    issues_created_count=$(echo "$activity_data" | jq -r '.issues_created_count')
    local issues_closed_count  
    issues_closed_count=$(echo "$activity_data" | jq -r '.issues_closed_count')
    local prs_merged_count
    prs_merged_count=$(echo "$activity_data" | jq -r '.prs_merged_count')
    local commits_count
    commits_count=$(echo "$activity_data" | jq -r '.commits_count')
    
    local prev_issues_closed
    prev_issues_closed=$(echo "$prev_activity_data" | jq -r '.prev_issues_closed_count')
    local prev_prs_merged
    prev_prs_merged=$(echo "$prev_activity_data" | jq -r '.prev_prs_merged_count')
    local prev_commits
    prev_commits=$(echo "$prev_activity_data" | jq -r '.prev_commits_count')
    
    # Calculate week-over-week changes
    local issues_change=""
    local prs_change=""
    local commits_change=""
    
    if [[ $prev_issues_closed -gt 0 ]]; then
        local issues_pct_change=$(( (issues_closed_count - prev_issues_closed) * 100 / prev_issues_closed ))
        if [[ $issues_pct_change -gt 0 ]]; then
            issues_change=" (↗️ +$issues_pct_change%)"
        elif [[ $issues_pct_change -lt 0 ]]; then
            issues_change=" (↘️ $issues_pct_change%)"
        else
            issues_change=" (→ 0%)"
        fi
    fi
    
    if [[ $prev_prs_merged -gt 0 ]]; then
        local prs_pct_change=$(( (prs_merged_count - prev_prs_merged) * 100 / prev_prs_merged ))
        if [[ $prs_pct_change -gt 0 ]]; then
            prs_change=" (↗️ +$prs_pct_change%)"
        elif [[ $prs_pct_change -lt 0 ]]; then
            prs_change=" (↘️ $prs_pct_change%)"
        else
            prs_change=" (→ 0%)"
        fi
    fi
    
    if [[ $prev_commits -gt 0 ]]; then
        local commits_pct_change=$(( (commits_count - prev_commits) * 100 / prev_commits ))
        if [[ $commits_pct_change -gt 0 ]]; then
            commits_change=" (↗️ +$commits_pct_change%)"
        elif [[ $commits_pct_change -lt 0 ]]; then
            commits_change=" (↘️ $commits_pct_change%)"
        else
            commits_change=" (→ 0%)"
        fi
    fi
    
    cat << EOF
### Key Metrics

| Metric | This Week | vs Last Week |
|--------|-----------|--------------|
| **Issues Created** | $issues_created_count | - |
| **Issues Completed** | $issues_closed_count | $prev_issues_closed$issues_change |
| **PRs Merged** | $prs_merged_count | $prev_prs_merged$prs_change |
| **Commits** | $commits_count | $prev_commits$commits_change |

### Weekly Highlights

EOF
    
    # Generate highlights based on data
    if [[ $issues_closed_count -gt $prev_issues_closed ]]; then
        echo "✅ **Increased Productivity**: Completed $issues_closed_count issues, up from $prev_issues_closed last week"
    elif [[ $issues_closed_count -eq $prev_issues_closed && $issues_closed_count -gt 0 ]]; then
        echo "📊 **Steady Progress**: Maintained consistent completion rate of $issues_closed_count issues"
    elif [[ $issues_closed_count -lt $prev_issues_closed ]]; then
        echo "⚠️ **Decreased Activity**: Completed $issues_closed_count issues, down from $prev_issues_closed last week"
    fi
    
    if [[ $prs_merged_count -gt 5 ]]; then
        echo "🚀 **High Development Activity**: $prs_merged_count pull requests merged this week"
    fi
    
    if [[ $commits_count -gt 50 ]]; then
        echo "💻 **Active Development**: $commits_count commits pushed this week"
    fi
    
    echo ""
}

# Function to generate completed work section
generate_completed_work() {
    local activity_data="$1"
    
    cat << EOF
## ✅ Completed This Week

EOF
    
    local issues_closed
    issues_closed=$(echo "$activity_data" | jq -r '.issues_closed')
    local issues_count
    issues_count=$(echo "$activity_data" | jq -r '.issues_closed_count')
    
    if [[ $issues_count -gt 0 ]]; then
        echo "### Issues Completed ($issues_count)"
        echo ""
        echo "$issues_closed" | jq -r '.[] | "- [#\(.number)](\("https://github.com/" + env.GITHUB_OWNER + "/" + env.GITHUB_REPO + "/issues/" + (.number | tostring))) \(.title)"' | head -15
        
        if [[ $issues_count -gt 15 ]]; then
            echo "- ... and $((issues_count - 15)) more issues"
        fi
        echo ""
        
        # Epic breakdown of completed work
        echo "### Completed by Epic"
        echo ""
        local epic_breakdown
        epic_breakdown=$(echo "$issues_closed" | jq -r '
            [.[] | .labels[]? | select(.name | startswith("epic:")) | .name] | 
            group_by(.) | 
            map({epic: .[0], count: length}) | 
            sort_by(.count) | reverse
        ')
        
        if [[ $(echo "$epic_breakdown" | jq length) -gt 0 ]]; then
            echo "$epic_breakdown" | jq -r '.[] | "- **\(.epic | sub("epic:"; ""))**: \(.count) tasks"'
        else
            echo "- No epic labels found on completed issues"
        fi
        echo ""
    else
        echo "No issues were completed this week."
        echo ""
    fi
    
    # Pull requests merged
    local prs_merged
    prs_merged=$(echo "$activity_data" | jq -r '.prs_merged')
    local prs_count
    prs_count=$(echo "$activity_data" | jq -r '.prs_merged_count')
    
    if [[ $prs_count -gt 0 ]]; then
        cat << EOF
### Pull Requests Merged ($prs_count)

EOF
        echo "$prs_merged" | jq -r '.[] | "- [#\(.number)](\("https://github.com/" + env.GITHUB_OWNER + "/" + env.GITHUB_REPO + "/pull/" + (.number | tostring))) \(.title) by @\(.author.login)"' | head -10
        
        if [[ $prs_count -gt 10 ]]; then
            echo "- ... and $((prs_count - 10)) more pull requests"
        fi
        echo ""
    fi
}

# Function to generate milestone progress section
generate_milestone_progress() {
    local milestone_data="$1"
    
    cat << EOF
## 🎯 Milestone Progress

EOF
    
    local milestone_count
    milestone_count=$(echo "$milestone_data" | jq length)
    
    if [[ $milestone_count -gt 0 ]]; then
        echo "| Milestone | Progress | This Week | Status |"
        echo "|-----------|----------|-----------|---------|"
        
        echo "$milestone_data" | jq -r '.[] | @base64' | while read -r milestone_b64; do
            local milestone
            milestone=$(echo "$milestone_b64" | base64 -d)
            
            local title
            title=$(echo "$milestone" | jq -r '.title')
            local progress
            progress=$(echo "$milestone" | jq -r '.progress_percentage')
            local recent_activity
            recent_activity=$(echo "$milestone" | jq -r '.recent_activity')
            local state
            state=$(echo "$milestone" | jq -r '.state')
            local due_date
            due_date=$(echo "$milestone" | jq -r '.due_date')
            
            # Status icon
            local status_icon="🔄"
            local status_text="In Progress"
            
            if [[ "$state" == "closed" ]]; then
                status_icon="✅"
                status_text="Complete"
            elif [[ $progress -eq 0 ]]; then
                status_icon="🔜"
                status_text="Not Started"
            elif [[ $progress -ge 90 ]]; then
                status_icon="🎯"
                status_text="Nearly Done"
            fi
            
            # Check if overdue
            if [[ "$due_date" != "No due date" && "$state" != "closed" ]]; then
                local due_date_formatted
                due_date_formatted=$(date -d "$due_date" +%Y-%m-%d 2>/dev/null || echo "Invalid")
                local today
                today=$(date +%Y-%m-%d)
                if [[ "$due_date_formatted" < "$today" ]]; then
                    status_icon="⚠️"
                    status_text="Overdue"
                fi
            fi
            
            # Recent activity indicator
            local activity_indicator=""
            if [[ $recent_activity -gt 0 ]]; then
                activity_indicator="+$recent_activity tasks"
            else
                activity_indicator="No activity"
            fi
            
            printf "| **%s** | %d%% | %s | %s %s |\n" "$title" "$progress" "$activity_indicator" "$status_icon" "$status_text"
        done
        echo ""
        
        # Milestone details
        echo "### Milestone Details"
        echo ""
        
        echo "$milestone_data" | jq -r '.[] | @base64' | while read -r milestone_b64; do
            local milestone
            milestone=$(echo "$milestone_b64" | base64 -d)
            
            local title
            title=$(echo "$milestone" | jq -r '.title')
            local open_issues
            open_issues=$(echo "$milestone" | jq -r '.open_issues')
            local closed_issues
            closed_issues=$(echo "$milestone" | jq -r '.closed_issues')
            local due_date
            due_date=$(echo "$milestone" | jq -r '.due_date')
            local recent_activity
            recent_activity=$(echo "$milestone" | jq -r '.recent_activity')
            
            local formatted_due_date="TBD"
            if [[ "$due_date" != "No due date" ]]; then
                formatted_due_date=$(date -d "$due_date" "+%B %d, %Y" 2>/dev/null || echo "$due_date")
            fi
            
            cat << EOF
#### $title
- **Due Date**: $formatted_due_date
- **Remaining**: $open_issues tasks
- **Completed**: $closed_issues tasks  
- **This Week**: $recent_activity tasks completed

EOF
        done
    else
        echo "No milestones found."
        echo ""
    fi
}

# Function to generate team performance section
generate_team_performance() {
    local team_data="$1"
    
    cat << EOF
## 👥 Team Performance

EOF
    
    local assignee_stats
    assignee_stats=$(echo "$team_data" | jq -r '.assignee_performance')
    local author_stats  
    author_stats=$(echo "$team_data" | jq -r '.pr_authors')
    
    # Top performers by issues completed
    local assignee_count
    assignee_count=$(echo "$assignee_stats" | jq length)
    
    if [[ $assignee_count -gt 0 ]]; then
        cat << EOF
### Issues Completed by Team Member

EOF
        echo "$assignee_stats" | jq -r '.[] | "- **@\(.assignee)**: \(.count) issues"' | head -10
        echo ""
    fi
    
    # Top contributors by PRs merged
    local author_count
    author_count=$(echo "$author_stats" | jq length)
    
    if [[ $author_count -gt 0 ]]; then
        cat << EOF
### Pull Requests by Author

EOF
        echo "$author_stats" | jq -r '.[] | "- **@\(.author)**: \(.count) PRs"' | head -10
        echo ""
    fi
    
    # Team insights
    cat << EOF
### Team Insights

EOF
    
    if [[ $assignee_count -eq 0 ]]; then
        echo "⚠️ **No Assigned Completions**: Consider assigning tasks to track individual performance"
    elif [[ $assignee_count -eq 1 ]]; then
        echo "📊 **Single Contributor**: All completed work assigned to one team member"
    else
        echo "👥 **Distributed Work**: $assignee_count team members completed work this week"
    fi
    
    if [[ $author_count -gt 0 ]]; then
        local top_author
        top_author=$(echo "$author_stats" | jq -r '.[0].author')
        local top_count
        top_count=$(echo "$author_stats" | jq -r '.[0].count')
        echo "🏆 **Top Contributor**: @$top_author with $top_count merged PRs"
    fi
    
    echo ""
}

# Function to generate blockers and risks section
generate_blockers_and_risks() {
    local blockers_data="$1"
    
    cat << EOF
## 🚫 Blockers & Risks

EOF
    
    local blocked_count
    blocked_count=$(echo "$blockers_data" | jq -r '.blocked_count')
    local high_priority_count
    high_priority_count=$(echo "$blockers_data" | jq -r '.high_priority_count')
    local stale_count
    stale_count=$(echo "$blockers_data" | jq -r '.stale_count')
    
    # Blocked issues
    if [[ $blocked_count -gt 0 ]]; then
        cat << EOF
### 🚫 Blocked Issues ($blocked_count)

EOF
        local blocked_issues
        blocked_issues=$(echo "$blockers_data" | jq -r '.blocked_issues')
        echo "$blocked_issues" | jq -r '.[] | "- [#\(.number)](\("https://github.com/" + env.GITHUB_OWNER + "/" + env.GITHUB_REPO + "/issues/" + (.number | tostring))) \(.title)"' | head -10
        echo ""
    fi
    
    # High priority open issues
    if [[ $high_priority_count -gt 0 ]]; then
        cat << EOF
### ⚡ High Priority Open Issues ($high_priority_count)

EOF
        local high_priority_issues
        high_priority_issues=$(echo "$blockers_data" | jq -r '.high_priority_open')
        echo "$high_priority_issues" | jq -r '.[] | "- [#\(.number)](\("https://github.com/" + env.GITHUB_OWNER + "/" + env.GITHUB_REPO + "/issues/" + (.number | tostring))) \(.title)"' | head -10
        echo ""
    fi
    
    # Stale issues
    if [[ $stale_count -gt 0 ]]; then
        cat << EOF
### 🕸️ Stale Issues ($stale_count)

Issues with no activity for 2+ weeks:

EOF
        local stale_issues
        stale_issues=$(echo "$blockers_data" | jq -r '.stale_issues')
        echo "$stale_issues" | jq -r '.[] | "- [#\(.number)](\("https://github.com/" + env.GITHUB_OWNER + "/" + env.GITHUB_REPO + "/issues/" + (.number | tostring))) \(.title)"' | head -5
        echo ""
    fi
    
    # Risk assessment
    cat << EOF
### ⚠️ Risk Assessment

EOF
    
    if [[ $blocked_count -gt 0 ]]; then
        echo "🔴 **High Risk**: $blocked_count blocked issues may impact timeline"
    fi
    
    if [[ $high_priority_count -gt 3 ]]; then
        echo "🟡 **Medium Risk**: $high_priority_count high-priority issues need attention"
    fi
    
    if [[ $stale_count -gt 5 ]]; then
        echo "🟡 **Medium Risk**: $stale_count stale issues may indicate scope or priority issues"
    fi
    
    if [[ $blocked_count -eq 0 && $high_priority_count -le 3 && $stale_count -le 5 ]]; then
        echo "🟢 **Low Risk**: No significant blockers or risks identified"
    fi
    
    echo ""
}

# Function to generate next week priorities
generate_next_week_priorities() {
    local milestone_data="$1"
    local blockers_data="$2"
    
    cat << EOF
## 🎯 Next Week Priorities

### Immediate Actions Required

EOF
    
    local blocked_count
    blocked_count=$(echo "$blockers_data" | jq -r '.blocked_count')
    local high_priority_count  
    high_priority_count=$(echo "$blockers_data" | jq -r '.high_priority_count')
    
    if [[ $blocked_count -gt 0 ]]; then
        echo "1. **🚫 Unblock Issues**: Resolve $blocked_count blocked issues immediately"
    fi
    
    if [[ $high_priority_count -gt 0 ]]; then
        echo "2. **⚡ High Priority Work**: Focus on $high_priority_count critical/high priority issues"
    fi
    
    # Find next milestone needing attention
    local next_milestone
    next_milestone=$(echo "$milestone_data" | jq -r '.[] | select(.state == "open" and .progress_percentage < 100) | .title' | head -1)
    
    if [[ -n "$next_milestone" ]]; then
        echo "3. **🎯 Milestone Focus**: Continue progress on \"$next_milestone\""
    fi
    
    cat << EOF

### Recommended Focus Areas

1. **Blocker Resolution**: Daily standup focus on removing impediments
2. **Code Reviews**: Ensure PRs are reviewed within 24 hours  
3. **Testing**: Maintain test coverage and fix any failing tests
4. **Documentation**: Update documentation as features are completed
5. **Communication**: Keep stakeholders informed of progress and blockers

### Success Metrics for Next Week

- **Velocity**: Aim to match or exceed this week's completion rate
- **Blockers**: Resolve blocked issues within 48 hours
- **Reviews**: Maintain PR review turnaround under 1 day
- **Quality**: Keep bug reports under 10% of completed issues

EOF
}

# Function to generate report footer
generate_report_footer() {
    cat << EOF
---

## 📊 Report Information

**Generated By**: Spec-Kit Weekly Status Generator  
**Generated On**: $(date)  
**Period**: $WEEK_START_DATE to $WEEK_END_DATE  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)

### Quick Links

- 📊 [Issues Dashboard](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/issues)
- 🎯 [Milestones](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/milestones)  
- 🔄 [Pull Requests](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/pulls)
- 📈 [Insights](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/pulse)

### How to Use This Report

1. **Review Metrics**: Compare this week vs last week performance
2. **Address Blockers**: Prioritize unblocking issues immediately  
3. **Celebrate Wins**: Acknowledge completed work and top performers
4. **Plan Ahead**: Use next week priorities for sprint planning
5. **Share Updates**: Forward relevant sections to stakeholders

### Automation

This report is automatically generated. To update:

\`\`\`bash
./05-reporting/weekly-status.sh
\`\`\`

To generate for a different time period:
\`\`\`bash
./05-reporting/weekly-status.sh --week-start 14  # 2 weeks ago
\`\`\`

---
*Weekly status report generated automatically by spec-kit tools*
EOF
}

# Main function to generate weekly status report
generate_weekly_status_report() {
    log_info "Generating weekly status report..."
    
    # Calculate date ranges
    calculate_date_ranges
    
    log_info "Analyzing period: $WEEK_START_DATE to $WEEK_END_DATE"
    
    # Gather all data
    local activity_data
    activity_data=$(get_weekly_activity)
    
    local prev_activity_data
    prev_activity_data=$(get_previous_week_activity)
    
    local milestone_data
    milestone_data=$(get_milestone_progress)
    
    local team_data
    team_data=$(get_team_performance)
    
    local blockers_data
    blockers_data=$(get_blockers_and_risks)
    
    log_info "Generating report sections..."
    
    # Generate complete report
    {
        generate_report_header
        generate_activity_summary "$activity_data" "$prev_activity_data"
        generate_completed_work "$activity_data"
        generate_milestone_progress "$milestone_data"
        generate_team_performance "$team_data"
        generate_blockers_and_risks "$blockers_data"
        generate_next_week_priorities "$milestone_data" "$blockers_data"
        generate_report_footer
    } > "$OUTPUT_FILE"
    
    log_success "Weekly status report generated: $OUTPUT_FILE"
}

# Function to generate summary email/slack format
generate_summary_format() {
    log_info "Generating summary format..."
    
    local summary_file="${ROOT_DIR}/weekly-summary-$(date +%Y-%m-%d).txt"
    local activity_data
    activity_data=$(get_weekly_activity)
    
    local issues_closed
    issues_closed=$(echo "$activity_data" | jq -r '.issues_closed_count')
    local prs_merged
    prs_merged=$(echo "$activity_data" | jq -r '.prs_merged_count')
    
    cat > "$summary_file" << EOF
📊 Weekly Update - $PROJECT_NAME ($WEEK_START_DATE to $WEEK_END_DATE)

✅ Completed: $issues_closed issues, $prs_merged PRs merged
🎯 Active milestones progressing
⚠️ Blockers: Check full report for details

Full report: $OUTPUT_FILE
EOF
    
    log_success "Summary format generated: $summary_file"
}

# Main function
main() {
    log_info "Starting weekly status report generation..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Project: $PROJECT_NAME"
    log_info "Week period: $WEEK_START days ago to today"
    log_info "Output file: $OUTPUT_FILE"
    echo ""
    
    # Generate report
    generate_weekly_status_report
    
    # Generate summary format
    generate_summary_format
    
    echo ""
    log_success "Weekly status report completed!"
    log_info "Files generated:"
    echo "  - Full report: $OUTPUT_FILE"
    echo "  - Summary: ${ROOT_DIR}/weekly-summary-$(date +%Y-%m-%d).txt"
    echo ""
    log_info "Next steps:"
    echo "  1. Review the report for accuracy"
    echo "  2. Share with team and stakeholders"
    echo "  3. Address any blockers identified"
    echo "  4. Use insights for next week planning"
    echo "  5. Schedule this as a weekly automation"
}

# Help function
show_help() {
    echo "Generate Weekly Status Report"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -o, --output FILE       Specify output file (default: ../weekly-status-YYYY-MM-DD.md)"
    echo "  -p, --project NAME      Specify project name"
    echo "  -w, --week-start DAYS   Days ago to start the week (default: 7)"
    echo "  --summary-only          Generate only summary format"
    echo "  --repo OWNER/REPO       Specify GitHub repository"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_OWNER            GitHub repository owner"
    echo "  GITHUB_REPO             GitHub repository name"
    echo "  PROJECT_NAME            Project name for report"
    echo "  WEEK_START              Days ago to start the reporting week"
    echo ""
    echo "This script generates comprehensive weekly status including:"
    echo "  • Activity metrics and week-over-week comparison"
    echo "  • Completed work breakdown by epic and team member"
    echo "  • Milestone progress tracking"
    echo "  • Team performance analysis"
    echo "  • Blockers and risk identification"
    echo "  • Next week priorities and action items"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Generate standard weekly report"
    echo "  $0 --week-start 14                   # Report for 2 weeks ago"
    echo "  $0 --project \"My Project\"             # Set custom project name"
    echo "  $0 --summary-only                    # Generate only summary format"
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
        -w|--week-start)
            WEEK_START="$2"
            shift 2
            ;;
        --summary-only)
            check_prerequisites
            calculate_date_ranges
            generate_summary_format
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