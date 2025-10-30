#!/bin/bash

# Generate Burndown Chart Data and Report
# This script creates burndown data for sprints, milestones, and epics

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
OUTPUT_FILE="${OUTPUT_FILE:-${ROOT_DIR}/burndown-report.md}"
BURNDOWN_TYPE="${BURNDOWN_TYPE:-milestone}"  # milestone, epic, or sprint
TARGET_MILESTONE="${TARGET_MILESTONE:-}"
TARGET_EPIC="${TARGET_EPIC:-}"
SPRINT_DAYS="${SPRINT_DAYS:-14}"
STORY_POINT_MAPPING="${STORY_POINT_MAPPING:-true}"

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

# Function to map size labels to story points
get_story_points() {
    local labels="$1"
    
    # Default story point mapping
    if echo "$labels" | grep -q "size:XS"; then
        echo "1"
    elif echo "$labels" | grep -q "size:S"; then
        echo "3"
    elif echo "$labels" | grep -q "size:M"; then
        echo "5"
    elif echo "$labels" | grep -q "size:L"; then
        echo "8"
    elif echo "$labels" | grep -q "size:XL"; then
        echo "13"
    else
        echo "3"  # Default for unlabeled issues
    fi
}

# Function to get milestone burndown data
get_milestone_burndown_data() {
    local milestone_title="$1"
    
    log_info "Generating burndown data for milestone: $milestone_title"
    
    # Get milestone information
    local milestone_data
    milestone_data=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq ".[] | select(.title == \"$milestone_title\")")
    
    if [[ -z "$milestone_data" ]]; then
        log_error "Milestone not found: $milestone_title"
        return 1
    fi
    
    local milestone_number
    milestone_number=$(echo "$milestone_data" | jq -r '.number')
    local due_date
    due_date=$(echo "$milestone_data" | jq -r '.due_on // empty')
    local created_date
    created_date=$(echo "$milestone_data" | jq -r '.created_at')
    
    # Get all issues for this milestone
    local milestone_issues
    milestone_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --milestone "$milestone_title" --state all --json number,title,state,createdAt,closedAt,labels --limit 1000)
    
    # Calculate start and end dates
    local start_date
    if [[ -n "$due_date" ]]; then
        # Calculate start date based on created date or 4 weeks before due date
        start_date=$(echo "$milestone_data" | jq -r '.created_at')
        if [[ -z "$start_date" ]]; then
            start_date=$(date -d "$due_date - 28 days" -u +%Y-%m-%dT00:00:00Z)
        fi
    else
        # Use creation date or current date - 28 days
        start_date=$(echo "$milestone_data" | jq -r '.created_at // empty')
        if [[ -z "$start_date" ]]; then
            start_date=$(date -d "28 days ago" -u +%Y-%m-%dT00:00:00Z)
        fi
        due_date=$(date -u +%Y-%m-%dT23:59:59Z)
    fi
    
    # Calculate total story points
    local total_points=0
    if [[ "$STORY_POINT_MAPPING" == "true" ]]; then
        while read -r issue; do
            if [[ -n "$issue" ]]; then
                local labels
                labels=$(echo "$issue" | jq -r '.labels[].name' | tr '\n' ' ')
                local points
                points=$(get_story_points "$labels")
                total_points=$((total_points + points))
            fi
        done < <(echo "$milestone_issues" | jq -c '.[]')
    else
        total_points=$(echo "$milestone_issues" | jq length)
    fi
    
    # Generate daily burndown data
    local burndown_data="[]"
    local current_date="$start_date"
    local end_date_timestamp
    end_date_timestamp=$(date -d "$due_date" +%s)
    
    while [[ $(date -d "$current_date" +%s) -le $end_date_timestamp ]]; do
        local remaining_points=0
        local completed_points=0
        
        # Calculate remaining points for this date
        while read -r issue; do
            if [[ -n "$issue" ]]; then
                local issue_state
                issue_state=$(echo "$issue" | jq -r '.state')
                local closed_at
                closed_at=$(echo "$issue" | jq -r '.closedAt // empty')
                
                local points=1
                if [[ "$STORY_POINT_MAPPING" == "true" ]]; then
                    local labels
                    labels=$(echo "$issue" | jq -r '.labels[].name' | tr '\n' ' ')
                    points=$(get_story_points "$labels")
                fi
                
                # If issue was closed after this date, it's still remaining
                if [[ "$issue_state" == "open" ]] || [[ -z "$closed_at" ]] || [[ "$closed_at" > "$current_date" ]]; then
                    remaining_points=$((remaining_points + points))
                else
                    completed_points=$((completed_points + points))
                fi
            fi
        done < <(echo "$milestone_issues" | jq -c '.[]')
        
        # Add data point
        local formatted_date
        formatted_date=$(date -d "$current_date" +%Y-%m-%d)
        
        local data_point
        data_point=$(jq -n \
            --arg date "$formatted_date" \
            --argjson remaining "$remaining_points" \
            --argjson completed "$completed_points" \
            --argjson total "$total_points" \
            '{
                date: $date,
                remaining_points: $remaining,
                completed_points: $completed,
                total_points: $total,
                ideal_remaining: ($total * (1 - ((now - ($date + "T00:00:00Z" | fromdateiso8601)) / ('$end_date_timestamp' - ('$start_date' | fromdateiso8601)))))
            }')
        
        burndown_data=$(echo "$burndown_data" | jq ". + [$data_point]")
        
        # Move to next day
        current_date=$(date -d "$current_date + 1 day" -u +%Y-%m-%dT00:00:00Z)
    done
    
    # Return burndown data with metadata
    jq -n \
        --arg milestone "$milestone_title" \
        --arg start_date "$start_date" \
        --arg end_date "$due_date" \
        --argjson total_points "$total_points" \
        --argjson burndown_data "$burndown_data" \
        --argjson issues "$milestone_issues" \
        '{
            milestone: $milestone,
            start_date: $start_date,
            end_date: $end_date,
            total_points: $total_points,
            burndown_data: $burndown_data,
            issues: $issues
        }'
}

# Function to get epic burndown data
get_epic_burndown_data() {
    local epic_name="$1"
    
    log_info "Generating burndown data for epic: $epic_name"
    
    # Get all issues for this epic
    local epic_issues
    epic_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --label "epic:$epic_name" --state all --json number,title,state,createdAt,closedAt,labels --limit 1000)
    
    if [[ $(echo "$epic_issues" | jq length) -eq 0 ]]; then
        log_error "No issues found for epic: $epic_name"
        return 1
    fi
    
    # Find date range (first created to last closed or now)
    local start_date
    start_date=$(echo "$epic_issues" | jq -r 'min_by(.createdAt).createdAt')
    local end_date
    end_date=$(echo "$epic_issues" | jq -r 'map(select(.closedAt)) | max_by(.closedAt).closedAt // empty')
    
    if [[ -z "$end_date" ]]; then
        end_date=$(date -u +%Y-%m-%dT23:59:59Z)
    fi
    
    # Calculate total story points
    local total_points=0
    if [[ "$STORY_POINT_MAPPING" == "true" ]]; then
        while read -r issue; do
            if [[ -n "$issue" ]]; then
                local labels
                labels=$(echo "$issue" | jq -r '.labels[].name' | tr '\n' ' ')
                local points
                points=$(get_story_points "$labels")
                total_points=$((total_points + points))
            fi
        done < <(echo "$epic_issues" | jq -c '.[]')
    else
        total_points=$(echo "$epic_issues" | jq length)
    fi
    
    # Generate weekly burndown data (epics typically span longer periods)
    local burndown_data="[]"
    local current_date="$start_date"
    local end_date_timestamp
    end_date_timestamp=$(date -d "$end_date" +%s)
    
    while [[ $(date -d "$current_date" +%s) -le $end_date_timestamp ]]; do
        local remaining_points=0
        local completed_points=0
        
        # Calculate remaining points for this date
        while read -r issue; do
            if [[ -n "$issue" ]]; then
                local issue_state
                issue_state=$(echo "$issue" | jq -r '.state')
                local closed_at
                closed_at=$(echo "$issue" | jq -r '.closedAt // empty')
                
                local points=1
                if [[ "$STORY_POINT_MAPPING" == "true" ]]; then
                    local labels
                    labels=$(echo "$issue" | jq -r '.labels[].name' | tr '\n' ' ')
                    points=$(get_story_points "$labels")
                fi
                
                # If issue was closed after this date, it's still remaining
                if [[ "$issue_state" == "open" ]] || [[ -z "$closed_at" ]] || [[ "$closed_at" > "$current_date" ]]; then
                    remaining_points=$((remaining_points + points))
                else
                    completed_points=$((completed_points + points))
                fi
            fi
        done < <(echo "$epic_issues" | jq -c '.[]')
        
        # Add data point
        local formatted_date
        formatted_date=$(date -d "$current_date" +%Y-%m-%d)
        
        local data_point
        data_point=$(jq -n \
            --arg date "$formatted_date" \
            --argjson remaining "$remaining_points" \
            --argjson completed "$completed_points" \
            --argjson total "$total_points" \
            '{
                date: $date,
                remaining_points: $remaining,
                completed_points: $completed,
                total_points: $total
            }')
        
        burndown_data=$(echo "$burndown_data" | jq ". + [$data_point]")
        
        # Move to next week for epics
        current_date=$(date -d "$current_date + 7 days" -u +%Y-%m-%dT00:00:00Z)
    done
    
    # Return burndown data with metadata
    jq -n \
        --arg epic "$epic_name" \
        --arg start_date "$start_date" \
        --arg end_date "$end_date" \
        --argjson total_points "$total_points" \
        --argjson burndown_data "$burndown_data" \
        --argjson issues "$epic_issues" \
        '{
            epic: $epic,
            start_date: $start_date,
            end_date: $end_date,
            total_points: $total_points,
            burndown_data: $burndown_data,
            issues: $issues
        }'
}

# Function to generate sprint burndown data
get_sprint_burndown_data() {
    local sprint_start_days_ago="$1"
    
    log_info "Generating sprint burndown data (last $SPRINT_DAYS days)"
    
    # Calculate sprint dates
    local sprint_start
    sprint_start=$(date -d "$sprint_start_days_ago days ago" -u +%Y-%m-%dT00:00:00Z)
    local sprint_end
    sprint_end=$(date -u +%Y-%m-%dT23:59:59Z)
    
    # Get issues closed during sprint
    local sprint_start_date
    sprint_start_date=$(date -d "$sprint_start_days_ago days ago" +%Y-%m-%d)
    local sprint_issues
    sprint_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "closed:>=$sprint_start_date" --state closed --json number,title,state,createdAt,closedAt,labels --limit 1000)
    
    # Also get currently open issues that were created before sprint start
    local open_issues
    open_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "created:<$sprint_start_date is:open" --json number,title,state,createdAt,closedAt,labels --limit 1000)
    
    # Combine all relevant issues
    local all_sprint_issues
    all_sprint_issues=$(echo "$sprint_issues $open_issues" | jq -s 'add | unique_by(.number)')
    
    # Calculate total story points at sprint start
    local total_points=0
    if [[ "$STORY_POINT_MAPPING" == "true" ]]; then
        while read -r issue; do
            if [[ -n "$issue" ]]; then
                local labels
                labels=$(echo "$issue" | jq -r '.labels[].name' | tr '\n' ' ')
                local points
                points=$(get_story_points "$labels")
                total_points=$((total_points + points))
            fi
        done < <(echo "$all_sprint_issues" | jq -c '.[]')
    else
        total_points=$(echo "$all_sprint_issues" | jq length)
    fi
    
    # Generate daily burndown data
    local burndown_data="[]"
    local current_date="$sprint_start"
    local end_date_timestamp
    end_date_timestamp=$(date -d "$sprint_end" +%s)
    
    while [[ $(date -d "$current_date" +%s) -le $end_date_timestamp ]]; do
        local remaining_points=0
        local completed_points=0
        
        # Calculate remaining points for this date
        while read -r issue; do
            if [[ -n "$issue" ]]; then
                local issue_state
                issue_state=$(echo "$issue" | jq -r '.state')
                local closed_at
                closed_at=$(echo "$issue" | jq -r '.closedAt // empty')
                
                local points=1
                if [[ "$STORY_POINT_MAPPING" == "true" ]]; then
                    local labels
                    labels=$(echo "$issue" | jq -r '.labels[].name' | tr '\n' ' ')
                    points=$(get_story_points "$labels")
                fi
                
                # If issue was closed after this date, it's still remaining
                if [[ "$issue_state" == "open" ]] || [[ -z "$closed_at" ]] || [[ "$closed_at" > "$current_date" ]]; then
                    remaining_points=$((remaining_points + points))
                else
                    completed_points=$((completed_points + points))
                fi
            fi
        done < <(echo "$all_sprint_issues" | jq -c '.[]')
        
        # Calculate ideal burndown
        local days_elapsed
        days_elapsed=$(( ($(date -d "$current_date" +%s) - $(date -d "$sprint_start" +%s)) / 86400 ))
        local ideal_remaining
        ideal_remaining=$(( total_points - (total_points * days_elapsed / SPRINT_DAYS) ))
        
        # Add data point
        local formatted_date
        formatted_date=$(date -d "$current_date" +%Y-%m-%d)
        
        local data_point
        data_point=$(jq -n \
            --arg date "$formatted_date" \
            --argjson remaining "$remaining_points" \
            --argjson completed "$completed_points" \
            --argjson total "$total_points" \
            --argjson ideal "$ideal_remaining" \
            '{
                date: $date,
                remaining_points: $remaining,
                completed_points: $completed,
                total_points: $total,
                ideal_remaining: $ideal
            }')
        
        burndown_data=$(echo "$burndown_data" | jq ". + [$data_point]")
        
        # Move to next day
        current_date=$(date -d "$current_date + 1 day" -u +%Y-%m-%dT00:00:00Z)
    done
    
    # Return burndown data with metadata
    jq -n \
        --arg sprint_start "$sprint_start" \
        --arg sprint_end "$sprint_end" \
        --argjson total_points "$total_points" \
        --argjson sprint_days "$SPRINT_DAYS" \
        --argjson burndown_data "$burndown_data" \
        --argjson issues "$all_sprint_issues" \
        '{
            sprint_start: $sprint_start,
            sprint_end: $sprint_end,
            sprint_days: $sprint_days,
            total_points: $total_points,
            burndown_data: $burndown_data,
            issues: $issues
        }'
}

# Function to generate burndown report header
generate_burndown_header() {
    local burndown_data="$1"
    local burndown_type="$2"
    
    cat << EOF
# $PROJECT_NAME - Burndown Chart Report

**Generated**: $(date)  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)  
**Burndown Type**: $burndown_type

---

## 📊 Burndown Overview

EOF
    
    # Extract key metrics based on burndown type
    if [[ "$burndown_type" == "milestone" ]]; then
        local milestone
        milestone=$(echo "$burndown_data" | jq -r '.milestone')
        local start_date
        start_date=$(echo "$burndown_data" | jq -r '.start_date' | cut -d'T' -f1)
        local end_date
        end_date=$(echo "$burndown_data" | jq -r '.end_date' | cut -d'T' -f1)
        
        echo "**Milestone**: $milestone"
        echo "**Period**: $start_date to $end_date"
    elif [[ "$burndown_type" == "epic" ]]; then
        local epic
        epic=$(echo "$burndown_data" | jq -r '.epic')
        local start_date
        start_date=$(echo "$burndown_data" | jq -r '.start_date' | cut -d'T' -f1)
        local end_date
        end_date=$(echo "$burndown_data" | jq -r '.end_date' | cut -d'T' -f1)
        
        echo "**Epic**: $epic"
        echo "**Period**: $start_date to $end_date"
    elif [[ "$burndown_type" == "sprint" ]]; then
        local sprint_days
        sprint_days=$(echo "$burndown_data" | jq -r '.sprint_days')
        local start_date
        start_date=$(echo "$burndown_data" | jq -r '.sprint_start' | cut -d'T' -f1)
        local end_date
        end_date=$(echo "$burndown_data" | jq -r '.sprint_end' | cut -d'T' -f1)
        
        echo "**Sprint Duration**: $sprint_days days"
        echo "**Period**: $start_date to $end_date"
    fi
    
    local total_points
    total_points=$(echo "$burndown_data" | jq -r '.total_points')
    
    if [[ "$STORY_POINT_MAPPING" == "true" ]]; then
        echo "**Total Story Points**: $total_points"
    else
        echo "**Total Issues**: $total_points"
    fi
    
    echo ""
}

# Function to generate burndown chart data table
generate_burndown_table() {
    local burndown_data="$1"
    local burndown_type="$2"
    
    cat << EOF
## 📈 Burndown Data

| Date | Remaining | Completed | Total |$(if [[ "$burndown_type" == "sprint" ]]; then echo " Ideal |"; fi)
|------|-----------|-----------|-------|$(if [[ "$burndown_type" == "sprint" ]]; then echo "-------|"; fi)
EOF
    
    local data_points
    data_points=$(echo "$burndown_data" | jq -r '.burndown_data')
    
    echo "$data_points" | jq -r '.[] | @base64' | while read -r point_b64; do
        local point
        point=$(echo "$point_b64" | base64 -d)
        
        local date
        date=$(echo "$point" | jq -r '.date')
        local remaining
        remaining=$(echo "$point" | jq -r '.remaining_points')
        local completed
        completed=$(echo "$point" | jq -r '.completed_points')
        local total
        total=$(echo "$point" | jq -r '.total_points')
        
        if [[ "$burndown_type" == "sprint" ]]; then
            local ideal
            ideal=$(echo "$point" | jq -r '.ideal_remaining // 0')
            printf "| %s | %d | %d | %d | %d |\n" "$date" "$remaining" "$completed" "$total" "$ideal"
        else
            printf "| %s | %d | %d | %d |\n" "$date" "$remaining" "$completed" "$total"
        fi
    done
    
    echo ""
}

# Function to generate burndown analysis
generate_burndown_analysis() {
    local burndown_data="$1"
    local burndown_type="$2"
    
    cat << EOF
## 🔍 Burndown Analysis

EOF
    
    local data_points
    data_points=$(echo "$burndown_data" | jq -r '.burndown_data')
    local total_points
    total_points=$(echo "$burndown_data" | jq -r '.total_points')
    
    # Get first and last data points
    local first_point
    first_point=$(echo "$data_points" | jq '.[0]')
    local last_point
    last_point=$(echo "$data_points" | jq '.[-1]')
    
    local start_remaining
    start_remaining=$(echo "$first_point" | jq -r '.remaining_points')
    local current_remaining
    current_remaining=$(echo "$last_point" | jq -r '.remaining_points')
    local current_completed
    current_completed=$(echo "$last_point" | jq -r '.completed_points')
    
    local completion_percentage=0
    if [[ $total_points -gt 0 ]]; then
        completion_percentage=$((current_completed * 100 / total_points))
    fi
    
    cat << EOF
### Progress Summary

- **Total Scope**: $total_points $(if [[ "$STORY_POINT_MAPPING" == "true" ]]; then echo "story points"; else echo "issues"; fi)
- **Completed**: $current_completed ($completion_percentage%)
- **Remaining**: $current_remaining
- **Velocity**: $(if [[ "$burndown_type" == "sprint" ]]; then echo "$((current_completed / SPRINT_DAYS)) points/day"; else echo "Varies by period"; fi)

EOF
    
    # Burndown trend analysis
    local data_count
    data_count=$(echo "$data_points" | jq length)
    
    if [[ $data_count -gt 1 ]]; then
        # Calculate trend (are we burning down consistently?)
        local mid_point_index=$((data_count / 2))
        local mid_point
        mid_point=$(echo "$data_points" | jq ".[$mid_point_index]")
        local mid_remaining
        mid_remaining=$(echo "$mid_point" | jq -r '.remaining_points')
        
        cat << EOF
### Trend Analysis

EOF
        
        if [[ $current_remaining -eq 0 ]]; then
            echo "🎯 **Complete**: All work has been finished!"
        elif [[ $current_remaining -lt $((total_points / 4)) ]]; then
            echo "🚀 **Excellent Progress**: Nearly complete with strong burndown rate"
        elif [[ $current_remaining -lt $((total_points / 2)) ]]; then
            echo "📊 **Good Progress**: More than halfway complete"
        elif [[ $current_remaining -eq $start_remaining ]]; then
            echo "⚠️ **No Progress**: No work has been completed yet"
        else
            echo "🔄 **In Progress**: Work is being completed steadily"
        fi
        
        # Sprint-specific analysis
        if [[ "$burndown_type" == "sprint" ]]; then
            local ideal_remaining
            ideal_remaining=$(echo "$last_point" | jq -r '.ideal_remaining // 0')
            
            if [[ $current_remaining -lt $ideal_remaining ]]; then
                local ahead_by=$((ideal_remaining - current_remaining))
                echo "📈 **Ahead of Schedule**: $ahead_by points ahead of ideal burndown"
            elif [[ $current_remaining -gt $ideal_remaining ]]; then
                local behind_by=$((current_remaining - ideal_remaining))
                echo "📉 **Behind Schedule**: $behind_by points behind ideal burndown"
            else
                echo "🎯 **On Track**: Following ideal burndown perfectly"
            fi
        fi
        
        echo ""
    fi
}

# Function to generate recommendations
generate_recommendations() {
    local burndown_data="$1"
    local burndown_type="$2"
    
    cat << EOF
## 💡 Recommendations

EOF
    
    local data_points
    data_points=$(echo "$burndown_data" | jq -r '.burndown_data')
    local total_points
    total_points=$(echo "$burndown_data" | jq -r '.total_points')
    local last_point
    last_point=$(echo "$data_points" | jq '.[-1]')
    local current_remaining
    current_remaining=$(echo "$last_point" | jq -r '.remaining_points')
    local current_completed
    current_completed=$(echo "$last_point" | jq -r '.completed_points')
    
    local completion_percentage=0
    if [[ $total_points -gt 0 ]]; then
        completion_percentage=$((current_completed * 100 / total_points))
    fi
    
    if [[ $current_remaining -eq 0 ]]; then
        cat << EOF
### 🎉 Completion Achieved!

- **Celebrate Success**: All planned work has been completed
- **Retrospective**: Conduct team retrospective to capture lessons learned
- **Documentation**: Ensure all deliverables are properly documented
- **Next Phase**: Begin planning for next milestone/sprint/epic

EOF
    elif [[ $completion_percentage -ge 80 ]]; then
        cat << EOF
### 🎯 Nearly Complete

- **Focus on Remaining Work**: Prioritize the last $current_remaining items
- **Quality Check**: Ensure completed work meets quality standards
- **Risk Management**: Identify any blockers for remaining items
- **Prepare for Closure**: Begin preparation for completion activities

EOF
    elif [[ $completion_percentage -ge 50 ]]; then
        cat << EOF
### 📊 Halfway Point

- **Maintain Momentum**: Current pace is showing good progress
- **Review Scope**: Assess if remaining work aligns with goals
- **Resource Check**: Ensure team has adequate capacity
- **Risk Assessment**: Monitor for potential impediments

EOF
    elif [[ $completion_percentage -ge 25 ]]; then
        cat << EOF
### 🔄 Early Progress

- **Increase Velocity**: Consider ways to accelerate completion
- **Remove Blockers**: Identify and resolve any impediments
- **Team Support**: Ensure team has necessary resources
- **Scope Review**: Validate that all remaining work is still needed

EOF
    else
        cat << EOF
### ⚠️ Limited Progress

- **Urgent Review Required**: Low completion rate needs immediate attention
- **Blocker Analysis**: Identify what's preventing progress
- **Resource Allocation**: Review team capacity and priorities
- **Scope Adjustment**: Consider reducing scope if timeline is fixed
- **Stakeholder Communication**: Keep stakeholders informed of challenges

EOF
    fi
    
    # Type-specific recommendations
    if [[ "$burndown_type" == "sprint" ]]; then
        local ideal_remaining
        ideal_remaining=$(echo "$last_point" | jq -r '.ideal_remaining // 0')
        
        if [[ $current_remaining -gt $ideal_remaining ]]; then
            cat << EOF
### Sprint-Specific Actions

- **Daily Standups**: Increase focus on removing impediments
- **Pair Programming**: Consider pairing on complex tasks
- **Scope Management**: Move non-critical items to next sprint
- **Team Availability**: Ensure full team availability for remaining days

EOF
        fi
    elif [[ "$burndown_type" == "milestone" ]]; then
        cat << EOF
### Milestone-Specific Actions

- **Weekly Reviews**: Schedule weekly progress reviews
- **Epic Prioritization**: Focus on critical path epics
- **Cross-team Coordination**: Ensure dependencies are managed
- **Quality Gates**: Don't compromise quality for speed

EOF
    fi
}

# Function to generate CSV export
generate_csv_export() {
    local burndown_data="$1"
    local burndown_type="$2"
    
    local csv_file="${ROOT_DIR}/burndown-data-$(date +%Y-%m-%d).csv"
    
    log_info "Generating CSV export: $csv_file"
    
    # CSV header
    if [[ "$burndown_type" == "sprint" ]]; then
        echo "date,remaining_points,completed_points,total_points,ideal_remaining" > "$csv_file"
    else
        echo "date,remaining_points,completed_points,total_points" > "$csv_file"
    fi
    
    # Data rows
    local data_points
    data_points=$(echo "$burndown_data" | jq -r '.burndown_data')
    
    echo "$data_points" | jq -r '.[] | @base64' | while read -r point_b64; do
        local point
        point=$(echo "$point_b64" | base64 -d)
        
        local date
        date=$(echo "$point" | jq -r '.date')
        local remaining
        remaining=$(echo "$point" | jq -r '.remaining_points')
        local completed
        completed=$(echo "$point" | jq -r '.completed_points')
        local total
        total=$(echo "$point" | jq -r '.total_points')
        
        if [[ "$burndown_type" == "sprint" ]]; then
            local ideal
            ideal=$(echo "$point" | jq -r '.ideal_remaining // 0')
            echo "$date,$remaining,$completed,$total,$ideal" >> "$csv_file"
        else
            echo "$date,$remaining,$completed,$total" >> "$csv_file"
        fi
    done
    
    log_success "CSV export generated: $csv_file"
}

# Function to generate report footer
generate_report_footer() {
    cat << EOF
---

## 📊 Chart Visualization

To visualize this burndown data:

### Using Excel/Google Sheets
1. Import the CSV file: \`burndown-data-$(date +%Y-%m-%d).csv\`
2. Create a line chart with date on X-axis
3. Plot remaining_points as primary line
4. Add ideal_remaining (for sprints) as reference line
5. Use completed_points for cumulative progress

### Using Python/Matplotlib
\`\`\`python
import pandas as pd
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv('burndown-data-$(date +%Y-%m-%d).csv')
df['date'] = pd.to_datetime(df['date'])

# Create burndown chart
plt.figure(figsize=(12, 6))
plt.plot(df['date'], df['remaining_points'], 'b-o', label='Actual Remaining')
$(if [[ "$BURNDOWN_TYPE" == "sprint" ]]; then echo "plt.plot(df['date'], df['ideal_remaining'], 'r--', label='Ideal Remaining')"; fi)
plt.xlabel('Date')
plt.ylabel('Story Points')
plt.title('Burndown Chart')
plt.legend()
plt.grid(True)
plt.show()
\`\`\`

---

## 📊 Report Information

**Generated By**: Spec-Kit Burndown Generator  
**Generated On**: $(date)  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)

### Automation

This report can be automated:

\`\`\`bash
# Generate milestone burndown
./05-reporting/burndown.sh --type milestone --milestone "M1: MVP Foundation"

# Generate epic burndown  
./05-reporting/burndown.sh --type epic --epic foundation

# Generate sprint burndown
./05-reporting/burndown.sh --type sprint --sprint-days 14
\`\`\`

---
*Burndown report generated automatically by spec-kit tools*
EOF
}

# Main function to generate burndown report
generate_burndown_report() {
    log_info "Generating burndown report for type: $BURNDOWN_TYPE"
    
    local burndown_data=""
    
    # Generate appropriate burndown data based on type
    case "$BURNDOWN_TYPE" in
        "milestone")
            if [[ -z "$TARGET_MILESTONE" ]]; then
                # Get first open milestone
                TARGET_MILESTONE=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq '.[] | select(.state == "open") | .title' | head -1)
                if [[ -z "$TARGET_MILESTONE" ]]; then
                    log_error "No open milestones found. Please specify --milestone option."
                    exit 1
                fi
                log_info "Using milestone: $TARGET_MILESTONE"
            fi
            burndown_data=$(get_milestone_burndown_data "$TARGET_MILESTONE")
            ;;
        "epic")
            if [[ -z "$TARGET_EPIC" ]]; then
                log_error "Epic name required for epic burndown. Use --epic option."
                exit 1
            fi
            burndown_data=$(get_epic_burndown_data "$TARGET_EPIC")
            ;;
        "sprint")
            burndown_data=$(get_sprint_burndown_data "$SPRINT_DAYS")
            ;;
        *)
            log_error "Invalid burndown type: $BURNDOWN_TYPE"
            exit 1
            ;;
    esac
    
    if [[ -z "$burndown_data" ]]; then
        log_error "Failed to generate burndown data"
        exit 1
    fi
    
    log_info "Generating report sections..."
    
    # Generate complete report
    {
        generate_burndown_header "$burndown_data" "$BURNDOWN_TYPE"
        generate_burndown_table "$burndown_data" "$BURNDOWN_TYPE"
        generate_burndown_analysis "$burndown_data" "$BURNDOWN_TYPE"
        generate_recommendations "$burndown_data" "$BURNDOWN_TYPE"
        generate_report_footer
    } > "$OUTPUT_FILE"
    
    # Generate CSV export
    generate_csv_export "$burndown_data" "$BURNDOWN_TYPE"
    
    log_success "Burndown report generated: $OUTPUT_FILE"
}

# Main function
main() {
    log_info "Starting burndown analysis..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Project: $PROJECT_NAME"
    log_info "Burndown type: $BURNDOWN_TYPE"
    if [[ "$BURNDOWN_TYPE" == "milestone" && -n "$TARGET_MILESTONE" ]]; then
        log_info "Target milestone: $TARGET_MILESTONE"
    elif [[ "$BURNDOWN_TYPE" == "epic" && -n "$TARGET_EPIC" ]]; then
        log_info "Target epic: $TARGET_EPIC"
    elif [[ "$BURNDOWN_TYPE" == "sprint" ]]; then
        log_info "Sprint duration: $SPRINT_DAYS days"
    fi
    log_info "Story point mapping: $STORY_POINT_MAPPING"
    log_info "Output file: $OUTPUT_FILE"
    echo ""
    
    # Generate report
    generate_burndown_report
    
    echo ""
    log_success "Burndown analysis completed!"
    log_info "Files generated:"
    echo "  - Burndown report: $OUTPUT_FILE"
    echo "  - CSV data: ${ROOT_DIR}/burndown-data-$(date +%Y-%m-%d).csv"
    echo ""
    log_info "Next steps:"
    echo "  1. Review burndown trends and analysis"
    echo "  2. Share insights with team and stakeholders"
    echo "  3. Take action on recommendations"
    echo "  4. Import CSV data into charting tools for visualization"
    echo "  5. Schedule regular burndown reviews"
}

# Help function
show_help() {
    echo "Generate Burndown Chart Data and Report"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -t, --type TYPE         Burndown type: milestone, epic, or sprint (default: milestone)"
    echo "  -m, --milestone NAME    Target milestone for milestone burndown"
    echo "  -e, --epic NAME         Target epic for epic burndown"
    echo "  -s, --sprint-days DAYS  Sprint duration in days (default: 14)"
    echo "  -o, --output FILE       Specify output file (default: ../burndown-report.md)"
    echo "  -p, --project NAME      Specify project name"
    echo "  --no-story-points       Use issue count instead of story points"
    echo "  --csv-only              Generate only CSV data"
    echo "  --repo OWNER/REPO       Specify GitHub repository"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_OWNER            GitHub repository owner"
    echo "  GITHUB_REPO             GitHub repository name"
    echo "  PROJECT_NAME            Project name for report"
    echo ""
    echo "This script generates burndown analysis including:"
    echo "  • Burndown chart data (CSV format)"
    echo "  • Progress analysis and trends"
    echo "  • Velocity calculations"
    echo "  • Recommendations based on current status"
    echo "  • Visualization instructions"
    echo ""
    echo "Burndown Types:"
    echo "  • milestone: Track progress toward milestone completion"
    echo "  • epic: Track epic progress over time"  
    echo "  • sprint: Track sprint progress with ideal burndown line"
    echo ""
    echo "Examples:"
    echo "  $0 --type milestone --milestone \"M1: MVP Foundation\""
    echo "  $0 --type epic --epic foundation"
    echo "  $0 --type sprint --sprint-days 10"
    echo "  $0 --csv-only --type sprint"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--type)
            BURNDOWN_TYPE="$2"
            shift 2
            ;;
        -m|--milestone)
            TARGET_MILESTONE="$2"
            shift 2
            ;;
        -e|--epic)
            TARGET_EPIC="$2"
            shift 2
            ;;
        -s|--sprint-days)
            SPRINT_DAYS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --no-story-points)
            STORY_POINT_MAPPING="false"
            shift
            ;;
        --csv-only)
            check_prerequisites
            case "$BURNDOWN_TYPE" in
                "milestone")
                    if [[ -z "$TARGET_MILESTONE" ]]; then
                        TARGET_MILESTONE=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq '.[] | select(.state == "open") | .title' | head -1)
                    fi
                    burndown_data=$(get_milestone_burndown_data "$TARGET_MILESTONE")
                    ;;
                "epic")
                    burndown_data=$(get_epic_burndown_data "$TARGET_EPIC")
                    ;;
                "sprint")
                    burndown_data=$(get_sprint_burndown_data "$SPRINT_DAYS")
                    ;;
            esac
            generate_csv_export "$burndown_data" "$BURNDOWN_TYPE"
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

# Validate burndown type specific requirements
if [[ "$BURNDOWN_TYPE" == "epic" && -z "$TARGET_EPIC" ]]; then
    log_error "Epic name is required for epic burndown. Use --epic option."
    exit 1
fi

# Run main function
main "$@"