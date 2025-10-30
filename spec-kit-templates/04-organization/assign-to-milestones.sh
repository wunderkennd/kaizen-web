#!/bin/bash

# Assign GitHub Issues to Milestones
# This script assigns issues to milestones based on epic mapping and project timeline

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
TASKS_FILE="${ROOT_DIR}/extracted-tasks.csv"
MILESTONES_CONFIG="${SCRIPT_DIR}/milestones.yaml"
DRY_RUN="${DRY_RUN:-false}"
BATCH_SIZE="${BATCH_SIZE:-5}"
RATE_LIMIT_DELAY="${RATE_LIMIT_DELAY:-2}"

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
    
    # Check if tasks file exists
    if [[ ! -f "$TASKS_FILE" ]]; then
        log_error "Tasks file not found: $TASKS_FILE"
        log_info "Please run: ./02-extraction/extract-tasks.sh"
        exit 1
    fi
    
    log_success "Prerequisites checked"
}

# Function to find issue number by task ID
find_issue_number() {
    local task_id="$1"
    
    # Search for issues with the task ID in title
    gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "$task_id in:title" --json number,title --jq ".[] | select(.title | test(\"\\\\[$task_id\\\\]\")) | .number" | head -1
}

# Function to get milestone number by title
get_milestone_number() {
    local milestone_title="$1"
    
    # Get milestone number from GitHub API
    gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq ".[] | select(.title == \"$milestone_title\") | .number" | head -1
}

# Function to get milestone from task ID
get_milestone_from_task_id() {
    local task_id="$1"
    
    # Extract numeric part from task ID (e.g., T001 -> 001)
    local task_num
    task_num=$(echo "$task_id" | sed 's/T0*//')
    
    # Convert to number for comparison
    local num=$((10#$task_num))
    
    # Define milestone task ranges based on project phases
    if [[ $num -ge 1 && $num -le 20 ]] || [[ $num -ge 175 && $num -le 182 ]] || [[ $num -ge 183 && $num -le 190 ]]; then
        echo "M1: MVP Foundation"
    elif [[ $num -ge 21 && $num -le 70 ]]; then
        echo "M2: Core Platform"
    elif [[ $num -ge 71 && $num -le 130 ]] || [[ $num -ge 171 && $num -le 179 ]]; then
        echo "M3: User Experience"
    elif [[ $num -ge 131 && $num -le 160 ]] || [[ $num -eq 165 ]] || [[ $num -eq 180 ]]; then
        echo "M4: Production Ready"
    elif [[ $num -eq 161 ]] || [[ $num -eq 162 ]] || [[ $num -ge 163 && $num -le 164 ]] || [[ $num -eq 166 ]] || [[ $num -ge 167 && $num -le 170 ]] || [[ $num -eq 172 ]] || [[ $num -ge 173 && $num -le 174 ]] || [[ $num -ge 176 && $num -le 177 ]] || [[ $num -eq 178 ]]; then
        echo "M5: Enhancement & Scale"
    else
        echo "unknown"
    fi
}

# Function to get milestone from epic
get_milestone_from_epic() {
    local epic="$1"
    
    case "$epic" in
        "foundation"|"cicd")
            echo "M1: MVP Foundation"
            ;;
        "data-layer"|"core-services")
            echo "M2: Core Platform"
            ;;
        "frontend"|"testing"|"documentation")
            echo "M3: User Experience"
            ;;
        "operations")
            echo "M4: Production Ready"
            ;;
        "experimentation")
            echo "M5: Enhancement & Scale"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function to assign issue to milestone
assign_to_milestone() {
    local issue_number="$1"
    local milestone_title="$2"
    local task_id="$3"
    
    if [[ "$milestone_title" == "unknown" ]]; then
        log_warning "Unknown milestone for task $task_id, skipping"
        return 1
    fi
    
    # Get milestone number
    local milestone_number
    milestone_number=$(get_milestone_number "$milestone_title")
    
    if [[ -z "$milestone_number" ]]; then
        log_warning "Milestone not found: $milestone_title"
        return 1
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would assign issue #$issue_number to milestone: $milestone_title"
        return 0
    fi
    
    log_info "Assigning issue #$issue_number ($task_id) to milestone: $milestone_title"
    
    # Assign issue to milestone using GitHub API
    if gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/issues/"$issue_number" \
        --method PATCH \
        --field milestone="$milestone_number" > /dev/null; then
        log_success "Assigned issue #$issue_number to milestone: $milestone_title"
        return 0
    else
        log_error "Failed to assign issue #$issue_number to milestone: $milestone_title"
        return 1
    fi
}

# Function to create milestone progress comment
create_milestone_comment() {
    local issue_number="$1"
    local milestone_title="$2"
    local task_id="$3"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    
    # Get milestone information
    local milestone_description=""
    local milestone_due_date=""
    
    if command -v yq &> /dev/null && [[ -f "$MILESTONES_CONFIG" ]]; then
        local milestone_num
        milestone_num=$(echo "$milestone_title" | grep -o 'M[0-9]' | sed 's/M//')
        milestone_description=$(yq eval ".milestones[] | select(.number == $milestone_num) | .description" "$MILESTONES_CONFIG" 2>/dev/null || echo "")
        local weeks
        weeks=$(yq eval ".milestones[] | select(.number == $milestone_num) | .weeks" "$MILESTONES_CONFIG" 2>/dev/null || echo "")
        if [[ -n "$weeks" ]]; then
            milestone_due_date="Week $weeks"
        fi
    fi
    
    local comment_body="## 🎯 Milestone Assignment: $milestone_title

**Milestone Description**: $milestone_description

**Target Timeline**: $milestone_due_date

This task is part of milestone **$milestone_title**. Track overall milestone progress by filtering issues with this milestone.

**Milestone Goals**: Ensure this task aligns with the milestone's key deliverables and success criteria.

*Automated milestone assignment by spec-kit*"
    
    # Add comment to issue
    if gh issue comment "$issue_number" --repo "$GITHUB_OWNER/$GITHUB_REPO" --body "$comment_body" 2>/dev/null; then
        log_info "Added milestone comment to issue #$issue_number"
    fi
}

# Function to process all tasks for milestone assignment
process_milestone_assignment() {
    local input_file="$1"
    
    log_info "Processing milestone assignment from: $input_file"
    
    local total_tasks=0
    local assigned_count=0
    local failed_count=0
    local unknown_count=0
    local batch_count=0
    
    # Count total tasks (excluding header)
    total_tasks=$(($(wc -l < "$input_file") - 1))
    
    log_info "Total tasks to process: $total_tasks"
    
    # Process tasks
    local line_count=0
    while IFS=, read -r task_id title component dependencies effort priority epic description spec_name file_path; do
        line_count=$((line_count + 1))
        
        # Skip header
        if [[ $line_count -eq 1 ]]; then
            continue
        fi
        
        # Clean task ID and epic
        local clean_task_id
        clean_task_id=$(echo "$task_id" | sed 's/^"//; s/"$//')
        local clean_epic
        clean_epic=$(echo "$epic" | sed 's/^"//; s/"$//')
        
        # Find corresponding issue
        local issue_number
        issue_number=$(find_issue_number "$clean_task_id")
        
        if [[ -z "$issue_number" ]]; then
            log_warning "Issue not found for task: $clean_task_id"
            failed_count=$((failed_count + 1))
            continue
        fi
        
        # Determine milestone (prefer epic mapping, fallback to task ID)
        local assigned_milestone
        if [[ -n "$clean_epic" ]] && [[ "$clean_epic" != "epic" ]]; then
            assigned_milestone=$(get_milestone_from_epic "$clean_epic")
        fi
        
        if [[ -z "$assigned_milestone" ]] || [[ "$assigned_milestone" == "unknown" ]]; then
            assigned_milestone=$(get_milestone_from_task_id "$clean_task_id")
        fi
        
        # Assign to milestone
        if assign_to_milestone "$issue_number" "$assigned_milestone" "$clean_task_id"; then
            assigned_count=$((assigned_count + 1))
            
            # Add milestone comment
            create_milestone_comment "$issue_number" "$assigned_milestone" "$clean_task_id"
        else
            if [[ "$assigned_milestone" == "unknown" ]]; then
                unknown_count=$((unknown_count + 1))
            else
                failed_count=$((failed_count + 1))
            fi
        fi
        
        batch_count=$((batch_count + 1))
        
        # Rate limiting
        if [[ $batch_count -ge $BATCH_SIZE ]]; then
            log_info "Processed batch of $BATCH_SIZE issues. Pausing for rate limiting..."
            sleep "$RATE_LIMIT_DELAY"
            batch_count=0
        fi
        
        # Progress indicator
        local progress=$((line_count - 1))
        if [[ $((progress % 10)) -eq 0 ]] && [[ $progress -gt 0 ]]; then
            log_info "Progress: $progress/$total_tasks tasks processed"
        fi
        
    done < "$input_file"
    
    # Summary
    echo ""
    log_success "Milestone assignment completed!"
    log_info "Total tasks: $total_tasks"
    log_info "Assigned to milestones: $assigned_count"
    log_info "Failed: $failed_count"
    log_info "Unknown milestone: $unknown_count"
    
    if [[ $((failed_count + unknown_count)) -gt 0 ]]; then
        log_warning "Some issues could not be assigned. Check the output above for details."
    fi
}

# Function to generate milestone report
generate_milestone_report() {
    log_info "Generating milestone assignment report..."
    
    local report_file="${ROOT_DIR}/milestone-assignment-report.md"
    
    cat > "$report_file" << EOF
# Milestone Assignment Report

Generated: $(date)

## Overview

This report shows the distribution of tasks across milestones.

## Milestone Progress

EOF
    
    # Get milestone distribution
    local milestones
    milestones=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq '.[].title' 2>/dev/null || echo "")
    
    if [[ -n "$milestones" ]]; then
        while read -r milestone; do
            if [[ -n "$milestone" ]]; then
                local milestone_number
                milestone_number=$(get_milestone_number "$milestone")
                
                if [[ -n "$milestone_number" ]]; then
                    local milestone_info
                    milestone_info=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones/"$milestone_number" 2>/dev/null)
                    
                    local open_issues
                    open_issues=$(echo "$milestone_info" | jq -r '.open_issues // 0')
                    local closed_issues
                    closed_issues=$(echo "$milestone_info" | jq -r '.closed_issues // 0')
                    local total_issues=$((open_issues + closed_issues))
                    local due_date
                    due_date=$(echo "$milestone_info" | jq -r '.due_on // "No due date"')
                    local completion_percentage=0
                    
                    if [[ $total_issues -gt 0 ]]; then
                        completion_percentage=$((closed_issues * 100 / total_issues))
                    fi
                    
                    cat >> "$report_file" << EOF
### $milestone
- **Total Issues**: $total_issues
- **Open**: $open_issues
- **Closed**: $closed_issues  
- **Progress**: $completion_percentage%
- **Due Date**: $due_date

EOF
                fi
            fi
        done <<< "$milestones"
    else
        echo "No milestones found." >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## Milestone Timeline

\`\`\`
M1: MVP Foundation (Week 4)
    ├── Infrastructure & CI/CD
    └── Basic security & monitoring

M2: Core Platform (Week 10)  
    ├── Data models & database
    └── API endpoints & business logic

M3: User Experience (Week 14)
    ├── Frontend & UI components
    ├── Testing & QA
    └── Documentation

M4: Production Ready (Week 18)
    ├── Deployment & operations
    └── Monitoring & security

M5: Enhancement & Scale (Week 24)
    ├── Analytics & experimentation
    └── Advanced features
\`\`\`

## Critical Path

The critical path for project completion follows the milestone dependencies:
M1 → M2 → M3 → M4 → M5

**Key Dependencies:**
- M2 requires M1 completion (infrastructure must be ready)
- M3 requires M2 completion (frontend needs working APIs)
- M4 requires M3 completion (can't deploy incomplete features)
- M5 builds on stable production platform from M4

## Risk Assessment

### High-Risk Milestones
- **M1**: Infrastructure delays can cascade to all subsequent milestones
- **M2**: API design changes can impact frontend development
- **M4**: Production issues can delay launch significantly

### Mitigation Strategies
- Start infrastructure work early and have contingencies
- Lock API contracts before frontend development begins
- Extensive testing in staging environment before production

## Next Steps

1. Review milestone assignments for accuracy
2. Balance workload across team members within milestones
3. Set up milestone-specific project boards
4. Begin sprint planning within milestone boundaries
5. Monitor milestone progress weekly

---
*Generated by spec-kit milestone assignment automation*
EOF
    
    log_success "Milestone report generated: $report_file"
}

# Function to validate milestone assignments
validate_milestone_assignments() {
    log_info "Validating milestone assignments..."
    
    local total_issues
    total_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --json number | jq length)
    
    local assigned_issues=0
    
    # Get all milestones and count assigned issues
    local milestones
    milestones=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq '.[].number' 2>/dev/null || echo "")
    
    while read -r milestone_num; do
        if [[ -n "$milestone_num" ]]; then
            local milestone_info
            milestone_info=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones/"$milestone_num" 2>/dev/null)
            local milestone_title
            milestone_title=$(echo "$milestone_info" | jq -r '.title')
            local milestone_issues
            milestone_issues=$(echo "$milestone_info" | jq -r '.open_issues + .closed_issues')
            
            assigned_issues=$((assigned_issues + milestone_issues))
            
            if [[ $milestone_issues -gt 0 ]]; then
                log_info "Milestone '$milestone_title': $milestone_issues issues"
            fi
        fi
    done <<< "$milestones"
    
    log_info "Total task issues: $total_issues"
    log_info "Assigned to milestones: $assigned_issues"
    
    if [[ $assigned_issues -eq $total_issues ]]; then
        log_success "All issues successfully assigned to milestones!"
    else
        local unassigned=$((total_issues - assigned_issues))
        log_warning "$unassigned issues not assigned to milestones"
        
        # Show unassigned issues
        if [[ $unassigned -gt 0 ]]; then
            echo ""
            log_info "Unassigned issues:"
            gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --json number,title,milestone | \
            jq -r '.[] | select(.milestone == null) | "  #\(.number) - \(.title)"' | head -10
        fi
    fi
}

# Function to balance milestone workload
balance_milestone_workload() {
    log_info "Analyzing milestone workload balance..."
    
    local milestones
    milestones=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq '.[].number' 2>/dev/null || echo "")
    
    local max_issues=0
    local min_issues=999999
    local total_milestones=0
    
    while read -r milestone_num; do
        if [[ -n "$milestone_num" ]]; then
            local milestone_info
            milestone_info=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones/"$milestone_num" 2>/dev/null)
            local milestone_issues
            milestone_issues=$(echo "$milestone_info" | jq -r '.open_issues + .closed_issues')
            
            if [[ $milestone_issues -gt $max_issues ]]; then
                max_issues=$milestone_issues
            fi
            
            if [[ $milestone_issues -lt $min_issues ]]; then
                min_issues=$milestone_issues
            fi
            
            total_milestones=$((total_milestones + 1))
        fi
    done <<< "$milestones"
    
    local variance=$((max_issues - min_issues))
    local balance_ratio=0
    
    if [[ $max_issues -gt 0 ]]; then
        balance_ratio=$((min_issues * 100 / max_issues))
    fi
    
    echo ""
    log_info "Workload Balance Analysis:"
    log_info "  Max issues in milestone: $max_issues"
    log_info "  Min issues in milestone: $min_issues"
    log_info "  Variance: $variance"
    log_info "  Balance ratio: $balance_ratio%"
    
    if [[ $balance_ratio -lt 70 ]]; then
        log_warning "Significant workload imbalance detected!"
        log_info "Consider redistributing tasks for better milestone balance."
    else
        log_success "Milestone workload is reasonably balanced."
    fi
}

# Main function
main() {
    log_info "Starting GitHub milestone assignment..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Tasks file: $TASKS_FILE"
    log_info "Milestones config: $MILESTONES_CONFIG"
    log_info "Dry run: $DRY_RUN"
    log_info "Batch size: $BATCH_SIZE"
    log_info "Rate limit delay: ${RATE_LIMIT_DELAY}s"
    echo ""
    
    # Process milestone assignments
    process_milestone_assignment "$TASKS_FILE"
    
    # Validate and analyze assignments
    if [[ "$DRY_RUN" != "true" ]]; then
        validate_milestone_assignments
        balance_milestone_workload
        generate_milestone_report
    fi
    
    echo ""
    log_info "Next steps:"
    echo "  1. Review milestone assignments: gh api repos/$GITHUB_OWNER/$GITHUB_REPO/milestones"
    echo "  2. Balance workload if needed"
    echo "  3. Set up milestone project boards"
    echo "  4. Begin sprint planning within milestones"
    echo "  5. Review milestone report: ${ROOT_DIR}/milestone-assignment-report.md"
}

# Help function
show_help() {
    echo "Assign GitHub Issues to Milestones"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -d, --dry-run           Show what would be assigned without making changes"
    echo "  -v, --validate          Validate current milestone assignments and exit"
    echo "  -r, --report            Generate milestone report only"
    echo "  -b, --balance           Analyze milestone workload balance only"
    echo "  --tasks FILE            Specify tasks file (default: ../extracted-tasks.csv)"
    echo "  --milestones FILE       Specify milestones config file (default: ./milestones.yaml)"
    echo "  --batch-size N          Process N issues per batch (default: 5)"
    echo "  --delay N               Delay N seconds between batches (default: 2)"
    echo "  --repo OWNER/REPO       Specify GitHub repository"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_OWNER            GitHub repository owner"
    echo "  GITHUB_REPO             GitHub repository name"
    echo "  BATCH_SIZE              Number of issues per batch"
    echo "  RATE_LIMIT_DELAY        Delay between batches (seconds)"
    echo ""
    echo "This script assigns issues to milestones based on:"
    echo "  • Epic to milestone mapping"
    echo "  • Task ID patterns and ranges"
    echo "  • Milestone configuration from YAML file"
    echo ""
    echo "Milestone Mapping:"
    echo "  • M1: MVP Foundation - Infrastructure, CI/CD (T001-T020, T175-T190)"
    echo "  • M2: Core Platform - Data layer, APIs (T021-T070)"
    echo "  • M3: User Experience - Frontend, Testing, Docs (T071-T130, T171-T179)"
    echo "  • M4: Production Ready - Operations, Deployment (T131-T160)"
    echo "  • M5: Enhancement & Scale - Advanced features (T161-T174)"
    echo ""
    echo "Examples:"
    echo "  $0                              # Assign all issues to milestones"
    echo "  $0 --dry-run                   # Preview assignments"
    echo "  $0 --validate                  # Check current assignments"
    echo "  $0 --balance                   # Analyze workload balance"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN="true"
            shift
            ;;
        -v|--validate)
            check_prerequisites
            validate_milestone_assignments
            exit 0
            ;;
        -r|--report)
            check_prerequisites
            generate_milestone_report
            exit 0
            ;;
        -b|--balance)
            check_prerequisites
            balance_milestone_workload
            exit 0
            ;;
        --tasks)
            TASKS_FILE="$2"
            shift 2
            ;;
        --milestones)
            MILESTONES_CONFIG="$2"
            shift 2
            ;;
        --batch-size)
            BATCH_SIZE="$2"
            shift 2
            ;;
        --delay)
            RATE_LIMIT_DELAY="$2"
            shift 2
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