#!/bin/bash
# Initialize message board for the feature

set -euo pipefail

FEATURE_NAME="$1"
WORKTREE_PATH="../wt-feature-$FEATURE_NAME"

# Clean up any old messages from previous runs
# Remove entire messages directory to ensure completely fresh start
if [ -d "$WORKTREE_PATH/messages" ]; then
    echo "Removing old message board from previous session..."
    rm -rf "$WORKTREE_PATH/messages"
    echo "✓ Old messages cleared"
fi

# Clear MCP message store to prevent old messages from re-triggering
MCP_MESSAGES="$HOME/.claude-messaging/messages.json"
if [ -f "$MCP_MESSAGES" ]; then
    echo "Clearing MCP message store from previous session..."
    echo '{}' > "$MCP_MESSAGES"
    echo "✓ MCP messages cleared"
fi

# Initialize fresh message board structure in the worktree
cd "$WORKTREE_PATH"
../claude-workflow-system/scripts/init-message-board.sh
cd - > /dev/null

echo "✅ Message board initialized"
