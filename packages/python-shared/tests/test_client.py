"""
Tests for PostHog analytics client
"""

import os
import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime

from kaizen_analytics import Analytics, PCMStage, PostHogConfig
from kaizen_analytics.client import logger


class TestPostHogConfig:
    """Test PostHog configuration"""
    
    def test_config_from_env(self):
        """Test configuration from environment variables"""
        with patch.dict(os.environ, {
            'POSTHOG_PROJECT_API_KEY': 'test-key',
            'POSTHOG_HOST': 'http://test-host',
            'SERVICE_NAME': 'test-service',
            'POSTHOG_ENABLED': 'true',
            'POSTHOG_BATCH_SIZE': '50',
            'POSTHOG_FLUSH_INTERVAL': '5000',
            'POSTHOG_DEBUG': 'true'
        }):
            config = PostHogConfig.from_env()
            
            assert config.api_key == 'test-key'
            assert config.host == 'http://test-host'
            assert config.service == 'test-service'
            assert config.enabled == True
            assert config.batch_size == 50
            assert config.flush_interval == 5000
            assert config.debug == True
    
    def test_config_defaults(self):
        """Test default configuration values"""
        with patch.dict(os.environ, {}, clear=True):
            config = PostHogConfig.from_env()
            
            assert config.api_key == ""
            assert config.host == "https://app.posthog.com"
            assert config.service == "python-service"
            assert config.enabled == True
            assert config.batch_size == 100
            assert config.flush_interval == 10000
            assert config.debug == False


class TestAnalytics:
    """Test Analytics client"""
    
    @pytest.fixture
    def mock_posthog(self):
        """Mock PostHog client"""
        with patch('kaizen_analytics.client.Posthog') as mock:
            yield mock
    
    @pytest.fixture
    def analytics(self, mock_posthog):
        """Create Analytics instance with mocked PostHog"""
        config = PostHogConfig(
            api_key="test-key",
            host="http://localhost",
            service="test-service",
            enabled=True
        )
        analytics = Analytics(config)
        analytics.client = mock_posthog.return_value
        return analytics
    
    def test_init_with_api_key(self, mock_posthog):
        """Test initialization with API key"""
        config = PostHogConfig(api_key="test-key", enabled=True)
        analytics = Analytics(config)
        
        assert analytics.enabled == True
        assert analytics.service == "python-service"
        mock_posthog.assert_called_once()
    
    def test_init_without_api_key(self, mock_posthog):
        """Test initialization without API key"""
        config = PostHogConfig(api_key="", enabled=True)
        
        with patch.object(logger, 'warning') as mock_log:
            analytics = Analytics(config)
            
            assert analytics.enabled == False
            mock_log.assert_called_with("PostHog enabled but API key not provided")
            mock_posthog.assert_not_called()
    
    def test_init_disabled(self, mock_posthog):
        """Test initialization when disabled"""
        config = PostHogConfig(enabled=False)
        analytics = Analytics(config)
        
        assert analytics.enabled == False
        mock_posthog.assert_not_called()
    
    def test_track_pcm_transition(self, analytics):
        """Test PCM stage transition tracking"""
        analytics.track_pcm_transition(
            user_id="user123",
            from_stage=PCMStage.AWARENESS,
            to_stage=PCMStage.ATTRACTION,
            trigger="viewed_content",
            properties={"content_id": "123"}
        )
        
        analytics.client.capture.assert_called_once()
        call_args = analytics.client.capture.call_args
        
        assert call_args[1]['distinct_id'] == "user123"
        assert call_args[1]['event'] == "pcm_stage_transition"
        assert call_args[1]['properties']['from_stage'] == "awareness"
        assert call_args[1]['properties']['to_stage'] == "attraction"
        assert call_args[1]['properties']['trigger'] == "viewed_content"
        assert call_args[1]['properties']['content_id'] == "123"
    
    def test_track_event(self, analytics):
        """Test generic event tracking"""
        analytics.track_event(
            user_id="user123",
            event_name="test_event",
            properties={"key": "value"}
        )
        
        analytics.client.capture.assert_called_once()
        call_args = analytics.client.capture.call_args
        
        assert call_args[1]['distinct_id'] == "user123"
        assert call_args[1]['event'] == "test_event"
        assert call_args[1]['properties']['key'] == "value"
        assert call_args[1]['properties']['service'] == "test-service"
    
    def test_track_service_metric(self, analytics):
        """Test service metric tracking"""
        analytics.track_service_metric(
            metric_name="latency",
            value=150.5,
            properties={"endpoint": "/api/test"}
        )
        
        analytics.client.capture.assert_called_once()
        call_args = analytics.client.capture.call_args
        
        assert call_args[1]['distinct_id'] == "system:test-service"
        assert call_args[1]['event'] == "test-service_metric"
        assert call_args[1]['properties']['metric_name'] == "latency"
        assert call_args[1]['properties']['metric_value'] == 150.5
        assert call_args[1]['properties']['endpoint'] == "/api/test"
    
    def test_track_experiment(self, analytics):
        """Test experiment tracking"""
        analytics.track_experiment(
            user_id="user123",
            experiment_key="hero-test",
            variant="variant-b",
            properties={"page": "home"}
        )
        
        analytics.client.capture.assert_called_once()
        call_args = analytics.client.capture.call_args
        
        assert call_args[1]['distinct_id'] == "user123"
        assert call_args[1]['event'] == "$experiment_started"
        assert call_args[1]['properties']['experiment'] == "hero-test"
        assert call_args[1]['properties']['variant'] == "variant-b"
        assert call_args[1]['properties']['page'] == "home"
    
    def test_track_conversion(self, analytics):
        """Test conversion tracking"""
        analytics.track_conversion(
            user_id="user123",
            experiment_key="hero-test",
            goal="clicked_cta",
            value=1.0,
            properties={"button": "signup"}
        )
        
        analytics.client.capture.assert_called_once()
        call_args = analytics.client.capture.call_args
        
        assert call_args[1]['distinct_id'] == "user123"
        assert call_args[1]['event'] == "experiment_conversion"
        assert call_args[1]['properties']['experiment'] == "hero-test"
        assert call_args[1]['properties']['goal'] == "clicked_cta"
        assert call_args[1]['properties']['value'] == 1.0
    
    def test_identify_user(self, analytics):
        """Test user identification"""
        analytics.identify_user(
            user_id="user123",
            properties={"name": "John", "pcm_stage": "awareness"}
        )
        
        analytics.client.identify.assert_called_once_with(
            distinct_id="user123",
            properties={"name": "John", "pcm_stage": "awareness"}
        )
    
    def test_feature_flag_enabled(self, analytics):
        """Test feature flag check"""
        analytics.client.feature_enabled.return_value = True
        
        result = analytics.feature_flag_enabled(
            user_id="user123",
            flag_key="new-feature",
            default=False
        )
        
        assert result == True
        analytics.client.feature_enabled.assert_called_once_with(
            key="new-feature",
            distinct_id="user123",
            default=False
        )
    
    def test_disabled_tracking(self, analytics):
        """Test that tracking is skipped when disabled"""
        analytics.enabled = False
        
        analytics.track_event("user123", "test_event", {})
        analytics.track_pcm_transition(
            "user123", 
            PCMStage.AWARENESS, 
            PCMStage.ATTRACTION,
            "trigger", 
            {}
        )
        
        analytics.client.capture.assert_not_called()
    
    def test_error_handling(self, analytics):
        """Test error handling in tracking methods"""
        analytics.client.capture.side_effect = Exception("Network error")
        
        with patch.object(logger, 'error') as mock_log:
            # Should not raise exception
            analytics.track_event("user123", "test_event", {})
            
            mock_log.assert_called()
            assert "Error tracking event test_event" in mock_log.call_args[0][0]
    
    def test_context_manager(self, mock_posthog):
        """Test context manager functionality"""
        config = PostHogConfig(api_key="test-key", enabled=True)
        
        with Analytics(config) as analytics:
            assert analytics.client is not None
        
        # Shutdown should be called on exit
        analytics.client.shutdown.assert_called_once()
    
    def test_flush(self, analytics):
        """Test flush method"""
        analytics.flush()
        analytics.client.flush.assert_called_once()
    
    def test_shutdown(self, analytics):
        """Test shutdown method"""
        with patch.object(logger, 'info') as mock_log:
            analytics.shutdown()
            
            analytics.client.shutdown.assert_called_once()
            mock_log.assert_called_with("PostHog client shut down")


class TestPCMStage:
    """Test PCM Stage enum"""
    
    def test_pcm_stage_values(self):
        """Test PCM stage enum values"""
        assert PCMStage.AWARENESS.value == "awareness"
        assert PCMStage.ATTRACTION.value == "attraction"
        assert PCMStage.ATTACHMENT.value == "attachment"
        assert PCMStage.ALLEGIANCE.value == "allegiance"
    
    def test_pcm_stage_comparison(self):
        """Test PCM stage comparisons"""
        stage1 = PCMStage.AWARENESS
        stage2 = PCMStage.AWARENESS
        stage3 = PCMStage.ATTRACTION
        
        assert stage1 == stage2
        assert stage1 != stage3