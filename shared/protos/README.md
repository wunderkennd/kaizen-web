# Protocol Buffers Definitions

This directory contains Protocol Buffer (protobuf) definitions for gRPC services used for inter-service communication.

## Structure

```
protos/
├── common/           # Shared message types
│   ├── types.proto
│   └── errors.proto
├── services/         # Service definitions
│   ├── kre.proto
│   ├── user_context.proto
│   ├── pcm.proto
│   └── streaming.proto
└── build/           # Generated code (git-ignored)
```

## Building Protos

### Generate for Go
```bash
./scripts/protos/generate-go.sh
```

### Generate for Rust
```bash
./scripts/protos/generate-rust.sh
```

### Generate for Python
```bash
./scripts/protos/generate-python.sh
```

## Service Definitions

### KRE Engine Service
- Rule evaluation
- Rule management
- Real-time rule updates

### User Context Service
- Context retrieval
- Context updates
- History tracking

### PCM Classifier Service
- Stage classification
- Feature extraction
- Model inference

### Streaming Service
- Real-time event streaming
- WebSocket adapter
- Event routing

## Version Management

Proto files use the following versioning convention:
- Package name includes version: `kaizen.v1.service`
- Breaking changes increment major version
- New services/methods are backwards compatible