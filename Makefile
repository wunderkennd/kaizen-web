# KAIZEN Platform Makefile
.PHONY: help dev stop clean test build deploy proto docker-up docker-down docker-reset

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKER_COMPOSE := docker-compose
SERVICES := frontend genui-orchestrator kre-engine user-context pcm-classifier ai-sommelier streaming-adapter

# Help target
help: ## Show this help message
	@echo "KAIZEN Platform Development Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development
dev: ## Start development environment
	@./scripts/docker/start-dev.sh

stop: ## Stop development environment
	@./scripts/docker/stop-dev.sh

clean: ## Clean development environment
	@./scripts/docker/reset-dev.sh

# Docker commands
docker-up: ## Start Docker services
	@$(DOCKER_COMPOSE) up -d

docker-down: ## Stop Docker services
	@$(DOCKER_COMPOSE) down

docker-reset: ## Reset Docker environment
	@$(DOCKER_COMPOSE) down -v --remove-orphans
	@$(DOCKER_COMPOSE) down --rmi local

docker-logs: ## Show Docker logs
	@$(DOCKER_COMPOSE) logs -f

docker-ps: ## Show Docker container status
	@$(DOCKER_COMPOSE) ps

# Service-specific commands
logs-%: ## Show logs for a specific service (e.g., make logs-frontend)
	@$(DOCKER_COMPOSE) logs -f $*

restart-%: ## Restart a specific service (e.g., make restart-frontend)
	@$(DOCKER_COMPOSE) restart $*

shell-%: ## Open shell in a service container (e.g., make shell-frontend)
	@$(DOCKER_COMPOSE) exec $* sh

# Database
db-migrate: ## Run database migrations
	@echo "Running database migrations..."
	@$(DOCKER_COMPOSE) exec postgres psql -U kaizen -d kaizen_db -f /docker-entrypoint-initdb.d/migrations.sql

db-seed: ## Seed database with test data
	@echo "Seeding database..."
	@$(DOCKER_COMPOSE) exec postgres psql -U kaizen -d kaizen_db -f /docker-entrypoint-initdb.d/seed.sql

db-reset: ## Reset database
	@echo "Resetting database..."
	@$(DOCKER_COMPOSE) exec postgres psql -U kaizen -c "DROP DATABASE IF EXISTS kaizen_db;"
	@$(DOCKER_COMPOSE) exec postgres psql -U kaizen -c "CREATE DATABASE kaizen_db;"
	@make db-migrate
	@make db-seed

db-console: ## Open PostgreSQL console
	@$(DOCKER_COMPOSE) exec postgres psql -U kaizen -d kaizen_db

redis-cli: ## Open Redis CLI
	@$(DOCKER_COMPOSE) exec redis redis-cli

# Protocol Buffers
proto: ## Generate all protobuf code
	@echo "Generating Protocol Buffer code..."
	@./scripts/protos/generate-go.sh
	@./scripts/protos/generate-rust.sh
	@./scripts/protos/generate-python.sh

proto-go: ## Generate Go protobuf code
	@./scripts/protos/generate-go.sh

proto-rust: ## Generate Rust protobuf code
	@./scripts/protos/generate-rust.sh

proto-python: ## Generate Python protobuf code
	@./scripts/protos/generate-python.sh

# Testing
test: ## Run all tests
	@echo "Running tests..."
	@make test-unit
	@make test-integration

test-unit: ## Run unit tests
	@echo "Running unit tests..."
	@for service in $(SERVICES); do \
		echo "Testing $$service..."; \
		$(DOCKER_COMPOSE) exec -T $$service make test 2>/dev/null || true; \
	done

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	@$(DOCKER_COMPOSE) exec -T frontend npm test
	@$(DOCKER_COMPOSE) exec -T genui-orchestrator go test ./...
	@$(DOCKER_COMPOSE) exec -T kre-engine cargo test

test-e2e: ## Run end-to-end tests
	@echo "Running E2E tests..."
	@cd tests/e2e && npm test

# Building
build: ## Build all services
	@echo "Building all services..."
	@$(DOCKER_COMPOSE) build

build-%: ## Build a specific service (e.g., make build-frontend)
	@echo "Building $*..."
	@$(DOCKER_COMPOSE) build $*

# Deployment
deploy-dev: ## Deploy to development environment
	@echo "Deploying to development..."
	@./scripts/deploy/deploy-dev.sh

deploy-staging: ## Deploy to staging environment
	@echo "Deploying to staging..."
	@./scripts/deploy/deploy-staging.sh

deploy-prod: ## Deploy to production environment
	@echo "⚠️  Production deployment"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@./scripts/deploy/deploy-prod.sh

# CI/CD
ci-lint: ## Run linting for CI
	@echo "Running linters..."
	@make lint-frontend
	@make lint-go
	@make lint-rust

lint-frontend: ## Lint frontend code
	@cd services/frontend && npm run lint

lint-go: ## Lint Go code
	@cd services/genui-orchestrator && golangci-lint run
	@cd services/user-context-service && golangci-lint run

lint-rust: ## Lint Rust code
	@cd services/kre-engine && cargo clippy
	@cd services/streaming-adapter && cargo clippy

fmt: ## Format all code
	@echo "Formatting code..."
	@cd services/frontend && npm run format
	@cd services/genui-orchestrator && go fmt ./...
	@cd services/kre-engine && cargo fmt

# Monitoring
monitor: ## Open monitoring dashboard
	@open http://localhost:3000
	@open http://localhost:8081  # Adminer
	@open http://localhost:8082  # Redis Commander

# Documentation
docs: ## Generate documentation
	@echo "Generating documentation..."
	@cd docs && npm run build

docs-serve: ## Serve documentation locally
	@cd docs && npm run serve

# Utilities
check-deps: ## Check if all dependencies are installed
	@echo "Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "Docker is not installed"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose is not installed"; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "Git is not installed"; exit 1; }
	@echo "✅ All dependencies installed"

setup: check-deps ## Initial project setup
	@echo "Setting up KAIZEN platform..."
	@cp .env.example .env 2>/dev/null || true
	@make proto
	@make docker-up
	@make db-migrate
	@echo "✅ Setup complete! Run 'make dev' to start developing"

# GitHub Issues
issue-update: ## Update GitHub issue status
	@./scripts/github/update-issue-status.sh

issue-close: ## Close completed GitHub issues
	@./scripts/github/close-completed-issues.sh