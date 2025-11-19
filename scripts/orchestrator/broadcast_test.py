#!/usr/bin/env python3
"""
Broadcast Test Script - MCP Store Version

Sends broadcast test message to all 11 Claude role instances via MCP message store
and collects responses automatically via inbox watchers.

Usage:
    python broadcast_test.py [--timeout SECONDS]

Default timeout: 10 seconds (to allow inbox watchers time to process)
"""

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional


# All roles (including orchestrator - 12 total)
ALL_ROLES = [
    "orchestrator",
    "librarian",
    "planner-a",
    "planner-b",
    "architect-a",
    "architect-b",
    "architect-c",
    "dev-a",
    "dev-b",
    "qa-a",
    "qa-b",
    "docs",
]


def get_timestamp() -> str:
    """Get ISO-8601 timestamp."""
    return datetime.now(timezone.utc).isoformat()


def get_project_root() -> Path:
    """Get project root directory."""
    # Assume this script is in scripts/orchestrator/
    return Path(__file__).parent.parent.parent


def get_mcp_messages_file() -> Path:
    """Get path to MCP message store."""
    return Path.home() / ".claude-messaging" / "messages.json"


def send_broadcast_via_mcp(test_id: str, timestamp: str, from_role: str = "orchestrator") -> int:
    """
    Send broadcast message to all roles via MCP store using direct_broadcast.py.

    Returns:
        Number of messages successfully sent
    """
    project_root = get_project_root()
    broadcast_script = project_root / "scripts" / "messaging" / "direct_broadcast.py"

    if not broadcast_script.exists():
        print(f"❌ direct_broadcast.py not found at {broadcast_script}", file=sys.stderr)
        return 0

    # Create broadcast message content
    message_content = f"""# Broadcast Test Request

This is an automated broadcast test of the message passing infrastructure via MCP store.

**Test ID:** `{test_id}`
**Timestamp:** {timestamp}

## Action Required

Please respond by sending a message back to {from_role} with:
1. Your role identity and status
2. Test ID confirmation

The inbox watcher will automatically detect this message and should trigger your response.

**Expected Response Time:** Within 10 seconds
"""

    sent_count = 0
    # Exclude sender from recipients (don't send to yourself)
    recipients = [r for r in ALL_ROLES if r != from_role]

    print(f"Sending broadcast to {len(recipients)} roles via MCP store...")

    for role in recipients:
        try:
            result = subprocess.run(
                [
                    "python3",
                    str(broadcast_script),
                    "send",
                    from_role,
                    role,
                    f"Broadcast Test - {test_id}",
                    message_content
                ],
                capture_output=True,
                text=True,
                timeout=10
            )

            if result.returncode == 0:
                sent_count += 1
                print(f"  ✓ Sent to {role}")
            else:
                print(f"  ✗ Failed to send to {role}: {result.stderr}", file=sys.stderr)

        except Exception as e:
            print(f"  ✗ Failed to send to {role}: {e}", file=sys.stderr)

    return sent_count


def collect_responses_from_mcp(test_id: str, timeout: int, collector_role: str = "orchestrator") -> Dict[str, Dict]:
    """
    Collect responses from collector's inbox in MCP store.

    Returns:
        Dict mapping role name to response data
    """
    responses = {}
    messages_file = get_mcp_messages_file()

    if not messages_file.exists():
        print(f"❌ MCP message store not found at {messages_file}", file=sys.stderr)
        return responses

    print(f"\nWaiting {timeout} seconds for responses from inbox watchers...")

    start_time = time.time()
    last_count = 0

    while time.time() - start_time < timeout:
        try:
            with open(messages_file, 'r') as f:
                all_messages = json.load(f)

            # Get collector's inbox
            collector_inbox = all_messages.get(collector_role, [])

            # Filter for responses to this test
            for msg in collector_inbox:
                subject = msg.get('subject', '')
                from_role = msg.get('from_role', '')

                # Check if this is a broadcast test response
                if test_id in subject and from_role in ALL_ROLES and from_role != collector_role:
                    if from_role not in responses:
                        responses[from_role] = {
                            "role": from_role,
                            "message_id": msg.get('id'),
                            "subject": subject,
                            "timestamp": msg.get('timestamp'),
                            "status": "Operational"
                        }
                        print(f"  ✓ Response from {from_role}")

            # Check if we got all expected responses (ALL_ROLES minus the collector)
            expected_count = len(ALL_ROLES) - 1
            if len(responses) >= expected_count:
                print(f"\n✅ All {expected_count} responses received!")
                break

            # Progress indicator
            if len(responses) > last_count:
                last_count = len(responses)

        except Exception as e:
            print(f"  ⚠️  Error reading MCP store: {e}", file=sys.stderr)

        time.sleep(1)

    return responses


def display_results(responses: Dict[str, Dict], test_id: str, timestamp: str, collector_role: str = "orchestrator"):
    """Display formatted results table."""
    # Expected responses = ALL_ROLES minus the collector
    expected_count = len(ALL_ROLES) - 1
    received_count = len(responses)
    percentage = (received_count / expected_count * 100) if expected_count > 0 else 0

    print("\n" + "━" * 80)
    print("  BROADCAST TEST RESULTS (MCP Store)")
    print("━" * 80)
    print(f"\nBroadcast sent from {collector_role} to {expected_count} roles at {timestamp}")
    print(f"Test ID: {test_id}\n")

    if received_count == expected_count:
        print(f"✅ Responses received: {received_count}/{expected_count} (100%)\n")
    elif received_count > 0:
        print(f"⚠️  Responses received: {received_count}/{expected_count} ({percentage:.0f}%)\n")
    else:
        print(f"❌ No responses received (0/{expected_count})\n")

    # Display table
    print("┌─────────────────┬────────────────────────────────────────────────┬──────────────┐")
    print("│ Role            │ Status                                          │ Response Time│")
    print("├─────────────────┼────────────────────────────────────────────────┼──────────────┤")

    for role in ALL_ROLES:
        # Skip the collector role in the results table
        if role == collector_role:
            continue

        if role in responses:
            resp = responses[role]
            role_display = role.ljust(15)
            status_display = resp["status"][:46].ljust(46)
            # Calculate rough response time
            resp_time = "< 10s"
            print(f"│ {role_display} │ {status_display} │ {resp_time.ljust(12)} │")
        else:
            role_display = role.ljust(15)
            print(f"│ {role_display} │ NO RESPONSE                                    │ -            │")

    print("└─────────────────┴────────────────────────────────────────────────┴──────────────┘")

    # Health status
    print()
    if received_count == expected_count:
        print("✅ Message passing infrastructure (MCP Store): HEALTHY")
        print(f"✅ Inbox watchers: OPERATIONAL (all {len(ALL_ROLES)} roles)")
        print("✅ Autonomous messaging: WORKING")
    elif received_count > expected_count * 0.8:
        print("⚠️  Message passing infrastructure: DEGRADED")
        missing = [r for r in ALL_ROLES if r not in responses and r != collector_role]
        print(f"   Missing responses from: {', '.join(missing)}")
    else:
        print("❌ Message passing infrastructure: UNHEALTHY")
        missing = [r for r in ALL_ROLES if r not in responses and r != collector_role]
        print(f"   Missing responses from {len(missing)} roles:")
        for role in missing:
            print(f"     - {role}")

    print()


def mark_responses_read(responses: Dict[str, Dict]):
    """Mark all broadcast test response messages as read."""
    messages_file = get_mcp_messages_file()

    try:
        with open(messages_file, 'r') as f:
            all_messages = json.load(f)

        # Mark orchestrator's messages as read
        orchestrator_inbox = all_messages.get("orchestrator", [])
        for msg in orchestrator_inbox:
            msg_id = msg.get('id')
            from_role = msg.get('from_role')

            if from_role in responses and responses[from_role].get('message_id') == msg_id:
                msg['read'] = True

        # Write back
        with open(messages_file, 'w') as f:
            json.dump(all_messages, f, indent=2)

        print("🗑️  Test response messages marked as read")

    except Exception as e:
        print(f"⚠️  Failed to mark messages as read: {e}", file=sys.stderr)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Broadcast test for Claude instances via MCP store")
    parser.add_argument(
        "--timeout",
        type=int,
        default=10,
        help="Timeout in seconds to wait for responses (default: 10)",
    )
    parser.add_argument(
        "--no-cleanup",
        action="store_true",
        help="Don't mark test messages as read after completion",
    )

    args = parser.parse_args()

    # Generate test ID and timestamp
    import uuid
    test_id = str(uuid.uuid4())[:8]
    timestamp = get_timestamp()

    collector_role = "orchestrator"
    expected_recipients = len(ALL_ROLES) - 1  # Exclude collector

    print(f"\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"  BROADCASTING TEST TO {expected_recipients} ROLES (MCP STORE)")
    print(f"  Total instances: {len(ALL_ROLES)} (including {collector_role})")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

    # Send broadcast via MCP store
    sent_count = send_broadcast_via_mcp(test_id, timestamp, collector_role)
    print(f"\nSent {sent_count}/{expected_recipients} broadcast messages via MCP store")

    if sent_count == 0:
        print("\n❌ Failed to send any messages. Check that direct_broadcast.py is available.")
        sys.exit(2)

    # Collect responses from MCP store
    responses = collect_responses_from_mcp(test_id, args.timeout, collector_role)

    # Display results
    display_results(responses, test_id, timestamp, collector_role)

    # Cleanup
    if not args.no_cleanup:
        mark_responses_read(responses)

    # Exit code based on success rate
    expected_responses = len(ALL_ROLES) - 1  # Exclude collector
    if len(responses) == expected_responses:
        sys.exit(0)  # Success
    elif len(responses) > 0:
        sys.exit(1)  # Partial success
    else:
        sys.exit(2)  # Complete failure


if __name__ == "__main__":
    main()
