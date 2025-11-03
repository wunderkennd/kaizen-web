'use client';

import { useEffect } from 'react';
import posthog from 'posthog-js';
import { PostHogProvider as PHProvider } from 'posthog-js/react';
import { usePathname, useSearchParams } from 'next/navigation';

// Types for PCM tracking
export type PCMStage = 'awareness' | 'attraction' | 'attachment' | 'allegiance';

export interface PCMContext {
  stage: PCMStage;
  score: number;
  history: Array<{
    stage: PCMStage;
    timestamp: string;
    trigger: string;
  }>;
}

interface PostHogProviderProps {
  children: React.ReactNode;
  bootstrapData?: {
    distinctId?: string;
    featureFlags?: Record<string, boolean | string>;
    pcmContext?: PCMContext;
  };
}

// Initialize PostHog only on the client side
if (typeof window !== 'undefined') {
  const posthogKey = process.env.NEXT_PUBLIC_POSTHOG_KEY;
  const posthogHost = process.env.NEXT_PUBLIC_POSTHOG_HOST || 'https://app.posthog.com';

  if (posthogKey) {
    posthog.init(posthogKey, {
      api_host: posthogHost,
      
      // Capture settings
      capture_pageview: false, // We'll handle this manually for better control
      capture_pageleave: true,
      autocapture: true,
      
      // Session recording
      disable_session_recording: process.env.NEXT_PUBLIC_POSTHOG_DISABLE_SESSION_RECORDING === 'true',
      session_recording: {
        maskAllInputs: false,
        maskTextSelector: '[data-sensitive]',
      },
      
      // Performance
      capture_performance: true,
      
      // Feature flags
      bootstrap: {
        featureFlags: {}, // Will be populated from server-side
      },
      
      // Privacy
      mask_all_text: false,
      mask_all_element_attributes: false,
      
      // Other options
      loaded: (posthog) => {
        if (process.env.NODE_ENV === 'development') {
          console.log('PostHog loaded:', posthog);
        }
      },
    });
  } else {
    console.warn('PostHog key not found. Analytics will be disabled.');
  }
}

export function PostHogProvider({ children, bootstrapData }: PostHogProviderProps) {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  // Bootstrap feature flags and user properties if provided
  useEffect(() => {
    if (bootstrapData && typeof window !== 'undefined') {
      // Set user ID if provided
      if (bootstrapData.distinctId) {
        posthog.identify(bootstrapData.distinctId);
      }

      // Bootstrap feature flags for immediate availability
      if (bootstrapData.featureFlags) {
        posthog.featureFlags.override(bootstrapData.featureFlags);
      }

      // Set PCM context as user properties
      if (bootstrapData.pcmContext) {
        posthog.setPersonProperties({
          pcm_stage: bootstrapData.pcmContext.stage,
          pcm_score: bootstrapData.pcmContext.score,
          pcm_history: JSON.stringify(bootstrapData.pcmContext.history),
          pcm_last_updated: new Date().toISOString(),
        });
      }
    }
  }, [bootstrapData]);

  // Track page views
  useEffect(() => {
    if (typeof window !== 'undefined' && pathname) {
      const url = window.location.origin + pathname;
      const search = searchParams?.toString();
      
      posthog.capture('$pageview', {
        $current_url: search ? `${url}?${search}` : url,
        $pathname: pathname,
        $search: search,
      });
    }
  }, [pathname, searchParams]);

  // Track PCM stage transitions
  const trackPCMTransition = (
    fromStage: PCMStage,
    toStage: PCMStage,
    trigger: string,
    metadata?: Record<string, any>
  ) => {
    if (typeof window !== 'undefined') {
      posthog.capture('pcm_stage_transition', {
        from_stage: fromStage,
        to_stage: toStage,
        trigger,
        transition_time: new Date().toISOString(),
        ...metadata,
      });

      // Update user properties
      posthog.setPersonProperties({
        pcm_stage: toStage,
        pcm_last_transition: new Date().toISOString(),
        [`pcm_reached_${toStage}`]: true,
      });
    }
  };

  // Track experiment exposure
  const trackExperimentExposure = (
    experimentKey: string,
    variant: string,
    metadata?: Record<string, any>
  ) => {
    if (typeof window !== 'undefined') {
      posthog.capture('$experiment_started', {
        experiment: experimentKey,
        variant,
        ...metadata,
      });
    }
  };

  // Provide additional context through window object
  useEffect(() => {
    if (typeof window !== 'undefined') {
      (window as any).__posthog = posthog;
      (window as any).__trackPCMTransition = trackPCMTransition;
      (window as any).__trackExperimentExposure = trackExperimentExposure;
    }
  }, []);

  return <PHProvider client={posthog}>{children}</PHProvider>;
}

// Export utility functions for use in components
export const PostHogUtils = {
  // Track custom events
  trackEvent: (eventName: string, properties?: Record<string, any>) => {
    if (typeof window !== 'undefined') {
      posthog.capture(eventName, properties);
    }
  },

  // Track PCM events
  trackPCMEvent: (eventType: string, stage: PCMStage, properties?: Record<string, any>) => {
    if (typeof window !== 'undefined') {
      posthog.capture(`pcm_${eventType}`, {
        pcm_stage: stage,
        ...properties,
      });
    }
  },

  // Get feature flag value
  getFeatureFlag: (flagKey: string): boolean | string | undefined => {
    if (typeof window !== 'undefined') {
      return posthog.getFeatureFlag(flagKey);
    }
    return undefined;
  },

  // Get all feature flags
  getAllFeatureFlags: (): Record<string, boolean | string> => {
    if (typeof window !== 'undefined') {
      return posthog.featureFlags.getAll();
    }
    return {};
  },

  // Identify user
  identify: (distinctId: string, properties?: Record<string, any>) => {
    if (typeof window !== 'undefined') {
      posthog.identify(distinctId, properties);
    }
  },

  // Reset user (on logout)
  reset: () => {
    if (typeof window !== 'undefined') {
      posthog.reset();
    }
  },

  // Set user properties
  setUserProperties: (properties: Record<string, any>) => {
    if (typeof window !== 'undefined') {
      posthog.setPersonProperties(properties);
    }
  },

  // Track conversion goals
  trackConversion: (goalName: string, value?: number, properties?: Record<string, any>) => {
    if (typeof window !== 'undefined') {
      posthog.capture('conversion', {
        goal: goalName,
        value,
        ...properties,
      });
    }
  },

  // A/B test utilities
  getExperimentVariant: (experimentKey: string): string | null => {
    if (typeof window !== 'undefined') {
      const variant = posthog.getFeatureFlag(experimentKey);
      if (variant && typeof variant === 'string') {
        // Track exposure
        posthog.capture('$experiment_started', {
          experiment: experimentKey,
          variant,
        });
        return variant;
      }
    }
    return null;
  },
};