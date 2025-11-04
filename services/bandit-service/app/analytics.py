"""
PostHog analytics integration for Bandit Service (Multi-Armed Bandits)
"""

from typing import Any, Dict, List, Optional
from kaizen_analytics import Analytics, PCMStage, PostHogConfig


class BanditAnalytics:
    """Analytics handler for Multi-Armed Bandit service"""
    
    def __init__(self):
        """Initialize analytics with service-specific config"""
        config = PostHogConfig.from_env()
        config.service = "bandit-service"
        self.client = Analytics(config)
    
    def track_arm_selection(
        self,
        user_id: str,
        bandit_id: str,
        algorithm: str,  # epsilon_greedy, ucb, thompson_sampling
        selected_arm: str,
        exploration_rate: float,
        confidence_bounds: Optional[Dict[str, float]] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track when a bandit arm is selected"""
        props = {
            "bandit_id": bandit_id,
            "algorithm": algorithm,
            "selected_arm": selected_arm,
            "exploration_rate": exploration_rate,
            **(metadata or {})
        }
        
        if confidence_bounds:
            props["confidence_bounds"] = confidence_bounds
        
        self.client.track_event(user_id, "bandit_arm_selected", props)
    
    def track_reward_update(
        self,
        user_id: str,
        bandit_id: str,
        arm: str,
        reward: float,
        cumulative_reward: float,
        trial_number: int,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track reward updates for bandit arms"""
        props = {
            "bandit_id": bandit_id,
            "arm": arm,
            "reward": reward,
            "cumulative_reward": cumulative_reward,
            "trial_number": trial_number,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "bandit_reward_updated", props)
    
    def track_bandit_convergence(
        self,
        bandit_id: str,
        algorithm: str,
        trials_to_converge: int,
        best_arm: str,
        final_regret: float,
        arm_statistics: Dict[str, Dict[str, float]]
    ) -> None:
        """Track when a bandit converges to optimal arm"""
        props = {
            "bandit_id": bandit_id,
            "algorithm": algorithm,
            "trials_to_converge": trials_to_converge,
            "best_arm": best_arm,
            "final_regret": final_regret,
            "arm_statistics": arm_statistics,
        }
        
        self.client.track_service_metric("bandit_convergence", trials_to_converge, props)
    
    def track_thompson_sampling(
        self,
        user_id: str,
        bandit_id: str,
        arm_priors: Dict[str, Dict[str, float]],  # alpha, beta for each arm
        sampled_values: Dict[str, float],
        selected_arm: str
    ) -> None:
        """Track Thompson Sampling specific metrics"""
        props = {
            "bandit_id": bandit_id,
            "arm_priors": arm_priors,
            "sampled_values": sampled_values,
            "selected_arm": selected_arm,
        }
        
        self.client.track_event(user_id, "thompson_sampling", props)
    
    def track_ucb_selection(
        self,
        user_id: str,
        bandit_id: str,
        arm_means: Dict[str, float],
        arm_ucb_values: Dict[str, float],
        exploration_parameter: float,
        selected_arm: str
    ) -> None:
        """Track Upper Confidence Bound selection"""
        props = {
            "bandit_id": bandit_id,
            "arm_means": arm_means,
            "arm_ucb_values": arm_ucb_values,
            "exploration_parameter": exploration_parameter,
            "selected_arm": selected_arm,
        }
        
        self.client.track_event(user_id, "ucb_selection", props)
    
    def track_contextual_bandit(
        self,
        user_id: str,
        bandit_id: str,
        context_features: Dict[str, Any],
        pcm_stage: PCMStage,
        selected_arm: str,
        expected_rewards: Dict[str, float]
    ) -> None:
        """Track contextual bandit decisions"""
        props = {
            "bandit_id": bandit_id,
            "context_features": context_features,
            "pcm_stage": pcm_stage.value,
            "selected_arm": selected_arm,
            "expected_rewards": expected_rewards,
        }
        
        self.client.track_event(user_id, "contextual_bandit_selection", props)
    
    def track_regret_metrics(
        self,
        bandit_id: str,
        algorithm: str,
        trial_number: int,
        instantaneous_regret: float,
        cumulative_regret: float,
        optimal_arm: str,
        selected_arm: str
    ) -> None:
        """Track regret metrics for bandit algorithms"""
        props = {
            "bandit_id": bandit_id,
            "algorithm": algorithm,
            "trial_number": trial_number,
            "instantaneous_regret": instantaneous_regret,
            "cumulative_regret": cumulative_regret,
            "optimal_arm": optimal_arm,
            "selected_arm": selected_arm,
        }
        
        self.client.track_service_metric("bandit_regret", cumulative_regret, props)
    
    def track_batch_update(
        self,
        bandit_id: str,
        batch_size: int,
        processing_time_ms: float,
        arms_updated: List[str],
        new_best_arm: Optional[str] = None
    ) -> None:
        """Track batch updates to bandit models"""
        props = {
            "bandit_id": bandit_id,
            "batch_size": batch_size,
            "processing_time_ms": processing_time_ms,
            "arms_updated": arms_updated,
            "arms_updated_count": len(arms_updated),
        }
        
        if new_best_arm:
            props["new_best_arm"] = new_best_arm
        
        self.client.track_service_metric("bandit_batch_update", batch_size, props)
    
    def track_exploration_exploitation(
        self,
        user_id: str,
        bandit_id: str,
        decision_type: str,  # "explore" or "exploit"
        exploration_probability: float,
        metadata: Optional[Dict[str, Any]] = None
    ) -> None:
        """Track exploration vs exploitation decisions"""
        props = {
            "bandit_id": bandit_id,
            "decision_type": decision_type,
            "exploration_probability": exploration_probability,
            **(metadata or {})
        }
        
        self.client.track_event(user_id, "exploration_exploitation", props)
    
    def track_arm_elimination(
        self,
        bandit_id: str,
        eliminated_arm: str,
        reason: str,
        trials_before_elimination: int,
        final_statistics: Dict[str, float]
    ) -> None:
        """Track when an arm is eliminated from consideration"""
        props = {
            "bandit_id": bandit_id,
            "eliminated_arm": eliminated_arm,
            "elimination_reason": reason,
            "trials_before_elimination": trials_before_elimination,
            "final_statistics": final_statistics,
        }
        
        self.client.track_service_metric("arm_elimination", 1.0, props)
    
    def track_bandit_reset(
        self,
        bandit_id: str,
        reason: str,
        previous_best_arm: str,
        total_trials: int,
        total_reward: float
    ) -> None:
        """Track when a bandit is reset"""
        props = {
            "bandit_id": bandit_id,
            "reset_reason": reason,
            "previous_best_arm": previous_best_arm,
            "total_trials": total_trials,
            "total_reward": total_reward,
        }
        
        self.client.track_service_metric("bandit_reset", 1.0, props)
    
    def track_performance_metrics(
        self,
        active_bandits: int,
        total_trials_today: int,
        avg_regret: float,
        avg_convergence_time: float,
        algorithm_distribution: Dict[str, int]
    ) -> None:
        """Track overall service performance metrics"""
        props = {
            "active_bandits": active_bandits,
            "total_trials_today": total_trials_today,
            "avg_regret": avg_regret,
            "avg_convergence_time": avg_convergence_time,
            "algorithm_distribution": algorithm_distribution,
        }
        
        self.client.track_service_metric("performance_metrics", active_bandits, props)
    
    def track_health_check(
        self,
        healthy: bool,
        active_bandits: int,
        avg_selection_time_ms: float,
        memory_usage_mb: float,
        error_rate: float
    ) -> None:
        """Track service health metrics"""
        props = {
            "healthy": healthy,
            "active_bandits": active_bandits,
            "avg_selection_time_ms": avg_selection_time_ms,
            "memory_usage_mb": memory_usage_mb,
            "error_rate": error_rate,
        }
        
        self.client.track_service_metric("health_check", 1.0, props)
    
    def shutdown(self) -> None:
        """Shutdown analytics client"""
        self.client.shutdown()


# Global analytics instance
analytics = BanditAnalytics()