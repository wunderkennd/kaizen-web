"""
Tests for analytics decorators
"""

import time
import pytest
from unittest.mock import Mock, MagicMock

from kaizen_analytics import Analytics
from kaizen_analytics.decorators import track_execution_time, track_event


class TestTrackExecutionTime:
    """Test execution time tracking decorator"""
    
    @pytest.fixture
    def mock_analytics(self):
        """Create mock analytics instance"""
        analytics = Mock(spec=Analytics)
        analytics.track_event = Mock()
        return analytics
    
    def test_track_execution_time_success(self, mock_analytics):
        """Test successful execution time tracking"""
        
        @track_execution_time(mock_analytics, event_name="function_executed")
        def test_function(user_id, value):
            time.sleep(0.01)  # Simulate work
            return value * 2
        
        result = test_function(user_id="user123", value=5)
        
        assert result == 10
        mock_analytics.track_event.assert_called_once()
        
        call_args = mock_analytics.track_event.call_args
        assert call_args[0][0] == "user123"  # user_id
        assert call_args[0][1] == "function_executed"  # event_name
        
        props = call_args[0][2]
        assert props["function_name"] == "test_function"
        assert props["execution_time_ms"] > 10  # Should be > 10ms
        assert props["error_occurred"] == False
    
    def test_track_execution_time_with_error(self, mock_analytics):
        """Test execution time tracking with error"""
        
        @track_execution_time(mock_analytics)
        def failing_function(user_id):
            raise ValueError("Test error")
        
        with pytest.raises(ValueError):
            failing_function(user_id="user123")
        
        mock_analytics.track_event.assert_called_once()
        
        call_args = mock_analytics.track_event.call_args
        props = call_args[0][2]
        assert props["error_occurred"] == True
        assert props["error_type"] == "ValueError"
    
    def test_track_execution_time_with_args(self, mock_analytics):
        """Test execution time tracking with arguments included"""
        
        @track_execution_time(mock_analytics, include_args=True)
        def test_function(user_id, param1, param2="default"):
            return f"{param1}-{param2}"
        
        result = test_function("user123", "value1", param2="value2")
        
        assert result == "value1-value2"
        
        call_args = mock_analytics.track_event.call_args
        props = call_args[0][2]
        assert "args" in props
        assert "kwargs" in props
    
    def test_track_execution_time_user_id_extraction(self, mock_analytics):
        """Test user_id extraction from different parameter positions"""
        
        @track_execution_time(mock_analytics, user_id_param="customer_id")
        def test_function(value, customer_id, extra=None):
            return value
        
        test_function(42, "customer123", extra="data")
        
        call_args = mock_analytics.track_event.call_args
        assert call_args[0][0] == "customer123"
    
    def test_track_execution_time_no_user_id(self, mock_analytics):
        """Test when user_id is not available"""
        
        @track_execution_time(mock_analytics)
        def test_function(value):
            return value
        
        test_function(42)
        
        call_args = mock_analytics.track_event.call_args
        assert call_args[0][0] == "system"  # Default user_id


class TestTrackEvent:
    """Test event tracking decorator"""
    
    @pytest.fixture
    def mock_analytics(self):
        """Create mock analytics instance"""
        analytics = Mock(spec=Analytics)
        analytics.track_event = Mock()
        return analytics
    
    def test_track_event_decorator(self, mock_analytics):
        """Test basic event tracking decorator"""
        
        @track_event(mock_analytics, "button_clicked")
        def click_handler(user_id, button_id):
            return f"Clicked {button_id}"
        
        result = click_handler(user_id="user123", button_id="submit")
        
        assert result == "Clicked submit"
        mock_analytics.track_event.assert_called_once()
        
        call_args = mock_analytics.track_event.call_args
        assert call_args[0][0] == "user123"
        assert call_args[0][1] == "button_clicked"
        
        props = call_args[0][2]
        assert props["function"] == "click_handler"
    
    def test_track_event_custom_user_param(self, mock_analytics):
        """Test event tracking with custom user_id parameter"""
        
        @track_event(mock_analytics, "action_performed", user_id_param="actor_id")
        def perform_action(actor_id, action_type):
            return f"Performed {action_type}"
        
        result = perform_action(actor_id="actor456", action_type="save")
        
        assert result == "Performed save"
        
        call_args = mock_analytics.track_event.call_args
        assert call_args[0][0] == "actor456"
    
    def test_track_event_positional_args(self, mock_analytics):
        """Test event tracking with positional arguments"""
        
        @track_event(mock_analytics, "function_called")
        def test_function(user_id, value1, value2):
            return value1 + value2
        
        result = test_function("user789", 10, 20)
        
        assert result == 30
        
        call_args = mock_analytics.track_event.call_args
        assert call_args[0][0] == "user789"
    
    def test_track_event_no_user_id(self, mock_analytics):
        """Test event tracking without user_id"""
        
        @track_event(mock_analytics, "system_event")
        def system_function():
            return "System action"
        
        result = system_function()
        
        assert result == "System action"
        
        call_args = mock_analytics.track_event.call_args
        assert call_args[0][0] == "system"


class TestDecoratorIntegration:
    """Test decorator integration scenarios"""
    
    def test_stacked_decorators(self):
        """Test stacking multiple decorators"""
        mock_analytics = Mock(spec=Analytics)
        mock_analytics.track_event = Mock()
        
        @track_event(mock_analytics, "function_called")
        @track_execution_time(mock_analytics, "function_timed")
        def complex_function(user_id, value):
            return value * 2
        
        result = complex_function(user_id="user999", value=7)
        
        assert result == 14
        assert mock_analytics.track_event.call_count == 2
        
        # Check both events were tracked
        calls = mock_analytics.track_event.call_args_list
        events = [call[0][1] for call in calls]
        assert "function_called" in events
        assert "function_timed" in events