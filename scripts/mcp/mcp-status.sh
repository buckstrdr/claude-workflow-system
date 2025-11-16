#!/bin/bash
# Check status of all MCP servers (supports remote servers)

set -euo pipefail

echo "Checking MCP servers..."

# Load server URLs from environment or defaults
SERENA_URL="${SERENA_URL:-http://localhost:3001}"
PLAYWRIGHT_URL="${PLAYWRIGHT_URL:-http://localhost:9222}"

# Check Serena (CRITICAL)
echo -n "Checking Serena at $SERENA_URL... "
if curl -sf "$SERENA_URL/health" >/dev/null 2>&1; then
    echo "✓"
else
    echo "❌ OFFLINE (CRITICAL)"
    echo ""
    echo "Serena is required for multi-instance coordination."
    echo "Set SERENA_URL environment variable if using remote server."
    echo "Example: export SERENA_URL=http://your-server:3001"
    exit 1
fi

# Check Playwright (OPTIONAL)
echo -n "Checking Playwright at $PLAYWRIGHT_URL... "
if curl -sf "$PLAYWRIGHT_URL/" >/dev/null 2>&1; then
    echo "✓"
else
    echo "⚠️  OFFLINE (UI verification unavailable)"
fi

# MCP stdio servers (filesystem, git, terminal) are managed by Claude Code CLI
echo "✓ MCP stdio servers managed by Claude Code CLI"

echo ""
echo "✅ All critical MCP servers ready"
