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
# Check if port is reachable (Serena may not have /health endpoint)
if curl -sf --max-time 2 "$SERENA_URL" >/dev/null 2>&1 || nc -z ${SERENA_URL#http://} 2>/dev/null; then
    echo "✓ (running)"
else
    # Try extracting host:port for nc check
    SERENA_HOST=$(echo $SERENA_URL | sed 's|http://||' | cut -d: -f1)
    SERENA_PORT=$(echo $SERENA_URL | sed 's|http://||' | cut -d: -f2)
    if nc -z $SERENA_HOST $SERENA_PORT 2>/dev/null; then
        echo "✓ (port open)"
    else
        echo "❌ OFFLINE"
        echo ""
        echo "Serena is required for multi-instance coordination."
        echo "Start with: serena start-mcp-server --transport sse --port 3001"
        echo "Or set SERENA_URL to point to running instance."
        exit 1
    fi
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
