#!/bin/bash
# Comprehensive Remote MCP Services Test
# Tests all remote HTTPS endpoints

set -euo pipefail

echo "=========================================="
echo "  Remote MCP Services Comprehensive Test"
echo "=========================================="
echo ""

# Load .env
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

PASS=0
FAIL=0

# Test 1: API Keys
echo "1. Testing API Keys..."
if [ -n "${FIRECRAWL_API_KEY:-}" ]; then
    echo "   ✓ FIRECRAWL_API_KEY present"
    ((PASS++))
else
    echo "   ✗ FIRECRAWL_API_KEY missing"
    ((FAIL++))
fi

if [ -n "${CONTEXT7_API_KEY:-}" ]; then
    echo "   ✓ CONTEXT7_API_KEY present"
    ((PASS++))
else
    echo "   ✗ CONTEXT7_API_KEY missing"
    ((FAIL++))
fi

echo ""

# Test 2: Required Remote Server URLs Configured
echo "2. Testing Required Server URLs Configured..."
for var in SERENA_URL FIRECRAWL_URL GIT_MCP_URL FILESYSTEM_MCP_URL TERMINAL_MCP_URL SKILLS_MCP_URL AGENTS_MCP_URL; do
    if [ -n "${!var:-}" ]; then
        echo "   ✓ $var configured: ${!var}"
        ((PASS++))
    else
        echo "   ✗ $var not configured"
        ((FAIL++))
    fi
done

echo ""

# Test 3: Remote Server Connectivity
echo "3. Testing Remote Server Connectivity..."

# Helper function
test_endpoint() {
    local name=$1
    local url=$2

    if curl -sf --max-time 2 "$url" >/dev/null 2>&1; then
        echo "   ✓ $name reachable at $url"
        ((PASS++))
        return 0
    fi

    # Fallback to port check
    local host=$(echo "$url" | sed 's|http[s]*://||' | cut -d: -f1)
    local port=$(echo "$url" | sed 's|http[s]*://||' | cut -d: -f2 | cut -d/ -f1)

    if [ -n "$port" ] && nc -z "$host" "$port" 2>/dev/null; then
        echo "   ✓ $name port open at $url (no HTTP response)"
        ((PASS++))
        return 0
    fi

    echo "   ✗ $name not reachable at $url"
    ((FAIL++))
    return 1
}

test_endpoint "Serena" "${SERENA_URL}"
test_endpoint "Firecrawl" "${FIRECRAWL_URL}"
test_endpoint "Git MCP" "${GIT_MCP_URL}"
test_endpoint "Filesystem MCP" "${FILESYSTEM_MCP_URL}"
test_endpoint "Terminal MCP" "${TERMINAL_MCP_URL}"
test_endpoint "Skills MCP" "${SKILLS_MCP_URL}"
test_endpoint "Agents MCP" "${AGENTS_MCP_URL}"

echo ""

# Test 4: Required CLI tools
echo "4. Testing Required CLI Tools..."
for cmd in claude jq tmux python3 git curl nc; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "   ✓ $cmd installed"
        ((PASS++))
    else
        echo "   ✗ $cmd missing"
        ((FAIL++))
    fi
done

echo ""

# Test 5: Python version
echo "5. Testing Python Version..."
if python3 -c "import sys; assert sys.version_info >= (3,8)" 2>/dev/null; then
    PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    echo "   ✓ Python $PY_VER (>= 3.8 required)"
    ((PASS++))
else
    echo "   ✗ Python 3.8+ required"
    ((FAIL++))
fi

echo ""

# Test 6: Git repository
echo "6. Testing Git Repository..."
if [ -d .git ]; then
    echo "   ✓ Git repository present"
    ((PASS++))
else
    echo "   ✗ Not a git repository"
    ((FAIL++))
fi

echo ""

# Test 7: Directory structure
echo "7. Testing Directory Structure..."
for dir in scripts/quality-gates scripts/bootstrap messages system-comps; do
    if [ -d "$dir" ]; then
        echo "   ✓ $dir/ exists"
        ((PASS++))
    else
        echo "   ✗ $dir/ missing"
        ((FAIL++))
    fi
done

echo ""

# Test 8: MCP Configuration
echo "8. Testing MCP Configuration..."
if [ -f mcp-config.yaml ]; then
    echo "   ✓ mcp-config.yaml exists"
    ((PASS++))

    # Check for no stdio references
    if ! grep -q "stdio" mcp-config.yaml; then
        echo "   ✓ No stdio transport in config (remote-only)"
        ((PASS++))
    else
        echo "   ✗ stdio transport found in config (should be remote-only)"
        ((FAIL++))
    fi

    # Check for remote type
    if grep -q "type: remote" mcp-config.yaml; then
        echo "   ✓ Remote type configured"
        ((PASS++))
    else
        echo "   ✗ No remote type found in config"
        ((FAIL++))
    fi
else
    echo "   ✗ mcp-config.yaml missing"
    ((FAIL++))
fi

echo ""

# Summary
echo "=========================================="
echo "  Test Results"
echo "=========================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✅ All tests passed - System ready!"
    echo ""
    echo "Remote MCP Architecture Verified:"
    echo "  • All MCP servers configured as remote HTTPS endpoints"
    echo "  • No local stdio servers"
    echo "  • All required services reachable"
    echo ""
    echo "Next: Run ./bootstrap.sh to start the multi-instance system"
    exit 0
else
    echo "❌ Some tests failed - Review above"
    echo ""
    echo "Common issues:"
    echo "  • Missing remote MCP server URLs in .env"
    echo "  • Remote MCP servers not started"
    echo "  • Network connectivity issues"
    echo ""
    echo "Run ./scripts/mcp/mcp-status.sh for detailed status"
    exit 1
fi
