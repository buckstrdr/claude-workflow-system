#!/bin/bash
# Stop all MCP servers

set -uo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo -e "  Stopping All MCP Servers"
echo -e "==========================================${NC}"
echo ""

STOPPED=0

# Function to stop server by PID file
stop_server() {
    local name=$1
    local pid_file="/tmp/${name}-mcp.pid"

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo -e "Stopping $name (PID: $pid)..."
            kill "$pid" 2>/dev/null || true
            sleep 1
            if ps -p "$pid" > /dev/null 2>&1; then
                kill -9 "$pid" 2>/dev/null || true
            fi
            rm -f "$pid_file"
            ((STOPPED++))
            echo -e "${GREEN}✓${NC} Stopped $name"
        else
            rm -f "$pid_file"
            echo -e "${RED}✗${NC} $name not running (stale PID file removed)"
        fi
    else
        echo -e "${RED}✗${NC} $name PID file not found"
    fi
}

# Stop each server
stop_server "serena"
stop_server "firecrawl"
stop_server "git-mcp"
stop_server "filesystem-mcp"
stop_server "terminal-mcp"
stop_server "playwright-mcp"
stop_server "puppeteer-mcp"
stop_server "context7-mcp"

echo ""
echo -e "${BLUE}=========================================="
echo -e "  Summary"
echo -e "==========================================${NC}"
echo -e "${GREEN}Stopped:${NC} $STOPPED servers"
echo ""

# Also kill any remaining processes (cleanup)
echo -e "${BLUE}Cleaning up any remaining MCP processes...${NC}"
pkill -f "mcp-proxy" 2>/dev/null && echo "  ✓ Killed mcp-proxy processes" || true
pkill -f "serena.*mcp-server" 2>/dev/null && echo "  ✓ Killed serena processes" || true

echo ""
echo -e "${GREEN}✅ All MCP servers stopped${NC}"
