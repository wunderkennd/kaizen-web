#!/bin/bash

# Enrich GitHub Issues with Enhanced Context and Relationships
# This script updates existing issues with additional context, dependencies, and metadata

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
CREATED_ISSUES_FILE="${ROOT_DIR}/created-issues.csv"
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

# Function to clean and escape text
clean_text() {
    local text="$1"
    echo "$text" | sed 's/^"//; s/"$//' | sed 's/"/\\"/g'
}

# Function to find issue number by task ID
find_issue_number() {
    local task_id="$1"
    
    # Search for issues with the task ID in title
    gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "$task_id in:title" --json number,title --jq ".[] | select(.title | test(\"\\\\[$task_id\\\\]\")) | .number" | head -1
}

# Function to get task dependencies
get_task_dependencies() {
    local task_id="$1"
    local dependencies_string="$2"
    
    # Clean dependencies string
    dependencies_string=$(clean_text "$dependencies_string")
    
    # Handle "None" or empty dependencies
    if [[ "$dependencies_string" == "None" ]] || [[ "$dependencies_string" == "none" ]] || [[ -z "$dependencies_string" ]]; then
        echo ""
        return 0
    fi
    
    # Extract task IDs and find corresponding issue numbers
    local dep_issues=()
    while read -r dep_task; do
        if [[ -n "$dep_task" ]]; then
            local dep_issue_num
            dep_issue_num=$(find_issue_number "$dep_task")
            if [[ -n "$dep_issue_num" ]]; then
                dep_issues+=("#$dep_issue_num")
            else
                dep_issues+=("$dep_task (not found)")
            fi
        fi
    done < <(echo "$dependencies_string" | tr ',' '\n' | grep -o 'T[0-9]\+' | sort -u)
    
    # Join with commas
    IFS=', '
    echo "${dep_issues[*]}"
}

# Function to get related tasks in same epic
get_related_epic_tasks() {
    local current_task_id="$1"
    local epic="$2"
    
    local epic_clean
    epic_clean=$(clean_text "$epic")
    
    # Find other tasks in the same epic
    local related_issues=()
    while IFS=, read -r task_id title component dependencies effort priority task_epic description spec_name file_path; do
        # Skip header and current task
        if [[ "$task_id" == "task_id" ]] || [[ "$task_id" == "\"$current_task_id\"" ]]; then
            continue
        fi
        
        local other_epic
        other_epic=$(clean_text "$task_epic")
        
        if [[ "$other_epic" == "$epic_clean" ]]; then
            local other_task_id
            other_task_id=$(clean_text "$task_id")
            local issue_num
            issue_num=$(find_issue_number "$other_task_id")
            if [[ -n "$issue_num" ]]; then
                local other_title
                other_title=$(clean_text "$title")
                related_issues+=("#$issue_num ($other_task_id: $other_title)")
            fi
        fi
    done < "$TASKS_FILE"
    
    # Return first 5 related issues
    printf '%s\n' "${related_issues[@]}" | head -5
}

# Function to generate technical context based on component
generate_technical_context() {
    local component="$1"
    local epic="$2"
    
    component=$(clean_text "$component")
    epic=$(clean_text "$epic")
    
    case "$component" in
        *"Frontend"*|*"UI"*|*"React"*|*"Vue"*)
            echo "### Frontend Implementation
- Consider component reusability and state management
- Implement responsive design for mobile compatibility
- Follow accessibility guidelines (ARIA, semantic HTML)
- Integrate with design system and component library
- Handle error states and loading indicators"
            ;;
        *"Backend"*|*"API"*|*"Service"*)
            echo "### Backend Implementation
- Design RESTful API endpoints following OpenAPI specification
- Implement proper error handling and status codes
- Add input validation and sanitization
- Consider database transaction boundaries
- Include proper logging and monitoring"
            ;;
        *"Database"*|*"Data"*)
            echo "### Database Implementation
- Design normalized database schema
- Consider indexing strategy for performance
- Implement proper constraints and relationships
- Plan for data migration and versioning
- Add backup and recovery considerations"
            ;;
        *"Authentication"*|*"Auth"*|*"Security"*)
            echo "### Security Implementation
- Follow OWASP security guidelines
- Implement proper session management
- Add rate limiting and DDoS protection
- Consider multi-factor authentication
- Audit logging for security events"
            ;;
        *"Infrastructure"*|*"DevOps"*|*"Deploy"*)
            echo "### Infrastructure Implementation
- Use Infrastructure as Code (IaC) principles
- Implement blue-green or rolling deployment strategy
- Set up monitoring and alerting
- Consider auto-scaling and load balancing
- Plan for disaster recovery and backups"
            ;;
        *)
            echo "### Implementation Notes
- Follow project coding standards and conventions
- Consider performance implications and optimization
- Implement proper error handling and logging
- Add comprehensive unit and integration tests
- Document API changes and breaking changes"
            ;;
    esac
}

# Function to generate enhanced issue body
generate_enhanced_issue_body() {
    local task_id="$1"
    local title="$2"
    local component="$3"
    local dependencies="$4"
    local effort="$5"
    local priority="$6"
    local epic="$7"
    local description="$8"
    local spec_name="$9"
    
    # Clean inputs
    title=$(clean_text "$title")
    component=$(clean_text "$component")
    description=$(clean_text "$description")
    epic=$(clean_text "$epic")
    
    # Get dependency information
    local dep_issues
    dep_issues=$(get_task_dependencies "$task_id" "$dependencies")
    
    # Get related tasks in same epic
    local related_tasks
    related_tasks=$(get_related_epic_tasks "$task_id" "$epic")
    
    # Generate technical context
    local tech_context
    tech_context=$(generate_technical_context "$component" "$epic")
    
    # Format dependencies
    local deps_section=""
    if [[ -n "$dep_issues" ]]; then
        deps_section="### Dependencies
This task depends on:
$dep_issues

**Note**: Ensure dependent tasks are completed before starting this task."
    else
        deps_section="### Dependencies
This task has no dependencies and can be started immediately."
    fi
    
    # Format related tasks
    local related_section=""
    if [[ -n "$related_tasks" ]]; then
        related_section="### Related Tasks in Epic: $epic
$(echo "$related_tasks" | sed 's/^/- /')"
    else
        related_section="### Related Tasks
No directly related tasks found in this epic."
    fi
    
    cat << EOF
# Task $task_id: $title

## 📋 Overview
**Epic**: $epic  
**Component**: $component  
**Effort**: $effort story points  
**Priority**: $priority  

$deps_section

## 📝 Description
$description

## 👤 User Story
As a [role], I want [functionality] so that [benefit].

*Please update this section with specific user story details based on the task requirements.*

## ✅ Acceptance Criteria
- [ ] **Functional**: Core functionality works as specified
- [ ] **Quality**: Code meets quality standards and passes review
- [ ] **Testing**: Comprehensive tests written and passing
- [ ] **Documentation**: Updated documentation and comments
- [ ] **Integration**: Successfully integrates with existing system

*Please expand with specific, testable criteria for this task.*

## 🔧 Technical Implementation

$tech_context

### Architecture Considerations
- [ ] Design reviewed and approved by technical lead
- [ ] Integration points identified and documented
- [ ] Performance requirements understood
- [ ] Security implications assessed

### Implementation Checklist
- [ ] Development environment setup
- [ ] Code implementation completed
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests added
- [ ] Code review completed
- [ ] Documentation updated

## 🧪 Testing & Validation

### Test Cases
- [ ] **Happy Path**: Normal usage scenarios work correctly
- [ ] **Edge Cases**: Boundary conditions handled properly
- [ ] **Error Cases**: Error conditions handled gracefully
- [ ] **Performance**: Meets performance requirements
- [ ] **Security**: Security requirements validated

### Quality Gates
- [ ] All tests passing in CI/CD pipeline
- [ ] Code coverage meets threshold (>80%)
- [ ] Static analysis passes (no critical issues)
- [ ] Performance benchmarks met
- [ ] Security scan completed

## 📚 Resources & Documentation

### Technical Resources
- [Architecture Documentation](link-to-docs)
- [API Specification](link-to-api-docs)
- [Component Documentation](link-to-component-docs)

### Design Resources
- [UI/UX Designs](link-to-designs) (if applicable)
- [Technical Specifications](link-to-tech-specs)
- [Database Schema](link-to-schema) (if applicable)

## 🔗 Issue Relationships

$related_section

### Epic Progress
Track overall progress of the **$epic** epic to understand how this task fits into the bigger picture.

## 📈 Definition of Done
- [ ] **Implementation**: All acceptance criteria met
- [ ] **Code Quality**: Code reviewed and approved
- [ ] **Testing**: All tests written and passing
- [ ] **Documentation**: Documentation updated
- [ ] **Integration**: Successfully integrated and deployed to staging
- [ ] **Validation**: QA validation completed
- [ ] **Deployment**: Ready for production deployment

## 📊 Effort Breakdown
**Total Effort**: $effort story points

Estimated breakdown:
- Analysis & Design: 20%
- Implementation: 50%
- Testing: 20%
- Documentation & Review: 10%

## 🏷️ Labels Applied
- **Epic**: epic:$epic
- **Priority**: $priority
- **Size**: Based on $effort story points
- **Component**: component:$component
- **Status**: status:ready

---
**Specification**: $spec_name  
**Task ID**: $task_id  
**Last Updated**: $(date)  
*Enhanced by spec-kit enrichment automation*
EOF
}

# Function to enrich a single issue
enrich_issue() {
    local task_id="$1"
    local title="$2"
    local component="$3"
    local dependencies="$4"
    local effort="$5"
    local priority="$6"
    local epic="$7"
    local description="$8"
    local spec_name="$9"
    
    # Find issue number
    local issue_number
    issue_number=$(find_issue_number "$task_id")
    
    if [[ -z "$issue_number" ]]; then
        log_warning "Issue not found for task: $task_id"
        return 1
    fi
    
    local clean_title
    clean_title=$(clean_text "$title")
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would enrich issue #$issue_number: $task_id - $clean_title"
        return 0
    fi
    
    log_info "Enriching issue #$issue_number: $task_id - $clean_title"
    
    # Generate enhanced body
    local enhanced_body
    enhanced_body=$(generate_enhanced_issue_body "$task_id" "$title" "$component" "$dependencies" "$effort" "$priority" "$epic" "$description" "$spec_name")
    
    # Update the issue
    if gh issue edit "$issue_number" \
        --repo "$GITHUB_OWNER/$GITHUB_REPO" \
        --body "$enhanced_body" 2>/dev/null; then
        log_success "Enriched issue #$issue_number: $task_id"
        return 0
    else
        log_error "Failed to enrich issue #$issue_number: $task_id"
        return 1
    fi
}

# Function to process all tasks for enrichment
process_enrichment() {
    local input_file="$1"
    
    log_info "Processing task enrichment from: $input_file"
    
    local total_tasks=0
    local enriched_count=0
    local failed_count=0
    local batch_count=0
    
    # Count total tasks (excluding header)
    total_tasks=$(($(wc -l < "$input_file") - 1))
    
    log_info "Total tasks to enrich: $total_tasks"
    
    # Process tasks
    local line_count=0
    while IFS=, read -r task_id title component dependencies effort priority epic description spec_name file_path; do
        line_count=$((line_count + 1))
        
        # Skip header
        if [[ $line_count -eq 1 ]]; then
            continue
        fi
        
        # Enrich issue
        if enrich_issue "$task_id" "$title" "$component" "$dependencies" "$effort" "$priority" "$epic" "$description" "$spec_name"; then
            enriched_count=$((enriched_count + 1))
        else
            failed_count=$((failed_count + 1))
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
    log_success "Issue enrichment completed!"
    log_info "Total tasks: $total_tasks"
    log_info "Enriched: $enriched_count"
    log_info "Failed: $failed_count"
    
    if [[ $failed_count -gt 0 ]]; then
        log_warning "Some issues failed to enrich. Check the output above for details."
    fi
}

# Function to add dependency comments
add_dependency_comments() {
    log_info "Adding dependency relationship comments..."
    
    local comment_count=0
    
    # Process each task to add dependency comments
    while IFS=, read -r task_id title component dependencies effort priority epic description spec_name file_path; do
        # Skip header
        if [[ "$task_id" == "task_id" ]]; then
            continue
        fi
        
        local clean_dependencies
        clean_dependencies=$(clean_text "$dependencies")
        
        # Skip if no dependencies
        if [[ "$clean_dependencies" == "None" ]] || [[ "$clean_dependencies" == "none" ]] || [[ -z "$clean_dependencies" ]]; then
            continue
        fi
        
        local issue_number
        issue_number=$(find_issue_number "$(clean_text "$task_id")")
        
        if [[ -z "$issue_number" ]]; then
            continue
        fi
        
        # Find dependency issue numbers
        local dep_refs=()
        while read -r dep_task; do
            if [[ -n "$dep_task" ]]; then
                local dep_issue_num
                dep_issue_num=$(find_issue_number "$dep_task")
                if [[ -n "$dep_issue_num" ]]; then
                    dep_refs+=("#$dep_issue_num")
                fi
            fi
        done < <(echo "$clean_dependencies" | tr ',' '\n' | grep -o 'T[0-9]\+')
        
        # Add comment if dependencies found
        if [[ ${#dep_refs[@]} -gt 0 ]]; then
            local comment_body="🔗 **Dependency Notice**

This task depends on: ${dep_refs[*]}

Please ensure the dependent tasks are completed before starting work on this issue.

*Automated dependency tracking by spec-kit*"
            
            if [[ "$DRY_RUN" != "true" ]]; then
                if gh issue comment "$issue_number" --repo "$GITHUB_OWNER/$GITHUB_REPO" --body "$comment_body" 2>/dev/null; then
                    comment_count=$((comment_count + 1))
                fi
            fi
        fi
        
    done < "$TASKS_FILE"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        log_success "Added $comment_count dependency comments"
    else
        log_info "[DRY RUN] Would add dependency comments"
    fi
}

# Main function
main() {
    log_info "Starting GitHub issue enrichment..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Tasks file: $TASKS_FILE"
    log_info "Dry run: $DRY_RUN"
    log_info "Batch size: $BATCH_SIZE"
    log_info "Rate limit delay: ${RATE_LIMIT_DELAY}s"
    echo ""
    
    # Process enrichment
    process_enrichment "$TASKS_FILE"
    
    # Add dependency comments
    add_dependency_comments
    
    echo ""
    log_info "Next steps:"
    echo "  1. Review enriched issues: gh issue list --repo $GITHUB_OWNER/$GITHUB_REPO"
    echo "  2. Assign to epics: ./04-organization/assign-to-epics.sh"
    echo "  3. Assign to milestones: ./04-organization/assign-to-milestones.sh"
    echo "  4. Update acceptance criteria and user stories as needed"
}

# Help function
show_help() {
    echo "Enrich GitHub Issues with Enhanced Context and Relationships"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -d, --dry-run           Show what would be updated without making changes"
    echo "  --deps-only             Only add dependency comments"
    echo "  --tasks FILE            Specify tasks file (default: ../extracted-tasks.csv)"
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
    echo "This script enhances GitHub issues with:"
    echo "  • Detailed technical implementation context"
    echo "  • Dependency relationships and links"
    echo "  • Related tasks in the same epic"
    echo "  • Comprehensive acceptance criteria"
    echo "  • Definition of done checklists"
    echo "  • Testing and validation requirements"
    echo ""
    echo "Examples:"
    echo "  $0                              # Enrich all issues"
    echo "  $0 --dry-run                   # Preview changes"
    echo "  $0 --deps-only                 # Only add dependency comments"
    echo "  $0 --batch-size 3 --delay 3   # Slower processing"
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
        --deps-only)
            check_prerequisites
            add_dependency_comments
            exit 0
            ;;
        --tasks)
            TASKS_FILE="$2"
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