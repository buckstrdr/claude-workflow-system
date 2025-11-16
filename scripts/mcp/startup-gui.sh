#!/bin/bash
# Interactive MCP Startup GUI
# Provides visual feedback and control for starting MCP servers

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

# Clear screen
clear

# Function to draw header
draw_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}Claude Multi-Instance Orchestration System${NC}        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}MCP Server Startup Manager${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

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

# Function to display server status table
display_status() {
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
}

# Function to check if all servers are running
all_servers_ready() {
    for port in 3001 3002 3003 3004 3005 3006 3007; do
        if ! nc -z localhost $port 2>/dev/null; then
            return 1
        fi
    done
    return 0
}

# Function to start all servers with progress
start_all_servers() {
    echo ""
    echo -e "${BLUE}Starting MCP Servers...${NC}"
    echo ""

    "$SCRIPT_DIR/start-all-mcp.sh"

    echo ""
    echo -e "${GREEN}Verifying all services...${NC}"
    sleep 2
}

# Function to show menu
show_menu() {
    echo -e "${BOLD}Options:${NC}"
    echo ""
    echo -e "  ${GREEN}[1]${NC} Start All MCP Servers"
    echo -e "  ${CYAN}[2]${NC} Refresh Status"
    echo -e "  ${YELLOW}[3]${NC} View Server Logs"
    echo -e "  ${GREEN}[4]${NC} Launch Orchestrator (if servers ready)"
    echo -e "  ${RED}[Q]${NC} Quit"
    echo ""
}

# Function to show green light
show_green_light() {
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                   ${BOLD}${GREEN}✅ ALL SYSTEMS GO${NC}                     ${GREEN}║${NC}"
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  All MCP servers are running and verified!           ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  System is ready to launch the orchestrator.         ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to show red light
show_red_light() {
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}                   ${BOLD}${RED}⚠️  SERVERS NOT READY${NC}                ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Some MCP servers are offline. Start them first.${NC}"
    echo ""
}

# Function to view logs
view_logs() {
    clear
    draw_header
    echo -e "${BOLD}Select log to view:${NC}"
    echo ""
    echo "  [1] Serena"
    echo "  [2] Firecrawl"
    echo "  [3] Git MCP"
    echo "  [4] Filesystem MCP"
    echo "  [5] Terminal MCP"
    echo "  [6] Skills MCP"
    echo "  [7] Agents MCP"
    echo "  [B] Back to menu"
    echo ""
    echo -n "Choose: "
    read -r log_choice

    case $log_choice in
        1) less /tmp/serena-mcp.log 2>/dev/null || echo "No log file found" ;;
        2) less /tmp/firecrawl-mcp.log 2>/dev/null || echo "No log file found" ;;
        3) less /tmp/git-mcp.log 2>/dev/null || echo "No log file found" ;;
        4) less /tmp/filesystem-mcp.log 2>/dev/null || echo "No log file found" ;;
        5) less /tmp/terminal-mcp.log 2>/dev/null || echo "No log file found" ;;
        6) less /tmp/skills-mcp.log 2>/dev/null || echo "No log file found" ;;
        7) less /tmp/agents-mcp.log 2>/dev/null || echo "No log file found" ;;
    esac
}

# Function to launch orchestrator
launch_orchestrator() {
    if all_servers_ready; then
        echo ""
        echo -e "${GREEN}Launching orchestrator...${NC}"
        echo -e "${YELLOW}Enter feature name:${NC} "
        read -r feature_name

        if [ -z "$feature_name" ]; then
            echo -e "${RED}Feature name required${NC}"
            sleep 2
            return
        fi

        echo -e "${BLUE}Starting bootstrap for: $feature_name${NC}"
        sleep 1

        # Launch bootstrap
        cd "$(git rev-parse --show-toplevel)"
        exec ./bootstrap.sh "$feature_name"
    else
        echo ""
        echo -e "${RED}Cannot launch orchestrator - servers not ready${NC}"
        sleep 2
    fi
}

# Main loop
while true; do
    clear
    draw_header
    display_status
    echo ""

    if all_servers_ready; then
        show_green_light
    else
        show_red_light
    fi

    show_menu
    echo -n "Choose option: "
    read -r choice

    case $choice in
        1)
            start_all_servers
            echo ""
            echo -e "${CYAN}Press Enter to continue...${NC}"
            read -r
            ;;
        2)
            # Refresh happens automatically on loop
            ;;
        3)
            view_logs
            ;;
        4)
            launch_orchestrator
            ;;
        q|Q)
            echo ""
            echo -e "${CYAN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            ;;
    esac
done
