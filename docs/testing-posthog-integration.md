# Testing PostHog Integration

This guide explains how to test the PostHog analytics integration across all services.

## Test Structure

```
tests/
├── integration/          # End-to-end integration tests
│   └── posthog-integration.test.ts
├── setup.ts             # Test setup and configuration
└── [service-specific]/  # Unit tests in each service directory
```

## Running Tests

### Run All Tests
```bash
npm run test:all
```

### Run PostHog-Specific Tests
```bash
npm run test:posthog
```

### Run by Language

#### Go Tests
```bash
npm run test:go
# or directly
cd packages/go-shared && go test ./... -v
```

#### Rust Tests
```bash
npm run test:rust
# or directly
cd packages/rust-shared && cargo test
```

#### Python Tests
```bash
npm run test:python
# or directly
cd packages/python-shared && python -m pytest tests/ -v
```

#### Frontend Tests
```bash
cd services/frontend && npm test
```

### Run Integration Tests
```bash
# Start PostHog stack first
npm run docker:posthog:up

# Run integration tests
npm run test:integration

# Stop PostHog stack
npm run docker:posthog:down
```

## Test Coverage

### Coverage Requirements
- Minimum 70% coverage for all services
- 100% coverage for critical paths (PCM transitions, experiments)

### Generate Coverage Reports

```bash
# JavaScript/TypeScript
npm run test:coverage

# Go
cd packages/go-shared
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out

# Rust
cd packages/rust-shared
cargo tarpaulin --out Html

# Python
cd packages/python-shared
pytest --cov=kaizen_analytics --cov-report=html
```

## Test Categories

### 1. Unit Tests
Test individual functions and methods in isolation.

**Go Example:**
```go
func TestClient_TrackPCMTransition(t *testing.T) {
    // Test PCM transition tracking
}
```

**Python Example:**
```python
def test_track_pcm_transition(analytics):
    # Test PCM transition tracking
```

**Rust Example:**
```rust
#[tokio::test]
async fn test_track_pcm_transition() {
    // Test PCM transition tracking
}
```

### 2. Integration Tests
Test complete event flows and service interactions.

```typescript
describe('End-to-End Event Flow', () => {
  test('should handle complete user journey', async () => {
    // Test full PCM progression
  });
});
```

### 3. Mock Testing
Use mocks to test without external dependencies.

**Frontend Mocking:**
```typescript
jest.mock('posthog-js/react', () => ({
  usePostHog: jest.fn(),
}));
```

**Python Mocking:**
```python
from unittest.mock import Mock
analytics.client = Mock()
```

## Test Data

### Standard Test User
```javascript
const TEST_USER = {
  id: 'test-user-123',
  pcmStage: 'awareness',
  properties: {
    name: 'Test User',
    email: 'test@example.com'
  }
};
```

### Test Events
```javascript
const TEST_EVENTS = {
  pcmTransition: {
    from_stage: 'awareness',
    to_stage: 'attraction',
    trigger: 'viewed_content'
  },
  experiment: {
    experiment: 'test-exp',
    variant: 'test-variant'
  }
};
```

## Debugging Tests

### Enable Debug Output

**Go:**
```bash
POSTHOG_DEBUG=true go test ./... -v
```

**Python:**
```bash
POSTHOG_DEBUG=true pytest -v -s
```

**JavaScript:**
```bash
DEBUG=posthog:* npm test
```

### View PostHog Logs
```bash
npm run docker:posthog:logs
```

### Check PostHog UI
1. Navigate to http://localhost:8000
2. Check Events tab for test events
3. Verify event properties

## Common Test Scenarios

### 1. PCM Stage Progression
```typescript
test('PCM stage progression', async () => {
  // Test awareness → attraction → attachment → allegiance
});
```

### 2. Experiment Assignment
```typescript
test('A/B test assignment', async () => {
  // Test variant assignment and conversion tracking
});
```

### 3. Service Metrics
```typescript
test('Service health metrics', async () => {
  // Test health check and performance metrics
});
```

### 4. Error Handling
```typescript
test('Graceful degradation', async () => {
  // Test behavior when PostHog is unavailable
});
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Test PostHog Integration
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
      - name: Setup Go
        uses: actions/setup-go@v4
      - name: Setup Rust
        uses: actions-rs/toolchain@v1
      - name: Setup Python
        uses: actions/setup-python@v4
      - name: Install dependencies
        run: |
          npm install
          cd packages/python-shared && pip install -e .[dev]
      - name: Run tests
        run: npm run test:all
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Troubleshooting

### Tests Failing

1. **PostHog not reachable:**
   ```bash
   # Check if PostHog is running
   docker ps | grep posthog
   
   # Restart PostHog
   npm run docker:posthog:down
   npm run docker:posthog:up
   ```

2. **Environment variables not set:**
   ```bash
   # Check environment
   env | grep POSTHOG
   
   # Set test environment
   export POSTHOG_ENABLED=false
   export POSTHOG_PROJECT_API_KEY=phc_test_key
   ```

3. **Mock not working:**
   ```javascript
   // Clear all mocks
   jest.clearAllMocks();
   
   // Reset modules
   jest.resetModules();
   ```

### Performance Issues

1. **Slow tests:**
   - Use `test.only` to run single test
   - Disable PostHog in unit tests
   - Use smaller batch sizes

2. **Memory leaks:**
   - Ensure proper cleanup in afterEach/afterAll
   - Close connections properly
   - Clear event queues

## Best Practices

1. **Isolate Tests**: Each test should be independent
2. **Use Mocks**: Mock external dependencies in unit tests
3. **Test Data**: Use consistent test data across services
4. **Cleanup**: Always clean up resources after tests
5. **Assertions**: Make specific assertions about event properties
6. **Coverage**: Aim for high coverage of critical paths
7. **Documentation**: Document complex test scenarios
8. **Performance**: Keep tests fast and focused

## Validation Checklist

- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] Coverage above 70%
- [ ] No console errors
- [ ] Mocks properly configured
- [ ] Test data consistent
- [ ] CI/CD pipeline green
- [ ] PostHog events visible in UI