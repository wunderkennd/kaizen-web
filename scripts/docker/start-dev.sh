#!/bin/bash

# Start development environment with Docker Compose

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting KAIZEN development environment...${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Create necessary directories
mkdir -p services/{frontend,genui-orchestrator,kre-engine,user-context-service,pcm-classifier,ai-sommelier-service,streaming-adapter}
mkdir -p shared/{contracts,protos}
mkdir -p scripts/db/init

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cat > .env << EOF
# Development Environment Variables
NODE_ENV=development
DATABASE_URL=postgres://kaizen:kaizen_dev_password@localhost:5432/kaizen_db
REDIS_URL=redis://localhost:6379
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXT_PUBLIC_WS_URL=ws://localhost:4001
EOF
fi

# Pull latest images
echo -e "${YELLOW}Pulling latest Docker images...${NC}"
docker-compose pull

# Build services
echo -e "${YELLOW}Building services...${NC}"
docker-compose build

# Start services
echo -e "${YELLOW}Starting services...${NC}"
docker-compose up -d

# Wait for services to be healthy
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 5

# Check service status
docker-compose ps

echo -e "${GREEN}✅ Development environment started successfully!${NC}"
echo ""
echo "Services available at:"
echo "  • Frontend:         http://localhost:3000"
echo "  • GenUI API:        http://localhost:4000"
echo "  • Adminer (DB):     http://localhost:8081"
echo "  • Redis Commander:  http://localhost:8082"
echo ""
echo "To view logs: docker-compose logs -f [service-name]"
echo "To stop:      ./scripts/docker/stop-dev.sh"