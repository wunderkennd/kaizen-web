package posthog

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/posthog/posthog-go"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockPostHogClient mocks the PostHog client interface
type MockPostHogClient struct {
	mock.Mock
	Events []posthog.Capture
}

func (m *MockPostHogClient) Enqueue(msg posthog.Message) error {
	args := m.Called(msg)
	if capture, ok := msg.(posthog.Capture); ok {
		m.Events = append(m.Events, capture)
	}
	return args.Error(0)
}

func (m *MockPostHogClient) Close() error {
	args := m.Called()
	return args.Error(0)
}

func (m *MockPostHogClient) GetAllFlags(payload posthog.FeatureFlagPayloadNoKey) (map[string]interface{}, error) {
	args := m.Called(payload)
	return args.Get(0).(map[string]interface{}), args.Error(1)
}

func (m *MockPostHogClient) GetFeatureFlag(payload posthog.FeatureFlagPayload) (interface{}, error) {
	args := m.Called(payload)
	return args.Get(0), args.Error(1)
}

func (m *MockPostHogClient) GetFeatureFlagPayload(payload posthog.FeatureFlagPayload) (string, error) {
	args := m.Called(payload)
	return args.String(0), args.Error(1)
}

func (m *MockPostHogClient) IsFeatureEnabled(payload posthog.FeatureFlagPayload) (interface{}, error) {
	args := m.Called(payload)
	return args.Get(0), args.Error(1)
}

func (m *MockPostHogClient) GetFeatureFlags() ([]posthog.FeatureFlag, error) {
	args := m.Called()
	return args.Get(0).([]posthog.FeatureFlag), args.Error(1)
}

func (m *MockPostHogClient) GetLastCapturedEvent() *posthog.Capture {
	args := m.Called()
	return args.Get(0).(*posthog.Capture)
}

func (m *MockPostHogClient) GetRemoteConfigPayload(key string) (string, error) {
	args := m.Called(key)
	return args.String(0), args.Error(1)
}

func (m *MockPostHogClient) ReloadFeatureFlags() error {
	args := m.Called()
	return args.Error(0)
}

func TestNewClient(t *testing.T) {
	tests := []struct {
		name    string
		config  Config
		envVars map[string]string
		wantErr bool
	}{
		{
			name: "valid config with API key",
			config: Config{
				APIKey:  "test-api-key",
				Host:    "http://localhost:8000",
				Service: "test-service",
				Enabled: true,
			},
			wantErr: false,
		},
		{
			name: "disabled client",
			config: Config{
				Enabled: false,
			},
			envVars: map[string]string{
				"POSTHOG_ENABLED": "false",
			},
			wantErr: false,
		},
		{
			name: "config from environment",
			envVars: map[string]string{
				"POSTHOG_PROJECT_API_KEY": "env-api-key",
				"POSTHOG_HOST":            "http://posthog:8000",
				"SERVICE_NAME":            "env-service",
				"POSTHOG_ENABLED":         "true",
			},
			config:  Config{},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Set environment variables
			for k, v := range tt.envVars {
				os.Setenv(k, v)
				defer os.Unsetenv(k)
			}

			client, err := NewClient(tt.config)
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, client)
			}
		})
	}
}

func TestClient_TrackPCMTransition(t *testing.T) {
	client := &Client{
		enabled: true,
		service: "test-service",
	}

	mockPH := &MockPostHogClient{}
	mockPH.On("Enqueue", mock.Anything).Return(nil)

	// Override the client with mock
	client.client = mockPH

	err := client.TrackPCMTransition(
		"user123",
		PCMStageAwareness,
		PCMStageAttraction,
		"viewed_content",
		map[string]interface{}{
			"content_id": "anime_456",
		},
	)

	assert.NoError(t, err)
	mockPH.AssertCalled(t, "Enqueue", mock.Anything)

	// Verify the event properties
	assert.Equal(t, 1, len(mockPH.Events))
	event := mockPH.Events[0]
	assert.Equal(t, "user123", event.DistinctId)
	assert.Equal(t, "pcm_stage_transition", event.Event)
}

func TestClient_TrackEvent(t *testing.T) {
	client := &Client{
		enabled: true,
		service: "test-service",
	}

	mockPH := &MockPostHogClient{}
	mockPH.On("Enqueue", mock.Anything).Return(nil)
	client.client = mockPH

	err := client.TrackEvent("user123", "test_event", map[string]interface{}{
		"key": "value",
	})

	assert.NoError(t, err)
	mockPH.AssertCalled(t, "Enqueue", mock.Anything)
}

func TestClient_TrackServiceMetric(t *testing.T) {
	client := &Client{
		enabled: true,
		service: "test-service",
	}

	mockPH := &MockPostHogClient{}
	mockPH.On("Enqueue", mock.Anything).Return(nil)
	client.client = mockPH

	err := client.TrackServiceMetric("latency", 150.5, map[string]interface{}{
		"endpoint": "/api/test",
	})

	assert.NoError(t, err)
	mockPH.AssertCalled(t, "Enqueue", mock.Anything)

	// Verify system distinct ID
	assert.Equal(t, 1, len(mockPH.Events))
	event := mockPH.Events[0]
	assert.Equal(t, "system:test-service", event.DistinctId)
}

func TestClient_DisabledTracking(t *testing.T) {
	client := &Client{
		enabled: false,
		service: "test-service",
	}

	// Should not error when disabled
	err := client.TrackEvent("user123", "test_event", nil)
	assert.NoError(t, err)

	err = client.TrackPCMTransition("user123", PCMStageAwareness, PCMStageAttraction, "trigger", nil)
	assert.NoError(t, err)
}

func TestClient_TrackExperiment(t *testing.T) {
	client := &Client{
		enabled: true,
		service: "test-service",
	}

	mockPH := &MockPostHogClient{}
	mockPH.On("Enqueue", mock.Anything).Return(nil)
	client.client = mockPH

	err := client.TrackExperiment("user123", "hero-test", "variant-b", map[string]interface{}{
		"page": "home",
	})

	assert.NoError(t, err)
	mockPH.AssertCalled(t, "Enqueue", mock.Anything)

	// Verify experiment event
	assert.Equal(t, 1, len(mockPH.Events))
	event := mockPH.Events[0]
	assert.Equal(t, "$experiment_started", event.Event)
}

func TestClient_EnableDisable(t *testing.T) {
	client := &Client{
		enabled: true,
		service: "test-service",
	}

	assert.True(t, client.IsEnabled())

	client.Disable()
	assert.False(t, client.IsEnabled())

	client.Enable()
	assert.True(t, client.IsEnabled())
}

func TestContextTracker(t *testing.T) {
	client := &Client{
		enabled: true,
		service: "test-service",
	}

	mockPH := &MockPostHogClient{}
	mockPH.On("Enqueue", mock.Anything).Return(nil)
	client.client = mockPH

	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	tracker := client.WithContext(ctx)

	// Should track successfully
	err := tracker.TrackEvent("user123", "test_event", nil)
	assert.NoError(t, err)

	// Wait for context to expire
	time.Sleep(150 * time.Millisecond)

	// Should error with expired context
	err = tracker.TrackEvent("user123", "test_event", nil)
	assert.Error(t, err)
}

// Benchmark tests
func BenchmarkTrackEvent(b *testing.B) {
	client := &Client{
		enabled: true,
		service: "benchmark-service",
	}

	mockPH := &MockPostHogClient{}
	mockPH.On("Enqueue", mock.Anything).Return(nil)
	client.client = mockPH

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_ = client.TrackEvent("user123", "benchmark_event", map[string]interface{}{
			"iteration": i,
		})
	}
}
