use anyhow::Result;
use kaizen_shared::analytics::{Analytics as BaseAnalytics, PCMStage, PostHogConfig};
use posthog_rs::Properties;
use std::collections::HashMap;

/// Analytics handler for Streaming Adapter
pub struct Analytics {
    client: BaseAnalytics,
}

impl Analytics {
    /// Create new Analytics instance
    pub fn new() -> Result<Self> {
        let mut config = PostHogConfig::default();
        config.service = "streaming-adapter".to_string();
        
        let client = BaseAnalytics::new(config)?;
        Ok(Self { client })
    }

    /// Track WebSocket connection
    pub async fn track_websocket_connection(
        &self,
        user_id: &str,
        connection_id: &str,
        pcm_stage: Option<PCMStage>,
        metadata: HashMap<String, serde_json::Value>,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("connection_id".to_string(), connection_id.into());
        
        if let Some(stage) = pcm_stage {
            props.insert("pcm_stage".to_string(), stage.to_string().into());
        }
        
        for (k, v) in metadata {
            props.insert(k, v);
        }

        self.client.track_event(user_id, "websocket_connected", props).await
    }

    /// Track WebSocket disconnection
    pub async fn track_websocket_disconnection(
        &self,
        user_id: &str,
        connection_id: &str,
        duration_seconds: f64,
        reason: &str,
        messages_sent: usize,
        messages_received: usize,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("connection_id".to_string(), connection_id.into());
        props.insert("duration_seconds".to_string(), duration_seconds.into());
        props.insert("disconnect_reason".to_string(), reason.into());
        props.insert("messages_sent".to_string(), messages_sent.into());
        props.insert("messages_received".to_string(), messages_received.into());

        self.client.track_event(user_id, "websocket_disconnected", props).await
    }

    /// Track message streaming
    pub async fn track_message_streamed(
        &self,
        user_id: &str,
        message_type: &str,
        size_bytes: usize,
        latency_ms: f64,
        success: bool,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("message_type".to_string(), message_type.into());
        props.insert("size_bytes".to_string(), size_bytes.into());
        props.insert("latency_ms".to_string(), latency_ms.into());
        props.insert("success".to_string(), success.into());

        self.client.track_event(user_id, "message_streamed", props).await
    }

    /// Track SSE (Server-Sent Events) connection
    pub async fn track_sse_connection(
        &self,
        user_id: &str,
        connection_id: &str,
        channel: &str,
        metadata: HashMap<String, serde_json::Value>,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("connection_id".to_string(), connection_id.into());
        props.insert("channel".to_string(), channel.into());
        
        for (k, v) in metadata {
            props.insert(k, v);
        }

        self.client.track_event(user_id, "sse_connected", props).await
    }

    /// Track streaming performance metrics
    pub async fn track_streaming_performance(
        &self,
        connection_type: &str,
        active_connections: usize,
        messages_per_second: f64,
        avg_latency_ms: f64,
        p95_latency_ms: f64,
        p99_latency_ms: f64,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("connection_type".to_string(), connection_type.into());
        props.insert("active_connections".to_string(), active_connections.into());
        props.insert("messages_per_second".to_string(), messages_per_second.into());
        props.insert("avg_latency_ms".to_string(), avg_latency_ms.into());
        props.insert("p95_latency_ms".to_string(), p95_latency_ms.into());
        props.insert("p99_latency_ms".to_string(), p99_latency_ms.into());

        self.client.track_service_metric("streaming_performance", messages_per_second, props).await
    }

    /// Track real-time UI update
    pub async fn track_realtime_ui_update(
        &self,
        user_id: &str,
        component_id: &str,
        update_type: &str,
        pcm_stage: PCMStage,
        latency_ms: f64,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("component_id".to_string(), component_id.into());
        props.insert("update_type".to_string(), update_type.into());
        props.insert("pcm_stage".to_string(), pcm_stage.to_string().into());
        props.insert("latency_ms".to_string(), latency_ms.into());

        self.client.track_event(user_id, "realtime_ui_updated", props).await
    }

    /// Track broadcast message
    pub async fn track_broadcast_message(
        &self,
        channel: &str,
        message_type: &str,
        recipient_count: usize,
        delivery_time_ms: f64,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("channel".to_string(), channel.into());
        props.insert("message_type".to_string(), message_type.into());
        props.insert("recipient_count".to_string(), recipient_count.into());
        props.insert("delivery_time_ms".to_string(), delivery_time_ms.into());

        self.client.track_service_metric("broadcast_message", recipient_count as f64, props).await
    }

    /// Track connection pool metrics
    pub async fn track_connection_pool_metrics(
        &self,
        pool_size: usize,
        active_connections: usize,
        idle_connections: usize,
        pending_connections: usize,
        connection_reuse_rate: f64,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("pool_size".to_string(), pool_size.into());
        props.insert("active_connections".to_string(), active_connections.into());
        props.insert("idle_connections".to_string(), idle_connections.into());
        props.insert("pending_connections".to_string(), pending_connections.into());
        props.insert("connection_reuse_rate".to_string(), connection_reuse_rate.into());

        self.client.track_service_metric("connection_pool", pool_size as f64, props).await
    }

    /// Track message queue metrics
    pub async fn track_message_queue_metrics(
        &self,
        queue_name: &str,
        queue_size: usize,
        messages_processed: usize,
        avg_processing_time_ms: f64,
        dropped_messages: usize,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("queue_name".to_string(), queue_name.into());
        props.insert("queue_size".to_string(), queue_size.into());
        props.insert("messages_processed".to_string(), messages_processed.into());
        props.insert("avg_processing_time_ms".to_string(), avg_processing_time_ms.into());
        props.insert("dropped_messages".to_string(), dropped_messages.into());

        self.client.track_service_metric("message_queue", queue_size as f64, props).await
    }

    /// Track streaming error
    pub async fn track_streaming_error(
        &self,
        user_id: Option<&str>,
        error_type: &str,
        error_message: &str,
        connection_id: Option<&str>,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("error_type".to_string(), error_type.into());
        props.insert("error_message".to_string(), error_message.into());
        
        if let Some(conn_id) = connection_id {
            props.insert("connection_id".to_string(), conn_id.into());
        }

        let distinct_id = user_id.unwrap_or("system:streaming-adapter");
        self.client.track_event(distinct_id, "streaming_error", props).await
    }

    /// Track health metrics
    pub async fn track_health_metrics(
        &self,
        healthy: bool,
        websocket_connections: usize,
        sse_connections: usize,
        avg_message_latency_ms: f64,
        error_rate: f64,
    ) -> Result<()> {
        let mut props = Properties::new();
        props.insert("healthy".to_string(), healthy.into());
        props.insert("websocket_connections".to_string(), websocket_connections.into());
        props.insert("sse_connections".to_string(), sse_connections.into());
        props.insert("total_connections".to_string(), (websocket_connections + sse_connections).into());
        props.insert("avg_message_latency_ms".to_string(), avg_message_latency_ms.into());
        props.insert("error_rate".to_string(), error_rate.into());

        self.client.track_service_metric("health_check", 1.0, props).await
    }
}