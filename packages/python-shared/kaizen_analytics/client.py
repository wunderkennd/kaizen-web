"""
PostHog analytics client for Python services
"""

import os
import logging
from datetime import datetime
from enum import Enum
from typing import Any, Dict, Optional
from dataclasses import dataclass

from posthog import Posthog

logger = logging.getLogger(__name__)


class PCMStage(Enum):
    """Psychological Continuum Model stages"""
    AWARENESS = "awareness"
    ATTRACTION = "attraction"
    ATTACHMENT = "attachment"
    ALLEGIANCE = "allegiance"


@dataclass
class PostHogConfig:
    """Configuration for PostHog client"""
    api_key: str = ""
    host: str = "https://app.posthog.com"
    service: str = "python-service"
    enabled: bool = True
    batch_size: int = 100
    flush_interval: int = 10000  # milliseconds
    debug: bool = False
    
    @classmethod
    def from_env(cls) -> "PostHogConfig":
        """Create config from environment variables"""
        return cls(
            api_key=os.getenv("POSTHOG_PROJECT_API_KEY", ""),
            host=os.getenv("POSTHOG_HOST", "https://app.posthog.com"),
            service=os.getenv("SERVICE_NAME", "python-service"),
            enabled=os.getenv("POSTHOG_ENABLED", "true").lower() == "true",
            batch_size=int(os.getenv("POSTHOG_BATCH_SIZE", "100")),
            flush_interval=int(os.getenv("POSTHOG_FLUSH_INTERVAL", "10000")),
            debug=os.getenv("POSTHOG_DEBUG", "false").lower() == "true",
        )


class Analytics:
    """Analytics client wrapper for PostHog with PCM support"""
    
    def __init__(self, config: Optional[PostHogConfig] = None):
        """Initialize the analytics client"""
        self.config = config or PostHogConfig.from_env()
        self.service = self.config.service
        self.enabled = self.config.enabled
        self.client: Optional[Posthog] = None
        
        if self.enabled and self.config.api_key:
            try:
                self.client = Posthog(
                    project_api_key=self.config.api_key,
                    host=self.config.host,
                    debug=self.config.debug,
                )
                logger.info(f"PostHog analytics initialized for service: {self.service}")
            except Exception as e:
                logger.error(f"Failed to initialize PostHog client: {e}")
                self.enabled = False
        elif self.enabled and not self.config.api_key:
            logger.warning("PostHog enabled but API key not provided")
            self.enabled = False
    
    def track_pcm_transition(
        self,
        user_id: str,
        from_stage: PCMStage,
        to_stage: PCMStage,
        trigger: str,
        properties: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track PCM stage transitions"""
        if not self.enabled or not self.client:
            return
        
        props = {
            "from_stage": from_stage.value,
            "to_stage": to_stage.value,
            "trigger": trigger,
            "service": self.service,
            "timestamp": datetime.utcnow().isoformat(),
            **(properties or {})
        }
        
        try:
            self.client.capture(
                distinct_id=user_id,
                event="pcm_stage_transition",
                properties=props
            )
        except Exception as e:
            logger.error(f"Error tracking PCM transition: {e}")
    
    def track_event(
        self,
        user_id: str,
        event_name: str,
        properties: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track a generic event"""
        if not self.enabled or not self.client:
            return
        
        props = {
            "service": self.service,
            "timestamp": datetime.utcnow().isoformat(),
            **(properties or {})
        }
        
        try:
            self.client.capture(
                distinct_id=user_id,
                event=event_name,
                properties=props
            )
        except Exception as e:
            logger.error(f"Error tracking event {event_name}: {e}")
    
    def track_service_metric(
        self,
        metric_name: str,
        value: float,
        properties: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track service-level metrics"""
        if not self.enabled or not self.client:
            return
        
        distinct_id = f"system:{self.service}"
        props = {
            "service": self.service,
            "metric_name": metric_name,
            "metric_value": value,
            "timestamp": datetime.utcnow().isoformat(),
            **(properties or {})
        }
        
        try:
            self.client.capture(
                distinct_id=distinct_id,
                event=f"{self.service}_metric",
                properties=props
            )
        except Exception as e:
            logger.error(f"Error tracking metric {metric_name}: {e}")
    
    def track_experiment(
        self,
        user_id: str,
        experiment_key: str,
        variant: str,
        properties: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track experiment assignment"""
        if not self.enabled or not self.client:
            return
        
        props = {
            "experiment": experiment_key,
            "variant": variant,
            "service": self.service,
            "timestamp": datetime.utcnow().isoformat(),
            **(properties or {})
        }
        
        try:
            self.client.capture(
                distinct_id=user_id,
                event="$experiment_started",
                properties=props
            )
        except Exception as e:
            logger.error(f"Error tracking experiment {experiment_key}: {e}")
    
    def track_conversion(
        self,
        user_id: str,
        experiment_key: str,
        goal: str,
        value: float,
        properties: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track conversion events"""
        if not self.enabled or not self.client:
            return
        
        props = {
            "experiment": experiment_key,
            "goal": goal,
            "value": value,
            "service": self.service,
            "timestamp": datetime.utcnow().isoformat(),
            **(properties or {})
        }
        
        try:
            self.client.capture(
                distinct_id=user_id,
                event="experiment_conversion",
                properties=props
            )
        except Exception as e:
            logger.error(f"Error tracking conversion for {experiment_key}: {e}")
    
    def identify_user(
        self,
        user_id: str,
        properties: Optional[Dict[str, Any]] = None
    ) -> None:
        """Identify user with properties"""
        if not self.enabled or not self.client:
            return
        
        try:
            self.client.identify(
                distinct_id=user_id,
                properties=properties or {}
            )
        except Exception as e:
            logger.error(f"Error identifying user {user_id}: {e}")
    
    def alias(self, previous_id: str, new_id: str) -> None:
        """Create an alias for user ID transition"""
        if not self.enabled or not self.client:
            return
        
        try:
            self.client.alias(previous_id=previous_id, distinct_id=new_id)
        except Exception as e:
            logger.error(f"Error creating alias {previous_id} -> {new_id}: {e}")
    
    def feature_flag_enabled(
        self,
        user_id: str,
        flag_key: str,
        default: bool = False
    ) -> bool:
        """Check if a feature flag is enabled for a user"""
        if not self.enabled or not self.client:
            return default
        
        try:
            return self.client.feature_enabled(
                key=flag_key,
                distinct_id=user_id,
                default=default
            )
        except Exception as e:
            logger.error(f"Error checking feature flag {flag_key}: {e}")
            return default
    
    def get_feature_flag(
        self,
        user_id: str,
        flag_key: str,
        default: Any = None
    ) -> Any:
        """Get feature flag value"""
        if not self.enabled or not self.client:
            return default
        
        try:
            return self.client.get_feature_flag(
                key=flag_key,
                distinct_id=user_id,
                default=default
            )
        except Exception as e:
            logger.error(f"Error getting feature flag {flag_key}: {e}")
            return default
    
    def flush(self) -> None:
        """Flush pending events"""
        if self.client:
            try:
                self.client.flush()
            except Exception as e:
                logger.error(f"Error flushing events: {e}")
    
    def shutdown(self) -> None:
        """Shutdown the analytics client"""
        if self.client:
            try:
                self.client.shutdown()
                logger.info("PostHog client shut down")
            except Exception as e:
                logger.error(f"Error shutting down PostHog client: {e}")
    
    def __enter__(self):
        """Context manager entry"""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.shutdown()