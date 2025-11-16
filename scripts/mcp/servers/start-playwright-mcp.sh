#!/bin/bash
set -eo pipefail
PORT=3006
LOG_FILE="/tmp/playwright-mcp.log"

echo "Starting Playwright MCP Server on port $PORT..."

if nc -z localhost $PORT 2>/dev/null; then
    echo "Playwright MCP already running on port $PORT"
    exit 0
fi

/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y @executeautomation/playwright-mcp-server > "$LOG_FILE" 2>&1 </dev/null &

for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        PW_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Playwright MCP started successfully (PID: $PW_PID)"
        echo $PW_PID > /tmp/playwright-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Playwright MCP"
cat "$LOG_FILE"
exit 1
