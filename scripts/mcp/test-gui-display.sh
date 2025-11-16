#!/bin/bash
# Test GUI display without interactive mode
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Draw header
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}Claude Multi-Instance Orchestration System${NC}        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  ${BOLD}MCP Server Startup Manager${NC}                        ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check server status
check_server_status() {
    local port=$1
    if nc -z localhost $port 2>/dev/null; then
        echo -e "${GREEN}●${NC} ONLINE"
        return 0
    else
        echo -e "${RED}●${NC} OFFLINE"
        return 1
    fi
}

# Display status
echo -e "${BOLD}Current MCP Server Status:${NC}"
echo ""
echo -e "  ${BOLD}Service${NC}              ${BOLD}Port${NC}    ${BOLD}Status${NC}"
echo -e "  ────────────────────────────────────────"
echo -en "  Serena              3001    "
check_server_status 3001 || true
echo -en "  Firecrawl           3002    "
check_server_status 3002 || true
echo -en "  Git MCP             3003    "
check_server_status 3003 || true
echo -en "  Filesystem MCP      3004    "
check_server_status 3004 || true
echo -en "  Terminal MCP        3005    "
check_server_status 3005 || true
echo -en "  Skills MCP          3006    "
check_server_status 3006 || true
echo -en "  Agents MCP          3007    "
check_server_status 3007 || true
echo ""

# Check if all ready
ALL_READY=true
for port in 3001 3002 3003 3004 3005 3006 3007; do
    if ! nc -z localhost $port 2>/dev/null; then
        ALL_READY=false
        break
    fi
done

if [ "$ALL_READY" = true ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                   ${BOLD}${GREEN}✅ ALL SYSTEMS GO${NC}                     ${GREEN}║${NC}"
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  All MCP servers are running and verified!           ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  System is ready to launch the orchestrator.         ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}                   ${BOLD}${RED}⚠️  SERVERS NOT READY${NC}                ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Some MCP servers are offline. Start them first.${NC}"
fi

echo ""
