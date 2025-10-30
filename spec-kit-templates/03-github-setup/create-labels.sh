#!/bin/bash

# Create GitHub Labels for Project Organization
# This script creates all necessary labels for epic, priority, size, and status tracking

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
FORCE_UPDATE="${FORCE_UPDATE:-false}"
DRY_RUN="${DRY_RUN:-false}"

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

# Function to create or update a label
create_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create label: $name ($color) - $description"
        return 0
    fi
    
    # Check if label exists
    if gh label list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "$name" --json name --jq '.[].name' | grep -q "^$name$"; then
        if [[ "$FORCE_UPDATE" == "true" ]]; then
            log_info "Updating existing label: $name"
            if gh label edit "$name" --repo "$GITHUB_OWNER/$GITHUB_REPO" --color "$color" --description "$description" 2>/dev/null; then
                log_success "Updated label: $name"
            else
                log_warning "Failed to update label: $name"
            fi
        else
            log_info "Label already exists: $name (use --force to update)"
        fi
    else
        log_info "Creating label: $name"
        if gh label create "$name" --repo "$GITHUB_OWNER/$GITHUB_REPO" --color "$color" --description "$description" 2>/dev/null; then
            log_success "Created label: $name"
        else
            log_error "Failed to create label: $name"
        fi
    fi
}

# Function to create epic labels
create_epic_labels() {
    log_info "Creating epic labels..."
    
    # Epic labels with colors
    create_label "epic:foundation" "0052cc" "Foundation & Infrastructure"
    create_label "epic:data-layer" "5319e7" "Data Layer & Models"
    create_label "epic:core-services" "b60205" "Core Services & API"
    create_label "epic:frontend" "f9d0c4" "Frontend & UI"
    create_label "epic:testing" "1d76db" "Testing & QA"
    create_label "epic:cicd" "006b75" "CI/CD & DevOps"
    create_label "epic:operations" "fbca04" "Platform Operations"
    create_label "epic:experimentation" "c5def5" "Experimentation & Analytics"
    create_label "epic:documentation" "7057ff" "Documentation & Training"
    
    log_success "Epic labels created"
}

# Function to create priority labels
create_priority_labels() {
    log_info "Creating priority labels..."
    
    create_label "P0-critical" "d73a4a" "Critical Priority - Must have"
    create_label "P1-high" "e99695" "High Priority - Should have"
    create_label "P2-medium" "fef2c0" "Medium Priority - Nice to have"
    create_label "P3-low" "c2e0c6" "Low Priority - Future consideration"
    
    log_success "Priority labels created"
}

# Function to create size labels
create_size_labels() {
    log_info "Creating size labels..."
    
    create_label "size:XS" "ffffff" "1-2 story points"
    create_label "size:S" "c2e0c6" "3-5 story points"
    create_label "size:M" "fef2c0" "5-8 story points"
    create_label "size:L" "f9d0c4" "8-13 story points"
    create_label "size:XL" "e99695" "13+ story points"
    
    log_success "Size labels created"
}

# Function to create status labels
create_status_labels() {
    log_info "Creating status labels..."
    
    create_label "status:ready" "0e8a16" "Ready to start"
    create_label "status:in-progress" "fbca04" "Currently being worked on"
    create_label "status:review" "7057ff" "In review/testing"
    create_label "status:blocked" "d73a4a" "Blocked by dependency or issue"
    create_label "status:on-hold" "fef2c0" "On hold - not active"
    create_label "status:needs-info" "e99695" "Needs more information"
    
    log_success "Status labels created"
}

# Function to create type labels
create_type_labels() {
    log_info "Creating type labels..."
    
    create_label "type:feature" "0052cc" "New feature"
    create_label "type:bug" "d73a4a" "Bug fix"
    create_label "type:enhancement" "5319e7" "Enhancement to existing feature"
    create_label "type:refactor" "1d76db" "Code refactoring"
    create_label "type:documentation" "7057ff" "Documentation update"
    create_label "type:test" "c5def5" "Test addition or improvement"
    create_label "type:chore" "fef2c0" "Maintenance task"
    
    log_success "Type labels created"
}

# Function to create component labels
create_component_labels() {
    log_info "Creating component labels..."
    
    create_label "component:frontend" "f9d0c4" "Frontend components"
    create_label "component:backend" "b60205" "Backend services"
    create_label "component:database" "5319e7" "Database related"
    create_label "component:api" "0052cc" "API endpoints"
    create_label "component:auth" "d73a4a" "Authentication/Authorization"
    create_label "component:infrastructure" "006b75" "Infrastructure/DevOps"
    create_label "component:security" "d73a4a" "Security related"
    create_label "component:performance" "fbca04" "Performance optimization"
    create_label "component:ui-ux" "f9d0c4" "User Interface/Experience"
    
    log_success "Component labels created"
}

# Function to create workflow labels
create_workflow_labels() {
    log_info "Creating workflow labels..."
    
    create_label "needs-design" "7057ff" "Needs design work"
    create_label "needs-review" "0e8a16" "Ready for review"
    create_label "needs-testing" "1d76db" "Needs testing"
    create_label "breaking-change" "d73a4a" "Breaking change"
    create_label "good-first-issue" "0e8a16" "Good for newcomers"
    create_label "help-wanted" "fbca04" "Extra attention is needed"
    create_label "duplicate" "cfd3d7" "This issue or pull request already exists"
    create_label "wontfix" "ffffff" "This will not be worked on"
    create_label "invalid" "e4e669" "This doesn't seem right"
    
    log_success "Workflow labels created"
}

# Function to list existing labels
list_labels() {
    log_info "Listing existing labels in $GITHUB_OWNER/$GITHUB_REPO:"
    echo ""
    
    gh label list --repo "$GITHUB_OWNER/$GITHUB_REPO" --json name,color,description | \
    jq -r '.[] | "  \(.name) (#\(.color)) - \(.description)"' | \
    sort
    
    echo ""
    local total_labels
    total_labels=$(gh label list --repo "$GITHUB_OWNER/$GITHUB_REPO" --json name | jq length)
    log_info "Total labels: $total_labels"
}

# Function to delete labels (for cleanup)
delete_label() {
    local name="$1"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would delete label: $name"
        return 0
    fi
    
    if gh label list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "$name" --json name --jq '.[].name' | grep -q "^$name$"; then
        log_info "Deleting label: $name"
        if gh label delete "$name" --repo "$GITHUB_OWNER/$GITHUB_REPO" --yes 2>/dev/null; then
            log_success "Deleted label: $name"
        else
            log_warning "Failed to delete label: $name"
        fi
    else
        log_info "Label does not exist: $name"
    fi
}

# Function to clean up default GitHub labels
cleanup_default_labels() {
    log_info "Cleaning up default GitHub labels..."
    
    local default_labels=("bug" "documentation" "duplicate" "enhancement" "good first issue" "help wanted" "invalid" "question" "wontfix")
    
    for label in "${default_labels[@]}"; do
        delete_label "$label"
    done
    
    log_success "Default label cleanup completed"
}

# Main function
main() {
    log_info "Starting GitHub label creation..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Force update: $FORCE_UPDATE"
    log_info "Dry run: $DRY_RUN"
    echo ""
    
    # Create all label categories
    create_epic_labels
    create_priority_labels
    create_size_labels
    create_status_labels
    create_type_labels
    create_component_labels
    create_workflow_labels
    
    echo ""
    log_success "GitHub labels created successfully!"
    
    # Show summary
    local total_labels
    if [[ "$DRY_RUN" != "true" ]]; then
        total_labels=$(gh label list --repo "$GITHUB_OWNER/$GITHUB_REPO" --json name | jq length)
        log_info "Total labels in repository: $total_labels"
    fi
    
    echo ""
    log_info "Label categories created:"
    echo "  • Epic labels (9): For organizing tasks by architectural area"
    echo "  • Priority labels (4): P0-P3 for task prioritization"
    echo "  • Size labels (5): XS-XL for effort estimation"
    echo "  • Status labels (6): For workflow state tracking"
    echo "  • Type labels (7): For categorizing work type"
    echo "  • Component labels (9): For system component organization"
    echo "  • Workflow labels (9): For process management"
    
    echo ""
    log_info "Next steps:"
    echo "  1. Review labels: gh label list --repo $GITHUB_OWNER/$GITHUB_REPO"
    echo "  2. Create milestones: ./03-github-setup/create-milestones.sh"
    echo "  3. Create issues: ./03-github-setup/create-issues.sh"
}

# Help function
show_help() {
    echo "Create GitHub Labels for Project Organization"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -f, --force         Force update existing labels"
    echo "  -d, --dry-run       Show what would be created without making changes"
    echo "  -l, --list          List existing labels and exit"
    echo "  -c, --cleanup       Clean up default GitHub labels"
    echo "  --repo OWNER/REPO   Specify GitHub repository"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_OWNER        GitHub repository owner"
    echo "  GITHUB_REPO         GitHub repository name"
    echo ""
    echo "This script creates comprehensive labels for:"
    echo "  • Epics (epic:*)"
    echo "  • Priorities (P0-P3)"
    echo "  • Sizes (size:XS-XL)"
    echo "  • Status (status:*)"
    echo "  • Types (type:*)"
    echo "  • Components (component:*)"
    echo "  • Workflow (various)"
    echo ""
    echo "Examples:"
    echo "  $0                                 # Create all labels"
    echo "  $0 --dry-run                       # Preview changes"
    echo "  $0 --force                         # Update existing labels"
    echo "  $0 --repo myorg/myrepo             # Specify repository"
    echo "  $0 --list                          # List current labels"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE_UPDATE="true"
            shift
            ;;
        -d|--dry-run)
            DRY_RUN="true"
            shift
            ;;
        -l|--list)
            check_prerequisites
            list_labels
            exit 0
            ;;
        -c|--cleanup)
            check_prerequisites
            cleanup_default_labels
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