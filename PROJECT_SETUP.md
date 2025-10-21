# KAIZEN Platform - GitHub Project Setup Guide

Since the GitHub CLI requires additional permissions, here's how to set up the project using the GitHub web interface:

## Step 1: Create the Project

1. Go to: https://github.com/wunderkennd/kaizen-web
2. Click on the "Projects" tab
3. Click "New project" button
4. Select "Board" template
5. Name it: "KAIZEN Adaptive Platform"
6. Set description: "Task tracking for KAIZEN adaptive platform (158 tasks)"

## Step 2: Configure Project Settings

### Custom Fields to Add:
Go to Settings → Custom Fields and add:

1. **Task ID** (Text field)
2. **Priority** (Single select): P0, P1, P2, P3
3. **Story Points** (Number): 1, 2, 3, 5, 8, 13
4. **Component** (Single select):
   - Frontend
   - KRE Engine
   - GenUI Orchestrator
   - User Context
   - AI Sommelier
   - PCM Classifier
   - Experiment Service
   - Bandit Service
5. **Dependencies** (Text field)
6. **Spec** (Single select):
   - 001-adaptive-platform
   - 002-ab-testing
   - 003-multivariate

### Board Columns:
1. 📋 Backlog
2. 🎯 To Do
3. 🚧 In Progress
4. 👀 In Review
5. ✅ Done
6. 🚫 Blocked

## Step 3: Import Issues

### Option A: Use CSV Import
1. Click "Add item" → "Add from repository"
2. Or use the `github-issues.csv` file we created
3. Bulk select and add to project

### Option B: Run Issue Commands
```bash
# Make the script executable
chmod +x scripts/issue-commands.sh

# Run it to create all issues
./scripts/issue-commands.sh
```

### Option C: Manual Sample Issues
Create these key issues manually to get started:

#### High Priority Core Platform Tasks:
```
Title: [T008] Initialize Rust project for streaming-adapter
Labels: 001-adaptive-platform, parallel
Description: Initialize streaming-adapter in services/streaming-adapter/
Priority: P0
Story Points: 3
Dependencies: T001
```

```
Title: [T009] Create docker-compose.yml
Labels: 001-adaptive-platform
Description: Docker setup with PostgreSQL, Redis, and services
Priority: P0
Story Points: 5
Dependencies: T001-T008
```

```
Title: [T010] Setup shared contracts and protos
Labels: 001-adaptive-platform, parallel
Description: Setup shared contracts and protos with build scripts
Priority: P0
Story Points: 3
Dependencies: T001
```

#### Contract Tests (TDD):
```
Title: [T016] GraphQL test for generateUI
Labels: 001-adaptive-platform, parallel
Description: GraphQL schema test for generateUI query
Priority: P0
Story Points: 3
Dependencies: T002
```

#### A/B Testing Tasks:
```
Title: [T105] Initialize experiment-service
Labels: 002-ab-testing, parallel
Description: Initialize experiment-service Go module
Priority: P1
Story Points: 3
```

#### Multivariate Tasks:
```
Title: [T131] Initialize bandit-service
Labels: 003-multivariate, parallel
Description: Initialize bandit-service Python module
Priority: P2
Story Points: 3
```

## Step 4: Set Up Automation

Go to Settings → Workflows and add:

1. **Auto-add issues**: When issue has label "001-adaptive-platform", "002-ab-testing", or "003-multivariate"
2. **Move to In Progress**: When issue is assigned
3. **Move to Done**: When issue is closed
4. **Move to Blocked**: When label "blocked" is added

## Step 5: Create Views

### View 1: Development Board (Default)
- Type: Board
- Group by: Status
- Filter: None

### View 2: Sprint Planning
- Type: Table
- Columns: Title, Task ID, Priority, Story Points, Dependencies, Assignee
- Filter: Status = "To Do"
- Sort: Priority (High to Low)

### View 3: Team Workload
- Type: Table
- Group by: Assignee
- Filter: Status = "In Progress"

### View 4: Roadmap
- Type: Roadmap (if available)
- Group by: Milestone/Spec
- Date field: Created date

## Quick Start Tasks

Based on our current progress, these tasks should be marked as DONE:
- T001: Repository structure ✅
- T002: Next.js frontend ✅
- T003: KRE Engine ✅
- T004: GenUI Orchestrator ✅
- T005: User Context ✅
- T006: AI Sommelier ✅
- T007: PCM Classifier ✅

Next priorities (To Do):
- T008: Streaming adapter
- T009: Docker compose
- T010: Shared contracts/protos
- T011-T015: Database migrations
- T016-T025: Contract tests (TDD)

## Tracking Metrics

The project will track:
- **Velocity**: Story points completed per week
- **Burndown**: Tasks remaining vs time
- **Cycle Time**: Time from "To Do" to "Done"
- **Blocked Time**: How long tasks stay blocked

## Success Milestones

- **Milestone 1**: Core Platform (T001-T098) - Target: Feb 2025
- **Milestone 2**: A/B Testing (T105-T122) - Target: Mar 2025
- **Milestone 3**: Multivariate (T123-T164) - Target: Apr 2025

## Team Assignment Strategy

- **Parallel tasks** (marked with [P]): Assign to different developers
- **Sequential tasks**: Keep with same developer for context
- **Contract tests**: Assign to QA/Test engineers
- **Service initialization**: Assign to backend developers
- **Frontend components**: Assign to frontend developers

## Daily Workflow

1. **Morning**: Check "In Progress" items
2. **Standup**: Review blocked items
3. **Planning**: Pick from "To Do" based on dependencies
4. **End of day**: Update task status

## Repository Integration

The project will automatically:
- Link PRs to issues when you use "Fixes #123" in PR description
- Update issue status when PRs are merged
- Track code review status
- Show CI/CD build status

---

For questions or issues with the setup, refer to:
- GitHub Projects documentation: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- Our project template: `.github/PROJECT_TEMPLATE.md`
- Issue generation scripts: `scripts/generate-issue-commands.sh`