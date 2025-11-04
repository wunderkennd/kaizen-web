/**
 * Integration tests for PostHog analytics across services
 */

import { spawn, ChildProcess } from 'child_process';
import axios from 'axios';
import { v4 as uuidv4 } from 'uuid';

describe('PostHog Integration Tests', () => {
  let postHogProcess: ChildProcess;
  const POSTHOG_HOST = 'http://localhost:8000';
  const TEST_API_KEY = 'phc_test_key_integration';
  const USER_ID = `test-user-${uuidv4()}`;

  beforeAll(async () => {
    // Start PostHog stack
    console.log('Starting PostHog stack...');
    postHogProcess = spawn('docker-compose', [
      '-f',
      'docker-compose.posthog.yml',
      'up',
      '-d'
    ]);

    // Wait for PostHog to be ready
    await waitForService(POSTHOG_HOST, 60000);
  }, 120000);

  afterAll(async () => {
    // Stop PostHog stack
    console.log('Stopping PostHog stack...');
    spawn('docker-compose', ['-f', 'docker-compose.posthog.yml', 'down']);
  });

  describe('Service Health Checks', () => {
    test('PostHog web service should be healthy', async () => {
      const response = await axios.get(`${POSTHOG_HOST}/_health`);
      expect(response.status).toBe(200);
    });

    test('PostHog can receive events', async () => {
      const response = await axios.post(
        `${POSTHOG_HOST}/capture`,
        {
          api_key: TEST_API_KEY,
          event: 'integration_test_event',
          distinct_id: USER_ID,
          properties: {
            test: true,
            timestamp: new Date().toISOString(),
          },
        }
      );
      expect(response.status).toBe(200);
    });
  });

  describe('PCM Stage Tracking', () => {
    test('should track PCM stage transitions', async () => {
      const stages = [
        { from: 'awareness', to: 'attraction' },
        { from: 'attraction', to: 'attachment' },
        { from: 'attachment', to: 'allegiance' },
      ];

      for (const stage of stages) {
        const response = await axios.post(
          `${POSTHOG_HOST}/capture`,
          {
            api_key: TEST_API_KEY,
            event: 'pcm_stage_transition',
            distinct_id: USER_ID,
            properties: {
              from_stage: stage.from,
              to_stage: stage.to,
              trigger: 'integration_test',
              service: 'test-service',
              timestamp: new Date().toISOString(),
            },
          }
        );
        expect(response.status).toBe(200);
      }
    });
  });

  describe('Experiment Tracking', () => {
    test('should track experiment assignments', async () => {
      const response = await axios.post(
        `${POSTHOG_HOST}/capture`,
        {
          api_key: TEST_API_KEY,
          event: '$experiment_started',
          distinct_id: USER_ID,
          properties: {
            experiment: 'integration_test_experiment',
            variant: 'test_variant',
            service: 'test-service',
            timestamp: new Date().toISOString(),
          },
        }
      );
      expect(response.status).toBe(200);
    });

    test('should track conversions', async () => {
      const response = await axios.post(
        `${POSTHOG_HOST}/capture`,
        {
          api_key: TEST_API_KEY,
          event: 'experiment_conversion',
          distinct_id: USER_ID,
          properties: {
            experiment: 'integration_test_experiment',
            goal: 'test_conversion',
            value: 1.0,
            service: 'test-service',
            timestamp: new Date().toISOString(),
          },
        }
      );
      expect(response.status).toBe(200);
    });
  });

  describe('Service Metrics', () => {
    test('should track service health metrics', async () => {
      const services = [
        'genui-orchestrator',
        'user-context',
        'kre-engine',
        'ai-sommelier',
        'bandit-service',
      ];

      for (const service of services) {
        const response = await axios.post(
          `${POSTHOG_HOST}/capture`,
          {
            api_key: TEST_API_KEY,
            event: `${service}_metric`,
            distinct_id: `system:${service}`,
            properties: {
              metric_name: 'health_check',
              metric_value: 1.0,
              healthy: true,
              latency_ms: Math.random() * 100,
              error_rate: Math.random() * 0.01,
              timestamp: new Date().toISOString(),
            },
          }
        );
        expect(response.status).toBe(200);
      }
    });
  });

  describe('End-to-End Event Flow', () => {
    test('should handle complete user journey', async () => {
      const journey = [
        { event: 'page_view', stage: 'awareness' },
        { event: 'content_viewed', stage: 'awareness' },
        { event: 'pcm_stage_transition', from: 'awareness', to: 'attraction' },
        { event: 'recommendation_generated', stage: 'attraction' },
        { event: 'ui_generated', stage: 'attraction' },
        { event: 'preference_updated', stage: 'attraction' },
        { event: 'pcm_stage_transition', from: 'attraction', to: 'attachment' },
        { event: 'account_created', stage: 'attachment' },
        { event: 'personalization_applied', stage: 'attachment' },
        { event: 'pcm_stage_transition', from: 'attachment', to: 'allegiance' },
        { event: 'premium_upgrade', stage: 'allegiance' },
      ];

      for (const step of journey) {
        const properties: any = {
          service: 'integration-test',
          timestamp: new Date().toISOString(),
        };

        if (step.stage) {
          properties.pcm_stage = step.stage;
        }
        if (step.from) {
          properties.from_stage = step.from;
          properties.to_stage = step.to;
        }

        const response = await axios.post(
          `${POSTHOG_HOST}/capture`,
          {
            api_key: TEST_API_KEY,
            event: step.event,
            distinct_id: USER_ID,
            properties,
          }
        );
        expect(response.status).toBe(200);
      }
    });
  });

  describe('Batch Event Processing', () => {
    test('should handle batch events', async () => {
      const batchSize = 100;
      const events = [];

      for (let i = 0; i < batchSize; i++) {
        events.push({
          api_key: TEST_API_KEY,
          event: 'batch_test_event',
          distinct_id: `batch-user-${i}`,
          properties: {
            index: i,
            batch: true,
            timestamp: new Date().toISOString(),
          },
        });
      }

      // PostHog batch endpoint
      const response = await axios.post(
        `${POSTHOG_HOST}/batch`,
        {
          api_key: TEST_API_KEY,
          batch: events,
        }
      );
      expect(response.status).toBe(200);
    });
  });

  describe('Feature Flags', () => {
    test('should evaluate feature flags', async () => {
      // Note: This would require setting up feature flags in PostHog first
      // For integration testing, we're just verifying the API works
      const response = await axios.post(
        `${POSTHOG_HOST}/decide`,
        {
          api_key: TEST_API_KEY,
          distinct_id: USER_ID,
          groups: {},
          person_properties: {
            pcm_stage: 'attraction',
          },
        }
      );
      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('featureFlags');
    });
  });
});

/**
 * Helper function to wait for a service to be ready
 */
async function waitForService(url: string, timeout: number = 30000): Promise<void> {
  const startTime = Date.now();
  
  while (Date.now() - startTime < timeout) {
    try {
      await axios.get(`${url}/_health`);
      console.log(`Service at ${url} is ready`);
      return;
    } catch (error) {
      console.log(`Waiting for service at ${url}...`);
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
  
  throw new Error(`Service at ${url} did not become ready within ${timeout}ms`);
}