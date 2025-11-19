#!/usr/bin/env python3
"""
Broadcast Test Response Handler - MCP Store Version

Automatically responds to broadcast test requests from Orchestrator using the MCP message store.

Usage:
    python handle_broadcast_test.py --role ROLE_NAME [--worktree PATH]
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, List, Dict


def get_mcp_messages_file() -> Path:
    """Get path to MCP message store."""
    return Path.home() / ".claude-messaging" / "messages.json"


def get_timestamp() -> str:
    """Get ISO-8601 timestamp."""
    return datetime.now(timezone.utc).isoformat()


def get_quality_gate() -> str:
    """Get current quality gate stage."""
    return os.getenv("QUALITY_GATE_STAGE", "UNKNOWN")


def find_broadcast_tests(role: str) -> List[Dict]:
    """Find unread broadcast test messages for role from MCP message store."""
    messages_file = get_mcp_messages_file()

    if not messages_file.exists():
        return []

    try:
        with open(messages_file, 'r') as f:
            all_messages = json.load(f)

        # Get messages for this role
        role_messages = all_messages.get(role, [])

        # Filter for unread broadcast messages about "Broadcast Test" or similar
        broadcast_tests = []
        for msg in role_messages:
            if msg.get('read', False):
                continue

            subject = msg.get('subject', '').lower()
            content = msg.get('content', '').lower()

            # Look for broadcast test indicators
            if ('broadcast' in subject or 'broadcast' in content) and \
               ('test' in subject or 'test' in content) and \
               msg.get('from_role') == 'orchestrator':
                broadcast_tests.append(msg)

        return sorted(broadcast_tests, key=lambda m: m.get('timestamp', ''))
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


def send_response(role: str, to_role: str, subject: str, content: str, worktree: Path) -> bool:
    """Send broadcast response using direct_broadcast.py."""
    script_path = worktree / "scripts" / "messaging" / "direct_broadcast.py"

    if not script_path.exists():
        print(f"❌ direct_broadcast.py not found at {script_path}", file=sys.stderr)
        return False

    try:
        result = subprocess.run(
            [
                "python3",
                str(script_path),
                "send",
                role,
                to_role,
                subject,
                content
            ],
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


def create_response_content(role: str, gate_stage: str, test_id: str) -> str:
    """Create broadcast response content."""
    response_timestamp = get_timestamp()

    return f"""# Broadcast Test Response

**Role:** {role}
**Quality Gate:** {gate_stage}
**Status:** Operational
**Responding At:** {response_timestamp}
**Test ID:** `{test_id}`

All systems operational. Message passing via MCP store confirmed working.

This is an automated response to the broadcast test request.
"""


def handle_broadcast_tests(role: str, worktree: Path) -> int:
    """
    Check for broadcast test requests and respond.

    Returns:
        Number of broadcast tests handled
    """
    # Find broadcast test messages
    broadcast_tests = find_broadcast_tests(role)

    if not broadcast_tests:
        return 0

    # Get current stats
    gate_stage = get_quality_gate()
    handled_count = 0

    for msg in broadcast_tests:
        msg_id = msg['id']
        from_role = msg.get('from_role', 'orchestrator')
        test_id = msg_id  # Use message ID as test ID

        # Create response
        response_content = create_response_content(role, gate_stage, test_id)
        response_subject = f"Broadcast Test Response from {role}"

        # Send response back to sender (usually orchestrator)
        if send_response(role, from_role, response_subject, response_content, worktree):
            # Mark original message as read
            if mark_message_read(role, msg_id):
                handled_count += 1
                print(f"✓ Responded to broadcast test {test_id}")
            else:
                print(f"⚠️  Sent response but failed to mark message as read", file=sys.stderr)
        else:
            print(f"✗ Failed to respond to broadcast test {msg_id}", file=sys.stderr)

    return handled_count


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Handle broadcast test requests from MCP message store"
    )
    parser.add_argument(
        "--role",
        type=str,
        help="Role name (default: from ROLE_NAME env var)",
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

    # Get worktree path
    if args.worktree:
        worktree = Path(args.worktree)
    else:
        worktree = Path.cwd()

    # Handle broadcast tests
    handled = handle_broadcast_tests(role, worktree)

    if handled > 0:
        print(f"Handled {handled} broadcast test(s)")
        sys.exit(0)
    else:
        # Silent success if no broadcasts (this is normal)
        sys.exit(0)


if __name__ == "__main__":
    main()
