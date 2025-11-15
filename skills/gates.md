# Gates - Quality Gate Status & Progression Tracker

Track progress through the 7-stage quality gate system and verify requirements for each stage.

## What This Skill Does

Displays:
- Current quality gate for active work
- Requirements to pass current gate
- Progress through all 7 gates
- Blockers preventing progression
- Recommended next actions

## 7-Stage Quality Gate System

```
Gate 1: Spec Approved
  ↓
Gate 2: Tests First (TDD)
  ↓
Gate 3: Implementation Complete
  ↓
Gate 4: Refactored
  ↓
Gate 5: Integrated (OpenAPI, Types, Docs)
  ↓
Gate 6: E2E Verified
  ↓
Gate 7: Code Reviewed
  ↓
✅ COMPLETE - Ready for Production
```

## Gate Requirements

### Gate 1: Spec Approved
**Requirements:**
- [ ] Specification file exists in `.ian/spec_*.md`
- [ ] All required sections complete:
  - Problem statement
  - Minimal viable solution
  - Scope boundaries (what we're NOT building)
  - Success criteria (measurable)
  - Test strategy
  - Edge cases identified
- [ ] User has approved spec
- [ ] Status field = "Approved"

**Outputs:** `.ian/spec_{FEATURE}_{DATE}.md`

**Verification:**
```bash
# Check if spec exists and is approved
ls .ian/spec_*.md | tail -1
grep "Status: Approved" $(ls .ian/spec_*.md | tail -1)
```

**Next Action:** Create tests first (`/test` skill or manual)

---

### Gate 2: Tests First (TDD)
**Requirements:**
- [ ] Tests written BEFORE implementation code
- [ ] Tests reflect success criteria from spec
- [ ] Edge cases from spec have tests
- [ ] Error scenarios have tests
- [ ] Tests are FAILING (Red phase)
- [ ] No implementation code exists yet

**Enforcement:** `enforce-test-first` hook blocks commits if:
- New production code added without corresponding tests
- Tests added in same commit as implementation

**Verification:**
```bash
# Check if tests exist
find your_backend/tests/ -name "test_*.py" -newer .ian/spec_*.md

# Check if tests are failing (Red phase)
python -m pytest your_backend/tests/ -v
# Should see failures - implementation doesn't exist yet
```

**Next Action:** Implement code to make tests pass (Green phase)

---

### Gate 3: Implementation Complete
**Requirements:**
- [ ] All tests from Gate 2 now PASSING (Green phase)
- [ ] Success criteria from spec are met
- [ ] Edge cases handled
- [ ] Error handling implemented
- [ ] No TODOs in production code
- [ ] No debug statements

**Verification:**
```bash
# All tests passing
python -m pytest your_backend/tests/ -v

# No TODOs
grep -r "TODO\|FIXME" your_backend/ --exclude-dir="tests" || echo "Clean"

# No debug statements
grep -r "print\|console.log\|debugger\|pdb" your_backend/ --exclude-dir="tests" || echo "Clean"
```

**Next Action:** Refactor for quality (DRY, SOLID, readability)

---

### Gate 4: Refactored
**Requirements:**
- [ ] Code follows DRY principles
- [ ] SOLID principles applied
- [ ] Function/class names are clear and descriptive
- [ ] Comments explain "why", not "what"
- [ ] No duplicate logic
- [ ] Complexity reduced where possible
- [ ] Tests still passing after refactor

**Verification:**
```bash
# Tests still passing after refactor
python -m pytest your_backend/tests/ -v

# Check code complexity (basic heuristics)
# Long functions (>50 lines)
find your_backend/ -name "*.py" -exec awk '/^def / {start=NR} /^def /||/^class / {if(start && NR-start>50) print FILENAME":"start; start=0}' {} \;

# Duplicate code detection (simple)
# Look for repeated patterns manually or use tools
```

**Next Action:** Integrate with OpenAPI, types, and documentation

---

### Gate 5: Integrated (OpenAPI, Types, Docs)
**Requirements:**
- [ ] OpenAPI spec regenerated: `make openapi`
- [ ] Frontend types synced: `make types`
- [ ] Code graphs updated: `make graphs`
- [ ] Semantic index updated: `make semantic`
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] README.md updated (if API or architecture changed)
- [ ] Docstrings added to public functions/classes

**Verification:**
```bash
# Regenerate integration artifacts
make openapi
make types
make graphs-fast
make semantic

# Check git status - should see updated artifacts
git status --short

# Verify no TypeScript errors in frontend
cd your_frontend && npm run type-check
```

**Next Action:** Run end-to-end verification

---

### Gate 6: E2E Verified
**Requirements:**
- [ ] Backend starts successfully
- [ ] Frontend builds and loads
- [ ] API endpoints respond correctly
- [ ] UI features accessible
- [ ] No runtime errors in logs
- [ ] Feature-specific tests pass

**Enforcement:** `pre-mark-complete` hook blocks marking todos complete until `/e2e-verify` passes

**Verification:**
```bash
# Run E2E verification script
/e2e-verify

# Should see:
# ✅ Backend: Server started
# ✅ Backend: Health endpoint OK (200)
# ✅ Frontend: Build succeeded
# ✅ Frontend: UI loads
# ✅ Feature: [Specific feature test] passed
```

**Next Action:** Request code review

---

### Gate 7: Code Reviewed
**Requirements:**
- [ ] `/validator` agent review completed
- [ ] All CRITICAL issues addressed
- [ ] All HIGH PRIORITY issues addressed
- [ ] MEDIUM PRIORITY issues documented for follow-up
- [ ] Test coverage validated
- [ ] Production readiness confirmed

**Verification:**
```bash
# Run validator agent
/validator

# Should see:
# OVERALL VERDICT: APPROVED or APPROVED WITH CONDITIONS

# Address any critical/high priority issues
# Re-run /validator until approved
```

**Next Action:** Mark complete, close issue, merge PR

---

## Gate Status Tracking

Gate status is tracked in `.git/quality-gates/{FEATURE}/`:

```bash
.git/quality-gates/
  order_idempotency/
    current_gate.txt         # Current gate number (1-7)
    gate_1_spec.status       # PASSED or PENDING
    gate_2_tests.status      # PASSED or PENDING
    gate_3_impl.status       # PASSED or PENDING
    gate_4_refactor.status   # PASSED or PENDING
    gate_5_integration.status # PASSED or PENDING
    gate_6_e2e.status        # PASSED or PENDING
    gate_7_review.status     # PASSED or PENDING
    started_at.txt           # ISO timestamp
    completed_at.txt         # ISO timestamp (when gate 7 passed)
```

## Usage

### Check Current Gate
```bash
/gates
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Quality Gate Status: order_idempotency
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Gate: 3 - Implementation Complete

Progress:
  ✅ Gate 1: Spec Approved (passed 2025-10-29 14:30)
  ✅ Gate 2: Tests First (passed 2025-10-29 14:45)
  🔄 Gate 3: Implementation Complete (IN PROGRESS)
  ⏸️  Gate 4: Refactored
  ⏸️  Gate 5: Integrated
  ⏸️  Gate 6: E2E Verified
  ⏸️  Gate 7: Code Reviewed

Gate 3 Requirements:
  ✅ All tests passing
  ✅ Success criteria met
  ❌ TODOs found in production code (BLOCKER)
  ✅ No debug statements

Blockers:
  • 3 TODOs found in your_backend/services/order_service.py:42,67,89

Recommended Actions:
  1. Remove or address TODOs
  2. Re-run: /gates
  3. When passing: Advance to Gate 4 (Refactor)

Time in current gate: 15 minutes
Total time in gates: 30 minutes
```

### Pass Current Gate
```bash
/gates pass
```

**Behavior:**
- Validates all requirements for current gate
- If passing: advances to next gate
- If failing: shows blockers and required actions
- Updates `.git/quality-gates/{FEATURE}/` status files

### Full Status Report
```bash
/gates status
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Quality Gates Status Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Active Features:
  • order_idempotency (Gate 3/7) - 30 min
  • websocket_reconnect (Gate 6/7) - 2 hours

Completed Features (Last 7 Days):
  • trailing_brackets (7/7) - Completed 2025-10-28
  • position_polling (7/7) - Completed 2025-10-27

Gate Statistics:
  Average time per gate:
    Gate 1 (Spec):         8 min
    Gate 2 (Tests):        15 min
    Gate 3 (Impl):         25 min
    Gate 4 (Refactor):     10 min
    Gate 5 (Integration):  5 min
    Gate 6 (E2E):          7 min
    Gate 7 (Review):       12 min

  Total average time: 82 min per feature

Most common blockers:
  1. Gate 3: TODOs in production code (40%)
  2. Gate 2: Missing edge case tests (30%)
  3. Gate 6: E2E verification failures (20%)
```

### Start New Feature
```bash
/gates start order_idempotency
```

**Behavior:**
- Creates `.git/quality-gates/order_idempotency/` directory
- Initializes status files
- Sets current_gate to 1
- Records started_at timestamp
- Prompts to run `/spec` to pass Gate 1

### Reset Gate (If Needed)
```bash
/gates reset 3
```

**Behavior:**
- Resets specified gate to PENDING
- Sets current_gate back to specified gate
- Useful if rework is needed

## Integration with Other Skills

**Flow:**
```bash
# 1. Start new feature
/gates start order_idempotency

# 2. Create specification
/spec
# → Passes Gate 1 automatically when spec status = "Approved"

# 3. Write tests first
# (manually or with /test skill)
# → Passes Gate 2 when tests exist and are failing

# 4. Implement code
# (make tests pass)
# → Passes Gate 3 when tests pass and no TODOs

# 5. Refactor
# → Passes Gate 4 when tests still pass and complexity reduced

# 6. Integrate
make openapi && make types
# → Passes Gate 5 when artifacts updated

# 7. E2E verify
/e2e-verify
# → Passes Gate 6 when all E2E checks pass

# 8. Code review
/validator
# → Passes Gate 7 when validator approves

# 9. Complete
# → Feature marked complete, issue closed
```

## Automatic Gate Detection

Gates can advance automatically based on detection:

**Gate 1:** Detects when spec file exists with "Status: Approved"
**Gate 2:** Detects when test files exist and are failing
**Gate 3:** Detects when all tests passing and no TODOs
**Gate 4:** Manual advancement (after refactor)
**Gate 5:** Detects when OpenAPI, types, graphs updated in git
**Gate 6:** Detects when `/e2e-verify` completes successfully
**Gate 7:** Detects when `/validator` returns APPROVED

## Benefits

1. **Visibility** - Always know where you are in the process
2. **No skipping** - Can't skip gates (enforced)
3. **Clear requirements** - Know exactly what's needed to progress
4. **Time tracking** - See how long each phase takes
5. **Historical data** - Learn and improve over time
6. **Confidence** - When you reach Gate 7, work is truly complete

## Implementation Script

```bash
#!/usr/bin/env bash
# Gates Status Checker

FEATURE="${1:-$(git branch --show-current | sed 's/^[^/]*\///')}"
GATE_DIR=".git/quality-gates/$FEATURE"

if [ ! -d "$GATE_DIR" ]; then
  echo "No quality gate tracking for feature: $FEATURE"
  echo "Run: /gates start $FEATURE"
  exit 1
fi

CURRENT_GATE=$(cat "$GATE_DIR/current_gate.txt")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Quality Gate Status: $FEATURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Current Gate: $CURRENT_GATE"
echo ""

# Show gate progress
for i in {1..7}; do
  STATUS_FILE="$GATE_DIR/gate_${i}_*.status"
  if [ -f $STATUS_FILE ]; then
    STATUS=$(cat $STATUS_FILE)
    if [ "$STATUS" = "PASSED" ]; then
      echo "  ✅ Gate $i: $(gate_name $i)"
    elif [ "$i" -eq "$CURRENT_GATE" ]; then
      echo "  🔄 Gate $i: $(gate_name $i) (IN PROGRESS)"
    else
      echo "  ⏸️  Gate $i: $(gate_name $i)"
    fi
  fi
done

# Show gate requirements
echo ""
echo "Gate $CURRENT_GATE Requirements:"
case $CURRENT_GATE in
  1)
    check_gate_1_requirements
    ;;
  2)
    check_gate_2_requirements
    ;;
  3)
    check_gate_3_requirements
    ;;
  # ... etc
esac
```

## Gate Name Helper
```bash
function gate_name() {
  case $1 in
    1) echo "Spec Approved" ;;
    2) echo "Tests First (TDD)" ;;
    3) echo "Implementation Complete" ;;
    4) echo "Refactored" ;;
    5) echo "Integrated" ;;
    6) echo "E2E Verified" ;;
    7) echo "Code Reviewed" ;;
  esac
}
```

## Tips

- Don't skip gates - each builds on the previous
- If stuck at a gate, review requirements carefully
- Use `/gates status` to see how long you've been in current gate
- Historical data helps estimate future work
- Gates prevent "90% done" syndrome - work is either done or not

## Integration with Git Hooks

**pre-commit hook:**
- Checks if current gate allows commits
- Gate 2: Allows test commits only
- Gate 3+: Allows any commits

**pre-push hook:**
- Requires Gate 7 (Code Reviewed) to push to main

**post-commit hook:**
- Auto-advances gates when conditions met
- Updates gate status files
