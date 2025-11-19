#!/usr/bin/env python3
"""
Generic Message Handler - Autonomous Messaging

Monitors MCP message store for ANY new messages to this role and takes appropriate action:
- Autonomous responses for simple messages (broadcast tests, acks, status requests)
- Interactive triggers for complex messages (task assignments, questions, reviews)

This replaces the specific handlers (handle_broadcast_test.py, handle_task_assignment.py)
with a unified approach that handles ALL message types.
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, List, Dict, Any


def get_mcp_messages_file() -> Path:
    """Get path to MCP message store."""
    return Path.home() / ".claude-messaging" / "messages.json"


def get_timestamp() -> str:
    """Get ISO-8601 timestamp."""
    return datetime.now(timezone.utc).isoformat()


def get_quality_gate() -> str:
    """Get current quality gate stage."""
    return os.getenv("QUALITY_GATE_STAGE", "UNKNOWN")


def get_unread_messages(role: str) -> List[Dict]:
    """Get all unread messages for role from MCP message store."""
    messages_file = get_mcp_messages_file()

    if not messages_file.exists():
        return []

    try:
        with open(messages_file, 'r') as f:
            all_messages = json.load(f)

        role_messages = all_messages.get(role, [])
        unread = [msg for msg in role_messages if not msg.get('read', False)]
        return sorted(unread, key=lambda m: m.get('timestamp', ''))

    except Exception as e:
        print(f"❌ Failed to read MCP message store: {e}", file=sys.stderr)
        return []


def mark_message_read(role: str, message_id: str) -> bool:
    """Mark a message as read in the MCP store."""
    messages_file = get_mcp_messages_file()

    try:
        with open(messages_file, 'r') as f:
            all_messages = json.load(f)

        role_messages = all_messages.get(role, [])
        for msg in role_messages:
            if msg['id'] == message_id:
                msg['read'] = True
                break

        with open(messages_file, 'w') as f:
            json.dump(all_messages, f, indent=2)

        return True
    except Exception as e:
        print(f"❌ Failed to mark message as read: {e}", file=sys.stderr)
        return False


def send_response(from_role: str, to_role: str, subject: str, content: str, worktree: Path) -> bool:
    """Send response message using direct_broadcast.py."""
    script_path = worktree / "scripts" / "messaging" / "direct_broadcast.py"

    if not script_path.exists():
        print(f"❌ direct_broadcast.py not found at {script_path}", file=sys.stderr)
        return False

    try:
        result = subprocess.run(
            ["python3", str(script_path), "send", from_role, to_role, subject, content],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0:
            return True
        else:
            print(f"❌ Failed to send response: {result.stderr}", file=sys.stderr)
            return False
    except Exception as e:
        print(f"❌ Failed to send response: {e}", file=sys.stderr)
        return False


def trigger_claude_interactive(role: str, message: Dict, feature: str, worktree: Path) -> bool:
    """
    Send interactive prompt to role's tmux pane to process message.
    Uses tmux send-keys with Enter to autonomously trigger Claude.
    """
    # Map role to tmux session and pane
    session_pane_map = {
        "orchestrator": ("claude-" + feature + "-orchestrator", "0"),
        "librarian": ("claude-" + feature + "-planning", "0"),
        "planner-a": ("claude-" + feature + "-planning", "1"),
        "planner-b": ("claude-" + feature + "-planning", "2"),
        "architect-a": ("claude-" + feature + "-architecture", "0"),
        "architect-b": ("claude-" + feature + "-architecture", "1"),
        "architect-c": ("claude-" + feature + "-architecture", "2"),
        "dev-a": ("claude-" + feature + "-architecture", "3"),
        "dev-b": ("claude-" + feature + "-dev-qa-docs", "0"),
        "qa-a": ("claude-" + feature + "-dev-qa-docs", "1"),
        "qa-b": ("claude-" + feature + "-dev-qa-docs", "2"),
        "docs": ("claude-" + feature + "-dev-qa-docs", "3"),
    }

    if role not in session_pane_map:
        print(f"❌ Unknown role: {role}", file=sys.stderr)
        return False

    session, pane = session_pane_map[role]
    target = f"{session}.{pane}"

    # Build interactive prompt with message details
    msg_id = message['id']
    subject = message['subject']
    from_role = message['from_role']
    content_preview = message['content'][:150] + "..." if len(message['content']) > 150 else message['content']

    prompt = f"New message from {from_role}: '{subject}' - {content_preview}. Use check_inbox MCP tool to read full message."

    try:
        # Send the prompt
        send_cmd = ["tmux", "send-keys", "-t", target, prompt]
        subprocess.run(send_cmd, capture_output=True, timeout=5)

        # Submit with Enter
        submit_cmd = ["tmux", "send-keys", "-t", target, "Enter"]
        subprocess.run(submit_cmd, capture_output=True, timeout=5)

        return True
    except Exception as e:
        print(f"❌ Failed to trigger Claude: {e}", file=sys.stderr)
        return False


def classify_message_intent(message: Dict) -> str:
    """
    Classify message to determine handling strategy.

    Returns:
    - "broadcast_test" - Broadcast test request (autonomous response)
    - "status_request" - Status/health check (autonomous response)
    - "task_assignment" - Task assignment (trigger Claude interactively)
    - "question" - Question requiring thought (trigger Claude interactively)
    - "review_request" - Code/spec review request (trigger Claude interactively)
    - "notification" - Informational only (mark read, no action)
    - "unknown" - Unclear intent (trigger Claude interactively to be safe)
    """
    subject = message.get('subject', '').lower()
    content = message.get('content', '').lower()

    # Broadcast test detection
    if ('broadcast' in subject or 'broadcast' in content) and \
       ('test' in subject or 'test' in content):
        return "broadcast_test"

    # Status/health request
    if 'status' in subject or 'health' in subject or 'ping' in subject:
        return "status_request"

    # Task assignment
    if 'task' in subject or 'assignment' in subject or 'implement' in subject:
        return "task_assignment"

    # Review request
    if 'review' in subject or 'feedback' in subject or 'approve' in subject:
        return "review_request"

    # Question
    if '?' in content or 'question' in subject or 'clarify' in subject:
        return "question"

    # Notification (no action needed)
    if 'notification' in subject or 'fyi' in subject or 'info' in subject:
        return "notification"

    # Default: unknown (trigger Claude to be safe)
    return "unknown"


def handle_broadcast_test(role: str, message: Dict, worktree: Path) -> bool:
    """Handle broadcast test message with autonomous response."""
    gate_stage = get_quality_gate()
    test_id = message['id']
    from_role = message.get('from_role', 'orchestrator')

    response_content = f"""# Broadcast Test Response

**Role:** {role}
**Quality Gate:** {gate_stage}
**Status:** Operational
**Responding At:** {get_timestamp()}
**Test ID:** `{test_id}`

All systems operational. Message passing via MCP store confirmed working.

This is an automated response to the broadcast test request.
"""

    response_subject = f"Broadcast Test Response from {role}"

    # Send response
    if send_response(role, from_role, response_subject, response_content, worktree):
        print(f"✓ Responded to broadcast test {test_id}")
        return True
    else:
        print(f"✗ Failed to respond to broadcast test {test_id}", file=sys.stderr)
        return False


def handle_status_request(role: str, message: Dict, worktree: Path) -> bool:
    """Handle status/health check with autonomous response."""
    gate_stage = get_quality_gate()
    from_role = message.get('from_role')

    response_content = f"""# Status Report

**Role:** {role}
**Quality Gate:** {gate_stage}
**Status:** Operational
**Timestamp:** {get_timestamp()}

System is operational and monitoring messages.
"""

    response_subject = f"Status Report from {role}"

    if send_response(role, from_role, response_subject, response_content, worktree):
        print(f"✓ Responded to status request from {from_role}")
        return True
    else:
        print(f"✗ Failed to respond to status request", file=sys.stderr)
        return False


def handle_notification(role: str, message: Dict) -> bool:
    """Handle notification message (just mark read, no action)."""
    print(f"ℹ️  Notification received: {message.get('subject')}")
    return True


def handle_interactive_message(role: str, message: Dict, feature: str, worktree: Path) -> bool:
    """
    Handle message that requires Claude's attention.
    Triggers Claude interactively via tmux send-keys.
    """
    msg_type = classify_message_intent(message)
    print(f"→ Triggering Claude for {msg_type}: {message.get('subject')}")

    return trigger_claude_interactive(role, message, feature, worktree)


def process_message(role: str, message: Dict, feature: str, worktree: Path) -> bool:
    """
    Process a single message based on its intent.

    Returns True if message was handled (should be marked read).
    """
    msg_id = message['id']
    intent = classify_message_intent(message)

    print(f"[{msg_id}] Intent: {intent} | Subject: {message.get('subject')}")

    handled = False

    if intent == "broadcast_test":
        # Autonomous response
        handled = handle_broadcast_test(role, message, worktree)

    elif intent == "status_request":
        # Autonomous response
        handled = handle_status_request(role, message, worktree)

    elif intent == "notification":
        # Just acknowledge, no action
        handled = handle_notification(role, message)

    elif intent in ["task_assignment", "question", "review_request", "unknown"]:
        # Trigger Claude interactively
        handled = handle_interactive_message(role, message, feature, worktree)

    return handled


def process_all_messages(role: str, feature: str, worktree: Path) -> int:
    """
    Process all unread messages for role.

    Returns count of messages processed.
    """
    messages = get_unread_messages(role)

    if not messages:
        return 0

    processed_count = 0

    for message in messages:
        msg_id = message['id']

        # Process message
        if process_message(role, message, feature, worktree):
            # Mark as read
            if mark_message_read(role, msg_id):
                processed_count += 1
            else:
                print(f"⚠️  Processed message {msg_id} but failed to mark as read", file=sys.stderr)
        else:
            print(f"⚠️  Failed to process message {msg_id}", file=sys.stderr)

    return processed_count


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Generic message handler for autonomous messaging"
    )
    parser.add_argument(
        "--role",
        type=str,
        help="Role name (default: from ROLE_NAME env var)",
    )
    parser.add_argument(
        "--feature",
        type=str,
        help="Feature name (for tmux session targeting)",
    )
    parser.add_argument(
        "--worktree",
        type=str,
        help="Path to worktree",
    )

    args = parser.parse_args()

    # Get role name
    role = args.role or os.getenv("ROLE_NAME")
    if not role:
        print("❌ Role name required (--role or ROLE_NAME env var)", file=sys.stderr)
        sys.exit(1)

    # Get feature name (for tmux targeting)
    feature = args.feature or os.getenv("FEATURE_NAME", "unknown")

    # Get worktree path
    if args.worktree:
        worktree = Path(args.worktree)
    else:
        worktree = Path.cwd()

    # Process all messages
    processed = process_all_messages(role, feature, worktree)

    if processed > 0:
        print(f"Processed {processed} message(s)")

    sys.exit(0)


if __name__ == "__main__":
    main()
