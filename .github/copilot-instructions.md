# KAIZEN Adaptive Platform - Copilot Instructions

## Project Overview

KAIZEN is an intelligent, context-aware platform that revolutionizes user experience through dynamic UI generation, ML-powered personalization, and sophisticated rule-based adaptation based on real-time behavior analysis and the Psychological Continuum Model (PCM).

**Key Features:**
- Dynamic UI Generation: Real-time interface adaptation based on user context and behavior
- PCM Integration: Tracks users through Awareness → Attraction → Attachment → Allegiance stages
- ML-Powered Personalization: Advanced recommendation engine (AI Sommelier)
- Rule-Based Adaptation: Sophisticated rule engine (KRE) for UI customization
- A/B Testing Platform: Built-in experimentation framework
- Multi-Armed Bandits: Advanced optimization algorithms for continuous improvement

## Architecture

The platform follows a **microservices architecture** with:

### Frontend
- **Framework**: Next.js 14 with React
- **Location**: `frontend/`
- **Communication**: GraphQL API and WebSocket

### Backend Services
The following microservices will be implemented in the `services/` directory:

1. **GenUI Orchestrator** (Go) - UI generation orchestrator
2. **KRE Engine** (Rust) - Rule evaluation engine
3. **User Context Service** (Go) - User context management
4. **AI Sommelier** (Python) - AI recommendations
5. **PCM Classifier** (Python/Rust) - PCM classification
6. **Streaming Adapter** (Rust) - WebSocket/SSE adapter
7. **Experiment Service** (Go) - A/B testing platform
8. **Bandit Service** (Python) - Multi-armed bandits

**Current Status**: Infrastructure setup completed (T001-T008). Services are being scaffolded.

### Shared Components
- **Current**: `shared/` - API contracts and protocol buffers
  - `shared/contracts/` - API contract definitions
  - `shared/protos/` - Protocol buffer definitions
- **Planned**: `packages/` - Reusable npm packages for Kaizen Design System (KDS) and shared utilities

### Data Layer
- **PostgreSQL 14+**: Primary database
- **Redis 7+**: Caching and real-time data
- **Pinecone**: Vector database for ML features

## Tech Stack

### Languages & Frameworks
- **Frontend**: TypeScript, Next.js 14, React
- **Backend Services**: 
  - Go 1.21+ (GenUI Orchestrator, User Context, Experiment Service)
  - Rust 1.70+ (KRE Engine, Streaming Adapter)
  - Python 3.11+ (AI Sommelier, PCM Classifier, Bandit Service)
- **Node.js**: 18+

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Orchestration**: Kubernetes (manifests in `k8s/`)
- **CI/CD**: GitHub Actions
- **Deployment**: Cloud Run / Kubernetes

## Repository Structure

```
kaizen-web/
├── frontend/               # Next.js 14 frontend application
│   ├── src/
│   │   ├── components/    # KDS component library
│   │   ├── features/      # Feature modules
│   │   └── app/          # Next.js app router
│   └── tests/            # Frontend tests
├── services/              # Microservices (planned)
│   ├── genui-orchestrator/    # Go
│   ├── kre-engine/           # Rust
│   ├── user-context/         # Go
│   ├── ai-sommelier/         # Python
│   ├── pcm-classifier/       # Python/Rust
│   ├── streaming-adapter/    # Rust
│   ├── experiment-service/   # Go
│   └── bandit-service/       # Python
├── packages/              # Shared packages (planned)
├── shared/                # Shared contracts and protos
│   ├── contracts/        # API contracts
│   └── protos/           # Protocol buffers
├── migrations/           # Database migrations
├── k8s/                 # Kubernetes manifests
├── scripts/             # Utility scripts
├── docs/                # Documentation
└── specs/               # Technical specifications
    ├── 001-adaptive-platform/
    ├── 002-ab-testing/
    └── 003-multivariate-experiments/
```

## Development Guidelines

### Code Style & Formatting

**TypeScript/JavaScript:**
- Use ESLint + Prettier
- Prefer functional components with hooks
- Use TypeScript strict mode
- Follow Next.js 14 conventions (App Router)

**Go:**
- Use `gofmt` + `golangci-lint`
- Follow standard Go project layout
- Use context for cancellation and deadlines
- Implement proper error handling

**Rust:**
- Use `rustfmt` + `clippy`
- Follow Rust API guidelines
- Prefer Result types over panics
- Use async/await for I/O operations

**Python:**
- Use Black + pylint
- Type hints required (PEP 484) with mypy for static type checking
- Follow PEP 8 style guide
- Use virtual environments

### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Testing changes
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `chore:` Build process or auxiliary tool changes

### Testing Requirements

**Test-Driven Development (TDD)**
- All services follow TDD with contract tests
- Contract tests must fail before implementation

**Frontend Testing:**
```bash
cd frontend
npm run test        # Unit tests (Vitest/Jest)
npm run test:e2e    # E2E tests with Playwright
npm run test:a11y   # Accessibility tests
```

**Backend Testing:**
```bash
# Go services
cd services/user-context
go test ./...

# Rust services
cd services/kre-engine
cargo test

# Python services
cd services/ai-sommelier
pytest
```

**Contract Tests:**
```bash
npm run test:contracts
```

### Performance Targets

**Critical Metrics:**
- UI Generation: <500ms (P95)
- Rule Evaluation: <50ms per request
- WebSocket Connections: 10,000 concurrent
- API Response Time: <200ms (P95)

**Frontend Core Web Vitals:**
- LCP (Largest Contentful Paint): <2.5s
- FID (First Input Delay): <100ms
- CLS (Cumulative Layout Shift): <0.1

### Security & Compliance

**Authentication & Authorization:**
- JWT-based authentication with refresh tokens
- Rate limiting on all endpoints
- Implement proper CORS policies

**Security Scanning:**
- OWASP security scanning in CI/CD pipeline
- Regular dependency vulnerability scans
- No secrets in code - use environment variables

**Compliance Requirements:**
- GDPR-compliant data handling
- CCPA compliance
- COPPA compliance for youth users
- EU AI Act compliance
- WCAG 2.1 AA accessibility compliance
- Encrypted data at rest and in transit

**Privacy:**
- Transparent data collection disclosure
- User data export/deletion capabilities
- Minimum data retention policies

## Key Workflows

### Starting Development

1. **Clone and setup:**
```bash
git clone https://github.com/wunderkennd/kaizen-web.git
cd kaizen-web
```

2. **Environment setup:**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Install dependencies:**
```bash
# Frontend (from repository root)
cd frontend && npm install

# Go services (from repository root)
cd services/genui-orchestrator && go mod download

# Python services (from repository root)
cd services/ai-sommelier
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

4. **Run with Docker Compose:**
```bash
docker-compose up -d
```

5. **Start development servers:**
```bash
# Frontend
cd frontend && npm run dev

# Individual services
cd services/genui-orchestrator && go run main.go
```

### Database Migrations

```bash
npm run db:migrate
```

### Working with Git Worktrees

The project supports parallel development:
```bash
# Frontend worktree
git worktree add -b feature/frontend ../kaizen-frontend main

# Backend worktree
git worktree add -b feature/backend ../kaizen-backend main
```

## Important Concepts

### Psychological Continuum Model (PCM)

Users progress through 4 stages:
1. **Awareness**: Initial discovery
2. **Attraction**: Growing interest
3. **Attachment**: Regular engagement
4. **Allegiance**: Deep commitment

The system adapts UI based on detected PCM stage.

### Kaizen Design System (KDS)

Atomic design principles with dynamic properties:
- **Atoms**: Basic UI elements
- **Molecules**: Simple component groups
- **Organisms**: Complex component compositions

Dynamic properties:
- **Density**: Information density level
- **MetadataVerbosity**: Detail level shown
- **VisualProminence**: Visual emphasis

### Rule Management Interface (RMI)

Designers create context-aware rules without coding:
- IF/THEN rule logic
- Priority-based conflict resolution
- Visual simulation and testing
- Version control and rollback

### Kaizen Rule Engine (KRE)

Evaluates adaptation rules in real-time:
- Context condition matching
- Priority-based rule selection
- <50ms evaluation time
- Graceful degradation on failure

## Documentation

- **Technical Specifications**: `specs/`
  - `001-adaptive-platform/spec.md` - Core platform spec
  - `002-ab-testing/spec.md` - A/B testing spec
  - `003-multivariate-experiments/spec.md` - MAB spec
- **API Documentation**: `docs/api/`
- **Architecture Decisions**: `docs/adr/`
- **Data Models**: Each spec has a `data-model.md`
- **Task Breakdown**: Each spec has a `tasks.md`

## Project Management

### Task Tracking
- All 190 tasks (T001-T190) tracked as GitHub Issues
- Completed: 8 tasks (T001-T008)
- Remaining: 182 tasks
- View issues: https://github.com/wunderkennd/kaizen-web/issues
- Project board: https://github.com/wunderkennd/kaizen-web/projects

### Epic Structure
1. **Foundation & Infrastructure** (29 tasks, ~120 story points)
2. **Data Layer** (26 tasks, ~90 story points)
3. **Core Services Implementation** (30 tasks, ~250 story points)
4. **Frontend & UI Components** (20 tasks, ~110 story points)
5. **Testing & Quality Assurance** (25 tasks, ~85 story points)
6. **CI/CD & DevOps** (15 tasks, ~75 story points)
7. **Platform Operations** (20 tasks, ~85 story points)
8. **Experimentation Platform** (44 tasks, ~220 story points)

### Key Task Categories
- Infrastructure Setup (T001-T010)
- Database Schema (T011-T015)
- Contract Tests (T016-T025)
- Data Models (T026-T036)
- Core Services (T037-T050)
- Frontend Components (T051-T057)
- Integration Tests (T058-T062)
- RMI Designer (T063-T068)
- Deployment & Ops (T069-T080)
- Admin & Analytics (T081-T084)
- Ecosystem Features (T085-T098)
- A/B Testing Platform (T099-T122)
- Multi-Armed Bandits (T123-T144)
- Advanced ML (T145-T164)
- Terraform IaC (T165, T167-T174)
- CI/CD (T175, T176, T178-T182)
- Cloud Run Infrastructure (T183-T190)

### Milestones
- **Milestone 1**: MVP Foundation (Weeks 1-4) - Basic infrastructure and service scaffolding
- **Milestone 2**: Core Platform (Weeks 5-10) - Functional adaptive UI generation
- **Milestone 3**: Production Launch (Weeks 11-16) - Production-ready with full features

## Best Practices

### When Writing Code

1. **Follow the tech stack conventions** for each language/framework
2. **Write tests first** (TDD approach with contract tests)
3. **Keep components small and reusable**
4. **Use proper error handling** - never swallow errors
5. **Document complex logic** with clear comments
6. **Optimize for performance** - meet the performance targets
7. **Consider security** - validate inputs, sanitize outputs
8. **Ensure accessibility** - WCAG 2.1 AA compliance

### When Creating Services

1. **Start with contract tests** that define the API
2. **Implement proper health checks** and readiness probes
3. **Use structured logging** for observability
4. **Implement graceful shutdown** for reliability
5. **Add metrics and tracing** for monitoring
6. **Follow the microservices patterns** in the architecture

### When Working with the Frontend

1. **Use the KDS component library** - don't create custom components unless necessary
2. **Follow Next.js 14 App Router conventions**
3. **Implement proper loading and error states**
4. **Optimize for Core Web Vitals**
5. **Test on multiple devices and screen sizes**
6. **Ensure keyboard navigation works**

### When Adding Dependencies

1. **Check for security vulnerabilities** before adding
2. **Prefer well-maintained packages** with active communities
3. **Keep dependencies up to date** but test thoroughly
4. **Document why the dependency is needed**
5. **Consider bundle size impact** for frontend dependencies

## Common Commands

### Docker
```bash
docker-compose up -d              # Start all services
docker-compose down              # Stop all services
docker-compose logs -f [service]  # View service logs
docker-compose ps                # List running services
```

### Kubernetes
```bash
kubectl apply -f k8s/staging/    # Deploy to staging
kubectl apply -f k8s/production/ # Deploy to production
kubectl get pods                 # List pods
kubectl logs <pod-name>          # View pod logs
```

### Scripts
```bash
./scripts/create-all-issues.sh      # Create GitHub issues
./scripts/create-epic-labels.sh     # Create epic labels
./scripts/create-milestones.sh      # Create milestones
```

## Contact

- **Project Lead**: Kenneth Sylvain
- **Organization**: Wunderkennd
- **Repository**: https://github.com/wunderkennd/kaizen-web
- **Status**: 🚧 Active Development

## Additional Resources

- [Contributing Guide](CONTRIBUTING.md) (when available)
- [GitHub Project Board](https://github.com/wunderkennd/kaizen-web/projects)
- [LICENSE](LICENSE) - MIT License
