#!/bin/bash
# Semantic Index Refresh Hook - Auto-refreshes index after significant changes

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Count changed Python/TypeScript files
CHANGED_COUNT=$(git diff --cached --name-only | grep -E "\.(py|ts|tsx)$" | wc -l)

# Threshold for triggering refresh (10+ files = significant change)
THRESHOLD=10

if [ "$CHANGED_COUNT" -ge "$THRESHOLD" ]; then
    echo -e "${YELLOW}📊 Significant code changes detected ($CHANGED_COUNT files)${NC}"
    echo -e "${YELLOW}   Refreshing semantic index...${NC}"

    # Run incremental semantic update
    if make semantic 2>&1 | tail -5; then
        echo -e "${GREEN}✓ Semantic index refreshed${NC}"

        # Stage updated index
        git add .serena/graphs/semantic*.{json,index} 2>/dev/null
    else
        echo -e "${YELLOW}⚠️  Semantic refresh failed (non-blocking)${NC}"
    fi
else
    echo -e "${GREEN}✓ Code changes < $THRESHOLD files - skipping semantic refresh${NC}"
fi

exit 0
