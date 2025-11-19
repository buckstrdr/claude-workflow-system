# Message Protocol - MCP Based

All communication between the 12 instances uses **MCP messaging tools** with a centralized message store.

## Overview

- **12 Instances**: orchestrator, librarian, planner-a, planner-b, architect-a/b/c, dev-a/b, qa-a/b, docs
- **Message Store**: `~/.claude-messaging/messages.json` (managed by MCP server)
- **Autonomous**: Inbox watchers monitor every 3 seconds and trigger instances automatically
- **Tools Available**: `send_message`, `broadcast_message`, `check_inbox`, `mark_message_read`, `get_unread_count`

## Your Instance Identity

You will see your specific identity in your system prompt:
- **Role:** (e.g., Planner-A, Dev-B, Architect-C)
- **Inbox:** (e.g., planner-a, dev-b, architect-c)

Always use your inbox identifier when calling MCP tools.

## Sending Messages

### Use `send_message` MCP Tool

**When to send messages:**
- Orchestrator assigning tasks to specific instances
- Requesting peer reviews
- Asking questions or requesting clarification
- Reporting task completion
- Escalating issues
- Coordinating work between instances

**Tool call format:**
```json
{
  "from_role": "orchestrator",
  "to_role": "planner-a",
  "subject": "Task Assignment: Design User Auth",
  "content": "Please design the user authentication system...\n\n**Requirements:**\n- OAuth2 support\n- JWT tokens\n...\n\nReply when complete."
}
```

**Simple example:**
```
Use send_message to assign task to planner-a:
- from_role: orchestrator
- to_role: planner-a
- subject: Create specification for payment refunds
- content: Please create a detailed spec for the payment refund feature. Include acceptance criteria and technical approach. Reply when ready for review.
```

### Use `broadcast_message` MCP Tool

**When to broadcast:**
- System-wide announcements
- Testing messaging infrastructure
- Emergency notifications
- Status updates to all instances

**Tool call format:**
```json
{
  "from_role": "orchestrator",
  "subject": "Sprint Planning Complete",
  "content": "Sprint planning is complete. Feature assignments:\n- planner-a: User auth\n- planner-b: Payment flow\n..."
}
```

## Receiving Messages

### Autonomous Detection

**You don't need to check manually** - the inbox watcher monitors for you:

1. Every 3 seconds, inbox watcher checks MCP store for new messages
2. If unread messages found, watcher triggers you automatically (via tmux)
3. You'll see: "New message from X: 'subject' - preview..."
4. You can then use `check_inbox` to read full message

### Manual Check (Optional)

Use `check_inbox` MCP tool when prompted:

```json
{
  "role": "planner-a",
  "unread_only": true
}
```

This returns all unread messages in your inbox.

### Marking Messages Read

After processing a message, mark it read:

```json
{
  "role": "planner-a",
  "message_id": "abc123"
}
```

## Message Types and Formats

### TaskAssignment

**From:** Orchestrator → Any role
**Purpose:** Assign specific work

**Subject format:** `TaskAssignment: <brief description>`

**Content template:**
```markdown
# Task Assignment

**Task:** <what to do>
**Context:** <background/why>
**Requirements:**
- <requirement 1>
- <requirement 2>

**Acceptance Criteria:**
- <criterion 1>
- <criterion 2>

**Priority:** <CRITICAL/HIGH/MEDIUM/LOW>

Reply to orchestrator when complete using send_message.
```

**Example:**
```
send_message:
  from_role: orchestrator
  to_role: dev-a
  subject: TaskAssignment: Implement rate limiting
  content: |
    # Task Assignment

    **Task:** Implement rate limiting for API endpoints
    **Context:** Need to prevent abuse of public API
    **Requirements:**
    - 100 requests/minute per IP
    - Redis-based tracking
    - Return 429 status when exceeded

    **Acceptance Criteria:**
    - Tests pass
    - Works with existing auth
    - Documented in API docs

    **Priority:** HIGH

    Reply when complete.
```

### TaskComplete

**From:** Any role → Orchestrator
**Purpose:** Report task completion

**Subject format:** `TaskComplete: <original task>`

**Content template:**
```markdown
# Task Complete

**Original Task:** <task description>
**Status:** Complete
**Results:**
- <result 1>
- <result 2>

**Files Modified:**
- <file 1>
- <file 2>

**Tests:** All passing
**Ready for:** <next gate/review>
```

### ReviewRequest

**From:** Any role → Peer
**Purpose:** Request code/spec review

**Subject format:** `ReviewRequest: <what to review>`

**Content template:**
```markdown
# Review Request

**What to review:** <spec/code/design>
**Location:** <files/paths>
**Context:** <why this review needed>

**Specific concerns:**
- <concern 1>
- <concern 2>

Reply with ReviewFeedback when done.
```

### ReviewFeedback

**From:** Reviewer → Requester
**Purpose:** Provide review feedback

**Subject format:** `ReviewFeedback: <original subject>`

**Content template:**
```markdown
# Review Feedback

**Reviewed:** <what was reviewed>
**Status:** APPROVED / CHANGES_REQUESTED / REJECTED

**Feedback:**
- ✅ <positive point>
- ⚠️  <concern>
- ❌ <blocker>

**Action Items:**
1. <action 1>
2. <action 2>
```

### Question

**From:** Any role → Any role
**Purpose:** Ask clarifying questions

**Subject format:** `Question: <brief question>`

**Content:** Direct question with context

### StatusReport

**From:** Any role → Orchestrator
**Purpose:** Periodic status updates

**Subject format:** `StatusReport: <role> <date>`

**Content:**
```markdown
# Status Report

**Current Work:**
- <task 1> - <status>
- <task 2> - <status>

**Blockers:**
- <blocker 1>
- <blocker 2>

**Needs Help:**
- <need 1>
```

## Natural Usage - How to Use Messaging Autonomously

### For Orchestrator

**Instead of telling the user:**
> "I need to ask planner-a to create a spec"

**Just do it:**
```
I'll assign this to planner-a.

<uses send_message MCP tool>
from_role: orchestrator
to_role: planner-a
subject: TaskAssignment: Create payment refund spec
content: Please create a specification for payment refunds...
```

### For Planners/Architects/Devs/QA

**When you complete work:**
```
Task complete. I'll notify orchestrator.

<uses send_message MCP tool>
from_role: planner-a
to_role: orchestrator
subject: TaskComplete: Payment refund spec
content: Specification is complete and ready for review...
```

**When you need peer review:**
```
I need peer review. I'll request it from planner-b.

<uses send_message MCP tool>
from_role: planner-a
to_role: planner-b
subject: ReviewRequest: Payment refund spec
content: Please review my specification for technical feasibility...
```

**When you have questions:**
```
I need clarification on the auth approach. I'll ask architect-a.

<uses send_message MCP tool>
from_role: dev-a
to_role: architect-a
subject: Question: OAuth2 provider choice
content: Should we use Auth0 or implement custom OAuth2?...
```

## Key Principles

1. **Be Proactive**: Don't ask permission to send messages - just send them
2. **Use Your Identity**: Always use your inbox name (planner-a, dev-b, etc.)
3. **Reply to Sender**: When responding to a message, reply to the from_role
4. **Clear Subjects**: Use descriptive subjects with message type prefix
5. **Markdown Content**: Use markdown formatting for readability
6. **Mark Read**: Mark messages as read after processing them
7. **Autonomous Communication**: Communicate directly with other instances without user intervention

## Examples of Natural Messaging Flow

### Example 1: Orchestrator → Planner → Architect

**User to Orchestrator:** "We need to build a payment refund feature"

**Orchestrator (autonomously):**
```
I'll assign planning to planner-a.

send_message:
  from_role: orchestrator
  to_role: planner-a
  subject: TaskAssignment: Plan payment refund feature
  content: User wants payment refund capability...
```

**Planner-A (triggered autonomously by inbox watcher):**
```
<sees message via inbox watcher>
I'll create the spec and then request architect review.

<creates spec>

send_message:
  from_role: planner-a
  to_role: architect-a
  subject: ReviewRequest: Payment refund spec feasibility
  content: Please review this spec for technical feasibility...
```

**Architect-A (triggered autonomously):**
```
<sees message via inbox watcher>
Spec looks good. I'll approve.

send_message:
  from_role: architect-a
  to_role: planner-a
  subject: ReviewFeedback: Payment refund spec - APPROVED
  content: Spec approved. Recommend PostgreSQL for refund tracking...
```

**Planner-A (triggered autonomously):**
```
<sees approval>
Architect approved. I'll notify orchestrator.

send_message:
  from_role: planner-a
  to_role: orchestrator
  subject: TaskComplete: Payment refund planning
  content: Planning complete. Spec approved by architect-a. Ready for dev assignment.
```

### Example 2: Direct Peer Communication

**Dev-A needs help from Dev-B:**

```
I need peer review on this authentication code.

send_message:
  from_role: dev-a
  to_role: dev-b
  subject: ReviewRequest: OAuth2 implementation
  content: Please review my OAuth2 implementation in src/auth/oauth.py...
```

**Dev-B responds:**
```
<receives message via inbox watcher>
Code looks good but needs rate limiting.

send_message:
  from_role: dev-b
  to_role: dev-a
  subject: ReviewFeedback: OAuth2 - CHANGES_REQUESTED
  content: Implementation is solid but add rate limiting to token endpoint...
```

## Summary

- **Use MCP tools** (`send_message`, `check_inbox`) - not files
- **Be autonomous** - send messages without asking permission
- **Use your identity** - always specify your inbox name
- **Respond directly** - reply to the sender using send_message
- **Inbox watchers handle detection** - you'll be triggered automatically
- **Natural communication** - just send messages like you would in a team chat

The system is designed for **autonomous agent-to-agent communication** without human intervention in the loop.
