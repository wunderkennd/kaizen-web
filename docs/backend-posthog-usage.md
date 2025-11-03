# Backend PostHog Integration Guide

This guide covers PostHog analytics integration for all backend services in the KAIZEN platform.

## Overview

Each backend service has PostHog analytics integrated to track:
- PCM stage transitions
- Service-specific events and metrics
- Experiment assignments and conversions
- Performance metrics
- Health checks

## Service Implementations

### Go Services

#### Shared Client Package

Location: `packages/go-shared/posthog/`

```go
import "github.com/wunderkennd/kaizen-web/packages/go-shared/posthog"

// Initialize client
client, err := posthog.NewClient(posthog.Config{
    Service: "your-service-name",
})

// Track PCM transition
err = client.TrackPCMTransition(
    userID,
    posthog.PCMStageAwareness,
    posthog.PCMStageAttraction,
    "viewed_content",
    props,
)

// Track custom event
err = client.TrackEvent(userID, "event_name", props)

// Track service metric
err = client.TrackServiceMetric("metric_name", value, props)
```

#### User Context Service

Location: `services/user-context/internal/analytics/`

Key tracking:
- Context updates
- PCM stage changes
- User behavior events
- Preference updates
- Segment assignments

#### GenUI Orchestrator

Location: `services/genui-orchestrator/internal/analytics/`

Key tracking:
- UI component generation
- Rule evaluation metrics
- Personalization applications
- Component interactions
- Cache performance

#### Experiment Service

Location: `services/experiment-service/internal/analytics/`

Key tracking:
- Experiment creation and completion
- Variant assignments
- Conversion events
- Statistical significance
- Multivariate tests

### Rust Services

#### Shared Analytics Module

Location: `packages/rust-shared/src/analytics/`

```rust
use kaizen_shared::analytics::{Analytics, PCMStage, PostHogConfig};

// Initialize
let analytics = Analytics::new(PostHogConfig::default())?;

// Track PCM transition
analytics.track_pcm_transition(
    user_id,
    PCMStage::Awareness,
    PCMStage::Attraction,
    "trigger",
    props,
).await?;

// Track event
analytics.track_event(user_id, "event_name", props).await?;

// Track metric
analytics.track_service_metric("metric", value, props).await?;
```

#### KRE Engine

Location: `services/kre-engine/src/analytics.rs`

Key tracking:
- Rule evaluation and execution
- Rule adaptation and compilation
- Cache hits/misses
- Conflict resolution
- Performance metrics

#### Streaming Adapter

Location: `services/streaming-adapter/src/analytics.rs`

Key tracking:
- WebSocket connections/disconnections
- SSE connections
- Message streaming metrics
- Real-time UI updates
- Connection pool statistics

### Python Services

#### Shared Analytics Package

Location: `packages/python-shared/kaizen_analytics/`

Installation:
```bash
cd packages/python-shared
pip install -e .
```

Usage:
```python
from kaizen_analytics import Analytics, PCMStage

analytics = Analytics()

# Track PCM transition
analytics.track_pcm_transition(
    user_id="user123",
    from_stage=PCMStage.AWARENESS,
    to_stage=PCMStage.ATTRACTION,
    trigger="viewed_content",
    properties={"content_id": "123"}
)

# Track event
analytics.track_event(user_id, "event_name", props)

# Track metric
analytics.track_service_metric("metric", value, props)
```

#### AI Sommelier

Location: `services/ai-sommelier/app/analytics.py`

Key tracking:
- Recommendation generation
- User interactions with recommendations
- Model inference performance
- Vector search operations
- Embedding generation
- Content analysis
- Cache performance

#### Bandit Service

Location: `services/bandit-service/app/analytics.py`

Key tracking:
- Arm selection (epsilon-greedy, UCB, Thompson sampling)
- Reward updates
- Convergence metrics
- Regret tracking
- Contextual bandit decisions
- Exploration vs exploitation
- Batch updates

## Environment Configuration

All services read PostHog configuration from environment variables:

```bash
# Required
POSTHOG_PROJECT_API_KEY=phc_your_api_key
POSTHOG_HOST=http://localhost:8000  # or https://app.posthog.com

# Optional
SERVICE_NAME=your-service-name
POSTHOG_ENABLED=true
POSTHOG_BATCH_SIZE=100
POSTHOG_FLUSH_INTERVAL=10000  # milliseconds
POSTHOG_DEBUG=false
```

## Event Naming Conventions

### System Events
- `health_check` - Service health status
- `[service]_metric` - Service-specific metrics

### PCM Events
- `pcm_stage_transition` - User stage changes
- `pcm_[action]` - PCM-specific actions

### Service Events
- `[service]_[action]` - Service-specific events
- Example: `genui_component_generated`, `kre_rule_evaluated`

### Experiment Events
- `$experiment_started` - Variant assignment
- `experiment_conversion` - Conversion tracking
- `multivariate_assignment` - Multivariate test assignment

## Best Practices

### 1. User Identification

Always use consistent user IDs across services:
```go
// Good
client.TrackEvent(userID, "event", props)

// For system events
client.TrackServiceMetric("metric", value, props)
```

### 2. Error Handling

All implementations gracefully handle PostHog unavailability:
```go
if !client.IsEnabled() {
    return nil  // Silent failure when disabled
}
```

### 3. Property Enrichment

Add contextual properties to all events:
```python
props = {
    "pcm_stage": user.pcm_stage,
    "service": "ai-sommelier",
    "timestamp": datetime.utcnow().isoformat(),
    **custom_props
}
```

### 4. Performance Tracking

Track timing for all critical operations:
```rust
let start = Instant::now();
// ... operation ...
let duration_ms = start.elapsed().as_millis() as f64;

analytics.track_service_metric("operation_time", duration_ms, props).await?;
```

### 5. Batching

High-volume events are automatically batched:
- Go: Uses PostHog client's internal batching
- Rust: Handled by posthog-rs
- Python: Configurable via POSTHOG_BATCH_SIZE

## Testing

### Unit Testing

Mock the analytics client in tests:

```go
// Go example
type MockAnalytics struct {
    events []Event
}

func (m *MockAnalytics) TrackEvent(userID, event string, props map[string]interface{}) error {
    m.events = append(m.events, Event{userID, event, props})
    return nil
}
```

```python
# Python example
from unittest.mock import MagicMock

analytics = MagicMock()
analytics.track_event.return_value = None
```

### Integration Testing

Use PostHog's test mode:
```bash
POSTHOG_ENABLED=false  # Disable in tests
POSTHOG_DEBUG=true     # Enable debug logging
```

## Monitoring

### Key Metrics to Monitor

1. **Event Volume**
   - Events per second by service
   - Event type distribution
   - Error rates

2. **Performance**
   - Event batching efficiency
   - Network latency
   - Queue sizes

3. **Data Quality**
   - Missing required properties
   - Invalid event formats
   - User identification issues

### Debugging

Enable debug mode for verbose logging:
```bash
POSTHOG_DEBUG=true
```

Check service logs for PostHog-related errors:
```bash
grep -i posthog /var/log/service.log
```

## Troubleshooting

### Events Not Appearing

1. Check API key configuration
2. Verify network connectivity to PostHog
3. Enable debug mode
4. Check service logs for errors

### High Memory Usage

1. Reduce batch size
2. Decrease flush interval
3. Check for memory leaks in event properties

### Performance Impact

1. Use async tracking where possible
2. Implement sampling for high-volume events
3. Consider local aggregation before sending

## Migration Guide

If migrating from another analytics provider:

1. **Parallel Tracking**: Run both systems temporarily
2. **Event Mapping**: Create mapping between old and new events
3. **Validation**: Compare metrics between systems
4. **Cutover**: Disable old system after validation

## Support

For issues or questions:
- Check service-specific logs
- Review PostHog dashboard for ingestion errors
- Open GitHub issue with details
- Contact platform team for assistance