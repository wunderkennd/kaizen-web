#!/bin/bash

# Assign GitHub Issues to Epics
# This script assigns issues to epics based on task ID patterns and epic configuration

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
EPICS_CONFIG="${SCRIPT_DIR}/epics.yaml"
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

# Function to get epic from task ID using patterns
get_epic_from_task_id() {
    local task_id="$1"
    
    # Extract numeric part from task ID (e.g., T001 -> 001)
    local task_num
    task_num=$(echo "$task_id" | sed 's/T0*//')
    
    # Convert to number for comparison
    local num=$((10#$task_num))
    
    # Define epic task ranges (update these based on your epic organization)
    if [[ $num -ge 1 && $num -le 20 ]] || [[ $num -ge 183 && $num -le 190 ]]; then
        echo "foundation"
    elif [[ $num -ge 21 && $num -le 40 ]]; then
        echo "data-layer"
    elif [[ $num -ge 41 && $num -le 70 ]] || [[ $num -eq 163 ]] || [[ $num -eq 164 ]] || [[ $num -eq 166 ]]; then
        echo "core-services"
    elif [[ $num -ge 71 && $num -le 100 ]] || [[ $num -eq 162 ]] || [[ $num -ge 167 && $num -le 168 ]] || [[ $num -eq 172 ]] || [[ $num -eq 178 ]]; then
        echo "frontend"
    elif [[ $num -ge 101 && $num -le 130 ]]; then
        echo "testing"
    elif [[ $num -ge 131 && $num -le 160 ]] || [[ $num -eq 165 ]] || [[ $num -eq 175 ]] || [[ $num -eq 180 ]]; then
        echo "operations"
    elif [[ $num -ge 175 && $num -le 182 ]]; then
        echo "cicd"
    elif [[ $num -eq 161 ]] || [[ $num -ge 169 && $num -le 170 ]]; then
        echo "experimentation"
    elif [[ $num -eq 171 ]] || [[ $num -ge 173 && $num -le 174 ]] || [[ $num -ge 176 && $num -le 177 ]] || [[ $num -eq 179 ]]; then
        echo "documentation"
    else
        echo "unknown"
    fi
}

# Function to load epic configuration from YAML
load_epic_config() {
    if [[ ! -f "$EPICS_CONFIG" ]]; then
        log_warning "Epic configuration file not found: $EPICS_CONFIG"
        log_info "Using default epic assignment based on task ID patterns"
        return 1
    fi
    
    # Check if yq is available for YAML parsing
    if ! command -v yq &> /dev/null; then
        log_warning "yq not available for YAML parsing. Using default patterns."
        return 1
    fi
    
    return 0
}

# Function to assign epic label to issue
assign_epic_label() {
    local issue_number="$1"
    local epic="$2"
    local task_id="$3"
    
    if [[ "$epic" == "unknown" ]]; then
        log_warning "Unknown epic for task $task_id, skipping"
        return 1
    fi
    
    local epic_label="epic:$epic"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would assign issue #$issue_number to epic: $epic"
        return 0
    fi
    
    log_info "Assigning issue #$issue_number ($task_id) to epic: $epic"
    
    # Add epic label to issue
    if gh issue edit "$issue_number" \
        --repo "$GITHUB_OWNER/$GITHUB_REPO" \
        --add-label "$epic_label" 2>/dev/null; then
        log_success "Assigned issue #$issue_number to epic: $epic"
        return 0
    else
        log_error "Failed to assign issue #$issue_number to epic: $epic"
        return 1
    fi
}

# Function to create epic summary comment
create_epic_summary_comment() {
    local issue_number="$1"
    local epic="$2"
    local task_id="$3"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    
    # Get epic information from config if available
    local epic_description="Part of the $epic epic"
    local epic_goals=""
    
    if command -v yq &> /dev/null && [[ -f "$EPICS_CONFIG" ]]; then
        epic_description=$(yq eval ".epics[] | select(.id == \"$epic\") | .description" "$EPICS_CONFIG" 2>/dev/null || echo "Part of the $epic epic")
        epic_goals=$(yq eval ".epics[] | select(.id == \"$epic\") | .success_criteria[]" "$EPICS_CONFIG" 2>/dev/null | head -3 | sed 's/^/- /')
    fi
    
    local comment_body="## 🎯 Epic Assignment: $epic

**Epic Description**: $epic_description

**Epic Goals**:
$epic_goals

This task contributes to the overall $epic epic. For related tasks and epic progress, search for issues with the \`epic:$epic\` label.

*Automated epic assignment by spec-kit*"
    
    # Add comment to issue
    if gh issue comment "$issue_number" --repo "$GITHUB_OWNER/$GITHUB_REPO" --body "$comment_body" 2>/dev/null; then
        log_info "Added epic summary comment to issue #$issue_number"
    fi
}

# Function to process all tasks for epic assignment
process_epic_assignment() {
    local input_file="$1"
    
    log_info "Processing epic assignment from: $input_file"
    
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
        
        # Clean task ID
        local clean_task_id
        clean_task_id=$(echo "$task_id" | sed 's/^"//; s/"$//')
        
        # Find corresponding issue
        local issue_number
        issue_number=$(find_issue_number "$clean_task_id")
        
        if [[ -z "$issue_number" ]]; then
            log_warning "Issue not found for task: $clean_task_id"
            failed_count=$((failed_count + 1))
            continue
        fi
        
        # Determine epic (use explicit epic from CSV or derive from task ID)
        local assigned_epic
        local csv_epic
        csv_epic=$(echo "$epic" | sed 's/^"//; s/"$//')
        
        if [[ -n "$csv_epic" ]] && [[ "$csv_epic" != "epic" ]]; then
            assigned_epic="$csv_epic"
        else
            assigned_epic=$(get_epic_from_task_id "$clean_task_id")
        fi
        
        # Assign epic
        if assign_epic_label "$issue_number" "$assigned_epic" "$clean_task_id"; then
            assigned_count=$((assigned_count + 1))
            
            # Add epic summary comment
            create_epic_summary_comment "$issue_number" "$assigned_epic" "$clean_task_id"
        else
            if [[ "$assigned_epic" == "unknown" ]]; then
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
    log_success "Epic assignment completed!"
    log_info "Total tasks: $total_tasks"
    log_info "Assigned to epics: $assigned_count"
    log_info "Failed: $failed_count"
    log_info "Unknown epic: $unknown_count"
    
    if [[ $((failed_count + unknown_count)) -gt 0 ]]; then
        log_warning "Some issues could not be assigned. Check the output above for details."
    fi
}

# Function to generate epic report
generate_epic_report() {
    log_info "Generating epic assignment report..."
    
    local report_file="${ROOT_DIR}/epic-assignment-report.md"
    
    cat > "$report_file" << EOF
# Epic Assignment Report

Generated: $(date)

## Overview

This report shows the distribution of tasks across epics.

## Epic Distribution

EOF
    
    # Get epic distribution
    local epics=("foundation" "data-layer" "core-services" "frontend" "testing" "operations" "cicd" "experimentation" "documentation")
    
    for epic in "${epics[@]}"; do
        local epic_issues
        epic_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --label "epic:$epic" --json number,title --jq length 2>/dev/null || echo "0")
        
        echo "### Epic: $epic" >> "$report_file"
        echo "- **Issues**: $epic_issues" >> "$report_file"
        echo "" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Epic Progress Tracking

Use these queries to track epic progress:

EOF
    
    for epic in "${epics[@]}"; do
        echo "- **$epic**: \`label:epic:$epic\`" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Next Steps

1. Review epic assignments for accuracy
2. Assign team members to epic-labeled issues
3. Set up epic-specific project boards
4. Begin sprint planning within epics

---
*Generated by spec-kit epic assignment automation*
EOF
    
    log_success "Epic report generated: $report_file"
}

# Function to validate epic assignments
validate_epic_assignments() {
    log_info "Validating epic assignments..."
    
    local total_issues
    total_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --json number | jq length)
    
    local assigned_issues=0
    local epics=("foundation" "data-layer" "core-services" "frontend" "testing" "operations" "cicd" "experimentation" "documentation")
    
    for epic in "${epics[@]}"; do
        local epic_count
        epic_count=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --label "epic:$epic" --json number | jq length 2>/dev/null || echo "0")
        assigned_issues=$((assigned_issues + epic_count))
        
        if [[ $epic_count -gt 0 ]]; then
            log_info "Epic $epic: $epic_count issues"
        fi
    done
    
    log_info "Total task issues: $total_issues"
    log_info "Assigned to epics: $assigned_issues"
    
    if [[ $assigned_issues -eq $total_issues ]]; then
        log_success "All issues successfully assigned to epics!"
    else
        local unassigned=$((total_issues - assigned_issues))
        log_warning "$unassigned issues not assigned to epics"
    fi
}

# Main function
main() {
    log_info "Starting GitHub epic assignment..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Tasks file: $TASKS_FILE"
    log_info "Epics config: $EPICS_CONFIG"
    log_info "Dry run: $DRY_RUN"
    log_info "Batch size: $BATCH_SIZE"
    log_info "Rate limit delay: ${RATE_LIMIT_DELAY}s"
    echo ""
    
    # Load epic configuration
    load_epic_config
    
    # Process epic assignments
    process_epic_assignment "$TASKS_FILE"
    
    # Validate assignments
    if [[ "$DRY_RUN" != "true" ]]; then
        validate_epic_assignments
        generate_epic_report
    fi
    
    echo ""
    log_info "Next steps:"
    echo "  1. Review epic assignments: gh issue list --repo $GITHUB_OWNER/$GITHUB_REPO --label epic:foundation"
    echo "  2. Assign to milestones: ./04-organization/assign-to-milestones.sh"
    echo "  3. Create epic project boards for better organization"
    echo "  4. Review epic report: ${ROOT_DIR}/epic-assignment-report.md"
}

# Help function
show_help() {
    echo "Assign GitHub Issues to Epics"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -d, --dry-run           Show what would be assigned without making changes"
    echo "  -v, --validate          Validate current epic assignments and exit"
    echo "  -r, --report            Generate epic report only"
    echo "  --tasks FILE            Specify tasks file (default: ../extracted-tasks.csv)"
    echo "  --epics FILE            Specify epics config file (default: ./epics.yaml)"
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
    echo "This script assigns issues to epics based on:"
    echo "  • Task ID patterns (T001-T020 = foundation, etc.)"
    echo "  • Epic specified in tasks CSV file"
    echo "  • Epic configuration from YAML file"
    echo ""
    echo "Epic Categories:"
    echo "  • foundation (T001-T020, T183-T190)"
    echo "  • data-layer (T021-T040)"
    echo "  • core-services (T041-T070, T163-T164, T166)"
    echo "  • frontend (T071-T100, T162, T167-T168, T172, T178)"
    echo "  • testing (T101-T130)"
    echo "  • operations (T131-T160, T165, T175, T180)"
    echo "  • cicd (T175-T182)"
    echo "  • experimentation (T161, T169-T170)"
    echo "  • documentation (T171, T173-T174, T176-T177, T179)"
    echo ""
    echo "Examples:"
    echo "  $0                              # Assign all issues to epics"
    echo "  $0 --dry-run                   # Preview assignments"
    echo "  $0 --validate                  # Check current assignments"
    echo "  $0 --report                    # Generate epic report"
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
            validate_epic_assignments
            exit 0
            ;;
        -r|--report)
            check_prerequisites
            generate_epic_report
            exit 0
            ;;
        --tasks)
            TASKS_FILE="$2"
            shift 2
            ;;
        --epics)
            EPICS_CONFIG="$2"
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