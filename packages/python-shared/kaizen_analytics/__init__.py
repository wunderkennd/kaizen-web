"""
Kaizen Analytics - PostHog integration for Python services
"""

from .client import Analytics, PCMStage, PostHogConfig
from .decorators import track_execution_time, track_event

__all__ = [
    "Analytics",
    "PCMStage",
    "PostHogConfig",
    "track_execution_time",
    "track_event",
]

__version__ = "0.1.0"