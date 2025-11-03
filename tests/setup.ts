/**
 * Test setup file for all test suites
 */

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.POSTHOG_ENABLED = 'false'; // Disable PostHog in tests by default
process.env.POSTHOG_PROJECT_API_KEY = 'phc_test_key';
process.env.POSTHOG_HOST = 'http://localhost:8000';
process.env.SERVICE_NAME = 'test-service';

// Mock console methods to reduce noise in test output
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  // Keep error for debugging
  error: console.error,
};

// Add custom matchers if needed
expect.extend({
  toBeValidUUID(received: string) {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    const pass = uuidRegex.test(received);
    return {
      pass,
      message: () =>
        pass
          ? `Expected ${received} not to be a valid UUID`
          : `Expected ${received} to be a valid UUID`,
    };
  },
  toBeValidTimestamp(received: string) {
    const date = new Date(received);
    const pass = !isNaN(date.getTime());
    return {
      pass,
      message: () =>
        pass
          ? `Expected ${received} not to be a valid timestamp`
          : `Expected ${received} to be a valid timestamp`,
    };
  },
});

// Extend Jest matchers TypeScript definitions
declare global {
  namespace jest {
    interface Matchers<R> {
      toBeValidUUID(): R;
      toBeValidTimestamp(): R;
    }
  }
}

// Clean up after tests
afterAll(() => {
  // Restore console methods
  global.console = console;
});