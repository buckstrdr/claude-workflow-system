#!/bin/bash
# Master bootstrap script

set -euo pipefail

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: $0 <feature_name>"
    exit 1
fi

echo "=== Claude Multi-Instance Bootstrap ==="
echo "Feature: $FEATURE_NAME"
echo ""

# Check if all MCP servers are running
echo "Checking MCP servers..."
SERVERS_READY=true
for port in 3001 3002 3003 3004 3005 3006 3007 3008; do
    if ! nc -z localhost $port 2>/dev/null; then
        SERVERS_READY=false
        break
    fi
done

if [ "$SERVERS_READY" = false ]; then
    echo ""
    echo "❌ MCP servers are not all running!"
    echo ""
    echo "Please run the startup GUI first:"
    echo "  ./start.sh"
    echo ""
    echo "Or start servers manually:"
    echo "  ./scripts/mcp/start-all-mcp.sh"
    echo ""
    exit 1
fi

echo "✅ All MCP servers online"
echo ""

# Run all bootstrap steps
for script in scripts/bootstrap/*.sh; do
    echo "Running: $(basename $script)"
    "$script" "$FEATURE_NAME" || {
        echo "❌ Bootstrap failed at: $(basename $script)"
        exit 1
    }
    echo ""
done

echo "✅ Bootstrap complete!"
tmux attach-session -t "claude-feature-$FEATURE_NAME:w0-orchestrator" 2>/dev/null || \
tmux attach-session -t "claude-feature-$FEATURE_NAME"
