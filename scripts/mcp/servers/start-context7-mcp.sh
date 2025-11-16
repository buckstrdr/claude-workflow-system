#!/bin/bash
set -eo pipefail
PORT=3008
LOG_FILE="/tmp/context7-mcp.log"

echo "Starting Context7 MCP Server on port $PORT..."

# Load .env for CONTEXT7_API_KEY
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

if nc -z localhost $PORT 2>/dev/null; then
    echo "Context7 MCP already running on port $PORT"
    exit 0
fi

# Start in background - using @upstash/context7-mcp
/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y @upstash/context7-mcp > "$LOG_FILE" 2>&1 </dev/null &

# Wait for startup
for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        CTX_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Context7 MCP started successfully (PID: $CTX_PID)"
        echo $CTX_PID > /tmp/context7-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Context7 MCP"
cat "$LOG_FILE"
exit 1
