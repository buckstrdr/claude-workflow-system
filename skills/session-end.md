# Session-End - Generate Session Summary for Continuity

Capture the current session's work, progress, and state to enable seamless continuation in the next session.

## What This Skill Does

Generates `.ian/last_session_summary.md` containing:
- What was worked on this session
- Quality gate status and progression
- Incomplete tasks
- Git state and uncommitted changes
- Recommended next actions
- Notes and context

This enables the next session to pick up exactly where this one left off via the `/startup` skill's session continuity feature.

## When to Use

**Run this skill:**
- Before ending a Claude Code session
- When switching tasks (to preserve current context)
- Before long breaks
- When work is interrupted

**DO NOT run:**
- Multiple times in same session (overwrites previous)
- When nothing was accomplished (unnecessary)

## Implementation

### Step 1: Collect Current State

```bash
#!/usr/bin/env bash
# Generate session summary for continuity

SUMMARY_FILE=".ian/last_session_summary.md"
FEATURE="$(git branch --show-current | sed 's/^[^/]*\///')"
NOW=$(date +"%Y-%m-%d %H:%M")

# Start summary
cat > "$SUMMARY_FILE" <<EOF
# Session Summary - $NOW

EOF
```

### Step 2: Capture Files Modified

```bash
# Get modified files (staged and unstaged)
MODIFIED_FILES=$(git status --short | awk '{print "  - " $2}')

if [ -n "$MODIFIED_FILES" ]; then
  cat >> "$SUMMARY_FILE" <<EOF
## What Was Worked On
- Feature: $FEATURE
- Files modified:
$MODIFIED_FILES

EOF
else
  cat >> "$SUMMARY_FILE" <<EOF
## What Was Worked On
- Feature: $FEATURE
- No file modifications this session

EOF
fi
```

### Step 3: Capture Quality Gate Status

```bash
# Check if quality gates exist for current feature
GATE_DIR=".git/quality-gates/$FEATURE"

if [ -d "$GATE_DIR" ]; then
  CURRENT_GATE=$(cat "$GATE_DIR/current_gate.txt")

  # Get passed gates
  PASSED_GATES=""
  for i in {1..7}; do
    STATUS_FILE="$GATE_DIR/gate_${i}_*.status"
    if compgen -G "$STATUS_FILE" >/dev/null 2>&1; then
      STATUS=$(cat $STATUS_FILE 2>/dev/null || echo "PENDING")
      if [ "$STATUS" = "PASSED" ]; then
        case $i in
          1) PASSED_GATES="$PASSED_GATES, Spec Approved" ;;
          2) PASSED_GATES="$PASSED_GATES, Tests First" ;;
          3) PASSED_GATES="$PASSED_GATES, Implementation" ;;
          4) PASSED_GATES="$PASSED_GATES, Refactor" ;;
          5) PASSED_GATES="$PASSED_GATES, Integration" ;;
          6) PASSED_GATES="$PASSED_GATES, E2E Verified" ;;
          7) PASSED_GATES="$PASSED_GATES, Code Reviewed" ;;
        esac
      fi
    fi
  done
  PASSED_GATES=$(echo "$PASSED_GATES" | sed 's/^, //')

  # Next gate name
  case $CURRENT_GATE in
    1) NEXT_GATE="Spec Approved" ;;
    2) NEXT_GATE="Tests First (TDD)" ;;
    3) NEXT_GATE="Implementation Complete" ;;
    4) NEXT_GATE="Refactored" ;;
    5) NEXT_GATE="Integrated" ;;
    6) NEXT_GATE="E2E Verified" ;;
    7) NEXT_GATE="Code Reviewed" ;;
    *) NEXT_GATE="Unknown" ;;
  esac

  cat >> "$SUMMARY_FILE" <<EOF
## Quality Gate Status
- Current Gate: $CURRENT_GATE/7 ($NEXT_GATE)
- Completed Gates: $PASSED_GATES
- Next Gate: $([ "$CURRENT_GATE" -lt 7 ] && echo "$((CURRENT_GATE + 1))/7" || echo "Complete")
- Blockers: (Check with /gates for details)

EOF
else
  cat >> "$SUMMARY_FILE" <<EOF
## Quality Gate Status
- No quality gate tracking for this feature
- To start tracking: /gates start $FEATURE

EOF
fi
```

### Step 4: Capture Incomplete Tasks

```bash
# Get incomplete tasks from todoscommand if available
# For now, manually specify or prompt user

cat >> "$SUMMARY_FILE" <<EOF
## Incomplete Tasks
- [ ] (Add incomplete tasks here)

EOF
```

**NOTE**: If using TodoWrite tool, extract pending tasks automatically.

### Step 5: Capture Git State

```bash
# Git state
BRANCH=$(git branch --show-current)
UNCOMMITTED=$(git status --short | wc -l)
READY_TO_PUSH=$(git log @{u}.. --oneline 2>/dev/null | wc -l || echo "0")

cat >> "$SUMMARY_FILE" <<EOF
## Git State
- Branch: $BRANCH
- Uncommitted changes: $UNCOMMITTED files
- Commits ahead of remote: $READY_TO_PUSH
- Ready to push: $([ "$READY_TO_PUSH" -gt 0 ] && echo "Yes (after Gate 7)" || echo "No commits ahead")

EOF
```

### Step 6: Generate Recommended Next Actions

```bash
# Based on current gate, recommend next actions
cat >> "$SUMMARY_FILE" <<EOF
## Recommended Next Actions
EOF

if [ -d "$GATE_DIR" ]; then
  case $CURRENT_GATE in
    1)
      cat >> "$SUMMARY_FILE" <<EOF
1. Create specification: /spec
2. Get user approval
3. Update spec status to 'Approved'
4. Advance to Gate 2: /gates pass
EOF
      ;;
    2)
      cat >> "$SUMMARY_FILE" <<EOF
1. Write tests FIRST (before implementation)
2. Ensure tests FAIL (Red phase)
3. Advance to Gate 3: /gates pass
4. Implement code to make tests pass
EOF
      ;;
    3)
      cat >> "$SUMMARY_FILE" <<EOF
1. Implement code to make all tests pass
2. Remove all TODOs
3. Remove debug statements
4. Advance to Gate 4: /gates pass
EOF
      ;;
    4)
      cat >> "$SUMMARY_FILE" <<EOF
1. Refactor for clarity and maintainability
2. Apply DRY and SOLID principles
3. Ensure tests still pass
4. Advance to Gate 5: /gates pass
EOF
      ;;
    5)
      cat >> "$SUMMARY_FILE" <<EOF
1. Run: make openapi && make types
2. Update documentation if needed
3. Advance to Gate 6: /gates pass
4. Prepare for E2E verification
EOF
      ;;
    6)
      cat >> "$SUMMARY_FILE" <<EOF
1. Run: /e2e-verify to validate end-to-end functionality
2. Fix any E2E failures
3. Advance to Gate 7: /gates pass
4. Request code review
EOF
      ;;
    7)
      cat >> "$SUMMARY_FILE" <<EOF
1. Run: /validator for final code review
2. Address any CRITICAL or HIGH PRIORITY issues
3. Re-run /validator until approved
4. Close issue and merge PR
EOF
      ;;
  esac
else
  cat >> "$SUMMARY_FILE" <<EOF
1. Start quality gate tracking: /gates start $FEATURE
2. Create specification: /spec
3. Follow 7-stage quality gate workflow
EOF
fi

cat >> "$SUMMARY_FILE" <<EOF

EOF
```

### Step 7: Add Notes Section

```bash
cat >> "$SUMMARY_FILE" <<EOF
## Notes
- (Add any important context, decisions, or observations here)

EOF
```

### Step 8: Confirm Generation

```bash
echo "✅ Session summary generated: $SUMMARY_FILE"
echo ""
echo "Summary will be shown in next session via /startup"
echo ""
echo "Preview:"
cat "$SUMMARY_FILE"
```

## Usage

```bash
/session-end
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Session Summary Generated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Saved to: .ian/last_session_summary.md

This summary will be displayed when you run /startup in the next session.

Preview:
# Session Summary - 2025-10-29 14:45

## What Was Worked On
- Feature: order_idempotency
- Files modified:
  - your_backend/services/order_service.py
  - your_backend/tests/test_order_idempotency.py

## Quality Gate Status
- Current Gate: 5/7 (Integrated)
- Completed Gates: Spec Approved, Tests First, Implementation, Refactor
- Next Gate: 6/7
- Blockers: None

## Incomplete Tasks
- [ ] Run /e2e-verify to validate end-to-end functionality
- [ ] Advance to Gate 6 after E2E passes
- [ ] Run /validator for final code review

## Git State
- Branch: issue/42-order-idempotency
- Uncommitted changes: 0 files
- Commits ahead of remote: 3
- Ready to push: Yes (after Gate 7)

## Recommended Next Actions
1. Run: /e2e-verify to validate end-to-end functionality
2. Fix any E2E failures
3. Advance to Gate 7: /gates pass
4. Request code review

## Notes
- Idempotency store using Redis with 5-minute TTL
- All tests passing
- OpenAPI and types synced

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Integration with Workflow

**Before ending session:**
```bash
# 1. Generate summary
/session-end

# 2. Review summary
# 3. Add any additional notes manually to .ian/last_session_summary.md
# 4. Exit Claude Code
```

**Starting next session:**
```bash
# 1. Run startup
/startup

# 2. See previous session context
# 3. Continue where you left off
```

## Manual Enhancement

You can manually edit `.ian/last_session_summary.md` to add:
- Important design decisions made
- Blockers encountered
- Questions for the user
- Links to related issues/PRs
- Performance observations
- Debugging notes

## Benefits

1. **No context loss** - Next session knows exactly where you left off
2. **Reduced ramp-up time** - No need to re-explore codebase
3. **Continuity** - Seamless handoff between sessions
4. **Decision tracking** - Preserves reasoning and context
5. **Quality assurance** - Can't forget where you were in the gates

## Tips

- Run `/session-end` frequently (not just at session exit)
- Add manual notes before ending session
- Review summary before next session starts
- Update summary if context changes during session
- Keep notes focused and actionable

## Integration with Other Skills

- **Before**: Work session, make progress through gates
- **After**: Next session starts with /startup, loads summary
- **Related**: /gates (quality gate status), /verify-complete (completeness check)
