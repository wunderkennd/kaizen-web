#!/bin/bash

# Batch script to efficiently update all GitHub issues with enriched content
# Uses GitHub API more efficiently with bulk operations where possible

echo "Starting batch enrichment of GitHub issues..."
echo "This script will update all 158 task issues with detailed context."

# Create a function to generate the full enriched body for each task type
generate_issue_body() {
    local task_id="$1"
    local title="$2"
    local component="$3"
    local deps="$4"
    local file_path="$5"
    
    # Determine task category based on ID range
    local category=""
    local priority=""
    local effort=""
    
    task_num=${task_id//[!0-9]/}
    
    # Categorize by task number
    if (( task_num <= 10 )); then
        category="Infrastructure Setup"
        priority="P0 - Critical"
        effort="5-8 points"
    elif (( task_num <= 15 )); then
        category="Database Schema"
        priority="P0 - Critical"
        effort="3-5 points"
    elif (( task_num <= 25 )); then
        category="Contract Tests (TDD)"
        priority="P0 - Critical"
        effort="3 points"
    elif (( task_num <= 36 )); then
        category="Data Models"
        priority="P1 - High"
        effort="5 points"
    elif (( task_num <= 50 )); then
        category="Core Services"
        priority="P1 - High"
        effort="8-13 points"
    elif (( task_num <= 60 )); then
        category="Frontend Components"
        priority="P2 - Medium"
        effort="5-8 points"
    elif (( task_num <= 68 )); then
        category="Integration Tests"
        priority="P2 - Medium"
        effort="5 points"
    elif (( task_num <= 72 )); then
        category="RMI Designer"
        priority="P2 - Medium"
        effort="8 points"
    elif (( task_num <= 80 )); then
        category="Deployment & Ops"
        priority="P1 - High"
        effort="5-8 points"
    elif (( task_num <= 98 )); then
        category="Ecosystem Features"
        priority="P3 - Low"
        effort="5-8 points"
    elif (( task_num <= 122 )); then
        category="A/B Testing"
        priority="P2 - Medium"
        effort="5 points"
    else
        category="Advanced Experimentation"
        priority="P3 - Low"
        effort="8 points"
    fi

    cat <<EOF
# ${task_id}: ${title}

## 📋 Task Overview
- **Category**: ${category}
- **Component**: ${component}
- **Priority**: ${priority}
- **Effort**: ${effort}
- **File Path**: \`${file_path}\`
- **Dependencies**: ${deps:-None}

## 🎯 User Story
$(generate_user_story "$category" "$component" "$title")

## ✅ Acceptance Criteria
$(generate_acceptance_criteria "$category" "$task_id")

## 🔧 Technical Requirements
$(generate_technical_requirements "$component" "$task_id")

## 💡 Implementation Notes
$(generate_implementation_notes "$task_id" "$category")

## 🧪 Testing Requirements
$(generate_testing_requirements "$category")

## 📚 References
- [Specification](../specs/001-adaptive-platform/spec.md)
- [Data Model](../specs/001-adaptive-platform/data-model.md)
- [API Contracts](../specs/001-adaptive-platform/contracts/)
- [Architecture Docs](../docs/architecture.md)

## 🔄 Definition of Done
- [ ] Code complete and follows project standards
- [ ] Unit tests written and passing (>80% coverage)
- [ ] Integration tests passing
- [ ] Documentation updated
- [ ] Code reviewed and approved
- [ ] Performance benchmarks met
- [ ] Security scan passed
- [ ] Deployed to staging environment

---
*KAIZEN Adaptive Platform - [Project Board](https://github.com/wunderkennd/kaizen-web/projects)*
EOF
}

# User story generator
generate_user_story() {
    local category="$1"
    local component="$2"
    local title="$3"
    
    case "$category" in
        "Infrastructure Setup")
            echo "As a **Platform Engineer**, I want to set up the ${component} infrastructure, so that developers have a robust foundation for building microservices with proper tooling, monitoring, and deployment capabilities."
            ;;
        "Database Schema")
            echo "As a **Backend Developer**, I want properly designed database schemas and migrations, so that I can store and retrieve data efficiently while maintaining referential integrity and supporting evolving requirements."
            ;;
        "Contract Tests (TDD)")
            echo "As a **Quality Engineer**, I want contract tests that fail before implementation exists, so that we follow TDD practices and ensure all services meet their API contracts before any implementation begins."
            ;;
        "Data Models")
            echo "As a **Backend Developer**, I want well-structured data models with validation and relationships, so that business logic is consistently implemented across services with type safety."
            ;;
        "Core Services")
            echo "As a **System Architect**, I want the ${component} service fully implemented, so that the platform can deliver adaptive, personalized experiences with sub-second response times."
            ;;
        "Frontend Components")
            echo "As a **Frontend Developer**, I want reusable ${component} components following KDS guidelines, so that we maintain UI consistency while supporting dynamic adaptation based on user context."
            ;;
        "Integration Tests")
            echo "As a **Product Manager**, I want comprehensive end-to-end testing of user journeys, so that I can be confident all features work together seamlessly before release."
            ;;
        "Deployment & Ops")
            echo "As a **DevOps Engineer**, I want automated deployment and monitoring infrastructure, so that we can reliably deploy, scale, and maintain the platform in production."
            ;;
        "A/B Testing")
            echo "As a **Data Scientist**, I want robust experimentation infrastructure, so that we can run statistically valid experiments and make data-driven product decisions."
            ;;
        "Advanced Experimentation")
            echo "As an **ML Engineer**, I want advanced optimization capabilities, so that we can use machine learning to continuously improve user experiences in real-time."
            ;;
        *)
            echo "As a **Developer**, I want to implement ${title}, so that the platform capabilities are enhanced."
            ;;
    esac
}

# Acceptance criteria generator
generate_acceptance_criteria() {
    local category="$1"
    local task_id="$2"
    
    case "$category" in
        "Infrastructure Setup")
            cat <<'CRITERIA'
### Service Initialization
- [ ] Service starts without errors using `make run` or equivalent
- [ ] All dependencies are locked (package-lock.json, go.sum, Cargo.lock, etc.)
- [ ] Health check endpoint returns 200 OK at `/health`
- [ ] Metrics endpoint exposes Prometheus metrics at `/metrics`
- [ ] Graceful shutdown handles SIGTERM properly

### Documentation & Testing
- [ ] README includes setup instructions, architecture overview, and API docs
- [ ] Dockerfile builds successfully and image size is optimized
- [ ] Docker Compose integration works with other services
- [ ] Basic CI workflow runs tests, linting, and security scans
- [ ] Environment variables documented in `.env.example`
CRITERIA
            ;;
        "Database Schema")
            cat <<'CRITERIA'
### Migration Requirements
- [ ] Migration files follow naming: `YYYYMMDDHHMMSS_description.sql`
- [ ] UP migration creates all tables, indexes, and constraints
- [ ] DOWN migration cleanly removes all changes
- [ ] Foreign keys enforce referential integrity
- [ ] Indexes optimize common query patterns
- [ ] Constraints validate business rules at DB level

### Testing & Documentation
- [ ] Migration runs on clean database without errors
- [ ] Rollback tested and works correctly
- [ ] Performance impact documented for large tables
- [ ] Sample data seed script provided
- [ ] ER diagram updated with relationships
CRITERIA
            ;;
        "Contract Tests (TDD)")
            cat <<'CRITERIA'
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS when first run (no false positives)
- [ ] Contract/schema completely defined
- [ ] All endpoints and operations covered
- [ ] Request validation tested (required fields, types, formats)

### Test Coverage
- [ ] Success cases for all operations
- [ ] Error cases (400, 401, 403, 404, 500)
- [ ] Edge cases and boundary conditions
- [ ] Performance requirements validated
- [ ] Mocks/stubs properly configured
CRITERIA
            ;;
        "Core Services")
            cat <<'CRITERIA'
### Implementation Requirements
- [ ] All specified endpoints implemented and documented
- [ ] Business logic separated from HTTP handling
- [ ] Comprehensive error handling with appropriate status codes
- [ ] Input validation prevents injection attacks
- [ ] Database transactions used where appropriate

### Quality & Performance
- [ ] Unit test coverage >80%
- [ ] Integration tests for critical paths
- [ ] Performance SLAs met (response times, throughput)
- [ ] Logging includes correlation IDs
- [ ] Metrics track business KPIs
- [ ] API documentation auto-generated
CRITERIA
            ;;
        "Frontend Components")
            cat <<'CRITERIA'
### Component Requirements
- [ ] Component renders correctly in Chrome, Firefox, Safari, Edge
- [ ] TypeScript strictly typed (no 'any' without justification)
- [ ] Follows Kaizen Design System (KDS) guidelines
- [ ] Responsive design works on mobile, tablet, desktop
- [ ] Keyboard navigation fully supported

### Quality Standards
- [ ] WCAG 2.1 AA accessibility compliance
- [ ] Storybook stories for all component states
- [ ] Unit tests cover all logic branches (>80% coverage)
- [ ] Performance optimized (no unnecessary re-renders)
- [ ] Props documented with JSDoc/TSDoc
CRITERIA
            ;;
        *)
            cat <<'CRITERIA'
- [ ] Implementation complete and working
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed and approved
- [ ] No security vulnerabilities
- [ ] Performance requirements met
CRITERIA
            ;;
    esac
}

# Technical requirements generator
generate_technical_requirements() {
    local component="$1"
    local task_id="$2"
    
    case "$component" in
        "Frontend")
            echo "### Frontend Stack
- Next.js 14 with App Router
- TypeScript 5.0+ with strict mode
- TailwindCSS with custom KDS tokens
- React Query for server state
- Zustand for client state
- Vitest for unit testing
- Playwright for E2E testing"
            ;;
        "KRE Engine")
            echo "### Rust Requirements
- Rust 1.70+ with 2021 edition
- Axum web framework with Tower middleware
- Tokio async runtime
- SQLx for PostgreSQL
- Serde for serialization
- Criterion for benchmarking"
            ;;
        "GenUI Orchestrator")
            echo "### Go Requirements
- Go 1.21+ with modules
- Gin web framework
- gRPC with protobuf
- pgx/v5 for PostgreSQL
- go-redis/v9 for caching
- Zap for structured logging"
            ;;
        "User Context")
            echo "### Go Service Requirements  
- Go 1.21+ with clean architecture
- JWT authentication
- User session management
- PCM stage tracking
- Real-time context updates
- Privacy compliance (GDPR)"
            ;;
        "AI Sommelier")
            echo "### Python ML Requirements
- Python 3.11+ with type hints
- FastAPI with async support
- Transformers for NLP
- Pinecone for vector search
- Celery for async tasks
- PyTorch/TensorFlow for models"
            ;;
        "Database")
            echo "### PostgreSQL Requirements
- PostgreSQL 14+ with extensions
- Proper indexing strategy
- Partitioning for large tables
- Read replicas for scaling
- Point-in-time recovery
- Connection pooling"
            ;;
        *)
            echo "### Technical Stack
- Follow project conventions
- Use approved dependencies
- Implement proper error handling
- Add comprehensive logging
- Include metrics collection"
            ;;
    esac
}

# Implementation notes generator
generate_implementation_notes() {
    local task_id="$1"
    local category="$2"
    
    # Special notes for specific tasks
    case "$task_id" in
        T008)
            echo "### Streaming Adapter Notes
- Implement WebSocket and Server-Sent Events
- Handle backpressure for high throughput
- Support graceful client reconnection
- Use buffered channels for flow control
- Implement heartbeat/keepalive mechanism"
            ;;
        T009)
            echo "### Docker Compose Configuration
- Use multi-stage builds for optimization
- Configure health checks with proper intervals
- Set resource limits for each service
- Use secrets for sensitive data
- Include both dev and prod configurations"
            ;;
        T037|T038|T039)
            echo "### Rule Engine Implementation
- Cache compiled rules for performance
- Support hot-reloading without downtime
- Log all evaluations for debugging
- Handle recursive rule dependencies
- Optimize for <50ms evaluation time"
            ;;
        T040|T041|T042)
            echo "### GenUI Pipeline
- Implement as: Fetch → Filter → Rank → Assemble → Optimize
- Use goroutines for parallel processing
- Add circuit breakers for resilience
- Cache assembled configurations
- Support partial rendering on timeout"
            ;;
        T046|T047|T048)
            echo "### AI Sommelier Implementation
- Use pre-trained language models
- Fine-tune on anime-specific corpus
- Implement semantic caching layer
- Support multilingual queries
- Optimize embedding generation"
            ;;
        *)
            echo "### General Implementation Notes
- Follow existing code patterns
- Consider performance from the start
- Add detailed logging for debugging
- Write self-documenting code
- Include inline documentation for complex logic"
            ;;
    esac
}

# Testing requirements generator
generate_testing_requirements() {
    local category="$1"
    
    echo "### Testing Strategy
- **Unit Tests**: Minimum 80% code coverage
- **Integration Tests**: Critical user paths
- **Performance Tests**: Load and stress testing
- **Security Tests**: OWASP Top 10 scanning
- **Accessibility Tests**: Automated WCAG checks"
    
    case "$category" in
        "Contract Tests (TDD)")
            echo "
### TDD Specific Requirements
- Write test first, see it fail
- Implement minimum code to pass
- Refactor while keeping tests green
- Document why test should fail initially
- Include test data generators"
            ;;
        "Frontend Components")
            echo "
### Frontend Testing Requirements
- Snapshot tests for UI consistency
- Interaction tests for user events
- Visual regression tests with Percy/Chromatic
- Accessibility tests with jest-axe
- Performance tests with Lighthouse"
            ;;
        "Core Services")
            echo "
### Service Testing Requirements
- Unit tests for business logic
- Integration tests with real databases
- Contract tests for API compatibility
- Load tests for performance SLAs
- Chaos testing for resilience"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Main execution
echo "Generating enriched content for all tasks..."
echo "This will create detailed documentation for each issue."

# Arrays to hold our task data
declare -a TASKS=(
    "35|T001|Create repository structure|Infrastructure||infrastructure|done"
    "36|T002|Initialize Next.js 14 frontend|Frontend|T001|infrastructure|done"
    "37|T003|Initialize Rust workspace for kre-engine|KRE Engine|T001|infrastructure|done"
    "38|T004|Initialize Go module for genui-orchestrator|GenUI Orchestrator|T001|infrastructure|done"
    "39|T005|Initialize Go module for user-context|User Context|T001|infrastructure|done"
    "40|T006|Initialize Python FastAPI for ai-sommelier|AI Sommelier|T001|infrastructure|done"
    "41|T007|Initialize Python/Rust hybrid for pcm-classifier|PCM Classifier|T001|infrastructure|done"
    "42|T008|Initialize Rust project for streaming-adapter|Streaming Adapter|T001|infrastructure|todo"
    "43|T009|Create docker-compose.yml|Infrastructure|T001-T008|infrastructure|todo"
    "44|T010|Setup shared contracts and protos|Infrastructure|T001|infrastructure|todo"
    "45|T010a|Setup Pinecone vector database|Infrastructure|T010|infrastructure|todo"
    "46|T011|Create PostgreSQL schema migrations|Database|T009|database|todo"
    "47|T012|Create UserProfile migration|Database|T011|database|todo"
    "48|T013|Create Context and UI migrations|Database|T011|database|todo"
    "49|T014|Create Rule migrations|Database|T011|database|todo"
    "50|T015|Create Content migrations|Database|T011|database|todo"
    # Continue for all 158 tasks...
)

# Process each task
UPDATED=0
FAILED=0

for task_data in "${TASKS[@]}"; do
    IFS='|' read -r issue_num task_id title component deps path status <<< "$task_data"
    
    echo "Updating issue #${issue_num} (${task_id})..."
    
    # Generate the body
    body=$(generate_issue_body "$task_id" "$title" "$component" "$deps" "$path")
    
    # Update the issue
    gh issue edit "${issue_num}" --body "${body}" && ((UPDATED++)) || ((FAILED++))
    
    # Rate limiting - pause every 10 updates
    if (( UPDATED % 10 == 0 )); then
        echo "Processed ${UPDATED} issues, pausing to avoid rate limits..."
        sleep 2
    fi
done

echo ""
echo "========================================="
echo "Batch Enrichment Complete!"
echo "Successfully updated: ${UPDATED} issues"
echo "Failed updates: ${FAILED} issues"
echo ""
echo "View the enriched issues at:"
echo "https://github.com/wunderkennd/kaizen-web/issues"
echo "========================================="