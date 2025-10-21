#!/bin/bash

# Create comprehensive CI/CD tickets for KAIZEN platform
echo "Creating Critical CI/CD Tickets..."

# T175: GitHub Actions Base Workflows
gh issue create \
  --title "T175: GitHub Actions base workflows for CI/CD" \
  --body "# Task T175: GitHub Actions base workflows for CI/CD

## 📋 Overview
**Category**: CI/CD
**Component**: GitHub Actions
**File Path**: \`.github/workflows/\`
**Dependencies**: None
**Priority**: P0 - Critical
**Effort**: 8 story points

## 👤 User Story
As a **DevOps engineer**, I want comprehensive GitHub Actions workflows so that code is automatically tested, built, and validated on every commit.

## ✅ Acceptance Criteria
### PR Validation Workflow
- [ ] Triggers on pull request events
- [ ] Runs all unit tests
- [ ] Checks code formatting
- [ ] Runs linting for all languages
- [ ] Generates test coverage reports
- [ ] Posts results as PR comment

### Main Branch CI
- [ ] Triggers on push to main
- [ ] Builds all services
- [ ] Runs integration tests
- [ ] Builds Docker images
- [ ] Pushes to registry
- [ ] Triggers deployment to staging

### Quality Gates
- [ ] Minimum 80% test coverage
- [ ] All tests must pass
- [ ] No critical security issues
- [ ] Build time < 15 minutes
- [ ] Status checks required for merge

## 🔧 Technical Context
**Languages**: TypeScript, Go, Rust, Python
**Test Runners**: Jest, go test, cargo test, pytest
**Container Registry**: GitHub Container Registry
**Caching**: Actions cache for dependencies

## 💡 Implementation Notes
\`\`\`yaml
# .github/workflows/pr-validation.yml
name: PR Validation
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run lint
      - run: npm run test:coverage
      - uses: codecov/codecov-action@v3
      
  go-services:
    strategy:
      matrix:
        service: [genui-orchestrator, user-context]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - run: cd services/\${{ matrix.service }} && go test ./...
\`\`\`

## 📚 Resources
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Actions Best Practices](https://docs.github.com/en/actions/guides)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cicd" \
  --label "P0-critical"

echo "✓ T175 created"

# T176: Docker Build Optimization
gh issue create \
  --title "T176: Docker multi-stage builds for all services" \
  --body "# Task T176: Docker multi-stage builds for all services

## 📋 Overview
**Category**: CI/CD
**Component**: Docker
**File Path**: \`services/*/Dockerfile\`
**Dependencies**: None
**Priority**: P0 - Critical
**Effort**: 8 story points

## 👤 User Story
As a **DevOps engineer**, I want optimized Docker builds for all services so that images are small, secure, and build quickly with proper caching.

## ✅ Acceptance Criteria
### Dockerfile Standards
- [ ] Multi-stage builds for all services
- [ ] Minimal base images (distroless/alpine)
- [ ] Non-root user execution
- [ ] Layer caching optimization
- [ ] Build ARGs for versioning
- [ ] Health check definitions

### Service-Specific
- [ ] Frontend: Node.js with static export
- [ ] Go services: Binary-only final stage
- [ ] Rust services: Binary-only final stage
- [ ] Python services: Minimal runtime
- [ ] Consistent labeling schema

### Security
- [ ] No secrets in images
- [ ] Vulnerability scanning passes
- [ ] SBOM generation
- [ ] Signed images
- [ ] Minimal attack surface

## 🔧 Technical Context
**Base Images**: 
- Go: gcr.io/distroless/static
- Rust: gcr.io/distroless/cc
- Python: python:3.11-slim
- Node: node:18-alpine

## 💡 Implementation Notes
\`\`\`dockerfile
# Go Service Example
FROM golang:1.21 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o server

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /app/server /
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/server"]

# Rust Service Example  
FROM rust:1.70 AS builder
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN cargo fetch
COPY . .
RUN cargo build --release

FROM gcr.io/distroless/cc
COPY --from=builder /app/target/release/app /
EXPOSE 8080
ENTRYPOINT ["/app"]
\`\`\`

## 📚 Resources
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Distroless Images](https://github.com/GoogleContainerTools/distroless)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cicd" \
  --label "docker" \
  --label "P0-critical"

echo "✓ T176 created"

# T177: ArgoCD GitOps Setup
gh issue create \
  --title "T177: ArgoCD GitOps setup for Kubernetes deployments" \
  --body "# Task T177: ArgoCD GitOps setup for Kubernetes deployments

## 📋 Overview
**Category**: CI/CD
**Component**: GitOps
**File Path**: \`argocd/\`
**Dependencies**: T166 (GKE)
**Priority**: P0 - Critical
**Effort**: 8 story points

## 👤 User Story
As a **DevOps engineer**, I want GitOps with ArgoCD so that all deployments are declarative, auditable, and can be easily rolled back.

## ✅ Acceptance Criteria
### ArgoCD Installation
- [ ] ArgoCD installed on GKE
- [ ] Ingress configured with SSL
- [ ] RBAC configured
- [ ] GitHub SSO integration
- [ ] Webhook for auto-sync

### Application Configuration
- [ ] App-of-apps pattern
- [ ] Environment separation
- [ ] Sync policies defined
- [ ] Health checks configured
- [ ] Notifications setup

### GitOps Structure
- [ ] Manifest repository structure
- [ ] Kustomize overlays per env
- [ ] Sealed secrets integration
- [ ] Progressive sync
- [ ] Rollback procedures

## 🔧 Technical Context
**Tool**: ArgoCD 2.8+
**Pattern**: App-of-apps
**Structure**: Kustomize
**Secrets**: Sealed Secrets
**Sync**: Automated with manual override

## 💡 Implementation Notes
\`\`\`yaml
# argocd/applications/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base
  
patchesStrategicMerge:
  - deployment-patch.yaml
  
configMapGenerator:
  - name: app-config
    literals:
      - ENV=production
      
images:
  - name: genui-orchestrator
    newTag: v1.2.3

# argocd/apps/root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/wunderkennd/kaizen-web
    targetRevision: main
    path: argocd/applications/production
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
\`\`\`

## 📚 Resources
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Best Practices](https://www.weave.works/technologies/gitops/)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cicd" \
  --label "gitops" \
  --label "P0-critical"

echo "✓ T177 created"

# T178: Container Security Scanning
gh issue create \
  --title "T178: Container security scanning pipeline" \
  --body "# Task T178: Container security scanning pipeline

## 📋 Overview
**Category**: CI/CD Security
**Component**: Security Scanning
**File Path**: \`.github/workflows/security.yml\`
**Dependencies**: T175, T176
**Priority**: P0 - Critical
**Effort**: 5 story points

## 👤 User Story
As a **security engineer**, I want automated container scanning so that vulnerabilities are detected before deployment.

## ✅ Acceptance Criteria
### Scanning Coverage
- [ ] Image vulnerability scanning
- [ ] SAST for source code
- [ ] Dependency scanning
- [ ] Secret detection
- [ ] License compliance
- [ ] SBOM generation

### Tools Integration
- [ ] Trivy for containers
- [ ] Snyk for dependencies
- [ ] GitLeaks for secrets
- [ ] OWASP dependency check
- [ ] Automated fixes for patches

### Policies
- [ ] Block critical vulnerabilities
- [ ] Alert on high severity
- [ ] Daily scanning of prod images
- [ ] Compliance reports
- [ ] Security dashboard

## 🔧 Technical Context
**Scanner**: Trivy, Snyk
**SAST**: SonarQube
**Secrets**: GitLeaks
**Policy**: OPA for policy as code

## 💡 Implementation Notes
\`\`\`yaml
# .github/workflows/security.yml
name: Security Scanning
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      - uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
          
  container-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Scan Docker image
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '\${{ env.IMAGE_NAME }}:\${{ github.sha }}'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'
\`\`\`

## 📚 Resources
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Supply Chain Security](https://slsa.dev/)

---
*KAIZEN Adaptive Platform - CI/CD Security*" \
  --label "cicd" \
  --label "security" \
  --label "P0-critical"

echo "✓ T178 created"

# T179: Progressive Delivery
gh issue create \
  --title "T179: Progressive delivery with canary deployments" \
  --body "# Task T179: Progressive delivery with canary deployments

## 📋 Overview
**Category**: CI/CD
**Component**: Deployment Strategy
**File Path**: \`k8s/canary/\`
**Dependencies**: T177 (ArgoCD)
**Priority**: P1 - High
**Effort**: 8 story points

## 👤 User Story
As a **platform engineer**, I want progressive delivery with canary deployments so that new versions are safely rolled out with automatic rollback on failures.

## ✅ Acceptance Criteria
### Canary Configuration
- [ ] Flagger installation
- [ ] Canary CRDs defined
- [ ] Traffic splitting rules
- [ ] Metric-based promotion
- [ ] Automatic rollback

### Deployment Strategy
- [ ] 10% → 30% → 50% → 100% progression
- [ ] Success metrics defined
- [ ] Error rate thresholds
- [ ] Latency thresholds
- [ ] Custom business metrics

### Observability
- [ ] Canary metrics dashboard
- [ ] Alerting on failures
- [ ] Deployment tracking
- [ ] A/B comparison views
- [ ] Rollback analytics

## 🔧 Technical Context
**Tool**: Flagger
**Mesh**: Istio (optional)
**Metrics**: Prometheus
**Progression**: Automated
**Rollback**: Automatic on failure

## 💡 Implementation Notes
\`\`\`yaml
# k8s/canary/genui-canary.yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: genui-orchestrator
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: genui-orchestrator
  progressDeadlineSeconds: 600
  service:
    port: 8080
    targetPort: 8080
    gateways:
    - public-gateway.istio-system.svc.cluster.local
    hosts:
    - api.kaizen.app
  analysis:
    interval: 30s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
      interval: 30s
    - name: request-duration
      thresholdRange:
        max: 500
      interval: 30s
    webhooks:
    - name: acceptance-test
      url: http://flagger-loadtester.test/
      timeout: 30s
      metadata:
        type: bash
        cmd: \"curl -sd 'test' http://genui-canary:8080/health\"
\`\`\`

## 📚 Resources
- [Flagger Documentation](https://flagger.app/)
- [Progressive Delivery](https://www.weave.works/blog/progressive-delivery-with-flagger)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cicd" \
  --label "deployment" \
  --label "P1-high"

echo "✓ T179 created"

# T180: CI/CD Observability
gh issue create \
  --title "T180: CI/CD observability and DORA metrics" \
  --body "# Task T180: CI/CD observability and DORA metrics

## 📋 Overview
**Category**: CI/CD
**Component**: Observability
**File Path**: \`monitoring/cicd/\`
**Dependencies**: T172 (Monitoring)
**Priority**: P1 - High
**Effort**: 5 story points

## 👤 User Story
As a **engineering manager**, I want CI/CD observability with DORA metrics so that we can measure and improve our delivery performance.

## ✅ Acceptance Criteria
### DORA Metrics
- [ ] Deployment Frequency tracking
- [ ] Lead Time for Changes
- [ ] Mean Time to Recovery
- [ ] Change Failure Rate
- [ ] Custom team metrics

### Dashboards
- [ ] Build performance dashboard
- [ ] Deployment dashboard
- [ ] Test metrics dashboard
- [ ] Security scan results
- [ ] Cost tracking

### Alerting
- [ ] Build failure alerts
- [ ] Deployment failure alerts
- [ ] Performance regression alerts
- [ ] Security vulnerability alerts
- [ ] SLA violation alerts

## 🔧 Technical Context
**Metrics**: Prometheus
**Dashboards**: Grafana
**DORA**: Four Keys metrics
**Storage**: BigQuery
**Alerting**: PagerDuty

## 💡 Implementation Notes
\`\`\`yaml
# Grafana Dashboard JSON snippet
{
  \"dashboard\": {
    \"title\": \"DORA Metrics\",
    \"panels\": [
      {
        \"title\": \"Deployment Frequency\",
        \"targets\": [
          {
            \"expr\": \"rate(deployments_total[7d])\"
          }
        ]
      },
      {
        \"title\": \"Lead Time for Changes\",
        \"targets\": [
          {
            \"expr\": \"histogram_quantile(0.5, commit_to_deploy_duration_seconds)\"
          }
        ]
      },
      {
        \"title\": \"Change Failure Rate\",
        \"targets\": [
          {
            \"expr\": \"rate(deployment_failures[7d]) / rate(deployments_total[7d])\"
          }
        ]
      }
    ]
  }
}
\`\`\`

## 📚 Resources
- [DORA Metrics](https://www.devops-research.com/research.html)
- [Four Keys](https://github.com/GoogleCloudPlatform/fourkeys)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cicd" \
  --label "observability" \
  --label "P1-high"

echo "✓ T180 created"

# T181: Release Automation
gh issue create \
  --title "T181: Semantic release automation" \
  --body "# Task T181: Semantic release automation

## 📋 Overview
**Category**: CI/CD
**Component**: Release Management
**File Path**: \`.github/workflows/release.yml\`
**Dependencies**: T175
**Priority**: P2 - Medium
**Effort**: 5 story points

## 👤 User Story
As a **developer**, I want automated semantic versioning and release notes so that releases are consistent and well-documented.

## ✅ Acceptance Criteria
### Release Process
- [ ] Semantic versioning (semver)
- [ ] Automatic version bumping
- [ ] CHANGELOG generation
- [ ] Release notes creation
- [ ] Git tag creation
- [ ] GitHub Release publishing

### Commit Standards
- [ ] Conventional commits enforced
- [ ] Commit message validation
- [ ] Breaking change detection
- [ ] Automatic PR titles
- [ ] Commit hooks setup

### Automation
- [ ] Release on main merge
- [ ] Multi-package releases
- [ ] NPM publishing (if needed)
- [ ] Docker tag alignment
- [ ] Notification on release

## 🔧 Technical Context
**Tool**: semantic-release
**Format**: Conventional Commits
**Changelog**: Keep a Changelog
**Versioning**: SemVer 2.0

## 💡 Implementation Notes
\`\`\`yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx semantic-release
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}

# .releaserc.json
{
  \"branches\": [\"main\"],
  \"plugins\": [
    \"@semantic-release/commit-analyzer\",
    \"@semantic-release/release-notes-generator\",
    \"@semantic-release/changelog\",
    \"@semantic-release/github\",
    [\"@semantic-release/git\", {
      \"assets\": [\"CHANGELOG.md\"],
      \"message\": \"chore(release): \${nextRelease.version} [skip ci]\"
    }]
  ]
}
\`\`\`

## 📚 Resources
- [Semantic Release](https://semantic-release.gitbook.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cicd" \
  --label "release" \
  --label "P2-medium"

echo "✓ T181 created"

# T182: PR Preview Environments
gh issue create \
  --title "T182: Pull request preview environments" \
  --body "# Task T182: Pull request preview environments

## 📋 Overview
**Category**: CI/CD
**Component**: Developer Experience
**File Path**: \`.github/workflows/preview.yml\`
**Dependencies**: T175, T177
**Priority**: P2 - Medium
**Effort**: 8 story points

## 👤 User Story
As a **developer**, I want preview environments for pull requests so that changes can be tested in isolation before merging.

## ✅ Acceptance Criteria
### Preview Environment
- [ ] Automatic creation on PR
- [ ] Unique URL per PR
- [ ] Full stack deployment
- [ ] Database seeding
- [ ] Automatic cleanup on merge

### Features
- [ ] Frontend preview
- [ ] API endpoints accessible
- [ ] Test data loaded
- [ ] SSL certificates
- [ ] Comments with URLs

### Management
- [ ] Resource limits
- [ ] Auto-cleanup after 7 days
- [ ] Manual refresh option
- [ ] Cost tracking
- [ ] Access control

## 🔧 Technical Context
**Platform**: GKE with namespaces
**Ingress**: Dynamic subdomain
**Database**: Ephemeral instances
**Cleanup**: CronJob

## 💡 Implementation Notes
\`\`\`yaml
# .github/workflows/preview.yml
name: Preview Environment
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  deploy-preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to preview
        run: |
          NAMESPACE=\"pr-\${{ github.event.number }}\"
          kubectl create namespace \$NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
          helm upgrade --install preview ./helm/kaizen \\
            --namespace \$NAMESPACE \\
            --set ingress.host=\"pr-\${{ github.event.number }}.preview.kaizen.app\" \\
            --set image.tag=\"pr-\${{ github.event.number }}\"
      - uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '🚀 Preview environment deployed: https://pr-' + context.issue.number + '.preview.kaizen.app'
            })
\`\`\`

## 📚 Resources
- [Preview Environments](https://docs.gitlab.com/ee/ci/review_apps/)
- [Ephemeral Environments](https://www.getambassador.io/docs/telepresence/latest/concepts/devenv/)

---
*KAIZEN Adaptive Platform - CI/CD*" \
  --label "cicd" \
  --label "dx" \
  --label "P2-medium"

echo "✓ T182 created"

echo ""
echo "========================================="
echo "Critical CI/CD Tickets Created!"
echo ""
echo "Created 8 comprehensive CI/CD tickets (T175-T182):"
echo "- T175: GitHub Actions base workflows (P0)"
echo "- T176: Docker multi-stage builds (P0)"
echo "- T177: ArgoCD GitOps setup (P0)"
echo "- T178: Container security scanning (P0)"
echo "- T179: Progressive delivery/canary (P1)"
echo "- T180: CI/CD observability & DORA (P1)"
echo "- T181: Semantic release automation (P2)"
echo "- T182: PR preview environments (P2)"
echo ""
echo "Priority Breakdown:"
echo "- P0 Critical: T175, T176, T177, T178 (28 points)"
echo "- P1 High: T179, T180 (13 points)"
echo "- P2 Medium: T181, T182 (13 points)"
echo ""
echo "Total effort: 54 story points"
echo ""
echo "These tickets provide complete CI/CD coverage for:"
echo "✅ Automated testing and validation"
echo "✅ Secure container builds"
echo "✅ GitOps deployments"
echo "✅ Progressive delivery"
echo "✅ Security scanning"
echo "✅ Observability and metrics"
echo "✅ Developer experience"
echo "========================================="