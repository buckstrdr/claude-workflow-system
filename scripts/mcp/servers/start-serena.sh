#!/bin/bash
# Start Serena MCP Server
set -eo pipefail

PORT=3001
LOG_FILE="/tmp/serena-mcp.log"

echo "Starting Serena MCP Server on port $PORT..."

# Check if already running
if nc -z localhost $PORT 2>/dev/null; then
    echo "Serena already running on port $PORT"
    exit 0
fi

# Start Serena in background (fully detached)
/home/buckstrdr/.local/bin/serena start-mcp-server --transport sse --port $PORT > "$LOG_FILE" 2>&1 </dev/null &
sleep 1
# Get the PID from the process list
SERENA_PID=$(pgrep -f "serena start-mcp-server.*$PORT" | head -1)

# Wait for startup (retry up to 10 times = 5 seconds max)
for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        echo "✓ Serena started successfully (PID: $SERENA_PID)"
        echo $SERENA_PID > /tmp/serena-mcp.pid
        exit 0
    fi
done

# If we get here, server failed to start
echo "✗ Failed to start Serena"
cat "$LOG_FILE"
exit 1
