#!/bin/bash
# Start Skills MCP Server (using server-memory)
set -eo pipefail

PORT=3006
LOG_FILE="/tmp/skills-mcp.log"

echo "Starting Skills MCP Server on port $PORT..."

# Check if already running
if nc -z localhost $PORT 2>/dev/null; then
    echo "Skills MCP already running on port $PORT"
    exit 0
fi

# Start using server-memory for skills storage
nohup /home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y @modelcontextprotocol/server-memory > "$LOG_FILE" 2>&1 </dev/null &
SKILLS_PID=$!

# Wait for startup (retry up to 10 times = 5 seconds max)
for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
if nc -z localhost $PORT 2>/dev/null; then
        echo "✓ Skills MCP started successfully (PID: $SKILLS_PID)"
        exit 0
    fi
done

# If we get here, server failed to start
    echo "✗ Failed to start Skills MCP"
    cat "$LOG_FILE"
    exit 1
