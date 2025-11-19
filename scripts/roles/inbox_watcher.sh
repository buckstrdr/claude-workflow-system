#!/bin/bash
# Background inbox watcher - monitors MCP message store for ALL messages

set -euo pipefail

ROLE_NAME="${1:-}"
WORKTREE_PATH="${2:-.}"
FEATURE_NAME="${FEATURE_NAME:-unknown}"

if [ -z "$ROLE_NAME" ]; then
    echo "Usage: $0 <role_name> [worktree_path]"
    exit 1
fi

echo "📬 Inbox watcher started for role: $ROLE_NAME"
echo "   Feature: $FEATURE_NAME"
echo "   MCP Store: ~/.claude-messaging/messages.json"
echo "   Checking every 3 seconds for ANY messages..."
echo ""

# Track last check time
LAST_CHECK=$(date +%s)

while true; do
    # Use generic message handler for ALL message types
    # This replaces the specific handlers (broadcast_test, task_assignment)
    if [ -x "$WORKTREE_PATH/scripts/roles/handle_messages.py" ]; then
        python3 "$WORKTREE_PATH/scripts/roles/handle_messages.py" \
            --role "$ROLE_NAME" \
            --feature "$FEATURE_NAME" \
            --worktree "$WORKTREE_PATH" 2>/dev/null || true
    fi

    # Update last check time
    LAST_CHECK=$(date +%s)

    # Wait 3 seconds before next check
    sleep 3
done
