#!/bin/bash
# Verify all remote MCP servers are operational

echo "=== Remote MCP Server Verification ==="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Server list
SERVERS=(
    "Serena|3001|Memory & Coordination"
    "Firecrawl|3002|Web Scraping"
    "Git MCP|3003|Git Operations"
    "Filesystem MCP|3004|File Operations"
    "Terminal MCP|3005|Terminal Execution"
    "Playwright MCP|3006|Browser Automation"
    "Puppeteer MCP|3007|Headless Browser"
    "Context7 MCP|3008|Documentation Search"
)

ALL_OK=true
PASS=0
FAIL=0

echo "Checking MCP servers..."
echo ""
printf "%-20s %-10s %-30s %s\n" "SERVER" "PORT" "DESCRIPTION" "STATUS"
echo "────────────────────────────────────────────────────────────────────────"

for server_info in "${SERVERS[@]}"; do
    name=$(echo "$server_info" | cut -d'|' -f1)
    port=$(echo "$server_info" | cut -d'|' -f2)
    desc=$(echo "$server_info" | cut -d'|' -f3)

    # Check if port is listening
    if nc -z localhost "$port" 2>/dev/null; then
        printf "%-20s %-10s %-30s ${GREEN}✓ ONLINE${NC}\n" "$name" "$port" "$desc"
        ((PASS++))
    else
        printf "%-20s %-10s %-30s ${RED}✗ OFFLINE${NC}\n" "$name" "$port" "$desc"
        ((FAIL++))
        ALL_OK=false
    fi
done

echo ""
echo "────────────────────────────────────────────────────────────────────────"
echo ""

if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}🟢 ✅ ALL SYSTEMS GO${NC}"
    echo ""
    echo "All $PASS MCP servers are online and ready."
    echo ""
    echo "You can now:"
    echo "  1. Launch the GUI: ./start.sh"
    echo "  2. Or run bootstrap directly: ./bootstrap.sh <feature-name>"
    echo ""
    exit 0
else
    echo -e "${RED}🔴 ❌ SOME SERVERS DOWN${NC}"
    echo ""
    echo "Status: $PASS online, $FAIL offline"
    echo ""
    echo "To start missing servers:"
    echo "  ./scripts/mcp/start-all-mcp.sh"
    echo ""
    exit 1
fi
