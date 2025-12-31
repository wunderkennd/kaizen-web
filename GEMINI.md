# KAIZEN Adaptive Platform - Project Context

## Project Overview
**KAIZEN** is an intelligent, context-aware platform designed to dynamically generate personalized user interfaces given a user's real-time behavior and their stage in the **Psychological Continuum Model (PCM)**.

### Core Philosophy
- **Dynamic UI**: Interfaces are not static; they are encoded in the `genui-orchestrator` and rendered by the frontend based on rules.
- **PCM Integration**: Users move through Awareness → Attraction → Attachment → Allegiance. The UI adapts to deepen this relationship.
- **Polyglot Services**: We use the right tool for the job (Rust for rules/perf, Python for ML, Go for orchestration).

## Architecture & Tech Stack

### High-Level
- **Frontend**: Next.js 14 (App Router) + React. Serves as the rendering head.
- **API Gateway**: GraphQL & WebSocket interfaces.
- **Microservices**:
  - `genui-orchestrator` (Go): The brain. Decides *what* UI components to show.
  - `kre-engine` (Rust): "Kaizen Rule Engine". High-performance rule evaluation.
  - `ai-sommelier` (Python): Recommendation engine (Anime/Content).
  - `user-context` (Go): Manages user state and preferences.
  - `streaming-adapter` (Rust): Handles real-time SSE/WebSocket data piping.
- **Data Stores**:
  - PostgreSQL (Primary Data)
  - Redis (Hot Cache / PubSub)
  - Pinecone (Vector DB for Recommendations)

### Infrastructure
- **Containerization**: Docker & Docker Compose (dev).
- **Orchestration**: Kubernetes (prod/staging).
- **Analytics**: PostHog (integrated across full stack).

## Repository Structure

```text
├── frontend/               # Next.js 14 Web App
│   ├── src/components/     
│   │   └── kds/            # Kaizen Design System (Moved from packages)
│   └── src/features/       # Business Logic Modules
├── services/               # Microservices
│   ├── genui-orchestrator/ # (Go) UI Logic
│   ├── kre-engine/         # (Rust) Rule Engine
│   ├── ai-sommelier/       # (Python) ML/Recs
│   ├── user-context/       # (Go) User State
│   ├── ...                 # (Other services: pcm-classifier, streaming-adapter, etc.)
├── packages/               # Shared libraries (Language Specific)
│   ├── go-shared/          # Go common libs
│   ├── python-shared/      # Python common libs
│   └── rust-shared/        # Rust common libs
├── shared/                 # Protocol Definitions
│   ├── contracts/          # OpenAPI / GraphQL Schemas
│   └── protos/             # gRPC Protobufs
├── k8s/                    # Kubernetes Manifests
└── scripts/                # Utility scripts
```

## Developer Workflow

### Quick Start
1. **Infra Up**: `docker-compose up -d` (Starts DBs, Redis, PostHog).
2. **Frontend**: `cd frontend && npm run dev`.
3. **Services**: Can be run via Docker or individually (e.g., `go run .` or `cargo run`).

### Testing Strategy
- **Unit**: Service-specific (Jest, Go Test, Cargo Test, Pytest).
- **Contract**: **Critical**. We use contract tests to enforce API boundaries before implementation.
  - Run: `npm run test:contracts`.
- **E2E**: Playwright (in `frontend/tests`).

### Conventions
- **Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`).
- **Schema First**: GraphQL and Protobuf definitions in `packages/contracts` drive implementation.

## Current Priorities (as of Dec 2025)
1. **PostHog Integration**: Validating analytics flow across all services.
2. **Contract Testing**: Ensuring robust interfaces between Core Services.
3. **Core Implementation**: Building out `User Context` and `GenUI Orchestrator`.

## Key Files for AI Context
- `README.md`: General user-facing info.
- `NEXT_STEPS.md`: Detailed granular task list & status.
- `PROJECT_SETUP.md`: Comprehensive environment setup guide.
- `docker-compose.yml`: Definition of the service mesh.
