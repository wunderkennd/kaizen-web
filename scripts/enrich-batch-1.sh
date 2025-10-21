#!/bin/bash

# Batch 1: Infrastructure Tasks (T009-T010a)
echo "Enriching Batch 1: Infrastructure Tasks..."

# T009 - Docker Compose
echo "Updating T009 (Docker Compose)..."
gh issue edit 43 --body "# Task T009: Create docker-compose.yml with PostgreSQL, Redis, and service definitions

## 📋 Overview
**Category**: Infrastructure Setup  
**Component**: Infrastructure  
**File Path**: \`docker-compose.yml\`  
**Dependencies**: T001-T008 (All services initialized)  
**Priority**: P0 - Critical  
**Effort**: 5 story points  

## 👤 User Story
As a **platform engineer**, I want a complete Docker Compose setup so that developers can run the entire KAIZEN platform locally with a single command, including all services, databases, and supporting infrastructure.

## ✅ Acceptance Criteria
### Docker Configuration
- [ ] docker-compose.yml with all 7+ services defined
- [ ] PostgreSQL 14+ with persistent volume
- [ ] Redis with persistence configured
- [ ] All services can communicate via network
- [ ] Health checks for all containers

### Service Configuration
- [ ] Environment variables properly set
- [ ] Ports mapped for local development
- [ ] Volume mounts for hot-reloading
- [ ] Resource limits defined
- [ ] Restart policies configured

### Development Experience
- [ ] Single command startup: \`docker-compose up\`
- [ ] Services start in correct order
- [ ] Logs aggregated and readable
- [ ] Dev and prod configurations separate
- [ ] README with usage instructions

## 🔧 Technical Context
**Container Runtime**: Docker 20+  
**Orchestration**: Docker Compose v2  
**Networking**: Bridge network for services  
**Storage**: Named volumes for data  
**Configuration**: .env files for secrets  

## 💡 Implementation Notes
\`\`\`yaml
# Example structure
version: '3.9'

services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: kaizen
      POSTGRES_USER: \${DB_USER}
      POSTGRES_PASSWORD: \${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]

  kre-engine:
    build:
      context: ./services/kre-engine
      dockerfile: Dockerfile
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgres://\${DB_USER}:\${DB_PASSWORD}@postgres/kaizen
    ports:
      - "3001:3000"
    volumes:
      - ./services/kre-engine:/app
    command: cargo watch -x run

volumes:
  postgres_data:
  redis_data:

networks:
  kaizen:
    driver: bridge
\`\`\`

### Key Considerations
- Use multi-stage builds in Dockerfiles
- Implement wait-for scripts for dependencies
- Configure logging drivers appropriately
- Set up development vs production configs
- Include database migration runner
- Add seed data for development
- Consider using Docker BuildKit

## 🧪 Testing Strategy
- Test all services start successfully
- Verify inter-service communication
- Test persistence across restarts
- Validate health checks work
- Test resource limit enforcement
- Benchmark startup time

## 📚 Resources
- [Docker Compose Best Practices](https://docs.docker.com/compose/compose-file/compose-file-v3/)
- [12-Factor App](https://12factor.net/)
- [Docker Security](https://docs.docker.com/engine/security/)

---
*KAIZEN Adaptive Platform - Infrastructure Task*"

echo "✓ T009 updated"

# T010 - Shared Contracts and Protos
echo "Updating T010 (Shared Contracts)..."
gh issue edit 44 --body "# Task T010: Setup shared contracts and protos directories with build scripts

## 📋 Overview
**Category**: Infrastructure Setup  
**Component**: Infrastructure  
**File Path**: \`shared/\`  
**Dependencies**: T001  
**Priority**: P0 - Critical  
**Effort**: 3 story points  

## 👤 User Story
As a **backend developer**, I want shared contract definitions and protocol buffers so that all services can communicate using strongly-typed interfaces with code generation for multiple languages.

## ✅ Acceptance Criteria
### Directory Structure
- [ ] shared/protos/ for gRPC definitions
- [ ] shared/contracts/ for OpenAPI specs
- [ ] shared/graphql/ for GraphQL schemas
- [ ] Build scripts for code generation
- [ ] CI validation for breaking changes

### Code Generation
- [ ] Proto compilation for Go, Rust, Python
- [ ] OpenAPI client generation
- [ ] GraphQL type generation
- [ ] Version management strategy
- [ ] Documentation generation

### Quality Standards
- [ ] Linting rules for all formats
- [ ] Backward compatibility checks
- [ ] Generated code in .gitignore
- [ ] Pre-commit hooks for validation
- [ ] Automated testing of contracts

## 🔧 Technical Context
**Proto Management**: Buf CLI  
**OpenAPI**: v3.1 specification  
**GraphQL**: Schema SDL  
**Languages**: Go, Rust, Python, TypeScript  
**Versioning**: Semantic versioning  

## 💡 Implementation Notes
### Directory Structure
\`\`\`
shared/
├── protos/
│   ├── buf.yaml
│   ├── buf.gen.yaml
│   ├── v1/
│   │   ├── common.proto
│   │   ├── kre_engine.proto
│   │   ├── genui.proto
│   │   └── user_context.proto
│   └── README.md
├── contracts/
│   ├── openapi/
│   │   ├── kre-engine.yaml
│   │   ├── genui-orchestrator.yaml
│   │   └── user-context.yaml
│   └── README.md
├── graphql/
│   ├── schema.graphql
│   ├── codegen.yml
│   └── README.md
└── scripts/
    ├── generate.sh
    ├── validate.sh
    └── test-compatibility.sh
\`\`\`

### Buf Configuration
\`\`\`yaml
# buf.yaml
version: v1
breaking:
  use:
    - FILE
lint:
  use:
    - DEFAULT
  except:
    - FIELD_LOWER_SNAKE_CASE
\`\`\`

### Code Generation Script
\`\`\`bash
#!/bin/bash
# generate.sh

# Generate Go code
buf generate protos --template protos/buf.gen.yaml

# Generate OpenAPI clients
openapi-generator-cli generate \\
  -i contracts/openapi/*.yaml \\
  -g go \\
  -o ../services/shared/clients

# Generate GraphQL types
graphql-codegen --config graphql/codegen.yml
\`\`\`

## 🧪 Testing Strategy
- Test proto compilation succeeds
- Validate OpenAPI specs
- Test GraphQL schema validity
- Verify generated code compiles
- Test backward compatibility
- Integration tests for contracts

## 📚 Resources
- [Buf Documentation](https://docs.buf.build)
- [OpenAPI Specification](https://spec.openapis.org/oas/v3.1.0)
- [Protocol Buffers](https://developers.google.com/protocol-buffers)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)

---
*KAIZEN Adaptive Platform - Infrastructure Task*"

echo "✓ T010 updated"

# T010a - Pinecone Vector Database
echo "Updating T010a (Pinecone Setup)..."
gh issue edit 45 --body "# Task T010a: Setup Pinecone vector database for semantic search embeddings

## 📋 Overview
**Category**: Infrastructure Setup  
**Component**: Infrastructure / AI  
**File Path**: \`infrastructure/pinecone/\`  
**Dependencies**: T010  
**Priority**: P1 - High  
**Effort**: 3 story points  

## 👤 User Story
As an **AI engineer**, I want Pinecone vector database configured so that the AI Sommelier can perform semantic search on anime content with sub-second query times for natural language discovery.

## ✅ Acceptance Criteria
### Pinecone Configuration
- [ ] Pinecone account and API keys set up
- [ ] Index created with appropriate dimensions
- [ ] Namespace strategy defined
- [ ] Metadata schema documented
- [ ] Connection pooling configured

### Integration Requirements
- [ ] Client libraries for Python service
- [ ] Embedding pipeline defined
- [ ] Batch upload functionality
- [ ] Search API implemented
- [ ] Performance monitoring setup

### Operational Standards
- [ ] Backup strategy documented
- [ ] Cost monitoring alerts
- [ ] Query performance <100ms
- [ ] Index optimization schedule
- [ ] Disaster recovery plan

## 🔧 Technical Context
**Vector DB**: Pinecone  
**Embedding Model**: sentence-transformers  
**Dimensions**: 768 (BERT-based)  
**Index Type**: Approximate (HNSW)  
**Query Performance**: <100ms P95  

## 💡 Implementation Notes
### Index Configuration
\`\`\`python
import pinecone
from typing import List, Dict
import numpy as np

# Initialize Pinecone
pinecone.init(
    api_key=os.getenv("PINECONE_API_KEY"),
    environment=os.getenv("PINECONE_ENV")
)

# Create index
index_name = "kaizen-content"
dimension = 768  # For BERT embeddings

if index_name not in pinecone.list_indexes():
    pinecone.create_index(
        name=index_name,
        dimension=dimension,
        metric="cosine",
        metadata_config={
            "indexed": ["content_type", "genre", "pcm_stage"]
        }
    )

# Connect to index
index = pinecone.Index(index_name)

# Upsert embeddings
def upsert_embeddings(
    embeddings: List[np.ndarray],
    metadata: List[Dict],
    ids: List[str]
):
    vectors = [
        (id, emb.tolist(), meta)
        for id, emb, meta in zip(ids, embeddings, metadata)
    ]
    
    index.upsert(
        vectors=vectors,
        namespace="anime_content"
    )

# Semantic search
def semantic_search(
    query_embedding: np.ndarray,
    filters: Dict = None,
    top_k: int = 10
):
    results = index.query(
        vector=query_embedding.tolist(),
        filter=filters,
        top_k=top_k,
        include_metadata=True
    )
    return results
\`\`\`

### Namespace Strategy
- **anime_content**: Main content embeddings
- **user_queries**: Cached query embeddings
- **recommendations**: Personalized vectors
- **trending**: Time-decay weighted content

### Metadata Schema
\`\`\`json
{
  "content_id": "uuid",
  "title": "string",
  "content_type": "episode|movie|clip",
  "genre": ["action", "comedy"],
  "pcm_stage": "awareness|attraction|attachment|allegiance",
  "emotional_tags": ["exciting", "heartwarming"],
  "popularity_score": 0.85,
  "release_date": "2024-01-01",
  "language": "en|jp"
}
\`\`\`

## 🧪 Testing Strategy
- Test index creation and deletion
- Benchmark query performance
- Test filtering capabilities
- Validate embedding dimensions
- Test batch upload performance
- Monitor index statistics

## 📚 Resources
- [Pinecone Documentation](https://docs.pinecone.io/)
- [Sentence Transformers](https://www.sbert.net/)
- [Vector Search Best Practices](https://www.pinecone.io/learn/vector-search/)
- [Embedding Models Comparison](https://www.sbert.net/docs/pretrained_models.html)

---
*KAIZEN Adaptive Platform - Infrastructure Task*"

echo "✓ T010a updated"

# T012 - UserProfile Migration
echo "Updating T012 (UserProfile Migration)..."
gh issue edit 47 --body "# Task T012: Create migration for UserProfile table with PCM stages

## 📋 Overview
**Category**: Database Schema  
**Component**: Database / User Context  
**File Path**: \`migrations/002_create_user_profile.sql\`  
**Dependencies**: T011 (Base migrations setup)  
**Priority**: P0 - Critical  
**Effort**: 3 story points  

## 👤 User Story
As a **backend developer**, I want the UserProfile table properly defined in the database so that we can store user data with PCM stages, preferences, and track their journey through the psychological continuum model.

## ✅ Acceptance Criteria
### Table Structure
- [ ] UserProfile table created with all required columns
- [ ] PCM stage enum type defined
- [ ] Expertise level enum type defined
- [ ] JSONB columns for flexible data
- [ ] Timestamps with timezone

### Data Integrity
- [ ] Primary key on id (UUID)
- [ ] Unique constraint on email
- [ ] Check constraints for valid data
- [ ] Default values where appropriate
- [ ] Indexes for query performance

### Migration Quality
- [ ] UP migration creates table
- [ ] DOWN migration drops table cleanly
- [ ] Migration is transactional
- [ ] Runs without errors
- [ ] Idempotent execution

## 🔧 Technical Context
**Database**: PostgreSQL 14+  
**Migration Tool**: golang-migrate  
**UUID Generation**: gen_random_uuid()  
**JSON Storage**: JSONB with GIN indexes  
**Timestamps**: TIMESTAMPTZ  

## 💡 Implementation Notes
### UP Migration
\`\`\`sql
-- 002_create_user_profile.up.sql

BEGIN;

-- Create PCM stage enum
CREATE TYPE pcm_stage AS ENUM (
    'awareness',
    'attraction', 
    'attachment',
    'allegiance'
);

-- Create expertise level enum
CREATE TYPE expertise_level AS ENUM (
    'curious',
    'casual',
    'enthusiast',
    'expert'
);

-- Create UserProfile table
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL,
    pcm_stage pcm_stage NOT NULL DEFAULT 'awareness',
    expertise_level expertise_level NOT NULL DEFAULT 'curious',
    preferences JSONB NOT NULL DEFAULT '{}',
    octalysis_scores JSONB NOT NULL DEFAULT '{
        "accomplishment": 0,
        "empowerment": 0,
        "ownership": 0,
        "social_influence": 0
    }',
    device_preferences JSONB NOT NULL DEFAULT '{}',
    privacy_settings JSONB NOT NULL DEFAULT '{
        "data_collection": true,
        "personalization": true,
        "analytics": true
    }',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$'),
    CONSTRAINT username_length CHECK (LENGTH(username) >= 3)
);

-- Create indexes
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_pcm_stage ON user_profiles(pcm_stage);
CREATE INDEX idx_user_profiles_expertise ON user_profiles(expertise_level);
CREATE INDEX idx_user_profiles_active ON user_profiles(last_active_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_profiles_preferences ON user_profiles USING GIN (preferences);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE user_profiles IS 'Core user profile with PCM stages and preferences';
COMMENT ON COLUMN user_profiles.pcm_stage IS 'Psychological Continuum Model stage';
COMMENT ON COLUMN user_profiles.octalysis_scores IS 'Gamification framework scores';

COMMIT;
\`\`\`

### DOWN Migration
\`\`\`sql
-- 002_create_user_profile.down.sql

BEGIN;

DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP TABLE IF EXISTS user_profiles;
DROP TYPE IF EXISTS expertise_level;
DROP TYPE IF EXISTS pcm_stage;

COMMIT;
\`\`\`

## 🧪 Testing Strategy
- Test migration up and down
- Verify all constraints work
- Test trigger functionality
- Check index performance
- Validate JSON operations
- Test with sample data

## 📚 Resources
- [PostgreSQL JSON](https://www.postgresql.org/docs/14/datatype-json.html)
- [UUID Best Practices](https://www.postgresql.org/docs/14/functions-uuid.html)
- [Index Types](https://www.postgresql.org/docs/14/indexes-types.html)

---
*KAIZEN Adaptive Platform - Database Task*"

echo "✓ T012 updated"

# T013 - Context and UI Migrations
echo "Updating T013 (Context/UI Tables)..."
gh issue edit 48 --body "# Task T013: Create migration for ContextSnapshot and UIConfiguration tables

## 📋 Overview
**Category**: Database Schema  
**Component**: Database / GenUI  
**File Path**: \`migrations/003_create_context_ui_tables.sql\`  
**Dependencies**: T011, T012  
**Priority**: P0 - Critical  
**Effort**: 3 story points  

## 👤 User Story
As a **backend developer**, I want ContextSnapshot and UIConfiguration tables so that we can capture user context in real-time and store the dynamically generated UI configurations for each context.

## ✅ Acceptance Criteria
### Table Creation
- [ ] ContextSnapshot table with all fields
- [ ] UIConfiguration table with relationships
- [ ] Foreign key to user_profiles
- [ ] Appropriate data types used
- [ ] Performance indexes created

### Data Model Requirements
- [ ] Context captures device, time, location
- [ ] UI config stores full layout JSON
- [ ] Assembly metrics tracked
- [ ] Versioning supported
- [ ] Soft delete capability

### Quality Standards
- [ ] Migration is transactional
- [ ] Rollback tested
- [ ] Sample data provided
- [ ] Performance validated
- [ ] Documentation complete

## 🔧 Technical Context
**Storage Strategy**: JSONB for flexible schemas  
**Partitioning**: Monthly for context snapshots  
**Retention**: 90 days for contexts  
**Indexes**: B-tree and GIN  
**Compression**: TOAST for large JSON  

## 💡 Implementation Notes
### UP Migration
\`\`\`sql
-- 003_create_context_ui_tables.up.sql

BEGIN;

-- Device type enum
CREATE TYPE device_type AS ENUM ('web', 'mobile', 'tv', 'tablet');
CREATE TYPE time_constraint AS ENUM ('limited', 'normal', 'extended');
CREATE TYPE network_quality AS ENUM ('poor', 'fair', 'good', 'excellent');
CREATE TYPE ui_density AS ENUM ('comfortable', 'compact');
CREATE TYPE metadata_verbosity AS ENUM ('minimal', 'standard', 'detailed');

-- ContextSnapshot table
CREATE TABLE context_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    device_type device_type NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    location VARCHAR(100),
    session_id UUID NOT NULL,
    active_content_id UUID,
    time_constraint time_constraint DEFAULT 'normal',
    event_context VARCHAR(255),
    inferred_intent VARCHAR(255),
    network_quality network_quality DEFAULT 'good',
    custom_attributes JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Partition key
    partition_date DATE NOT NULL DEFAULT CURRENT_DATE
) PARTITION BY RANGE (partition_date);

-- Create monthly partitions (example for next 3 months)
CREATE TABLE context_snapshots_2025_01 PARTITION OF context_snapshots
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE context_snapshots_2025_02 PARTITION OF context_snapshots
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE context_snapshots_2025_03 PARTITION OF context_snapshots
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

-- UIConfiguration table
CREATE TABLE ui_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    context_snapshot_id UUID NOT NULL REFERENCES context_snapshots(id) ON DELETE CASCADE,
    configuration JSONB NOT NULL,
    sections JSONB NOT NULL DEFAULT '[]',
    frame_config JSONB DEFAULT '{}',
    canvas_config JSONB DEFAULT '{}',
    density ui_density NOT NULL DEFAULT 'comfortable',
    metadata_verbosity metadata_verbosity NOT NULL DEFAULT 'standard',
    theme VARCHAR(50) DEFAULT 'light',
    assembly_time_ms INTEGER NOT NULL,
    cache_hit BOOLEAN DEFAULT false,
    version INTEGER DEFAULT 1,
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for ContextSnapshot
CREATE INDEX idx_context_user_id ON context_snapshots(user_id, created_at DESC);
CREATE INDEX idx_context_session ON context_snapshots(session_id);
CREATE INDEX idx_context_device ON context_snapshots(device_type, device_id);
CREATE INDEX idx_context_created ON context_snapshots(created_at DESC);

-- Indexes for UIConfiguration  
CREATE INDEX idx_ui_config_context ON ui_configurations(context_snapshot_id);
CREATE INDEX idx_ui_config_generated ON ui_configurations(generated_at DESC);
CREATE INDEX idx_ui_config_performance ON ui_configurations(assembly_time_ms);
CREATE INDEX idx_ui_config_cache ON ui_configurations(cache_hit) WHERE cache_hit = true;

-- Add table comments
COMMENT ON TABLE context_snapshots IS 'Real-time user context for adaptive UI generation';
COMMENT ON TABLE ui_configurations IS 'Generated UI layouts based on context';

COMMIT;
\`\`\`

### Partition Management
\`\`\`sql
-- Function to auto-create monthly partitions
CREATE OR REPLACE FUNCTION create_monthly_partitions()
RETURNS void AS $$
DECLARE
    start_date date;
    end_date date;
    partition_name text;
BEGIN
    FOR i IN 0..2 LOOP
        start_date := DATE_TRUNC('month', CURRENT_DATE + (i || ' months')::interval);
        end_date := start_date + INTERVAL '1 month';
        partition_name := 'context_snapshots_' || TO_CHAR(start_date, 'YYYY_MM');
        
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS %I PARTITION OF context_snapshots FOR VALUES FROM (%L) TO (%L)',
            partition_name, start_date, end_date
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;
\`\`\`

## 🧪 Testing Strategy
- Test partition creation
- Verify foreign keys work
- Test JSON operations
- Check query performance
- Validate data retention
- Test rollback procedure

## 📚 Resources
- [PostgreSQL Partitioning](https://www.postgresql.org/docs/14/ddl-partitioning.html)
- [JSONB Performance](https://www.postgresql.org/docs/14/datatype-json.html#JSON-INDEXING)
- [Time-Series Best Practices](https://docs.timescale.com/timescaledb/latest/how-to-guides/schema-management/)

---
*KAIZEN Adaptive Platform - Database Task*"

echo "✓ T013 updated"

echo ""
echo "========================================="
echo "Batch 1 Complete!"
echo "Updated issues #43-48:"
echo "- T009: Docker Compose"
echo "- T010: Shared Contracts" 
echo "- T010a: Pinecone Setup"
echo "- T012: UserProfile Migration"
echo "- T013: Context/UI Tables"
echo "========================================="