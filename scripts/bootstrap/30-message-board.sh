#!/bin/bash
# Initialize message board for the feature

set -euo pipefail

FEATURE_NAME="$1"
WORKTREE_PATH="../wt-feature-$FEATURE_NAME"

# Clean up any old messages from previous runs
if [ -d "$WORKTREE_PATH/messages" ]; then
    echo "Cleaning up old messages from previous session..."
    ./scripts/messaging/cleanup_old_messages.sh "$WORKTREE_PATH"
fi

# Initialize message board structure
./scripts/init-message-board.sh

echo "✅ Message board initialized"
