# Kaizen Analytics

PostHog analytics integration for Kaizen platform Python services.

## Installation

```bash
pip install -e .
```

## Usage

```python
from kaizen_analytics import Analytics, PCMStage

# Initialize analytics
analytics = Analytics()

# Track PCM transition
analytics.track_pcm_transition(
    user_id="user123",
    from_stage=PCMStage.AWARENESS,
    to_stage=PCMStage.ATTRACTION,
    trigger="viewed_content",
    properties={"content_id": "anime_456"}
)

# Track custom event
analytics.track_event(
    user_id="user123",
    event_name="recommendation_generated",
    properties={"count": 10}
)
```

## Configuration

Set environment variables:
- `POSTHOG_PROJECT_API_KEY`: Your PostHog API key
- `POSTHOG_HOST`: PostHog host URL
- `SERVICE_NAME`: Name of your service
- `POSTHOG_ENABLED`: Enable/disable tracking