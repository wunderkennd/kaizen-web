package analytics

import (
	"fmt"
	"time"

	phClient "github.com/wunderkennd/kaizen-web/packages/go-shared/posthog"
)

// Analytics handles all analytics tracking for the user context service
type Analytics struct {
	client *phClient.Client
}

// NewAnalytics creates a new analytics instance
func NewAnalytics(serviceName string) (*Analytics, error) {
	client, err := phClient.NewClient(phClient.Config{
		Service: serviceName,
		// Other config will be read from environment variables
	})
	if err != nil {
		return nil, fmt.Errorf("failed to initialize PostHog client: %w", err)
	}

	return &Analytics{
		client: client,
	}, nil
}

// TrackContextUpdate tracks when user context is updated
func (a *Analytics) TrackContextUpdate(userID string, contextType string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"context_type":  contextType,
		"update_source": "user-context-service",
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "context_updated", props)
}

// TrackPCMStageChange tracks PCM stage transitions
func (a *Analytics) TrackPCMStageChange(userID string, from, to phClient.PCMStage, trigger string, metadata map[string]interface{}) error {
	return a.client.TrackPCMTransition(userID, from, to, trigger, metadata)
}

// TrackBehaviorEvent tracks user behavior events
func (a *Analytics) TrackBehaviorEvent(userID, eventType string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"behavior_type": eventType,
		"captured_at":   time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "user_behavior", props)
}

// TrackPreferenceUpdate tracks when user preferences are updated
func (a *Analytics) TrackPreferenceUpdate(userID string, preferenceType string, oldValue, newValue interface{}) error {
	return a.client.TrackEvent(userID, "preference_updated", map[string]interface{}{
		"preference_type": preferenceType,
		"old_value":       oldValue,
		"new_value":       newValue,
		"updated_at":      time.Now().UTC().Format(time.RFC3339),
	})
}

// TrackSegmentAssignment tracks when a user is assigned to a segment
func (a *Analytics) TrackSegmentAssignment(userID, segmentID, segmentName string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"segment_id":   segmentID,
		"segment_name": segmentName,
		"assigned_at":  time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "segment_assigned", props)
}

// TrackFeatureFlagEvaluation tracks feature flag evaluations
func (a *Analytics) TrackFeatureFlagEvaluation(userID, flagKey string, value interface{}, pcmStage string) error {
	return a.client.TrackEvent(userID, "feature_flag_evaluated", map[string]interface{}{
		"flag_key":  flagKey,
		"value":     value,
		"pcm_stage": pcmStage,
		"evaluated_at": time.Now().UTC().Format(time.RFC3339),
	})
}

// IdentifyUser updates user properties in PostHog
func (a *Analytics) IdentifyUser(userID string, properties map[string]interface{}) error {
	return a.client.IdentifyUser(userID, properties)
}

// TrackServiceHealth tracks service health metrics
func (a *Analytics) TrackServiceHealth(healthy bool, latency float64, errorRate float64) error {
	return a.client.TrackServiceMetric("health_check", 1.0, map[string]interface{}{
		"healthy":    healthy,
		"latency_ms": latency,
		"error_rate": errorRate,
		"checked_at": time.Now().UTC().Format(time.RFC3339),
	})
}

// Close gracefully shuts down the analytics client
func (a *Analytics) Close() error {
	if a.client != nil {
		return a.client.Close()
	}
	return nil
}