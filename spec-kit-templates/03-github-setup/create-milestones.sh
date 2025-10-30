#!/bin/bash

# Create GitHub Milestones for Project Planning
# This script creates time-boxed milestones based on project timeline

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
PROJECT_START_DATE="${PROJECT_START_DATE:-$(date +%Y-%m-%d)}"
DRY_RUN="${DRY_RUN:-false}"
MILESTONES_CONFIG="${ROOT_DIR}/04-organization/milestones.yaml"

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

# Function to calculate date from start date
calculate_date() {
    local weeks="$1"
    local start_date="$2"
    
    # Use different date command based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -j -f "%Y-%m-%d" -v +"${weeks}w" "$start_date" "+%Y-%m-%dT23:59:59Z"
    else
        # Linux
        date -d "$start_date + $weeks weeks" "+%Y-%m-%dT23:59:59Z"
    fi
}

# Function to create a milestone
create_milestone() {
    local title="$1"
    local description="$2"
    local due_date="$3"
    local state="${4:-open}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create milestone: $title (due: $due_date)"
        return 0
    fi
    
    log_info "Creating milestone: $title"
    
    # Check if milestone already exists
    if gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq '.[].title' | grep -q "^$title$"; then
        log_warning "Milestone already exists: $title"
        return 0
    fi
    
    # Create milestone using GitHub API
    local milestone_data
    milestone_data=$(cat << EOF
{
  "title": "$title",
  "description": "$description",
  "due_on": "$due_date",
  "state": "$state"
}
EOF
    )
    
    if gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones \
        --method POST \
        --input - <<< "$milestone_data" > /dev/null; then
        log_success "Created milestone: $title"
        return 0
    else
        log_error "Failed to create milestone: $title"
        return 1
    fi
}

# Function to create default milestones
create_default_milestones() {
    log_info "Creating default project milestones..."
    
    local start_date="$PROJECT_START_DATE"
    
    # Milestone 1: MVP Foundation (4 weeks)
    local m1_date
    m1_date=$(calculate_date 4 "$start_date")
    create_milestone \
        "M1: MVP Foundation" \
        "Infrastructure setup, development environment, and basic CI/CD pipeline. Core foundation for all subsequent development." \
        "$m1_date"
    
    # Milestone 2: Core Platform (10 weeks)
    local m2_date
    m2_date=$(calculate_date 10 "$start_date")
    create_milestone \
        "M2: Core Platform" \
        "Core business logic implementation, data models, and essential API endpoints. Backend services foundation." \
        "$m2_date"
    
    # Milestone 3: User Experience (14 weeks)
    local m3_date
    m3_date=$(calculate_date 14 "$start_date")
    create_milestone \
        "M3: User Experience" \
        "Complete frontend implementation, user interfaces, and end-to-end user flows with comprehensive testing." \
        "$m3_date"
    
    # Milestone 4: Production Ready (18 weeks)
    local m4_date
    m4_date=$(calculate_date 18 "$start_date")
    create_milestone \
        "M4: Production Ready" \
        "Production deployment, monitoring, security hardening, and operational procedures. Ready for launch." \
        "$m4_date"
    
    # Milestone 5: Enhancement & Scale (24 weeks)
    local m5_date
    m5_date=$(calculate_date 24 "$start_date")
    create_milestone \
        "M5: Enhancement & Scale" \
        "Advanced features, performance optimization, A/B testing, and machine learning capabilities." \
        "$m5_date"
    
    log_success "Default milestones created"
}

# Function to create milestones from YAML config
create_milestones_from_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_warning "Milestones config file not found: $config_file"
        log_info "Using default milestones instead..."
        create_default_milestones
        return 0
    fi
    
    log_info "Creating milestones from config: $config_file"
    
    # Check if yq is available for YAML parsing
    if ! command -v yq &> /dev/null; then
        log_warning "yq not available for YAML parsing. Using default milestones."
        create_default_milestones
        return 0
    fi
    
    # Parse YAML and create milestones
    local milestone_count
    milestone_count=$(yq eval '.milestones | length' "$config_file" 2>/dev/null || echo "0")
    
    if [[ "$milestone_count" -eq 0 ]]; then
        log_warning "No milestones found in config file. Using defaults."
        create_default_milestones
        return 0
    fi
    
    for ((i=0; i<milestone_count; i++)); do
        local title
        title=$(yq eval ".milestones[$i].title" "$config_file" 2>/dev/null || echo "")
        local description
        description=$(yq eval ".milestones[$i].description" "$config_file" 2>/dev/null || echo "")
        local weeks
        weeks=$(yq eval ".milestones[$i].weeks" "$config_file" 2>/dev/null || echo "")
        
        if [[ -n "$title" ]] && [[ -n "$weeks" ]]; then
            local due_date
            due_date=$(calculate_date "$weeks" "$PROJECT_START_DATE")
            create_milestone "$title" "$description" "$due_date"
        else
            log_warning "Incomplete milestone data at index $i"
        fi
    done
    
    log_success "Milestones created from config"
}

# Function to list existing milestones
list_milestones() {
    log_info "Listing existing milestones in $GITHUB_OWNER/$GITHUB_REPO:"
    echo ""
    
    local milestones
    milestones=$(gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --jq '.[] | {number: .number, title: .title, state: .state, due_on: .due_on, open_issues: .open_issues, closed_issues: .closed_issues}')
    
    if [[ -n "$milestones" ]]; then
        echo "$milestones" | jq -r '. | "  #\(.number) - \(.title) (\(.state))"'
        echo ""
        echo "$milestones" | jq -r '. | "    Due: \(.due_on // "No due date") | Issues: \(.open_issues) open, \(.closed_issues) closed"'
        echo ""
        
        local total_milestones
        total_milestones=$(echo "$milestones" | jq -s length)
        log_info "Total milestones: $total_milestones"
    else
        log_info "No milestones found"
    fi
}

# Function to update milestone
update_milestone() {
    local milestone_number="$1"
    local title="$2"
    local description="$3"
    local due_date="$4"
    local state="${5:-open}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would update milestone #$milestone_number: $title"
        return 0
    fi
    
    log_info "Updating milestone #$milestone_number: $title"
    
    local milestone_data
    milestone_data=$(cat << EOF
{
  "title": "$title",
  "description": "$description",
  "due_on": "$due_date",
  "state": "$state"
}
EOF
    )
    
    if gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones/"$milestone_number" \
        --method PATCH \
        --input - <<< "$milestone_data" > /dev/null; then
        log_success "Updated milestone #$milestone_number: $title"
        return 0
    else
        log_error "Failed to update milestone #$milestone_number: $title"
        return 1
    fi
}

# Function to delete milestone
delete_milestone() {
    local milestone_number="$1"
    local title="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would delete milestone #$milestone_number: $title"
        return 0
    fi
    
    log_warning "Deleting milestone #$milestone_number: $title"
    
    if gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones/"$milestone_number" \
        --method DELETE > /dev/null; then
        log_success "Deleted milestone #$milestone_number: $title"
        return 0
    else
        log_error "Failed to delete milestone #$milestone_number: $title"
        return 1
    fi
}

# Function to generate milestone timeline
generate_timeline() {
    log_info "Generating milestone timeline..."
    
    local timeline_file="${ROOT_DIR}/milestone-timeline.md"
    
    cat > "$timeline_file" << EOF
# Project Milestone Timeline

Generated: $(date)
Project Start Date: $PROJECT_START_DATE

## Milestone Schedule

EOF
    
    # Add default milestones to timeline
    local milestones=(
        "M1: MVP Foundation|4|Infrastructure setup and development environment"
        "M2: Core Platform|10|Core business logic and API development"
        "M3: User Experience|14|Frontend implementation and user flows"
        "M4: Production Ready|18|Deployment and operational readiness"
        "M5: Enhancement & Scale|24|Advanced features and optimization"
    )
    
    for milestone in "${milestones[@]}"; do
        IFS='|' read -r title weeks description <<< "$milestone"
        local due_date
        due_date=$(calculate_date "$weeks" "$PROJECT_START_DATE" | cut -d'T' -f1)
        
        cat >> "$timeline_file" << EOF
### $title
- **Timeline**: Week $weeks
- **Due Date**: $due_date
- **Description**: $description

EOF
    done
    
    cat >> "$timeline_file" << EOF

## Timeline Visualization

\`\`\`
Week:  0    4    8   12   16   20   24
       |    |    |    |    |    |    |
Start  M1   |    |    M3   |    |    M5
            |    M2   |    M4   |
            |         |         |
\`\`\`

## Key Deliverables by Milestone

### M1: MVP Foundation (Week 4)
- [ ] Repository setup and CI/CD pipeline
- [ ] Development environment configuration
- [ ] Database infrastructure
- [ ] Basic security measures
- [ ] Testing framework setup

### M2: Core Platform (Week 10)
- [ ] Data models and database schema
- [ ] Authentication and authorization
- [ ] Core API endpoints
- [ ] Business logic implementation
- [ ] Data validation and caching

### M3: User Experience (Week 14)
- [ ] Complete UI component library
- [ ] User authentication flows
- [ ] Main application features
- [ ] Responsive design
- [ ] End-to-end testing

### M4: Production Ready (Week 18)
- [ ] Production deployment setup
- [ ] Monitoring and alerting
- [ ] Security hardening
- [ ] Performance optimization
- [ ] Documentation and runbooks

### M5: Enhancement & Scale (Week 24)
- [ ] Advanced analytics
- [ ] A/B testing framework
- [ ] Machine learning features
- [ ] Performance scaling
- [ ] Future roadmap planning

---

*Generated by spec-kit milestone planner*
EOF
    
    log_success "Timeline generated: $timeline_file"
}

# Main function
main() {
    log_info "Starting GitHub milestone creation..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Project start date: $PROJECT_START_DATE"
    log_info "Dry run: $DRY_RUN"
    echo ""
    
    # Create milestones from config or use defaults
    if [[ -f "$MILESTONES_CONFIG" ]]; then
        create_milestones_from_config "$MILESTONES_CONFIG"
    else
        create_default_milestones
    fi
    
    # Generate timeline document
    generate_timeline
    
    echo ""
    log_success "GitHub milestones created successfully!"
    
    # Show summary
    if [[ "$DRY_RUN" != "true" ]]; then
        list_milestones
    fi
    
    echo ""
    log_info "Next steps:"
    echo "  1. Review milestones: gh api repos/$GITHUB_OWNER/$GITHUB_REPO/milestones"
    echo "  2. Create issues: ./03-github-setup/create-issues.sh"
    echo "  3. Assign issues to milestones: ./04-organization/assign-to-milestones.sh"
    echo "  4. Review timeline: ${ROOT_DIR}/milestone-timeline.md"
}

# Help function
show_help() {
    echo "Create GitHub Milestones for Project Planning"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -d, --dry-run           Show what would be created without making changes"
    echo "  -l, --list              List existing milestones and exit"
    echo "  -t, --timeline          Generate timeline document only"
    echo "  --start-date DATE       Project start date (YYYY-MM-DD, default: today)"
    echo "  --config FILE           Use custom milestones config file"
    echo "  --repo OWNER/REPO       Specify GitHub repository"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_OWNER            GitHub repository owner"
    echo "  GITHUB_REPO             GitHub repository name"
    echo "  PROJECT_START_DATE      Project start date (YYYY-MM-DD)"
    echo ""
    echo "This script creates 5 default milestones:"
    echo "  • M1: MVP Foundation (Week 4)"
    echo "  • M2: Core Platform (Week 10)"
    echo "  • M3: User Experience (Week 14)"
    echo "  • M4: Production Ready (Week 18)"
    echo "  • M5: Enhancement & Scale (Week 24)"
    echo ""
    echo "Examples:"
    echo "  $0                                        # Create default milestones"
    echo "  $0 --start-date 2024-01-15               # Set custom start date"
    echo "  $0 --config custom-milestones.yaml       # Use custom config"
    echo "  $0 --dry-run                             # Preview changes"
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
        -l|--list)
            check_prerequisites
            list_milestones
            exit 0
            ;;
        -t|--timeline)
            generate_timeline
            exit 0
            ;;
        --start-date)
            PROJECT_START_DATE="$2"
            shift 2
            ;;
        --config)
            MILESTONES_CONFIG="$2"
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