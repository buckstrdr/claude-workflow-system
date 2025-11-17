#!/usr/bin/env python3
"""
Broadcast Test Response Handler

Automatically responds to broadcast test requests from Orchestrator.

This script is called by the sessionStart hook to check for pending broadcast tests.
Each role instance runs this to respond to Orchestrator's broadcast.

Usage:
    python handle_broadcast_test.py --role ROLE_NAME [--worktree PATH]

Environment Variables:
    ROLE_NAME: Name of this Claude instance's role
    WORKTREE_PATH: Path to feature worktree
    QUALITY_GATE_STAGE: Current quality gate stage (optional)
"""

import argparse
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Dict


def get_timestamp() -> str:
    """Get ISO-8601 timestamp."""
    return datetime.now(timezone.utc).isoformat()


def get_worktree_path() -> Path:
    """Get worktree path from environment or current directory."""
    if worktree_env := os.getenv("WORKTREE_PATH"):
        return Path(worktree_env)

    cwd = Path.cwd()
    if cwd.name.startswith("wt-feature-"):
        return cwd

    return cwd


def get_role_name() -> Optional[str]:
    """Get role name from environment."""
    return os.getenv("ROLE_NAME")


def get_quality_gate() -> str:
    """Get current quality gate stage."""
    return os.getenv("QUALITY_GATE_STAGE", "UNKNOWN")


def count_messages(role_path: Path, box: str) -> int:
    """Count messages in inbox or outbox."""
    box_path = role_path / box
    if not box_path.exists():
        return 0
    return len(list(box_path.glob("*.md")))


def parse_broadcast_request(request_file: Path) -> Optional[Dict[str, str]]:
    """
    Parse broadcast test request message.

    Returns:
        Dict with test_id, timestamp, from
        None if parsing fails
    """
    try:
        content = request_file.read_text()

        # Extract frontmatter
        test_id = None
        timestamp = None
        from_role = None

        in_frontmatter = False
        for line in content.split("\n"):
            line = line.strip()

            if line == "---":
                if not in_frontmatter:
                    in_frontmatter = True
                else:
                    break  # End of frontmatter
                continue

            if in_frontmatter:
                if line.startswith("test_id:"):
                    test_id = line.split("test_id:")[1].strip()
                elif line.startswith("timestamp:"):
                    timestamp = line.split("timestamp:")[1].strip()
                elif line.startswith("from:"):
                    from_role = line.split("from:")[1].strip()

        if test_id and from_role == "orchestrator":
            return {
                "test_id": test_id,
                "timestamp": timestamp or "unknown",
                "from": from_role,
            }

        return None
    except Exception as e:
        print(f"Failed to parse broadcast request: {e}", file=sys.stderr)
        return None


def create_response_message(
    role: str,
    test_id: str,
    request_timestamp: str,
    gate_stage: str,
    inbox_count: int,
    outbox_count: int,
) -> str:
    """Create broadcast response message."""
    response_timestamp = get_timestamp()

    return f"""---
type: broadcast-response
from: {role}
to: orchestrator
timestamp: {response_timestamp}
test_id: {test_id}
---

# Broadcast Test Response

**Role:** {role}
**Quality Gate:** {gate_stage}
**Inbox Count:** {inbox_count}
**Outbox Count:** {outbox_count}
**Status:** Operational
**Received At:** {request_timestamp}
**Responding At:** {response_timestamp}

---

This is an automated response to the broadcast test request.

**Test ID:** `{test_id}`

All systems operational. Message passing infrastructure confirmed working.

---

**End of Broadcast Test Response**
"""


def handle_broadcast_tests(role: str, worktree: Path) -> int:
    """
    Check for broadcast test requests and respond.

    Returns:
        Number of broadcast tests handled
    """
    message_board = worktree / "messages"
    role_inbox = message_board / role / "inbox"
    orchestrator_inbox = message_board / "orchestrator" / "inbox"

    if not role_inbox.exists():
        return 0

    # Find all broadcast test requests
    broadcast_requests = list(role_inbox.glob("broadcast-test-*.md"))

    if not broadcast_requests:
        return 0

    # Get current stats
    gate_stage = get_quality_gate()
    inbox_count = count_messages(message_board / role, "inbox")
    outbox_count = count_messages(message_board / role, "outbox")

    handled_count = 0

    for request_file in broadcast_requests:
        request_data = parse_broadcast_request(request_file)

        if not request_data:
            continue

        test_id = request_data["test_id"]
        request_timestamp = request_data["timestamp"]

        # Create response
        response_content = create_response_message(
            role, test_id, request_timestamp, gate_stage, inbox_count, outbox_count
        )

        # Write response to orchestrator's inbox
        orchestrator_inbox.mkdir(parents=True, exist_ok=True)
        response_file = orchestrator_inbox / f"broadcast-response-{role}-{test_id}.md"

        try:
            response_file.write_text(response_content)
            handled_count += 1
            print(f"✓ Responded to broadcast test {test_id}")

            # Remove the request from our inbox (it's been handled)
            request_file.unlink()
        except Exception as e:
            print(f"✗ Failed to respond to broadcast test: {e}", file=sys.stderr)

    return handled_count


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Handle broadcast test requests for a Claude role instance"
    )
    parser.add_argument(
        "--role",
        type=str,
        help="Role name (default: from ROLE_NAME env var)",
    )
    parser.add_argument(
        "--worktree",
        type=str,
        help="Path to worktree (default: auto-detect)",
    )

    args = parser.parse_args()

    # Get role name
    role = args.role or get_role_name()
    if not role:
        print("❌ Role name required (--role or ROLE_NAME env var)", file=sys.stderr)
        sys.exit(1)

    # Get worktree path
    if args.worktree:
        worktree = Path(args.worktree)
    else:
        worktree = get_worktree_path()

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
