# 🎯 KAIZEN Adaptive Platform

> An intelligent, context-aware platform that dynamically generates personalized user interfaces based on real-time behavior analysis and the Psychological Continuum Model (PCM).

[![GitHub Issues](https://img.shields.io/github/issues/wunderkennd/kaizen-web)](https://github.com/wunderkennd/kaizen-web/issues)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-in%20development-yellow)](https://github.com/wunderkennd/kaizen-web/projects)

## 🚀 Overview

KAIZEN is a next-generation adaptive platform that revolutionizes user experience through:

- **Dynamic UI Generation**: Real-time interface adaptation based on user context and behavior
- **PCM Integration**: Tracks users through Awareness → Attraction → Attachment → Allegiance stages
- **ML-Powered Personalization**: Advanced recommendation engine for anime content
- **Rule-Based Adaptation**: Sophisticated rule engine for UI customization
- **A/B Testing Platform**: Built-in experimentation framework
- **Multi-Armed Bandits**: Advanced optimization algorithms for continuous improvement

## 🏗️ Architecture

The platform follows a microservices architecture with the following core services:

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                             │
│                    (Next.js 14 + React)                      │
└─────────────┬───────────────────────────────┬───────────────┘
              │                               │
              ▼                               ▼
        GraphQL API                      WebSocket
              │                               │
┌─────────────┴───────────────────────────────┴───────────────┐
│                    API Gateway Layer                         │
├───────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │GenUI         │  │User Context  │  │KRE Engine    │      │
│  │Orchestrator  │  │Service       │  │(Rust)        │      │
│  │(Go)          │  │(Go)          │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │AI Sommelier  │  │PCM           │  │Streaming     │      │
│  │(Python)      │  │Classifier    │  │Adapter       │      │
│  │              │  │(Python/Rust) │  │(Rust)        │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└───────────────────────────────────────────────────────────────┘
              │                               │
              ▼                               ▼
      PostgreSQL                        Pinecone
        Redis                          (Vector DB)
```

## 📦 Repository Structure

```
kaizen-web/
├── frontend/               # Next.js 14 frontend application
│   ├── src/
│   │   ├── components/    # KDS component library
│   │   ├── features/      # Feature modules
│   │   └── app/          # Next.js app router
│   └── tests/            # Frontend tests
│
├── services/              # Microservices
│   ├── genui-orchestrator/    # Go - UI generation orchestrator
│   ├── kre-engine/           # Rust - Rule evaluation engine
│   ├── user-context/         # Go - User context management
│   ├── ai-sommelier/         # Python - AI recommendations
│   ├── pcm-classifier/       # Python/Rust - PCM classification
│   ├── streaming-adapter/    # Rust - WebSocket/SSE adapter
│   ├── experiment-service/   # Go - A/B testing platform
│   └── bandit-service/       # Python - Multi-armed bandits
│
├── packages/              # Shared packages
│   ├── contracts/        # API contracts and protos
│   └── kds/             # Kaizen Design System
│
├── migrations/           # Database migrations
├── k8s/                 # Kubernetes manifests
├── scripts/             # Utility scripts
├── docs/                # Documentation
└── specs/               # Technical specifications
```

## 🚦 Getting Started

### Prerequisites

- Node.js 18+
- Go 1.21+
- Rust 1.70+
- Python 3.11+
- Docker & Docker Compose
- PostgreSQL 14+
- Redis 7+

### Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/wunderkennd/kaizen-web.git
cd kaizen-web
```

2. **Install dependencies**
```bash
# Install frontend dependencies
cd frontend && npm install

# Install service dependencies (example for Go service)
cd ../services/genui-orchestrator && go mod download

# Install Python dependencies
cd ../services/ai-sommelier && pip install -r requirements.txt
```

3. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Run database migrations**
```bash
npm run db:migrate
```

5. **Start services with Docker Compose**
```bash
docker-compose up -d
```

6. **Start development servers**
```bash
# Terminal 1: Frontend
cd frontend && npm run dev

# Terminal 2: Services (example)
cd services/genui-orchestrator && go run main.go
```

Visit http://localhost:3000 to see the application.

## 🧪 Testing

### Running Tests

```bash
# Frontend tests
cd frontend
npm run test        # Unit tests
npm run test:e2e    # E2E tests with Playwright
npm run test:a11y   # Accessibility tests

# Backend tests (Go example)
cd services/user-context
go test ./...

# Backend tests (Rust example)
cd services/kre-engine
cargo test

# Backend tests (Python example)
cd services/ai-sommelier
pytest
```

### Contract Tests (TDD)

All services follow Test-Driven Development with contract tests that must fail before implementation:

```bash
# Run contract tests
npm run test:contracts
```

## 🛠️ Development

### Working with Git Worktrees

The project supports parallel development using Git worktrees:

```bash
# Create worktree for frontend development
git worktree add -b feature/frontend ../kaizen-frontend main

# Create worktree for backend development
git worktree add -b feature/backend ../kaizen-backend main
```

### Code Style

- **TypeScript/JavaScript**: ESLint + Prettier
- **Go**: gofmt + golangci-lint
- **Rust**: rustfmt + clippy
- **Python**: Black + pylint

### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `test:` Testing
- `refactor:` Code refactoring
- `perf:` Performance improvements

## 📊 Project Management

### Task Tracking

All 158 tasks are tracked as GitHub Issues with detailed specifications:
- View issues: https://github.com/wunderkennd/kaizen-web/issues
- Project board: https://github.com/wunderkennd/kaizen-web/projects

### Task Categories

1. **Infrastructure Setup** (T001-T010)
2. **Database Schema** (T011-T015)
3. **Contract Tests** (T016-T025)
4. **Data Models** (T026-T036)
5. **Core Services** (T037-T050)
6. **Frontend Components** (T051-T057)
7. **Integration Tests** (T058-T062)
8. **RMI Designer** (T063-T068)
9. **Deployment & Ops** (T069-T080)
10. **A/B Testing** (T099-T122)
11. **Advanced ML** (T123-T164)

## 🚀 Deployment

### Kubernetes Deployment

```bash
# Deploy to staging
kubectl apply -f k8s/staging/

# Deploy to production
kubectl apply -f k8s/production/
```

### CI/CD Pipeline

The project uses GitHub Actions for CI/CD:

- **Build & Test**: On every pull request
- **Security Scanning**: Daily vulnerability scans
- **Deployment**: Automatic deployment to staging on merge

## 📈 Performance Targets

- **UI Generation**: <500ms (P95)
- **Rule Evaluation**: <50ms per request
- **WebSocket Connections**: 10,000 concurrent
- **API Response Time**: <200ms (P95)
- **Frontend Core Web Vitals**:
  - LCP: <2.5s
  - FID: <100ms
  - CLS: <0.1

## 🔐 Security

- JWT-based authentication with refresh tokens
- Rate limiting on all endpoints
- OWASP security scanning in CI/CD
- GDPR-compliant data handling
- Encrypted data at rest and in transit

## 📚 Documentation

- [Technical Specification](specs/001-adaptive-platform/spec.md)
- [Data Model](specs/001-adaptive-platform/data-model.md)
- [API Documentation](docs/api/)
- [Contributing Guide](CONTRIBUTING.md)
- [Architecture Decision Records](docs/adr/)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- Code of Conduct
- Development setup
- Submitting pull requests
- Reporting issues

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with the Kaizen Design System (KDS)
- Powered by cutting-edge ML/AI technologies
- Inspired by anime recommendation platforms
- Based on the Psychological Continuum Model

## 📞 Contact

- **Project Lead**: Kenneth Sylvain
- **Organization**: Wunderkennd
- **Repository**: https://github.com/wunderkennd/kaizen-web

---

**Current Status**: 🚧 Active Development

Track our progress on the [GitHub Project Board](https://github.com/wunderkennd/kaizen-web/projects)