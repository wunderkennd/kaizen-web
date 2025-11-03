use anyhow::Result;
use chrono::Utc;
use posthog_rs::{Client as PostHogClient, Event, Properties};
use serde::{Deserialize, Serialize};
use std::env;
use std::sync::Arc;
use tokio::sync::RwLock;
use tracing::warn;

/// PCM stages for the Psychological Continuum Model
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum PCMStage {
    Awareness,
    Attraction,
    Attachment,
    Allegiance,
}

impl ToString for PCMStage {
    fn to_string(&self) -> String {
        match self {
            PCMStage::Awareness => "awareness".to_string(),
            PCMStage::Attraction => "attraction".to_string(),
            PCMStage::Attachment => "attachment".to_string(),
            PCMStage::Allegiance => "allegiance".to_string(),
        }
    }
}

/// Configuration for PostHog client
#[derive(Debug, Clone)]
pub struct PostHogConfig {
    pub api_key: String,
    pub host: String,
    pub service: String,
    pub enabled: bool,
    pub batch_size: usize,
    pub flush_interval_ms: u64,
}

impl Default for PostHogConfig {
    fn default() -> Self {
        Self {
            api_key: env::var("POSTHOG_PROJECT_API_KEY").unwrap_or_default(),
            host: env::var("POSTHOG_HOST").unwrap_or_else(|_| "https://app.posthog.com".to_string()),
            service: env::var("SERVICE_NAME").unwrap_or_else(|_| "rust-service".to_string()),
            enabled: env::var("POSTHOG_ENABLED")
                .map(|v| v.parse().unwrap_or(true))
                .unwrap_or(true),
            batch_size: env::var("POSTHOG_BATCH_SIZE")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(100),
            flush_interval_ms: env::var("POSTHOG_FLUSH_INTERVAL")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(10000),
        }
    }
}

/// Analytics client wrapper for PostHog
pub struct Analytics {
    client: Option<PostHogClient>,
    service: String,
    enabled: Arc<RwLock<bool>>,
}

impl Analytics {
    /// Create a new Analytics instance
    pub fn new(config: PostHogConfig) -> Result<Self> {
        let client = if config.enabled && !config.api_key.is_empty() {
            Some(PostHogClient::new(config.api_key, config.host))
        } else {
            if config.enabled && config.api_key.is_empty() {
                warn!("PostHog enabled but API key not provided");
            }
            None
        };

        Ok(Self {
            client,
            service: config.service,
            enabled: Arc::new(RwLock::new(config.enabled)),
        })
    }

    /// Track PCM stage transition
    pub async fn track_pcm_transition(
        &self,
        user_id: &str,
        from: PCMStage,
        to: PCMStage,
        trigger: &str,
        mut props: Properties,
    ) -> Result<()> {
        if !self.is_enabled().await {
            return Ok(());
        }

        props.insert("from_stage".to_string(), from.to_string().into());
        props.insert("to_stage".to_string(), to.to_string().into());
        props.insert("trigger".to_string(), trigger.into());
        props.insert("service".to_string(), self.service.clone().into());
        props.insert("timestamp".to_string(), Utc::now().to_rfc3339().into());

        self.track_event(user_id, "pcm_stage_transition", props).await
    }

    /// Track a generic event
    pub async fn track_event(
        &self,
        user_id: &str,
        event_name: &str,
        mut props: Properties,
    ) -> Result<()> {
        if !self.is_enabled().await {
            return Ok(());
        }

        if let Some(client) = &self.client {
            props.insert("service".to_string(), self.service.clone().into());
            props.insert("timestamp".to_string(), Utc::now().to_rfc3339().into());

            let event = Event {
                event: event_name.to_string(),
                distinct_id: user_id.to_string(),
                properties: props,
                timestamp: Some(Utc::now()),
                ..Default::default()
            };

            client.capture(event)?;
        }

        Ok(())
    }

    /// Track service-level metrics
    pub async fn track_service_metric(
        &self,
        metric_name: &str,
        value: f64,
        mut props: Properties,
    ) -> Result<()> {
        if !self.is_enabled().await {
            return Ok(());
        }

        let distinct_id = format!("system:{}", self.service);
        
        props.insert("service".to_string(), self.service.clone().into());
        props.insert("metric_name".to_string(), metric_name.into());
        props.insert("metric_value".to_string(), value.into());
        props.insert("timestamp".to_string(), Utc::now().to_rfc3339().into());

        self.track_event(&distinct_id, &format!("{}_metric", self.service), props).await
    }

    /// Track experiment assignment
    pub async fn track_experiment(
        &self,
        user_id: &str,
        experiment_key: &str,
        variant: &str,
        mut props: Properties,
    ) -> Result<()> {
        props.insert("experiment".to_string(), experiment_key.into());
        props.insert("variant".to_string(), variant.into());
        props.insert("service".to_string(), self.service.clone().into());

        self.track_event(user_id, "$experiment_started", props).await
    }

    /// Track conversion events
    pub async fn track_conversion(
        &self,
        user_id: &str,
        experiment_key: &str,
        goal: &str,
        value: f64,
        mut props: Properties,
    ) -> Result<()> {
        props.insert("experiment".to_string(), experiment_key.into());
        props.insert("goal".to_string(), goal.into());
        props.insert("value".to_string(), value.into());
        props.insert("service".to_string(), self.service.clone().into());

        self.track_event(user_id, "experiment_conversion", props).await
    }

    /// Identify user with properties
    pub async fn identify_user(
        &self,
        user_id: &str,
        props: Properties,
    ) -> Result<()> {
        if !self.is_enabled().await {
            return Ok(());
        }

        if let Some(client) = &self.client {
            let event = Event {
                event: "$identify".to_string(),
                distinct_id: user_id.to_string(),
                properties: props,
                timestamp: Some(Utc::now()),
                ..Default::default()
            };

            client.capture(event)?;
        }

        Ok(())
    }

    /// Check if analytics is enabled
    pub async fn is_enabled(&self) -> bool {
        *self.enabled.read().await
    }

    /// Enable analytics tracking
    pub async fn enable(&self) {
        *self.enabled.write().await = true;
    }

    /// Disable analytics tracking
    pub async fn disable(&self) {
        *self.enabled.write().await = false;
    }

    /// Flush pending events
    pub fn flush(&self) -> Result<()> {
        // PostHog-rs handles batching internally
        Ok(())
    }
}

#[cfg(test)]
mod tests;