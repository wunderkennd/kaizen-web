#!/bin/bash
# GitHub Issue Creation Commands for KAIZEN Platform
# Generated on Sun Oct 19 19:14:01 EDT 2025

# Create labels first
gh label create "001-adaptive-platform" --description "Core adaptive platform tasks" --color "0052CC"
gh label create "002-ab-testing" --description "A/B testing infrastructure tasks" --color "00875A"
gh label create "003-multivariate" --description "Multivariate experimentation tasks" --color "5319E7"
gh label create "parallel" --description "Can be executed in parallel" --color "FBCA04"
gh label create "blocked" --description "Blocked by dependencies" --color "D93F0B"
gh label create "in-progress" --description "Currently being worked on" --color "0E8A16"

# Phase 3.1: Project Setup & Infrastructure (T001-T010)
gh issue create \
  --title "[T001] Create repository structure per plan.md microservices layout" \
  --body "## Task: T001

**Description**: Create repository structure per plan.md microservices layout
**File Path**: `root directory`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: No
**Status**: Done


### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,done"

gh issue create \
  --title "[T002] Initialize Next.js 14 frontend with TypeScript" \
  --body "## Task: T002

**Description**: Initialize Next.js 14 frontend with TypeScript
**File Path**: `frontend/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: Done
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel,done"

gh issue create \
  --title "[T003] Initialize Rust workspace for kre-engine" \
  --body "## Task: T003

**Description**: Initialize Rust workspace for kre-engine
**File Path**: `services/kre-engine/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: Done
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel,done"

gh issue create \
  --title "[T004] Initialize Go module for genui-orchestrator" \
  --body "## Task: T004

**Description**: Initialize Go module for genui-orchestrator
**File Path**: `services/genui-orchestrator/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: Done
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel,done"

gh issue create \
  --title "[T005] Initialize Go module for user-context" \
  --body "## Task: T005

**Description**: Initialize Go module for user-context
**File Path**: `services/user-context/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: Done
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel,done"

gh issue create \
  --title "[T006] Initialize Python FastAPI project for ai-sommelier" \
  --body "## Task: T006

**Description**: Initialize Python FastAPI project for ai-sommelier
**File Path**: `services/ai-sommelier/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: Done
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel,done"

gh issue create \
  --title "[T007] Initialize Python/Rust hybrid for pcm-classifier" \
  --body "## Task: T007

**Description**: Initialize Python/Rust hybrid for pcm-classifier
**File Path**: `services/pcm-classifier/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: Done
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel,done"

gh issue create \
  --title "[T008] Initialize Rust project for streaming-adapter" \
  --body "## Task: T008

**Description**: Initialize Rust project for streaming-adapter
**File Path**: `services/streaming-adapter/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T009] Create docker-compose.yml with PostgreSQL, Redis, and service definitions" \
  --body "## Task: T009

**Description**: Create docker-compose.yml with PostgreSQL, Redis, and service definitions
**File Path**: `root directory`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: No
**Status**: To Do
**Dependencies**: T001-T008

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform"

gh issue create \
  --title "[T010] Setup shared contracts and protos directories with build scripts" \
  --body "## Task: T010

**Description**: Setup shared contracts and protos directories with build scripts
**File Path**: `shared/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T001

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

# Phase 3.2: Database & Migrations (T011-T015)
gh issue create \
  --title "[T011] Create PostgreSQL schema migrations for all 11 entities" \
  --body "## Task: T011

**Description**: Create PostgreSQL schema migrations for all 11 entities
**File Path**: `migrations/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: No
**Status**: To Do
**Dependencies**: T009

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform"

gh issue create \
  --title "[T012] Create migration for UserProfile table with PCM stages" \
  --body "## Task: T012

**Description**: Create migration for UserProfile table with PCM stages
**File Path**: `migrations/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T011

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T013] Create migration for ContextSnapshot and UIConfiguration tables" \
  --body "## Task: T013

**Description**: Create migration for ContextSnapshot and UIConfiguration tables
**File Path**: `migrations/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T011

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T014] Create migration for AdaptationRule and RuleSetVersion tables" \
  --body "## Task: T014

**Description**: Create migration for AdaptationRule and RuleSetVersion tables
**File Path**: `migrations/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T011

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T015] Create migration for ContentItem and DiscoveryQuery tables" \
  --body "## Task: T015

**Description**: Create migration for ContentItem and DiscoveryQuery tables
**File Path**: `migrations/`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T011

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

# Phase 3.3: Contract Tests (TDD - MUST FAIL FIRST) (T016-T025)
gh issue create \
  --title "[T016] GraphQL schema test for generateUI query" \
  --body "## Task: T016

**Description**: GraphQL schema test for generateUI query
**File Path**: `frontend/tests/contract/test_genui_query.ts`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T002

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T017] GraphQL schema test for searchContent query" \
  --body "## Task: T017

**Description**: GraphQL schema test for searchContent query
**File Path**: `frontend/tests/contract/test_search_query.ts`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T002

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T018] GraphQL schema test for rerankComponents mutation" \
  --body "## Task: T018

**Description**: GraphQL schema test for rerankComponents mutation
**File Path**: `frontend/tests/contract/test_rerank_mutation.ts`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T002

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T019] OpenAPI contract test for POST /ui/generate" \
  --body "## Task: T019

**Description**: OpenAPI contract test for POST /ui/generate
**File Path**: `services/genui-orchestrator/tests/contract_test.go`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T004

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

gh issue create \
  --title "[T020] OpenAPI contract test for POST /ui/rerank" \
  --body "## Task: T020

**Description**: OpenAPI contract test for POST /ui/rerank
**File Path**: `services/genui-orchestrator/tests/rerank_test.go`
**Specification**: 001-adaptive-platform
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T004

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "001-adaptive-platform,parallel"

# Sample A/B Testing Tasks
gh issue create \
  --title "[T105] Initialize experiment-service Go module" \
  --body "## Task: T105

**Description**: Initialize experiment-service Go module
**File Path**: `services/experiment-service/`
**Specification**: 002-ab-testing
**Can Run in Parallel**: Yes
**Status**: To Do


### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "002-ab-testing,parallel"

gh issue create \
  --title "[T106] Create PostgreSQL schema for experiments" \
  --body "## Task: T106

**Description**: Create PostgreSQL schema for experiments
**File Path**: `migrations/experiment_tables.sql`
**Specification**: 002-ab-testing
**Can Run in Parallel**: No
**Status**: To Do
**Dependencies**: T105

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "002-ab-testing"

# Sample Multivariate Tasks
gh issue create \
  --title "[T123] Factorial design generator" \
  --body "## Task: T123

**Description**: Factorial design generator
**File Path**: `services/experiment-service/internal/design/factorial.go`
**Specification**: 003-multivariate
**Can Run in Parallel**: Yes
**Status**: To Do
**Dependencies**: T105

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "003-multivariate,parallel"

gh issue create \
  --title "[T131] Initialize bandit-service Python module" \
  --body "## Task: T131

**Description**: Initialize bandit-service Python module
**File Path**: `services/bandit-service/`
**Specification**: 003-multivariate
**Can Run in Parallel**: Yes
**Status**: To Do


### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \
  --label "003-multivariate,parallel"


# To execute all commands:
# chmod +x issue-commands.sh && ./issue-commands.sh
