"""
PostHog analytics integration for PCM Classifier service
"""

from typing import Any, Dict, List, Optional
from kaizen_analytics import Analytics, PCMStage, PostHogConfig


class PCMClassifierAnalytics:
    """Analytics handler for PCM Classifier service"""
    
    def __init__(self):
        """Initialize analytics with service-specific config"""
        config = PostHogConfig.from_env()
        config.service = "pcm-classifier"
        self.client = Analytics(config)
    
    def track_classification(
        self,
        user_id: str,
        predicted_stage: PCMStage,
        confidence_score: float,
        features_used: List[str],
        model_version: str,
        inference_time_ms: float,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track PCM stage classification"""
        props = {
            "predicted_stage": predicted_stage.value,
            "confidence_score": confidence_score,
            "features_used": features_used,
            "feature_count": len(features_used),
            "model_version": model_version,
            "inference_time_ms": inference_time_ms,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "pcm_classification", props)
    
    def track_stage_transition_prediction(
        self,
        user_id: str,
        current_stage: PCMStage,
        predicted_next_stage: PCMStage,
        transition_probability: float,
        time_to_transition_days: Optional[float] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track PCM stage transition predictions"""
        props = {
            "current_stage": current_stage.value,
            "predicted_next_stage": predicted_next_stage.value,
            "transition_probability": transition_probability,
            **(metadata or {})
        }
        
        if time_to_transition_days:
            props["time_to_transition_days"] = time_to_transition_days
        
        self.client.track_event(user_id, "pcm_transition_prediction", props)
    
    def track_feature_extraction(
        self,
        user_id: str,
        feature_categories: Dict[str, int],
        total_features: int,
        extraction_time_ms: float,
        data_sources: List[str]
    ) -> None:
        """Track feature extraction for PCM classification"""
        props = {
            "feature_categories": feature_categories,
            "total_features": total_features,
            "extraction_time_ms": extraction_time_ms,
            "data_sources": data_sources,
            "source_count": len(data_sources),
        }
        
        self.client.track_event(user_id, "pcm_feature_extraction", props)
    
    def track_model_training(
        self,
        model_type: str,
        dataset_size: int,
        features_used: int,
        training_time_seconds: float,
        accuracy: float,
        f1_score: float,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track PCM model training"""
        props = {
            "model_type": model_type,
            "dataset_size": dataset_size,
            "features_used": features_used,
            "training_time_seconds": training_time_seconds,
            "accuracy": accuracy,
            "f1_score": f1_score,
            **(metadata or {})
        }
        
        self.client.track_service_metric("pcm_model_training", accuracy, props)
    
    def track_batch_classification(
        self,
        batch_id: str,
        user_count: int,
        processing_time_ms: float,
        stage_distribution: Dict[str, int],
        avg_confidence: float
    ) -> None:
        """Track batch PCM classification"""
        props = {
            "batch_id": batch_id,
            "user_count": user_count,
            "processing_time_ms": processing_time_ms,
            "stage_distribution": stage_distribution,
            "avg_confidence": avg_confidence,
            "throughput": user_count / (processing_time_ms / 1000),  # users/second
        }
        
        self.client.track_service_metric("pcm_batch_classification", user_count, props)
    
    def track_classification_accuracy(
        self,
        actual_stage: PCMStage,
        predicted_stage: PCMStage,
        user_id: str,
        model_version: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track classification accuracy for model evaluation"""
        props = {
            "actual_stage": actual_stage.value,
            "predicted_stage": predicted_stage.value,
            "correct": actual_stage == predicted_stage,
            "model_version": model_version,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "pcm_classification_evaluation", props)
    
    def track_stage_progression_analysis(
        self,
        user_id: str,
        stage_history: List[Dict[str, Any]],
        current_stage: PCMStage,
        engagement_score: float,
        days_in_current_stage: int
    ) -> None:
        """Track stage progression analysis"""
        props = {
            "stage_history_length": len(stage_history),
            "current_stage": current_stage.value,
            "engagement_score": engagement_score,
            "days_in_current_stage": days_in_current_stage,
            "stage_changes": len(stage_history) - 1 if stage_history else 0,
        }
        
        self.client.track_event(user_id, "pcm_progression_analysis", props)
    
    def track_model_comparison(
        self,
        comparison_id: str,
        models: List[str],
        winner: str,
        metrics: Dict[str, Dict[str, float]],
        test_size: int
    ) -> None:
        """Track model comparison results"""
        props = {
            "comparison_id": comparison_id,
            "models": models,
            "model_count": len(models),
            "winner": winner,
            "metrics": metrics,
            "test_size": test_size,
        }
        
        self.client.track_service_metric("pcm_model_comparison", 1.0, props)
    
    def track_feature_importance(
        self,
        model_version: str,
        feature_importance: Dict[str, float],
        top_features: List[str],
        computation_time_ms: float
    ) -> None:
        """Track feature importance analysis"""
        props = {
            "model_version": model_version,
            "feature_importance": feature_importance,
            "top_features": top_features[:10],  # Top 10 features
            "total_features": len(feature_importance),
            "computation_time_ms": computation_time_ms,
        }
        
        self.client.track_service_metric("feature_importance", 1.0, props)
    
    def track_drift_detection(
        self,
        drift_detected: bool,
        drift_score: float,
        affected_features: List[str],
        model_version: str,
        action_taken: str
    ) -> None:
        """Track model drift detection"""
        props = {
            "drift_detected": drift_detected,
            "drift_score": drift_score,
            "affected_features": affected_features,
            "affected_feature_count": len(affected_features),
            "model_version": model_version,
            "action_taken": action_taken,
        }
        
        self.client.track_service_metric("drift_detection", drift_score, props)
    
    def track_health_check(
        self,
        healthy: bool,
        model_loaded: bool,
        avg_inference_time_ms: float,
        classification_accuracy: float,
        error_rate: float
    ) -> None:
        """Track service health metrics"""
        props = {
            "healthy": healthy,
            "model_loaded": model_loaded,
            "avg_inference_time_ms": avg_inference_time_ms,
            "classification_accuracy": classification_accuracy,
            "error_rate": error_rate,
        }
        
        self.client.track_service_metric("health_check", 1.0, props)
    
    def shutdown(self) -> None:
        """Shutdown analytics client"""
        self.client.shutdown()


# Global analytics instance
analytics = PCMClassifierAnalytics()