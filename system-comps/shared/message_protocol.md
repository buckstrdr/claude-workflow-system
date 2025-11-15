# Message Protocol

All communication between roles uses file-based messages with standardized format.

## Message Structure

Every message is a markdown file with this format:

```markdown
## <MessageType>

**From:** <sender_role>
**To:** <recipient_role>
**Timestamp:** <ISO 8601 timestamp>

<message body with specific fields based on type>
```

## Message Types

### TaskAssignment
**From:** Orchestrator
**To:** Any role
**Purpose:** Assign specific work

```markdown
## TaskAssignment

**From:** Orchestrator
**To:** Dev-A
**Timestamp:** 2025-11-15T22:00:00Z

**Task:** Implement user authentication endpoint
**Gate:** 3 (Implementation Complete)
**Context:** See ContextPack in messages/dev-a/inbox/context-001.md
**Acceptance Criteria:**
- Tests pass
- Follows existing auth pattern
- Includes DocIntent comments

**Estimated Time:** 2 hours
```

### TaskComplete
**From:** Any role
**To:** Orchestrator
**Purpose:** Signal task completion

```markdown
## TaskComplete

**From:** Dev-A
**To:** Orchestrator
**Timestamp:** 2025-11-15T23:30:00Z

**Task:** Implement user authentication endpoint
**Status:** DONE
**Files Changed:**
- backend/api/auth.py (implementation)
- backend/tests/test_auth.py (tests already committed)

**Tests:** ✅ All passing
**Next:** Ready for QA validation
```

### WriteRequest
**From:** Any role
**To:** Orchestrator
**Purpose:** Request write lock

```markdown
## WriteRequest

**From:** Dev-A
**To:** Orchestrator
**Timestamp:** 2025-11-15T23:29:00Z

**Operation:** Commit auth implementation
**Estimated Duration:** 30 seconds
**Files:**
- backend/api/auth.py
```

### WriteLockGrant
**From:** Orchestrator
**To:** Requesting role
**Purpose:** Grant write permission

```markdown
## WriteLockGrant

**From:** Orchestrator
**To:** Dev-A
**Timestamp:** 2025-11-15T23:29:05Z

**Lock ID:** lock-12345
**Timeout:** 2025-11-15T23:34:05Z (5 minutes)
**Proceed:** YES

You have the write lock. Complete your operation and send WriteComplete.
```

### GateStatusUpdate
**From:** Orchestrator
**To:** ALL (broadcast)
**Purpose:** Notify gate advancement

```markdown
## GateStatusUpdate

**From:** Orchestrator
**To:** ALL
**Timestamp:** 2025-11-16T00:00:00Z

**Previous Gate:** 3 (Implementation Complete)
**Current Gate:** 4 (Refactored)

**Status:** Gate 3 PASSED - advancing to Gate 4

**Next Steps:**
- Dev-A: Refactor auth module for DRY/SOLID
- QA-A: Verify tests still pass after refactor
- All: No new features until refactor complete
```

## Message Delivery

**File locations:**
- Messages to role: `messages/<role>/inbox/<message-id>.md`
- Messages from role: `messages/<role>/outbox/<message-id>.md`
- Orchestrator reads from all `/outbox/` directories
- Roles read from their own `/inbox/` directory

**Message IDs:**
- Format: `<type>-<timestamp>-<sender>.md`
- Example: `task-20251115-230000-orchestrator.md`

## Message Lifecycle

1. **Send:** Role writes message to own `/outbox/`
2. **Deliver:** Orchestrator moves to recipient's `/inbox/`
3. **Read:** Recipient reads from `/inbox/`
4. **Archive:** After processing, move to `/inbox/archive/`

## Self-Contained Requirement

**Critical:** Every message MUST be self-contained.
- Do NOT reference previous conversation history
- INCLUDE all context needed to act on the message
- ATTACH or inline any required code/specs/data

This allows roles to act on messages without conversation history.
