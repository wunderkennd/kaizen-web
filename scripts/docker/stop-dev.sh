#!/bin/bash

# Stop development environment

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping KAIZEN development environment...${NC}"

# Stop services
docker-compose down

echo -e "${GREEN}✅ Development environment stopped${NC}"

# Ask if user wants to remove volumes
read -p "Remove data volumes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Removing volumes...${NC}"
    docker-compose down -v
    echo -e "${GREEN}✅ Volumes removed${NC}"
fi