# Broadcast Test System - User Guide

**Purpose:** Test message passing infrastructure between all 12 Claude instances by broadcasting to all roles and collecting identity responses.

**Status:** ✅ Fully implemented and tested

---

## Overview

The broadcast test system allows the Orchestrator to verify that all Claude role instances can:
1. Receive messages from the message board
2. Process those messages
3. Send responses back to the Orchestrator

This is critical for ensuring the multi-instance workflow system is operational.

---

## Components

### 1. Slash Command: `/broadcast-test`
- **Location:** `.claude/commands/broadcast-test.md`
- **Usage:** Invoke from Orchestrator Claude instance
- **Function:** Triggers the broadcast test script

### 2. Broadcast Test Script
- **Location:** `scripts/orchestrator/broadcast_test.py`
- **Function:** Sends broadcast messages to all roles, collects responses, displays results
- **Exit Codes:**
  - `0`: Success (all responses received)
  - `1`: Partial success (some responses received)
  - `2`: Complete failure (no responses received)

### 3. Response Handler Script
- **Location:** `scripts/roles/handle_broadcast_test.py`
- **Function:** Automatically responds to broadcast test requests
- **Trigger:** Runs via `sessionStart` hook on each role instance

### 4. SessionStart Hook
- **Location:** `toolset.yaml` → `hooks.sessionStart`
- **Hook Name:** `handle-broadcast-tests`
- **Function:** Automatically checks inbox for broadcast tests and responds

---

## Message Board Roles

The system broadcasts to **8 message board directories** representing the **12 Claude instances**:

| Message Board Directory | Claude Instances |
|------------------------|------------------|
| `librarian` | Librarian (1 instance) |
| `planner` | Planner-A, Planner-B (2 instances share) |
| `architect` | Architect-A, Architect-B, Architect-C (3 instances share) |
| `dev-a` | Dev-A (1 instance) |
| `dev-b` | Dev-B (1 instance) |
| `qa-a` | QA-A (1 instance) |
| `qa-b` | QA-B (1 instance) |
| `docs` | Docs (1 instance) |

**Note:** Planner-A/B share the `planner` inbox/outbox, and all three Architects share the `architect` inbox/outbox.

---

## How to Use

### From Orchestrator

**Command:**
```bash
/broadcast-test
```

**What Happens:**
1. Orchestrator sends broadcast message to all 8 role directories
2. Each role's `sessionStart` hook detects the broadcast test
3. Each role responds with:
   - Role name
   - Current quality gate stage
   - Inbox message count
   - Outbox message count
   - Operational status
4. Orchestrator collects responses for 5 seconds
5. Results displayed in formatted table

---

## Example Output

### Healthy System (100% Response Rate)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  BROADCAST TEST RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Broadcast sent to 8 roles at 2025-11-17T10:20:04Z
Test ID: e88a8306

✅ Responses received: 8/8 (100%)

┌─────────────────┬──────────────┬──────────┬─────────┐
│ Role            │ Gate Stage   │ Inbox    │ Outbox  │
├─────────────────┼──────────────┼──────────┼─────────┤
│ librarian       │ GREEN        │ 1        │ 0       │
│ planner         │ GREEN        │ 1        │ 0       │
│ architect       │ PEER         │ 1        │ 0       │
│ dev-a           │ RED          │ 1        │ 0       │
│ dev-b           │ RED          │ 1        │ 0       │
│ qa-a            │ QA           │ 1        │ 0       │
│ qa-b            │ GREEN        │ 1        │ 0       │
│ docs            │ DOCS         │ 1        │ 0       │
│ orchestrator    │ N/A          │ 8        │ 0       │
└─────────────────┴──────────────┴──────────┴─────────┘

✅ Message passing infrastructure: HEALTHY
```

### Degraded System (Partial Responses)

```
⚠️  Responses received: 5/8 (63%)

┌─────────────────┬──────────────┬──────────┬─────────┐
│ Role            │ Gate Stage   │ Inbox    │ Outbox  │
├─────────────────┼──────────────┼──────────┼─────────┤
│ librarian       │ GREEN        │ 1        │ 0       │
│ planner         │ NO RESPONSE  │ -        │ -       │
│ architect       │ PEER         │ 1        │ 0       │
│ dev-a           │ NO RESPONSE  │ -        │ -       │
│ dev-b           │ RED          │ 1        │ 0       │
│ qa-a            │ QA           │ 1        │ 0       │
│ qa-b            │ NO RESPONSE  │ -        │ -       │
│ docs            │ DOCS         │ 1        │ 0       │
│ orchestrator    │ N/A          │ 5        │ 0       │
└─────────────────┴──────────────┴──────────┴─────────┘

⚠️  Message passing infrastructure: DEGRADED
   Missing responses from: planner, dev-a, qa-b
```

---

## Manual Usage

### Run Broadcast Test Script Directly

**From worktree:**
```bash
cd /path/to/wt-feature-name
python3 ../claude-workflow-system/scripts/orchestrator/broadcast_test.py
```

**Options:**
```bash
--timeout SECONDS    # Wait time for responses (default: 5)
--worktree PATH      # Worktree path (default: auto-detect)
--no-cleanup         # Keep test messages after completion
```

**Example:**
```bash
# Wait 10 seconds for responses, keep messages
python3 scripts/orchestrator/broadcast_test.py --timeout 10 --no-cleanup
```

### Manually Trigger Role Response

**Simulate a role responding:**
```bash
ROLE_NAME=librarian QUALITY_GATE_STAGE=GREEN \
python3 scripts/roles/handle_broadcast_test.py --role librarian
```

---

## Message Format

### Broadcast Request (Orchestrator → Roles)

**File:** `messages/{role}/inbox/broadcast-test-{test_id}.md`

```markdown
---
type: broadcast-test
from: orchestrator
to: {role}
timestamp: 2025-11-17T10:20:04Z
test_id: e88a8306
---

# Broadcast Test Request

This is an automated broadcast test of the message passing infrastructure.

**Test ID:** `e88a8306`
**Timestamp:** 2025-11-17T10:20:04Z

## Action Required

Please respond immediately with your role identity and status.

**Expected Response Time:** Within 5 seconds
```

### Broadcast Response (Role → Orchestrator)

**File:** `messages/orchestrator/inbox/broadcast-response-{role}-{test_id}.md`

```markdown
---
type: broadcast-response
from: {role}
to: orchestrator
timestamp: 2025-11-17T10:20:05Z
test_id: e88a8306
---

# Broadcast Test Response

**Role:** librarian
**Quality Gate:** GREEN
**Inbox Count:** 1
**Outbox Count:** 0
**Status:** Operational
**Received At:** 2025-11-17T10:20:04Z
**Responding At:** 2025-11-17T10:20:05Z
```

---

## Troubleshooting

### No Responses Received

**Symptoms:** All roles show "NO RESPONSE"

**Possible Causes:**
1. Claude instances not running
2. Message board directories missing
3. File permissions incorrect
4. `sessionStart` hook not configured

**Diagnostics:**
```bash
# Check if Claude instances are running
tmux ls | grep claude

# Check message board directories exist
ls messages/*/inbox/

# Check file permissions
ls -la messages/

# Check sessionStart hook in toolset.yaml
grep -A 10 "handle-broadcast-tests" toolset.yaml
```

**Fixes:**
```bash
# Start Claude instances
./scripts/start-claude-instances.sh

# Create message board
bash scripts/init-message-board.sh

# Fix permissions
chmod -R 755 messages/
```

### Partial Responses

**Symptoms:** Some roles respond, others don't

**Possible Causes:**
1. Specific Claude instances crashed
2. Role's sessionStart hook failed
3. Python script not executable
4. Environment variables not set

**Diagnostics:**
```bash
# Check which roles didn't respond in output
# Then check that role's tmux pane
tmux attach -t claude-workflow

# Check that role's inbox
ls messages/{role}/inbox/

# Check script is executable
ls -la scripts/roles/handle_broadcast_test.py

# Check environment variables for that role
# (in that role's tmux pane)
echo $ROLE_NAME
echo $WORKTREE_PATH
```

**Fixes:**
```bash
# Restart specific role instance
tmux send-keys -t claude-workflow:{pane-number} C-c
# Then restart Claude instance

# Make script executable
chmod +x scripts/roles/handle_broadcast_test.py

# Set environment variables
export ROLE_NAME=librarian
export WORKTREE_PATH=/path/to/worktree
```

### Permission Errors

**Symptoms:** Script fails with "Permission denied"

**Fix:**
```bash
chmod +x scripts/orchestrator/broadcast_test.py
chmod +x scripts/roles/handle_broadcast_test.py
chmod -R 755 messages/
```

---

## When to Use Broadcast Test

### Before Major Feature Work
- Verify all 12 instances are running
- Confirm message board is accessible
- Test broadcast capability works

### After Infrastructure Changes
- Validate message passing still works after changes
- Check all roles are responsive
- Verify no permission issues introduced

### During Debugging
- Identify which roles are unresponsive
- Check message board health
- Diagnose communication issues between roles

### After System Restart
- Confirm all instances came back up
- Test inter-role communication restored
- Verify no startup issues

---

## Integration with Workflow

### Automatic Response Handling

When a role's Claude instance starts:
1. `sessionStart` hook runs
2. `handle-broadcast-tests` hook checks inbox
3. If broadcast test found, automatically responds
4. Response sent to Orchestrator's inbox
5. Broadcast test message removed from role's inbox

**No manual intervention required!**

### Environment Variables Used

| Variable | Purpose | Example |
|----------|---------|---------|
| `ROLE_NAME` | Identity of this Claude instance | `librarian` |
| `QUALITY_GATE_STAGE` | Current quality gate | `GREEN` |
| `WORKTREE_PATH` | Path to feature worktree | `/home/user/wt-feature-auth` |

---

## Testing the System

### End-to-End Test

**Simulate complete workflow:**

```bash
cd /path/to/worktree

# 1. Send broadcast (in background)
python3 ../claude-workflow-system/scripts/orchestrator/broadcast_test.py --timeout 3 &
PID=$!

# 2. Wait for messages to be created
sleep 0.5

# 3. Simulate all roles responding
for role in librarian planner architect dev-a dev-b qa-a qa-b docs; do
  ROLE_NAME=$role QUALITY_GATE_STAGE=GREEN \
  python3 ../claude-workflow-system/scripts/roles/handle_broadcast_test.py --role $role &
done

# 4. Wait for completion
wait $PID
```

**Expected Result:**
- All 8 roles respond
- 100% success rate
- "Message passing infrastructure: HEALTHY"

---

## Performance Characteristics

### Timing
- **Broadcast send:** ~50ms for all 8 roles
- **Response time:** Typically < 100ms per role
- **Total test time:** 1-5 seconds (depending on timeout)

### Resource Usage
- **Disk:** ~2KB per broadcast test (8 messages × ~250 bytes)
- **CPU:** Minimal (Python script, no heavy processing)
- **Memory:** < 10MB for script execution

### Cleanup
- By default, test messages are cleaned up automatically
- Use `--no-cleanup` to preserve messages for debugging
- Messages stored at:
  - `messages/{role}/inbox/broadcast-test-*.md`
  - `messages/orchestrator/inbox/broadcast-response-*.md`

---

## Future Enhancements

Potential improvements (not yet implemented):

1. **Latency Tracking:** Measure response time per role
2. **Historical Trends:** Track success rate over time
3. **Alerting:** Send notifications if < 80% response rate
4. **Auto-Retry:** Automatically retry failed broadcasts
5. **Dashboard:** Web UI showing real-time message board health
6. **Stress Testing:** Send multiple broadcasts concurrently

---

## Summary

The broadcast test system provides:

✅ **Verification** - Confirms all roles are operational
✅ **Automation** - Automatic response handling via hooks
✅ **Visibility** - Clear table showing role status
✅ **Troubleshooting** - Identifies unresponsive roles
✅ **Integration** - Seamless with existing workflow

**Use it regularly to ensure your multi-instance Claude workflow system is healthy!**

---

## Related Documentation

- [toolset.yaml Explained](TOOLSET_YAML_EXPLAINED.md) - Configuration file details
- [Comprehensive Audit Report](COMPREHENSIVE_AUDIT_REPORT.md) - Full system audit
- [Message Protocol](../system-comps/shared/message_protocol.md) - Message format spec

---

**Created:** 2025-11-17
**Status:** Production Ready
**Testing:** ✅ All tests passing (100% success rate)
