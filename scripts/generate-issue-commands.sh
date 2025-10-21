#!/bin/bash

# Script to generate GitHub issue creation commands
# Output can be redirected to a file and executed when permissions are available

echo "#!/bin/bash"
echo "# GitHub Issue Creation Commands for KAIZEN Platform"
echo "# Generated on $(date)"
echo ""
echo "# Create labels first"
echo 'gh label create "001-adaptive-platform" --description "Core adaptive platform tasks" --color "0052CC"'
echo 'gh label create "002-ab-testing" --description "A/B testing infrastructure tasks" --color "00875A"'
echo 'gh label create "003-multivariate" --description "Multivariate experimentation tasks" --color "5319E7"'
echo 'gh label create "parallel" --description "Can be executed in parallel" --color "FBCA04"'
echo 'gh label create "blocked" --description "Blocked by dependencies" --color "D93F0B"'
echo 'gh label create "in-progress" --description "Currently being worked on" --color "0E8A16"'
echo ""

# Function to generate issue creation command
generate_issue_command() {
    local task_id="$1"
    local description="$2"
    local file_path="$3"
    local spec="$4"
    local is_parallel="$5"
    local dependencies="$6"
    local status="$7"
    
    local title="[${task_id}] ${description}"
    local labels="${spec}"
    
    if [[ -n "$is_parallel" ]]; then
        labels="${labels},parallel"
    fi
    
    if [[ "$status" == "Done" ]]; then
        labels="${labels},done"
    fi
    
    cat <<EOF
gh issue create \\
  --title "${title}" \\
  --body "## Task: ${task_id}

**Description**: ${description}
**File Path**: \`${file_path}\`
**Specification**: ${spec}
**Can Run in Parallel**: ${is_parallel:-No}
**Status**: ${status}
${dependencies:+**Dependencies**: ${dependencies}}

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated" \\
  --label "${labels}"

EOF
}

echo "# Phase 3.1: Project Setup & Infrastructure (T001-T010)"
generate_issue_command "T001" "Create repository structure per plan.md microservices layout" "root directory" "001-adaptive-platform" "" "" "Done"
generate_issue_command "T002" "Initialize Next.js 14 frontend with TypeScript" "frontend/" "001-adaptive-platform" "Yes" "T001" "Done"
generate_issue_command "T003" "Initialize Rust workspace for kre-engine" "services/kre-engine/" "001-adaptive-platform" "Yes" "T001" "Done"
generate_issue_command "T004" "Initialize Go module for genui-orchestrator" "services/genui-orchestrator/" "001-adaptive-platform" "Yes" "T001" "Done"
generate_issue_command "T005" "Initialize Go module for user-context" "services/user-context/" "001-adaptive-platform" "Yes" "T001" "Done"
generate_issue_command "T006" "Initialize Python FastAPI project for ai-sommelier" "services/ai-sommelier/" "001-adaptive-platform" "Yes" "T001" "Done"
generate_issue_command "T007" "Initialize Python/Rust hybrid for pcm-classifier" "services/pcm-classifier/" "001-adaptive-platform" "Yes" "T001" "Done"
generate_issue_command "T008" "Initialize Rust project for streaming-adapter" "services/streaming-adapter/" "001-adaptive-platform" "Yes" "T001" "To Do"
generate_issue_command "T009" "Create docker-compose.yml with PostgreSQL, Redis, and service definitions" "root directory" "001-adaptive-platform" "" "T001-T008" "To Do"
generate_issue_command "T010" "Setup shared contracts and protos directories with build scripts" "shared/" "001-adaptive-platform" "Yes" "T001" "To Do"

echo "# Phase 3.2: Database & Migrations (T011-T015)"
generate_issue_command "T011" "Create PostgreSQL schema migrations for all 11 entities" "migrations/" "001-adaptive-platform" "" "T009" "To Do"
generate_issue_command "T012" "Create migration for UserProfile table with PCM stages" "migrations/" "001-adaptive-platform" "Yes" "T011" "To Do"
generate_issue_command "T013" "Create migration for ContextSnapshot and UIConfiguration tables" "migrations/" "001-adaptive-platform" "Yes" "T011" "To Do"
generate_issue_command "T014" "Create migration for AdaptationRule and RuleSetVersion tables" "migrations/" "001-adaptive-platform" "Yes" "T011" "To Do"
generate_issue_command "T015" "Create migration for ContentItem and DiscoveryQuery tables" "migrations/" "001-adaptive-platform" "Yes" "T011" "To Do"

echo "# Phase 3.3: Contract Tests (TDD - MUST FAIL FIRST) (T016-T025)"
generate_issue_command "T016" "GraphQL schema test for generateUI query" "frontend/tests/contract/test_genui_query.ts" "001-adaptive-platform" "Yes" "T002" "To Do"
generate_issue_command "T017" "GraphQL schema test for searchContent query" "frontend/tests/contract/test_search_query.ts" "001-adaptive-platform" "Yes" "T002" "To Do"
generate_issue_command "T018" "GraphQL schema test for rerankComponents mutation" "frontend/tests/contract/test_rerank_mutation.ts" "001-adaptive-platform" "Yes" "T002" "To Do"
generate_issue_command "T019" "OpenAPI contract test for POST /ui/generate" "services/genui-orchestrator/tests/contract_test.go" "001-adaptive-platform" "Yes" "T004" "To Do"
generate_issue_command "T020" "OpenAPI contract test for POST /ui/rerank" "services/genui-orchestrator/tests/rerank_test.go" "001-adaptive-platform" "Yes" "T004" "To Do"

echo "# Sample A/B Testing Tasks"
generate_issue_command "T105" "Initialize experiment-service Go module" "services/experiment-service/" "002-ab-testing" "Yes" "" "To Do"
generate_issue_command "T106" "Create PostgreSQL schema for experiments" "migrations/experiment_tables.sql" "002-ab-testing" "" "T105" "To Do"

echo "# Sample Multivariate Tasks"
generate_issue_command "T123" "Factorial design generator" "services/experiment-service/internal/design/factorial.go" "003-multivariate" "Yes" "T105" "To Do"
generate_issue_command "T131" "Initialize bandit-service Python module" "services/bandit-service/" "003-multivariate" "Yes" "" "To Do"

echo ""
echo "# To execute all commands:"
echo "# chmod +x issue-commands.sh && ./issue-commands.sh"