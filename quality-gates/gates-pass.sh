#!/usr/bin/env bash
# Quality Gates: Mark current gate as passed and advance

set -euo pipefail

FEATURE="${1:-$(git branch --show-current | sed 's/^[^/]*\///')}"
GATE_DIR=".git/quality-gates/$FEATURE"

if [ ! -d "$GATE_DIR" ]; then
  echo "❌ No quality gate tracking found for: $FEATURE"
  echo ""
  echo "To start tracking: .git/quality-gates/gates-start.sh $FEATURE"
  exit 1
fi

CURRENT_GATE=$(cat "$GATE_DIR/current_gate.txt")

# Gate names
gate_name() {
  case $1 in
    1) echo "Spec Approved" ;;
    2) echo "Tests First (TDD)" ;;
    3) echo "Implementation Complete" ;;
    4) echo "Refactored" ;;
    5) echo "Integrated" ;;
    6) echo "E2E Verified" ;;
    7) echo "Code Reviewed" ;;
    *) echo "Unknown" ;;
  esac
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Quality Gate Validation: $FEATURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Current Gate: $CURRENT_GATE - $(gate_name $CURRENT_GATE)"
echo ""

# Validate requirements for current gate
VALIDATION_PASSED=1

case $CURRENT_GATE in
  1)
    echo "→ Validating Gate 1: Spec Approved"
    echo ""

    # Check if spec file exists
    SPEC_FILE=$(ls .ian/spec_*.md 2>/dev/null | tail -1 || echo "")
    if [ -z "$SPEC_FILE" ]; then
      echo "❌ No specification file found in .ian/"
      VALIDATION_PASSED=0
    else
      echo "✓ Specification file: $SPEC_FILE"

      # Check if approved
      if grep -q "Status: Approved" "$SPEC_FILE"; then
        echo "✓ Specification status: Approved"
      else
        echo "❌ Specification not approved (Status field != 'Approved')"
        VALIDATION_PASSED=0
      fi
    fi
    ;;

  2)
    echo "→ Validating Gate 2: Tests First (TDD)"
    echo ""

    # Check if tests exist
    TEST_COUNT=$(find your_backend/tests/ -name "test_*.py" 2>/dev/null | wc -l || echo 0)
    if [ "$TEST_COUNT" -gt 0 ]; then
      echo "✓ Test files found: $TEST_COUNT"

      # Check if tests are failing (Red phase)
      if python -m pytest your_backend/tests/ -q >/dev/null 2>&1; then
        echo "⚠️  Tests are PASSING (should be FAILING in Red phase)"
        echo "   This is OK if you're reviewing after implementation"
      else
        echo "✓ Tests FAILING (expected Red phase)"
      fi
    else
      echo "❌ No test files found"
      VALIDATION_PASSED=0
    fi
    ;;

  3)
    echo "→ Validating Gate 3: Implementation Complete"
    echo ""

    # Check if tests pass
    if python -m pytest your_backend/tests/ -q >/dev/null 2>&1; then
      echo "✓ All tests PASSING (Green phase)"
    else
      echo "❌ Tests FAILING (need to pass for Gate 3)"
      VALIDATION_PASSED=0
    fi

    # Check for TODOs
    TODOS=$(grep -r "TODO\|FIXME" your_backend/ --exclude-dir="tests" 2>/dev/null || true)
    if [ -z "$TODOS" ]; then
      echo "✓ No TODOs in production code"
    else
      echo "❌ TODOs found in production code"
      VALIDATION_PASSED=0
    fi

    # Check for debug statements
    DEBUG=$(grep -rE "(print\(|console\.log)" your_backend/ your_frontend/src/ --exclude-dir="tests" --exclude-dir="__tests__" 2>/dev/null || true)
    if [ -z "$DEBUG" ]; then
      echo "✓ No debug statements"
    else
      echo "❌ Debug statements found"
      VALIDATION_PASSED=0
    fi
    ;;

  4)
    echo "→ Validating Gate 4: Refactored"
    echo ""

    # Check if tests still pass
    if python -m pytest your_backend/tests/ -q >/dev/null 2>&1; then
      echo "✓ Tests still passing after refactor"
    else
      echo "❌ Tests FAILING after refactor"
      VALIDATION_PASSED=0
    fi

    echo "⚠️  Code quality checks (manual review recommended)"
    ;;

  5)
    echo "→ Validating Gate 5: Integrated"
    echo ""

    # Check if OpenAPI updated recently
    if [ -f ".serena/knowledge/openapi.json" ]; then
      OPENAPI_AGE=$(( $(date +%s) - $(stat -c %Y .serena/knowledge/openapi.json 2>/dev/null || stat -f %m .serena/knowledge/openapi.json 2>/dev/null || echo 0) ))
      if [ "$OPENAPI_AGE" -lt 3600 ]; then
        echo "✓ OpenAPI spec updated recently"
      else
        echo "⚠️  OpenAPI spec not updated recently (run: make openapi)"
      fi
    else
      echo "❌ OpenAPI spec not found"
      VALIDATION_PASSED=0
    fi

    # Check if FE types exist
    if [ -f "your_frontend/src/types/api.d.ts" ]; then
      echo "✓ Frontend types exist"
    else
      echo "❌ Frontend types not found (run: make types)"
      VALIDATION_PASSED=0
    fi
    ;;

  6)
    echo "→ Validating Gate 6: E2E Verified"
    echo ""

    echo "⚠️  E2E verification requires running services"
    echo "   Manual validation: /e2e-verify"
    echo ""
    echo "   Assuming E2E verification passed if you're advancing"
    ;;

  7)
    echo "→ Validating Gate 7: Code Reviewed"
    echo ""

    echo "⚠️  Code review requires manual /validator run"
    echo "   Assuming validator approved if you're advancing"
    ;;
esac

echo ""

if [ "$VALIDATION_PASSED" -eq 0 ]; then
  echo "❌ VALIDATION FAILED"
  echo ""
  echo "Fix the issues above and re-run:"
  echo "  .git/quality-gates/gates-pass.sh $FEATURE"
  echo ""
  exit 1
fi

# Mark current gate as PASSED
GATE_STATUS_FILE="$GATE_DIR/gate_${CURRENT_GATE}_$(gate_name $CURRENT_GATE | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g').status"
echo "PASSED" > "$GATE_STATUS_FILE"

# Advance to next gate (if not at gate 7)
if [ "$CURRENT_GATE" -lt 7 ]; then
  NEXT_GATE=$((CURRENT_GATE + 1))
  echo "$NEXT_GATE" > "$GATE_DIR/current_gate.txt"

  echo "✅ Gate $CURRENT_GATE PASSED - $(gate_name $CURRENT_GATE)"
  echo ""
  echo "Advanced to Gate $NEXT_GATE: $(gate_name $NEXT_GATE)"
  echo ""
else
  # Gate 7 passed = complete
  date -u +"%Y-%m-%dT%H:%M:%SZ" > "$GATE_DIR/completed_at.txt"

  echo "🎉 Gate 7 PASSED - ALL GATES COMPLETE!"
  echo ""
  echo "Feature: $FEATURE"
  echo "Started: $(cat "$GATE_DIR/started_at.txt")"
  echo "Completed: $(cat "$GATE_DIR/completed_at.txt")"
  echo ""
  echo "Work is production-ready:"
  echo "  • Mark todo as completed"
  echo "  • Close GitHub issue"
  echo "  • Merge PR"
  echo ""
fi
