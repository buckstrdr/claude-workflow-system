#!/bin/bash
# Asynchronous startup - starts all servers and exits immediately

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVERS_DIR="$SCRIPT_DIR/servers"

# Start all servers individually in background
for server in serena firecrawl git-mcp filesystem-mcp terminal-mcp playwright-mcp puppeteer-mcp context7-mcp; do
    nohup "$SERVERS_DIR/start-$server.sh" >/dev/null 2>&1 </dev/null &
    disown
done

echo "All MCP servers starting in background..."
echo "Check status with: ./scripts/mcp/verify-remote-mcp.sh"
exit 0
