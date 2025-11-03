package analytics

import (
	"fmt"
	"time"

	phClient "github.com/wunderkennd/kaizen-web/packages/go-shared/posthog"
)

// Analytics handles all analytics tracking for the experiment service
type Analytics struct {
	client *phClient.Client
}

// NewAnalytics creates a new analytics instance
func NewAnalytics() (*Analytics, error) {
	client, err := phClient.NewClient(phClient.Config{
		Service: "experiment-service",
	})
	if err != nil {
		return nil, fmt.Errorf("failed to initialize PostHog client: %w", err)
	}

	return &Analytics{
		client: client,
	}, nil
}

// TrackExperimentCreated tracks when a new experiment is created
func (a *Analytics) TrackExperimentCreated(experimentID, experimentName, experimentType string, variants []string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"experiment_id":   experimentID,
		"experiment_name": experimentName,
		"experiment_type": experimentType,
		"variants":        variants,
		"variant_count":   len(variants),
		"created_at":      time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackServiceMetric("experiment_created", 1.0, props)
}

// TrackVariantAssignment tracks when a user is assigned to an experiment variant
func (a *Analytics) TrackVariantAssignment(userID, experimentID, variant string, pcmStage phClient.PCMStage, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"pcm_stage": string(pcmStage),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackExperiment(userID, experimentID, variant, props)
}

// TrackConversion tracks conversion events for experiments
func (a *Analytics) TrackConversion(userID, experimentID, goal string, value float64, metadata map[string]interface{}) error {
	return a.client.TrackConversion(userID, experimentID, goal, value, metadata)
}

// TrackExperimentMetric tracks experiment-specific metrics
func (a *Analytics) TrackExperimentMetric(experimentID, metricName string, value float64, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"experiment_id": experimentID,
		"metric_name":   metricName,
		"metric_value":  value,
		"tracked_at":    time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackServiceMetric("experiment_metric", value, props)
}

// TrackSampleSizeReached tracks when an experiment reaches its sample size
func (a *Analytics) TrackSampleSizeReached(experimentID string, targetSize, actualSize int, timeToReach float64) error {
	return a.client.TrackServiceMetric("sample_size_reached", float64(actualSize), map[string]interface{}{
		"experiment_id":     experimentID,
		"target_size":       targetSize,
		"actual_size":       actualSize,
		"time_to_reach_hrs": timeToReach,
		"reached_at":        time.Now().UTC().Format(time.RFC3339),
	})
}

// TrackExperimentCompleted tracks when an experiment is completed
func (a *Analytics) TrackExperimentCompleted(experimentID, winningVariant string, confidence float64, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"experiment_id":   experimentID,
		"winning_variant": winningVariant,
		"confidence":      confidence,
		"completed_at":    time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackServiceMetric("experiment_completed", 1.0, props)
}

// TrackStatisticalSignificance tracks when statistical significance is reached
func (a *Analytics) TrackStatisticalSignificance(experimentID string, pValue, effect_size float64, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"experiment_id": experimentID,
		"p_value":       pValue,
		"effect_size":   effect_size,
		"significant":   pValue < 0.05,
		"calculated_at": time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackServiceMetric("statistical_significance", pValue, props)
}

// TrackSegmentExperiment tracks segment-specific experiment data
func (a *Analytics) TrackSegmentExperiment(userID, experimentID, segmentID, variant string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"segment_id": segmentID,
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackExperiment(userID, experimentID, variant, props)
}

// TrackMultivariateTest tracks multivariate test assignments
func (a *Analytics) TrackMultivariateTest(userID, testID string, factors map[string]string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"test_id":      testID,
		"factors":      factors,
		"factor_count": len(factors),
		"assigned_at":  time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackEvent(userID, "multivariate_assignment", props)
}

// TrackBayesianUpdate tracks Bayesian experiment updates
func (a *Analytics) TrackBayesianUpdate(experimentID string, priorAlpha, priorBeta, posteriorAlpha, posteriorBeta float64) error {
	return a.client.TrackServiceMetric("bayesian_update", 1.0, map[string]interface{}{
		"experiment_id":   experimentID,
		"prior_alpha":     priorAlpha,
		"prior_beta":      priorBeta,
		"posterior_alpha": posteriorAlpha,
		"posterior_beta":  posteriorBeta,
		"updated_at":      time.Now().UTC().Format(time.RFC3339),
	})
}

// TrackExperimentRollback tracks when an experiment is rolled back
func (a *Analytics) TrackExperimentRollback(experimentID, reason string, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"experiment_id": experimentID,
		"rollback_reason": reason,
		"rolled_back_at":  time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackServiceMetric("experiment_rollback", 1.0, props)
}

// TrackFeatureFlagToggle tracks feature flag state changes
func (a *Analytics) TrackFeatureFlagToggle(flagKey string, enabled bool, metadata map[string]interface{}) error {
	props := map[string]interface{}{
		"flag_key": flagKey,
		"enabled":  enabled,
		"toggled_at": time.Now().UTC().Format(time.RFC3339),
	}
	
	for k, v := range metadata {
		props[k] = v
	}
	
	return a.client.TrackServiceMetric("feature_flag_toggle", 1.0, props)
}

// Close gracefully shuts down the analytics client
func (a *Analytics) Close() error {
	if a.client != nil {
		return a.client.Close()
	}
	return nil
}