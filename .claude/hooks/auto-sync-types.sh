#!/bin/bash
# Auto-Sync Types Hook - Regenerates FE types when backend API changes

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if backend API files changed
API_CHANGED=$(git diff --cached --name-only | grep -E "topstepx_backend/api/(routes|schemas)/.*\.py$" | wc -l)

if [ "$API_CHANGED" -gt 0 ]; then
    echo -e "${YELLOW}🔄 Backend API changes detected - syncing types...${NC}"

    # Generate OpenAPI spec
    make openapi

    # Generate FE types
    make types

    # Stage the updated types
    git add .serena/knowledge/openapi.json
    git add topstepx_frontend/src/types/api.d.ts

    echo -e "${GREEN}✓ Types synced and staged${NC}"
fi

exit 0
