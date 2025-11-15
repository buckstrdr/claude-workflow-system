#!/bin/bash
# Release write lock

set -euo pipefail

ROLE="$1"
LOCK_FILE="messages/write-lock.json"

# Check if this role holds the lock
HOLDER=$(jq -r '.holder' "$LOCK_FILE")
if [ "$HOLDER" != "$ROLE" ]; then
    echo "❌ Cannot release: lock held by $HOLDER, not $ROLE"
    exit 1
fi

# Check if there's a queue
QUEUE_LENGTH=$(jq '.queue | length' "$LOCK_FILE")

if [ "$QUEUE_LENGTH" -gt 0 ]; then
    # Grant to next in queue
    NEXT_ROLE=$(jq -r '.queue[0]' "$LOCK_FILE")
    echo "🔄 Granting lock to next in queue: $NEXT_ROLE"

    # Remove from queue and grant
    jq ".holder = \"$NEXT_ROLE\" |
        .queue = .queue[1:] |
        .timestamp = \"$(date -Iseconds)\" |
        .timeout_at = \"$(date -Iseconds -d '+300 seconds')\"" \
        "$LOCK_FILE" > "$LOCK_FILE.tmp" && mv "$LOCK_FILE.tmp" "$LOCK_FILE"

    echo "✅ Lock granted to: $NEXT_ROLE"
else
    # Release completely
    jq ".locked = false |
        .holder = null |
        .operation = null |
        .timestamp = null |
        .timeout_at = null" \
        "$LOCK_FILE" > "$LOCK_FILE.tmp" && mv "$LOCK_FILE.tmp" "$LOCK_FILE"

    echo "✅ Lock released"
fi
