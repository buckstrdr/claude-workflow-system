#!/usr/bin/env python3
"""
Direct broadcast script - bypasses MCP layer and writes directly to message store.
Temporary workaround until MCP messaging tools are fixed.
"""

import json
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

# Message storage
MESSAGES_DIR = Path.home() / ".claude-messaging"
MESSAGES_DIR.mkdir(exist_ok=True)
MESSAGES_FILE = MESSAGES_DIR / "messages.json"

ALL_ROLES = [
    "orchestrator",
    "librarian",
    "planner",
    "architect",
    "dev-a",
    "dev-b",
    "qa-a",
    "qa-b",
    "docs",
]


def load_messages():
    """Load existing messages from file."""
    if MESSAGES_FILE.exists():
        return json.loads(MESSAGES_FILE.read_text())
    return {}


def save_messages(messages):
    """Save messages to file."""
    MESSAGES_FILE.write_text(json.dumps(messages, indent=2))


def broadcast_message(from_role, subject, content):
    """Broadcast a message to all roles except sender."""
    messages = load_messages()
    msg_ids = []

    for to_role in ALL_ROLES:
        if to_role != from_role:
            msg_id = str(uuid.uuid4())[:8]
            timestamp = datetime.now(timezone.utc).isoformat()

            message = {
                "id": msg_id,
                "from_role": from_role,
                "to_role": to_role,
                "subject": subject,
                "content": content,
                "timestamp": timestamp,
                "read": False,
                "broadcast": True
            }

            if to_role not in messages:
                messages[to_role] = []
            messages[to_role].append(message)
            msg_ids.append(msg_id)

    save_messages(messages)
    return msg_ids


def send_message(from_role, to_role, subject, content):
    """Send a message to a specific role."""
    messages = load_messages()

    msg_id = str(uuid.uuid4())[:8]
    timestamp = datetime.now(timezone.utc).isoformat()

    message = {
        "id": msg_id,
        "from_role": from_role,
        "to_role": to_role,
        "subject": subject,
        "content": content,
        "timestamp": timestamp,
        "read": False,
        "broadcast": False
    }

    if to_role not in messages:
        messages[to_role] = []
    messages[to_role].append(message)

    save_messages(messages)
    return msg_id


def check_inbox(role, unread_only=False):
    """Check inbox for a role."""
    messages = load_messages()
    role_messages = messages.get(role, [])

    if unread_only:
        role_messages = [m for m in role_messages if not m["read"]]

    return role_messages


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  broadcast <from_role> <subject> <content>")
        print("  send <from_role> <to_role> <subject> <content>")
        print("  inbox <role> [--unread]")
        sys.exit(1)

    command = sys.argv[1]

    if command == "broadcast":
        if len(sys.argv) < 5:
            print("Usage: broadcast <from_role> <subject> <content>")
            sys.exit(1)

        from_role = sys.argv[2]
        subject = sys.argv[3]
        content = sys.argv[4]

        msg_ids = broadcast_message(from_role, subject, content)
        print(f"✓ Broadcast sent to {len(msg_ids)} roles")
        print(f"Message IDs: {', '.join(msg_ids)}")

    elif command == "send":
        if len(sys.argv) < 6:
            print("Usage: send <from_role> <to_role> <subject> <content>")
            sys.exit(1)

        from_role = sys.argv[2]
        to_role = sys.argv[3]
        subject = sys.argv[4]
        content = sys.argv[5]

        msg_id = send_message(from_role, to_role, subject, content)
        print(f"✓ Message sent to {to_role}")
        print(f"Message ID: {msg_id}")

    elif command == "inbox":
        if len(sys.argv) < 3:
            print("Usage: inbox <role> [--unread]")
            sys.exit(1)

        role = sys.argv[2]
        unread_only = "--unread" in sys.argv

        messages = check_inbox(role, unread_only)

        if not messages:
            print(f"📭 No {'unread ' if unread_only else ''}messages for {role}")
        else:
            print(f"📬 Inbox for {role} ({len(messages)} messages)\n")
            for msg in messages:
                status = "📩" if not msg["read"] else "✉️"
                broadcast_flag = " [BROADCAST]" if msg["broadcast"] else ""
                print(f"{status} [{msg['id']}]{broadcast_flag} From: {msg['from_role']}")
                print(f"   Subject: {msg['subject']}")
                print(f"   Time: {msg['timestamp']}")
                print(f"   Content:\n{msg['content']}\n")

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
