#!/bin/bash
set -eo pipefail
PORT=3007
LOG_FILE="/tmp/puppeteer-mcp.log"

echo "Starting Puppeteer MCP Server on port $PORT..."

if nc -z localhost $PORT 2>/dev/null; then
    echo "Puppeteer MCP already running on port $PORT"
    exit 0
fi

/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y @modelcontextprotocol/server-puppeteer > "$LOG_FILE" 2>&1 </dev/null &

for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        PP_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Puppeteer MCP started successfully (PID: $PP_PID)"
        echo $PP_PID > /tmp/puppeteer-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Puppeteer MCP"
cat "$LOG_FILE"
exit 1
