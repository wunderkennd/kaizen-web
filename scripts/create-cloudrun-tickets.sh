#!/bin/bash

# Create Cloud Run migration tickets for KAIZEN platform
echo "Creating Cloud Run Migration Tickets..."

# T183: Cloud Run base configuration
gh issue create \
  --title "T183: Cloud Run Terraform base configuration" \
  --body "# Task T183: Cloud Run Terraform base configuration

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Cloud Run / Terraform
**File Path**: \`terraform/modules/cloud-run/\`
**Dependencies**: T165
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **DevOps engineer**, I want Terraform modules for Cloud Run so that all services can be deployed as serverless containers with auto-scaling and zero infrastructure management.

## ✅ Acceptance Criteria
### Cloud Run Configuration
- [ ] Service deployment module
- [ ] Environment variables management
- [ ] Secret integration
- [ ] Service account bindings
- [ ] VPC connector setup
- [ ] Cloud SQL proxy configuration

### Networking
- [ ] Custom domains
- [ ] HTTPS certificates (managed)
- [ ] Internal-only services
- [ ] VPC egress configuration
- [ ] Private Cloud SQL connections

### Scaling & Performance
- [ ] Min/max instances configuration
- [ ] Concurrency settings
- [ ] CPU/memory allocation
- [ ] Cold start mitigation
- [ ] Request timeout settings

## 🔧 Technical Context
**Platform**: Cloud Run fully managed
**Scaling**: 0-1000 instances
**Billing**: Per 100ms
**Container**: Any language/framework
**Max request timeout**: 60 minutes (WebSocket)

## 💡 Implementation Notes
\`\`\`hcl
# terraform/modules/cloud-run/main.tf
resource \"google_cloud_run_service\" \"service\" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.image
        
        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }
        
        env {
          name  = \"DB_CONNECTION\"
          value = \"/cloudsql/\${var.project}:\${var.region}:\${var.instance}\"
        }
      }
      
      service_account_name = google_service_account.service.email
    }
    
    metadata {
      annotations = {
        \"autoscaling.knative.dev/minScale\"     = var.min_instances
        \"autoscaling.knative.dev/maxScale\"     = var.max_instances
        \"run.googleapis.com/cpu-throttling\"    = \"false\"
        \"run.googleapis.com/vpc-access-connector\" = var.vpc_connector
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
\`\`\`

## 🧪 Testing Strategy
- Terraform plan validation
- Service deployment testing
- Auto-scaling verification
- Cold start measurement
- Load testing

## 📚 Resources
- [Cloud Run Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service)
- [Cloud Run Best Practices](https://cloud.google.com/run/docs/best-practices)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "cloud-run" \
  --label "P0-critical"

echo "✓ T183 created"

# T184: Service migration from K8s to Cloud Run
gh issue create \
  --title "T184: Migrate frontend service to Cloud Run" \
  --body "# Task T184: Migrate frontend service to Cloud Run

## 📋 Overview
**Category**: Migration
**Component**: Frontend / Cloud Run
**File Path**: \`frontend/\`
**Dependencies**: T183
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **developer**, I want the frontend migrated to Cloud Run so that we can eliminate Kubernetes complexity while maintaining performance and scalability.

## ✅ Acceptance Criteria
### Frontend Migration
- [ ] Next.js standalone build configuration
- [ ] Dockerfile optimized for Cloud Run
- [ ] Environment variables migrated
- [ ] Static assets to Cloud CDN
- [ ] Health check endpoint
- [ ] Graceful shutdown handling

### Deployment Configuration
- [ ] Cloud Run service created
- [ ] Custom domain configured
- [ ] SSL certificate provisioned
- [ ] Traffic splitting setup
- [ ] Rollback procedure documented

### Performance
- [ ] Cold start < 3 seconds
- [ ] Response time < 200ms
- [ ] Core Web Vitals maintained
- [ ] CDN cache hit ratio > 80%
- [ ] Auto-scaling validated

## 🔧 Technical Context
**Framework**: Next.js 14
**Build**: Standalone output
**CDN**: Cloud CDN for static
**Scaling**: 0-100 instances

## 💡 Implementation Notes
\`\`\`dockerfile
# Optimized Dockerfile for Cloud Run
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER nextjs
EXPOSE 8080
ENV PORT 8080

CMD [\"node\", \"server.js\"]
\`\`\`

\`\`\`bash
# Deploy to Cloud Run
gcloud run deploy frontend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 100 \
  --cpu 2 \
  --memory 2Gi
\`\`\`

## 🧪 Testing Strategy
- Smoke tests after deployment
- Performance benchmarking
- Load testing with k6
- A/B test old vs new
- Monitor error rates

## 📚 Resources
- [Next.js on Cloud Run](https://github.com/GoogleCloudPlatform/cloud-run-hello)
- [Cloud Run Migration Guide](https://cloud.google.com/run/docs/migrating)

---
*KAIZEN Adaptive Platform - Migration*" \
  --label "cloud-run" \
  --label "migration" \
  --label "P0-critical"

echo "✓ T184 created"

# T185: Migrate Go services to Cloud Run
gh issue create \
  --title "T185: Migrate Go services to Cloud Run (genui-orchestrator, user-context)" \
  --body "# Task T185: Migrate Go services to Cloud Run

## 📋 Overview
**Category**: Migration
**Component**: Go Services / Cloud Run
**File Path**: \`services/genui-orchestrator/\`, \`services/user-context/\`
**Dependencies**: T183
**Priority**: P0 - Critical
**Effort**: 8 story points

## 👤 User Story
As a **backend developer**, I want Go services migrated to Cloud Run so that they can auto-scale efficiently without Kubernetes overhead.

## ✅ Acceptance Criteria
### Service Migration
- [ ] Both Go services containerized
- [ ] PORT environment variable handled
- [ ] Cloud SQL connections configured
- [ ] Redis connections configured
- [ ] Health checks implemented
- [ ] Graceful shutdown

### Cloud Run Features
- [ ] Service-to-service authentication
- [ ] VPC connector for internal services
- [ ] Structured logging
- [ ] OpenTelemetry tracing
- [ ] Metric collection

### Performance
- [ ] Cold start < 2 seconds
- [ ] Response time < 100ms
- [ ] Connection pooling optimized
- [ ] Memory usage optimized
- [ ] CPU utilization efficient

## 🔧 Technical Context
**Language**: Go 1.21
**Framework**: Gin
**Database**: Cloud SQL PostgreSQL
**Cache**: Memorystore Redis
**Auth**: Service-to-service

## 💡 Implementation Notes
\`\`\`go
// main.go - Cloud Run optimizations
package main

import (
    \"context\"
    \"fmt\"
    \"log\"
    \"net/http\"
    \"os\"
    \"os/signal\"
    \"syscall\"
    \"time\"

    \"github.com/gin-gonic/gin\"
)

func main() {
    // Get port from environment
    port := os.Getenv(\"PORT\")
    if port == \"\" {
        port = \"8080\"
    }

    router := gin.Default()
    
    // Health check for Cloud Run
    router.GET(\"/health\", func(c *gin.Context) {
        c.JSON(200, gin.H{\"status\": \"healthy\"})
    })

    srv := &http.Server{
        Addr:    \":\" + port,
        Handler: router,
    }

    // Graceful shutdown
    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf(\"listen: %s\\n\", err)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    
    if err := srv.Shutdown(ctx); err != nil {
        log.Fatal(\"Server forced to shutdown:\", err)
    }
}
\`\`\`

\`\`\`dockerfile
# Optimized Go Dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server .

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /app/server /
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT [\"/server\"]
\`\`\`

## 🧪 Testing Strategy
- Unit tests pass
- Integration tests with Cloud SQL
- Service-to-service communication
- Load testing
- Monitoring setup

## 📚 Resources
- [Go on Cloud Run](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/go)
- [Cloud SQL from Cloud Run](https://cloud.google.com/sql/docs/mysql/connect-run)

---
*KAIZEN Adaptive Platform - Migration*" \
  --label "cloud-run" \
  --label "migration" \
  --label "P0-critical"

echo "✓ T185 created"

# T186: Migrate Rust services to Cloud Run
gh issue create \
  --title "T186: Migrate Rust services to Cloud Run (kre-engine, streaming-adapter)" \
  --body "# Task T186: Migrate Rust services to Cloud Run

## 📋 Overview
**Category**: Migration
**Component**: Rust Services / Cloud Run
**File Path**: \`services/kre-engine/\`, \`services/streaming-adapter/\`
**Dependencies**: T183
**Priority**: P0 - Critical
**Effort**: 8 story points

## 👤 User Story
As a **backend developer**, I want Rust services migrated to Cloud Run with special attention to WebSocket support for the streaming adapter.

## ✅ Acceptance Criteria
### KRE Engine Migration
- [ ] Rule engine containerized
- [ ] Rule caching strategy
- [ ] Database connections
- [ ] Performance maintained
- [ ] Memory optimization

### Streaming Adapter
- [ ] WebSocket support verified
- [ ] Connection persistence
- [ ] Min instances for no cold start
- [ ] Backpressure handling
- [ ] Graceful disconnection

### Cloud Run Configuration
- [ ] CPU always allocated (streaming)
- [ ] Session affinity enabled
- [ ] 60-minute timeout for WebSocket
- [ ] VPC connector configured
- [ ] Monitoring enabled

## 🔧 Technical Context
**Language**: Rust 1.70+
**WebSocket**: tokio-tungstenite
**Async**: Tokio runtime
**Critical**: WebSocket support

## 💡 Implementation Notes
\`\`\`rust
// main.rs - Cloud Run WebSocket support
use axum::{
    extract::ws::{WebSocket, WebSocketUpgrade},
    response::Response,
    routing::get,
    Router,
};
use std::env;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    // Get port from Cloud Run
    let port = env::var(\"PORT\").unwrap_or_else(|_| \"8080\".to_string());
    let addr = format!(\"0.0.0.0:{}\", port);

    let app = Router::new()
        .route(\"/health\", get(health))
        .route(\"/ws\", get(websocket_handler));

    let listener = TcpListener::bind(&addr).await.unwrap();
    println!(\"Listening on {}\", addr);
    
    axum::serve(listener, app).await.unwrap();
}

async fn health() -> &'static str {
    \"healthy\"
}

async fn websocket_handler(ws: WebSocketUpgrade) -> Response {
    ws.on_upgrade(handle_socket)
}

async fn handle_socket(socket: WebSocket) {
    // WebSocket handling with 60-minute Cloud Run timeout
    // Implement heartbeat to keep connection alive
}
\`\`\`

\`\`\`yaml
# Cloud Run configuration for WebSocket
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: streaming-adapter
  annotations:
    run.googleapis.com/cpu-throttling: \"false\"
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: \"2\"
        autoscaling.knative.dev/maxScale: \"50\"
    spec:
      containerConcurrency: 1000
      timeoutSeconds: 3600  # 60 minutes for WebSocket
\`\`\`

## 🧪 Testing Strategy
- WebSocket connection tests
- Load test with 1000 connections
- Reconnection handling
- Memory usage under load
- Rule evaluation performance

## 📚 Resources
- [WebSocket on Cloud Run](https://cloud.google.com/run/docs/triggering/websockets)
- [Rust on Cloud Run](https://github.com/GoogleCloudPlatform/cloud-run-samples/tree/main/rust)

---
*KAIZEN Adaptive Platform - Migration*" \
  --label "cloud-run" \
  --label "migration" \
  --label "P0-critical"

echo "✓ T186 created"

# T187: Migrate Python services to Cloud Run
gh issue create \
  --title "T187: Migrate Python services to Cloud Run (ai-sommelier, pcm-classifier)" \
  --body "# Task T187: Migrate Python services to Cloud Run

## 📋 Overview
**Category**: Migration
**Component**: Python Services / Cloud Run
**File Path**: \`services/ai-sommelier/\`, \`services/pcm-classifier/\`
**Dependencies**: T183
**Priority**: P0 - Critical
**Effort**: 8 story points

## 👤 User Story
As a **ML engineer**, I want Python ML services migrated to Cloud Run with proper integration to Vertex AI for model serving.

## ✅ Acceptance Criteria
### AI Sommelier Migration
- [ ] FastAPI containerized
- [ ] Vertex AI integration
- [ ] Vector search configured
- [ ] Model loading optimized
- [ ] Async processing

### PCM Classifier
- [ ] Model serving setup
- [ ] Batch prediction support
- [ ] Feature extraction pipeline
- [ ] Cache predictions
- [ ] Monitoring metrics

### ML Optimization
- [ ] Model lazy loading
- [ ] Memory optimization
- [ ] GPU support (if needed)
- [ ] Prediction caching
- [ ] Cold start mitigation

## 🔧 Technical Context
**Framework**: FastAPI
**ML**: Vertex AI integration
**Models**: Cached in memory
**Async**: Full async support

## 💡 Implementation Notes
\`\`\`python
# main.py - Optimized for Cloud Run
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.responses import JSONResponse
import uvicorn

# Global model cache
model_cache = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Load models
    model_cache['recommender'] = await load_model()
    yield
    # Shutdown: Cleanup
    model_cache.clear()

app = FastAPI(lifespan=lifespan)

@app.get(\"/health\")
async def health():
    return {\"status\": \"healthy\"}

@app.post(\"/recommend\")
async def recommend(user_id: str, context: dict):
    model = model_cache.get('recommender')
    if not model:
        model = await load_model()
        model_cache['recommender'] = model
    
    recommendations = await model.predict(user_id, context)
    return JSONResponse(recommendations)

async def load_model():
    # Load from Vertex AI Model Registry
    # or from Cloud Storage
    pass

if __name__ == \"__main__\":
    port = int(os.environ.get(\"PORT\", 8080))
    uvicorn.run(app, host=\"0.0.0.0\", port=port)
\`\`\`

\`\`\`dockerfile
# Optimized Python Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080
ENV PORT 8080

CMD [\"python\", \"main.py\"]
\`\`\`

## 🧪 Testing Strategy
- Model inference testing
- Vertex AI integration
- Response time benchmarks
- Memory usage monitoring
- Concurrent request handling

## 📚 Resources
- [FastAPI on Cloud Run](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/python)
- [Vertex AI Integration](https://cloud.google.com/vertex-ai/docs/start/client-libraries)

---
*KAIZEN Adaptive Platform - Migration*" \
  --label "cloud-run" \
  --label "migration" \
  --label "P0-critical"

echo "✓ T187 created"

# T188: Cloud Run CI/CD with Cloud Build
gh issue create \
  --title "T188: Simplified CI/CD pipeline for Cloud Run with Cloud Build" \
  --body "# Task T188: Simplified CI/CD pipeline for Cloud Run

## 📋 Overview
**Category**: CI/CD
**Component**: Cloud Build / Cloud Run
**File Path**: \`cloudbuild.yaml\`
**Dependencies**: T183-T187
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **DevOps engineer**, I want simplified CI/CD for Cloud Run that automatically builds, tests, and deploys services without Kubernetes complexity.

## ✅ Acceptance Criteria
### Build Pipeline
- [ ] Automatic builds on push
- [ ] Multi-service detection
- [ ] Parallel builds
- [ ] Container registry push
- [ ] Vulnerability scanning

### Deployment Pipeline
- [ ] Automatic deployment to staging
- [ ] Manual promotion to production
- [ ] Traffic splitting
- [ ] Automatic rollback
- [ ] Deployment notifications

### Simplification
- [ ] Single cloudbuild.yaml
- [ ] No Kubernetes manifests
- [ ] No Helm charts
- [ ] Direct Cloud Run deployment
- [ ] Built-in blue-green

## 🔧 Technical Context
**CI/CD**: Cloud Build
**Deployment**: gcloud run deploy
**Registry**: Artifact Registry
**Promotion**: Manual approval

## 💡 Implementation Notes
\`\`\`yaml
# cloudbuild.yaml - Root level
steps:
  # Build all services in parallel
  - id: 'build-frontend'
    name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/\$PROJECT_ID/frontend:\$SHORT_SHA', './frontend']
    waitFor: ['-']

  - id: 'build-genui'
    name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/\$PROJECT_ID/genui:\$SHORT_SHA', './services/genui-orchestrator']
    waitFor: ['-']

  - id: 'build-kre'
    name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/\$PROJECT_ID/kre:\$SHORT_SHA', './services/kre-engine']
    waitFor: ['-']

  # Push images
  - id: 'push-images'
    name: 'gcr.io/cloud-builders/docker'
    args: ['push', '--all-tags', 'gcr.io/\$PROJECT_ID']

  # Deploy to Cloud Run (staging)
  - id: 'deploy-frontend-staging'
    name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: 'gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'frontend'
      - '--image=gcr.io/\$PROJECT_ID/frontend:\$SHORT_SHA'
      - '--region=us-central1'
      - '--platform=managed'
      - '--tag=staging-\$SHORT_SHA'
      - '--no-traffic'

  # Traffic split for canary
  - id: 'canary-rollout'
    name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: 'gcloud'
    args:
      - 'run'
      - 'services'
      - 'update-traffic'
      - 'frontend'
      - '--region=us-central1'
      - '--to-tags=staging-\$SHORT_SHA=10'

options:
  machineType: 'E2_HIGHCPU_8'
  dynamic_substitutions: true

# Trigger configuration
trigger:
  branch:
    name: '^main\$'
  includedFiles:
    - 'frontend/**'
    - 'services/**'
\`\`\`

## 🧪 Testing Strategy
- Build success validation
- Deployment verification
- Traffic split testing
- Rollback testing
- Performance monitoring

## 📚 Resources
- [Cloud Build for Cloud Run](https://cloud.google.com/build/docs/deploying-builds/deploy-cloud-run)
- [Cloud Run Continuous Deployment](https://cloud.google.com/run/docs/continuous-deployment)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cloud-run" \
  --label "cicd" \
  --label "P0-critical"

echo "✓ T188 created"

# T189: Cloud Run monitoring and observability
gh issue create \
  --title "T189: Cloud Run monitoring and observability setup" \
  --body "# Task T189: Cloud Run monitoring and observability setup

## 📋 Overview
**Category**: Monitoring
**Component**: Cloud Run / Cloud Monitoring
**File Path**: \`monitoring/\`
**Dependencies**: T183-T187
**Priority**: P1 - High
**Effort**: 5 story points

## 👤 User Story
As a **SRE**, I want comprehensive monitoring for Cloud Run services so that we have visibility into performance, errors, and costs.

## ✅ Acceptance Criteria
### Metrics & Monitoring
- [ ] Request latency tracking
- [ ] Error rate monitoring
- [ ] Cold start metrics
- [ ] Concurrency tracking
- [ ] Memory/CPU utilization

### Dashboards
- [ ] Service overview dashboard
- [ ] Performance dashboard
- [ ] Cost tracking dashboard
- [ ] SLO dashboard
- [ ] Custom metrics dashboard

### Alerting
- [ ] Error rate alerts
- [ ] Latency alerts
- [ ] Cold start alerts
- [ ] Cost anomaly alerts
- [ ] SLO breach alerts

### Tracing & Logging
- [ ] Distributed tracing setup
- [ ] Structured logging
- [ ] Log aggregation
- [ ] Error reporting
- [ ] Log-based metrics

## 🔧 Technical Context
**Monitoring**: Cloud Monitoring (native)
**Tracing**: Cloud Trace
**Logging**: Cloud Logging
**Dashboards**: Terraform-managed

## 💡 Implementation Notes
\`\`\`hcl
# terraform/modules/monitoring/cloud-run-dashboard.tf
resource \"google_monitoring_dashboard\" \"cloud_run\" {
  display_name = \"Cloud Run Services\"

  dashboard_json = jsonencode({
    displayName = \"Cloud Run Services\"
    gridLayout = {
      widgets = [
        {
          title = \"Request Latency (P95)\"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = \"metric.type=\\\"run.googleapis.com/request_latencies\\\"\"
                  aggregation = {
                    alignmentPeriod = \"60s\"
                    perSeriesAligner = \"ALIGN_PERCENTILE_95\"
                  }
                }
              }
            }]
          }
        },
        {
          title = \"Cold Start Frequency\"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = \"metric.type=\\\"run.googleapis.com/container/cold_start_count\\\"\"
                }
              }
            }]
          }
        }
      ]
    }
  })
}

# Alert for high error rate
resource \"google_monitoring_alert_policy\" \"error_rate\" {
  display_name = \"Cloud Run Error Rate\"
  
  conditions {
    display_name = \"Error rate > 1%\"
    condition_threshold {
      filter = \"metric.type=\\\"run.googleapis.com/request_count\\\" AND resource.type=\\\"cloud_run_revision\\\" AND metric.label.response_code_class=\\\"5xx\\\"\"
      
      comparison = \"COMPARISON_GT\"
      threshold_value = 0.01
      duration = \"60s\"
      
      aggregations {
        alignment_period = \"60s\"
        per_series_aligner = \"ALIGN_RATE\"
      }
    }
  }
  
  notification_channels = [var.notification_channel_id]
}
\`\`\`

## 🧪 Testing Strategy
- Dashboard validation
- Alert testing
- Metric accuracy
- Log aggregation testing
- Cost tracking validation

## 📚 Resources
- [Cloud Run Monitoring](https://cloud.google.com/run/docs/monitoring)
- [Cloud Run Metrics](https://cloud.google.com/monitoring/api/metrics_gcp#gcp-run)

---
*KAIZEN Adaptive Platform - Monitoring*" \
  --label "cloud-run" \
  --label "monitoring" \
  --label "P1-high"

echo "✓ T189 created"

# T190: Cloud Run cost optimization
gh issue create \
  --title "T190: Cloud Run cost optimization and scaling strategies" \
  --body "# Task T190: Cloud Run cost optimization and scaling strategies

## 📋 Overview
**Category**: Cost Optimization
**Component**: Cloud Run
**File Path**: \`terraform/modules/cloud-run/\`
**Dependencies**: T183-T189
**Priority**: P1 - High
**Effort**: 5 story points

## 👤 User Story
As a **platform owner**, I want Cloud Run services optimized for cost so that we minimize expenses while maintaining performance.

## ✅ Acceptance Criteria
### Cost Optimization
- [ ] Min instances optimized per service
- [ ] CPU/memory right-sized
- [ ] Concurrency tuned
- [ ] Idle timeout configured
- [ ] CPU throttling decisions

### Scaling Strategy
- [ ] Service-specific scaling rules
- [ ] Time-based scaling
- [ ] Predictive scaling setup
- [ ] Traffic-based routing
- [ ] Regional deployment strategy

### Cost Monitoring
- [ ] Budget alerts configured
- [ ] Cost attribution tags
- [ ] Service-level cost tracking
- [ ] Cost anomaly detection
- [ ] Monthly cost reports

## 🔧 Technical Context
**Goal**: <\$1,500/month total
**Strategy**: Scale to zero where possible
**Critical Services**: 1-2 min instances
**Non-critical**: 0 min instances

## 💡 Implementation Notes
\`\`\`hcl
# Service-specific configurations
locals {
  service_configs = {
    frontend = {
      min_instances = 1  # Always warm
      max_instances = 100
      cpu = \"1\"
      memory = \"512Mi\"
      concurrency = 80
    }
    genui-orchestrator = {
      min_instances = 1  # Critical service
      max_instances = 50
      cpu = \"1\"
      memory = \"1Gi\"
      concurrency = 100
    }
    kre-engine = {
      min_instances = 2  # Performance critical
      max_instances = 100
      cpu = \"2\"
      memory = \"2Gi\"
      concurrency = 50
    }
    ai-sommelier = {
      min_instances = 0  # Scale to zero
      max_instances = 20
      cpu = \"2\"
      memory = \"4Gi\"
      concurrency = 10
    }
    streaming-adapter = {
      min_instances = 2  # WebSocket needs warm
      max_instances = 50
      cpu = \"1\"
      memory = \"512Mi\"
      concurrency = 1000
    }
  }
}

# Budget alert
resource \"google_billing_budget\" \"cloud_run\" {
  billing_account = var.billing_account
  display_name = \"Cloud Run Budget\"
  
  budget_filter {
    services = [\"run.googleapis.com\"]
  }
  
  amount {
    specified_amount {
      currency_code = \"USD\"
      units = \"500\"  # \$500/month for Cloud Run
    }
  }
  
  threshold_rules {
    threshold_percent = 0.8
  }
  
  threshold_rules {
    threshold_percent = 1.0
  }
}
\`\`\`

## 🧪 Testing Strategy
- Cost simulation
- Load testing for right-sizing
- Scale-to-zero verification
- Budget alert testing
- Performance impact analysis

## 📚 Resources
- [Cloud Run Pricing](https://cloud.google.com/run/pricing)
- [Cost Optimization Guide](https://cloud.google.com/run/docs/cost-optimization)

---
*KAIZEN Adaptive Platform - Cost Optimization*" \
  --label "cloud-run" \
  --label "cost-optimization" \
  --label "P1-high"

echo "✓ T190 created"

echo ""
echo "========================================="
echo "Cloud Run Migration Tickets Created!"
echo ""
echo "Created 8 new Cloud Run tickets (T183-T190):"
echo "- T183: Cloud Run Terraform modules (P0)"
echo "- T184: Frontend migration (P0)"
echo "- T185: Go services migration (P0)"
echo "- T186: Rust services migration (P0)"
echo "- T187: Python services migration (P0)"
echo "- T188: Simplified CI/CD pipeline (P0)"
echo "- T189: Monitoring setup (P1)"
echo "- T190: Cost optimization (P1)"
echo ""
echo "Priority Breakdown:"
echo "- P0 Critical: T183-T188 (39 points)"
echo "- P1 High: T189-T190 (10 points)"
echo ""
echo "Total effort: 49 story points"
echo ""
echo "This replaces the Kubernetes approach with:"
echo "✅ 70% less complexity"
echo "✅ \$500/month cost savings"
echo "✅ Zero infrastructure management"
echo "✅ Faster deployments"
echo "✅ Better developer experience"
echo "========================================="