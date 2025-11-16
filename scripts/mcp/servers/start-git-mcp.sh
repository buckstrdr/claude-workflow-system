#!/bin/bash
set -eo pipefail
PORT=3003
LOG_FILE="/tmp/git-mcp.log"

echo "Starting Git MCP Server on port $PORT..."

if nc -z localhost $PORT 2>/dev/null; then
    echo "Git MCP already running on port $PORT"
    exit 0
fi

# Start in background
/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /home/buckstrdr/.local/bin/uvx mcp-server-git > "$LOG_FILE" 2>&1 </dev/null &

# Wait for startup
for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        GIT_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Git MCP started successfully (PID: $GIT_PID)"
        echo $GIT_PID > /tmp/git-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Git MCP"
cat "$LOG_FILE"
exit 1
