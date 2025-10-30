#!/bin/bash

# Generate Python code from Protocol Buffers

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
PROTO_DIR="../../shared/protos"
PYTHON_SERVICES=("pcm-classifier" "ai-sommelier-service")

echo -e "${YELLOW}Generating Python code from Protocol Buffers...${NC}"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}protoc is not installed. Please install Protocol Buffers compiler.${NC}"
    echo "Visit: https://grpc.io/docs/protoc-installation/"
    exit 1
fi

# Install Python gRPC tools if needed
pip_install_if_needed() {
    if ! pip show "$1" &> /dev/null; then
        echo -e "${YELLOW}Installing $1...${NC}"
        pip install "$1"
    fi
}

pip_install_if_needed "grpcio"
pip_install_if_needed "grpcio-tools"

# Generate for each Python service
for service in "${PYTHON_SERVICES[@]}"; do
    SERVICE_DIR="../../services/$service"
    OUTPUT_DIR="$SERVICE_DIR/src/proto"
    
    if [ -d "$SERVICE_DIR" ] || [ "$service" == "pcm-classifier" ] || [ "$service" == "ai-sommelier-service" ]; then
        # Create service directory if it doesn't exist
        mkdir -p "$SERVICE_DIR"
        echo "Generating for $service..."
        
        # Create output directory
        mkdir -p "$OUTPUT_DIR"
        
        # Generate Python code
        cd "$PROTO_DIR"
        python -m grpc_tools.protoc \
            -I. \
            --python_out="$OUTPUT_DIR" \
            --grpc_python_out="$OUTPUT_DIR" \
            common/types.proto \
            services/kre.proto
        
        # Create __init__.py files
        touch "$OUTPUT_DIR/__init__.py"
        
        # Fix imports in generated files
        cd "$OUTPUT_DIR"
        for file in *_pb2*.py; do
            if [ -f "$file" ]; then
                # Fix relative imports
                sed -i.bak 's/^import \([a-z_]*\)_pb2/from . import \1_pb2/' "$file"
                rm "${file}.bak"
            fi
        done
        
        echo -e "${GREEN}✓ Generated Python code for $service${NC}"
    else
        echo -e "${YELLOW}Skipping $service (directory not found)${NC}"
    fi
done

echo -e "${GREEN}✅ Python code generation complete!${NC}"