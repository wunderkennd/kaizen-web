use anyhow::Result;
use kaizen_shared::analytics::{Analytics as BaseAnalytics, PCMStage, PostHogConfig};
use posthog_rs::Properties;
use std::collections::HashMap;

/// Analytics handler for KRE Engine
pub struct Analytics {
    client: BaseAnalytics,
}

impl Analytics {
    /// Create new Analytics instance
    pub fn new() -> Result<Self> {
        let mut config = PostHogConfig::default();
        config.service = "kre-engine".to_string();
        
        let client = BaseAnalytics::new(config)?;
        Ok(Self { client })
    }

    /// Track rule evaluation
    pub async fn track_rule_evaluation(
        &self,
        user_id: &str,
        rule_id: &str,
        result: &str,
        execution_time_ms: f64,
        metadata: HashMap<String, serde_json::Value>,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("rule_id".to_string(), rule_id.into());
        props.insert("result".to_string(), result.into());
        props.insert("execution_time_ms".to_string(), execution_time_ms.into());
        
        for (k, v) in metadata {
            props.insert(k, v);
        }

        self.client.track_event(user_id, "rule_evaluated", props).await
    }

    /// Track rule execution batch
    pub async fn track_rule_batch_execution(
        &self,
        batch_id: &str,
        rule_count: usize,
        total_execution_time_ms: f64,
        success_count: usize,
        failure_count: usize,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("batch_id".to_string(), batch_id.into());
        props.insert("rule_count".to_string(), rule_count.into());
        props.insert("total_execution_time_ms".to_string(), total_execution_time_ms.into());
        props.insert("success_count".to_string(), success_count.into());
        props.insert("failure_count".to_string(), failure_count.into());
        props.insert("success_rate".to_string(), (success_count as f64 / rule_count as f64).into());

        self.client.track_service_metric("rule_batch_execution", rule_count as f64, props).await
    }

    /// Track rule adaptation
    pub async fn track_rule_adaptation(
        &self,
        user_id: &str,
        rule_id: &str,
        adaptation_type: &str,
        old_config: &str,
        new_config: &str,
        trigger: &str,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("rule_id".to_string(), rule_id.into());
        props.insert("adaptation_type".to_string(), adaptation_type.into());
        props.insert("old_config".to_string(), old_config.into());
        props.insert("new_config".to_string(), new_config.into());
        props.insert("trigger".to_string(), trigger.into());

        self.client.track_event(user_id, "rule_adapted", props).await
    }

    /// Track rule performance metrics
    pub async fn track_rule_performance(
        &self,
        rule_id: &str,
        avg_execution_time: f64,
        p95_execution_time: f64,
        p99_execution_time: f64,
        success_rate: f64,
        invocation_count: usize,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("rule_id".to_string(), rule_id.into());
        props.insert("avg_execution_time_ms".to_string(), avg_execution_time.into());
        props.insert("p95_execution_time_ms".to_string(), p95_execution_time.into());
        props.insert("p99_execution_time_ms".to_string(), p99_execution_time.into());
        props.insert("success_rate".to_string(), success_rate.into());
        props.insert("invocation_count".to_string(), invocation_count.into());

        self.client.track_service_metric("rule_performance", avg_execution_time, props).await
    }

    /// Track rule cache hit/miss
    pub async fn track_rule_cache_access(
        &self,
        user_id: &str,
        rule_id: &str,
        cache_hit: bool,
        cache_key: &str,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("rule_id".to_string(), rule_id.into());
        props.insert("cache_hit".to_string(), cache_hit.into());
        props.insert("cache_key".to_string(), cache_key.into());

        self.client.track_event(user_id, "rule_cache_access", props).await
    }

    /// Track rule conflict resolution
    pub async fn track_rule_conflict(
        &self,
        user_id: &str,
        conflicting_rules: Vec<String>,
        resolution_strategy: &str,
        winning_rule: &str,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("conflicting_rules".to_string(), serde_json::json!(conflicting_rules));
        props.insert("conflict_count".to_string(), conflicting_rules.len().into());
        props.insert("resolution_strategy".to_string(), resolution_strategy.into());
        props.insert("winning_rule".to_string(), winning_rule.into());

        self.client.track_event(user_id, "rule_conflict_resolved", props).await
    }

    /// Track rule compilation
    pub async fn track_rule_compilation(
        &self,
        rule_id: &str,
        compilation_time_ms: f64,
        success: bool,
        error: Option<String>,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("rule_id".to_string(), rule_id.into());
        props.insert("compilation_time_ms".to_string(), compilation_time_ms.into());
        props.insert("success".to_string(), success.into());
        
        if let Some(err) = error {
            props.insert("error".to_string(), err.into());
        }

        self.client.track_service_metric("rule_compilation", compilation_time_ms, props).await
    }

    /// Track PCM-aware rule execution
    pub async fn track_pcm_rule_execution(
        &self,
        user_id: &str,
        rule_id: &str,
        pcm_stage: PCMStage,
        result: &str,
        execution_time_ms: f64,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("rule_id".to_string(), rule_id.into());
        props.insert("pcm_stage".to_string(), pcm_stage.to_string().into());
        props.insert("result".to_string(), result.into());
        props.insert("execution_time_ms".to_string(), execution_time_ms.into());

        self.client.track_event(user_id, "pcm_rule_executed", props).await
    }

    /// Track rule health metrics
    pub async fn track_health_metrics(
        &self,
        total_rules: usize,
        active_rules: usize,
        cached_rules: usize,
        avg_execution_time: f64,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("total_rules".to_string(), total_rules.into());
        props.insert("active_rules".to_string(), active_rules.into());
        props.insert("cached_rules".to_string(), cached_rules.into());
        props.insert("avg_execution_time_ms".to_string(), avg_execution_time.into());
        props.insert("cache_hit_rate".to_string(), (cached_rules as f64 / total_rules as f64).into());

        self.client.track_service_metric("health_check", 1.0, props).await
    }
}