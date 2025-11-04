'use client';

import { useEffect, useState, useCallback } from 'react';
import { usePostHog as usePostHogLib, useFeatureFlagEnabled, useFeatureFlagVariantKey } from 'posthog-js/react';
import { PCMStage, PostHogUtils } from '@/providers/posthog';

// Re-export the base hooks
export { usePostHog, useFeatureFlagEnabled, useFeatureFlagVariantKey } from 'posthog-js/react';

/**
 * Hook for PCM stage tracking
 */
export function usePCMTracking() {
  const posthog = usePostHogLib();
  
  const trackStageTransition = useCallback((
    fromStage: PCMStage,
    toStage: PCMStage,
    trigger: string,
    metadata?: Record<string, any>
  ) => {
    posthog?.capture('pcm_stage_transition', {
      from_stage: fromStage,
      to_stage: toStage,
      trigger,
      timestamp: new Date().toISOString(),
      ...metadata,
    });
    
    // Update user properties
    posthog?.setPersonProperties({
      pcm_stage: toStage,
      pcm_last_transition: new Date().toISOString(),
      [`pcm_reached_${toStage}`]: true,
    });
  }, [posthog]);

  const trackEngagement = useCallback((
    action: string,
    score: number,
    metadata?: Record<string, any>
  ) => {
    posthog?.capture('pcm_engagement', {
      action,
      score,
      timestamp: new Date().toISOString(),
      ...metadata,
    });
  }, [posthog]);

  return {
    trackStageTransition,
    trackEngagement,
  };
}

/**
 * Hook for A/B testing experiments
 */
export function useExperiment(experimentKey: string, options?: {
  defaultVariant?: string;
  onExposure?: (variant: string) => void;
}) {
  const posthog = usePostHogLib();
  const [variant, setVariant] = useState<string | null>(options?.defaultVariant || null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!posthog) {
      setIsLoading(false);
      return;
    }

    // Get the feature flag value (which represents the variant)
    const checkVariant = () => {
      const flagValue = posthog.getFeatureFlag(experimentKey);
      
      if (flagValue !== undefined) {
        const variantValue = typeof flagValue === 'string' ? flagValue : flagValue ? 'test' : 'control';
        setVariant(variantValue);
        setIsLoading(false);

        // Track exposure
        posthog.capture('$experiment_started', {
          experiment: experimentKey,
          variant: variantValue,
          timestamp: new Date().toISOString(),
        });

        // Call exposure callback if provided
        if (options?.onExposure) {
          options.onExposure(variantValue);
        }
      } else {
        setIsLoading(false);
      }
    };

    // Check immediately
    checkVariant();

    // Listen for feature flag updates
    posthog.onFeatureFlags(checkVariant);
  }, [posthog, experimentKey, options]);

  const trackConversion = useCallback((goalName: string, value?: number, metadata?: Record<string, any>) => {
    if (posthog && variant) {
      posthog.capture('experiment_conversion', {
        experiment: experimentKey,
        variant,
        goal: goalName,
        value,
        timestamp: new Date().toISOString(),
        ...metadata,
      });
    }
  }, [posthog, experimentKey, variant]);

  return {
    variant,
    isLoading,
    isControl: variant === 'control',
    isTest: variant !== 'control' && variant !== null,
    trackConversion,
  };
}

/**
 * Hook for tracking UI generation events
 */
export function useUIGenerationTracking() {
  const posthog = usePostHogLib();

  const trackUIGenerated = useCallback((
    componentType: string,
    pcmStage: PCMStage,
    metadata?: Record<string, any>
  ) => {
    posthog?.capture('ui_generated', {
      component_type: componentType,
      pcm_stage: pcmStage,
      timestamp: new Date().toISOString(),
      ...metadata,
    });
  }, [posthog]);

  const trackUIInteraction = useCallback((
    componentId: string,
    interactionType: string,
    metadata?: Record<string, any>
  ) => {
    posthog?.capture('ui_interaction', {
      component_id: componentId,
      interaction_type: interactionType,
      timestamp: new Date().toISOString(),
      ...metadata,
    });
  }, [posthog]);

  const trackRuleExecution = useCallback((
    ruleId: string,
    result: 'applied' | 'skipped' | 'error',
    metadata?: Record<string, any>
  ) => {
    posthog?.capture('rule_execution', {
      rule_id: ruleId,
      result,
      timestamp: new Date().toISOString(),
      ...metadata,
    });
  }, [posthog]);

  return {
    trackUIGenerated,
    trackUIInteraction,
    trackRuleExecution,
  };
}

/**
 * Hook for feature flag with PCM context
 */
export function usePCMFeatureFlag(flagKey: string, pcmStage?: PCMStage) {
  const posthog = usePostHogLib();
  const [isEnabled, setIsEnabled] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!posthog) {
      setIsLoading(false);
      return;
    }

    const checkFlag = () => {
      // If PCM stage is provided, check stage-specific flag first
      if (pcmStage) {
        const stageSpecificFlag = posthog.getFeatureFlag(`${flagKey}_${pcmStage}`);
        if (stageSpecificFlag !== undefined) {
          setIsEnabled(!!stageSpecificFlag);
          setIsLoading(false);
          return;
        }
      }

      // Fall back to general flag
      const flag = posthog.getFeatureFlag(flagKey);
      setIsEnabled(!!flag);
      setIsLoading(false);
    };

    checkFlag();
    posthog.onFeatureFlags(checkFlag);
  }, [posthog, flagKey, pcmStage]);

  return { isEnabled, isLoading };
}

/**
 * Hook for tracking analytics events with auto-batching
 */
export function useAnalytics() {
  const posthog = usePostHogLib();
  const [eventQueue, setEventQueue] = useState<Array<{ name: string; properties: any }>>([]);

  // Batch events and send them
  useEffect(() => {
    if (eventQueue.length > 0 && posthog) {
      const timer = setTimeout(() => {
        eventQueue.forEach(event => {
          posthog.capture(event.name, event.properties);
        });
        setEventQueue([]);
      }, 1000); // Batch events every second

      return () => clearTimeout(timer);
    }
  }, [eventQueue, posthog]);

  const track = useCallback((eventName: string, properties?: Record<string, any>) => {
    if (process.env.NODE_ENV === 'development') {
      console.log('Analytics Event:', eventName, properties);
    }

    if (posthog) {
      // For high-priority events, send immediately
      const highPriorityEvents = ['conversion', 'purchase', 'signup', 'error'];
      if (highPriorityEvents.some(e => eventName.includes(e))) {
        posthog.capture(eventName, properties);
      } else {
        // Otherwise, add to queue for batching
        setEventQueue(prev => [...prev, { name: eventName, properties }]);
      }
    }
  }, [posthog]);

  const identify = useCallback((userId: string, properties?: Record<string, any>) => {
    posthog?.identify(userId, properties);
  }, [posthog]);

  const reset = useCallback(() => {
    posthog?.reset();
  }, [posthog]);

  return {
    track,
    identify,
    reset,
  };
}

/**
 * Hook for session recording control
 */
export function useSessionRecording() {
  const posthog = usePostHogLib();
  const [isRecording, setIsRecording] = useState(false);

  useEffect(() => {
    if (posthog) {
      setIsRecording(!posthog.sessionRecording?.disabled);
    }
  }, [posthog]);

  const startRecording = useCallback(() => {
    if (posthog?.sessionRecording) {
      posthog.startSessionRecording();
      setIsRecording(true);
    }
  }, [posthog]);

  const stopRecording = useCallback(() => {
    if (posthog?.sessionRecording) {
      posthog.stopSessionRecording();
      setIsRecording(false);
    }
  }, [posthog]);

  const tagRecording = useCallback((tags: Record<string, any>) => {
    if (posthog) {
      posthog.capture('$session_recording_tag', tags);
    }
  }, [posthog]);

  return {
    isRecording,
    startRecording,
    stopRecording,
    tagRecording,
  };
}

/**
 * Hook for multivariate testing
 */
export function useMultivariateTe st(testKey: string, variants: string[]) {
  const posthog = usePostHogLib();
  const [selectedVariant, setSelectedVariant] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!posthog) {
      setIsLoading(false);
      return;
    }

    const checkVariant = () => {
      const flagValue = posthog.getFeatureFlag(testKey);
      
      if (flagValue && typeof flagValue === 'string' && variants.includes(flagValue)) {
        setSelectedVariant(flagValue);
        
        // Track exposure
        posthog.capture('$experiment_started', {
          experiment: testKey,
          variant: flagValue,
          available_variants: variants,
          timestamp: new Date().toISOString(),
        });
      } else {
        // Default to first variant if flag not found
        setSelectedVariant(variants[0] || null);
      }
      
      setIsLoading(false);
    };

    checkVariant();
    posthog.onFeatureFlags(checkVariant);
  }, [posthog, testKey, variants]);

  const trackInteraction = useCallback((action: string, metadata?: Record<string, any>) => {
    if (posthog && selectedVariant) {
      posthog.capture('multivariate_interaction', {
        test: testKey,
        variant: selectedVariant,
        action,
        timestamp: new Date().toISOString(),
        ...metadata,
      });
    }
  }, [posthog, testKey, selectedVariant]);

  return {
    variant: selectedVariant,
    isLoading,
    trackInteraction,
  };
}