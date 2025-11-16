#!/bin/bash
# Preflight checks before bootstrap

set -euo pipefail

FEATURE_NAME="$1"

# Load environment variables from .env if exists
if [ -f .env ]; then
    echo "Loading environment from .env..."
    set -a
    source .env
    set +a
fi

echo "Running preflight checks..."

# Check Claude Code CLI
if ! command -v claude &> /dev/null; then
    echo "❌ Claude Code CLI not installed"
    exit 1
fi
echo "✓ Claude Code CLI"

# Check tmux
if ! command -v tmux &> /dev/null; then
    echo "❌ tmux not installed"
    exit 1
fi
echo "✓ tmux"

# Check jq
if ! command -v jq &> /dev/null; then
    echo "❌ jq not installed"
    exit 1
fi
echo "✓ jq"

# Check Python 3.8+
if ! python3 -c "import sys; assert sys.version_info >= (3,8)" 2>/dev/null; then
    echo "❌ Python 3.8+ required"
    exit 1
fi
echo "✓ Python 3.8+"

# Check git repo
if [ ! -d .git ]; then
    echo "❌ Not a git repository"
    exit 1
fi
echo "✓ Git repository"

# Check no existing session
if tmux has-session -t "claude-feature-$FEATURE_NAME" 2>/dev/null; then
    echo "❌ Session already exists: claude-feature-$FEATURE_NAME"
    exit 1
fi
echo "✓ No existing session"

# Check API keys
if [ -z "${FIRECRAWL_API_KEY:-}" ]; then
    echo "⚠️  FIRECRAWL_API_KEY not set (add to .env file)"
else
    echo "✓ FIRECRAWL_API_KEY configured"
fi

if [ -z "${CONTEXT7_API_KEY:-}" ]; then
    echo "⚠️  CONTEXT7_API_KEY not set (add to .env file)"
else
    echo "✓ CONTEXT7_API_KEY configured"
fi

echo "✅ All preflight checks passed"
