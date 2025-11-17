#!/bin/bash
# Clean up old messages from inbox/outbox before starting new session

set -euo pipefail

WORKTREE_PATH="${1:-.}"

echo "🧹 Cleaning up old messages..."

# All message board roles
ROLES=(
    "orchestrator"
    "librarian"
    "planner"
    "architect"
    "dev-a"
    "dev-b"
    "qa-a"
    "qa-b"
    "docs"
)

TOTAL_REMOVED=0

for role in "${ROLES[@]}"; do
    INBOX="$WORKTREE_PATH/messages/$role/inbox"
    OUTBOX="$WORKTREE_PATH/messages/$role/outbox"

    if [ -d "$INBOX" ]; then
        COUNT=$(find "$INBOX" -type f -name "*.md" | wc -l)
        if [ "$COUNT" -gt 0 ]; then
            echo "  Cleaning $role inbox: $COUNT messages"
            find "$INBOX" -type f -name "*.md" -delete
            TOTAL_REMOVED=$((TOTAL_REMOVED + COUNT))
        fi
    fi

    if [ -d "$OUTBOX" ]; then
        COUNT=$(find "$OUTBOX" -type f -name "*.md" | wc -l)
        if [ "$COUNT" -gt 0 ]; then
            echo "  Cleaning $role outbox: $COUNT messages"
            find "$OUTBOX" -type f -name "*.md" -delete
            TOTAL_REMOVED=$((TOTAL_REMOVED + COUNT))
        fi
    fi
done

if [ "$TOTAL_REMOVED" -eq 0 ]; then
    echo "✓ No old messages found"
else
    echo "✓ Removed $TOTAL_REMOVED old messages"
fi

echo ""
