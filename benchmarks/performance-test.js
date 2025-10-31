import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// Custom metrics
export let errorRate = new Rate('errors');
export let responseTime = new Trend('response_time');
export let requestCount = new Counter('requests');

// Test configuration
export let options = {
  stages: [
    { duration: '2m', target: 10 }, // Ramp up to 10 users
    { duration: '5m', target: 10 }, // Stay at 10 users
    { duration: '2m', target: 20 }, // Ramp up to 20 users
    { duration: '5m', target: 20 }, // Stay at 20 users
    { duration: '2m', target: 0 },  // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // 95% of requests must complete below 2s
    http_req_failed: ['rate<0.1'],     // Error rate must be below 10%
    errors: ['rate<0.1'],              // Custom error rate must be below 10%
  },
};

// Base URL
const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

// Test scenarios
export default function () {
  // Test 1: Health check
  let healthResponse = http.get(`${BASE_URL}/health`);
  check(healthResponse, {
    'health check status is 200': (r) => r.status === 200,
    'health check response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  errorRate.add(healthResponse.status !== 200);
  responseTime.add(healthResponse.timings.duration);
  requestCount.add(1);
  
  sleep(1);
  
  // Test 2: API endpoint performance
  let apiResponse = http.get(`${BASE_URL}/api/users/me`, {
    headers: {
      'Authorization': 'Bearer test-token',
      'Content-Type': 'application/json',
    },
  });
  
  check(apiResponse, {
    'API response status is 200 or 401': (r) => r.status === 200 || r.status === 401,
    'API response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  
  errorRate.add(apiResponse.status >= 400 && apiResponse.status !== 401);
  responseTime.add(apiResponse.timings.duration);
  requestCount.add(1);
  
  sleep(1);
  
  // Test 3: Component library endpoint
  let componentsResponse = http.get(`${BASE_URL}/api/components`);
  check(componentsResponse, {
    'components endpoint accessible': (r) => r.status < 500,
    'components response time < 1500ms': (r) => r.timings.duration < 1500,
  });
  
  errorRate.add(componentsResponse.status >= 500);
  responseTime.add(componentsResponse.timings.duration);
  requestCount.add(1);
  
  sleep(2);
}

// Setup function runs once before the test
export function setup() {
  console.log('Starting performance test...');
  console.log(`Base URL: ${BASE_URL}`);
  
  // Verify the service is accessible
  let healthCheck = http.get(`${BASE_URL}/health`);
  if (healthCheck.status !== 200) {
    throw new Error(`Service not accessible. Health check returned: ${healthCheck.status}`);
  }
  
  return { timestamp: new Date().toISOString() };
}

// Teardown function runs once after the test
export function teardown(data) {
  console.log('Performance test completed.');
  console.log(`Started at: ${data.timestamp}`);
  console.log(`Completed at: ${new Date().toISOString()}`);
}