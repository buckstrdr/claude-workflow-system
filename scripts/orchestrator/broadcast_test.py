#!/usr/bin/env python3
"""
Broadcast Test Script

Sends broadcast test message to all 12 Claude role instances and collects responses.

Usage:
    python broadcast_test.py [--timeout SECONDS] [--worktree PATH]

Default timeout: 5 seconds
Default worktree: Current directory's parent's wt-feature-* directory
"""

import argparse
import json
import os
import sys
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple


# All message board roles (excluding orchestrator)
# Note: Planner-A/B share "planner" directory, Architect-A/B/C share "architect"
ALL_ROLES = [
    "librarian",
    "planner",
    "architect",
    "dev-a",
    "dev-b",
    "qa-a",
    "qa-b",
    "docs",
]


def get_timestamp() -> str:
    """Get ISO-8601 timestamp."""
    return datetime.now(timezone.utc).isoformat()


def get_worktree_path() -> Path:
    """Get worktree path from environment or current directory."""
    # Check environment variable first
    if worktree_env := os.getenv("WORKTREE_PATH"):
        return Path(worktree_env)

    # Check if we're in a worktree
    cwd = Path.cwd()
    if cwd.name.startswith("wt-feature-"):
        return cwd

    # Check parent directory for worktrees
    parent = cwd.parent
    worktrees = list(parent.glob("wt-feature-*"))
    if worktrees:
        # Use the most recently modified worktree
        return max(worktrees, key=lambda p: p.stat().st_mtime)

    # Fallback to current directory
    return cwd


def get_message_board_path(worktree: Path) -> Path:
    """Get message board base path."""
    return worktree / "messages"


def count_messages(role_path: Path, box: str) -> int:
    """Count messages in inbox or outbox."""
    box_path = role_path / box
    if not box_path.exists():
        return 0
    return len(list(box_path.glob("*.md")))


def create_broadcast_message(role: str, test_id: str, timestamp: str) -> str:
    """Create broadcast test message content."""
    return f"""---
type: broadcast-test
from: orchestrator
to: {role}
timestamp: {timestamp}
test_id: {test_id}
---

# Broadcast Test Request

This is an automated broadcast test of the message passing infrastructure.

**Test ID:** `{test_id}`
**Timestamp:** {timestamp}

## Action Required

Please respond immediately with your role identity and status.

**Response Instructions:**

1. Create response file: `messages/orchestrator/inbox/broadcast-response-{role}-{test_id}.md`
2. Use the template below:

```markdown
---
type: broadcast-response
from: {role}
to: orchestrator
timestamp: {{current-timestamp}}
test_id: {test_id}
---

# Broadcast Test Response

**Role:** {role}
**Quality Gate:** {{your-current-gate-stage}}
**Inbox Count:** {{your-inbox-count}}
**Outbox Count:** {{your-outbox-count}}
**Status:** Operational
**Received At:** {{timestamp-when-you-saw-this}}
**Responding At:** {{current-timestamp}}
```

**Expected Response Time:** Within 5 seconds

---

**End of Broadcast Test Request**
"""


def send_broadcast(message_board: Path, test_id: str, timestamp: str) -> int:
    """
    Send broadcast message to all roles and trigger them via tmux.

    Returns:
        Number of messages successfully sent and triggered
    """
    import subprocess

    sent_count = 0
    feature_name = os.getenv("FEATURE_NAME", "unknown")

    for role in ALL_ROLES:
        inbox_path = message_board / role / "inbox"

        # Create inbox if it doesn't exist
        inbox_path.mkdir(parents=True, exist_ok=True)

        # Create message file
        message_file = inbox_path / f"broadcast-test-{test_id}.md"
        message_content = create_broadcast_message(role, test_id, timestamp)

        try:
            message_file.write_text(message_content)

            # Trigger the receiving instance via tmux
            trigger_role_instance(role, feature_name)

            sent_count += 1
            print(f"  ✓ Sent to {role}")
        except Exception as e:
            print(f"  ✗ Failed to send to {role}: {e}", file=sys.stderr)

    return sent_count


def trigger_role_instance(role: str, feature_name: str):
    """
    Trigger a Claude instance to check its inbox by sending a prompt via tmux.

    Args:
        role: Role name (librarian, planner, architect, dev-a, etc.)
        feature_name: Feature name for tmux session lookup
    """
    import subprocess

    # Map role to tmux session
    session_map = {
        "librarian": f"claude-{feature_name}-planning",
        "planner": f"claude-{feature_name}-planning",
        "architect": f"claude-{feature_name}-architecture",
        "dev-a": f"claude-{feature_name}-architecture",
        "dev-b": f"claude-{feature_name}-dev-qa-docs",
        "qa-a": f"claude-{feature_name}-dev-qa-docs",
        "qa-b": f"claude-{feature_name}-dev-qa-docs",
        "docs": f"claude-{feature_name}-dev-qa-docs",
    }

    # Map role to pane within session
    pane_map = {
        "librarian": 0,
        "planner": 1,
        "architect": 0,
        "dev-a": 3,
        "dev-b": 0,
        "qa-a": 1,
        "qa-b": 2,
        "docs": 3,
    }

    session = session_map.get(role)
    pane = pane_map.get(role, 0)

    if not session:
        return  # Unknown role, skip trigger

    # Check if session exists
    try:
        subprocess.run(
            ["tmux", "has-session", "-t", session],
            check=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError:
        # Session doesn't exist, skip trigger
        return

    # Send prompt to Claude instance to trigger inbox check
    try:
        subprocess.run(
            [
                "tmux", "send-keys", "-t", f"{session}.{pane}",
                "Check inbox for new messages", "C-m"
            ],
            check=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError:
        # Failed to send keys, but message is still in inbox
        pass


def parse_response(response_file: Path) -> Optional[Dict[str, str]]:
    """
    Parse broadcast response message.

    Returns:
        Dict with role, gate, inbox_count, outbox_count, status
        None if parsing fails
    """
    try:
        content = response_file.read_text()

        # Simple parsing - look for key lines
        role = None
        gate = None
        inbox_count = None
        outbox_count = None
        status = None

        for line in content.split("\n"):
            line = line.strip()
            if line.startswith("**Role:**"):
                role = line.split("**Role:**")[1].strip()
            elif line.startswith("**Quality Gate:**"):
                gate = line.split("**Quality Gate:**")[1].strip()
            elif line.startswith("**Inbox Count:**"):
                inbox_count = line.split("**Inbox Count:**")[1].strip()
            elif line.startswith("**Outbox Count:**"):
                outbox_count = line.split("**Outbox Count:**")[1].strip()
            elif line.startswith("**Status:**"):
                status = line.split("**Status:**")[1].strip()

        if role:
            return {
                "role": role,
                "gate": gate or "UNKNOWN",
                "inbox_count": inbox_count or "?",
                "outbox_count": outbox_count or "?",
                "status": status or "Unknown",
            }

        return None
    except Exception as e:
        print(f"  ⚠️  Failed to parse {response_file.name}: {e}", file=sys.stderr)
        return None


def collect_responses(
    message_board: Path, test_id: str, timeout: int
) -> Dict[str, Dict[str, str]]:
    """
    Collect responses from all roles.

    Returns:
        Dict mapping role name to response data
    """
    responses = {}
    inbox_path = message_board / "orchestrator" / "inbox"

    # Create inbox if it doesn't exist
    inbox_path.mkdir(parents=True, exist_ok=True)

    print(f"\nWaiting {timeout} seconds for responses...")

    start_time = time.time()
    last_count = 0

    while time.time() - start_time < timeout:
        # Check for new response files
        response_files = list(inbox_path.glob(f"broadcast-response-*-{test_id}.md"))

        if len(response_files) > last_count:
            # New responses arrived
            for response_file in response_files:
                if response_file.name not in [r["file"] for r in responses.values() if "file" in r]:
                    response_data = parse_response(response_file)
                    if response_data:
                        role = response_data["role"]
                        responses[role] = {**response_data, "file": response_file.name}
                        print(f"  ✓ Response from {role}")

            last_count = len(response_files)

            # Check if we got all responses
            if len(responses) >= len(ALL_ROLES):
                print(f"\n✅ All {len(ALL_ROLES)} responses received!")
                break

        time.sleep(0.5)

    return responses


def display_results(
    responses: Dict[str, Dict[str, str]], test_id: str, timestamp: str
):
    """Display formatted results table."""
    total_roles = len(ALL_ROLES)
    received_count = len(responses)
    percentage = (received_count / total_roles * 100) if total_roles > 0 else 0

    print("\n" + "━" * 80)
    print("  BROADCAST TEST RESULTS")
    print("━" * 80)
    print(f"\nBroadcast sent to {total_roles} roles at {timestamp}")
    print(f"Test ID: {test_id}\n")

    if received_count == total_roles:
        print(f"✅ Responses received: {received_count}/{total_roles} (100%)\n")
    elif received_count > 0:
        print(f"⚠️  Responses received: {received_count}/{total_roles} ({percentage:.0f}%)\n")
    else:
        print(f"❌ No responses received (0/{total_roles})\n")

    # Display table
    print("┌─────────────────┬──────────────┬──────────┬─────────┐")
    print("│ Role            │ Gate Stage   │ Inbox    │ Outbox  │")
    print("├─────────────────┼──────────────┼──────────┼─────────┤")

    for role in ALL_ROLES:
        if role in responses:
            resp = responses[role]
            role_display = role.ljust(15)
            gate_display = resp["gate"][:12].ljust(12)
            inbox_display = resp["inbox_count"][:8].ljust(8)
            outbox_display = resp["outbox_count"][:7].ljust(7)
            print(f"│ {role_display} │ {gate_display} │ {inbox_display} │ {outbox_display} │")
        else:
            role_display = role.ljust(15)
            print(f"│ {role_display} │ NO RESPONSE  │ -        │ -       │")

    # Add orchestrator row
    print("│ orchestrator    │ N/A          │ " + f"{received_count}".ljust(8) + " │ 0       │")
    print("└─────────────────┴──────────────┴──────────┴─────────┘")

    # Health status
    print()
    if received_count == total_roles:
        print("✅ Message passing infrastructure: HEALTHY")
    elif received_count > total_roles * 0.8:
        print("⚠️  Message passing infrastructure: DEGRADED")
        print(f"   Missing responses from: {', '.join([r for r in ALL_ROLES if r not in responses])}")
    else:
        print("❌ Message passing infrastructure: UNHEALTHY")
        print(f"   Missing responses from: {', '.join([r for r in ALL_ROLES if r not in responses])}")

    print()


def cleanup_test_messages(message_board: Path, test_id: str):
    """Clean up broadcast test messages after test completes."""
    # Remove broadcast requests from all role inboxes
    for role in ALL_ROLES:
        inbox_path = message_board / role / "inbox"
        test_file = inbox_path / f"broadcast-test-{test_id}.md"
        if test_file.exists():
            test_file.unlink()

    # Remove responses from orchestrator inbox
    inbox_path = message_board / "orchestrator" / "inbox"
    for response_file in inbox_path.glob(f"broadcast-response-*-{test_id}.md"):
        response_file.unlink()


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Broadcast test for Claude instances")
    parser.add_argument(
        "--timeout",
        type=int,
        default=5,
        help="Timeout in seconds to wait for responses (default: 5)",
    )
    parser.add_argument(
        "--worktree",
        type=str,
        help="Path to worktree (default: auto-detect)",
    )
    parser.add_argument(
        "--no-cleanup",
        action="store_true",
        help="Don't clean up test messages after completion",
    )

    args = parser.parse_args()

    # Get worktree path
    if args.worktree:
        worktree = Path(args.worktree)
    else:
        worktree = get_worktree_path()

    print(f"Using worktree: {worktree}")

    message_board = get_message_board_path(worktree)

    if not message_board.exists():
        print(f"❌ Message board not found at: {message_board}", file=sys.stderr)
        print("   Run this from a feature worktree or set WORKTREE_PATH", file=sys.stderr)
        sys.exit(1)

    # Generate test ID and timestamp
    test_id = str(uuid.uuid4())[:8]
    timestamp = get_timestamp()

    print(f"\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"  BROADCASTING TEST TO {len(ALL_ROLES)} ROLES")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

    # Send broadcast
    sent_count = send_broadcast(message_board, test_id, timestamp)
    print(f"\nSent {sent_count}/{len(ALL_ROLES)} broadcast messages")

    # Collect responses
    responses = collect_responses(message_board, test_id, args.timeout)

    # Display results
    display_results(responses, test_id, timestamp)

    # Cleanup
    if not args.no_cleanup:
        cleanup_test_messages(message_board, test_id)
        print("🗑️  Test messages cleaned up")

    # Exit code based on success rate
    if len(responses) == len(ALL_ROLES):
        sys.exit(0)  # Success
    elif len(responses) > 0:
        sys.exit(1)  # Partial success
    else:
        sys.exit(2)  # Complete failure


if __name__ == "__main__":
    main()
