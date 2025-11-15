#!/bin/bash
# Check status of all MCP servers

echo "Checking MCP servers..."

# Serena (CRITICAL)
if curl -s http://localhost:3001/health >/dev/null 2>&1; then
    echo "✓ Serena (port 3001)"
else
    echo "❌ Serena OFFLINE (CRITICAL)"
    exit 1
fi

# Playwright (for UI verification)
if curl -s http://localhost:9222 >/dev/null 2>&1; then
    echo "✓ Playwright (port 9222)"
else
    echo "⚠️  Playwright offline (UI verification unavailable)"
fi

echo "✅ Critical MCP servers running"
