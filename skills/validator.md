# Validator - Task Completion Validator

Quality assurance agent that validates task completion by verifying implementations actually work end-to-end.

## What This Skill Does

Validates that completed work actually functions:
- Tests the implementation end-to-end
- Checks for regressions
- Verifies todos are complete
- Tests edge cases
- Returns APPROVED or REJECTED with details

## How to Use

```
/validator

Then provide context:
CONTEXT: Just implemented order idempotency in OrderService.
Added duplicate detection using idempotency_store before submitting orders.

Please validate this implementation.
```

## Validation Workflow

### 1. Understand the Change
- What was implemented?
- What files were modified?
- What was the intended behavior?

### 2. Test the Implementation
```bash
# Find the implementation
/find "order idempotency"

# Read the code
# Review: OrderService, idempotency_store integration

# Check for tests
ls your_backend/tests/test_order_service.py

# Run tests
pytest your_backend/tests/ -k idempotency
```

### 3. Verify End-to-End
```bash
# Start services if needed
/status
/start (if not running)

# Test the actual functionality
curl -X POST http://localhost:8000/api/orders/submit \
  -H "Content-Type: application/json" \
  -d '{"symbol": "MNQ", "quantity": 1, "order_type": "market"}'

# Try duplicate (should be rejected)
# Same request again

# Check logs for idempotency messages
/logs backend | grep idempotency
```

### 4. Check for Regressions
```bash
# Run full test suite
pytest your_backend/

# Check existing functionality still works
# Test order submission without duplication
# Test other order service methods
```

### 5. Validate Edge Cases
- What if idempotency key is None?
- What if store is full?
- What if same order from different client?
- What happens after restart?

## Output Format

### APPROVED
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ VALIDATION: APPROVED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementation: Order Idempotency
Status: APPROVED ✓

What Was Validated:
  ✓ Code implementation in OrderService
  ✓ IdempotencyStore integration
  ✓ Duplicate detection works
  ✓ Edge cases handled
  ✓ No regressions
  ✓ Tests pass

Test Results:
  - Submitted order #1: SUCCESS
  - Submitted duplicate: REJECTED (as expected)
  - Error message: "Duplicate order: MNQ:1:market:..."
  - Full test suite: 45/45 PASSED

Edge Cases Verified:
  ✓ Null idempotency key: Handled
  ✓ Store persistence: Works across restarts
  ✓ Concurrent submissions: Properly serialized

Recommendations:
  - Add integration test for duplicate detection
  - Document idempotency behavior in API docs
  - Consider TTL for idempotency cache

Ready to commit: YES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### REJECTED
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✗ VALIDATION: REJECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementation: Order Idempotency
Status: REJECTED ✗

Issues Found:

1. Duplicate orders NOT detected
   Location: your_backend/services/order_service.py:87
   Problem: IdempotencyStore.is_duplicate() never called
   Evidence: Submitted same order twice, both succeeded

2. Tests failing
   Test: test_order_service.py::test_duplicate_rejection
   Error: AssertionError: Expected ValueError, got OrderResponse

3. Edge case not handled
   Scenario: Idempotency key is None
   Result: KeyError crash
   Location: your_backend/services/idempotency_store.py:23

Required Fixes:
  1. Call is_duplicate() before submitting order
  2. Fix test to match actual behavior
  3. Handle None idempotency key gracefully

Test Results: 43/45 FAILED

Do NOT commit until these issues are fixed.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Validation Checklist

For every validation:

- [ ] Code review (implementation looks correct)
- [ ] Unit tests exist and pass
- [ ] Integration tests pass (if applicable)
- [ ] End-to-end test (actual functionality)
- [ ] Edge cases handled
- [ ] No regressions (existing tests pass)
- [ ] Error handling appropriate
- [ ] Documentation updated (if needed)
- [ ] Performance acceptable
- [ ] Security considerations addressed

## When to Use

**Always validate after:**
- Completing a feature
- Fixing a bug
- Making significant changes
- Before creating a pull request
- When user claims "done"

**Before:**
- Committing code
- Marking todo as complete
- Moving to next task

## Integration with Workflow

```bash
# Typical workflow
# 1. Implement feature
Edit("order_service.py", ...)

# 2. Mark as complete
TodoWrite([...status: "completed"...])

# 3. VALIDATE
/validator
> CONTEXT: Implemented order idempotency...

# 4. Review validation results
# - If APPROVED: commit
# - If REJECTED: fix issues, re-validate

# 5. Commit only after approval
git add . && git commit -m "feat: add order idempotency"
```

## Tips

- Be thorough - don't just check if code runs
- Test edge cases - that's where bugs hide
- Verify the actual problem was solved
- Check for regressions - did we break anything?
- Don't approve incomplete implementations
- Be specific about what's wrong in REJECTED
