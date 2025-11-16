#!/bin/bash
set -eo pipefail
PORT=3005
LOG_FILE="/tmp/terminal-mcp.log"

echo "Starting Terminal MCP Server on port $PORT..."

if nc -z localhost $PORT 2>/dev/null; then
    echo "Terminal MCP already running on port $PORT"
    exit 0
fi

# Start in background - using mcp-shell instead
/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y mcp-shell > "$LOG_FILE" 2>&1 </dev/null &

# Wait for startup
for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        TERM_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Terminal MCP started successfully (PID: $TERM_PID)"
        echo $TERM_PID > /tmp/terminal-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Terminal MCP"
cat "$LOG_FILE"
exit 1
