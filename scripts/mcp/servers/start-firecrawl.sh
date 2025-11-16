#!/bin/bash
set -eo pipefail
PORT=3002
LOG_FILE="/tmp/firecrawl-mcp.log"

echo "Starting Firecrawl MCP Server on port $PORT..."

# Load .env
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

if nc -z localhost $PORT 2>/dev/null; then
    echo "Firecrawl already running on port $PORT"
    exit 0
fi

# Start in background
# Force use of system /usr/bin/npx to avoid nvm version issues
/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- /usr/bin/npx -y @mzxrai/mcp-webresearch > "$LOG_FILE" 2>&1 </dev/null &

# Wait for startup
for i in {1..10}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        FIRECRAWL_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Firecrawl started successfully (PID: $FIRECRAWL_PID)"
        echo $FIRECRAWL_PID > /tmp/firecrawl-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Firecrawl"
cat "$LOG_FILE"
exit 1
