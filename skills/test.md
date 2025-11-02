# Test - Intelligent Test Runner

Smart test execution based on code changes, with automatic test selection and result analysis.

## What This Skill Does

Intelligently runs tests based on what changed:
- Detect changed files (git diff)
- Run relevant tests only
- Backend changes → pytest
- Frontend changes → npm test
- Strategy changes → strategy tests
- Display results with clear pass/fail

## How to Use

```
/test              # Auto-detect and run relevant tests
/test backend      # Run backend tests only
/test frontend     # Run frontend tests only
/test all          # Run everything
/test file <path>  # Test specific file
```

## Implementation

### Auto-Detection
```bash
# Detect what changed
CHANGED_FILES=$(git diff --name-only HEAD)

if echo "$CHANGED_FILES" | grep -q "topstepx_backend"; then
  echo "Backend changes detected, running pytest..."
  pytest topstepx_backend/
fi

if echo "$CHANGED_FILES" | grep -q "topstepx_frontend"; then
  echo "Frontend changes detected, running npm test..."
  cd topstepx_frontend && npm test
fi

if echo "$CHANGED_FILES" | grep -q "strategy"; then
  echo "Strategy changes detected, running strategy tests..."
  pytest topstepx_backend/strategy/tests/
fi
```

### Backend Tests
```bash
# Run all backend tests
pytest topstepx_backend/ -v

# Run with coverage
pytest topstepx_backend/ --cov=topstepx_backend --cov-report=html

# Run specific test file
pytest topstepx_backend/tests/test_order_service.py

# Run specific test
pytest topstepx_backend/tests/test_order_service.py::test_submit_order
```

### Frontend Tests
```bash
cd topstepx_frontend

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test file
npm test -- OrderForm.test.tsx

# Watch mode
npm test -- --watch
```

### Smoke Tests
```bash
# Run smoke tests (integration tests)
python dev/smoke/test_brackets_trailing.py
python dev/smoke/monitor_bars_parity.py --duration-min 5
python dev/smoke/test_startup_backfill.py
```

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Test Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Backend Tests (pytest):
  ✓ test_order_service.py::test_submit_order
  ✓ test_order_service.py::test_cancel_order
  ✗ test_bracket_editor.py::test_bracket_creation
    Error: AssertionError: Expected status 'pending', got 'rejected'
    File: topstepx_backend/tests/test_bracket_editor.py:45

Frontend Tests (npm):
  ✓ OrderForm.test.tsx
  ✓ PositionList.test.tsx
  ✗ Dashboard.test.tsx
    Error: Component did not render
    File: topstepx_frontend/src/components/Dashboard.test.tsx:23

Summary:
  Total: 5 tests
  Passed: 4 (80%)
  Failed: 1 (20%)

Failed Tests:
  1. test_bracket_editor.py::test_bracket_creation
     topstepx_backend/tests/test_bracket_editor.py:45

Next Steps:
  - Fix failing tests
  - Run: /test backend to re-run
  - Check logs: /logs backend
```

## Tips

- Run `/test` after code changes to catch issues early
- Use `/test backend` or `/test frontend` for faster iteration
- Check coverage reports to find untested code
- Integrate with `/debug` for test debugging
