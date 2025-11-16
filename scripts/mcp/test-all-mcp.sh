#!/bin/bash
# Comprehensive MCP services test

set -euo pipefail

echo "=========================================="
echo "  MCP Services Comprehensive Test"
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

# Test 2: Serena Server
echo "2. Testing Serena MCP Server..."
SERENA_URL="${SERENA_URL:-http://localhost:3001}"
SERENA_HOST=$(echo $SERENA_URL | sed 's|http://||' | cut -d: -f1)
SERENA_PORT=$(echo $SERENA_URL | sed 's|http://||' | cut -d: -f2)

if nc -z $SERENA_HOST $SERENA_PORT 2>/dev/null; then
    echo "   ✓ Serena reachable at $SERENA_URL"
    ((PASS++))
else
    echo "   ✗ Serena not reachable at $SERENA_URL"
    ((FAIL++))
fi

echo ""

# Test 3: Required CLI tools
echo "3. Testing Required CLI Tools..."
for cmd in claude jq tmux python3 git npx; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "   ✓ $cmd installed"
        ((PASS++))
    else
        echo "   ✗ $cmd missing"
        ((FAIL++))
    fi
done

echo ""

# Test 4: Python version
echo "4. Testing Python Version..."
if python3 -c "import sys; assert sys.version_info >= (3,8)" 2>/dev/null; then
    PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    echo "   ✓ Python $PY_VER (>= 3.8 required)"
    ((PASS++))
else
    echo "   ✗ Python 3.8+ required"
    ((FAIL++))
fi

echo ""

# Test 5: Git repository
echo "5. Testing Git Repository..."
if [ -d .git ]; then
    echo "   ✓ Git repository present"
    ((PASS++))
else
    echo "   ✗ Not a git repository"
    ((FAIL++))
fi

echo ""

# Test 6: Directory structure
echo "6. Testing Directory Structure..."
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

# Summary
echo "=========================================="
echo "  Test Results"
echo "=========================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✅ All tests passed - System ready!"
    exit 0
else
    echo "❌ Some tests failed - Review above"
    exit 1
fi
