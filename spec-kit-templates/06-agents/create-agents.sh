#!/bin/bash

# Agent Creation Script with User Approval
# Creates specialized sub-agents based on project needs

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Load configuration
if [ -f "../config.sh" ]; then
    source ../config.sh
else
    if [ -f "config.sh" ]; then
        source config.sh
    fi
fi

# Project analysis results
PROJECT_CHARACTERISTICS=""
RECOMMENDED_AGENTS=()
SELECTED_AGENTS=()
AGENT_CONFIGS=()

# Functions
show_banner() {
    echo -e "${MAGENTA}"
    echo "════════════════════════════════════════════════════════"
    echo "     🤖 SUB-AGENT CREATION WIZARD                       "
    echo "     Creating specialized agents for your project       "
    echo "════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

analyze_project() {
    echo -e "${BLUE}📊 Analyzing Project Characteristics...${NC}"
    echo ""
    
    local has_backend=false
    local has_frontend=false
    local has_database=false
    local has_cloud=false
    local has_ml=false
    local has_testing=false
    local is_microservices=false
    local is_enterprise=false
    local has_legacy=false
    
    # Check for backend services
    if [ -f "../specs/001-main/tasks.md" ]; then
        if grep -q "API\|backend\|service\|REST\|GraphQL\|gRPC" ../specs/001-main/tasks.md 2>/dev/null; then
            has_backend=true
            echo "  ✓ Backend services detected"
        fi
        
        if grep -q "frontend\|UI\|React\|Next.js\|component" ../specs/001-main/tasks.md 2>/dev/null; then
            has_frontend=true
            echo "  ✓ Frontend components detected"
        fi
        
        if grep -q "database\|PostgreSQL\|MongoDB\|Redis\|migration" ../specs/001-main/tasks.md 2>/dev/null; then
            has_database=true
            echo "  ✓ Database operations detected"
        fi
        
        if grep -q "cloud\|AWS\|GCP\|Azure\|Terraform\|Docker" ../specs/001-main/tasks.md 2>/dev/null; then
            has_cloud=true
            echo "  ✓ Cloud infrastructure detected"
        fi
        
        if grep -q "ML\|machine learning\|AI\|model\|training" ../specs/001-main/tasks.md 2>/dev/null; then
            has_ml=true
            echo "  ✓ Machine learning components detected"
        fi
        
        if grep -q "test\|TDD\|QA\|coverage" ../specs/001-main/tasks.md 2>/dev/null; then
            has_testing=true
            echo "  ✓ Testing requirements detected"
        fi
        
        if grep -q "microservice\|service mesh\|distributed" ../specs/001-main/tasks.md 2>/dev/null; then
            is_microservices=true
            echo "  ✓ Microservices architecture detected"
        fi
        
        if grep -q "enterprise\|compliance\|security\|audit" ../specs/001-main/tasks.md 2>/dev/null; then
            is_enterprise=true
            echo "  ✓ Enterprise requirements detected"
        fi
        
        if grep -q "migration\|legacy\|refactor\|modernization" ../specs/001-main/tasks.md 2>/dev/null; then
            has_legacy=true
            echo "  ✓ Legacy migration detected"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}📋 Project Profile:${NC}"
    
    # Build recommendations based on analysis
    if [ "$has_backend" = true ]; then
        RECOMMENDED_AGENTS+=("backend-specialist")
        echo "  • Backend development required"
    fi
    
    if [ "$has_frontend" = true ]; then
        RECOMMENDED_AGENTS+=("frontend-specialist")
        echo "  • Frontend development required"
    fi
    
    if [ "$has_cloud" = true ]; then
        RECOMMENDED_AGENTS+=("devops-engineer")
        echo "  • Cloud infrastructure management needed"
    fi
    
    if [ "$has_database" = true ] && [ "$has_ml" = true ]; then
        RECOMMENDED_AGENTS+=("data-engineer")
        echo "  • Data engineering capabilities needed"
    fi
    
    if [ "$is_enterprise" = true ]; then
        RECOMMENDED_AGENTS+=("security-specialist")
        RECOMMENDED_AGENTS+=("documentation-specialist")
        echo "  • Enterprise-grade security and documentation"
    fi
    
    if [ "$has_testing" = true ]; then
        RECOMMENDED_AGENTS+=("testing-specialist")
        echo "  • Comprehensive testing strategy required"
    fi
    
    if [ "$is_microservices" = true ]; then
        RECOMMENDED_AGENTS+=("integration-specialist")
        echo "  • Service integration and API management"
    fi
    
    if [ "$has_legacy" = true ]; then
        RECOMMENDED_AGENTS+=("migration-specialist")
        echo "  • Legacy system migration support"
    fi
    
    # Add performance engineer for large-scale projects
    local task_count=$(grep -c "^### T" ../specs/001-main/tasks.md 2>/dev/null || echo "0")
    if [ "$task_count" -gt 100 ]; then
        RECOMMENDED_AGENTS+=("performance-engineer")
        echo "  • Performance optimization (large project)"
    fi
    
    echo ""
}

display_agent_details() {
    local agent_id=$1
    
    case $agent_id in
        "backend-specialist")
            echo -e "${CYAN}🔧 Backend Development Specialist${NC}"
            echo "   Handles server-side logic, APIs, and data operations"
            echo "   Skills: REST/GraphQL/gRPC, databases, business logic"
            echo "   Epics: data-layer, core-services, api-development"
            ;;
        "frontend-specialist")
            echo -e "${CYAN}🎨 Frontend Development Specialist${NC}"
            echo "   Focuses on UI/UX and user interactions"
            echo "   Skills: React/Next.js, responsive design, state management"
            echo "   Epics: frontend, ui-components, user-experience"
            ;;
        "devops-engineer")
            echo -e "${CYAN}⚙️ DevOps & Infrastructure Engineer${NC}"
            echo "   Manages CI/CD and cloud infrastructure"
            echo "   Skills: Terraform, Docker, CI/CD, monitoring"
            echo "   Epics: infrastructure, cicd, operations"
            ;;
        "testing-specialist")
            echo -e "${CYAN}🧪 Testing & QA Specialist${NC}"
            echo "   Implements comprehensive testing strategies"
            echo "   Skills: Unit/integration/E2E testing, TDD, coverage"
            echo "   Epics: testing, quality-assurance"
            ;;
        "security-specialist")
            echo -e "${CYAN}🔒 Security & Compliance Specialist${NC}"
            echo "   Handles security and compliance requirements"
            echo "   Skills: Auth, encryption, audits, compliance"
            echo "   Epics: security, compliance, authentication"
            ;;
        "data-engineer")
            echo -e "${CYAN}📊 Data & Analytics Engineer${NC}"
            echo "   Manages data pipelines and ML operations"
            echo "   Skills: ETL/ELT, data warehousing, ML deployment"
            echo "   Epics: data-pipeline, analytics, machine-learning"
            ;;
        "documentation-specialist")
            echo -e "${CYAN}📚 Documentation Specialist${NC}"
            echo "   Creates technical documentation and guides"
            echo "   Skills: Technical writing, API docs, diagrams"
            echo "   Epics: documentation, developer-experience"
            ;;
        "performance-engineer")
            echo -e "${CYAN}⚡ Performance Optimization Engineer${NC}"
            echo "   Optimizes application performance and scalability"
            echo "   Skills: Profiling, caching, load balancing"
            echo "   Epics: performance, optimization, scalability"
            ;;
        "migration-specialist")
            echo -e "${CYAN}🔄 Migration & Modernization Specialist${NC}"
            echo "   Handles legacy migrations and upgrades"
            echo "   Skills: Migration planning, refactoring, compatibility"
            echo "   Epics: migration, modernization, refactoring"
            ;;
        "integration-specialist")
            echo -e "${CYAN}🔗 Integration & API Specialist${NC}"
            echo "   Manages integrations and API ecosystem"
            echo "   Skills: API integration, webhooks, event streaming"
            echo "   Epics: integrations, api-management, external-services"
            ;;
    esac
}

recommend_agents() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🎯 RECOMMENDED AGENTS BASED ON YOUR PROJECT${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ ${#RECOMMENDED_AGENTS[@]} -eq 0 ]; then
        echo "No specific recommendations. Please choose agents manually."
        # Default recommendations for any project
        RECOMMENDED_AGENTS=("backend-specialist" "frontend-specialist" "devops-engineer")
    fi
    
    # Remove duplicates
    RECOMMENDED_AGENTS=($(echo "${RECOMMENDED_AGENTS[@]}" | tr ' ' '\n' | sort -u))
    
    for agent in "${RECOMMENDED_AGENTS[@]}"; do
        display_agent_details "$agent"
        echo ""
    done
}

prompt_agent_creation() {
    local agent_id=$1
    local agent_name=$2
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    display_agent_details "$agent_id"
    echo ""
    
    while true; do
        read -p "$(echo -e ${GREEN}"Create this agent? (y/n/details): "${NC})" choice
        case $choice in
            [Yy]* )
                SELECTED_AGENTS+=("$agent_id")
                echo -e "${GREEN}✓ Agent added to creation queue${NC}"
                echo ""
                return 0
                ;;
            [Nn]* )
                echo -e "${YELLOW}⊗ Agent skipped${NC}"
                echo ""
                return 0
                ;;
            [Dd]* )
                show_agent_tasks "$agent_id"
                ;;
            * )
                echo "Please answer y (yes), n (no), or d (details)"
                ;;
        esac
    done
}

show_agent_tasks() {
    local agent_id=$1
    
    echo ""
    echo -e "${BLUE}📋 Tasks this agent would handle:${NC}"
    
    case $agent_id in
        "backend-specialist")
            echo "  • Implement API endpoints (REST/GraphQL/gRPC)"
            echo "  • Create database models and migrations"
            echo "  • Implement business logic and validation"
            echo "  • Set up data access layers"
            echo "  • Configure caching strategies"
            ;;
        "frontend-specialist")
            echo "  • Create React/Next.js components"
            echo "  • Implement responsive layouts"
            echo "  • Manage application state"
            echo "  • Optimize performance and accessibility"
            echo "  • Integrate with backend APIs"
            ;;
        "devops-engineer")
            echo "  • Write Terraform configurations"
            echo "  • Set up CI/CD pipelines"
            echo "  • Configure cloud services"
            echo "  • Implement monitoring and logging"
            echo "  • Manage deployments and rollbacks"
            ;;
        "testing-specialist")
            echo "  • Write unit and integration tests"
            echo "  • Create E2E test suites"
            echo "  • Implement contract testing"
            echo "  • Set up test automation"
            echo "  • Generate coverage reports"
            ;;
        "security-specialist")
            echo "  • Implement authentication/authorization"
            echo "  • Conduct security audits"
            echo "  • Set up vulnerability scanning"
            echo "  • Manage secrets and encryption"
            echo "  • Ensure compliance standards"
            ;;
        *)
            echo "  • See agent description above"
            ;;
    esac
    echo ""
}

select_additional_agents() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📝 ADDITIONAL AGENT SELECTION${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Would you like to add any additional specialized agents?"
    echo ""
    
    local all_agents=(
        "backend-specialist"
        "frontend-specialist"
        "devops-engineer"
        "testing-specialist"
        "security-specialist"
        "data-engineer"
        "documentation-specialist"
        "performance-engineer"
        "migration-specialist"
        "integration-specialist"
    )
    
    echo "Available agents not yet selected:"
    echo ""
    
    for agent in "${all_agents[@]}"; do
        # Check if agent is already selected
        if [[ ! " ${SELECTED_AGENTS[@]} " =~ " ${agent} " ]]; then
            case $agent in
                "backend-specialist") echo "  1) Backend Development Specialist" ;;
                "frontend-specialist") echo "  2) Frontend Development Specialist" ;;
                "devops-engineer") echo "  3) DevOps & Infrastructure Engineer" ;;
                "testing-specialist") echo "  4) Testing & QA Specialist" ;;
                "security-specialist") echo "  5) Security & Compliance Specialist" ;;
                "data-engineer") echo "  6) Data & Analytics Engineer" ;;
                "documentation-specialist") echo "  7) Documentation Specialist" ;;
                "performance-engineer") echo "  8) Performance Optimization Engineer" ;;
                "migration-specialist") echo "  9) Migration & Modernization Specialist" ;;
                "integration-specialist") echo " 10) Integration & API Specialist" ;;
            esac
        fi
    done
    
    echo ""
    echo "  0) Done selecting agents"
    echo ""
    
    while true; do
        read -p "Select agent number (0 to finish): " choice
        
        case $choice in
            1) prompt_agent_creation "backend-specialist" ;;
            2) prompt_agent_creation "frontend-specialist" ;;
            3) prompt_agent_creation "devops-engineer" ;;
            4) prompt_agent_creation "testing-specialist" ;;
            5) prompt_agent_creation "security-specialist" ;;
            6) prompt_agent_creation "data-engineer" ;;
            7) prompt_agent_creation "documentation-specialist" ;;
            8) prompt_agent_creation "performance-engineer" ;;
            9) prompt_agent_creation "migration-specialist" ;;
            10) prompt_agent_creation "integration-specialist" ;;
            0) break ;;
            *) echo "Invalid selection" ;;
        esac
    done
}

create_agent_config() {
    local agent_id=$1
    
    echo ""
    echo -e "${BLUE}⚙️ Configuring agent: ${agent_id}${NC}"
    
    # Create agent configuration file
    cat > "agent-config-${agent_id}.yaml" << EOF
# Configuration for ${agent_id}
agent:
  id: ${agent_id}
  name: $(get_agent_name ${agent_id})
  created: $(date +%Y-%m-%d)
  project: ${PROJECT_NAME}
  
settings:
  auto_assign_tasks: true
  priority_level: normal
  max_concurrent_tasks: 3
  
capabilities:
$(get_agent_capabilities ${agent_id})
  
assigned_epics:
$(get_agent_epics ${agent_id})
  
task_filters:
  labels:
$(get_agent_labels ${agent_id})
  
  keywords:
$(get_agent_keywords ${agent_id})
  
performance_metrics:
  expected_velocity: 20  # story points per week
  quality_threshold: 95  # percentage
  
collaboration:
  report_to: project-manager
  collaborate_with:
$(get_collaboration_agents ${agent_id})
EOF
    
    echo -e "${GREEN}✓ Configuration created: agent-config-${agent_id}.yaml${NC}"
}

get_agent_name() {
    case $1 in
        "backend-specialist") echo "Backend Development Specialist" ;;
        "frontend-specialist") echo "Frontend Development Specialist" ;;
        "devops-engineer") echo "DevOps & Infrastructure Engineer" ;;
        "testing-specialist") echo "Testing & QA Specialist" ;;
        "security-specialist") echo "Security & Compliance Specialist" ;;
        "data-engineer") echo "Data & Analytics Engineer" ;;
        "documentation-specialist") echo "Documentation Specialist" ;;
        "performance-engineer") echo "Performance Optimization Engineer" ;;
        "migration-specialist") echo "Migration & Modernization Specialist" ;;
        "integration-specialist") echo "Integration & API Specialist" ;;
        *) echo "Specialist" ;;
    esac
}

get_agent_capabilities() {
    case $1 in
        "backend-specialist")
            echo "    - API development (REST/GraphQL/gRPC)"
            echo "    - Database design and optimization"
            echo "    - Business logic implementation"
            echo "    - Data modeling and validation"
            ;;
        "frontend-specialist")
            echo "    - React/Next.js development"
            echo "    - UI/UX implementation"
            echo "    - State management"
            echo "    - Performance optimization"
            ;;
        "devops-engineer")
            echo "    - Infrastructure as Code"
            echo "    - CI/CD pipeline creation"
            echo "    - Cloud service configuration"
            echo "    - Monitoring and logging"
            ;;
        *)
            echo "    - Specialized tasks"
            ;;
    esac
}

get_agent_epics() {
    case $1 in
        "backend-specialist")
            echo "    - epic:data-layer"
            echo "    - epic:core-services"
            ;;
        "frontend-specialist")
            echo "    - epic:frontend"
            echo "    - epic:ui-components"
            ;;
        "devops-engineer")
            echo "    - epic:infrastructure"
            echo "    - epic:cicd"
            ;;
        "testing-specialist")
            echo "    - epic:testing"
            echo "    - epic:quality-assurance"
            ;;
        "security-specialist")
            echo "    - epic:security"
            echo "    - epic:compliance"
            ;;
        *)
            echo "    - epic:general"
            ;;
    esac
}

get_agent_labels() {
    case $1 in
        "backend-specialist")
            echo "    - backend"
            echo "    - api"
            echo "    - database"
            ;;
        "frontend-specialist")
            echo "    - frontend"
            echo "    - ui"
            echo "    - component"
            ;;
        "devops-engineer")
            echo "    - infrastructure"
            echo "    - deployment"
            echo "    - cicd"
            ;;
        *)
            echo "    - ${1//-specialist/}"
            ;;
    esac
}

get_agent_keywords() {
    case $1 in
        "backend-specialist")
            echo "    - API"
            echo "    - service"
            echo "    - database"
            echo "    - model"
            ;;
        "frontend-specialist")
            echo "    - component"
            echo "    - UI"
            echo "    - React"
            echo "    - layout"
            ;;
        "devops-engineer")
            echo "    - Docker"
            echo "    - Terraform"
            echo "    - deploy"
            echo "    - pipeline"
            ;;
        *)
            echo "    - ${1//-specialist/}"
            ;;
    esac
}

get_collaboration_agents() {
    case $1 in
        "backend-specialist")
            echo "    - frontend-specialist"
            echo "    - testing-specialist"
            echo "    - data-engineer"
            ;;
        "frontend-specialist")
            echo "    - backend-specialist"
            echo "    - testing-specialist"
            echo "    - documentation-specialist"
            ;;
        "devops-engineer")
            echo "    - backend-specialist"
            echo "    - security-specialist"
            echo "    - performance-engineer"
            ;;
        *)
            echo "    - all"
            ;;
    esac
}

assign_tasks_to_agents() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 TASK ASSIGNMENT TO AGENTS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo "Analyzing tasks and assigning to appropriate agents..."
    echo ""
    
    # Create task assignment file
    cat > "agent-task-assignments.md" << EOF
# Agent Task Assignments
Generated: $(date)

## Summary
Total Agents: ${#SELECTED_AGENTS[@]}
Total Tasks: $(grep -c "^### T" ../specs/001-main/tasks.md 2>/dev/null || echo "0")

## Agent Assignments

EOF
    
    for agent in "${SELECTED_AGENTS[@]}"; do
        echo "### $(get_agent_name $agent)" >> agent-task-assignments.md
        echo "" >> agent-task-assignments.md
        echo "**Assigned Epics:**" >> agent-task-assignments.md
        get_agent_epics $agent | sed 's/^    //' >> agent-task-assignments.md
        echo "" >> agent-task-assignments.md
        echo "**Task Keywords:**" >> agent-task-assignments.md
        get_agent_keywords $agent | sed 's/^    //' >> agent-task-assignments.md
        echo "" >> agent-task-assignments.md
        echo "---" >> agent-task-assignments.md
        echo "" >> agent-task-assignments.md
    done
    
    echo -e "${GREEN}✓ Task assignments documented in agent-task-assignments.md${NC}"
}

create_agent_dashboard() {
    echo ""
    echo -e "${BLUE}📊 Creating Agent Dashboard...${NC}"
    
    cat > "agent-dashboard.md" << EOF
# 🤖 Project Agent Dashboard
Generated: $(date)

## Active Agents (${#SELECTED_AGENTS[@]})

EOF
    
    for agent in "${SELECTED_AGENTS[@]}"; do
        cat >> "agent-dashboard.md" << EOF
### $(get_agent_name $agent)
- **Status:** Active
- **Configuration:** agent-config-${agent}.yaml
- **Assigned Epics:** $(get_agent_epics $agent | tr '\n' ' ' | sed 's/    - //g')
- **Collaboration:** $(get_collaboration_agents $agent | tr '\n' ' ' | sed 's/    - //g')

EOF
    done
    
    cat >> "agent-dashboard.md" << EOF

## Agent Collaboration Matrix

| Agent | Collaborates With | Shared Epics |
|-------|------------------|--------------|
EOF
    
    for agent in "${SELECTED_AGENTS[@]}"; do
        echo "| $(get_agent_name $agent) | $(get_collaboration_agents $agent | tr '\n' ',' | sed 's/    - //g' | sed 's/,$//' | sed 's/,/, /g') | $(get_agent_epics $agent | tr '\n' ',' | sed 's/    - //g' | sed 's/,$//' | sed 's/,/, /g') |" >> agent-dashboard.md
    done
    
    cat >> "agent-dashboard.md" << EOF

## Quick Actions

- [View Task Assignments](agent-task-assignments.md)
- [View Agent Configurations](.)
- [Monitor Agent Performance](#)
- [Update Agent Settings](#)

## Performance Metrics

*Metrics will be populated once agents begin work*

- Total Tasks Completed: 0
- Average Velocity: 0 pts/week
- Quality Score: 0%
- Collaboration Score: 0%
EOF
    
    echo -e "${GREEN}✓ Dashboard created: agent-dashboard.md${NC}"
}

finalize_agent_creation() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}     ✅ AGENT CREATION COMPLETE                         ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "📊 Summary:"
    echo "  • Agents Created: ${#SELECTED_AGENTS[@]}"
    echo "  • Configurations Generated: ${#SELECTED_AGENTS[@]}"
    echo "  • Task Assignments: Documented"
    echo "  • Dashboard: Created"
    echo ""
    echo "📁 Generated Files:"
    for agent in "${SELECTED_AGENTS[@]}"; do
        echo "  • agent-config-${agent}.yaml"
    done
    echo "  • agent-task-assignments.md"
    echo "  • agent-dashboard.md"
    echo ""
    echo "🚀 Next Steps:"
    echo "  1. Review agent configurations"
    echo "  2. Fine-tune task assignments"
    echo "  3. Set up agent monitoring"
    echo "  4. Begin development with agent assistance"
    echo ""
    echo "💡 Tips:"
    echo "  • Agents work best with clear, well-defined tasks"
    echo "  • Regular sync meetings improve collaboration"
    echo "  • Monitor agent metrics to optimize performance"
    echo "  • Update configurations as project evolves"
}

# Main execution
main() {
    show_banner
    
    # Phase 1: Project Analysis
    analyze_project
    
    # Phase 2: Agent Recommendations
    recommend_agents
    
    # Phase 3: Agent Selection with Approval
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🤖 AGENT APPROVAL PROCESS${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "For each recommended agent, you'll be asked to approve its creation."
    echo "You can also request details about what each agent will do."
    echo ""
    
    read -p "Ready to review agents? (y/n): " ready
    if [[ ! $ready =~ ^[Yy]$ ]]; then
        echo "Agent creation cancelled."
        exit 0
    fi
    
    echo ""
    for agent in "${RECOMMENDED_AGENTS[@]}"; do
        prompt_agent_creation "$agent"
    done
    
    # Phase 4: Additional Agent Selection
    select_additional_agents
    
    if [ ${#SELECTED_AGENTS[@]} -eq 0 ]; then
        echo ""
        echo -e "${YELLOW}No agents selected. Exiting.${NC}"
        exit 0
    fi
    
    # Phase 5: Create Agent Configurations
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}⚙️ CREATING AGENT CONFIGURATIONS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for agent in "${SELECTED_AGENTS[@]}"; do
        create_agent_config "$agent"
    done
    
    # Phase 6: Task Assignment
    assign_tasks_to_agents
    
    # Phase 7: Create Dashboard
    create_agent_dashboard
    
    # Phase 8: Finalize
    finalize_agent_creation
}

# Run main function
main "$@"