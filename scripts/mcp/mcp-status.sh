#!/bin/bash
# Check status of all MCP servers and API keys

set -euo pipefail

echo "Checking MCP configuration..."
echo ""

# Check API Keys
echo "API Keys:"
if [ -n "${FIRECRAWL_API_KEY:-}" ]; then
    echo "✓ FIRECRAWL_API_KEY configured (${FIRECRAWL_API_KEY:0:10}...)"
else
    echo "❌ FIRECRAWL_API_KEY not set"
    echo "   Add to .env: FIRECRAWL_API_KEY=fc-your-key"
    exit 1
fi

if [ -n "${CONTEXT7_API_KEY:-}" ]; then
    echo "✓ CONTEXT7_API_KEY configured (${CONTEXT7_API_KEY:0:10}...)"
else
    echo "⚠️  CONTEXT7_API_KEY not set (documentation retrieval unavailable)"
fi

echo ""
echo "MCP Stdio Services (managed by Claude CLI):"
echo "✓ Firecrawl MCP (npx -y firecrawl-mcp)"
echo "✓ Git MCP"
echo "✓ Filesystem MCP"
echo "✓ Terminal MCP"

echo ""
echo "Remote MCP Servers:"

# Load server URLs from environment or defaults
SERENA_URL="${SERENA_URL:-http://localhost:3001}"
PLAYWRIGHT_URL="${PLAYWRIGHT_URL:-http://localhost:9222}"

# Check Serena (CRITICAL)
echo -n "Serena at $SERENA_URL... "
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
echo -n "Playwright at $PLAYWRIGHT_URL... "
if curl -sf "$PLAYWRIGHT_URL/" >/dev/null 2>&1; then
    echo "✓"
else
    echo "⚠️  OFFLINE (UI verification unavailable)"
fi

echo ""
echo "✅ All critical MCP services ready"
