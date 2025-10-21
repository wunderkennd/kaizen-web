#!/bin/bash

# Script to create GCP Terraform Infrastructure as Code tickets
echo "Creating GCP Terraform Infrastructure tickets..."

# T165: Terraform base configuration
gh issue create \
  --title "T165: Create Terraform base configuration for GCP" \
  --body "# Task T165: Create Terraform base configuration for GCP

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / GCP
**File Path**: \`terraform/\`
**Dependencies**: None
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **DevOps engineer**, I want Terraform base configuration for GCP so that all infrastructure can be provisioned as code with proper state management and module structure.

## ✅ Acceptance Criteria
### Configuration Structure
- [ ] Root module with provider configuration
- [ ] Remote state backend in GCS
- [ ] Workspace support for environments (dev/staging/prod)
- [ ] Variable definitions with defaults
- [ ] Output definitions for resource IDs
- [ ] .tfvars files for each environment

### Module Organization
- [ ] Separate modules for each service type
- [ ] Reusable modules with versioning
- [ ] Module documentation with examples
- [ ] Input validation rules
- [ ] Consistent naming conventions

### State Management
- [ ] GCS bucket for state storage
- [ ] State locking with Cloud SQL
- [ ] Encryption at rest
- [ ] Versioning enabled
- [ ] Lifecycle policies

## 🔧 Technical Context
**Terraform Version**: 1.5+
**Provider**: hashicorp/google 5.0+
**Backend**: GCS with locking
**Structure**: Modular design
**Environments**: dev, staging, prod

## 💡 Implementation Notes
\`\`\`hcl
# terraform/main.tf
terraform {
  required_version = \">= 1.5.0\"
  
  required_providers {
    google = {
      source  = \"hashicorp/google\"
      version = \"~> 5.0\"
    }
  }
  
  backend \"gcs\" {
    bucket = \"kaizen-terraform-state\"
    prefix = \"terraform/state\"
  }
}

# terraform/environments/prod/terraform.tfvars
project_id = \"kaizen-prod\"
region     = \"us-central1\"
environment = \"prod\"
\`\`\`

## 🧪 Testing Strategy
- Terraform validate for syntax
- Terraform plan for dry-run
- tflint for best practices
- Checkov for security scanning
- terraform-docs for documentation

## 📚 Resources
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [GCP Terraform Modules](https://github.com/terraform-google-modules)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "gcp" \
  --label "P0-critical"

echo "✓ T165 created"

# T166: GKE Terraform module
gh issue create \
  --title "T166: Terraform module for GKE Autopilot clusters" \
  --body "# Task T166: Terraform module for GKE Autopilot clusters

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / GKE
**File Path**: \`terraform/modules/gke/\`
**Dependencies**: T165
**Priority**: P0 - Critical
**Effort**: 8 story points

## 👤 User Story
As a **DevOps engineer**, I want a Terraform module for GKE Autopilot so that Kubernetes clusters can be provisioned consistently across environments with best practices.

## ✅ Acceptance Criteria
### GKE Configuration
- [ ] GKE Autopilot cluster creation
- [ ] Workload Identity enabled
- [ ] Private cluster with authorized networks
- [ ] Regional cluster for HA
- [ ] Appropriate machine types
- [ ] Node auto-scaling configuration

### Networking
- [ ] VPC-native networking
- [ ] Private endpoint access
- [ ] Cloud NAT for egress
- [ ] Firewall rules
- [ ] Private service connections

### Security
- [ ] Binary Authorization
- [ ] Workload Identity for service accounts
- [ ] Network policies enabled
- [ ] Pod Security Standards
- [ ] Secrets encryption at rest

## 🔧 Technical Context
**GKE Mode**: Autopilot
**Networking**: VPC-native
**Security**: Workload Identity
**Monitoring**: GKE monitoring enabled
**Region**: Multi-zone regional

## 💡 Implementation Notes
\`\`\`hcl
# terraform/modules/gke/main.tf
resource \"google_container_cluster\" \"autopilot\" {
  name     = var.cluster_name
  location = var.region
  
  enable_autopilot = true
  
  network    = var.network_id
  subnetwork = var.subnet_id
  
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range
    services_secondary_range_name = var.services_range
  }
  
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = var.master_cidr
  }
  
  workload_identity_config {
    workload_pool = \"\${var.project_id}.svc.id.goog\"
  }
}
\`\`\`

## 🧪 Testing Strategy
- Terraform plan validation
- Test cluster creation/destruction
- Verify Workload Identity
- Test auto-scaling
- Security scanning with Checkov

## 📚 Resources
- [GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [GKE Terraform Module](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "gke" \
  --label "P0-critical"

echo "✓ T166 created"

# T167: Cloud SQL Terraform module
gh issue create \
  --title "T167: Terraform module for Cloud SQL PostgreSQL" \
  --body "# Task T167: Terraform module for Cloud SQL PostgreSQL

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / Cloud SQL
**File Path**: \`terraform/modules/cloud-sql/\`
**Dependencies**: T165
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **DevOps engineer**, I want a Terraform module for Cloud SQL PostgreSQL so that databases can be provisioned with HA, backups, and security best practices.

## ✅ Acceptance Criteria
### Database Configuration
- [ ] PostgreSQL 14+ instance
- [ ] High Availability with regional configuration
- [ ] Automated backups with PITR
- [ ] Read replicas for scaling
- [ ] Private IP only
- [ ] SSL enforcement

### Performance
- [ ] Appropriate machine types
- [ ] Storage auto-resize
- [ ] Connection pooling config
- [ ] Query insights enabled
- [ ] Performance insights

### Security
- [ ] Private service connection
- [ ] IAM authentication
- [ ] Encryption at rest
- [ ] Automated maintenance windows
- [ ] Database flags for security

## 🔧 Technical Context
**PostgreSQL Version**: 14
**HA**: Regional configuration
**Backup**: Daily with 7-day retention
**Network**: Private IP only
**Encryption**: Customer-managed keys

## 💡 Implementation Notes
\`\`\`hcl
# terraform/modules/cloud-sql/main.tf
resource \"google_sql_database_instance\" \"main\" {
  name             = var.instance_name
  database_version = \"POSTGRES_14\"
  region          = var.region
  
  settings {
    tier              = var.tier
    availability_type = \"REGIONAL\"
    disk_size        = var.disk_size
    disk_autoresize  = true
    
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = \"02:00\"
      location                       = var.backup_location
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      require_ssl     = true
    }
    
    database_flags {
      name  = \"max_connections\"
      value = \"1000\"
    }
  }
}
\`\`\`

## 🧪 Testing Strategy
- Test instance creation
- Verify backup/restore
- Test failover scenarios
- Validate SSL enforcement
- Performance benchmarks

## 📚 Resources
- [Cloud SQL Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "database" \
  --label "P0-critical"

echo "✓ T167 created"

# T168: Memorystore Redis Terraform
gh issue create \
  --title "T168: Terraform module for Memorystore Redis" \
  --body "# Task T168: Terraform module for Memorystore Redis

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / Memorystore
**File Path**: \`terraform/modules/memorystore/\`
**Dependencies**: T165
**Priority**: P0 - Critical
**Effort**: 3 story points

## 👤 User Story
As a **DevOps engineer**, I want a Terraform module for Memorystore Redis so that caching infrastructure can be provisioned with HA and proper configuration.

## ✅ Acceptance Criteria
- [ ] Redis 6.x instance creation
- [ ] Standard tier with HA
- [ ] AUTH enabled
- [ ] Private service connection
- [ ] Appropriate memory allocation
- [ ] Maintenance windows configured
- [ ] Redis configuration parameters
- [ ] Monitoring enabled

## 🔧 Technical Context
**Redis Version**: 6.x
**Tier**: Standard (HA)
**Memory**: 5-10 GB for production
**Network**: Private service connection

## 💡 Implementation Notes
\`\`\`hcl
resource \"google_redis_instance\" \"cache\" {
  name           = var.instance_name
  tier           = \"STANDARD_HA\"
  memory_size_gb = var.memory_size
  region         = var.region
  
  authorized_network = var.network_id
  connect_mode      = \"PRIVATE_SERVICE_ACCESS\"
  
  redis_version = \"REDIS_6_X\"
  auth_enabled  = true
  
  maintenance_policy {
    weekly_maintenance_window {
      day = \"SUNDAY\"
      start_time {
        hours   = 2
        minutes = 0
      }
    }
  }
}
\`\`\`

## 📚 Resources
- [Memorystore Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "cache" \
  --label "P0-critical"

echo "✓ T168 created"

# T169: Vertex AI Terraform
gh issue create \
  --title "T169: Terraform module for Vertex AI infrastructure" \
  --body "# Task T169: Terraform module for Vertex AI infrastructure

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / Vertex AI
**File Path**: \`terraform/modules/vertex-ai/\`
**Dependencies**: T165
**Priority**: P1 - High
**Effort**: 8 story points

## 👤 User Story
As a **ML engineer**, I want Terraform modules for Vertex AI so that ML infrastructure including training, serving, and vector search can be provisioned consistently.

## ✅ Acceptance Criteria
### Vertex AI Setup
- [ ] Vertex AI API enablement
- [ ] Model registry configuration
- [ ] Endpoint creation for serving
- [ ] Matching Engine index for vector search
- [ ] Pipeline configuration
- [ ] Tensorboard setup

### ML Infrastructure
- [ ♎ Training job configurations
- [ ] Model serving endpoints
- [ ] Batch prediction jobs
- [ ] Feature store setup
- [ ] Metadata store

### Vector Search
- [ ] Matching Engine index creation
- [ ] Index endpoint deployment
- [ ] VPC peering for private access
- [ ] Update policies

## 🔧 Technical Context
**ML Platform**: Vertex AI
**Vector Search**: Matching Engine
**Serving**: Private endpoints
**Monitoring**: Tensorboard

## 💡 Implementation Notes
\`\`\`hcl
# Matching Engine Index
resource \"google_vertex_ai_index\" \"embeddings\" {
  display_name = var.index_name
  region       = var.region
  
  metadata {
    contents_delta_uri = var.gcs_bucket
    config {
      dimensions                  = 768
      approximate_neighbors_count = 100
      shard_size                 = \"SHARD_SIZE_MEDIUM\"
      distance_measure_type      = \"COSINE_DISTANCE\"
      algorithm_config {
        tree_ah_config {
          leaf_node_embedding_count = 1000
          leaf_nodes_to_search_percent = 10
        }
      }
    }
  }
}

# Model Endpoint
resource \"google_vertex_ai_endpoint\" \"model\" {
  display_name = var.endpoint_name
  region       = var.region
  
  network = var.network_id
  
  encryption_spec {
    kms_key_name = var.kms_key
  }
}
\`\`\`

## 📚 Resources
- [Vertex AI Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vertex_ai_endpoint)
- [Matching Engine](https://cloud.google.com/vertex-ai/docs/matching-engine/overview)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "ml" \
  --label "P1-high"

echo "✓ T169 created"

# T170: VPC and Networking Terraform
gh issue create \
  --title "T170: Terraform module for VPC and networking" \
  --body "# Task T170: Terraform module for VPC and networking

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / Networking
**File Path**: \`terraform/modules/networking/\`
**Dependencies**: T165
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **network engineer**, I want Terraform modules for VPC and networking so that network infrastructure is provisioned with security and scalability best practices.

## ✅ Acceptance Criteria
### VPC Configuration
- [ ] Custom VPC creation
- [ ] Subnet design for each tier
- [ ] Secondary ranges for GKE
- [ ] Private service connections
- [ ] Cloud NAT configuration

### Security
- [ ] Firewall rules (least privilege)
- [ ] Cloud Armor policies
- [ ] Private Google Access
- [ ] VPC Flow Logs
- [ ] Network segmentation

### Load Balancing
- [ ] Global HTTPS load balancer
- [ ] SSL certificates
- [ ] CDN configuration
- [ ] Backend services
- [ ] Health checks

## 🔧 Technical Context
**VPC Mode**: Custom
**Subnets**: Regional
**Routing**: Dynamic
**Security**: Zero-trust principles

## 💡 Implementation Notes
\`\`\`hcl
module \"vpc\" {
  source = \"terraform-google-modules/network/google\"
  
  project_id   = var.project_id
  network_name = \"kaizen-vpc\"
  
  subnets = [
    {
      subnet_name           = \"gke-subnet\"
      subnet_ip            = \"10.0.0.0/20\"
      subnet_region        = var.region
      subnet_private_access = true
      subnet_flow_logs     = true
    },
    {
      subnet_name   = \"services-subnet\"
      subnet_ip     = \"10.0.16.0/20\"
      subnet_region = var.region
    }
  ]
  
  secondary_ranges = {
    gke-subnet = [
      {
        range_name    = \"pods\"
        ip_cidr_range = \"10.1.0.0/16\"
      },
      {
        range_name    = \"services\"
        ip_cidr_range = \"10.2.0.0/16\"
      }
    ]
  }
}
\`\`\`

## 📚 Resources
- [VPC Terraform Module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest)
- [GCP Networking Best Practices](https://cloud.google.com/architecture/best-practices-vpc-design)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "networking" \
  --label "P0-critical"

echo "✓ T170 created"

# T171: IAM and Security Terraform
gh issue create \
  --title "T171: Terraform module for IAM and security" \
  --body "# Task T171: Terraform module for IAM and security

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / IAM
**File Path**: \`terraform/modules/iam/\`
**Dependencies**: T165
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **security engineer**, I want Terraform modules for IAM and security so that access control and security policies are managed as code with least-privilege principles.

## ✅ Acceptance Criteria
### IAM Configuration
- [ ] Service account creation
- [ ] Workload Identity bindings
- [ ] Custom roles definition
- [ ] IAM policy bindings
- [ ] Organization policies

### Security
- [ ] KMS key management
- [ ] Secret Manager setup
- [ ] Binary Authorization policies
- [ ] Security Command Center
- [ ] VPC Service Controls

### Compliance
- [ ] Audit logging configuration
- [ ] Data residency controls
- [ ] Access transparency
- [ ] Resource hierarchy
- [ ] Policy constraints

## 🔧 Technical Context
**Principle**: Least privilege
**Authentication**: Workload Identity
**Secrets**: Secret Manager
**Encryption**: Customer-managed keys

## 💡 Implementation Notes
\`\`\`hcl
# Service Account with Workload Identity
resource \"google_service_account\" \"microservice\" {
  account_id   = var.service_name
  display_name = \"Service Account for \${var.service_name}\"
}

resource \"google_service_account_iam_member\" \"workload_identity\" {
  service_account_id = google_service_account.microservice.name
  role              = \"roles/iam.workloadIdentityUser\"
  member            = \"serviceAccount:\${var.project_id}.svc.id.goog[\${var.namespace}/\${var.ksa_name}]\"
}

# Custom Role
resource \"google_project_iam_custom_role\" \"microservice_role\" {
  role_id     = \"\${var.service_name}_role\"
  title       = \"Custom role for \${var.service_name}\"
  permissions = var.permissions
}
\`\`\`

## 📚 Resources
- [IAM Best Practices](https://cloud.google.com/iam/docs/best-practices)
- [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "security" \
  --label "P0-critical"

echo "✓ T171 created"

# T172: Monitoring and Logging Terraform
gh issue create \
  --title "T172: Terraform module for monitoring and logging" \
  --body "# Task T172: Terraform module for monitoring and logging

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / Monitoring
**File Path**: \`terraform/modules/monitoring/\`
**Dependencies**: T165
**Priority**: P1 - High
**Effort**: 5 story points

## 👤 User Story
As a **SRE**, I want Terraform modules for monitoring and logging so that observability infrastructure is provisioned with dashboards, alerts, and log aggregation.

## ✅ Acceptance Criteria
### Monitoring Setup
- [ ] Cloud Monitoring workspace
- [ ] Custom dashboards
- [ ] Alerting policies
- [ ] Uptime checks
- [ ] SLO definitions

### Logging Configuration
- [ ] Log sinks to BigQuery
- [ ] Log-based metrics
- [ ] Log retention policies
- [ ] Exclusion filters
- [ ] Log routing

### Tracing
- [ ] Cloud Trace configuration
- [ ] Error Reporting setup
- [ ] APM integration
- [ ] Custom metrics
- [ ] Profiler setup

## 🔧 Technical Context
**Monitoring**: Cloud Operations Suite
**Storage**: BigQuery for logs
**Alerting**: PagerDuty integration
**Dashboards**: Terraform-managed

## 💡 Implementation Notes
\`\`\`hcl
# Alert Policy
resource \"google_monitoring_alert_policy\" \"api_latency\" {
  display_name = \"API Latency Alert\"
  
  conditions {
    display_name = \"API latency > 500ms\"
    
    condition_threshold {
      filter          = \"metric.type=\\\"custom.googleapis.com/api/latency\\\"\"
      duration        = \"60s\"
      comparison      = \"COMPARISON_GT\"
      threshold_value = 0.5
      
      aggregations {
        alignment_period   = \"60s\"
        per_series_aligner = \"ALIGN_RATE\"
      }
    }
  }
  
  notification_channels = [var.notification_channel_id]
}

# Log Sink to BigQuery
resource \"google_logging_project_sink\" \"bigquery\" {
  name        = \"bigquery-sink\"
  destination = \"bigquery.googleapis.com/projects/\${var.project_id}/datasets/\${var.dataset_id}\"
  
  filter = \"severity >= WARNING\"
  
  unique_writer_identity = true
}
\`\`\`

## 📚 Resources
- [Cloud Monitoring Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy)
- [SRE Workbook](https://sre.google/workbook/table-of-contents/)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "monitoring" \
  --label "P1-high"

echo "✓ T172 created"

# T173: Cloud Build CI/CD Terraform
gh issue create \
  --title "T173: Terraform module for Cloud Build CI/CD" \
  --body "# Task T173: Terraform module for Cloud Build CI/CD

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / CI/CD
**File Path**: \`terraform/modules/cloud-build/\`
**Dependencies**: T165
**Priority**: P1 - High
**Effort**: 5 story points

## 👤 User Story
As a **DevOps engineer**, I want Terraform modules for Cloud Build so that CI/CD pipelines are managed as code with proper triggers and deployments.

## ✅ Acceptance Criteria
### Cloud Build Configuration
- [ ] Build triggers for GitHub
- [ ] Build configurations
- [ ] Worker pool setup
- [ ] Artifact Registry repos
- [ ] Deploy to GKE

### Pipeline Setup
- [ ] PR validation builds
- [ ] Main branch deployments
- [ ] Tag-based releases
- [ ] Rollback procedures
- [ ] Multi-environment deploys

### Security
- [ ] Secret Manager integration
- [ ] Vulnerability scanning
- [ ] Binary Authorization
- [ ] SLSA compliance
- [ ] Supply chain security

## 🔧 Technical Context
**CI/CD**: Cloud Build
**Registry**: Artifact Registry
**Deployment**: GKE with kubectl
**Security**: Binary Authorization

## 💡 Implementation Notes
\`\`\`hcl
# Build Trigger
resource \"google_cloudbuild_trigger\" \"main\" {
  name     = \"deploy-main\"
  location = var.region
  
  github {
    owner = \"wunderkennd\"
    name  = \"kaizen-web\"
    push {
      branch = \"^main$\"
    }
  }
  
  build {
    step {
      name = \"gcr.io/cloud-builders/docker\"
      args = [\"build\", \"-t\", \"gcr.io/\$PROJECT_ID/\${var.service_name}:\$COMMIT_SHA\", \".\"]
    }
    
    step {
      name = \"gcr.io/cloud-builders/docker\"
      args = [\"push\", \"gcr.io/\$PROJECT_ID/\${var.service_name}:\$COMMIT_SHA\"]
    }
    
    step {
      name = \"gcr.io/cloud-builders/gke-deploy\"
      args = [
        \"run\",
        \"--filename=k8s/\",
        \"--image=gcr.io/\$PROJECT_ID/\${var.service_name}:\$COMMIT_SHA\",
        \"--cluster=\${var.cluster_name}\",
        \"--location=\${var.region}\"
      ]
    }
  }
}
\`\`\`

## 📚 Resources
- [Cloud Build Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger)
- [Cloud Build Best Practices](https://cloud.google.com/build/docs/best-practices)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "cicd" \
  --label "P1-high"

echo "✓ T173 created"

# T174: Terraform environments configuration
gh issue create \
  --title "T174: Terraform environment configurations (dev/staging/prod)" \
  --body "# Task T174: Terraform environment configurations

## 📋 Overview
**Category**: Infrastructure as Code
**Component**: Terraform / Environments
**File Path**: \`terraform/environments/\`
**Dependencies**: T165-T173
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **DevOps engineer**, I want separate Terraform configurations for each environment so that infrastructure can be promoted through dev, staging, and production safely.

## ✅ Acceptance Criteria
### Environment Setup
- [ ] Dev environment configuration
- [ ] Staging environment configuration
- [ ] Production environment configuration
- [ ] Environment-specific variables
- [ ] Resource sizing per environment

### Promotion Process
- [ ] Environment promotion scripts
- [ ] Plan validation gates
- [ ] Approval workflows
- [ ] Rollback procedures
- [ ] State management per env

### Cost Optimization
- [ ] Dev: Minimal resources
- [ ] Staging: Production-like
- [ ] Prod: Full HA and scaling
- [ ] Auto-shutdown for dev
- [ ] Resource tagging

## 🔧 Technical Context
**Workspaces**: Terraform workspaces
**State**: Separate per environment
**Variables**: tfvars per environment
**Promotion**: GitOps workflow

## 💡 Implementation Notes
\`\`\`hcl
# terraform/environments/dev/terraform.tfvars
project_id  = \"kaizen-dev\"
environment = \"dev\"
region      = \"us-central1\"

# Smaller resources for dev
gke_machine_type = \"e2-standard-2\"
cloud_sql_tier   = \"db-f1-micro\"
redis_memory_gb  = 1

# terraform/environments/prod/terraform.tfvars
project_id  = \"kaizen-prod\"
environment = \"prod\"
region      = \"us-central1\"

# Production-grade resources
gke_machine_type = \"n2-standard-4\"
cloud_sql_tier   = \"db-n1-standard-4\"
redis_memory_gb  = 10

# HA configuration
cloud_sql_ha = true
gke_regions  = [\"us-central1\", \"us-east1\"]
\`\`\`

## 📚 Resources
- [Terraform Workspaces](https://www.terraform.io/docs/state/workspaces.html)
- [Environment Promotion](https://cloud.google.com/architecture/framework/operational-excellence/release-engineering)

---
*KAIZEN Adaptive Platform - Infrastructure as Code*" \
  --label "infrastructure" \
  --label "terraform" \
  --label "environments" \
  --label "P0-critical"

echo "✓ T174 created"

echo ""
echo "========================================="
echo "GCP Terraform Infrastructure Tickets Created!"
echo ""
echo "Created 10 new tickets (T165-T174):"
echo "- T165: Terraform base configuration"
echo "- T166: GKE Autopilot module"
echo "- T167: Cloud SQL module"
echo "- T168: Memorystore Redis module"
echo "- T169: Vertex AI module"
echo "- T170: VPC and networking module"
echo "- T171: IAM and security module"
echo "- T172: Monitoring and logging module"
echo "- T173: Cloud Build CI/CD module"
echo "- T174: Environment configurations"
echo ""
echo "Priority:"
echo "- P0 Critical: T165, T166, T167, T168, T170, T171, T174"
echo "- P1 High: T169, T172, T173"
echo ""
echo "Total estimated effort: 59 story points"
echo "========================================="