---
name: executing-plans
description: Autonomous plan execution for multi-instance workflow - executes tasks in batches and reports status to orchestrator
---

# Autonomous Plan Execution Skill

This is a LOCAL override of the superpowers executing-plans skill, adapted for autonomous multi-instance workflow.

## Key Differences from Standard Execution

- **NEVER ask the user for permission to continue** - You're in an autonomous workflow
- **Execute all batches autonomously** - Report progress to orchestrator via send_message
- **Handle failures gracefully** - Document issues, continue with next batch if possible
- **Final report to orchestrator** - Send TaskComplete when done

## When to Use This Skill

Use this skill when you have a detailed implementation plan and need to execute it systematically with quality checkpoints between batches.

## Workflow

### 1. Load and Review the Plan

- Read the plan document
- Verify you understand all tasks
- Identify natural batch boundaries (typically 3-5 tasks per batch)
- Note dependencies between tasks

### 2. Execute Batch-by-Batch

For each batch:

**A. Pre-Batch Check:**
- Verify prerequisites are met
- Check no blocking issues from previous batch

**B. Execute Tasks:**
- Work through tasks in order
- Use TDD where appropriate
- Commit after each logical unit of work
- Document any deviations from plan

**C. Post-Batch Validation:**
- Run tests for this batch
- Verify acceptance criteria met
- Document any issues or blockers

**D. Status Report to Orchestrator:**
```javascript
// Use send_message MCP tool
from_role: dev-a  // or your role
to_role: orchestrator
subject: Progress Update: [Feature] - Batch [N] Complete
content: |
  # Batch [N/Total] Complete: [Batch Name]

  **Status:** ✅ Complete | ⚠️ Partial | ❌ Blocked

  **Tasks Completed:**
  - [Task 1] - ✅ Done
  - [Task 2] - ✅ Done
  - [Task 3] - ⚠️ Partial (reason)

  **Tests:** [X/Y passing]

  **Issues/Blockers:** [None | List issues]

  **Next Batch:** [Next batch name]

  Continuing autonomously to next batch.
```

### 3. Continue to Next Batch

**DO NOT wait for orchestrator response** - The status update is informational

**Exception:** If truly blocked (missing dependencies, fundamental design flaw):
- Send Question message to orchestrator with specific ask
- Wait for response before continuing

### 4. Final Report

After all batches complete:

```javascript
// Use send_message MCP tool
from_role: dev-a
to_role: orchestrator
subject: TaskComplete: [Feature] Implementation Complete
content: |
  # Implementation Complete: [Feature]

  **Total Batches:** [N]
  **Status:** ✅ All batches complete

  **Summary:**
  - Total tasks: [X]
  - Completed: [Y]
  - Test coverage: [Z%]
  - All tests passing: ✅

  **Deliverables:**
  - [List key files created/modified]

  **Ready for:** QA review

  **Notes:** [Any deviations from plan, architectural decisions made]
```

## Handling Failures

### Non-Blocking Failures
If a task fails but doesn't block other work:
- Document the failure
- Continue with next task
- Report in batch status update
- Mark that task for followup

### Blocking Failures
If a task failure blocks all further work:
- Send Question to orchestrator immediately
- Explain what's blocked and why
- Propose solutions or ask for guidance
- Wait for response before continuing

## Example Execution Flow

```markdown
# Executing Plan: Snake Game Implementation

## Batch 1: Core Game Setup (Tasks 1-3)
✅ Task 1: Create HTML structure
✅ Task 2: Setup Canvas rendering
✅ Task 3: Implement game loop
Tests: 3/3 passing

→ Send status to orchestrator
→ Continue to Batch 2 (no wait)

## Batch 2: Game Mechanics (Tasks 4-7)
✅ Task 4: Implement snake movement
✅ Task 5: Add collision detection
⚠️  Task 6: Food generation (simplified - using random, not grid-based)
✅ Task 7: Scoring system
Tests: 7/8 passing (1 test adjusted for simplified food generation)

→ Send status to orchestrator (note deviation)
→ Continue to Batch 3

## Batch 3: Polish & Testing (Tasks 8-10)
✅ Task 8: Add keyboard controls
✅ Task 9: Implement game over state
✅ Task 10: Add localStorage persistence
Tests: 10/10 passing

→ Send final TaskComplete to orchestrator
→ Done!
```

## Integration with Multi-Instance Workflow

### Status Updates (Each Batch)
Keep orchestrator informed but **don't block**:
- ✅ "Batch 1 complete, continuing to Batch 2"
- ⚠️ "Batch 2 partial, Task 6 simplified, continuing to Batch 3"
- ❌ "Batch 3 blocked, API endpoint not available - need guidance"

### Only Block When Truly Stuck
Send Question message only when:
- Fundamental blocker (missing API, design flaw)
- Plan assumptions were wrong
- Need architectural decision

**Don't block for:**
- Minor test failures (fix and continue)
- Small deviations from plan (document and continue)
- Implementation details (make decision and continue)

## Remember

- **Autonomous execution** - Execute all batches without waiting for permission
- **Keep orchestrator informed** - Status updates, not approval requests
- **Handle issues gracefully** - Fix, document, continue
- **Only escalate true blockers** - Fundamental problems that need decisions
- **Test continuously** - Run tests after each batch
- **Document deviations** - Note any changes from original plan

This skill enables systematic implementation while maintaining autonomous operation in the multi-instance workflow.
