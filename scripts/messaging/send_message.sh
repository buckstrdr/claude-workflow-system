#!/bin/bash
# Send message to another Claude role instance and trigger them to read it

set -euo pipefail

FROM_ROLE="${1:-}"
TO_ROLE="${2:-}"
MESSAGE_FILE="${3:-}"

if [ -z "$FROM_ROLE" ] || [ -z "$TO_ROLE" ] || [ -z "$MESSAGE_FILE" ]; then
    echo "Usage: $0 <from_role> <to_role> <message_file>"
    echo ""
    echo "Example:"
    echo "  $0 orchestrator librarian /path/to/message.md"
    exit 1
fi

# Get feature name from environment or current directory
FEATURE_NAME="${FEATURE_NAME:-}"
if [ -z "$FEATURE_NAME" ]; then
    # Try to extract from current directory
    CURRENT_DIR=$(basename "$PWD")
    if [[ "$CURRENT_DIR" == wt-feature-* ]]; then
        FEATURE_NAME="${CURRENT_DIR#wt-feature-}"
    else
        echo "❌ FEATURE_NAME not set and couldn't detect from directory"
        exit 1
    fi
fi

# Message board paths
INBOX="messages/${TO_ROLE}/inbox"
MESSAGE_NAME=$(basename "$MESSAGE_FILE")
DEST_MESSAGE="$INBOX/$MESSAGE_NAME"

# Copy message to recipient's inbox
echo "📨 Sending message from $FROM_ROLE to $TO_ROLE"
echo "   File: $MESSAGE_NAME"

mkdir -p "$INBOX"
cp "$MESSAGE_FILE" "$DEST_MESSAGE"

echo "✓ Message delivered to: $DEST_MESSAGE"

# Map role to tmux session
# Session naming: claude-${FEATURE_NAME}-${session_type}
map_role_to_session() {
    local role="$1"

    case "$role" in
        orchestrator)
            echo "claude-${FEATURE_NAME}-orchestrator"
            ;;
        librarian|planner)
            echo "claude-${FEATURE_NAME}-planning"
            ;;
        architect|dev)
            echo "claude-${FEATURE_NAME}-architecture"
            ;;
        qa|docs)
            echo "claude-${FEATURE_NAME}-dev-qa-docs"
            ;;
        dev-a|dev-b)
            echo "claude-${FEATURE_NAME}-architecture"
            ;;
        qa-a|qa-b)
            echo "claude-${FEATURE_NAME}-dev-qa-docs"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Map role to pane number within session
map_role_to_pane() {
    local role="$1"

    case "$role" in
        orchestrator) echo "0" ;;
        librarian) echo "0" ;;
        planner) echo "1" ;;  # Note: Both Planner-A and Planner-B share this
        architect) echo "0" ;;
        dev) echo "3" ;;  # Dev-A is in architecture session
        dev-a) echo "3" ;;
        dev-b) echo "0" ;;  # Dev-B is in dev-qa-docs session
        qa) echo "1" ;;  # QA-A
        qa-a) echo "1" ;;
        qa-b) echo "2" ;;
        docs) echo "3" ;;
        *) echo "0" ;;
    esac
}

# Get target session and pane
TARGET_SESSION=$(map_role_to_session "$TO_ROLE")
TARGET_PANE=$(map_role_to_pane "$TO_ROLE")

if [ -z "$TARGET_SESSION" ]; then
    echo "❌ Unknown role: $TO_ROLE"
    exit 1
fi

# Check if session exists
if ! tmux has-session -t "$TARGET_SESSION" 2>/dev/null; then
    echo "⚠️  Warning: tmux session not found: $TARGET_SESSION"
    echo "   Message delivered but recipient not notified"
    exit 0
fi

# Send prompt to target Claude instance to check inbox
echo "📬 Notifying $TO_ROLE (session: $TARGET_SESSION, pane: $TARGET_PANE)"

# Send a prompt that will trigger the userPromptSubmit hook
# The hook will check inbox and process the message
tmux send-keys -t "${TARGET_SESSION}.${TARGET_PANE}" \
    "Check inbox for new messages" C-m

echo "✅ Message sent and recipient notified!"
echo ""
echo "The $TO_ROLE instance will now:"
echo "  1. See the 'Check inbox' prompt"
echo "  2. userPromptSubmit hook runs"
echo "  3. Hook processes message in inbox"
echo "  4. Claude acts on the message"
