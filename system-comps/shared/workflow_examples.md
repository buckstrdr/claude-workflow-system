# Complete Workflow Examples

This document shows end-to-end workflows for how features flow through the 12-instance multiagent system.

## The 12 Instances

- **orchestrator** - Coordination and task assignment
- **librarian** - Knowledge management and co-signature authority
- **planner-a, planner-b** - Feature specification
- **architect-a, architect-b, architect-c** - Technical design and feasibility
- **dev-a, dev-b** - Implementation
- **qa-a, qa-b** - Testing and quality assurance
- **docs** - Documentation

## Complete Feature Flow: Payment Refunds

### Step 1: User Request → Orchestrator Assignment

**User to Orchestrator:**
```
We need to add payment refund capability to the system
```

**Orchestrator analyzes and assigns planning:**
```
I'll assign this to planner-a for specification.

<uses send_message MCP tool>
from_role: orchestrator
to_role: planner-a
subject: TaskAssignment: Create payment refund specification
content: |
  # Task Assignment

  **Task:** Create detailed specification for payment refund feature
  **Context:** User wants ability to refund payments through the system
  **Requirements:**
  - Support full and partial refunds
  - Integrate with existing payment gateway
  - Include audit trail

  **Deliverable:** Specification with acceptance criteria and technical approach
  **Priority:** MEDIUM

  Reply when complete.
```

### Step 2: Planner Creates Specification

**Planner-A (triggered by inbox watcher):**
```
<inbox watcher detects message within 3 seconds>
<triggers planner-a with: "New message from orchestrator: TaskAssignment: Create payment refund specification...">

I'll create the specification for payment refunds.

<creates specification document>

Now I need architect review before marking complete.

<uses send_message MCP tool>
from_role: planner-a
to_role: architect-a
subject: ReviewRequest: Payment refund spec - feasibility
content: |
  # Review Request

  **What to review:** Payment refund specification
  **Location:** docs/specs/payment-refunds.md
  **Context:** Need technical feasibility review before proceeding

  **Specific concerns:**
  - Can we integrate with Stripe refund API?
  - Should refunds be async or synchronous?
  - Database schema approach for refund tracking?

  Reply with ReviewFeedback when done.
```

### Step 3: Architect Reviews Feasibility

**Architect-A (triggered by inbox watcher):**
```
<inbox watcher detects message>
<triggers architect-a>

I'll review the payment refund specification.

<reads spec>

Looks technically sound. I recommend async refunds with PostgreSQL tracking.

<uses send_message MCP tool>
from_role: architect-a
to_role: planner-a
subject: ReviewFeedback: Payment refund spec - APPROVED
content: |
  # Review Feedback

  **Reviewed:** Payment refund specification
  **Status:** APPROVED

  **Feedback:**
  - ✅ Stripe refund API integration is straightforward
  - ✅ Async processing recommended (use job queue)
  - ✅ PostgreSQL refund_transactions table approach is solid

  **Recommendations:**
  1. Use existing job queue for async processing
  2. Add idempotency keys to prevent duplicate refunds
  3. Store Stripe refund_id for reconciliation

  Ready for development.
```

### Step 4: Planner Reports Completion

**Planner-A (triggered by inbox watcher):**
```
<receives architect approval>

Spec approved. I'll notify orchestrator.

<uses send_message MCP tool>
from_role: planner-a
to_role: orchestrator
subject: TaskComplete: Payment refund specification
content: |
  # Task Complete

  **Original Task:** Create payment refund specification
  **Status:** Complete
  **Results:**
  - Specification created: docs/specs/payment-refunds.md
  - Architect-A reviewed and approved
  - Technical approach: Async processing with PostgreSQL tracking

  **Ready for:** Development assignment
```

### Step 5: Orchestrator Assigns Development

**Orchestrator (triggered by inbox watcher):**
```
<receives completion notice>

Spec is ready. I'll assign development to dev-a.

<uses send_message MCP tool>
from_role: orchestrator
to_role: dev-a
subject: TaskAssignment: Implement payment refunds
content: |
  # Task Assignment

  **Task:** Implement payment refund feature per specification
  **Specification:** docs/specs/payment-refunds.md
  **Architect Approval:** architect-a (async + PostgreSQL approach)

  **Requirements:**
  - Follow TDD: Write tests first
  - Use existing job queue for async processing
  - Add idempotency keys
  - Store Stripe refund_id

  **Acceptance Criteria:**
  - Tests pass
  - Follows spec exactly
  - Includes error handling
  - Works with existing payment flow

  **Priority:** MEDIUM

  Reply when ready for QA review.
```

### Step 6: Developer Implements

**Dev-A (triggered by inbox watcher):**
```
<inbox watcher detects message>

I'll implement the payment refund feature following TDD.

<writes tests first>
<implements feature>
<all tests pass>

Implementation complete. I need peer review before QA.

<uses send_message MCP tool>
from_role: dev-a
to_role: dev-b
subject: ReviewRequest: Payment refund implementation
content: |
  # Review Request

  **What to review:** Payment refund implementation
  **Location:**
  - src/payments/refunds.py (150 LOC)
  - tests/payments/test_refunds.py (80 LOC)
  **Context:** Need peer review before QA

  **Specific concerns:**
  - Error handling for Stripe API failures
  - Idempotency implementation
  - Job queue integration

  Reply with ReviewFeedback when done.
```

### Step 7: Peer Review

**Dev-B (triggered by inbox watcher):**
```
<receives review request>

I'll review the payment refund code.

<reviews code>

Looks good but needs rate limiting on retries.

<uses send_message MCP tool>
from_role: dev-b
to_role: dev-a
subject: ReviewFeedback: Payment refund - CHANGES_REQUESTED
content: |
  # Review Feedback

  **Reviewed:** Payment refund implementation
  **Status:** CHANGES_REQUESTED

  **Feedback:**
  - ✅ Idempotency implementation is correct
  - ✅ Error handling covers most cases
  - ⚠️ Add exponential backoff for Stripe retries
  - ⚠️ Job queue integration looks good but add timeout

  **Action Items:**
  1. Add exponential backoff (max 3 retries)
  2. Add 30-second timeout to job processing

  Reply when fixed.
```

**Dev-A fixes issues:**
```
<receives feedback>

I'll fix those issues.

<adds exponential backoff and timeout>
<tests pass>

<uses send_message MCP tool>
from_role: dev-a
to_role: dev-b
subject: ReviewFeedback addressed - ready for re-review
content: |
  Fixed both items:
  - Added exponential backoff (1s, 2s, 4s)
  - Added 30s timeout to job processing

  Please re-review when you have a moment.
```

**Dev-B approves:**
```
<uses send_message MCP tool>
from_role: dev-b
to_role: dev-a
subject: ReviewFeedback: Payment refund - APPROVED
content: Changes look good. Ready for QA.
```

**Dev-A notifies orchestrator:**
```
<uses send_message MCP tool>
from_role: dev-a
to_role: orchestrator
subject: TaskComplete: Payment refund implementation
content: |
  # Task Complete

  **Original Task:** Implement payment refunds
  **Status:** Complete
  **Results:**
  - Implementation: src/payments/refunds.py
  - Tests: tests/payments/test_refunds.py (100% coverage)
  - Peer reviewed and approved by dev-b

  **Ready for:** QA testing
```

### Step 8: QA Testing

**Orchestrator assigns QA:**
```
<uses send_message MCP tool>
from_role: orchestrator
to_role: qa-a
subject: TaskAssignment: Test payment refunds
content: |
  # Task Assignment

  **Task:** Test payment refund implementation
  **Specification:** docs/specs/payment-refunds.md
  **Implementation:** src/payments/refunds.py

  **Test Coverage:**
  - Full refunds
  - Partial refunds
  - Error handling (API failures)
  - Idempotency (duplicate requests)
  - Async processing

  Reply with test results.
```

**QA-A tests:**
```
<runs comprehensive tests>
<finds edge case bug>

<uses send_message MCP tool>
from_role: qa-a
to_role: orchestrator
subject: QA Rejection: Payment refunds - edge case bug found
content: |
  # QA Rejection

  **Feature:** Payment refunds
  **Status:** REJECTED - Bug found

  **Bug:** Partial refund fails when amount > original payment
  **Severity:** HIGH
  **Steps to Reproduce:**
  1. Create payment for $50
  2. Request refund for $75
  3. System crashes instead of returning error

  **Action:** Rollback to Dev for fix
```

**Orchestrator rolls back:**
```
<uses send_message MCP tool>
from_role: orchestrator
to_role: dev-a
subject: QA Rejection - Fix required
content: |
  QA found bug in payment refunds:
  - Partial refund validation missing
  - Fix and resubmit for QA
```

**Dev-A fixes:**
```
<adds validation>
<tests pass>

<uses send_message MCP tool>
from_role: dev-a
to_role: orchestrator
subject: Bug fixed - ready for QA re-test
content: Added validation for refund amount. Ready for re-test.
```

**Orchestrator reassigns to QA... cycle continues until QA approves**

### Step 9: Documentation

**After QA approval, Orchestrator assigns docs:**
```
<uses send_message MCP tool>
from_role: orchestrator
to_role: docs
subject: TaskAssignment: Document payment refunds
content: |
  # Task Assignment

  **Task:** Create documentation for payment refund feature
  **Specification:** docs/specs/payment-refunds.md
  **Implementation:** src/payments/refunds.py
  **QA Status:** Approved by qa-a

  **Documentation needed:**
  - API endpoint documentation
  - User guide for refund process
  - Error handling documentation

  Reply when complete.
```

**Docs creates documentation:**
```
<creates docs>

<uses send_message MCP tool>
from_role: docs
to_role: orchestrator
subject: TaskComplete: Payment refund documentation
content: |
  Documentation complete:
  - API docs: docs/api/refunds.md
  - User guide: docs/guides/refunds.md
  - Ready for deployment
```

### Step 10: Deployment

**Orchestrator marks feature complete and ready for deployment**

---

## Shorter Example: Simple Bug Fix

**User to Orchestrator:**
```
Login button is broken on mobile
```

**Orchestrator → Dev-A:**
```
<uses send_message>
subject: TaskAssignment: Fix mobile login button
content: Quick fix: login button not working on mobile. Investigate and fix.
```

**Dev-A:**
```
<fixes CSS issue>
<tests pass>

<uses send_message to orchestrator>
subject: TaskComplete: Mobile login fixed
content: Fixed CSS issue. Button now works on mobile. Ready for QA.
```

**Orchestrator → QA-A:**
```
<uses send_message>
subject: TaskAssignment: Verify mobile login fix
```

**QA-A:**
```
<tests on mobile>

<uses send_message to orchestrator>
subject: QA Approved: Mobile login working
```

**Done!**

---

## Key Workflow Principles

1. **Orchestrator coordinates all features** - Never assign yourself work directly
2. **Use send_message proactively** - Don't ask permission, just communicate
3. **Inbox watchers handle detection** - You'll be triggered automatically within 3 seconds
4. **Always reply to the sender** - Complete the communication loop
5. **Peer review before QA** - Devs review each other, Planners review each other
6. **Architect approval required** - All specs need architect feasibility review
7. **QA can reject** - Features go back to dev if bugs found
8. **Docs before deployment** - All features need documentation

## Your Role in the Workflow

**If you are Orchestrator:**
- Receive user requests
- Assign to planners
- Track progress through quality gates
- Coordinate between all roles
- Make final deployment decisions

**If you are Planner:**
- Create specifications from user requirements
- Get architect feasibility review
- Reply to orchestrator when done

**If you are Architect:**
- Review planner specifications
- Provide technical guidance
- Participate in architecture council votes

**If you are Developer:**
- Implement per specification
- Get peer review from other dev
- Reply to orchestrator when ready for QA

**If you are QA:**
- Test implementations thoroughly
- Reject if bugs found (goes back to dev)
- Approve when quality standards met

**If you are Docs:**
- Document all features before deployment
- Create user guides and API docs

**If you are Librarian:**
- Provide knowledge and context
- Co-sign critical decisions

---

## Common Messaging Patterns

### Pattern 1: Request → Work → Complete
```
Orchestrator → You: TaskAssignment
You: <do the work>
You → Orchestrator: TaskComplete
```

### Pattern 2: Request → Question → Answer → Work
```
Orchestrator → You: TaskAssignment
You → Orchestrator: Question (need clarification)
Orchestrator → You: Answer
You: <do the work>
You → Orchestrator: TaskComplete
```

### Pattern 3: Peer Review
```
You: <complete work>
You → Peer: ReviewRequest
Peer → You: ReviewFeedback (APPROVED/CHANGES_REQUESTED)
If approved:
  You → Orchestrator: TaskComplete
If changes requested:
  You: <fix issues>
  You → Peer: Fixed, ready for re-review
  Peer → You: ReviewFeedback (APPROVED)
  You → Orchestrator: TaskComplete
```

### Pattern 4: Cross-Role Collaboration
```
Planner → Architect: ReviewRequest (feasibility)
Architect → Planner: ReviewFeedback (APPROVED)
Planner → Orchestrator: TaskComplete

Orchestrator → Dev: TaskAssignment (implement)
Dev → Architect: Question (technical guidance)
Architect → Dev: Answer (recommendation)
Dev: <implements>
Dev → Orchestrator: TaskComplete
```

---

This comprehensive workflow documentation ensures all 12 instances understand how features flow through the system and when to communicate with whom.
