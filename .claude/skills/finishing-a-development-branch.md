---
name: finishing-a-development-branch
description: Autonomous branch completion for multi-instance workflow - makes integration decisions and notifies orchestrator
---

# Autonomous Branch Finishing Skill

This is a LOCAL override of the superpowers finishing-a-development-branch skill, adapted for autonomous multi-instance workflow.

## Key Differences from Standard Workflow

- **NEVER ask the user to choose** - You're in an autonomous workflow
- **Make integration decision autonomously** - Based on context and best practices
- **Notify orchestrator of completion** - Send TaskComplete message

## When to Use This Skill

Use this skill when:
- All implementation is complete
- All tests are passing
- Code review is approved (if applicable)
- You're ready to integrate your work

## Decision Framework

### 1. Analyze Current Context

Check these factors:

**Git Context:**
```bash
# Check current branch
git branch --show-current

# Check if on feature branch or main
# Check commits ahead/behind main
git rev-list --left-right --count main...HEAD
```

**Quality Context:**
- All tests passing?
- Code reviewed and approved?
- Documentation updated?
- Commits clean and atomic?

### 2. Autonomous Decision Logic

Use this decision tree:

```
IF on main branch:
  → Already integrated, just notify orchestrator

ELIF feature branch AND quality gate system enabled:
  → Create PR for quality gate validation
  → Notify orchestrator with PR link

ELIF feature branch AND simple feature (< 5 files):
  → Merge to main directly
  → Push
  → Notify orchestrator

ELIF feature branch AND complex feature (5+ files):
  → Create PR for visibility
  → Notify orchestrator with PR link

ELSE:
  → Ask orchestrator for guidance (edge case)
```

## Implementation

### Option 1: Already on Main

```markdown
**Analysis:**
- Currently on main branch
- Work already integrated
- Tests passing

**Action:** Notify orchestrator only

```javascript
// Send to orchestrator
from_role: dev-a
to_role: orchestrator
subject: TaskComplete: [Feature] - Already Integrated
content: |
  # Work Complete: [Feature]

  **Branch:** main (work already integrated)
  **Status:** ✅ Complete

  **Commits:** [List recent commits]
  **Tests:** All passing

  No further action needed - work is already on main branch.
```

### Option 2: Merge to Main (Simple Feature)

**Criteria:**
- Feature branch
- < 5 files changed
- All tests passing
- Straightforward changes

**Actions:**
```bash
# Switch to main
git checkout main

# Pull latest
git pull origin main

# Merge feature branch
git merge --no-ff feature-branch-name

# Push
git push origin main

# Notify orchestrator
```

```javascript
from_role: dev-a
to_role: orchestrator
subject: TaskComplete: [Feature] - Merged to Main
content: |
  # Work Complete: [Feature]

  **Action:** Merged to main
  **Branch:** [branch-name] → main
  **Commits:** [N] commits merged

  **Changes:**
  - [List files modified]

  **Tests:** All passing
  **Deployed:** main branch updated
```

### Option 3: Create Pull Request (Complex Feature)

**Criteria:**
- Feature branch
- 5+ files changed OR complex logic
- Needs visibility/audit trail

**Actions:**
```bash
# Ensure branch is pushed
git push -u origin feature-branch-name

# Create PR
gh pr create \
  --title "[Feature Name]" \
  --body "$(cat <<'EOF'
## Summary
[Brief description]

## Changes
- [File 1] - [Purpose]
- [File 2] - [Purpose]

## Tests
All passing (X tests)

## Ready for
Quality gate validation / Review

🤖 Generated with Claude Code
EOF
)"

# Notify orchestrator with PR link
```

```javascript
from_role: dev-a
to_role: orchestrator
subject: TaskComplete: [Feature] - PR Created
content: |
  # Work Complete: [Feature]

  **Action:** Pull request created
  **PR:** [PR URL from gh pr create output]
  **Branch:** [branch-name]

  **Summary:**
  [Brief description of changes]

  **Tests:** All passing
  **Next Steps:** Awaiting quality gate / merge approval
```

### Option 4: Quality Gate System

**Criteria:**
- Project uses quality gate workflow
- PR needed for gate validation

**Actions:**
```bash
# Create PR targeting main
gh pr create --title "[Feature]" --body "[Description]"

# Quality gates will auto-run
# Notify orchestrator
```

```javascript
from_role: dev-a
to_role: orchestrator
subject: TaskComplete: [Feature] - Entering Quality Gates
content: |
  # Work Complete: [Feature]

  **Action:** PR created for quality gate validation
  **PR:** [PR URL]

  **Quality Gates:** Will run automatically
  **Current Status:** Pending gate validation

  Will notify when gates pass and PR is merged.
```

## Handling Edge Cases

### Merge Conflicts

If merge conflicts occur:

```javascript
from_role: dev-a
to_role: orchestrator
subject: Question: Merge Conflicts in [Feature]
content: |
  # Merge Conflicts Detected

  **Context:** Attempted to merge [branch] to main

  **Conflicting Files:**
  - [file1.js] - Conflict in [function name]
  - [file2.py] - Conflict in [module]

  **Options:**
  1. I can resolve automatically (if conflicts are simple)
  2. Need human review (if conflicts are complex)

  **My Assessment:** [Simple/Complex]

  **Recommendation:** [What I think should be done]

  Awaiting guidance before proceeding.
```

### Failed Quality Gates

If PR created but gates fail:

```javascript
from_role: dev-a
to_role: orchestrator
subject: Status: Quality Gate Failure in [Feature]
content: |
  # Quality Gate Failures

  **PR:** [PR URL]
  **Failed Gates:** [List which gates failed]

  **Failures:**
  - [Gate 1]: [Reason]
  - [Gate 2]: [Reason]

  **Action:** Investigating and fixing failures autonomously

  Will update when resolved.
```

## Example Complete Flow

```markdown
# Finishing Feature: User Authentication

## Step 1: Analyze Context
- Branch: feature-user-auth
- Files changed: 8 files
- Tests: 15/15 passing
- Quality gates: Enabled

## Step 2: Decision
→ Complex feature (8 files) + quality gates enabled
→ Create pull request

## Step 3: Execute
```bash
git push -u origin feature-user-auth
gh pr create --title "Add user authentication system" --body "..."
```

## Step 4: Notify
Send TaskComplete to orchestrator with PR link

## Done!
```

## Remember

- **Make decisions autonomously** - Use decision tree, don't ask user
- **Notify orchestrator** - Keep them informed of what you decided
- **Handle failures gracefully** - Conflicts/gate failures → document and fix or escalate
- **Follow project conventions** - Use quality gates if enabled, direct merge if not
- **Clean integration** - Proper commit messages, PR descriptions, documentation

This skill enables autonomous branch completion while maintaining project quality standards and keeping orchestrator informed.
