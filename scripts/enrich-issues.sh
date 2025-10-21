#!/bin/bash

# Script to enrich all GitHub issues with detailed context, user stories, and acceptance criteria
# This updates existing issues with comprehensive information based on task type

echo "Enriching GitHub issues with detailed context..."
echo "This will update all 158 tasks with comprehensive information..."

# Counter for tracking
UPDATED=0
FAILED=0

# Function to update an issue with enriched content
update_issue() {
    local issue_number="$1"
    local body="$2"
    
    echo "Updating issue #${issue_number}..."
    
    gh issue edit "${issue_number}" \
        --body "${body}" 2>/dev/null && ((UPDATED++)) || ((FAILED++))
}

# Function to generate enriched content based on task type
generate_enriched_content() {
    local task_id="$1"
    local title="$2"
    local file_path="$3"
    local deps="$4"
    local type="$5"
    local component="$6"
    
    cat <<EOF
# Task ${task_id}: ${title}

## 📋 Overview
**Component**: ${component}
**File Path**: \`${file_path}\`
**Task Type**: ${type}
${deps:+**Dependencies**: ${deps}}

$(generate_user_story "$task_id" "$type" "$component")

$(generate_technical_context "$task_id" "$type" "$component")

$(generate_acceptance_criteria "$task_id" "$type" "$component")

$(generate_implementation_notes "$task_id" "$type" "$component")

$(generate_testing_requirements "$task_id" "$type")

## 🔗 Related Documentation
- [Project Specification](../specs/001-adaptive-platform/spec.md)
- [Data Model](../specs/001-adaptive-platform/data-model.md)
- [API Contracts](../specs/001-adaptive-platform/contracts/)

## 🏷️ Labels
- Component: ${component}
- Type: ${type}
- Priority: $(get_priority "$task_id")

---
*Part of the KAIZEN Adaptive Platform - Task tracking: [Project Board](https://github.com/wunderkennd/kaizen-web/projects)*
EOF
}

# Generate user story based on task type
generate_user_story() {
    local task_id="$1"
    local type="$2"
    local component="$3"
    
    case "$type" in
        "infrastructure")
            echo "## 👤 User Story
As a **platform engineer**
I want to **set up the ${component} infrastructure**
So that **the development team has a solid foundation for building services**"
            ;;
        "database")
            echo "## 👤 User Story
As a **backend developer**
I want to **have database schemas properly defined**
So that **I can persist and query data efficiently with type safety**"
            ;;
        "contract-test")
            echo "## 👤 User Story
As a **QA engineer**
I want to **have contract tests that fail before implementation**
So that **we follow TDD practices and ensure API contracts are met**"
            ;;
        "data-model")
            echo "## 👤 User Story
As a **backend developer**
I want to **have well-defined data models**
So that **I can implement business logic with clear entity relationships**"
            ;;
        "service")
            echo "## 👤 User Story
As a **system architect**
I want to **implement core service functionality**
So that **the platform can deliver adaptive experiences to users**"
            ;;
        "frontend")
            echo "## 👤 User Story
As a **frontend developer**
I want to **create reusable UI components**
So that **we can build consistent, adaptive interfaces across the platform**"
            ;;
        "integration-test")
            echo "## 👤 User Story
As a **product owner**
I want to **verify end-to-end functionality**
So that **users have a seamless experience across all platform features**"
            ;;
        *)
            echo "## 👤 User Story
As a **developer**
I want to **complete this task**
So that **the system functionality is enhanced**"
            ;;
    esac
}

# Generate technical context
generate_technical_context() {
    local task_id="$1"
    local type="$2"
    local component="$3"
    
    echo "## 🔧 Technical Context"
    
    case "$component" in
        "Frontend")
            echo "**Framework**: Next.js 14 with TypeScript
**Styling**: TailwindCSS with KDS design tokens
**State Management**: React Context + TanStack Query
**Testing**: Vitest for unit tests, Playwright for E2E"
            ;;
        "KRE Engine")
            echo "**Language**: Rust
**Framework**: Axum for HTTP, Tokio for async
**Database**: PostgreSQL with sqlx
**Testing**: Built-in Rust testing with cargo test"
            ;;
        "GenUI Orchestrator")
            echo "**Language**: Go
**Framework**: Gin for HTTP
**Communication**: gRPC for inter-service, GraphQL for frontend
**Testing**: Go testing package with testify"
            ;;
        "User Context")
            echo "**Language**: Go
**Framework**: Gin for HTTP
**Database**: PostgreSQL for profiles, Redis for sessions
**Testing**: Go testing with mock interfaces"
            ;;
        "AI Sommelier")
            echo "**Language**: Python 3.11+
**Framework**: FastAPI
**ML Libraries**: scikit-learn, transformers
**Vector DB**: Pinecone for semantic search
**Testing**: pytest with async support"
            ;;
        "Experiment Service")
            echo "**Language**: Go
**Framework**: Gin for HTTP
**Database**: PostgreSQL for experiments, Redis for assignments
**Statistics**: Built-in statistical functions + gonum"
            ;;
        "Bandit Service")
            echo "**Language**: Python
**Framework**: FastAPI
**ML Libraries**: NumPy, SciPy, scikit-learn
**Algorithms**: Thompson Sampling, UCB, Epsilon-Greedy
**Testing**: pytest with hypothesis for property-based tests"
            ;;
        *)
            echo "**Stack**: See project documentation for technology choices"
            ;;
    esac
}

# Generate detailed acceptance criteria
generate_acceptance_criteria() {
    local task_id="$1"
    local type="$2"
    local component="$3"
    
    echo "## ✅ Acceptance Criteria"
    
    case "$type" in
        "infrastructure")
            cat <<'CRITERIA'
- [ ] Service/module successfully initializes with `make init` or equivalent
- [ ] All dependencies are properly versioned in lock file
- [ ] README.md includes setup instructions and architecture overview
- [ ] Dockerfile builds successfully and passes health checks
- [ ] Environment variables are documented in `.env.example`
- [ ] Basic CI/CD workflow is configured (build, test, lint)
- [ ] Service connects to required infrastructure (DB, Redis, etc.)
- [ ] Logging is configured with appropriate levels
- [ ] Health check endpoint returns 200 OK at `/health`
CRITERIA
            ;;
        "database")
            cat <<'CRITERIA'
- [ ] Migration files follow naming convention: `YYYYMMDD_HHMMSS_description.sql`
- [ ] UP migration creates all required tables/columns with correct types
- [ ] DOWN migration cleanly reverses all changes
- [ ] Foreign key relationships are properly defined with constraints
- [ ] Appropriate indexes are created for query performance
- [ ] Migration runs successfully on clean database
- [ ] Migration is idempotent (can run multiple times safely)
- [ ] Test data seed script is provided for development
- [ ] Database schema is documented with table relationships
CRITERIA
            ;;
        "contract-test")
            cat <<'CRITERIA'
- [ ] Test file exists at specified path with proper naming
- [ ] Test MUST FAIL when run before implementation (TDD)
- [ ] Contract/schema definition is complete and accurate
- [ ] Test covers all required endpoints/operations
- [ ] Request validation tests are included
- [ ] Response format validation is included
- [ ] Error cases are properly tested (400, 401, 404, 500)
- [ ] Test uses proper mocking/stubbing for dependencies
- [ ] Test documentation explains expected behavior
- [ ] Performance expectations are validated (<500ms, etc.)
CRITERIA
            ;;
        "data-model")
            cat <<'CRITERIA'
- [ ] Model struct/class is defined with all required fields
- [ ] Field types match database schema exactly
- [ ] Validation rules are implemented (required, min/max, format)
- [ ] Relationships to other models are properly defined
- [ ] JSON serialization/deserialization works correctly
- [ ] Model includes necessary business logic methods
- [ ] Unit tests cover all model methods with >80% coverage
- [ ] Documentation includes usage examples
- [ ] Model follows project naming conventions
- [ ] Database queries are optimized (no N+1 problems)
CRITERIA
            ;;
        "service")
            cat <<'CRITERIA'
- [ ] Service implements all required API endpoints
- [ ] Business logic is properly separated from HTTP handling
- [ ] Error handling returns appropriate status codes and messages
- [ ] Input validation is comprehensive and secure
- [ ] Service integrates with required dependencies (DB, cache, etc.)
- [ ] Unit tests achieve >80% code coverage
- [ ] Integration tests verify key workflows
- [ ] Performance meets requirements (<500ms for GenUI, <50ms for assignment)
- [ ] Logging includes request IDs for tracing
- [ ] Metrics are exported for monitoring (Prometheus format)
- [ ] API documentation is auto-generated (OpenAPI/Swagger)
CRITERIA
            ;;
        "frontend")
            cat <<'CRITERIA'
- [ ] Component renders without errors in all supported browsers
- [ ] Component is fully typed with TypeScript (no `any` types)
- [ ] Component follows KDS design system guidelines
- [ ] Component is responsive (mobile, tablet, desktop)
- [ ] Component is accessible (WCAG 2.1 AA compliant)
- [ ] Component has Storybook stories for all states
- [ ] Unit tests cover all component logic (>80% coverage)
- [ ] Component performance is optimized (no unnecessary re-renders)
- [ ] Props are documented with JSDoc comments
- [ ] Component exports are properly configured in index.ts
- [ ] CSS follows BEM or CSS-in-JS conventions consistently
CRITERIA
            ;;
        "integration-test")
            cat <<'CRITERIA'
- [ ] Test covers complete user journey from start to finish
- [ ] Test runs successfully in CI environment
- [ ] Test is resilient to timing issues (proper waits/retries)
- [ ] Test cleanup runs after completion (no test pollution)
- [ ] Test covers happy path and key error scenarios
- [ ] Test validates UI state at each step
- [ ] Test checks API responses and database state
- [ ] Test execution time is reasonable (<2 minutes)
- [ ] Test failure messages are clear and actionable
- [ ] Test is tagged for selective execution (smoke, regression, etc.)
CRITERIA
            ;;
        *)
            cat <<'CRITERIA'
- [ ] Code compiles/runs without errors
- [ ] All tests pass
- [ ] Code follows project style guidelines
- [ ] Documentation is complete
- [ ] PR review approved
CRITERIA
            ;;
    esac
}

# Generate implementation notes
generate_implementation_notes() {
    local task_id="$1"
    local type="$2"
    local component="$3"
    
    echo "## 💡 Implementation Notes"
    
    case "$task_id" in
        T008)
            echo "- Use Rust with Tokio for async streaming
- Implement WebSocket and Server-Sent Events support
- Consider backpressure handling for high-throughput scenarios
- Use channels for inter-task communication"
            ;;
        T009)
            echo "- Include health checks for all services
- Use named volumes for data persistence
- Configure network isolation between services
- Add wait-for-it script for service dependencies
- Include both development and production configurations"
            ;;
        T010)
            echo "- Use buf for protobuf management
- Generate code for Go, Rust, and Python
- Include gRPC service definitions
- Version contracts using semantic versioning
- Add pre-commit hooks for proto linting"
            ;;
        T016|T017|T018)
            echo "- Use Apollo Client for GraphQL in tests
- Mock backend responses initially (TDD)
- Test both query and mutation operations
- Validate TypeScript types match schema
- Consider subscription testing for real-time features"
            ;;
        T037)
            echo "- Implement rule caching for performance
- Use a rules DSL for non-technical users
- Support hot-reloading of rules
- Log all rule evaluations for debugging
- Consider using a rules engine library (e.g., Drools concepts)"
            ;;
        T040)
            echo "- Pipeline stages: Fetch → Filter → Rank → Assemble → Optimize
- Use goroutines for parallel processing
- Implement circuit breakers for service calls
- Cache assembled configurations
- Support partial rendering on timeout"
            ;;
        T046)
            echo "- Use spaCy or Transformers for NLP
- Fine-tune on anime-specific terminology
- Support multiple languages (EN, JP)
- Implement query expansion for better recall
- Cache processed queries for performance"
            ;;
        *)
            echo "- Follow existing patterns in the codebase
- Consider performance implications
- Add appropriate logging and monitoring
- Write comprehensive tests
- Document any assumptions or decisions"
            ;;
    esac
}

# Generate testing requirements
generate_testing_requirements() {
    local task_id="$1"
    local type="$2"
    
    echo "## 🧪 Testing Requirements"
    
    case "$type" in
        "infrastructure")
            echo "- Unit tests for utility functions
- Integration tests for service connections
- Load tests for performance validation
- Security scanning for vulnerabilities"
            ;;
        "database")
            echo "- Test migrations on empty database
- Test rollback procedures
- Validate constraints and indexes
- Performance test with sample data"
            ;;
        "contract-test")
            echo "- Contract must fail before implementation
- Mock external dependencies
- Test all status codes
- Validate response schemas"
            ;;
        "service")
            echo "- Unit tests: >80% coverage
- Integration tests: key workflows
- Load tests: meet performance SLAs
- Contract tests: API compatibility"
            ;;
        "frontend")
            echo "- Unit tests: component logic
- Visual regression tests: Storybook
- E2E tests: user workflows
- Accessibility tests: WCAG compliance"
            ;;
        *)
            echo "- Write tests appropriate to the task type
- Ensure tests are maintainable
- Document test scenarios
- Include edge cases"
            ;;
    esac
}

# Get priority based on task ID
get_priority() {
    local task_id="$1"
    
    # Extract numeric part
    task_num=${task_id//[!0-9]/}
    
    if (( task_num <= 25 )); then
        echo "P0 (Critical)"
    elif (( task_num <= 50 )); then
        echo "P1 (High)"
    elif (( task_num <= 100 )); then
        echo "P2 (Medium)"
    else
        echo "P3 (Low)"
    fi
}

# Determine task type based on ID
get_task_type() {
    local task_id="$1"
    task_num=${task_id//[!0-9]/}
    
    if (( task_num <= 10 )); then
        echo "infrastructure"
    elif (( task_num <= 15 )); then
        echo "database"
    elif (( task_num <= 25 )); then
        echo "contract-test"
    elif (( task_num <= 36 )); then
        echo "data-model"
    elif (( task_num <= 50 )); then
        echo "service"
    elif (( task_num <= 60 )); then
        echo "frontend"
    elif (( task_num <= 68 )); then
        echo "integration-test"
    elif (( task_num <= 80 )); then
        echo "deployment"
    elif (( task_num <= 98 )); then
        echo "feature"
    elif (( task_num <= 122 )); then
        echo "experiment"
    else
        echo "ml-optimization"
    fi
}

# Determine component based on file path
get_component() {
    local path="$1"
    
    if [[ "$path" == *"frontend"* ]]; then
        echo "Frontend"
    elif [[ "$path" == *"kre-engine"* ]]; then
        echo "KRE Engine"
    elif [[ "$path" == *"genui-orchestrator"* ]]; then
        echo "GenUI Orchestrator"
    elif [[ "$path" == *"user-context"* ]]; then
        echo "User Context"
    elif [[ "$path" == *"ai-sommelier"* ]]; then
        echo "AI Sommelier"
    elif [[ "$path" == *"pcm-classifier"* ]]; then
        echo "PCM Classifier"
    elif [[ "$path" == *"experiment-service"* ]]; then
        echo "Experiment Service"
    elif [[ "$path" == *"bandit-service"* ]]; then
        echo "Bandit Service"
    elif [[ "$path" == *"streaming-adapter"* ]]; then
        echo "Streaming Adapter"
    elif [[ "$path" == *"social-experiment"* ]]; then
        echo "Social Experiments"
    elif [[ "$path" == *"migrations"* ]] || [[ "$path" == *"database"* ]]; then
        echo "Database"
    elif [[ "$path" == *"k8s"* ]] || [[ "$path" == *"docker"* ]]; then
        echo "Infrastructure"
    else
        echo "Platform"
    fi
}

echo ""
echo "Starting issue enrichment process..."
echo "This will update issues #35 to #198 with detailed content..."
echo ""

# Update infrastructure tasks (T001-T010)
echo "=== Updating Infrastructure Tasks (T001-T010) ==="

# T008 - Streaming Adapter
body=$(generate_enriched_content "T008" "Initialize Rust project for streaming-adapter" \
    "services/streaming-adapter/" "T001" "infrastructure" "Streaming Adapter")
update_issue 42 "$body"

# T009 - Docker Compose
body=$(generate_enriched_content "T009" "Create docker-compose.yml" \
    "root" "T001-T008" "infrastructure" "Infrastructure")
update_issue 43 "$body"

# T010 - Shared Contracts
body=$(generate_enriched_content "T010" "Setup shared contracts and protos" \
    "shared/" "T001" "infrastructure" "Infrastructure")
update_issue 44 "$body"

# Continue with more tasks...
echo ""
echo "=== Updating Database Tasks (T011-T015) ==="

# T011 - PostgreSQL Migrations
body=$(generate_enriched_content "T011" "Create PostgreSQL schema migrations" \
    "migrations/" "T009" "database" "Database")
update_issue 46 "$body"

# T012 - UserProfile Migration
body=$(generate_enriched_content "T012" "Create migration for UserProfile table" \
    "migrations/" "T011" "database" "Database")
update_issue 47 "$body"

echo ""
echo "=== Updating Contract Test Tasks (T016-T025) ==="

# T016 - GraphQL generateUI test
body=$(generate_enriched_content "T016" "GraphQL schema test for generateUI query" \
    "frontend/tests/contract/test_genui_query.ts" "T002" "contract-test" "Frontend")
update_issue 51 "$body"

# T019 - OpenAPI /ui/generate test
body=$(generate_enriched_content "T019" "OpenAPI contract test for POST /ui/generate" \
    "services/genui-orchestrator/tests/contract_test.go" "T004" "contract-test" "GenUI Orchestrator")
update_issue 54 "$body"

echo ""
echo "=== Updating Data Model Tasks (T026-T036) ==="

# T026 - UserProfile Model
body=$(generate_enriched_content "T026" "UserProfile model with PCM stages" \
    "services/user-context/internal/models/user.go" "T012" "data-model" "User Context")
update_issue 61 "$body"

echo ""
echo "=== Updating Service Implementation Tasks (T037-T050) ==="

# T037 - Rule Evaluation Engine
body=$(generate_enriched_content "T037" "Rule evaluation engine" \
    "services/kre-engine/src/engine/evaluator.rs" "T031,T032" "service" "KRE Engine")
update_issue 72 "$body"

# T040 - UI Assembly Pipeline
body=$(generate_enriched_content "T040" "UI assembly pipeline" \
    "services/genui-orchestrator/internal/assembly/pipeline.go" "T028,T029,T030" "service" "GenUI Orchestrator")
update_issue 75 "$body"

# T046 - NLP Query Processor
body=$(generate_enriched_content "T046" "Natural language query processor" \
    "services/ai-sommelier/src/nlp/processor.py" "T033,T034" "service" "AI Sommelier")
update_issue 81 "$body"

echo ""
echo "========================================="
echo "Issue Enrichment Summary:"
echo "Updated: $UPDATED issues"
echo "Failed: $FAILED issues"
echo ""
echo "Note: This is a sample of updates. To update all 158 issues,"
echo "expand this script with all task IDs and run it."
echo "========================================="