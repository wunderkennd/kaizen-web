package posthog

import (
	"context"
	"fmt"
	"os"
	"strconv"
	"sync"
	"time"

	"github.com/posthog/posthog-go"
)

// PCMStage represents the user's stage in the Psychological Continuum Model
type PCMStage string

const (
	PCMStageAwareness   PCMStage = "awareness"
	PCMStageAttraction  PCMStage = "attraction"
	PCMStageAttachment  PCMStage = "attachment"
	PCMStageAllegiance  PCMStage = "allegiance"
)

// Client wraps the PostHog client with PCM-specific functionality
type Client struct {
	client    posthog.Client
	enabled   bool
	service   string
	mu        sync.RWMutex
	batchSize int
	flushInterval time.Duration
}

// Config holds PostHog client configuration
type Config struct {
	APIKey        string
	Host          string
	Service       string
	Enabled       bool
	BatchSize     int
	FlushInterval time.Duration
}

// NewClient creates a new PostHog client with PCM support
func NewClient(cfg Config) (*Client, error) {
	// Use environment variables as fallback
	if cfg.APIKey == "" {
		cfg.APIKey = os.Getenv("POSTHOG_PROJECT_API_KEY")
	}
	if cfg.Host == "" {
		cfg.Host = os.Getenv("POSTHOG_HOST")
		if cfg.Host == "" {
			cfg.Host = "https://app.posthog.com"
		}
	}
	if cfg.Service == "" {
		cfg.Service = os.Getenv("SERVICE_NAME")
	}
	
	// Parse enabled flag from env if not set
	if !cfg.Enabled {
		if enabled := os.Getenv("POSTHOG_ENABLED"); enabled != "" {
			cfg.Enabled, _ = strconv.ParseBool(enabled)
		} else {
			cfg.Enabled = true // Default to enabled
		}
	}
	
	// Parse batch configuration
	if cfg.BatchSize == 0 {
		if size := os.Getenv("POSTHOG_BATCH_SIZE"); size != "" {
			cfg.BatchSize, _ = strconv.Atoi(size)
		} else {
			cfg.BatchSize = 100
		}
	}
	
	if cfg.FlushInterval == 0 {
		if interval := os.Getenv("POSTHOG_FLUSH_INTERVAL"); interval != "" {
			ms, _ := strconv.Atoi(interval)
			cfg.FlushInterval = time.Duration(ms) * time.Millisecond
		} else {
			cfg.FlushInterval = 10 * time.Second
		}
	}
	
	c := &Client{
		enabled:       cfg.Enabled,
		service:       cfg.Service,
		batchSize:     cfg.BatchSize,
		flushInterval: cfg.FlushInterval,
	}
	
	if !cfg.Enabled {
		return c, nil
	}
	
	if cfg.APIKey == "" {
		return nil, fmt.Errorf("PostHog API key is required when enabled")
	}
	
	phClient, err := posthog.NewWithConfig(
		cfg.APIKey,
		posthog.Config{
			Endpoint:  cfg.Host,
			BatchSize: cfg.BatchSize,
			Interval:  cfg.FlushInterval,
			Verbose:   os.Getenv("POSTHOG_DEBUG") == "true",
		},
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create PostHog client: %w", err)
	}
	
	c.client = phClient
	return c, nil
}

// TrackPCMTransition tracks a user's transition between PCM stages
func (c *Client) TrackPCMTransition(userID string, from, to PCMStage, trigger string, props map[string]interface{}) error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	properties := posthog.NewProperties().
		Set("from_stage", string(from)).
		Set("to_stage", string(to)).
		Set("trigger", trigger).
		Set("service", c.service).
		Set("timestamp", time.Now().UTC().Format(time.RFC3339))
	
	for k, v := range props {
		properties.Set(k, v)
	}
	
	return c.client.Enqueue(posthog.Capture{
		DistinctId: userID,
		Event:      "pcm_stage_transition",
		Properties: properties,
		Timestamp:  time.Now(),
	})
}

// TrackEvent tracks a generic event with service context
func (c *Client) TrackEvent(userID, event string, props map[string]interface{}) error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	properties := posthog.NewProperties().
		Set("service", c.service).
		Set("timestamp", time.Now().UTC().Format(time.RFC3339))
	
	for k, v := range props {
		properties.Set(k, v)
	}
	
	return c.client.Enqueue(posthog.Capture{
		DistinctId: userID,
		Event:      event,
		Properties: properties,
		Timestamp:  time.Now(),
	})
}

// TrackServiceMetric tracks service-specific metrics
func (c *Client) TrackServiceMetric(metric string, value float64, props map[string]interface{}) error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	// Use system as distinct ID for service metrics
	distinctID := fmt.Sprintf("system:%s", c.service)
	
	properties := posthog.NewProperties().
		Set("service", c.service).
		Set("metric_name", metric).
		Set("metric_value", value).
		Set("timestamp", time.Now().UTC().Format(time.RFC3339))
	
	for k, v := range props {
		properties.Set(k, v)
	}
	
	return c.client.Enqueue(posthog.Capture{
		DistinctId: distinctID,
		Event:      fmt.Sprintf("%s_metric", c.service),
		Properties: properties,
		Timestamp:  time.Now(),
	})
}

// IdentifyUser sets or updates user properties
func (c *Client) IdentifyUser(userID string, props map[string]interface{}) error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	properties := posthog.NewProperties()
	for k, v := range props {
		properties.Set(k, v)
	}
	
	return c.client.Enqueue(posthog.Identify{
		DistinctId: userID,
		Properties: properties,
		Timestamp:  time.Now(),
	})
}

// TrackExperiment tracks experiment assignment
func (c *Client) TrackExperiment(userID, experimentKey, variant string, props map[string]interface{}) error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	properties := posthog.NewProperties().
		Set("experiment", experimentKey).
		Set("variant", variant).
		Set("service", c.service).
		Set("timestamp", time.Now().UTC().Format(time.RFC3339))
	
	for k, v := range props {
		properties.Set(k, v)
	}
	
	return c.client.Enqueue(posthog.Capture{
		DistinctId: userID,
		Event:      "$experiment_started",
		Properties: properties,
		Timestamp:  time.Now(),
	})
}

// TrackConversion tracks conversion events for experiments
func (c *Client) TrackConversion(userID, experimentKey, goal string, value float64, props map[string]interface{}) error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	properties := posthog.NewProperties().
		Set("experiment", experimentKey).
		Set("goal", goal).
		Set("value", value).
		Set("service", c.service).
		Set("timestamp", time.Now().UTC().Format(time.RFC3339))
	
	for k, v := range props {
		properties.Set(k, v)
	}
	
	return c.client.Enqueue(posthog.Capture{
		DistinctId: userID,
		Event:      "experiment_conversion",
		Properties: properties,
		Timestamp:  time.Now(),
	})
}

// Flush forces sending of queued events
func (c *Client) Flush() error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	return c.client.Close()
}

// Close gracefully shuts down the client
func (c *Client) Close() error {
	if !c.enabled || c.client == nil {
		return nil
	}
	
	return c.client.Close()
}

// IsEnabled returns whether PostHog tracking is enabled
func (c *Client) IsEnabled() bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.enabled
}

// Enable enables PostHog tracking
func (c *Client) Enable() {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.enabled = true
}

// Disable disables PostHog tracking
func (c *Client) Disable() {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.enabled = false
}

// WithContext creates a context-aware tracking helper
func (c *Client) WithContext(ctx context.Context) *ContextTracker {
	return &ContextTracker{
		client: c,
		ctx:    ctx,
	}
}

// ContextTracker provides context-aware tracking
type ContextTracker struct {
	client *Client
	ctx    context.Context
}

// TrackEvent tracks an event with context awareness
func (ct *ContextTracker) TrackEvent(userID, event string, props map[string]interface{}) error {
	select {
	case <-ct.ctx.Done():
		return ct.ctx.Err()
	default:
		return ct.client.TrackEvent(userID, event, props)
	}
}

// TrackPCMTransition tracks PCM transition with context awareness
func (ct *ContextTracker) TrackPCMTransition(userID string, from, to PCMStage, trigger string, props map[string]interface{}) error {
	select {
	case <-ct.ctx.Done():
		return ct.ctx.Err()
	default:
		return ct.client.TrackPCMTransition(userID, from, to, trigger, props)
	}
}