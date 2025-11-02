# Quality Gates Tracking System

This directory tracks progression through the 7-stage quality gate system for each feature.

## Directory Structure

```
.git/quality-gates/
  README.md                    # This file
  gates-start.sh              # Start tracking a new feature
  gates-check.sh              # Check current gate status
  gates-pass.sh               # Mark current gate as passed
  gates-status.sh             # Show status of all features
  {feature_name}/             # Per-feature tracking
    current_gate.txt          # Current gate number (1-7)
    gate_1_spec.status        # PASSED or PENDING
    gate_2_tests.status       # PASSED or PENDING
    gate_3_impl.status        # PASSED or PENDING
    gate_4_refactor.status    # PASSED or PENDING
    gate_5_integration.status # PASSED or PENDING
    gate_6_e2e.status         # PASSED or PENDING
    gate_7_review.status      # PASSED or PENDING
    started_at.txt            # ISO timestamp
    completed_at.txt          # ISO timestamp (when gate 7 passed)
    notes.md                  # Optional notes
```

## 7-Stage Quality Gate System

**Gate 1: Spec Approved**
- Specification file exists in `.ian/spec_*.md`
- All required sections complete
- User has approved spec
- Status field = "Approved"

**Gate 2: Tests First (TDD)**
- Tests written BEFORE implementation code
- Tests reflect success criteria from spec
- Tests are FAILING (Red phase)
- No implementation code exists yet

**Gate 3: Implementation Complete**
- All tests now PASSING (Green phase)
- Success criteria from spec are met
- No TODOs in production code
- No debug statements

**Gate 4: Refactored**
- Code follows DRY principles
- SOLID principles applied
- Function/class names clear
- Tests still passing

**Gate 5: Integrated**
- OpenAPI spec regenerated
- Frontend types synced
- Code graphs updated
- Semantic index updated
- Documentation updated

**Gate 6: E2E Verified**
- Backend starts successfully
- Frontend builds and loads
- API endpoints respond
- Feature-specific tests pass
- No runtime errors

**Gate 7: Code Reviewed**
- `/validator` agent review completed
- All CRITICAL issues addressed
- All HIGH PRIORITY issues addressed
- Production readiness confirmed

## Usage

### Start New Feature
```bash
.git/quality-gates/gates-start.sh order_idempotency
```

### Check Current Status
```bash
.git/quality-gates/gates-check.sh order_idempotency
```

### Pass Current Gate
```bash
.git/quality-gates/gates-pass.sh order_idempotency
```

### View All Features
```bash
.git/quality-gates/gates-status.sh
```

## Integration

The `/gates` skill uses these scripts to:
- Display current gate and requirements
- Validate gate requirements
- Advance to next gate
- Show historical statistics

## Benefits

1. **Visibility** - Always know where you are in the process
2. **No skipping** - Can't skip gates (enforced)
3. **Clear requirements** - Know exactly what's needed to progress
4. **Time tracking** - See how long each phase takes
5. **Historical data** - Learn and improve over time
6. **Confidence** - When you reach Gate 7, work is truly complete
