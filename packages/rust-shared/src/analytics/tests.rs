#[cfg(test)]
mod tests {
    use super::super::*;
    use mockall::{mock, predicate::*};
    use posthog_rs::Properties;

    // Mock PostHog client for testing
    mock! {
        PostHogClient {
            fn capture(&self, event: Event) -> Result<()>;
        }
    }

    #[tokio::test]
    async fn test_pcm_stage_to_string() {
        assert_eq!(PCMStage::Awareness.to_string(), "awareness");
        assert_eq!(PCMStage::Attraction.to_string(), "attraction");
        assert_eq!(PCMStage::Attachment.to_string(), "attachment");
        assert_eq!(PCMStage::Allegiance.to_string(), "allegiance");
    }

    #[tokio::test]
    async fn test_config_from_env() {
        std::env::set_var("POSTHOG_PROJECT_API_KEY", "test-key");
        std::env::set_var("POSTHOG_HOST", "http://test-host");
        std::env::set_var("SERVICE_NAME", "test-service");
        std::env::set_var("POSTHOG_ENABLED", "true");
        std::env::set_var("POSTHOG_BATCH_SIZE", "50");
        std::env::set_var("POSTHOG_FLUSH_INTERVAL", "5000");

        let config = PostHogConfig::default();

        assert_eq!(config.api_key, "test-key");
        assert_eq!(config.host, "http://test-host");
        assert_eq!(config.service, "test-service");
        assert_eq!(config.enabled, true);
        assert_eq!(config.batch_size, 50);
        assert_eq!(config.flush_interval_ms, 5000);

        // Clean up
        std::env::remove_var("POSTHOG_PROJECT_API_KEY");
        std::env::remove_var("POSTHOG_HOST");
        std::env::remove_var("SERVICE_NAME");
        std::env::remove_var("POSTHOG_ENABLED");
        std::env::remove_var("POSTHOG_BATCH_SIZE");
        std::env::remove_var("POSTHOG_FLUSH_INTERVAL");
    }

    #[tokio::test]
    async fn test_analytics_new_with_api_key() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        assert!(analytics.is_enabled().await);
        assert_eq!(analytics.service, "test-service");
    }

    #[tokio::test]
    async fn test_analytics_new_disabled() {
        let config = PostHogConfig {
            api_key: "".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: false,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        assert!(!analytics.is_enabled().await);
    }

    #[tokio::test]
    async fn test_track_pcm_transition() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        let mut props = Properties::new();
        props.insert("content_id".to_string(), "123".into());

        let result = analytics.track_pcm_transition(
            "user123",
            PCMStage::Awareness,
            PCMStage::Attraction,
            "viewed_content",
            props,
        ).await;

        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_track_event() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        let mut props = Properties::new();
        props.insert("key".to_string(), "value".into());

        let result = analytics.track_event(
            "user123",
            "test_event",
            props,
        ).await;

        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_track_service_metric() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        let mut props = Properties::new();
        props.insert("endpoint".to_string(), "/api/test".into());

        let result = analytics.track_service_metric(
            "latency",
            150.5,
            props,
        ).await;

        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_track_experiment() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        let mut props = Properties::new();
        props.insert("page".to_string(), "home".into());

        let result = analytics.track_experiment(
            "user123",
            "hero-test",
            "variant-b",
            props,
        ).await;

        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_track_conversion() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        let mut props = Properties::new();
        props.insert("button".to_string(), "signup".into());

        let result = analytics.track_conversion(
            "user123",
            "hero-test",
            "clicked_cta",
            1.0,
            props,
        ).await;

        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_disabled_tracking() {
        let config = PostHogConfig {
            api_key: "".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: false,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        // Should not error when disabled
        let result = analytics.track_event(
            "user123",
            "test_event",
            Properties::new(),
        ).await;

        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_enable_disable() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        assert!(analytics.is_enabled().await);
        
        analytics.disable().await;
        assert!(!analytics.is_enabled().await);
        
        analytics.enable().await;
        assert!(analytics.is_enabled().await);
    }

    #[tokio::test]
    async fn test_identify_user() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        let mut props = Properties::new();
        props.insert("name".to_string(), "John".into());
        props.insert("pcm_stage".to_string(), "awareness".into());

        let result = analytics.identify_user("user123", props).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_flush() {
        let config = PostHogConfig {
            api_key: "test-key".to_string(),
            host: "http://localhost".to_string(),
            service: "test-service".to_string(),
            enabled: true,
            batch_size: 100,
            flush_interval_ms: 10000,
        };

        let analytics = Analytics::new(config).unwrap();
        
        let result = analytics.flush();
        assert!(result.is_ok());
    }
}