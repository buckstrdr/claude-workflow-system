#!/bin/bash
# Master script to start all MCP servers
set -uo pipefail

# EXTREME DEBUG MODE
exec 2> >(tee -a /tmp/start-all-debug.log >&2)
echo "=== START-ALL DEBUG $(date) ===" >> /tmp/start-all-debug.log
echo "PWD: $(pwd)" >> /tmp/start-all-debug.log
echo "SHELL: $SHELL" >> /tmp/start-all-debug.log
echo "BASH_VERSION: $BASH_VERSION" >> /tmp/start-all-debug.log
echo "PATH: $PATH" >> /tmp/start-all-debug.log

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVERS_DIR="$SCRIPT_DIR/servers"

echo "SCRIPT_DIR: $SCRIPT_DIR" >> /tmp/start-all-debug.log
echo "SERVERS_DIR: $SERVERS_DIR" >> /tmp/start-all-debug.log

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo -e "  Starting All MCP Servers"
echo -e "==========================================${NC}"
echo ""

# Make all server scripts executable
chmod +x "$SERVERS_DIR"/*.sh

# Array of servers to start
declare -a SERVERS=(
    "serena:Serena (Memory & Coordination)"
    "firecrawl:Firecrawl (Web Scraping)"
    "git-mcp:Git Operations"
    "filesystem-mcp:Filesystem Operations"
    "terminal-mcp:Terminal Execution"
    "playwright-mcp:Playwright (Browser Automation)"
    "puppeteer-mcp:Puppeteer (Headless Browser)"
    "context7-mcp:Context7 (Documentation Search)"
)

STARTED=0
FAILED=0

# Start each server
for server_info in "${SERVERS[@]}"; do
    IFS=':' read -r server_name server_desc <<< "$server_info"

    echo -e "${BLUE}Starting $server_desc...${NC}"

    # Run server start script directly (not backgrounded)
    echo ">>> Calling: $SERVERS_DIR/start-$server_name.sh" >> /tmp/start-all-debug.log
    echo ">>> Exists: $(test -f "$SERVERS_DIR/start-$server_name.sh" && echo YES || echo NO)" >> /tmp/start-all-debug.log
    echo ">>> Executable: $(test -x "$SERVERS_DIR/start-$server_name.sh" && echo YES || echo NO)" >> /tmp/start-all-debug.log

    if "$SERVERS_DIR/start-$server_name.sh" 2>> /tmp/start-all-debug.log; then
        ((STARTED++))
        echo ">>> SUCCESS: $server_name" >> /tmp/start-all-debug.log
    else
        EXIT_CODE=$?
        echo -e "${RED}✗ Failed to start $server_desc${NC}"
        ((FAILED++))
        echo ">>> FAILED: $server_name (exit code: $EXIT_CODE)" >> /tmp/start-all-debug.log
    fi

    echo ""
done

# Summary
echo -e "${BLUE}=========================================="
echo -e "  Startup Summary"
echo -e "==========================================${NC}"
echo -e "${GREEN}Started:${NC} $STARTED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All MCP servers started!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some servers failed to start${NC}"
    exit 1
fi
