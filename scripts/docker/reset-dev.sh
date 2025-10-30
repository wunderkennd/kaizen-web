#!/bin/bash

# Reset development environment (clean slate)

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}⚠️  This will completely reset your development environment!${NC}"
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

echo -e "${YELLOW}Resetting KAIZEN development environment...${NC}"

# Stop and remove everything
docker-compose down -v --remove-orphans

# Remove all built images
echo -e "${YELLOW}Removing built images...${NC}"
docker-compose down --rmi local

# Clean up any dangling images
docker image prune -f

echo -e "${GREEN}✅ Development environment reset complete${NC}"
echo "Run ./scripts/docker/start-dev.sh to start fresh"