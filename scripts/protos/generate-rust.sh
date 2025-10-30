#!/bin/bash

# Generate Rust code from Protocol Buffers

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Paths
PROTO_DIR="../../shared/protos"
RUST_SERVICES=("kre-engine" "streaming-adapter")

echo -e "${YELLOW}Generating Rust code from Protocol Buffers...${NC}"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}protoc is not installed. Please install Protocol Buffers compiler.${NC}"
    echo "Visit: https://grpc.io/docs/protoc-installation/"
    exit 1
fi

# Generate for each Rust service
for service in "${RUST_SERVICES[@]}"; do
    SERVICE_DIR="../../services/$service"
    OUTPUT_DIR="$SERVICE_DIR/src/proto"
    
    if [ -d "$SERVICE_DIR" ]; then
        echo "Generating for $service..."
        
        # Create output directory
        mkdir -p "$OUTPUT_DIR"
        
        # Create build.rs file for the service
        cat > "$SERVICE_DIR/build.rs" << 'EOF'
use std::io::Result;

fn main() -> Result<()> {
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .compile(
            &[
                "../../shared/protos/common/types.proto",
                "../../shared/protos/services/kre.proto",
            ],
            &["../../shared/protos"],
        )?;
    Ok(())
}
EOF
        
        # Add dependencies to Cargo.toml if not present
        if ! grep -q "tonic" "$SERVICE_DIR/Cargo.toml" 2>/dev/null; then
            echo -e "${YELLOW}Adding tonic dependencies to $service/Cargo.toml${NC}"
            cat >> "$SERVICE_DIR/Cargo.toml" << 'EOF'

[dependencies]
tonic = "0.10"
prost = "0.12"
tokio = { version = "1", features = ["full"] }
tokio-stream = "0.1"

[build-dependencies]
tonic-build = "0.10"
EOF
        fi
        
        echo -e "${GREEN}✓ Generated Rust code for $service${NC}"
    else
        echo -e "${YELLOW}Skipping $service (directory not found)${NC}"
    fi
done

echo -e "${GREEN}✅ Rust code generation complete!${NC}"