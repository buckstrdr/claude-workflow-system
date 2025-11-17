#!/bin/bash
# Background inbox watcher - checks for new messages every 3 seconds

set -euo pipefail

ROLE_NAME="${1:-}"
WORKTREE_PATH="${2:-.}"

if [ -z "$ROLE_NAME" ]; then
    echo "Usage: $0 <role_name> [worktree_path]"
    exit 1
fi

INBOX="$WORKTREE_PATH/messages/$ROLE_NAME/inbox"

# Create inbox if it doesn't exist
mkdir -p "$INBOX"

echo "📬 Inbox watcher started for role: $ROLE_NAME"
echo "   Watching: $INBOX"
echo "   Checking every 3 seconds..."
echo ""

# Track last check time
LAST_CHECK=$(date +%s)

while true; do
    # Check for broadcast test messages
    if [ -x "$WORKTREE_PATH/scripts/roles/handle_broadcast_test.py" ]; then
        python3 "$WORKTREE_PATH/scripts/roles/handle_broadcast_test.py" \
            --role "$ROLE_NAME" \
            --worktree "$WORKTREE_PATH" 2>/dev/null || true
    fi

    # Check for other message types in the future
    # (add more message handlers here)

    # Update last check time
    LAST_CHECK=$(date +%s)

    # Wait 3 seconds before next check
    sleep 3
done
