#!/bin/bash

# Generate Project Roadmap
# This script creates a comprehensive project roadmap from milestones, epics, and issues

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
OUTPUT_FILE="${OUTPUT_FILE:-${ROOT_DIR}/roadmap.md}"
INCLUDE_DETAILS="${INCLUDE_DETAILS:-true}"
FORMAT="${FORMAT:-markdown}"

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

# Function to get milestone data
get_milestone_data() {
    log_info "Fetching milestone data..."
    
    # Get all milestones with their issues
    gh api repos/"$GITHUB_OWNER"/"$GITHUB_REPO"/milestones --paginate | jq -r '
        .[] | {
            number: .number,
            title: .title,
            description: .description,
            state: .state,
            due_on: .due_on,
            open_issues: .open_issues,
            closed_issues: .closed_issues,
            created_at: .created_at,
            updated_at: .updated_at
        }' | jq -s 'sort_by(.number)'
}

# Function to get epic data
get_epic_data() {
    log_info "Fetching epic data..."
    
    local epics=("foundation" "data-layer" "core-services" "frontend" "testing" "operations" "cicd" "experimentation" "documentation")
    local epic_data="[]"
    
    for epic in "${epics[@]}"; do
        local epic_issues
        epic_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --label "epic:$epic" --state all --json number,title,state,milestone --limit 1000 2>/dev/null || echo "[]")
        
        local total_count
        total_count=$(echo "$epic_issues" | jq length)
        local open_count
        open_count=$(echo "$epic_issues" | jq '[.[] | select(.state == "open")] | length')
        local closed_count
        closed_count=$(echo "$epic_issues" | jq '[.[] | select(.state == "closed")] | length')
        
        local epic_info
        epic_info=$(jq -n --arg epic "$epic" --argjson total "$total_count" --argjson open "$open_count" --argjson closed "$closed_count" --argjson issues "$epic_issues" '{
            name: $epic,
            total_issues: $total,
            open_issues: $open,
            closed_issues: $closed,
            progress_percentage: (if $total > 0 then ($closed * 100 / $total) else 0 end),
            issues: $issues
        }')
        
        epic_data=$(echo "$epic_data" | jq ". + [$epic_info]")
    done
    
    echo "$epic_data"
}

# Function to generate roadmap header
generate_roadmap_header() {
    cat << EOF
# $PROJECT_NAME - Project Roadmap

**Generated**: $(date)  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)  
**Last Updated**: $(date)

---

## 📋 Executive Summary

This roadmap provides a comprehensive overview of the $PROJECT_NAME development timeline, including milestones, epics, and current progress.

### Quick Stats
EOF
    
    # Get overall project statistics
    local total_issues
    total_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --state all --json number | jq length)
    local open_issues
    open_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --state open --json number | jq length)
    local closed_issues
    closed_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --state closed --json number | jq length)
    
    local completion_percentage=0
    if [[ $total_issues -gt 0 ]]; then
        completion_percentage=$((closed_issues * 100 / total_issues))
    fi
    
    cat << EOF

- **Total Tasks**: $total_issues
- **Completed**: $closed_issues
- **In Progress**: $open_issues
- **Overall Progress**: $completion_percentage%

EOF
}

# Function to generate milestone section
generate_milestone_section() {
    local milestone_data="$1"
    
    cat << EOF
## 🎯 Milestones Overview

Our project is organized into strategic milestones that build upon each other:

EOF
    
    # Process each milestone
    echo "$milestone_data" | jq -r '.[] | @base64' | while read -r milestone_b64; do
        local milestone
        milestone=$(echo "$milestone_b64" | base64 -d)
        
        local title
        title=$(echo "$milestone" | jq -r '.title')
        local description
        description=$(echo "$milestone" | jq -r '.description // "No description"')
        local state
        state=$(echo "$milestone" | jq -r '.state')
        local due_date
        due_date=$(echo "$milestone" | jq -r '.due_on // "No due date"')
        local open_issues
        open_issues=$(echo "$milestone" | jq -r '.open_issues')
        local closed_issues
        closed_issues=$(echo "$milestone" | jq -r '.closed_issues')
        local total_issues=$((open_issues + closed_issues))
        
        local progress_percentage=0
        if [[ $total_issues -gt 0 ]]; then
            progress_percentage=$((closed_issues * 100 / total_issues))
        fi
        
        # Format due date
        local formatted_due_date="TBD"
        if [[ "$due_date" != "No due date" ]]; then
            formatted_due_date=$(date -d "$due_date" "+%B %d, %Y" 2>/dev/null || echo "$due_date")
        fi
        
        # Status emoji
        local status_emoji="🔄"
        case "$state" in
            "closed") status_emoji="✅" ;;
            "open") 
                if [[ $progress_percentage -eq 0 ]]; then
                    status_emoji="🔜"
                elif [[ $progress_percentage -lt 50 ]]; then
                    status_emoji="🔄"
                else
                    status_emoji="🚀"
                fi
                ;;
        esac
        
        cat << EOF
### $status_emoji $title

**Status**: $state  
**Due Date**: $formatted_due_date  
**Progress**: $closed_issues/$total_issues tasks completed ($progress_percentage%)

$description

EOF
        
        # Add progress bar
        local progress_bar=""
        local filled_blocks=$((progress_percentage / 5))
        for ((i=1; i<=20; i++)); do
            if [[ $i -le $filled_blocks ]]; then
                progress_bar+="█"
            else
                progress_bar+="░"
            fi
        done
        
        echo "**Progress**: [$progress_bar] $progress_percentage%"
        echo ""
    done
}

# Function to generate epic section
generate_epic_section() {
    local epic_data="$1"
    
    cat << EOF
## 🏗️ Epic Breakdown

Our work is organized into focused epics that represent major areas of functionality:

EOF
    
    # Create epic progress table
    cat << EOF
| Epic | Progress | Total Tasks | Status |
|------|----------|-------------|---------|
EOF
    
    echo "$epic_data" | jq -r '.[] | @base64' | while read -r epic_b64; do
        local epic
        epic=$(echo "$epic_b64" | base64 -d)
        
        local name
        name=$(echo "$epic" | jq -r '.name')
        local total_issues
        total_issues=$(echo "$epic" | jq -r '.total_issues')
        local closed_issues
        closed_issues=$(echo "$epic" | jq -r '.closed_issues')
        local progress_percentage
        progress_percentage=$(echo "$epic" | jq -r '.progress_percentage | floor')
        
        # Status based on progress
        local status="🔜 Not Started"
        if [[ $progress_percentage -gt 0 && $progress_percentage -lt 25 ]]; then
            status="🔄 Just Started"
        elif [[ $progress_percentage -ge 25 && $progress_percentage -lt 50 ]]; then
            status="🚧 In Progress"
        elif [[ $progress_percentage -ge 50 && $progress_percentage -lt 90 ]]; then
            status="🚀 Well Underway"
        elif [[ $progress_percentage -ge 90 && $progress_percentage -lt 100 ]]; then
            status="🎯 Nearly Complete"
        elif [[ $progress_percentage -eq 100 ]]; then
            status="✅ Complete"
        fi
        
        printf "| **%s** | %d%% | %d | %s |\n" "$name" "$progress_percentage" "$total_issues" "$status"
    done
    
    echo ""
    
    # Detailed epic breakdown
    if [[ "$INCLUDE_DETAILS" == "true" ]]; then
        cat << EOF
### Detailed Epic Status

EOF
        
        echo "$epic_data" | jq -r '.[] | @base64' | while read -r epic_b64; do
            local epic
            epic=$(echo "$epic_b64" | base64 -d)
            
            local name
            name=$(echo "$epic" | jq -r '.name')
            local total_issues
            total_issues=$(echo "$epic" | jq -r '.total_issues')
            local open_issues
            open_issues=$(echo "$epic" | jq -r '.open_issues')
            local closed_issues
            closed_issues=$(echo "$epic" | jq -r '.closed_issues')
            local progress_percentage
            progress_percentage=$(echo "$epic" | jq -r '.progress_percentage | floor')
            
            # Get epic description from predefined list
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
#### Epic: $name

**Description**: $epic_description  
**Progress**: $closed_issues/$total_issues completed ($progress_percentage%)  
**Remaining**: $open_issues tasks

EOF
            
            # Show recent completed tasks (if any)
            local recent_completed
            recent_completed=$(echo "$epic" | jq -r '.issues[] | select(.state == "closed") | .title' | head -3)
            
            if [[ -n "$recent_completed" ]]; then
                echo "**Recently Completed**:"
                echo "$recent_completed" | sed 's/^/- /'
                echo ""
            fi
            
            # Show current open tasks (if any)
            local current_open
            current_open=$(echo "$epic" | jq -r '.issues[] | select(.state == "open") | .title' | head -3)
            
            if [[ -n "$current_open" ]]; then
                echo "**Currently Open**:"
                echo "$current_open" | sed 's/^/- /'
                echo ""
            fi
        done
    fi
}

# Function to generate timeline visualization
generate_timeline_section() {
    local milestone_data="$1"
    
    cat << EOF
## 📅 Timeline Visualization

\`\`\`
Project Timeline Overview
EOF
    
    echo "$milestone_data" | jq -r '.[] | @base64' | while read -r milestone_b64; do
        local milestone
        milestone=$(echo "$milestone_b64" | base64 -d)
        
        local title
        title=$(echo "$milestone" | jq -r '.title')
        local due_date
        due_date=$(echo "$milestone" | jq -r '.due_on // "TBD"')
        local state
        state=$(echo "$milestone" | jq -r '.state')
        
        # Format milestone in timeline
        local status_symbol="○"
        if [[ "$state" == "closed" ]]; then
            status_symbol="●"
        fi
        
        local formatted_date="TBD"
        if [[ "$due_date" != "TBD" ]]; then
            formatted_date=$(date -d "$due_date" "+%Y-%m-%d" 2>/dev/null || echo "$due_date")
        fi
        
        printf "%-30s %s %s\n" "$title" "$status_symbol" "$formatted_date"
    done
    
    cat << EOF
\`\`\`

**Legend**: ● Completed | ○ In Progress/Planned

EOF
}

# Function to generate dependencies section
generate_dependencies_section() {
    cat << EOF
## 🔗 Dependencies & Critical Path

### Milestone Dependencies

Our milestones follow a sequential dependency pattern:

\`\`\`
M1: MVP Foundation
    ↓
M2: Core Platform  
    ↓
M3: User Experience
    ↓
M4: Production Ready
    ↓
M5: Enhancement & Scale
\`\`\`

### Critical Path Analysis

The critical path represents the sequence of tasks that directly impacts the project completion date:

1. **Foundation Setup** → Infrastructure must be ready before development
2. **Core Development** → APIs must exist before frontend integration  
3. **Integration & Testing** → Features must be tested before deployment
4. **Production Deployment** → System must be stable before enhancements
5. **Enhancement & Scale** → Advanced features build on stable platform

### Key Dependencies

- **M2 depends on M1**: Cannot develop APIs without infrastructure
- **M3 depends on M2**: Frontend needs working backend services
- **M4 depends on M3**: Cannot deploy incomplete features
- **M5 depends on M4**: Advanced features require stable production environment

EOF
}

# Function to generate risks section
generate_risks_section() {
    cat << EOF
## ⚠️ Risk Assessment

### High-Priority Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Infrastructure delays | High | Medium | Multi-cloud strategy, early provisioning |
| API design changes | High | Medium | Lock contracts early, extensive review |
| Performance issues | Medium | High | Early testing, optimization sprints |
| Security vulnerabilities | High | Low | Regular audits, security-first design |
| Team availability | Medium | Medium | Cross-training, documentation |

### Mitigation Strategies

1. **Early Risk Detection**: Weekly risk assessment meetings
2. **Contingency Planning**: Alternative approaches for high-risk items
3. **Stakeholder Communication**: Regular updates on risk status
4. **Resource Flexibility**: Buffer time in critical path items

EOF
}

# Function to generate next steps section
generate_next_steps_section() {
    local milestone_data="$1"
    local epic_data="$2"
    
    cat << EOF
## 🚀 Next Steps & Action Items

### Immediate Priorities

EOF
    
    # Get the next milestone to focus on
    local next_milestone
    next_milestone=$(echo "$milestone_data" | jq -r '.[] | select(.state == "open") | .title' | head -1)
    
    if [[ -n "$next_milestone" ]]; then
        echo "**Current Focus**: $next_milestone"
        echo ""
    fi
    
    # Get epics that need attention
    echo "**Epics Requiring Attention**:"
    echo "$epic_data" | jq -r '.[] | select(.progress_percentage < 50 and .total_issues > 0) | "- **\(.name)**: \(.progress_percentage)% complete, \(.open_issues) tasks remaining"'
    echo ""
    
    cat << EOF
### Recommended Actions

1. **Weekly Reviews**: Schedule weekly milestone progress reviews
2. **Blocker Resolution**: Address any blocked tasks immediately  
3. **Resource Allocation**: Ensure teams are focused on critical path items
4. **Stakeholder Updates**: Provide bi-weekly progress reports
5. **Risk Monitoring**: Continue weekly risk assessment meetings

### Success Metrics

- **Schedule Performance**: Stay within 10% of milestone dates
- **Quality Metrics**: Maintain >80% test coverage
- **Team Velocity**: Track story points completed per sprint
- **Risk Mitigation**: Resolve high-impact risks within 1 week

EOF
}

# Function to generate footer
generate_footer() {
    cat << EOF
---

## 📊 Report Information

**Generated By**: Spec-Kit Roadmap Generator  
**Generated On**: $(date)  
**Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)  
**Issues**: [View All Issues](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/issues)  
**Milestones**: [View Milestones](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/milestones)  

### How to Use This Roadmap

1. **Track Progress**: Use milestone percentages to gauge overall progress
2. **Identify Blockers**: Look for epics with low progress percentages
3. **Plan Sprints**: Focus team efforts on critical path milestones
4. **Communicate Status**: Share this roadmap with stakeholders regularly
5. **Update Regularly**: Regenerate weekly to maintain accuracy

### Automation

This roadmap is automatically generated from your GitHub issues, milestones, and labels. To update:

\`\`\`bash
./05-reporting/generate-roadmap.sh
\`\`\`

---
*Roadmap generated automatically by spec-kit tools*
EOF
}

# Main function to generate roadmap
generate_roadmap() {
    log_info "Generating project roadmap..."
    
    # Fetch data
    local milestone_data
    milestone_data=$(get_milestone_data)
    
    local epic_data
    epic_data=$(get_epic_data)
    
    # Generate roadmap sections
    log_info "Creating roadmap sections..."
    
    {
        generate_roadmap_header
        generate_milestone_section "$milestone_data"
        generate_epic_section "$epic_data"
        generate_timeline_section "$milestone_data"
        generate_dependencies_section
        generate_risks_section
        generate_next_steps_section "$milestone_data" "$epic_data"
        generate_footer
    } > "$OUTPUT_FILE"
    
    log_success "Roadmap generated: $OUTPUT_FILE"
}

# Function to generate summary report
generate_summary_report() {
    log_info "Generating roadmap summary..."
    
    local summary_file="${ROOT_DIR}/roadmap-summary.md"
    local milestone_data
    milestone_data=$(get_milestone_data)
    local epic_data
    epic_data=$(get_epic_data)
    
    # Calculate overall statistics
    local total_milestones
    total_milestones=$(echo "$milestone_data" | jq length)
    local completed_milestones
    completed_milestones=$(echo "$milestone_data" | jq '[.[] | select(.state == "closed")] | length')
    
    local total_issues
    total_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --state all --json number | jq length)
    local completed_issues
    completed_issues=$(gh issue list --repo "$GITHUB_OWNER/$GITHUB_REPO" --search "[T" --state closed --json number | jq length)
    
    local overall_progress=0
    if [[ $total_issues -gt 0 ]]; then
        overall_progress=$((completed_issues * 100 / total_issues))
    fi
    
    cat > "$summary_file" << EOF
# $PROJECT_NAME - Roadmap Summary

**Generated**: $(date)

## Key Metrics

- **Overall Progress**: $overall_progress% ($completed_issues/$total_issues tasks)
- **Milestones**: $completed_milestones/$total_milestones completed
- **Repository**: [$GITHUB_OWNER/$GITHUB_REPO](https://github.com/$GITHUB_OWNER/$GITHUB_REPO)

## Current Status

EOF
    
    # Add epic status summary
    echo "$epic_data" | jq -r '.[] | "- **\(.name)**: \(.progress_percentage | floor)% complete (\(.closed_issues)/\(.total_issues) tasks)"' >> "$summary_file"
    
    cat >> "$summary_file" << EOF

## Next Milestone

EOF
    
    local next_milestone_title
    next_milestone_title=$(echo "$milestone_data" | jq -r '.[] | select(.state == "open") | .title' | head -1)
    local next_milestone_due
    next_milestone_due=$(echo "$milestone_data" | jq -r ".[] | select(.title == \"$next_milestone_title\") | .due_on // \"TBD\"")
    
    if [[ -n "$next_milestone_title" ]]; then
        echo "**$next_milestone_title** - Due: $next_milestone_due" >> "$summary_file"
    else
        echo "All milestones completed!" >> "$summary_file"
    fi
    
    cat >> "$summary_file" << EOF

---
For detailed roadmap, see: [roadmap.md](./roadmap.md)
EOF
    
    log_success "Summary generated: $summary_file"
}

# Main function
main() {
    log_info "Starting roadmap generation..."
    
    check_prerequisites
    
    echo ""
    log_info "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    log_info "Project: $PROJECT_NAME"
    log_info "Output file: $OUTPUT_FILE"
    log_info "Include details: $INCLUDE_DETAILS"
    echo ""
    
    # Generate roadmap
    generate_roadmap
    
    # Generate summary
    generate_summary_report
    
    echo ""
    log_success "Roadmap generation completed!"
    log_info "Files generated:"
    echo "  - Main roadmap: $OUTPUT_FILE"
    echo "  - Summary: ${ROOT_DIR}/roadmap-summary.md"
    echo ""
    log_info "Next steps:"
    echo "  1. Review the generated roadmap"
    echo "  2. Share with stakeholders"
    echo "  3. Schedule regular updates (weekly recommended)"
    echo "  4. Use for sprint planning and progress tracking"
}

# Help function
show_help() {
    echo "Generate Project Roadmap"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -o, --output FILE       Specify output file (default: ../roadmap.md)"
    echo "  -p, --project NAME      Specify project name"
    echo "  --no-details            Skip detailed epic breakdown"
    echo "  --format FORMAT         Output format (markdown, html) [default: markdown]"
    echo "  --repo OWNER/REPO       Specify GitHub repository"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_OWNER            GitHub repository owner"
    echo "  GITHUB_REPO             GitHub repository name"
    echo "  PROJECT_NAME            Project name for roadmap"
    echo ""
    echo "This script generates a comprehensive roadmap including:"
    echo "  • Milestone progress and timelines"
    echo "  • Epic breakdown and status"
    echo "  • Timeline visualization"
    echo "  • Dependencies and critical path"
    echo "  • Risk assessment"
    echo "  • Next steps and action items"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Generate standard roadmap"
    echo "  $0 --project \"My Project\"             # Set custom project name"
    echo "  $0 --output /path/to/roadmap.md       # Custom output location"
    echo "  $0 --no-details                      # Generate summary only"
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
        --no-details)
            INCLUDE_DETAILS="false"
            shift
            ;;
        --format)
            FORMAT="$2"
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