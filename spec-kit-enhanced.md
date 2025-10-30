# Enhanced Spec-Kit: From Specification to GitHub Project

## 🎯 Overview

This enhanced spec-kit provides a complete workflow for transforming project specifications into a fully organized GitHub project with issues, milestones, epics, and labels.

---

## 📋 Phase 1: Specification Development

### 1.1 Core Specification Structure
Create your specification with this structure:
```
project-name/
├── specs/
│   ├── 001-main-platform/
│   │   ├── spec.md          # Main specification
│   │   ├── tasks.md          # Task breakdown (T001-TXXX)
│   │   ├── data-model.md     # Data structures
│   │   └── contracts/        # API contracts
│   │       ├── service1.yaml
│   │       └── service2.yaml
│   └── 002-feature-area/
│       └── ...
```

### 1.2 Task Definition Format
Each task in `tasks.md` should follow:
```markdown
### T001: Task Title
**Component**: Service/Area
**Dependencies**: T000 (if any)
**Effort**: Story points
**Description**: Clear description of what needs to be done
```

---

## 📋 Phase 2: Task Extraction & Issue Creation

### 2.1 Create Task Extraction Script
```bash
#!/bin/bash
# scripts/extract-tasks.sh

# Extract all tasks from specification files
echo "Extracting tasks from specifications..."

# Parse tasks.md files and generate issue creation commands
for spec_dir in specs/*/; do
    spec_name=$(basename "$spec_dir")
    tasks_file="$spec_dir/tasks.md"
    
    if [ -f "$tasks_file" ]; then
        # Extract tasks using grep/awk
        grep "^### T[0-9]" "$tasks_file" | while read -r line; do
            task_id=$(echo "$line" | grep -o 'T[0-9]\+')
            task_title=$(echo "$line" | sed 's/### T[0-9]\+: //')
            echo "$task_id|$task_title|$spec_name"
        done
    fi
done > tasks.csv
```

### 2.2 Create GitHub Issues Script
```bash
#!/bin/bash
# scripts/create-all-issues.sh

# Create issues from extracted tasks
while IFS='|' read -r task_id title spec_name; do
    gh issue create \
        --title "[$task_id] $title" \
        --body "Task from $spec_name specification" \
        --label "$spec_name"
done < tasks.csv
```

---

## 📋 Phase 3: Epic Organization

### 3.1 Define Epic Structure
Create epic mapping in `epics.yaml`:
```yaml
epics:
  - id: foundation
    name: "Foundation & Infrastructure"
    color: "0052cc"
    tasks: ["T001-T010", "T165-T174", "T183-T190"]
    
  - id: data-layer
    name: "Data Layer & Models"
    color: "5319e7"
    tasks: ["T011-T015", "T026-T036"]
    
  - id: core-services
    name: "Core Services"
    color: "b60205"
    tasks: ["T037-T050"]
    
  - id: frontend
    name: "Frontend & UI"
    color: "f9d0c4"
    tasks: ["T051-T057", "T063-T068"]
    
  - id: testing
    name: "Testing & QA"
    color: "1d76db"
    tasks: ["T016-T025", "T058-T062"]
    
  - id: cicd
    name: "CI/CD & DevOps"
    color: "006b75"
    tasks: ["T175-T182"]
    
  - id: operations
    name: "Platform Operations"
    color: "fbca04"
    tasks: ["T071-T080"]
    
  - id: experimentation
    name: "Experimentation"
    color: "c5def5"
    tasks: ["T099-T164"]
```

### 3.2 Create Epic Labels Script
```bash
#!/bin/bash
# scripts/create-epic-labels.sh

# Create epic labels
gh label create "epic:foundation" --color "0052cc" --description "Foundation & Infrastructure"
gh label create "epic:data-layer" --color "5319e7" --description "Data Layer & Models"
gh label create "epic:core-services" --color "b60205" --description "Core Services"
gh label create "epic:frontend" --color "f9d0c4" --description "Frontend & UI"
gh label create "epic:testing" --color "1d76db" --description "Testing & QA"
gh label create "epic:cicd" --color "006b75" --description "CI/CD & DevOps"
gh label create "epic:operations" --color "fbca04" --description "Platform Operations"
gh label create "epic:experimentation" --color "c5def5" --description "Experimentation"

# Create priority labels
gh label create "P0-critical" --color "d73a4a" --description "Critical Priority"
gh label create "P1-high" --color "e99695" --description "High Priority"
gh label create "P2-medium" --color "fef2c0" --description "Medium Priority"
gh label create "P3-low" --color "c2e0c6" --description "Low Priority"

# Create size labels
gh label create "size:XS" --color "ffffff" --description "1-2 story points"
gh label create "size:S" --color "c2e0c6" --description "3-5 story points"
gh label create "size:M" --color "fef2c0" --description "5-8 story points"
gh label create "size:L" --color "f9d0c4" --description "8-13 story points"
gh label create "size:XL" --color "e99695" --description "13+ story points"
```

---

## 📋 Phase 4: Milestone Creation

### 4.1 Define Milestones
Create `milestones.yaml`:
```yaml
milestones:
  - number: 1
    title: "M1: MVP Foundation"
    description: "Infrastructure and basic setup"
    weeks: 4
    epics: ["foundation", "data-layer"]
    tasks: ["T001-T015", "T183-T190"]
    
  - number: 2
    title: "M2: Core Platform"
    description: "Core services and business logic"
    weeks: 10
    epics: ["core-services", "data-layer"]
    tasks: ["T026-T050"]
    
  - number: 3
    title: "M3: User Experience"
    description: "Frontend and user features"
    weeks: 14
    epics: ["frontend", "testing"]
    tasks: ["T051-T062"]
    
  - number: 4
    title: "M4: Production Ready"
    description: "Deployment and operations"
    weeks: 18
    epics: ["cicd", "operations"]
    tasks: ["T071-T080", "T175-T182"]
    
  - number: 5
    title: "M5: Experimentation"
    description: "A/B testing and ML"
    weeks: 24
    epics: ["experimentation"]
    tasks: ["T099-T164"]
```

### 4.2 Create Milestones Script
```bash
#!/bin/bash
# scripts/create-milestones.sh

# Calculate dates from current date
current_date=$(date +%Y-%m-%d)

# Create milestones
gh api repos/$OWNER/$REPO/milestones \
  --method POST \
  -f title="M1: MVP Foundation" \
  -f description="Infrastructure and basic setup" \
  -f due_on="$(date -d "$current_date + 4 weeks" +%Y-%m-%dT23:59:59Z)"

# Repeat for other milestones...
```

---

## 📋 Phase 5: Issue Enhancement

### 5.1 Enrich Issues with Context
```bash
#!/bin/bash
# scripts/enrich-issues.sh

enrich_issue() {
    local issue_num="$1"
    local task_id="$2"
    local title="$3"
    local epic="$4"
    local size="$5"
    local priority="$6"
    
    # Generate rich issue body
    local body="# Task $task_id: $title

## 📋 Overview
**Epic**: $epic
**Size**: $size story points
**Priority**: $priority

## 👤 User Story
As a [role], I want [feature] so that [benefit]

## ✅ Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## 🔧 Technical Context
Implementation notes and technical details

## 🧪 Testing Strategy
How this will be tested

## 📚 Resources
- [Documentation](link)
- [Related Issues](#)

---
*Part of the KAIZEN Platform*"
    
    # Update the issue
    gh issue edit "$issue_num" --body "$body"
    
    # Add labels
    gh issue edit "$issue_num" \
        --add-label "epic:$epic" \
        --add-label "$priority" \
        --add-label "size:$size"
}
```

---

## 📋 Phase 6: Automation Pipeline

### 6.1 Master Orchestration Script
```bash
#!/bin/bash
# scripts/setup-github-project.sh

echo "Setting up GitHub project from specification..."

# Step 1: Extract tasks from specs
./scripts/extract-tasks.sh

# Step 2: Create labels
./scripts/create-epic-labels.sh

# Step 3: Create milestones
./scripts/create-milestones.sh

# Step 4: Create issues
./scripts/create-all-issues.sh

# Step 5: Enrich issues with context
./scripts/enrich-issues.sh

# Step 6: Assign issues to milestones
./scripts/assign-to-milestones.sh

# Step 7: Create project board
gh project create "KAIZEN Platform" --owner $OWNER

# Step 8: Generate reports
./scripts/generate-epic-report.sh > docs/epics-and-milestones.md
./scripts/generate-roadmap.sh > docs/roadmap.md

echo "✅ GitHub project setup complete!"
echo "View at: https://github.com/$OWNER/$REPO"
```

---

## 📋 Phase 7: Reporting & Visualization

### 7.1 Epic Progress Report
```bash
#!/bin/bash
# scripts/generate-epic-report.sh

echo "# Epic Progress Report"
echo "Generated: $(date)"
echo ""

# For each epic, count completed vs total
for epic in foundation data-layer core-services frontend testing cicd operations experimentation; do
    total=$(gh issue list --label "epic:$epic" --state all --json number | jq length)
    closed=$(gh issue list --label "epic:$epic" --state closed --json number | jq length)
    percent=$((closed * 100 / total))
    
    echo "## Epic: $epic"
    echo "Progress: $closed/$total ($percent%)"
    echo ""
done
```

### 7.2 Burndown Chart Data
```python
#!/usr/bin/env python3
# scripts/generate-burndown.py

import json
import subprocess
from datetime import datetime, timedelta

# Get all issues with their creation and close dates
result = subprocess.run(['gh', 'issue', 'list', '--state', 'all', '--limit', '500', '--json', 'number,createdAt,closedAt,labels'], capture_output=True)
issues = json.loads(result.stdout)

# Group by milestone and generate burndown data
milestones = {}
for issue in issues:
    # Process and aggregate data
    pass

# Output CSV for charting
print("date,remaining_points,completed_points")
# ... generate daily data points
```

---

## 📋 Phase 8: Sub-Agent Definition & Creation

### 8.1 Agent Analysis Script
```bash
#!/bin/bash
# scripts/analyze-and-create-agents.sh

# Analyze project characteristics
analyze_project_needs() {
    echo "Analyzing project requirements for agent recommendations..."
    
    # Check for different technology stacks and requirements
    local has_backend=$(grep -c "API\|backend\|service" specs/*/tasks.md)
    local has_frontend=$(grep -c "frontend\|UI\|React" specs/*/tasks.md)
    local has_ml=$(grep -c "ML\|machine learning\|model" specs/*/tasks.md)
    local has_security=$(grep -c "security\|auth\|compliance" specs/*/tasks.md)
    
    # Generate recommendations
    echo "Recommended agents based on analysis:"
    [ "$has_backend" -gt 0 ] && echo "  • Backend Development Specialist"
    [ "$has_frontend" -gt 0 ] && echo "  • Frontend Development Specialist"
    [ "$has_ml" -gt 0 ] && echo "  • Data & Analytics Engineer"
    [ "$has_security" -gt 0 ] && echo "  • Security Specialist"
}

# Interactive agent approval
approve_agent() {
    local agent_name="$1"
    local agent_desc="$2"
    
    echo ""
    echo "Agent: $agent_name"
    echo "Description: $agent_desc"
    read -p "Create this agent? (y/n/details): " choice
    
    case $choice in
        y|Y) return 0 ;;
        n|N) return 1 ;;
        d|D) 
            show_agent_details "$agent_name"
            approve_agent "$agent_name" "$agent_desc"
            ;;
    esac
}

# Main execution
analyze_project_needs

# Get user approval for each recommended agent
for agent in "${RECOMMENDED_AGENTS[@]}"; do
    if approve_agent "$agent"; then
        create_agent_config "$agent"
        assign_tasks_to_agent "$agent"
    fi
done
```

### 8.2 Agent Configuration Template
```yaml
# agent-config-{agent-id}.yaml
agent:
  id: backend-specialist
  name: "Backend Development Specialist"
  created: 2024-01-20
  project: "Project Name"
  
capabilities:
  - API development (REST/GraphQL/gRPC)
  - Database design and optimization
  - Business logic implementation
  - Data modeling and validation
  
assigned_epics:
  - epic:data-layer
  - epic:core-services
  - epic:api-development
  
task_filters:
  labels:
    - backend
    - api
    - database
  keywords:
    - API
    - service
    - endpoint
    - database
    - model
  
collaboration:
  primary_collaborators:
    - frontend-specialist
    - testing-specialist
  report_to: project-manager
  
performance_metrics:
  expected_velocity: 20  # story points per week
  quality_threshold: 95  # percentage
```

### 8.3 Available Agent Types

| Agent Type | Focus Area | Primary Skills | Recommended For |
|------------|------------|----------------|-----------------|
| Backend Specialist | Server-side development | APIs, databases, business logic | All projects with backend |
| Frontend Specialist | UI/UX implementation | React, state management, responsive design | User-facing applications |
| DevOps Engineer | Infrastructure & deployment | Terraform, CI/CD, cloud services | Cloud-native projects |
| Testing Specialist | Quality assurance | TDD, E2E tests, coverage | High-reliability apps |
| Security Specialist | Security & compliance | Auth, encryption, auditing | Sensitive data handling |
| Data Engineer | Data & analytics | Pipelines, ML, warehousing | Data-driven applications |
| Documentation Specialist | Technical writing | Docs, API specs, guides | Open source/enterprise |
| Performance Engineer | Optimization | Profiling, caching, scaling | High-traffic systems |
| Migration Specialist | Legacy modernization | Refactoring, compatibility | Legacy upgrades |
| Integration Specialist | Third-party integrations | APIs, webhooks, events | Platform ecosystems |

---

## 📋 Phase 9: Maintenance & Updates

### 9.1 Sync Specification Changes
```bash
#!/bin/bash
# scripts/sync-spec-changes.sh

# Detect new tasks in spec files
git diff HEAD~1 specs/*/tasks.md | grep "^+### T" | while read -r line; do
    # Extract and create new issues
    task_id=$(echo "$line" | grep -o 'T[0-9]\+')
    # Create issue if it doesn't exist
    if ! gh issue list --search "$task_id in:title" | grep -q "$task_id"; then
        # Create new issue
        echo "Creating issue for new task $task_id"
    fi
done
```

### 9.2 Weekly Status Update
```bash
#!/bin/bash
# scripts/weekly-status.sh

echo "# Weekly Status Report - $(date +%Y-%m-%d)"
echo ""
echo "## Completed This Week"
gh issue list --state closed --search "closed:>$(date -d '7 days ago' +%Y-%m-%d)" --json number,title

echo ""
echo "## In Progress"
gh issue list --label "status:in-progress" --json number,title,assignee

echo ""
echo "## Blocked"
gh issue list --label "status:blocked" --json number,title,labels

echo ""
echo "## Next Week Priority"
gh issue list --label "P0-critical" --state open --limit 10 --json number,title
```

---

## 🚀 Quick Start

1. **Initialize your project:**
```bash
mkdir -p scripts docs specs
curl -o scripts/setup-github-project.sh https://example.com/spec-kit/setup.sh
chmod +x scripts/*.sh
```

2. **Configure GitHub:**
```bash
export OWNER="your-github-username"
export REPO="your-repo-name"
gh auth login
```

3. **Run the setup:**
```bash
./scripts/setup-github-project.sh
```

---

## 📊 Deliverables

After running the spec-kit, you'll have:

1. ✅ All tasks as GitHub issues
2. ✅ Epic labels for organization
3. ✅ Priority and size labels
4. ✅ Milestones with due dates
5. ✅ Enriched issue descriptions
6. ✅ Project board (optional)
7. ✅ Documentation (epics, roadmap)
8. ✅ Progress tracking reports

---

## 🔧 Customization

### Add Custom Labels
Edit `scripts/create-epic-labels.sh`:
```bash
gh label create "needs-design" --color "7057ff" --description "Needs design work"
gh label create "needs-review" --color "0e8a16" --description "Ready for review"
```

### Modify Epic Structure
Edit `epics.yaml` to define your own epic boundaries

### Change Milestone Timeline
Edit `milestones.yaml` to adjust milestone dates and scope

---

## 📚 Best Practices

1. **Keep task IDs sequential**: T001, T002, etc.
2. **Group related tasks**: Use number ranges for related work
3. **Size consistently**: Use Fibonacci for story points
4. **Update regularly**: Sync spec changes weekly
5. **Review epics quarterly**: Adjust epic boundaries as needed

---

## 🎯 Next Steps

After initial setup:
1. Assign team members to issues
2. Set up GitHub Projects views
3. Configure GitHub Actions for automation
4. Create team dashboards
5. Schedule regular epic reviews

---

*This enhanced spec-kit is part of the KAIZEN Platform toolkit*