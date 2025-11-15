#!/bin/bash
# Check write lock status

LOCK_FILE="messages/write-lock.json"

if [ ! -f "$LOCK_FILE" ]; then
    echo "❌ Lock file not found"
    exit 1
fi

LOCKED=$(jq -r '.locked' "$LOCK_FILE")

if [ "$LOCKED" = "true" ]; then
    HOLDER=$(jq -r '.holder' "$LOCK_FILE")
    OPERATION=$(jq -r '.operation' "$LOCK_FILE")
    echo "🔒 LOCKED by $HOLDER"
    echo "   Operation: $OPERATION"
    exit 1
else
    echo "🔓 AVAILABLE"
    exit 0
fi
