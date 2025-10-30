# Shared Contracts

This directory contains shared API contracts and data models used across all services in the KAIZEN platform.

## Structure

```
contracts/
├── openapi/          # OpenAPI/Swagger specifications
│   ├── genui.yaml
│   ├── kre.yaml
│   ├── user-context.yaml
│   ├── pcm.yaml
│   └── ai-sommelier.yaml
├── graphql/          # GraphQL schemas
│   ├── schema.graphql
│   └── fragments/
├── models/           # Shared data models
│   ├── user.yaml
│   ├── pcm.yaml
│   ├── rules.yaml
│   └── ui-components.yaml
└── events/           # Event schemas
    ├── user-events.yaml
    ├── ui-events.yaml
    └── system-events.yaml
```

## Usage

### For OpenAPI Contracts
```bash
# Generate client code
openapi-generator generate -i openapi/genui.yaml -g typescript-axios -o ../services/frontend/src/api

# Validate contracts
swagger-cli validate openapi/*.yaml
```

### For GraphQL Schemas
```bash
# Generate TypeScript types
graphql-codegen --config codegen.yml
```

## Contract Versioning

All contracts follow semantic versioning:
- MAJOR: Breaking changes
- MINOR: New features (backwards compatible)
- PATCH: Bug fixes

Current versions are defined in each contract file's `info.version` field.