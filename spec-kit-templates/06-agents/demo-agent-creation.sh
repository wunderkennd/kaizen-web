#!/bin/bash

# Demo Script: Shows the agent creation process
# This demonstrates how the interactive agent approval works

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}"
echo "════════════════════════════════════════════════════════"
echo "     🤖 AGENT CREATION DEMO                             "
echo "════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo "This demo shows how the sub-agent creation process works"
echo "in the enhanced spec-kit system."
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1: Project Analysis
echo -e "${YELLOW}Step 1: Project Analysis${NC}"
echo "The system analyzes your project specifications to identify:"
echo "  • Technology stack (backend, frontend, database)"
echo "  • Architecture patterns (microservices, monolithic)"
echo "  • Special requirements (ML, security, compliance)"
echo ""
sleep 2

echo -e "${CYAN}📊 Sample Analysis Results:${NC}"
echo "  ✓ Backend services detected (REST/GraphQL APIs)"
echo "  ✓ Frontend components detected (React/Next.js)"
echo "  ✓ Database operations detected (PostgreSQL)"
echo "  ✓ Cloud infrastructure detected (GCP/Cloud Run)"
echo "  ✓ Testing requirements detected (TDD)"
echo "  ✓ Machine learning components detected"
echo ""
sleep 2

# Step 2: Agent Recommendations
echo -e "${YELLOW}Step 2: Agent Recommendations${NC}"
echo "Based on the analysis, the system recommends:"
echo ""
echo -e "${CYAN}🎯 RECOMMENDED AGENTS:${NC}"
echo ""
echo "  1️⃣  Backend Development Specialist"
echo "      • Handles APIs, databases, business logic"
echo "      • Assigned to: data-layer, core-services epics"
echo ""
echo "  2️⃣  Frontend Development Specialist"
echo "      • Implements UI/UX, components, state management"
echo "      • Assigned to: frontend, ui-components epics"
echo ""
echo "  3️⃣  DevOps & Infrastructure Engineer"
echo "      • Manages Terraform, CI/CD, cloud services"
echo "      • Assigned to: infrastructure, cicd epics"
echo ""
echo "  4️⃣  Testing & QA Specialist"
echo "      • Implements TDD, E2E tests, coverage"
echo "      • Assigned to: testing, quality-assurance epics"
echo ""
echo "  5️⃣  Data & Analytics Engineer"
echo "      • Handles ML pipelines, data processing"
echo "      • Assigned to: data-pipeline, machine-learning epics"
echo ""
sleep 3

# Step 3: Interactive Approval
echo -e "${YELLOW}Step 3: Interactive Approval Process${NC}"
echo "For each recommended agent, you'll see:"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔧 Backend Development Specialist${NC}"
echo "   Handles server-side logic, APIs, and data operations"
echo "   Skills: REST/GraphQL/gRPC, databases, business logic"
echo "   Epics: data-layer, core-services, api-development"
echo ""
echo -e "${GREEN}Create this agent? (y/n/details): ${NC}[User would enter: y]"
echo -e "${GREEN}✓ Agent added to creation queue${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
sleep 2

# Step 4: Configuration Generation
echo -e "${YELLOW}Step 4: Agent Configuration${NC}"
echo "For each approved agent, the system generates:"
echo ""
echo -e "${CYAN}📄 agent-config-backend-specialist.yaml${NC}"
cat << 'EOF'
agent:
  id: backend-specialist
  name: "Backend Development Specialist"
  project: "KAIZEN Platform"
  
capabilities:
  - API development (REST/GraphQL/gRPC)
  - Database design and optimization
  - Business logic implementation
  
assigned_epics:
  - epic:data-layer
  - epic:core-services
  
task_filters:
  labels: [backend, api, database]
  keywords: [API, service, endpoint, model]
EOF
echo ""
sleep 2

# Step 5: Task Assignment
echo -e "${YELLOW}Step 5: Task Assignment${NC}"
echo "Agents are assigned tasks based on:"
echo "  • Epic associations"
echo "  • Label matching"
echo "  • Keyword detection"
echo ""
echo "Example assignments:"
echo "  • Backend Specialist → T026-T050 (Core Services)"
echo "  • Frontend Specialist → T051-T068 (UI Components)"
echo "  • DevOps Engineer → T183-T190 (Cloud Run)"
echo ""
sleep 2

# Step 6: Collaboration Setup
echo -e "${YELLOW}Step 6: Collaboration Matrix${NC}"
echo "The system defines how agents work together:"
echo ""
echo "┌─────────────────────────────────────────────────────┐"
echo "│ Agent Collaboration Patterns                        │"
echo "├─────────────────────────────────────────────────────┤"
echo "│ • API Development:                                  │"
echo "│   Backend + Documentation + Testing                 │"
echo "│                                                      │"
echo "│ • Full-Stack Feature:                               │"
echo "│   Backend + Frontend + Testing                      │"
echo "│                                                      │"
echo "│ • Infrastructure Setup:                             │"
echo "│   DevOps + Security + Performance                   │"
echo "└─────────────────────────────────────────────────────┘"
echo ""
sleep 2

# Step 7: Final Output
echo -e "${YELLOW}Step 7: Generated Outputs${NC}"
echo "The process creates:"
echo ""
echo "  📁 Configuration Files:"
echo "     • agent-config-*.yaml (one per agent)"
echo ""
echo "  📊 Documentation:"
echo "     • agent-dashboard.md (overview & metrics)"
echo "     • agent-task-assignments.md (task mapping)"
echo ""
echo "  🔗 Integration:"
echo "     • Agents linked to GitHub issues"
echo "     • Epic and milestone associations"
echo "     • Collaboration workflows defined"
echo ""
sleep 2

# Summary
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}     ✅ DEMO COMPLETE                                   ${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo "This demonstration showed how the spec-kit:"
echo "  1. Analyzes your project requirements"
echo "  2. Recommends appropriate specialized agents"
echo "  3. Gets your approval for each agent"
echo "  4. Creates detailed configurations"
echo "  5. Assigns tasks to agents"
echo "  6. Sets up collaboration patterns"
echo "  7. Generates documentation and dashboards"
echo ""
echo "The actual process is interactive and customized"
echo "to your specific project needs."
echo ""
echo -e "${BLUE}To run the real agent creation:${NC}"
echo "  cd spec-kit-templates/06-agents/"
echo "  ./create-agents.sh"
echo ""