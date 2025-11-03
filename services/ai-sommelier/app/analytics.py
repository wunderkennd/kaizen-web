"""
PostHog analytics integration for AI Sommelier service
"""

from typing import Any, Dict, List, Optional
from kaizen_analytics import Analytics, PCMStage, PostHogConfig


class AISommelierAnalytics:
    """Analytics handler for AI Sommelier service"""
    
    def __init__(self):
        """Initialize analytics with service-specific config"""
        config = PostHogConfig.from_env()
        config.service = "ai-sommelier"
        self.client = Analytics(config)
    
    def track_recommendation_generated(
        self,
        user_id: str,
        recommendation_type: str,
        items: List[str],
        pcm_stage: PCMStage,
        model_name: str,
        confidence_score: float,
        generation_time_ms: float,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track when recommendations are generated"""
        props = {
            "recommendation_type": recommendation_type,
            "recommendation_count": len(items),
            "items": items[:10],  # Track first 10 items
            "pcm_stage": pcm_stage.value,
            "model_name": model_name,
            "confidence_score": confidence_score,
            "generation_time_ms": generation_time_ms,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "recommendation_generated", props)
    
    def track_recommendation_interaction(
        self,
        user_id: str,
        recommendation_id: str,
        interaction_type: str,  # clicked, viewed, dismissed, saved
        item_position: int,
        time_to_interact_ms: float,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track user interactions with recommendations"""
        props = {
            "recommendation_id": recommendation_id,
            "interaction_type": interaction_type,
            "item_position": item_position,
            "time_to_interact_ms": time_to_interact_ms,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "recommendation_interaction", props)
    
    def track_model_inference(
        self,
        model_name: str,
        model_version: str,
        input_size: int,
        inference_time_ms: float,
        success: bool,
        error: Optional[str] = None
    ) -> None:
        """Track ML model inference metrics"""
        props = {
            "model_name": model_name,
            "model_version": model_version,
            "input_size": input_size,
            "inference_time_ms": inference_time_ms,
            "success": success,
        }
        
        if error:
            props["error"] = error
        
        self.client.track_service_metric("model_inference", inference_time_ms, props)
    
    def track_vector_search(
        self,
        user_id: str,
        query_type: str,
        vector_dimensions: int,
        results_count: int,
        search_time_ms: float,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track vector database search operations"""
        props = {
            "query_type": query_type,
            "vector_dimensions": vector_dimensions,
            "results_count": results_count,
            "search_time_ms": search_time_ms,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "vector_search", props)
    
    def track_embedding_generation(
        self,
        content_type: str,
        content_count: int,
        embedding_model: str,
        generation_time_ms: float,
        batch_size: int
    ) -> None:
        """Track embedding generation for content"""
        props = {
            "content_type": content_type,
            "content_count": content_count,
            "embedding_model": embedding_model,
            "generation_time_ms": generation_time_ms,
            "batch_size": batch_size,
            "throughput": content_count / (generation_time_ms / 1000),  # items/second
        }
        
        self.client.track_service_metric("embedding_generation", generation_time_ms, props)
    
    def track_collaborative_filtering(
        self,
        user_id: str,
        algorithm: str,
        neighbor_count: int,
        computation_time_ms: float,
        recommendations_generated: int
    ) -> None:
        """Track collaborative filtering operations"""
        props = {
            "algorithm": algorithm,
            "neighbor_count": neighbor_count,
            "computation_time_ms": computation_time_ms,
            "recommendations_generated": recommendations_generated,
        }
        
        self.client.track_event(user_id, "collaborative_filtering", props)
    
    def track_content_analysis(
        self,
        content_id: str,
        content_type: str,
        features_extracted: List[str],
        analysis_time_ms: float,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track content analysis for recommendations"""
        props = {
            "content_id": content_id,
            "content_type": content_type,
            "features_extracted": features_extracted,
            "feature_count": len(features_extracted),
            "analysis_time_ms": analysis_time_ms,
            **(metadata or {})
        }
        
        self.client.track_service_metric("content_analysis", analysis_time_ms, props)
    
    def track_personalization_update(
        self,
        user_id: str,
        pcm_stage: PCMStage,
        preference_type: str,
        update_source: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track personalization preference updates"""
        props = {
            "pcm_stage": pcm_stage.value,
            "preference_type": preference_type,
            "update_source": update_source,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "personalization_updated", props)
    
    def track_recommendation_feedback(
        self,
        user_id: str,
        recommendation_id: str,
        feedback_type: str,  # positive, negative, explicit_rating
        feedback_value: Optional[float] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track explicit user feedback on recommendations"""
        props = {
            "recommendation_id": recommendation_id,
            "feedback_type": feedback_type,
            **(metadata or {})
        }
        
        if feedback_value is not None:
            props["feedback_value"] = feedback_value
        
        self.client.track_event(user_id, "recommendation_feedback", props)
    
    def track_cache_performance(
        self,
        cache_type: str,
        hit: bool,
        key: str,
        retrieval_time_ms: float
    ) -> None:
        """Track recommendation cache performance"""
        props = {
            "cache_type": cache_type,
            "cache_hit": hit,
            "cache_key": key,
            "retrieval_time_ms": retrieval_time_ms,
        }
        
        self.client.track_service_metric("cache_access", retrieval_time_ms, props)
    
    def track_health_check(
        self,
        healthy: bool,
        model_status: Dict[str, bool],
        vector_db_connected: bool,
        avg_inference_time_ms: float,
        error_rate: float
    ) -> None:
        """Track service health metrics"""
        props = {
            "healthy": healthy,
            "model_status": model_status,
            "vector_db_connected": vector_db_connected,
            "avg_inference_time_ms": avg_inference_time_ms,
            "error_rate": error_rate,
        }
        
        self.client.track_service_metric("health_check", 1.0, props)
    
    def shutdown(self) -> None:
        """Shutdown analytics client"""
        self.client.shutdown()


# Global analytics instance
analytics = AISommelierAnalytics()