#!/bin/bash
# Check status of all REMOTE MCP servers via HTTPS
# ALL MCP servers are remote - none managed by Claude CLI

set -euo pipefail

# Load environment variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

echo "==========================================="
echo "  Remote MCP Services Status Check"
echo "==========================================="
echo ""
echo "Architecture: Remote-Only HTTPS"
echo "All MCP servers accessed via HTTPS endpoints"
echo "NO local stdio servers managed by Claude CLI"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

# Function to check HTTPS endpoint
check_endpoint() {
    local name=$1
    local url=$2
    local required=$3
    local health_path=${4:-""}

    echo -n "Checking $name at $url... "

    if [ -z "$url" ] || [ "$url" = "http://localhost:0" ]; then
        if [ "$required" = "true" ]; then
            echo -e "${RED}✗ URL NOT CONFIGURED${NC}"
            ((FAIL++))
        else
            echo -e "${YELLOW}⚠ NOT CONFIGURED (optional)${NC}"
            ((WARN++))
        fi
        return
    fi

    # Try health endpoint if specified
    if [ -n "$health_path" ]; then
        if curl -sf --max-time 2 "${url}${health_path}" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ ONLINE${NC}"
            ((PASS++))
            return
        fi
    fi

    # Try base URL
    if curl -sf --max-time 2 "$url" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ONLINE${NC}"
        ((PASS++))
        return
    fi

    # Try port connectivity as fallback
    local host=$(echo "$url" | sed 's|http[s]*://||' | cut -d: -f1)
    local port=$(echo "$url" | sed 's|http[s]*://||' | cut -d: -f2 | cut -d/ -f1)

    if [ -n "$port" ] && nc -z "$host" "$port" 2>/dev/null; then
        echo -e "${YELLOW}⚠ PORT OPEN (no HTTP response)${NC}"
        ((WARN++))
        return
    fi

    # Service is offline
    if [ "$required" = "true" ]; then
        echo -e "${RED}✗ OFFLINE${NC}"
        ((FAIL++))
    else
        echo -e "${YELLOW}⚠ OFFLINE (optional)${NC}"
        ((WARN++))
    fi
}

echo "API Keys:"
echo "==========================================="

# Check API Keys
if [ -n "${FIRECRAWL_API_KEY:-}" ]; then
    echo -e "${GREEN}✓${NC} FIRECRAWL_API_KEY configured (${FIRECRAWL_API_KEY:0:10}...)"
    ((PASS++))
else
    echo -e "${RED}✗${NC} FIRECRAWL_API_KEY not set"
    ((FAIL++))
fi

if [ -n "${CONTEXT7_API_KEY:-}" ]; then
    echo -e "${GREEN}✓${NC} CONTEXT7_API_KEY configured (${CONTEXT7_API_KEY:0:10}...)"
    ((PASS++))
else
    echo -e "${YELLOW}⚠${NC} CONTEXT7_API_KEY not set (documentation retrieval unavailable)"
    ((WARN++))
fi

echo ""
echo "Remote MCP Servers (REQUIRED):"
echo "==========================================="

# Check required remote services
check_endpoint "Serena" "${SERENA_URL}" "true" ""
check_endpoint "Firecrawl" "${FIRECRAWL_URL}" "true" ""
check_endpoint "Git MCP" "${GIT_MCP_URL}" "true" ""
check_endpoint "Filesystem MCP" "${FILESYSTEM_MCP_URL}" "true" ""
check_endpoint "Terminal MCP" "${TERMINAL_MCP_URL}" "true" ""
check_endpoint "Skills MCP" "${SKILLS_MCP_URL}" "true" ""
check_endpoint "Agents MCP" "${AGENTS_MCP_URL}" "true" ""

echo ""
echo "Remote MCP Servers (OPTIONAL):"
echo "==========================================="

check_endpoint "Context7 API" "${CONTEXT7_URL:-https://api.context7.com}" "false" ""
check_endpoint "Playwright" "${PLAYWRIGHT_URL}" "false" "/"

echo ""
echo "==========================================="
echo "  Summary"
echo "==========================================="
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo -e "${RED}Failed:${NC} $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All critical MCP services ready${NC}"
    exit 0
else
    echo -e "${RED}❌ Some required services are offline or not configured${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review .env file for missing URLs"
    echo "2. Start required MCP servers (see .env for ports)"
    echo "3. Re-run this script to verify"
    exit 1
fi
