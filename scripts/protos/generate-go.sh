#!/bin/bash

# Generate Go code from Protocol Buffers

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
PROTO_DIR="../../shared/protos"
OUTPUT_DIR="../../pkg/proto"

echo -e "${YELLOW}Generating Go code from Protocol Buffers...${NC}"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}protoc is not installed. Please install Protocol Buffers compiler.${NC}"
    echo "Visit: https://grpc.io/docs/protoc-installation/"
    exit 1
fi

# Check if Go plugins are installed
if ! command -v protoc-gen-go &> /dev/null; then
    echo -e "${YELLOW}Installing protoc-gen-go...${NC}"
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo -e "${YELLOW}Installing protoc-gen-go-grpc...${NC}"
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate Go code
cd "$PROTO_DIR"

# Find all .proto files
proto_files=$(find . -name "*.proto")

for proto in $proto_files; do
    echo "Processing $proto..."
    protoc \
        --go_out="$OUTPUT_DIR" \
        --go_opt=paths=source_relative \
        --go-grpc_out="$OUTPUT_DIR" \
        --go-grpc_opt=paths=source_relative \
        -I. \
        "$proto"
done

echo -e "${GREEN}✅ Go code generation complete!${NC}"
echo "Generated files in: $OUTPUT_DIR"