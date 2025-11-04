import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react';
import { usePostHog as usePostHogLib } from 'posthog-js/react';
import {
  usePCMTracking,
  useExperiment,
  useUIGenerationTracking,
  usePCMFeatureFlag,
  useAnalytics,
  useSessionRecording,
  useMultivariateTest,
} from '../usePostHog';

// Mock posthog-js/react
jest.mock('posthog-js/react', () => ({
  usePostHog: jest.fn(),
  useFeatureFlagEnabled: jest.fn(),
  useFeatureFlagVariantKey: jest.fn(),
}));

describe('usePostHog Hooks', () => {
  let mockPostHog: any;

  beforeEach(() => {
    mockPostHog = {
      capture: jest.fn(),
      setPersonProperties: jest.fn(),
      getFeatureFlag: jest.fn(),
      identify: jest.fn(),
      reset: jest.fn(),
      onFeatureFlags: jest.fn(),
      startSessionRecording: jest.fn(),
      stopSessionRecording: jest.fn(),
      sessionRecording: { disabled: false },
    };

    (usePostHogLib as jest.Mock).mockReturnValue(mockPostHog);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('usePCMTracking', () => {
    it('should track stage transitions', () => {
      const { result } = renderHook(() => usePCMTracking());

      act(() => {
        result.current.trackStageTransition(
          'awareness',
          'attraction',
          'viewed_content',
          { content_id: '123' }
        );
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('pcm_stage_transition', {
        from_stage: 'awareness',
        to_stage: 'attraction',
        trigger: 'viewed_content',
        timestamp: expect.any(String),
        content_id: '123',
      });

      expect(mockPostHog.setPersonProperties).toHaveBeenCalledWith({
        pcm_stage: 'attraction',
        pcm_last_transition: expect.any(String),
        pcm_reached_attraction: true,
      });
    });

    it('should track engagement', () => {
      const { result } = renderHook(() => usePCMTracking());

      act(() => {
        result.current.trackEngagement('watched_video', 10, { video_id: '456' });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('pcm_engagement', {
        action: 'watched_video',
        score: 10,
        timestamp: expect.any(String),
        video_id: '456',
      });
    });
  });

  describe('useExperiment', () => {
    it('should return experiment variant', async () => {
      mockPostHog.getFeatureFlag.mockReturnValue('test');
      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        setTimeout(() => callback(), 0);
      });

      const { result } = renderHook(() =>
        useExperiment('hero-test', { defaultVariant: 'control' })
      );

      expect(result.current.variant).toBe('control');
      expect(result.current.isLoading).toBe(true);

      await waitFor(() => {
        expect(result.current.variant).toBe('test');
        expect(result.current.isLoading).toBe(false);
        expect(result.current.isTest).toBe(true);
        expect(result.current.isControl).toBe(false);
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('$experiment_started', {
        experiment: 'hero-test',
        variant: 'test',
        timestamp: expect.any(String),
      });
    });

    it('should track conversion', async () => {
      mockPostHog.getFeatureFlag.mockReturnValue('test');
      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        callback();
      });

      const { result } = renderHook(() => useExperiment('hero-test'));

      await waitFor(() => {
        expect(result.current.variant).toBe('test');
      });

      act(() => {
        result.current.trackConversion('clicked_cta', 1, { button: 'signup' });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('experiment_conversion', {
        experiment: 'hero-test',
        variant: 'test',
        goal: 'clicked_cta',
        value: 1,
        timestamp: expect.any(String),
        button: 'signup',
      });
    });

    it('should call exposure callback', async () => {
      const onExposure = jest.fn();
      mockPostHog.getFeatureFlag.mockReturnValue('variant-a');
      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        callback();
      });

      renderHook(() => useExperiment('test-exp', { onExposure }));

      await waitFor(() => {
        expect(onExposure).toHaveBeenCalledWith('variant-a');
      });
    });
  });

  describe('useUIGenerationTracking', () => {
    it('should track UI generation', () => {
      const { result } = renderHook(() => useUIGenerationTracking());

      act(() => {
        result.current.trackUIGenerated('hero-banner', 'awareness', {
          template: 'template-1',
        });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('ui_generated', {
        component_type: 'hero-banner',
        pcm_stage: 'awareness',
        timestamp: expect.any(String),
        template: 'template-1',
      });
    });

    it('should track UI interaction', () => {
      const { result } = renderHook(() => useUIGenerationTracking());

      act(() => {
        result.current.trackUIInteraction('comp-123', 'click', { element: 'button' });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('ui_interaction', {
        component_id: 'comp-123',
        interaction_type: 'click',
        timestamp: expect.any(String),
        element: 'button',
      });
    });

    it('should track rule execution', () => {
      const { result } = renderHook(() => useUIGenerationTracking());

      act(() => {
        result.current.trackRuleExecution('rule-456', 'applied', {
          confidence: 0.95,
        });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('rule_execution', {
        rule_id: 'rule-456',
        result: 'applied',
        timestamp: expect.any(String),
        confidence: 0.95,
      });
    });
  });

  describe('usePCMFeatureFlag', () => {
    it('should check stage-specific feature flag', async () => {
      mockPostHog.getFeatureFlag.mockReturnValue(true);
      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        callback();
      });

      const { result } = renderHook(() =>
        usePCMFeatureFlag('new-feature', 'attraction')
      );

      expect(result.current.isLoading).toBe(true);

      await waitFor(() => {
        expect(result.current.isEnabled).toBe(true);
        expect(result.current.isLoading).toBe(false);
      });

      expect(mockPostHog.getFeatureFlag).toHaveBeenCalledWith('new-feature_attraction');
    });

    it('should fall back to general flag', async () => {
      mockPostHog.getFeatureFlag
        .mockReturnValueOnce(undefined) // Stage-specific flag
        .mockReturnValueOnce(true); // General flag

      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        callback();
      });

      const { result } = renderHook(() =>
        usePCMFeatureFlag('new-feature', 'awareness')
      );

      await waitFor(() => {
        expect(result.current.isEnabled).toBe(true);
      });

      expect(mockPostHog.getFeatureFlag).toHaveBeenCalledWith('new-feature_awareness');
      expect(mockPostHog.getFeatureFlag).toHaveBeenCalledWith('new-feature');
    });
  });

  describe('useAnalytics', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it('should track events immediately for high priority', () => {
      const { result } = renderHook(() => useAnalytics());

      act(() => {
        result.current.track('conversion_completed', { value: 100 });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('conversion_completed', {
        value: 100,
      });
    });

    it('should batch low priority events', () => {
      const { result } = renderHook(() => useAnalytics());

      act(() => {
        result.current.track('page_view', { page: 'home' });
        result.current.track('button_hover', { button: 'cta' });
      });

      // Events should not be sent immediately
      expect(mockPostHog.capture).not.toHaveBeenCalled();

      // Fast forward time to trigger batch
      act(() => {
        jest.advanceTimersByTime(1000);
      });

      // Events should now be sent
      expect(mockPostHog.capture).toHaveBeenCalledTimes(2);
      expect(mockPostHog.capture).toHaveBeenCalledWith('page_view', { page: 'home' });
      expect(mockPostHog.capture).toHaveBeenCalledWith('button_hover', { button: 'cta' });
    });

    it('should identify user', () => {
      const { result } = renderHook(() => useAnalytics());

      act(() => {
        result.current.identify('user123', { name: 'John Doe' });
      });

      expect(mockPostHog.identify).toHaveBeenCalledWith('user123', { name: 'John Doe' });
    });

    it('should reset user', () => {
      const { result } = renderHook(() => useAnalytics());

      act(() => {
        result.current.reset();
      });

      expect(mockPostHog.reset).toHaveBeenCalled();
    });

    it('should log in development mode', () => {
      const originalEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'development';
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();

      const { result } = renderHook(() => useAnalytics());

      act(() => {
        result.current.track('test_event', { test: true });
      });

      expect(consoleSpy).toHaveBeenCalledWith(
        'Analytics Event:',
        'test_event',
        { test: true }
      );

      consoleSpy.mockRestore();
      process.env.NODE_ENV = originalEnv;
    });
  });

  describe('useSessionRecording', () => {
    it('should start recording', () => {
      const { result } = renderHook(() => useSessionRecording());

      act(() => {
        result.current.startRecording();
      });

      expect(mockPostHog.startSessionRecording).toHaveBeenCalled();
      expect(result.current.isRecording).toBe(true);
    });

    it('should stop recording', () => {
      const { result } = renderHook(() => useSessionRecording());

      act(() => {
        result.current.stopRecording();
      });

      expect(mockPostHog.stopSessionRecording).toHaveBeenCalled();
      expect(result.current.isRecording).toBe(false);
    });

    it('should tag recording', () => {
      const { result } = renderHook(() => useSessionRecording());

      act(() => {
        result.current.tagRecording({ session_type: 'onboarding' });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('$session_recording_tag', {
        session_type: 'onboarding',
      });
    });
  });

  describe('useMultivariateTest', () => {
    it('should select variant from feature flag', async () => {
      mockPostHog.getFeatureFlag.mockReturnValue('guided');
      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        callback();
      });

      const { result } = renderHook(() =>
        useMultivariateTest('onboarding-flow', ['minimal', 'guided', 'gamified'])
      );

      await waitFor(() => {
        expect(result.current.variant).toBe('guided');
        expect(result.current.isLoading).toBe(false);
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('$experiment_started', {
        experiment: 'onboarding-flow',
        variant: 'guided',
        available_variants: ['minimal', 'guided', 'gamified'],
        timestamp: expect.any(String),
      });
    });

    it('should default to first variant if flag not found', async () => {
      mockPostHog.getFeatureFlag.mockReturnValue(undefined);
      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        callback();
      });

      const { result } = renderHook(() =>
        useMultivariateTest('test', ['a', 'b', 'c'])
      );

      await waitFor(() => {
        expect(result.current.variant).toBe('a');
      });
    });

    it('should track interaction', async () => {
      mockPostHog.getFeatureFlag.mockReturnValue('b');
      mockPostHog.onFeatureFlags.mockImplementation((callback) => {
        callback();
      });

      const { result } = renderHook(() =>
        useMultivariateTest('test', ['a', 'b', 'c'])
      );

      await waitFor(() => {
        expect(result.current.variant).toBe('b');
      });

      act(() => {
        result.current.trackInteraction('clicked_next', { step: 1 });
      });

      expect(mockPostHog.capture).toHaveBeenCalledWith('multivariate_interaction', {
        test: 'test',
        variant: 'b',
        action: 'clicked_next',
        timestamp: expect.any(String),
        step: 1,
      });
    });
  });
});