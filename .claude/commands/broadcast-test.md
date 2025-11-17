---
name: broadcast-test
description: Trigger broadcast test to all Claude instances - each role responds with identity
tags: [orchestrator-only, testing, message-passing]
---

# Broadcast Test

**Purpose:** Test message passing infrastructure by broadcasting to all 12 roles and collecting identity responses.

**Orchestrator-Only:** This command should only be run by the Orchestrator role.

---

## What This Does

1. Sends broadcast test message to all 12 roles (Librarian, Planner-A, Planner-B, Architect-A/B/C, Dev-A/B, QA-A/B, Docs)
2. Each role receives message in their inbox
3. Each role responds with:
   - Role name
   - Current quality gate stage
   - Current timestamp
   - Message board status (inbox/outbox counts)
4. Orchestrator collects all responses and displays results
5. Reports success rate and any missing responses

---

## Usage

**From Orchestrator Claude instance:**

```bash
/broadcast-test
```

**Expected Output:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  BROADCAST TEST RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Broadcast sent to 12 roles at 2025-11-17T14:23:45Z

✅ Responses received: 12/12 (100%)

┌──────────────┬────────────┬──────────┬─────────┐
│ Role         │ Gate Stage │ Inbox    │ Outbox  │
├──────────────┼────────────┼──────────┼─────────┤
│ Librarian    │ GREEN      │ 0        │ 1       │
│ Planner-A    │ GREEN      │ 0        │ 1       │
│ Planner-B    │ GREEN      │ 0        │ 1       │
│ Architect-A  │ PEER       │ 0        │ 1       │
│ Architect-B  │ PEER       │ 0        │ 1       │
│ Architect-C  │ RED        │ 0        │ 1       │
│ Dev-A        │ RED        │ 0        │ 1       │
│ Dev-B        │ RED        │ 0        │ 1       │
│ QA-A         │ GREEN      │ 0        │ 1       │
│ QA-B         │ GREEN      │ 0        │ 1       │
│ Docs         │ DOCS       │ 0        │ 1       │
│ Orchestrator │ N/A        │ 12       │ 0       │
└──────────────┴────────────┴──────────┴─────────┘

✅ Message passing infrastructure: HEALTHY
```

---

## Implementation

When invoked, this command:

1. **Calls** `scripts/orchestrator/broadcast_test.py`
2. **Sends** broadcast message to `messages/{role}/inbox/broadcast-test-{timestamp}.md`
3. **Waits** 5 seconds for responses
4. **Collects** responses from `messages/orchestrator/inbox/broadcast-response-{role}-{timestamp}.md`
5. **Displays** formatted results table

---

## Message Format

**Broadcast message (Orchestrator → All Roles):**

```markdown
---
type: broadcast-test
from: orchestrator
to: {role-name}
timestamp: {ISO-8601}
test_id: {uuid}
---

# Broadcast Test Request

This is an automated broadcast test of the message passing infrastructure.

## Action Required

Please respond immediately with:
1. Your role name
2. Current quality gate stage
3. Message board status (inbox/outbox counts)

**Response Template:**

Send message to: `messages/orchestrator/inbox/broadcast-response-{your-role}-{timestamp}.md`

Use the template in this message's frontmatter.
```

**Response message (Role → Orchestrator):**

```markdown
---
type: broadcast-response
from: {role-name}
to: orchestrator
timestamp: {ISO-8601}
test_id: {uuid}
---

# Broadcast Test Response

**Role:** {role-name}
**Quality Gate:** {stage}
**Inbox Count:** {count}
**Outbox Count:** {count}
**Status:** Operational
```

---

## Use Cases

**Before major feature work:**
- Verify all instances are running
- Confirm message board is accessible
- Test broadcast capability

**After infrastructure changes:**
- Validate message passing still works
- Check all roles are responsive
- Verify no permission issues

**During debugging:**
- Identify which roles are unresponsive
- Check message board health
- Diagnose communication issues

---

## Troubleshooting

**No responses received:**
- Check all 12 Claude instances are running (tmux sessions)
- Verify message board directories exist: `ls messages/*/inbox`
- Check file permissions: `ls -la messages/`

**Partial responses (< 12/12):**
- Check which roles didn't respond in output table
- Check that role's tmux pane: `tmux attach -t claude-workflow`
- Verify that role's inbox: `ls messages/{role}/inbox/`

**Permission errors:**
- Run: `chmod -R 755 messages/`
- Check worktree ownership: `ls -la ../wt-feature-*/`

---

## Related Commands

- `/status` - Check quality gate status
- `/sync` - Sync message board state
- `/triage` - Orchestrator message triage

---

## Hook Integration

This command triggers:
- `userPromptSubmit` hook (audit logging)
- `toolCallBefore/After` hooks (if using MCP tools)

Does NOT trigger:
- `fileWrite` hooks (messages are written by script, not Claude)
- `gateAdvance` hooks (no gate changes)

---

**End of broadcast-test command definition**
