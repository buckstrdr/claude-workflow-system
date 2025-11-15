#!/bin/bash
# Pre-commit hook: Enforce test-first development

set -euo pipefail

# Check environment variable
STRICT_TDD="${STRICT_TDD:-1}"

if [ "$STRICT_TDD" != "1" ]; then
    echo "⚠️  STRICT_TDD=0: Skipping TDD enforcement"
    exit 0
fi

# Get staged files
STAGED_IMPL=$(git diff --cached --name-only --diff-filter=ACM | \
              grep -E "backend/services/.*\.py$|backend/api/.*\.py$" || true)
STAGED_TESTS=$(git diff --cached --name-only --diff-filter=ACM | \
               grep -E "backend/tests/.*\.py$" || true)

# If no implementation files, allow commit
if [ -z "$STAGED_IMPL" ]; then
    exit 0
fi

# Implementation files staged - check for tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  TDD Enforcement Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if tests are staged together (not allowed)
if [ -n "$STAGED_TESTS" ]; then
    echo "❌ BLOCKED: Cannot commit tests and implementation together"
    echo ""
    echo "TDD requires separate commits:"
    echo "  1. Commit tests FIRST (Red phase)"
    echo "  2. Commit implementation SECOND (Green phase)"
    echo ""
    echo "Staged implementation files:"
    echo "$STAGED_IMPL" | sed 's/^/  - /'
    echo ""
    echo "Staged test files:"
    echo "$STAGED_TESTS" | sed 's/^/  - /'
    echo ""
    echo "To fix:"
    echo "  git reset HEAD backend/tests/  # Unstage tests"
    echo "  git commit -m 'feat: ...'      # Commit implementation"
    echo "  git add backend/tests/         # Stage tests later"
    echo ""
    exit 1
fi

# Implementation staged without tests - check if tests exist in history
ERRORS=0

for impl_file in $STAGED_IMPL; do
    # Derive expected test file path
    test_file=$(echo "$impl_file" | \
                sed 's|backend/services/|backend/tests/test_|' | \
                sed 's|backend/api/|backend/tests/test_|')

    # Check if test file exists and is committed
    if ! git ls-files --error-unmatch "$test_file" >/dev/null 2>&1; then
        echo "❌ Missing test file for: $impl_file"
        echo "   Expected: $test_file"
        echo ""
        ERRORS=$((ERRORS + 1))
    else
        # Test file exists - check if it was committed BEFORE this
        IMPL_COMMITS=$(git log --oneline --follow "$impl_file" 2>/dev/null | wc -l || echo 0)
        TEST_COMMITS=$(git log --oneline --follow "$test_file" 2>/dev/null | wc -l || echo 0)

        if [ "$TEST_COMMITS" -eq 0 ]; then
            echo "❌ Test file not committed yet: $test_file"
            echo "   Implementation: $impl_file"
            echo ""
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

if [ "$ERRORS" -gt 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TDD Violation: Tests must be committed FIRST"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Workflow:"
    echo "  1. Write tests for new functionality"
    echo "  2. git add backend/tests/"
    echo "  3. git commit -m 'test: add tests for feature'"
    echo "  4. Verify tests FAIL (Red phase)"
    echo "  5. Write implementation"
    echo "  6. git add backend/services/"
    echo "  7. git commit -m 'feat: implement feature'"
    echo "  8. Verify tests PASS (Green phase)"
    echo ""
    echo "To bypass (EMERGENCY ONLY):"
    echo "  STRICT_TDD=0 git commit -m 'emergency: ...'"
    echo ""
    exit 1
fi

echo "✅ TDD enforcement passed: Tests exist for all implementation files"
echo ""
exit 0
