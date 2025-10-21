#!/bin/bash

# Script to update a sample of issues with enriched content
# This demonstrates the enrichment for different task types

echo "Updating sample issues with enriched content..."

# Function to update a single issue
enrich_issue() {
    local issue_num="$1"
    local task_id="$2"
    local title="$3"
    local component="$4"
    local deps="$5"
    local path="$6"
    local category="$7"
    
    echo "Enriching issue #${issue_num} (${task_id}: ${title})..."
    
    local body="# Task ${task_id}: ${title}

## 📋 Overview
**Category**: ${category}  
**Component**: ${component}  
**File Path**: \`${path}\`  
**Dependencies**: ${deps:-None}  
**Status**: To Do

## 👤 User Story
$(case "$category" in
    "Infrastructure")
        echo "As a **platform engineer**, I want to set up ${title,,} so that the development team has a robust foundation with proper tooling, monitoring, and deployment capabilities."
        ;;
    "Database")
        echo "As a **backend developer**, I want database schemas properly defined so that data can be stored and queried efficiently with type safety and referential integrity."
        ;;
    "Contract Test")
        echo "As a **QA engineer**, I want contract tests that fail before implementation so that we follow TDD practices and ensure APIs meet their contracts."
        ;;
    "Data Model")
        echo "As a **backend developer**, I want well-defined data models so that business logic can be implemented consistently with proper validation."
        ;;
    "Service")
        echo "As a **system architect**, I want ${component} service functionality so that the platform can deliver adaptive experiences with high performance."
        ;;
    "Frontend")
        echo "As a **frontend developer**, I want reusable components so that we can build consistent, adaptive interfaces following design system guidelines."
        ;;
    "Integration Test")
        echo "As a **product owner**, I want end-to-end testing so that user journeys work seamlessly across all components."
        ;;
    "Deployment")
        echo "As a **DevOps engineer**, I want deployment infrastructure so that we can reliably deploy, monitor, and scale the platform."
        ;;
    *)
        echo "As a **developer**, I want to implement this functionality so that system capabilities are enhanced."
        ;;
esac)

## ✅ Acceptance Criteria
$(case "$category" in
    "Infrastructure")
        cat <<'EOF'
### Service Setup
- [ ] Service initializes without errors
- [ ] Dependencies locked in version file  
- [ ] Health check returns 200 at /health
- [ ] Metrics exposed at /metrics
- [ ] Graceful shutdown on SIGTERM
- [ ] README with setup instructions
- [ ] Dockerfile builds and runs
- [ ] Environment variables documented
- [ ] Basic CI/CD workflow configured
- [ ] Logging configured appropriately
EOF
        ;;
    "Database")
        cat <<'EOF'
### Migration Requirements  
- [ ] Follows naming convention: YYYYMMDDHHMMSS_description.sql
- [ ] UP migration creates all objects
- [ ] DOWN migration reverses changes
- [ ] Foreign keys properly defined
- [ ] Indexes for common queries
- [ ] Constraints enforce business rules
- [ ] Runs on clean database
- [ ] Idempotent execution
- [ ] Test data seed provided
- [ ] Performance impact documented
EOF
        ;;
    "Contract Test")
        cat <<'EOF'
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS on first run
- [ ] Contract fully defined
- [ ] All endpoints covered
- [ ] Request validation tested
- [ ] Response format validated
- [ ] Error cases tested (4xx, 5xx)
- [ ] Performance requirements checked
- [ ] Mocks properly configured
- [ ] Test is maintainable
EOF
        ;;
    "Service")
        cat <<'EOF'
### Implementation Requirements
- [ ] All endpoints implemented
- [ ] Business logic separated
- [ ] Error handling comprehensive
- [ ] Input validation secure
- [ ] Database integrated
- [ ] Unit tests >80% coverage
- [ ] Integration tests pass
- [ ] Performance meets SLAs
- [ ] Logging with correlation IDs
- [ ] Metrics exported
EOF
        ;;
    "Frontend")
        cat <<'EOF'
### Component Requirements
- [ ] Renders in all browsers
- [ ] Fully typed (no 'any')
- [ ] Follows KDS guidelines
- [ ] Responsive design
- [ ] WCAG 2.1 AA compliant
- [ ] Storybook stories
- [ ] Unit tests >80%
- [ ] Performance optimized
- [ ] Props documented
- [ ] Keyboard navigable
EOF
        ;;
    *)
        cat <<'EOF'
- [ ] Implementation complete
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Security scan passed
EOF
        ;;
esac)

## 🔧 Technical Context
$(case "$component" in
    "Frontend")
        echo "**Stack**: Next.js 14, TypeScript, TailwindCSS, React Query, Playwright"
        ;;
    "KRE Engine")
        echo "**Stack**: Rust, Axum, Tokio, PostgreSQL with sqlx, Serde"
        ;;
    "GenUI Orchestrator")
        echo "**Stack**: Go, Gin, gRPC, PostgreSQL with pgx, Redis"
        ;;
    "User Context")
        echo "**Stack**: Go, Gin, JWT auth, PostgreSQL, Redis sessions"
        ;;
    "AI Sommelier")
        echo "**Stack**: Python 3.11+, FastAPI, Transformers, Pinecone, Celery"
        ;;
    "Database")
        echo "**Stack**: PostgreSQL 14+, migrations, indexing, partitioning"
        ;;
    "Infrastructure")
        echo "**Stack**: Docker, Kubernetes, GitHub Actions, Prometheus, Grafana"
        ;;
    *)
        echo "**Stack**: See project documentation"
        ;;
esac)

## 💡 Implementation Notes
$(case "$task_id" in
    "T008")
        echo "- Use Tokio for async I/O
- Implement WebSocket and SSE
- Handle backpressure gracefully
- Support concurrent streams
- Add heartbeat mechanism"
        ;;
    "T009")
        echo "- Multi-stage Docker builds
- Health checks for services
- Resource limits configured
- Secrets management
- Dev and prod configs"
        ;;
    "T016"|"T017"|"T018")
        echo "- Use Apollo Client
- Mock all responses for TDD
- Test error boundaries
- Validate TypeScript types
- Check subscriptions"
        ;;
    "T037")
        echo "- Cache compiled rules
- Support hot-reloading
- Log evaluation traces
- Handle dependencies
- Target <50ms evaluation"
        ;;
    "T040")
        echo "- Pipeline: Fetch→Filter→Rank→Assemble
- Parallel processing
- Circuit breakers
- Configuration caching
- Target <500ms total"
        ;;
    *)
        echo "- Follow existing patterns
- Consider performance
- Add comprehensive logging
- Document decisions"
        ;;
esac)

## 🧪 Testing Strategy
- **Unit Tests**: >80% coverage of business logic
- **Integration Tests**: Critical user paths
- **Contract Tests**: API compatibility with TDD
- **Performance Tests**: Meet defined SLAs
- **Security Tests**: Vulnerability scanning

## 📚 Resources
- [Project Specification](../specs/001-adaptive-platform/spec.md)
- [Data Model](../specs/001-adaptive-platform/data-model.md)
- [API Contracts](../specs/001-adaptive-platform/contracts/)
- [Contributing Guide](../CONTRIBUTING.md)

## 🏷️ Metadata
**Priority**: $(case "${task_id:1:3}" in
    00[1-9]|01[0-9]|02[0-5]) echo "P0 - Critical" ;;
    02[6-9]|03[0-9]|04[0-9]|050) echo "P1 - High" ;;
    *) echo "P2 - Medium" ;;
esac)  
**Effort**: $(case "$category" in
    "Infrastructure") echo "5-8 story points" ;;
    "Database") echo "3-5 story points" ;;
    "Contract Test") echo "2-3 story points" ;;
    "Service") echo "8-13 story points" ;;
    "Frontend") echo "5-8 story points" ;;
    *) echo "5 story points" ;;
esac)

---
*Part of the KAIZEN Adaptive Platform | Task ${task_id} | [Project Board](https://github.com/wunderkennd/kaizen-web/projects)*"

    # Update the issue
    gh issue edit "${issue_num}" --body "${body}" 2>/dev/null && echo "✓ Updated" || echo "✗ Failed"
}

# Update sample issues from different categories
echo ""
echo "=== Updating Infrastructure Task Sample ==="
enrich_issue 42 "T008" "Initialize Rust project for streaming-adapter" \
    "Streaming Adapter" "T001" "services/streaming-adapter/" "Infrastructure"

echo ""
echo "=== Updating Database Task Sample ==="
enrich_issue 46 "T011" "Create PostgreSQL schema migrations" \
    "Database" "T009" "migrations/" "Database"

echo ""
echo "=== Updating Contract Test Sample ==="
enrich_issue 51 "T016" "GraphQL schema test for generateUI query" \
    "Frontend" "T002" "frontend/tests/contract/test_genui_query.ts" "Contract Test"

echo ""
echo "=== Updating Service Task Sample ==="
enrich_issue 72 "T037" "Rule evaluation engine" \
    "KRE Engine" "T031,T032" "services/kre-engine/src/engine/evaluator.rs" "Service"

echo ""
echo "=== Updating Frontend Task Sample ==="
enrich_issue 87 "T051" "Button atom variations" \
    "Frontend" "T002" "frontend/src/components/kds/atoms/button.tsx" "Frontend"

echo ""
echo "=== Updating A/B Testing Task Sample ==="
enrich_issue 139 "T105" "Initialize experiment-service Go module" \
    "Experiment Service" "" "services/experiment-service/" "Infrastructure"

echo ""
echo "=== Updating ML Task Sample ==="
enrich_issue 165 "T131" "Initialize bandit-service Python module" \
    "Bandit Service" "" "services/bandit-service/" "Infrastructure"

echo ""
echo "========================================="
echo "Sample issue enrichment complete!"
echo ""
echo "To update ALL issues, run:"
echo "  ./scripts/enrich-all-issues.sh"
echo ""
echo "View updated issues at:"
echo "  https://github.com/wunderkennd/kaizen-web/issues"
echo "========================================="