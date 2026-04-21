# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

KAIZEN is an adaptive, context-aware platform that generates personalized UIs in real time. It is organized as a polyglot monorepo containing a Next.js frontend and eight backend microservices written in Go, Rust, and Python. All services share a common PostHog-backed analytics layer and communicate via GraphQL, gRPC (protobuf), and WebSockets.

Two domain concepts show up throughout the code and docs:

- **PCM (Psychological Continuum Model)** — users are classified into four stages (`Awareness → Attraction → Attachment → Allegiance`). The PCM stage is both tracked (PostHog, `kaizen_analytics.PCMStage`) and used by the KRE/GenUI services to adapt the UI. New analytics tracking functions should accept a PCM stage.
- **KRE (Kaizen Rule Engine) + GenUI Orchestrator** — the Rust-based rule engine evaluates adaptation rules (<50ms target) and the Go orchestrator composes UI responses based on those rules plus user context.

Current implementation state (as of this writing) is important: most `services/*` directories are **scaffolded but not implemented** — they contain only an `analytics.{go,rs,py}` or a few provider/hook files plus the PostHog integration. Infra (Docker Compose, migrations, CI) and the shared PostHog packages are the only completed pieces. When asked to "add a feature", verify that the parent service's business logic exists before assuming you can edit it.

## Repository Layout

```
services/                Microservices (mostly scaffolds + analytics.*)
├── frontend/            Next.js 14 app (src/providers + src/hooks only so far)
├── genui-orchestrator/  Go - UI generation orchestrator
├── kre-engine/          Rust - rule evaluation engine
├── user-context/        Go - user/PCM context store
├── ai-sommelier/        Python - ML recommendations
├── pcm-classifier/      Python - PCM stage classifier
├── streaming-adapter/   Rust - WebSocket/SSE fan-out
├── experiment-service/  Go - A/B testing
└── bandit-service/      Python - multi-armed bandits

packages/                Shared libraries, all PostHog clients today
├── go-shared/           `github.com/wunderkennd/kaizen-web/packages/go-shared`
├── python-shared/       installable as `kaizen-analytics` (pip install -e .)
└── rust-shared/         `kaizen-shared` crate

shared/
├── contracts/openapi/   OpenAPI definitions (source of truth for REST)
└── protos/              Protobuf definitions (source of truth for gRPC)

specs/                   Spec-Kit specs; each has spec.md, data-model.md, tasks.md
├── 001-adaptive-platform/
├── 002-ab-testing/
└── 003-multivariate-experiments/

scripts/db/              migrate.sh + up/down migrations + seed data
scripts/protos/          generate-{go,rust,python}.sh for protobuf codegen
scripts/docker/          start-dev.sh / stop-dev.sh / reset-dev.sh
```

Note the discrepancy between `services/user-context/` (on disk) and `services/user-context-service/` (referenced by `docker-compose.yml`, CI matrix, and some scripts); same for `ai-sommelier` vs `ai-sommelier-service`. Compose builds will fail until these are reconciled.

## Commands

Tests are split across language toolchains; the npm scripts orchestrate them:

```bash
# All JS/TS Jest tests (roots: services/, packages/, tests/)
npm test
npm run test:watch
npm run test:coverage

# Per-language test runners
npm run test:go       # cd packages/go-shared && go test ./...
npm run test:rust     # cd packages/rust-shared && cargo test
npm run test:python   # cd packages/python-shared && python -m pytest tests/
npm run test:all      # go + rust + python + jest
npm run test:posthog  # same as test:all but filters jest to posthog tests

# Single Jest test
npx jest path/to/file.test.ts
npx jest -t "test name pattern"

# Single Go test (from a Go module root, e.g. packages/go-shared)
go test ./posthog -run TestName

# Single Rust test (from a Rust crate root)
cargo test test_name

# Single Python test (from packages/python-shared)
pytest tests/test_file.py::TestClass::test_name

# Lint/format (root repo: TS/JS only)
npm run lint
npm run lint:fix
npm run format
```

Dev environment is Docker-first via the Makefile:

```bash
make dev              # ./scripts/docker/start-dev.sh
make stop             # ./scripts/docker/stop-dev.sh
make clean            # ./scripts/docker/reset-dev.sh (wipes volumes)
make docker-up        # docker-compose up -d
make logs-<service>   # tail a service (e.g. make logs-frontend)
make restart-<service>
make shell-<service>  # exec sh into a running container
make db-console       # psql into kaizen_db
make redis-cli
```

Database migrations and seeds live under `scripts/db/` and are idempotent:

```bash
./scripts/db/migrate.sh up              # apply all pending
./scripts/db/migrate.sh up 003          # apply up to version 003
./scripts/db/migrate.sh down 1          # rollback one
./scripts/db/migrate.sh status
./scripts/db/migrate.sh create <name>   # scaffolds up/ and down/ files
./scripts/db/seed.sh load               # dev data only — never run in prod
./scripts/db/seed.sh reload             # clear + load
```

Env vars used by the migration script: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `MIGRATIONS_DIR`.

Protobuf codegen (regenerate after editing `shared/protos/*.proto`):

```bash
make proto            # all three languages
make proto-go
make proto-rust
make proto-python
```

PostHog analytics stack (separate from the main compose):

```bash
npm run docker:posthog:up     # docker-compose -f docker-compose.posthog.yml up -d
npm run docker:posthog:down
npm run docker:posthog:logs
```

## Cross-Service Architecture

Four things connect every service and should be understood before editing any one of them:

1. **Contracts are the source of truth.** Before implementing an endpoint, update `shared/contracts/openapi/*.yaml` (REST) or `shared/protos/services/*.proto` (gRPC). Protobuf packages embed a version (`kaizen.v1.service`); breaking changes bump the major.

2. **TDD with failing contract tests.** Spec-Kit tasks T016–T025 define contract tests that are expected to fail before the corresponding service is implemented. When adding a new endpoint, add the contract test first in `tests/integration/` (or the service's own test dir) and confirm it fails before writing the handler.

3. **PostHog analytics is mandatory on every service boundary.** Each language has a shared client:
   - Go: `packages/go-shared/posthog` (`client.go`) — used by `services/{genui-orchestrator,user-context,experiment-service}/internal/analytics/`.
   - Rust: `packages/rust-shared` (`src/analytics/`) — used by `services/{kre-engine,streaming-adapter}/src/analytics.rs`.
   - Python: `packages/python-shared/kaizen_analytics/` — used by `services/{ai-sommelier,pcm-classifier,bandit-service}/app/analytics.py`.
   All three expose a `PCMStage` enum and a `track_pcm_transition` (or equivalent) method. Mirror existing service `analytics.*` files when adding a new service; don't call `posthog-*` SDKs directly.

4. **Service ports are fixed.** `docker-compose.yml` pins: frontend 3000, genui-orchestrator 4000, kre-engine 4001, user-context 4002, pcm-classifier 4003, ai-sommelier 4004, streaming-adapter 4005 (+ WebSocket 9000), Postgres 5432, Redis 6379, Weaviate 8080, Adminer 8081, Redis Commander 8082. Inter-service env vars (`KRE_SERVICE_URL`, `USER_CONTEXT_URL`, etc.) are injected by compose, not hard-coded.

## Testing Conventions

- Jest config (`jest.config.js`) has a 70% coverage threshold across branches/functions/lines/statements and scans `services/**` + `packages/**` + `tests/**`. Paths alias: `@/*` → `services/frontend/src/*`, `@packages/*` → `packages/*`.
- Jest global setup (`tests/setup.ts`) sets `POSTHOG_ENABLED=false` and adds `toBeValidUUID()` / `toBeValidTimestamp()` matchers; rely on these rather than inlining regex.
- Python tests use `pytest-cov` with `--cov-fail-under=70` and PostHog disabled via env. Markers: `unit`, `integration`, `slow`.
- Go shared module requires `testify`; Rust shared crate uses `mockall` + `tokio-test`.

## Spec-Kit Workflow

This repo uses [Spec-Kit](./.specify/) to drive feature work. Slash commands in `.claude/commands/` (`/specify`, `/clarify`, `/plan`, `/tasks`, `/analyze`, `/implement`, `/constitution`) expect a feature directory under `specs/NNN-name/` containing `spec.md`, `plan.md`, `data-model.md`, `tasks.md`, and optionally `contracts/`, `research.md`, `quickstart.md`. `/implement` runs `.specify/scripts/bash/check-prerequisites.sh` and expects an existing `tasks.md` with `[X]` checkboxes to mark progress. When implementing from a spec, update `tasks.md` checkboxes as you go.

Task IDs in commit messages and scripts follow a single numeric sequence `T001`…`T190+` spanning all three specs. Scripts under `scripts/` (`create-all-issues.sh`, `enrich-*.sh`, etc.) expect GitHub CLI access and can recreate the GitHub Issues that track these tasks — run them sparingly, they make many API calls.

## Conventions

- **Commits:** Conventional Commits (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `perf:`, `chore:`).
- **Go:** `gofmt` + `golangci-lint`; context plumbed through requests.
- **Rust:** `rustfmt` + `clippy`; async via tokio; prefer `Result` over panics.
- **Python:** Black + flake8 + mypy; PEP 484 type hints required in shared packages.
- **TypeScript:** strict mode; Next.js App Router conventions in `services/frontend/`.
- **Dockerfiles:** each service has a `Dockerfile.dev` referenced from `docker-compose.yml`; add these when creating a new service.

## Performance Targets

These numbers show up in specs and should gate PRs that touch hot paths:

- UI generation: <500ms (P95)
- Rule evaluation (KRE): <50ms per request
- API response: <200ms (P95)
- WebSocket connections: 10,000 concurrent
- Frontend Core Web Vitals: LCP <2.5s, FID <100ms, CLS <0.1
