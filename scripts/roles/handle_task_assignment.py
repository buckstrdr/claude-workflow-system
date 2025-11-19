#!/usr/bin/env python3
"""Handler for TaskAssignment messages - triggers role to act on assigned tasks."""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime
import subprocess
import time


def get_mcp_messages_file() -> Path:
    """Get path to MCP message store."""
    return Path.home() / ".claude-messaging" / "messages.json"


def find_unread_messages(role: str) -> list[dict]:
    """Find unread messages for role from MCP message store."""
    messages_file = get_mcp_messages_file()

    if not messages_file.exists():
        return []

    try:
        with open(messages_file, 'r') as f:
            all_messages = json.load(f)

        # Get messages for this role
        role_messages = all_messages.get(role, [])

        # Filter for unread messages only
        unread = [msg for msg in role_messages if not msg.get('read', False)]

        # Sort by timestamp
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

        # Find and mark the message as read
        role_messages = all_messages.get(role, [])
        for msg in role_messages:
            if msg['id'] == message_id:
                msg['read'] = True
                break

        # Write back
        with open(messages_file, 'w') as f:
            json.dump(all_messages, f, indent=2)

        return True
    except Exception as e:
        print(f"❌ Failed to mark message as read: {e}", file=sys.stderr)
        return False


def map_role_to_session(role: str, feature: str) -> tuple[str, str]:
    """Map role name to tmux session and pane."""

    # Map role to session
    session_map = {
        "orchestrator": f"claude-{feature}-orchestrator",
        "librarian": f"claude-{feature}-planning",
        "planner-a": f"claude-{feature}-planning",
        "planner-b": f"claude-{feature}-planning",
        "architect-a": f"claude-{feature}-architecture",
        "architect-b": f"claude-{feature}-architecture",
        "architect-c": f"claude-{feature}-architecture",
        "dev-a": f"claude-{feature}-architecture",
        "dev-b": f"claude-{feature}-dev-qa-docs",
        "qa-a": f"claude-{feature}-dev-qa-docs",
        "qa-b": f"claude-{feature}-dev-qa-docs",
        "docs": f"claude-{feature}-dev-qa-docs",
    }

    # Map role to pane within session
    pane_map = {
        "orchestrator": "0",
        "librarian": "0",
        "planner-a": "1",
        "planner-b": "2",
        "architect-a": "0",
        "architect-b": "1",
        "architect-c": "2",
        "dev-a": "3",
        "dev-b": "0",
        "qa-a": "1",
        "qa-b": "2",
        "docs": "3",
    }

    session = session_map.get(role, "")
    pane = pane_map.get(role, "0")

    return session, pane


def trigger_role(role: str, feature: str, message: dict) -> bool:
    """Send interactive prompt to role's tmux pane to process message."""

    session, pane = map_role_to_session(role, feature)

    if not session:
        print(f"❌ Unknown role: {role}", file=sys.stderr)
        return False

    # Check if session exists
    check_cmd = ["tmux", "has-session", "-t", session]
    result = subprocess.run(check_cmd, capture_output=True)

    if result.returncode != 0:
        print(f"⚠️  Session not found: {session}", file=sys.stderr)
        return False

    # Build prompt with message details
    target = f"{session}.{pane}"
    msg_id = message['id']
    subject = message['subject']
    from_role = message['from_role']
    content_preview = message['content'][:100] + "..." if len(message['content']) > 100 else message['content']

    prompt = f"New message from {from_role}: '{subject}' - {content_preview}. Use check_inbox MCP tool to read full message."

    # Send the prompt and SUBMIT it with Enter
    send_cmd = ["tmux", "send-keys", "-t", target, prompt]
    result = subprocess.run(send_cmd, capture_output=True)
    if result.returncode != 0:
        print(f"❌ Failed to send prompt to {role}: {result.stderr.decode()}", file=sys.stderr)
        return False

    # Submit the prompt
    submit_cmd = ["tmux", "send-keys", "-t", target, "Enter"]
    result = subprocess.run(submit_cmd, capture_output=True)

    if result.returncode == 0:
        print(f"✓ Triggered {role} to process message {msg_id}")
        return True
    else:
        print(f"❌ Failed to trigger {role}: {result.stderr.decode()}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Handle messages from MCP message store"
    )
    parser.add_argument("--role", required=True, help="Role name")
    parser.add_argument("--worktree", required=True, help="Worktree path")

    args = parser.parse_args()

    # Get feature name from worktree path
    worktree_path = Path(args.worktree).resolve()
    worktree_name = worktree_path.name
    if worktree_name.startswith("wt-feature-"):
        feature = worktree_name.replace("wt-feature-", "")
    else:
        feature = "test"  # Default for non-feature worktrees

    # Find unread messages from MCP store
    messages = find_unread_messages(args.role)

    if not messages:
        return  # No messages, exit silently

    # Process each message
    for msg in messages:
        msg_id = msg['id']
        subject = msg['subject']
        print(f"📨 Found unread message: [{msg_id}] {subject}")

        # Trigger role to process the message
        if trigger_role(args.role, feature, msg):
            # Mark message as read after successfully triggering
            if mark_message_read(args.role, msg_id):
                print(f"✓ Marked message {msg_id} as read")
            else:
                print(f"⚠️  Failed to mark message {msg_id} as read")
        else:
            print(f"⚠️  Could not trigger role to process message {msg_id}")


if __name__ == "__main__":
    main()
