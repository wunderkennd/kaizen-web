"""
Decorators for automatic analytics tracking
"""

import time
import functools
import logging
from typing import Any, Callable, Optional

from .client import Analytics

logger = logging.getLogger(__name__)


def track_execution_time(
    analytics: Analytics,
    event_name: Optional[str] = None,
    user_id_param: Optional[str] = None,
    include_args: bool = False
):
    """
    Decorator to automatically track function execution time
    
    Args:
        analytics: Analytics client instance
        event_name: Custom event name (defaults to function name)
        user_id_param: Parameter name containing user_id (defaults to 'user_id')
        include_args: Whether to include function arguments in tracking
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs) -> Any:
            start_time = time.time()
            error_occurred = False
            error_type = None
            
            try:
                result = func(*args, **kwargs)
                return result
            except Exception as e:
                error_occurred = True
                error_type = type(e).__name__
                raise
            finally:
                execution_time = (time.time() - start_time) * 1000  # Convert to ms
                
                # Extract user_id from kwargs or args
                user_id = None
                if user_id_param:
                    user_id = kwargs.get(user_id_param)
                    if not user_id and args:
                        # Try to get from positional args if function signature matches
                        try:
                            param_names = func.__code__.co_varnames[:func.__code__.co_argcount]
                            if user_id_param in param_names:
                                idx = param_names.index(user_id_param)
                                if idx < len(args):
                                    user_id = args[idx]
                        except:
                            pass
                
                if not user_id:
                    user_id = kwargs.get("user_id", "system")
                
                # Prepare properties
                props = {
                    "function_name": func.__name__,
                    "module": func.__module__,
                    "execution_time_ms": execution_time,
                    "error_occurred": error_occurred,
                }
                
                if error_occurred:
                    props["error_type"] = error_type
                
                if include_args:
                    props["args"] = str(args)[:500]  # Limit arg string length
                    props["kwargs"] = str(kwargs)[:500]
                
                # Track the event
                track_name = event_name or f"function_executed_{func.__name__}"
                analytics.track_event(user_id, track_name, props)
        
        return wrapper
    return decorator


def track_event(
    analytics: Analytics,
    event_name: str,
    user_id_param: str = "user_id"
):
    """
    Decorator to automatically track when a function is called
    
    Args:
        analytics: Analytics client instance
        event_name: Event name to track
        user_id_param: Parameter name containing user_id
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs) -> Any:
            # Extract user_id
            user_id = kwargs.get(user_id_param)
            if not user_id and args:
                try:
                    param_names = func.__code__.co_varnames[:func.__code__.co_argcount]
                    if user_id_param in param_names:
                        idx = param_names.index(user_id_param)
                        if idx < len(args):
                            user_id = args[idx]
                except:
                    pass
            
            if not user_id:
                user_id = "system"
            
            # Track event before execution
            analytics.track_event(user_id, event_name, {
                "function": func.__name__,
                "module": func.__module__,
            })
            
            return func(*args, **kwargs)
        
        return wrapper
    return decorator