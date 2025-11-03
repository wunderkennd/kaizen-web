package analytics

import (
	"fmt"
	"time"

	phClient "github.com/wunderkennd/kaizen-web/packages/go-shared/posthog"
)

// Analytics handles all analytics tracking for the GenUI orchestrator
type Analytics struct {
	client *phClient.Client
}

// NewAnalytics creates a new analytics instance
func NewAnalytics() (*Analytics, error) {
	client, err := phClient.NewClient(phClient.Config{
		Service: "genui-orchestrator",
	})
	if err != nil {
		return nil, fmt.Errorf("failed to initialize PostHog client: %w", err)
	}

	return &Analytics{
		client: client,
	}, nil
}

// TrackUIGenerated tracks when a UI component is generated
func (a *Analytics) TrackUIGenerated(userID, componentType string, pcmStage phClient.PCMStage, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"component_type": componentType,
		"pcm_stage":      string(pcmStage),
		"generated_at":   time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "ui_generated", props)
}

// TrackRuleEvaluation tracks rule evaluation metrics
func (a *Analytics) TrackRuleEvaluation(userID, ruleID string, result string, executionTime float64, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"rule_id":           ruleID,
		"result":            result,
		"execution_time_ms": executionTime,
		"evaluated_at":      time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "rule_evaluated", props)
}

// TrackPersonalizationApplied tracks when personalization is applied
func (a *Analytics) TrackPersonalizationApplied(userID string, personalizationType string, rulesApplied []string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"personalization_type": personalizationType,
		"rules_applied":        rulesApplied,
		"rules_count":          len(rulesApplied),
		"applied_at":           time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "personalization_applied", props)
}

// TrackComponentInteraction tracks user interactions with generated components
func (a *Analytics) TrackComponentInteraction(userID, componentID, interactionType string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"component_id":     componentID,
		"interaction_type": interactionType,
		"interacted_at":    time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "ui_interaction", props)
}

// TrackGenerationPerformance tracks performance metrics for UI generation
func (a *Analytics) TrackGenerationPerformance(componentType string, generationTime, ruleEvalTime, renderTime float64) error {
	return a.client.TrackServiceMetric("ui_generation_performance", generationTime, map[string]interface{}{
		"component_type":       componentType,
		"generation_time_ms":   generationTime,
		"rule_eval_time_ms":    ruleEvalTime,
		"render_time_ms":       renderTime,
		"total_time_ms":        generationTime + ruleEvalTime + renderTime,
		"measured_at":          time.Now().UTC().Format(time.RFC3339),
	})
}

// TrackCacheHit tracks cache hit/miss metrics
func (a *Analytics) TrackCacheHit(userID, cacheKey string, hit bool, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"cache_key": cacheKey,
		"cache_hit": hit,
		"cached_at": time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "cache_access", props)
}

// TrackABTestVariant tracks when a user is assigned to an A/B test variant
func (a *Analytics) TrackABTestVariant(userID, experimentKey, variant string, metadata map[string]interface{}) error {
	return a.client.TrackExperiment(userID, experimentKey, variant, metadata)
}

// TrackConversion tracks conversion events
func (a *Analytics) TrackConversion(userID, experimentKey, goal string, value float64) error {
	return a.client.TrackConversion(userID, experimentKey, goal, value, nil)
}

// TrackError tracks error events
func (a *Analytics) TrackError(userID, errorType, errorMessage string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"error_type":    errorType,
		"error_message": errorMessage,
		"occurred_at":   time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "genui_error", props)
}

// TrackBatchGeneration tracks batch UI generation metrics
func (a *Analytics) TrackBatchGeneration(batchID string, componentCount int, totalTime float64, successCount, failureCount int) error {
	return a.client.TrackServiceMetric("batch_generation", float64(componentCount), map[string]interface{}{
		"batch_id":        batchID,
		"component_count": componentCount,
		"total_time_ms":   totalTime,
		"success_count":   successCount,
		"failure_count":   failureCount,
		"success_rate":    float64(successCount) / float64(componentCount),
		"generated_at":    time.Now().UTC().Format(time.RFC3339),
	})
}

// Close gracefully shuts down the analytics client
func (a *Analytics) Close() error {
	if a.client != nil {
		return a.client.Close()
	}
	return nil
}