#!/bin/bash
# Start Agents MCP Server (using sequential-thinking)
set -eo pipefail

PORT=3007
LOG_FILE="/tmp/agents-mcp.log"

echo "Starting Agents MCP Server on port $PORT..."

# Check if already running
if nc -z localhost $PORT 2>/dev/null; then
    echo "Agents MCP already running on port $PORT"
    exit 0
fi

# Start using server-sequential-thinking for agent coordination
nohup /home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y @modelcontextprotocol/server-sequential-thinking > "$LOG_FILE" 2>&1 </dev/null &
AGENTS_PID=$!

# Wait for startup (retry up to 10 times = 5 seconds max)
for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
if nc -z localhost $PORT 2>/dev/null; then
        echo "✓ Agents MCP started successfully (PID: $AGENTS_PID)"
        exit 0
    fi
done

# If we get here, server failed to start
    echo "✗ Failed to start Agents MCP"
    cat "$LOG_FILE"
    exit 1
