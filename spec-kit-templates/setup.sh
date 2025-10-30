#!/bin/bash

# Spec-Kit Master Setup Script
# Transforms specifications into a complete GitHub project

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "════════════════════════════════════════════════════════"
echo "     SPEC-KIT: GitHub Project Setup Automation          "
echo "════════════════════════════════════════════════════════"
echo -e "${NC}"

# Load configuration
if [ -f "config.sh" ]; then
    source config.sh
else
    echo -e "${RED}Error: config.sh not found!${NC}"
    echo "Please copy config.example.sh to config.sh and configure it."
    exit 1
fi

# Verify GitHub CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed!${NC}"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub!${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Function to show progress
show_progress() {
    echo -e "${YELLOW}→ $1${NC}"
}

show_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

show_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to confirm action
confirm() {
    read -p "$(echo -e ${YELLOW}"$1 (y/n): "${NC})" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

# Main setup flow
main() {
    echo -e "${BLUE}Starting GitHub Project Setup...${NC}"
    echo "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    echo "Project: $PROJECT_NAME"
    echo ""

    # Phase 0: Validate Setup
    show_progress "Phase 0: Validating spec-kit setup..."
    if [[ -f "./validate-setup.sh" ]]; then
        if ./validate-setup.sh --quiet; then
            show_success "Spec-kit validation passed"
        else
            show_error "Spec-kit validation failed"
            log_info "Run './validate-setup.sh' for detailed validation report"
            exit 1
        fi
    else
        log_warning "Validation script not found, continuing without validation"
    fi

    # Phase 1: Validate Specifications
    show_progress "Phase 1: Validating specifications..."
    if [ ! -d "../specs" ]; then
        show_error "Specs directory not found at ../specs"
        if confirm "Create specs directory and templates?"; then
            mkdir -p ../specs/001-main
            cp 01-specification/*.md ../specs/001-main/
            show_success "Created spec templates in ../specs/001-main/"
            echo "Please edit the specifications and run this script again."
            exit 0
        else
            exit 1
        fi
    fi
    show_success "Specifications found"

    # Phase 2: Extract Tasks
    show_progress "Phase 2: Extracting tasks from specifications..."
    task_count=$(./02-extraction/extract-tasks.sh | wc -l)
    show_success "Extracted $task_count tasks"

    # Phase 3: Create GitHub Labels
    if confirm "Create GitHub labels? This will create epic, priority, and size labels."; then
        show_progress "Phase 3: Creating GitHub labels..."
        ./03-github-setup/create-labels.sh
        show_success "Labels created"
    else
        show_progress "Skipping label creation"
    fi

    # Phase 4: Create Milestones
    if confirm "Create GitHub milestones? This will create 5 default milestones."; then
        show_progress "Phase 4: Creating milestones..."
        ./03-github-setup/create-milestones.sh
        show_success "Milestones created"
    else
        show_progress "Skipping milestone creation"
    fi

    # Phase 5: Create Issues
    if confirm "Create $task_count GitHub issues?"; then
        show_progress "Phase 5: Creating GitHub issues..."
        ./03-github-setup/create-issues.sh
        show_success "Issues created"
        
        # Phase 6: Enrich Issues
        if confirm "Enrich issues with detailed descriptions?"; then
            show_progress "Phase 6: Enriching issues..."
            ./03-github-setup/enrich-issues.sh
            show_success "Issues enriched"
        fi
        
        # Phase 7: Assign to Epics
        if confirm "Organize issues into epics?"; then
            show_progress "Phase 7: Assigning issues to epics..."
            ./04-organization/assign-to-epics.sh
            show_success "Issues organized into epics"
        fi
        
        # Phase 8: Assign to Milestones
        if confirm "Assign issues to milestones?"; then
            show_progress "Phase 8: Assigning issues to milestones..."
            ./04-organization/assign-to-milestones.sh
            show_success "Issues assigned to milestones"
        fi
    else
        show_progress "Skipping issue creation"
    fi

    # Phase 9: Create Sub-Agents
    if confirm "Define and create specialized sub-agents for this project?"; then
        show_progress "Phase 9: Creating specialized sub-agents..."
        echo ""
        echo -e "${YELLOW}This will analyze your project and recommend specialized AI agents${NC}"
        echo -e "${YELLOW}You'll be able to approve each agent individually${NC}"
        echo ""
        
        # Run agent creation wizard
        cd 06-agents/
        ./create-agents.sh
        cd ..
        
        show_success "Sub-agents configured"
        
        # Check if any agents were created
        if ls 06-agents/agent-config-*.yaml 1> /dev/null 2>&1; then
            agent_count=$(ls -1 06-agents/agent-config-*.yaml | wc -l)
            show_success "Created $agent_count specialized agents"
        fi
    else
        show_progress "Skipping sub-agent creation"
    fi

    # Phase 10: Create Project Board
    if confirm "Create GitHub Project board?"; then
        show_progress "Phase 10: Creating project board..."
        project_url=$(gh project create "$PROJECT_NAME" \
            --owner "$GITHUB_OWNER" \
            --format json | jq -r '.url')
        show_success "Project board created: $project_url"
    else
        show_progress "Skipping project board creation"
    fi

    # Phase 11: Generate Documentation
    show_progress "Phase 11: Generating documentation..."
    mkdir -p ../docs
    ./05-reporting/generate-roadmap.sh > ../docs/roadmap.md
    ./05-reporting/epic-progress.sh > ../docs/epic-progress.md
    show_success "Documentation generated in ../docs/"

    # Summary
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}     ✅ GitHub Project Setup Complete!                  ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "📊 Summary:"
    echo "  • Tasks extracted: $task_count"
    echo "  • Labels created: 25+"
    echo "  • Milestones created: 5"
    echo "  • Issues created: $task_count"
    if [ -d "06-agents" ] && ls 06-agents/agent-config-*.yaml 1> /dev/null 2>&1; then
        agent_count=$(ls -1 06-agents/agent-config-*.yaml | wc -l)
        echo "  • Sub-agents created: $agent_count"
    fi
    echo "  • Documentation: ../docs/"
    echo ""
    echo "🔗 Links:"
    echo "  • Repository: https://github.com/$GITHUB_OWNER/$GITHUB_REPO"
    echo "  • Issues: https://github.com/$GITHUB_OWNER/$GITHUB_REPO/issues"
    echo "  • Milestones: https://github.com/$GITHUB_OWNER/$GITHUB_REPO/milestones"
    echo "  • Labels: https://github.com/$GITHUB_OWNER/$GITHUB_REPO/labels"
    if [ ! -z "$project_url" ]; then
        echo "  • Project Board: $project_url"
    fi
    echo ""
    echo "📝 Next Steps:"
    echo "  1. Review and refine issue descriptions"
    echo "  2. Assign team members to issues"
    echo "  3. Set up sprint planning"
    echo "  4. Configure CI/CD pipelines"
    echo "  5. Begin development!"
    echo ""
}

# Run main function
main "$@"