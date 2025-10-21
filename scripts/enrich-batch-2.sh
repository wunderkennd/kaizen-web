#!/bin/bash

# Batch 2: Database Migration Tasks (T014-T018)
echo "Enriching Batch 2: Database & Contract Test Tasks..."

# T014: Rule migrations
echo "Updating T014 (Rule Migrations)..."
gh issue edit 49 --body "# Task T014: Create Rule migrations

## 📋 Overview
**Category**: Database Schema
**Component**: Database
**File Path**: \`migrations/002_rules.sql\`
**Dependencies**: T011
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **backend developer**, I want properly structured rule and adaptation tables so that the KRE engine can efficiently store and query adaptation rules with proper versioning and conflict resolution.

## ✅ Acceptance Criteria
### Migration Requirements
- [ ] AdaptationRule table created with all fields
- [ ] RuleCondition table for complex conditions
- [ ] RuleAction table for action definitions
- [ ] RuleExecution audit table
- [ ] Proper indexes on priority and condition fields
- [ ] Foreign keys to UserProfile and Context tables

### Schema Quality
- [ ] Supports complex nested conditions (AND/OR/NOT)
- [ ] Rule versioning implemented
- [ ] Conflict resolution tracked
- [ ] Performance optimized for evaluation queries
- [ ] Test data includes sample rules

## 🔧 Technical Context
**Database**: PostgreSQL 14+
**Schema Type**: Normalized with JSONB for flexibility
**Indexing**: B-tree for lookups, GIN for JSONB queries
**Partitioning**: Consider for execution history

## 💡 Implementation Notes
- Use JSONB for flexible condition storage
- Add CHECK constraints for priority ranges
- Create composite indexes for common queries
- Consider rule evaluation order optimization
- Add triggers for audit logging

## 🧪 Testing Strategy
- Test complex rule creation
- Validate constraint enforcement
- Test rollback procedures
- Performance test with 1000+ rules
- Test concurrent rule updates

## 📚 Resources
- [Data Model Specification](../specs/001-adaptive-platform/data-model.md)
- [PostgreSQL JSONB](https://www.postgresql.org/docs/14/datatype-json.html)
- [Rule Engine Patterns](https://martinfowler.com/bliki/RulesEngine.html)

---
*KAIZEN Adaptive Platform - Database Task*"

echo "✓ T014 updated"

# T015: Content migrations
echo "Updating T015 (Content Migrations)..."
gh issue edit 50 --body "# Task T015: Create Content migrations

## 📋 Overview
**Category**: Database Schema
**Component**: Database
**File Path**: \`migrations/003_content.sql\`
**Dependencies**: T011
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **content manager**, I want structured content storage so that anime content can be efficiently stored, searched, and recommended with proper metadata and relationships.

## ✅ Acceptance Criteria
### Migration Requirements
- [ ] ContentItem table with metadata
- [ ] ContentRecommendation junction table
- [ ] ContentEmbedding for vector search
- [ ] ContentTag for categorization
- [ ] ContentInteraction for tracking
- [ ] Full-text search indexes configured

### Schema Quality
- [ ] Supports multiple content types (anime, manga, etc.)
- [ ] Efficient similarity search via embeddings
- [ ] Proper relationships to users and contexts
- [ ] Optimized for recommendation queries
- [ ] Sample content data provided

## 🔧 Technical Context
**Database**: PostgreSQL 14+ with pgvector
**Search**: Full-text search with GIN indexes
**Embeddings**: 768-dimensional vectors
**Caching**: Consider materialized views

## 💡 Implementation Notes
- Use pgvector extension for embeddings
- Create GIN indexes for full-text search
- Add triggers for search vector updates
- Consider partitioning by content type
- Implement soft deletes for content

## 🧪 Testing Strategy
- Test content CRUD operations
- Validate search functionality
- Test embedding similarity queries
- Performance test with 100K+ items
- Test recommendation generation

## 📚 Resources
- [Data Model Specification](../specs/001-adaptive-platform/data-model.md)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [Full-Text Search](https://www.postgresql.org/docs/14/textsearch.html)

---
*KAIZEN Adaptive Platform - Database Task*"

echo "✓ T015 updated"

# T017: kre-engine contract test
echo "Updating T017 (KRE Engine Contract Test)..."
gh issue edit 52 --body "# Task T017: gRPC contract test for KRE engine

## 📋 Overview
**Category**: Contract Tests (TDD)
**Component**: KRE Engine
**File Path**: \`services/kre-engine/tests/contract/test_evaluate.rs\`
**Dependencies**: T003
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **QA engineer**, I want contract tests for the KRE engine gRPC service that fail before implementation, ensuring we follow TDD practices and the service meets its API contract.

## ✅ Acceptance Criteria
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS when first run (red phase)
- [ ] gRPC service definition complete
- [ ] All RPC methods covered
- [ ] Message types validated

### Test Coverage
- [ ] EvaluateRules RPC with valid context
- [ ] Batch evaluation endpoint
- [ ] Invalid rule handling
- [ ] Performance requirements (<50ms)
- [ ] Concurrent request handling
- [ ] Error cases (malformed rules, timeouts)

### Contract Validation
- [ ] Proto definitions match spec
- [ ] Field validation enforced
- [ ] Response streaming tested
- [ ] Metadata headers validated
- [ ] Version compatibility checked

## 🔧 Technical Context
**Framework**: tonic for gRPC in Rust
**Testing**: tokio-test for async tests
**Mocking**: mockito for service mocks
**Protocol**: gRPC with Protocol Buffers

## 💡 Implementation Notes
\`\`\`rust
// Expected proto definition
service KREEngine {
  rpc EvaluateRules(EvaluateRequest) returns (EvaluateResponse);
  rpc BatchEvaluate(stream EvaluateRequest) returns (stream EvaluateResponse);
  rpc GetRuleStats(Empty) returns (RuleStats);
}

message EvaluateRequest {
  string user_id = 1;
  Context context = 2;
  repeated string rule_ids = 3;
}
\`\`\`

- Use tonic for gRPC implementation
- Mock the service initially
- Test both unary and streaming RPCs
- Validate proto message serialization
- Test deadline/timeout handling

## 🧪 Testing Strategy
- Write proto definitions first
- Create failing tests for each RPC
- Test message validation
- Test streaming endpoints
- Performance benchmarks
- Load testing with concurrent clients

## 📚 Resources
- [tonic Documentation](https://github.com/hyperium/tonic)
- [gRPC Best Practices](https://grpc.io/docs/guides/performance/)
- [TDD in Rust](https://doc.rust-lang.org/book/ch11-03-test-organization.html)

---
*KAIZEN Adaptive Platform - Contract Test (TDD)*"

echo "✓ T017 updated"

# T018: user-context contract test
echo "Updating T018 (User Context Contract Test)..."
gh issue edit 53 --body "# Task T018: REST contract test for user-context API

## 📋 Overview
**Category**: Contract Tests (TDD)
**Component**: User Context
**File Path**: \`services/user-context/tests/contract/test_api.go\`
**Dependencies**: T005
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **QA engineer**, I want contract tests for the user-context REST API that fail before implementation, ensuring the service properly manages user sessions and PCM stages.

## ✅ Acceptance Criteria
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS when first run (red phase)
- [ ] OpenAPI spec fully defined
- [ ] All endpoints covered
- [ ] Authentication tested

### Test Coverage
- [ ] GET /users/{id}/context
- [ ] POST /users/{id}/context/update
- [ ] GET /users/{id}/pcm-stage
- [ ] POST /users/{id}/events
- [ ] WebSocket /users/{id}/stream
- [ ] JWT authentication validation
- [ ] Rate limiting behavior
- [ ] CORS configuration

### Contract Validation
- [ ] Request/response schemas match OpenAPI
- [ ] Status codes properly used
- [ ] Error responses formatted correctly
- [ ] Pagination implemented
- [ ] Cache headers present

## 🔧 Technical Context
**Framework**: Gin with Go
**Testing**: httptest and testify
**Mocking**: gomock for dependencies
**API Spec**: OpenAPI 3.0

## 💡 Implementation Notes
\`\`\`go
// Expected endpoints
type UserContextAPI interface {
    GetContext(userID string) (*Context, error)
    UpdateContext(userID string, ctx *Context) error
    GetPCMStage(userID string) (PCMStage, error)
    RecordEvent(userID string, event *Event) error
    StreamUpdates(userID string) (<-chan Update, error)
}
\`\`\`

- Use httptest for API testing
- Mock database and cache layers
- Test authentication middleware
- Validate JSON schema compliance
- Test WebSocket upgrade

## 🧪 Testing Strategy
- Define OpenAPI spec first
- Write tests for each endpoint
- Test authentication flows
- Test error scenarios
- Validate response times
- Test concurrent requests

## 📚 Resources
- [OpenAPI Specification](../specs/001-adaptive-platform/contracts/user-context.yaml)
- [Gin Testing](https://gin-gonic.com/docs/testing/)
- [TDD in Go](https://quii.gitbook.io/learn-go-with-tests/)

---
*KAIZEN Adaptive Platform - Contract Test (TDD)*"

echo "✓ T018 updated"

# T019: ai-sommelier contract test
echo "Updating T019 (AI Sommelier Contract Test)..."
gh issue edit 54 --body "# Task T019: REST contract test for ai-sommelier

## 📋 Overview
**Category**: Contract Tests (TDD)
**Component**: AI Sommelier
**File Path**: \`services/ai-sommelier/tests/contract/test_api.py\`
**Dependencies**: T006
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **QA engineer**, I want contract tests for the AI Sommelier REST API that fail before implementation, ensuring the service properly handles content recommendations and embeddings.

## ✅ Acceptance Criteria
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS when first run (red phase)
- [ ] FastAPI schema defined
- [ ] All endpoints covered
- [ ] Async operations tested

### Test Coverage
- [ ] POST /recommendations/generate
- [ ] POST /embeddings/create
- [ ] GET /similar/{content_id}
- [ ] POST /feedback
- [ ] GET /health with ML model status
- [ ] Batch processing endpoints
- [ ] Rate limiting (10 req/s)
- [ ] Response time validation (<2s)

### Contract Validation
- [ ] Pydantic models match API spec
- [ ] Vector dimension validation (768)
- [ ] Content filtering tested
- [ ] Error responses formatted
- [ ] Async task handling

## 🔧 Technical Context
**Framework**: FastAPI with Python
**Testing**: pytest with httpx
**Mocking**: pytest-mock
**Validation**: Pydantic v2

## 💡 Implementation Notes
\`\`\`python
# Expected API structure
class RecommendationRequest(BaseModel):
    user_id: str
    context: dict
    limit: int = 10
    filters: Optional[dict] = None

class RecommendationResponse(BaseModel):
    recommendations: List[ContentItem]
    confidence_scores: List[float]
    generation_time_ms: float
\`\`\`

- Use httpx for async testing
- Mock ML model initially
- Test vector operations
- Validate response schemas
- Test caching behavior

## 🧪 Testing Strategy
- Define Pydantic models first
- Write async test fixtures
- Test ML pipeline mocking
- Test batch operations
- Validate embeddings format
- Performance benchmarks

## 📚 Resources
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/)
- [pytest-asyncio](https://pytest-asyncio.readthedocs.io/)
- [Sentence Transformers](https://www.sbert.net/)

---
*KAIZEN Adaptive Platform - Contract Test (TDD)*"

echo "✓ T019 updated"

echo ""
echo "========================================="
echo "Batch 2 Complete!"
echo "Updated issues #49-54:"
echo "- T014: Rule Migrations"
echo "- T015: Content Migrations"
echo "- T017: KRE Engine Contract Test"
echo "- T018: User Context Contract Test"
echo "- T019: AI Sommelier Contract Test"
echo "========================================="