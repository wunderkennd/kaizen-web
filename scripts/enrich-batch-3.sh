#!/bin/bash

# Batch 3: More Contract Tests (T020-T024)
echo "Enriching Batch 3: Contract Test Tasks..."

# T020: pcm-classifier contract test
echo "Updating T020 (PCM Classifier Contract Test)..."
gh issue edit 55 --body "# Task T020: gRPC contract test for pcm-classifier

## 📋 Overview
**Category**: Contract Tests (TDD)
**Component**: PCM Classifier
**File Path**: \`services/pcm-classifier/tests/contract/test_classify.py\`
**Dependencies**: T007
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **QA engineer**, I want contract tests for the PCM classifier gRPC service that fail before implementation, ensuring accurate classification of users into PCM stages.

## ✅ Acceptance Criteria
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS when first run (red phase)
- [ ] gRPC proto definitions complete
- [ ] All classification methods covered
- [ ] Model loading tested

### Test Coverage
- [ ] ClassifyUser RPC with behavior data
- [ ] BatchClassify for multiple users
- [ ] GetStageConfidence scores
- [ ] Stage transition detection
- [ ] Model version handling
- [ ] Error cases (invalid data, model errors)

### Contract Validation
- [ ] Proto messages match specification
- [ ] PCM stages properly enumerated
- [ ] Confidence scores normalized (0-1)
- [ ] Metadata includes model version
- [ ] Performance <100ms per classification

## 🔧 Technical Context
**Framework**: grpcio with Python/Rust hybrid
**ML Framework**: PyTorch or Candle
**Testing**: pytest with grpc testing
**Protocol**: gRPC with Protocol Buffers

## 💡 Implementation Notes
\`\`\`proto
service PCMClassifier {
  rpc ClassifyUser(UserBehavior) returns (PCMClassification);
  rpc BatchClassify(stream UserBehavior) returns (stream PCMClassification);
  rpc GetTransitionProbability(TransitionRequest) returns (TransitionResponse);
}

message PCMClassification {
  string user_id = 1;
  PCMStage current_stage = 2;
  float confidence = 3;
  map<string, float> stage_probabilities = 4;
}
\`\`\`

- Mock ML model initially
- Test all 4 PCM stages
- Validate probability distributions
- Test streaming classification
- Benchmark classification speed

## 🧪 Testing Strategy
- Define proto schema first
- Create failing tests for each RPC
- Test stage transition logic
- Test batch processing
- Validate model versioning
- Performance testing

## 📚 Resources
- [PCM Model Documentation](../docs/pcm-stages.md)
- [gRPC Python](https://grpc.io/docs/languages/python/)
- [TDD Best Practices](https://martinfowler.com/bliki/TestDrivenDevelopment.html)

---
*KAIZEN Adaptive Platform - Contract Test (TDD)*"

echo "✓ T020 updated"

# T021: streaming-adapter contract test
echo "Updating T021 (Streaming Adapter Contract Test)..."
gh issue edit 56 --body "# Task T021: WebSocket contract test for streaming-adapter

## 📋 Overview
**Category**: Contract Tests (TDD)
**Component**: Streaming Adapter
**File Path**: \`services/streaming-adapter/tests/contract/test_websocket.rs\`
**Dependencies**: T008
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **QA engineer**, I want contract tests for the streaming adapter WebSocket service that fail before implementation, ensuring reliable real-time communication.

## ✅ Acceptance Criteria
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS when first run (red phase)
- [ ] WebSocket protocol defined
- [ ] Message formats specified
- [ ] Event types enumerated

### Test Coverage
- [ ] WebSocket handshake and upgrade
- [ ] Message broadcasting
- [ ] Room/channel subscriptions
- [ ] Heartbeat/keepalive mechanism
- [ ] Reconnection handling
- [ ] Backpressure management
- [ ] SSE fallback endpoint

### Contract Validation
- [ ] Message schemas validated
- [ ] Binary and text frame support
- [ ] Close codes properly handled
- [ ] Compression negotiated
- [ ] Max frame size enforced

## 🔧 Technical Context
**Framework**: Axum with tokio-tungstenite
**Protocol**: WebSocket (RFC 6455)
**Testing**: tokio-test for async
**Alternative**: Server-Sent Events

## 💡 Implementation Notes
\`\`\`rust
// Expected WebSocket messages
#[derive(Serialize, Deserialize)]
enum StreamMessage {
    Subscribe { channel: String },
    Unsubscribe { channel: String },
    Broadcast { channel: String, data: Value },
    Heartbeat,
    Error { code: u16, message: String },
}

// Expected SSE endpoint
async fn sse_stream() -> Sse<impl Stream<Item = Result<Event>>> {
    // Server-sent events for fallback
}
\`\`\`

- Test WebSocket upgrade process
- Mock message broadcasting
- Test connection pooling
- Validate frame formats
- Test graceful disconnection

## 🧪 Testing Strategy
- Define message protocols first
- Test connection lifecycle
- Test message routing
- Test error recovery
- Load test with 1000+ connections
- Test SSE fallback

## 📚 Resources
- [WebSocket RFC 6455](https://datatracker.ietf.org/doc/html/rfc6455)
- [tokio-tungstenite](https://docs.rs/tokio-tungstenite/)
- [SSE Specification](https://html.spec.whatwg.org/multipage/server-sent-events.html)

---
*KAIZEN Adaptive Platform - Contract Test (TDD)*"

echo "✓ T021 updated"

# T022: genui-orchestrator contract test
echo "Updating T022 (GenUI Orchestrator Contract Test)..."
gh issue edit 57 --body "# Task T022: GraphQL contract test for genui-orchestrator

## 📋 Overview
**Category**: Contract Tests (TDD)
**Component**: GenUI Orchestrator
**File Path**: \`services/genui-orchestrator/tests/contract/test_graphql.go\`
**Dependencies**: T004
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **QA engineer**, I want contract tests for the GenUI orchestrator GraphQL API that fail before implementation, ensuring proper UI generation orchestration.

## ✅ Acceptance Criteria
### TDD Requirements (MUST FAIL FIRST!)
- [ ] Test written BEFORE implementation
- [ ] Test FAILS when first run (red phase)
- [ ] GraphQL schema complete
- [ ] All queries and mutations covered
- [ ] Subscriptions tested

### Test Coverage
- [ ] generateUI query with context
- [ ] updateUIConfiguration mutation
- [ ] subscribeToUpdates subscription
- [ ] Fragment reusability
- [ ] Batch query optimization
- [ ] Error handling and nullability
- [ ] Performance (<500ms total)

### Contract Validation
- [ ] Schema matches TypeScript types
- [ ] Field resolvers validated
- [ ] N+1 query prevention
- [ ] Depth limiting enforced
- [ ] Rate limiting active

## 🔧 Technical Context
**Framework**: gqlgen for Go
**Testing**: gqlgen test client
**Schema**: GraphQL SDL
**Performance**: DataLoader pattern

## 💡 Implementation Notes
\`\`\`graphql
type Query {
  generateUI(userId: ID!, context: ContextInput!): UIConfiguration!
  getUIHistory(userId: ID!, limit: Int): [UIConfiguration!]!
}

type Mutation {
  updateUIConfiguration(id: ID!, updates: UIUpdateInput!): UIConfiguration!
  recordInteraction(userId: ID!, event: InteractionInput!): Boolean!
}

type Subscription {
  uiUpdates(userId: ID!): UIConfiguration!
}

type UIConfiguration {
  id: ID!
  sections: [Section!]!
  assemblyTime: Float!
  cacheHit: Boolean!
}
\`\`\`

- Use gqlgen for type safety
- Mock service dependencies
- Test query complexity
- Validate subscriptions
- Test caching behavior

## 🧪 Testing Strategy
- Define GraphQL schema first
- Test each operation type
- Test field resolution
- Test subscription streaming
- Validate performance
- Test error propagation

## 📚 Resources
- [gqlgen Documentation](https://gqlgen.com/)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)
- [DataLoader Pattern](https://github.com/graphql/dataloader)

---
*KAIZEN Adaptive Platform - Contract Test (TDD)*"

echo "✓ T022 updated"

# T023: Integration test for user journey
echo "Updating T023 (User Journey Integration Test)..."
gh issue edit 58 --body "# Task T023: Frontend integration test for basic user journey

## 📋 Overview
**Category**: Integration Tests
**Component**: Frontend
**File Path**: \`frontend/tests/e2e/test_user_journey.spec.ts\`
**Dependencies**: T002, T016
**Priority**: P1 - High
**Effort**: 5 story points

## 👤 User Story
As a **product owner**, I want end-to-end tests that validate the complete user journey from landing to content interaction, ensuring all components work together seamlessly.

## ✅ Acceptance Criteria
### Test Scenarios
- [ ] User lands on homepage
- [ ] Dynamic UI adapts to new user (Awareness stage)
- [ ] User searches for anime content
- [ ] Results display with proper layout
- [ ] User interacts with content (triggers Attraction)
- [ ] UI adapts to new PCM stage
- [ ] Personalized recommendations appear

### Quality Requirements
- [ ] Tests run in CI/CD pipeline
- [ ] Screenshots on failure
- [ ] Performance metrics captured
- [ ] Cross-browser testing (Chrome, Firefox, Safari)
- [ ] Mobile responsive testing
- [ ] Accessibility checks included

### Integration Points
- [ ] GraphQL API calls verified
- [ ] WebSocket updates tested
- [ ] State management validated
- [ ] Error boundaries tested
- [ ] Loading states verified

## 🔧 Technical Context
**Framework**: Playwright for E2E
**Browsers**: Chrome, Firefox, Safari
**Devices**: Desktop, Mobile viewports
**CI/CD**: GitHub Actions
**Reporting**: Allure or similar

## 💡 Implementation Notes
\`\`\`typescript
// Example test structure
test.describe('User Journey: New to Engaged', () => {
  test('adapts UI from awareness to attraction', async ({ page }) => {
    // 1. Visit homepage
    await page.goto('/');
    
    // 2. Verify awareness-stage UI
    await expect(page.locator('[data-pcm="awareness"]')).toBeVisible();
    
    // 3. Search for content
    await page.fill('[data-testid="search"]', 'One Piece');
    
    // 4. Interact with results
    await page.click('[data-testid="content-card"]');
    
    // 5. Verify UI adaptation
    await expect(page.locator('[data-pcm="attraction"]')).toBeVisible();
  });
});
\`\`\`

- Use Page Object Model
- Mock external services when needed
- Test real GraphQL endpoints
- Capture performance metrics
- Include visual regression tests

## 🧪 Testing Strategy
- Test critical user paths
- Include negative scenarios
- Test PCM stage transitions
- Validate UI adaptations
- Test real-time updates
- Performance benchmarks

## 📚 Resources
- [Playwright Documentation](https://playwright.dev/)
- [E2E Best Practices](https://testingjavascript.com/)
- [Page Object Model](https://playwright.dev/docs/pom)

---
*KAIZEN Adaptive Platform - Integration Test*"

echo "✓ T023 updated"

# T024: E2E authentication flow
echo "Updating T024 (Authentication E2E Test)..."
gh issue edit 59 --body "# Task T024: E2E test for authentication flow

## 📋 Overview
**Category**: Integration Tests
**Component**: Full Stack
**File Path**: \`frontend/tests/e2e/test_auth_flow.spec.ts\`
**Dependencies**: T002, T005
**Priority**: P1 - High
**Effort**: 5 story points

## 👤 User Story
As a **security engineer**, I want comprehensive end-to-end tests for authentication flows, ensuring secure user login, session management, and authorization across all services.

## ✅ Acceptance Criteria
### Test Scenarios
- [ ] User registration with validation
- [ ] Email verification process
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Password reset flow
- [ ] JWT token refresh
- [ ] Logout and session cleanup
- [ ] Protected route access

### Security Requirements
- [ ] XSS prevention verified
- [ ] CSRF tokens validated
- [ ] Rate limiting tested
- [ ] Session timeout tested
- [ ] Secure cookie handling
- [ ] OAuth flow tested (if applicable)

### Integration Points
- [ ] Frontend form validation
- [ ] Backend API authentication
- [ ] Database user creation
- [ ] Session storage (Redis)
- [ ] JWT token validation
- [ ] WebSocket authentication

## 🔧 Technical Context
**Auth Method**: JWT with refresh tokens
**Session Store**: Redis
**Password**: bcrypt hashing
**Testing**: Playwright + API tests
**Security**: OWASP guidelines

## 💡 Implementation Notes
\`\`\`typescript
// Test authentication flow
test.describe('Authentication Flow', () => {
  test('complete registration and login', async ({ page, request }) => {
    // 1. Register new user
    await page.goto('/register');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.click('[type="submit"]');
    
    // 2. Verify email (mock or real)
    const verificationLink = await getVerificationLink();
    await page.goto(verificationLink);
    
    // 3. Login with new credentials
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.click('[type="submit"]');
    
    // 4. Verify authenticated state
    await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
    
    // 5. Test protected route
    await page.goto('/dashboard');
    await expect(page).toHaveURL('/dashboard');
  });
});
\`\`\`

- Test both happy and error paths
- Include API-level tests
- Test token expiration
- Verify secure headers
- Test concurrent sessions

## 🧪 Testing Strategy
- Test all auth endpoints
- Include security tests
- Test session management
- Verify token handling
- Test error messages
- Performance under load

## 📚 Resources
- [OWASP Authentication](https://owasp.org/www-project-cheat-sheets/cheatsheets/Authentication_Cheat_Sheet)
- [JWT Best Practices](https://datatracker.ietf.org/doc/html/rfc8725)
- [Playwright Auth Testing](https://playwright.dev/docs/auth)

---
*KAIZEN Adaptive Platform - Integration Test*"

echo "✓ T024 updated"

echo ""
echo "========================================="
echo "Batch 3 Complete!"
echo "Updated issues #55-59:"
echo "- T020: PCM Classifier Contract Test"
echo "- T021: Streaming Adapter Contract Test"
echo "- T022: GenUI Orchestrator Contract Test"
echo "- T023: User Journey Integration Test"
echo "- T024: Authentication E2E Test"
echo "========================================="