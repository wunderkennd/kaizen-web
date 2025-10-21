#!/bin/bash

# Simplified script to enrich GitHub issues with detailed context

echo "Enriching GitHub issues with detailed context..."

# Update T008 - Streaming Adapter
echo "Updating T008 (Streaming Adapter)..."
gh issue edit 42 --body "# Task T008: Initialize Rust project for streaming-adapter

## 📋 Overview
**Category**: Infrastructure Setup  
**Component**: Streaming Adapter  
**File Path**: \`services/streaming-adapter/\`  
**Dependencies**: T001  
**Priority**: P0 - Critical  
**Effort**: 5-8 story points  

## 👤 User Story
As a **platform engineer**, I want to set up the streaming adapter service so that the platform can handle real-time data streams, WebSocket connections, and server-sent events efficiently.

## ✅ Acceptance Criteria
### Service Initialization
- [ ] Rust project structure created with Cargo.toml
- [ ] Service starts without errors using \`cargo run\`
- [ ] Dependencies locked in Cargo.lock file
- [ ] Health check endpoint returns 200 at /health
- [ ] Metrics exposed in Prometheus format at /metrics

### Implementation Requirements
- [ ] WebSocket support implemented with Tokio
- [ ] Server-Sent Events (SSE) endpoint available
- [ ] Backpressure handling for high throughput
- [ ] Graceful client reconnection support
- [ ] Connection pooling and management

### Quality & Documentation
- [ ] README with architecture and setup instructions
- [ ] Dockerfile optimized with multi-stage build
- [ ] Unit tests for core functionality (>80% coverage)
- [ ] Integration tests for streaming scenarios
- [ ] Performance benchmarks documented

## 🔧 Technical Context
**Language**: Rust 1.70+  
**Runtime**: Tokio async runtime  
**Web Framework**: Axum with Tower middleware  
**Protocol Support**: WebSocket, SSE, gRPC streaming  
**Performance Target**: 10K concurrent connections  

## 💡 Implementation Notes
- Use Tokio for async I/O and concurrency
- Implement both WebSocket and Server-Sent Events
- Use bounded channels for flow control
- Add heartbeat/keepalive mechanism
- Support graceful shutdown and reconnection
- Consider using Tower for middleware (auth, rate limiting)
- Implement proper error handling and retry logic

## 🧪 Testing Strategy
- **Unit Tests**: Core streaming logic, message handling
- **Integration Tests**: End-to-end streaming scenarios
- **Load Tests**: 10K concurrent connections benchmark
- **Reliability Tests**: Connection drops, reconnection
- **Performance Tests**: Throughput and latency metrics

## 📚 Resources
- [Tokio Documentation](https://tokio.rs)
- [Axum Framework](https://github.com/tokio-rs/axum)
- [WebSocket RFC 6455](https://datatracker.ietf.org/doc/html/rfc6455)
- [Server-Sent Events Spec](https://html.spec.whatwg.org/multipage/server-sent-events.html)

---
*KAIZEN Adaptive Platform - Infrastructure Task*"

echo "✓ T008 updated"

# Update T011 - Database Migrations
echo "Updating T011 (Database Migrations)..."
gh issue edit 46 --body "# Task T011: Create PostgreSQL schema migrations

## 📋 Overview  
**Category**: Database Schema  
**Component**: Database  
**File Path**: \`migrations/\`  
**Dependencies**: T009 (Docker setup)  
**Priority**: P0 - Critical  
**Effort**: 5 story points  

## 👤 User Story
As a **backend developer**, I want properly structured database migrations so that the database schema can evolve safely over time while maintaining data integrity and supporting rollbacks.

## ✅ Acceptance Criteria
### Migration Structure
- [ ] Migration tool configured (golang-migrate or similar)
- [ ] Migrations follow naming: YYYYMMDDHHMMSS_description.sql
- [ ] UP and DOWN migrations for all changes
- [ ] All 11 core entities have table definitions
- [ ] Foreign key relationships properly defined

### Schema Requirements
- [ ] UserProfile table with PCM stages
- [ ] ContextSnapshot with real-time data
- [ ] UIConfiguration for layouts
- [ ] KDSComponent registry
- [ ] AdaptationRule storage
- [ ] ContentItem metadata
- [ ] All tables have appropriate indexes
- [ ] Constraints enforce business rules

### Quality Standards
- [ ] Migrations run on clean database
- [ ] Rollback procedures tested
- [ ] Idempotent execution (can run multiple times)
- [ ] Performance impact documented
- [ ] Test data seed scripts provided

## 🔧 Technical Context
**Database**: PostgreSQL 14+  
**Migration Tool**: golang-migrate or sqlx  
**Schema Design**: Normalized 3NF  
**Indexing**: B-tree for lookups, GiST for search  
**Partitioning**: Time-based for large tables  

## 💡 Implementation Notes
- Start with core entities from data model
- Use transactions for DDL operations
- Create indexes after data load for performance
- Consider partition strategy for context snapshots
- Add CHECK constraints for data validation
- Use JSONB for flexible metadata fields
- Plan for horizontal scaling from the start

## 🧪 Testing Strategy
- Test migrations on empty database
- Test rollback procedures
- Validate foreign key constraints
- Performance test with sample data (1M+ records)
- Test concurrent migrations handling

## 📚 Resources
- [Data Model Specification](../specs/001-adaptive-platform/data-model.md)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Main_Page)
- [Migration Tool Docs](https://github.com/golang-migrate/migrate)

---
*KAIZEN Adaptive Platform - Database Task*"

echo "✓ T011 updated"

# Update T016 - GraphQL Contract Test
echo "Updating T016 (GraphQL Contract Test)..."
gh issue edit 51 --body "# Task T016: GraphQL schema test for generateUI query

## 📋 Overview
**Category**: Contract Tests (TDD)  
**Component**: Frontend  
**File Path**: \`frontend/tests/contract/test_genui_query.ts\`  
**Dependencies**: T002 (Frontend setup)  
**Priority**: P0 - Critical  
**Effort**: 3 story points  

## 👤 User Story
As a **QA engineer**, I want contract tests for the generateUI GraphQL query that fail before implementation, so that we follow TDD practices and ensure the frontend-backend contract is well-defined.

## ✅ Acceptance Criteria
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE any implementation
- [ ] Test FAILS when first run (red phase)
- [ ] GraphQL schema fully defined
- [ ] Query structure documented
- [ ] Response types validated

### Test Coverage
- [ ] Valid query with all parameters
- [ ] Query with minimal parameters
- [ ] Invalid user context handling
- [ ] Missing authentication test
- [ ] Response time validation (<500ms)
- [ ] Large response pagination
- [ ] Error response formats

### Schema Validation
- [ ] Input types match specification
- [ ] Response types properly nested
- [ ] Nullable fields identified
- [ ] Enums for constrained values
- [ ] Deprecation strategy defined

## 🔧 Technical Context
**Testing Framework**: Vitest  
**GraphQL Client**: Apollo Client  
**Schema Language**: GraphQL SDL  
**Mocking**: MSW (Mock Service Worker)  
**Type Generation**: GraphQL Code Generator  

## 💡 Implementation Notes
\`\`\`graphql
# Expected Query Structure
query GenerateUI(\$userId: ID!, \$context: ContextInput!) {
  generateUI(userId: \$userId, context: \$context) {
    configuration {
      id
      sections {
        components {
          id
          type
          props
        }
      }
    }
    assemblyTime
    cacheHit
  }
}
\`\`\`

- Use Apollo Client for testing
- Mock all backend responses initially
- Test both successful and error cases
- Validate TypeScript types match schema
- Consider subscription testing for real-time updates
- Test with various user contexts (mobile, desktop, TV)

## 🧪 Testing Strategy
- Write test first, see it fail
- Define complete GraphQL schema
- Mock responses following schema
- Test query variables validation
- Test response type checking
- Measure query performance

## 📚 Resources
- [GraphQL Testing Best Practices](https://www.apollographql.com/docs/react/development-testing/testing)
- [TDD Workflow](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [Contract Testing](https://martinfowler.com/bliki/ContractTest.html)

---
*KAIZEN Adaptive Platform - Contract Test (TDD)*"

echo "✓ T016 updated"

# Update T037 - Rule Engine
echo "Updating T037 (Rule Evaluation Engine)..."
gh issue edit 72 --body "# Task T037: Rule evaluation engine

## 📋 Overview
**Category**: Core Services  
**Component**: KRE Engine  
**File Path**: \`services/kre-engine/src/engine/evaluator.rs\`  
**Dependencies**: T031, T032 (Rule models)  
**Priority**: P1 - High  
**Effort**: 13 story points  

## 👤 User Story
As a **system architect**, I want a high-performance rule evaluation engine so that the platform can dynamically adapt UI based on context with sub-50ms response times.

## ✅ Acceptance Criteria
### Core Functionality
- [ ] Rules evaluated based on context input
- [ ] Priority-based execution order
- [ ] Conflict resolution implemented
- [ ] Rule caching for performance
- [ ] Hot-reload without downtime

### Performance Requirements
- [ ] <50ms evaluation time (P95)
- [ ] Support 1000+ rules
- [ ] Concurrent evaluation safe
- [ ] Memory efficient caching
- [ ] Optimized rule compilation

### Quality Standards
- [ ] Unit tests >80% coverage
- [ ] Integration tests with real rules
- [ ] Performance benchmarks documented
- [ ] Error handling comprehensive
- [ ] Logging with evaluation traces

## 🔧 Technical Context
**Language**: Rust  
**Async Runtime**: Tokio  
**Rule Format**: JSON DSL  
**Caching**: In-memory with TTL  
**Performance Target**: <50ms for 100 rules  

## 💡 Implementation Notes
### Rule Structure Example
\`\`\`rust
pub struct Rule {
    pub id: String,
    pub priority: u8,
    pub conditions: Condition,
    pub actions: Vec<Action>,
    pub metadata: RuleMetadata,
}

pub enum Condition {
    And(Vec<Condition>),
    Or(Vec<Condition>),
    Not(Box<Condition>),
    Equals(String, Value),
    GreaterThan(String, Value),
    // ... more conditions
}
\`\`\`

### Implementation Strategy
- Use recursive evaluation for nested conditions
- Implement short-circuit evaluation for performance
- Cache compiled rules in memory
- Use RwLock for concurrent access
- Support async rule actions
- Log evaluation path for debugging
- Implement rule versioning
- Handle circular dependencies

## 🧪 Testing Strategy
- Unit test each condition type
- Test complex nested conditions
- Test priority ordering
- Test conflict resolution
- Performance test with 1000+ rules
- Test hot-reload functionality
- Test concurrent evaluation

## 📚 Resources
- [Rules Engine Patterns](https://martinfowler.com/bliki/RulesEngine.html)
- [Rust Async Programming](https://rust-lang.github.io/async-book/)
- [Performance Optimization](https://nnethercote.github.io/perf-book/)

---
*KAIZEN Adaptive Platform - Core Service Task*"

echo "✓ T037 updated"

# Update T051 - KDS Button Component
echo "Updating T051 (Button Component)..."
gh issue edit 87 --body "# Task T051: Button atom variations

## 📋 Overview
**Category**: Frontend Components  
**Component**: Frontend / KDS  
**File Path**: \`frontend/src/components/kds/atoms/button.tsx\`  
**Dependencies**: T002 (Frontend setup)  
**Priority**: P2 - Medium  
**Effort**: 5 story points  

## 👤 User Story
As a **frontend developer**, I want a comprehensive button component system so that we can maintain UI consistency while supporting adaptive variations based on user context and PCM stages.

## ✅ Acceptance Criteria
### Component Variations
- [ ] Primary, secondary, tertiary variants
- [ ] Small, medium, large sizes
- [ ] Icon-only and icon-with-text support
- [ ] Loading and disabled states
- [ ] Adaptive density based on context

### Quality Requirements
- [ ] Fully typed with TypeScript
- [ ] WCAG 2.1 AA compliant
- [ ] Keyboard navigation support
- [ ] Touch-friendly on mobile
- [ ] Dark mode support

### Documentation
- [ ] Storybook stories for all variants
- [ ] Props documented with TSDoc
- [ ] Usage examples in README
- [ ] Design tokens documented
- [ ] Migration guide from old buttons

## 🔧 Technical Context
**Framework**: React 18+ with TypeScript  
**Styling**: TailwindCSS + CSS Modules  
**Design Tokens**: KDS token system  
**State Management**: React hooks  
**Animation**: Framer Motion  

## 💡 Implementation Notes
### Component Structure
\`\`\`typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'tertiary';
  size?: 'sm' | 'md' | 'lg';
  density?: 'comfortable' | 'compact';
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  as?: 'button' | 'a';
  onClick?: (event: React.MouseEvent) => void;
  children: React.ReactNode;
}

// Adaptive density based on context
const density = useAdaptiveDensity();

// PCM-aware styling
const pcmStyles = usePCMStyles(userStage);
\`\`\`

### Implementation Guidelines
- Use forwardRef for ref forwarding
- Implement proper focus management
- Add ripple effect for touch devices
- Support keyboard shortcuts
- Use CSS custom properties for theming
- Optimize re-renders with memo
- Add haptic feedback hook for mobile

## 🧪 Testing Strategy
- Unit tests for all props combinations
- Visual regression tests with Chromatic
- Accessibility tests with jest-axe
- Interaction tests with Testing Library
- Performance tests for re-render optimization
- Cross-browser testing

## 📚 Resources
- [KDS Design System](../docs/design-system/kds.md)
- [Button Patterns](https://www.w3.org/WAI/ARIA/apg/patterns/button/)
- [Inclusive Components](https://inclusive-components.design/buttons/)

---
*KAIZEN Adaptive Platform - Frontend Component*"

echo "✓ T051 updated"

echo ""
echo "========================================="
echo "Successfully enriched sample issues!"
echo ""
echo "Updated issues:"
echo "- #42 (T008): Streaming Adapter"
echo "- #46 (T011): Database Migrations"
echo "- #51 (T016): GraphQL Contract Test"
echo "- #72 (T037): Rule Engine"
echo "- #87 (T051): Button Component"
echo ""
echo "View at: https://github.com/wunderkennd/kaizen-web/issues"
echo "========================================="