#!/bin/bash
# Grant write lock to a role

set -euo pipefail

ROLE="$1"
OPERATION="${2:-write operation}"
DURATION="${3:-300}"  # Default 5 minutes

LOCK_FILE="messages/write-lock.json"

# Check if already locked
LOCKED=$(jq -r '.locked' "$LOCK_FILE")
if [ "$LOCKED" = "true" ]; then
    HOLDER=$(jq -r '.holder' "$LOCK_FILE")
    echo "❌ Lock already held by: $HOLDER"
    echo "Adding $ROLE to queue..."

    # Add to queue
    jq ".queue += [\"$ROLE\"]" "$LOCK_FILE" > "$LOCK_FILE.tmp" && \
        mv "$LOCK_FILE.tmp" "$LOCK_FILE"
    exit 1
fi

# Grant lock
TIMEOUT_AT=$(date -Iseconds -d "+${DURATION} seconds")
jq ".locked = true |
    .holder = \"$ROLE\" |
    .operation = \"$OPERATION\" |
    .timestamp = \"$(date -Iseconds)\" |
    .timeout_at = \"$TIMEOUT_AT\"" \
    "$LOCK_FILE" > "$LOCK_FILE.tmp" && mv "$LOCK_FILE.tmp" "$LOCK_FILE"

echo "✅ Lock granted to: $ROLE"
echo "   Operation: $OPERATION"
echo "   Timeout: $TIMEOUT_AT"
