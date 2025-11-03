# PostHog Analytics & Experimentation Setup

## Overview

PostHog provides comprehensive analytics, A/B testing, feature flags, and session recording capabilities for the KAIZEN platform. Our integration includes custom PCM (Psychological Continuum Model) tracking and advanced experimentation features.

## Quick Start

### 1. Start PostHog Services

```bash
# Start PostHog with Docker Compose
docker-compose -f docker-compose.posthog.yml up -d

# Verify services are running
docker-compose -f docker-compose.posthog.yml ps
```

### 2. Set Up Environment Variables

```bash
# Copy the example configuration
cp .env.posthog.example .env.posthog

# Edit with your values
vim .env.posthog
```

Required environment variables:
- `NEXT_PUBLIC_POSTHOG_KEY`: Your PostHog project API key
- `NEXT_PUBLIC_POSTHOG_HOST`: PostHog host URL (default: http://localhost:8000)
- `POSTHOG_PERSONAL_API_KEY`: For server-side operations

### 3. Initial PostHog Configuration

1. Access PostHog at http://localhost:8000
2. Create your first project
3. Copy the project API key to `.env.posthog`
4. Configure your organization settings

## Frontend Integration

### Provider Setup

The PostHog provider is already configured in the frontend application. It wraps your app with analytics context:

```tsx
// app/layout.tsx
import { PostHogProvider } from '@/providers/posthog';

export default function RootLayout({ children }) {
  return (
    <PostHogProvider>
      {children}
    </PostHogProvider>
  );
}
```

### Using PostHog Hooks

#### PCM Stage Tracking

Track user progression through PCM stages:

```tsx
import { usePCMTracking } from '@/hooks/usePostHog';

function UserJourneyComponent() {
  const { trackStageTransition, trackEngagement } = usePCMTracking();
  
  const handleUserAction = () => {
    // Track stage transition
    trackStageTransition('awareness', 'attraction', 'viewed_content', {
      content_id: 'anime_123',
      interaction_time: 30
    });
    
    // Track engagement score
    trackEngagement('watched_video', 10, {
      video_id: 'trailer_456'
    });
  };
}
```

#### A/B Testing

Run experiments with automatic variant assignment:

```tsx
import { useExperiment } from '@/hooks/usePostHog';

function HeroSection() {
  const { variant, isLoading, trackConversion } = useExperiment('hero-layout-test', {
    defaultVariant: 'control',
    onExposure: (variant) => console.log('User exposed to:', variant)
  });
  
  if (isLoading) return <Skeleton />;
  
  const handleCTA = () => {
    trackConversion('clicked_cta', 1, { button_text: 'Get Started' });
  };
  
  return variant === 'test' ? <NewHeroLayout /> : <StandardHeroLayout />;
}
```

#### Feature Flags with PCM Context

Enable features based on user's PCM stage:

```tsx
import { usePCMFeatureFlag } from '@/hooks/usePostHog';

function ContentRecommendations({ userStage }) {
  const { isEnabled, isLoading } = usePCMFeatureFlag('advanced_recommendations', userStage);
  
  if (!isEnabled) return <BasicRecommendations />;
  
  return <AIRecommendations />;
}
```

#### UI Generation Tracking

Monitor dynamically generated UI components:

```tsx
import { useUIGenerationTracking } from '@/hooks/usePostHog';

function DynamicUIComponent({ componentType, pcmStage }) {
  const { trackUIGenerated, trackUIInteraction, trackRuleExecution } = useUIGenerationTracking();
  
  useEffect(() => {
    trackUIGenerated(componentType, pcmStage, {
      rules_applied: ['rule_1', 'rule_2'],
      generation_time: 150
    });
  }, []);
  
  const handleInteraction = (interactionType) => {
    trackUIInteraction(componentId, interactionType, {
      pcm_stage: pcmStage,
      timestamp: Date.now()
    });
  };
}
```

#### Multivariate Testing

Test multiple variations simultaneously:

```tsx
import { useMultivariateTest } from '@/hooks/usePostHog';

function OnboardingFlow() {
  const { variant, isLoading, trackInteraction } = useMultivariateTest(
    'onboarding-flow',
    ['minimal', 'guided', 'gamified']
  );
  
  const handleStepComplete = (step) => {
    trackInteraction('step_completed', { step_number: step });
  };
  
  switch (variant) {
    case 'gamified':
      return <GamifiedOnboarding onComplete={handleStepComplete} />;
    case 'guided':
      return <GuidedOnboarding onComplete={handleStepComplete} />;
    default:
      return <MinimalOnboarding onComplete={handleStepComplete} />;
  }
}
```

#### Analytics with Auto-batching

Track events efficiently with automatic batching:

```tsx
import { useAnalytics } from '@/hooks/usePostHog';

function InteractiveComponent() {
  const { track, identify, reset } = useAnalytics();
  
  const handleUserLogin = (userId, userProps) => {
    identify(userId, {
      ...userProps,
      pcm_stage: 'awareness',
      signup_date: new Date().toISOString()
    });
  };
  
  const handleUserAction = () => {
    // Low-priority events are batched
    track('button_hover', { button_id: 'cta_1' });
    
    // High-priority events sent immediately
    track('purchase_completed', { amount: 99.99, product_id: 'premium' });
  };
  
  const handleLogout = () => {
    reset(); // Clear user data
  };
}
```

## Backend Integration

### Go Services

```go
// Install the PostHog Go client
// go get github.com/posthog/posthog-go

import (
    "github.com/posthog/posthog-go"
)

func initPostHog() posthog.Client {
    client, _ := posthog.NewWithConfig(
        os.Getenv("POSTHOG_PROJECT_API_KEY"),
        posthog.Config{
            Endpoint: os.Getenv("POSTHOG_HOST"),
        },
    )
    return client
}

// Track PCM transitions
func trackPCMTransition(userID string, from, to, trigger string) {
    client.Enqueue(posthog.Capture{
        DistinctId: userID,
        Event:      "pcm_stage_transition",
        Properties: posthog.NewProperties().
            Set("from_stage", from).
            Set("to_stage", to).
            Set("trigger", trigger),
    })
}
```

### Python Services

```python
# Install: pip install posthog

from posthog import Posthog
import os

posthog = Posthog(
    project_api_key=os.getenv('POSTHOG_PROJECT_API_KEY'),
    host=os.getenv('POSTHOG_HOST')
)

def track_ai_recommendation(user_id: str, recommendations: list, pcm_stage: str):
    posthog.capture(
        user_id,
        'ai_recommendation_generated',
        {
            'recommendation_count': len(recommendations),
            'pcm_stage': pcm_stage,
            'model_version': '1.0.0',
            'recommendations': recommendations[:5]  # Track top 5
        }
    )

def track_experiment_assignment(user_id: str, experiment: str, variant: str):
    posthog.capture(
        user_id,
        '$experiment_started',
        {
            'experiment': experiment,
            'variant': variant
        }
    )
```

### Rust Services

```rust
// Add to Cargo.toml:
// [dependencies]
// posthog-rs = "0.2"

use posthog_rs::{Event, Client, Properties};

fn init_posthog() -> Client {
    Client::new(
        env::var("POSTHOG_PROJECT_API_KEY").unwrap(),
        env::var("POSTHOG_HOST").unwrap_or("https://app.posthog.com".to_string())
    )
}

fn track_rule_execution(user_id: &str, rule_id: &str, result: &str) {
    let client = init_posthog();
    
    let mut props = Properties::new();
    props.insert("rule_id".to_string(), rule_id.into());
    props.insert("result".to_string(), result.into());
    props.insert("execution_time_ms".to_string(), 25.into());
    
    client.capture(Event {
        event: "rule_execution".to_string(),
        distinct_id: user_id.to_string(),
        properties: props,
        ..Default::default()
    });
}
```

## PCM Stage Definitions

Our implementation tracks users through four stages:

1. **Awareness**: User discovers the platform
   - Events: page_view, search, browse_catalog
   - Metrics: bounce rate, session duration

2. **Attraction**: User shows interest
   - Events: content_view, add_to_list, share
   - Metrics: engagement rate, return visits

3. **Attachment**: User forms connection
   - Events: create_account, personalize_preferences, rate_content
   - Metrics: feature adoption, session frequency

4. **Allegiance**: User becomes advocate
   - Events: premium_upgrade, invite_friends, create_content
   - Metrics: LTV, referral rate, NPS

## Experimentation Framework

### Creating Experiments

1. Define hypothesis and success metrics
2. Set up feature flag in PostHog
3. Implement variant logic in code
4. Track exposure and conversions
5. Analyze results in PostHog dashboard

### Example Experiment Configuration

```typescript
// Experiment: Personalized vs Standard Onboarding
const EXPERIMENT_CONFIG = {
  key: 'onboarding-personalization',
  variants: ['control', 'personalized'],
  metrics: {
    primary: 'activation_rate',
    secondary: ['time_to_value', 'feature_adoption']
  },
  minimum_sample_size: 1000,
  pcm_stage_filter: 'awareness'
};
```

## Cohort Analysis

Create cohorts based on PCM stages:

```sql
-- Example cohort definitions in PostHog
-- Awareness Cohort: New users in last 7 days
-- Attraction Cohort: Users with >3 content views
-- Attachment Cohort: Users who created account
-- Allegiance Cohort: Premium subscribers
```

## Session Recording

Control session recording programmatically:

```tsx
import { useSessionRecording } from '@/hooks/usePostHog';

function PrivacySettings() {
  const { isRecording, startRecording, stopRecording, tagRecording } = useSessionRecording();
  
  const handleConsentChange = (consent) => {
    if (consent) {
      startRecording();
      tagRecording({ consent_given: true, timestamp: Date.now() });
    } else {
      stopRecording();
    }
  };
}
```

## Dashboard Setup

### Key Metrics to Track

1. **PCM Progression Funnel**
   - Awareness → Attraction conversion
   - Attraction → Attachment conversion
   - Attachment → Allegiance conversion

2. **Engagement Metrics**
   - Daily/Weekly/Monthly active users by PCM stage
   - Feature adoption by stage
   - Time spent per stage

3. **Experimentation Metrics**
   - Experiment exposure rates
   - Conversion rates by variant
   - Statistical significance

4. **UI Generation Performance**
   - Rules executed per session
   - Component generation time
   - Personalization effectiveness

## Troubleshooting

### Common Issues

1. **PostHog not receiving events**
   - Check API key configuration
   - Verify network connectivity
   - Check browser console for errors

2. **Feature flags not updating**
   - Clear PostHog cache
   - Check polling interval settings
   - Verify flag configuration in dashboard

3. **Session recordings not working**
   - Check recording settings
   - Verify user consent
   - Check browser compatibility

### Debug Mode

Enable debug logging:

```typescript
// Frontend
if (process.env.NODE_ENV === 'development') {
  window.__POSTHOG_DEBUG__ = true;
}

// Backend (Node.js)
process.env.POSTHOG_DEBUG = 'true';
```

## Performance Optimization

1. **Batch Events**: Use auto-batching for non-critical events
2. **Sampling**: Configure session recording sampling rate
3. **Selective Tracking**: Only track relevant user actions
4. **CDN Usage**: Load PostHog script from CDN in production

## Security Considerations

1. **PII Protection**: Never send personally identifiable information
2. **Data Masking**: Use `data-sensitive` attribute for sensitive elements
3. **API Key Management**: Keep server-side keys secure
4. **GDPR Compliance**: Implement consent management

## Maintenance

### Regular Tasks

- Weekly: Review experiment results
- Monthly: Audit event taxonomy
- Quarterly: Clean up unused feature flags
- Annually: Review data retention policies

### Monitoring

Set up alerts for:
- Event ingestion failures
- Experiment sample size reached
- Anomalies in PCM progression
- Performance degradation

## Resources

- [PostHog Documentation](https://posthog.com/docs)
- [PostHog API Reference](https://posthog.com/docs/api)
- [PCM Integration Guide](./pcm-tracking.md)
- [Experimentation Best Practices](./experimentation.md)

## Support

For issues or questions:
- Check PostHog status: http://localhost:8000/status
- View logs: `docker-compose -f docker-compose.posthog.yml logs`
- GitHub Issues: https://github.com/wunderkennd/kaizen-web/issues