#!/bin/bash
set -eo pipefail
PORT=3004
LOG_FILE="/tmp/filesystem-mcp.log"

echo "Starting Filesystem MCP Server on port $PORT..."

if nc -z localhost $PORT 2>/dev/null; then
    echo "Filesystem MCP already running on port $PORT"
    exit 0
fi

/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y @modelcontextprotocol/server-filesystem /home > "$LOG_FILE" 2>&1 </dev/null &

for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        FS_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Filesystem MCP started successfully (PID: $FS_PID)"
        echo $FS_PID > /tmp/filesystem-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Filesystem MCP"
cat "$LOG_FILE"
exit 1
