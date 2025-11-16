#!/bin/bash
set -eo pipefail
PORT=3009
LOG_FILE="/tmp/hf-mcp.log"
echo "Starting Hugging Face MCP Server on port $PORT..."

# Source .env if it exists to get HF_TOKEN
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

if nc -z localhost $PORT 2>/dev/null; then
    echo "Hugging Face MCP already running on port $PORT"
    exit 0
fi

# Start HF MCP in background (fully detached)
# Set TRANSPORT=stdio to disable the dashboard server
# Pass env vars through to /usr/bin/npx command
/home/buckstrdr/.local/bin/mcp-proxy --host 127.0.0.1 --port $PORT -- env TRANSPORT=stdio /usr/bin/npx -y @llmindset/hf-mcp-server > "$LOG_FILE" 2>&1 </dev/null &
sleep 1

# Wait for startup (retry up to 20 times = 10 seconds max)
for i in {1..20}; do
    sleep 0.5
    if nc -z localhost $PORT 2>/dev/null; then
        HF_PID=$(pgrep -f "mcp-proxy.*$PORT" | head -1)
        echo "✓ Hugging Face MCP started successfully (PID: $HF_PID)"
        echo $HF_PID > /tmp/hf-mcp.pid
        exit 0
    fi
done

echo "✗ Failed to start Hugging Face MCP"
cat "$LOG_FILE"
exit 1
