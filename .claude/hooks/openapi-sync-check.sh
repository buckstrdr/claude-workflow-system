#!/bin/bash
# OpenAPI Sync Check - Alerts if OpenAPI spec out of sync with FE types

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

OPENAPI_FILE=".serena/knowledge/openapi.json"
TYPES_FILE="topstepx_frontend/src/types/api.d.ts"

if [ ! -f "$OPENAPI_FILE" ] || [ ! -f "$TYPES_FILE" ]; then
    exit 0
fi

# Compare modification times
OPENAPI_MOD=$(stat -c %Y "$OPENAPI_FILE" 2>/dev/null || stat -f %m "$OPENAPI_FILE" 2>/dev/null)
TYPES_MOD=$(stat -c %Y "$TYPES_FILE" 2>/dev/null || stat -f %m "$TYPES_FILE" 2>/dev/null)

if [ "$OPENAPI_MOD" -gt "$TYPES_MOD" ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}✗ Frontend types OUT OF SYNC with OpenAPI spec${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}OpenAPI spec modified: $(date -d @$OPENAPI_MOD 2>/dev/null || date -r $OPENAPI_MOD)${NC}"
    echo -e "${YELLOW}Types generated:       $(date -d @$TYPES_MOD 2>/dev/null || date -r $TYPES_MOD)${NC}"
    echo ""
    echo -e "${YELLOW}To sync: make types${NC}"
    echo ""
    read -p "Continue without syncing? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ Commit blocked - Run: make types${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Frontend types synced with OpenAPI${NC}"
fi

exit 0
