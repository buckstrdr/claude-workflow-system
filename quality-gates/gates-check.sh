#!/usr/bin/env bash
# Quality Gates: Check current gate status

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
STARTED_AT=$(cat "$GATE_DIR/started_at.txt")

# Calculate time in current gate
STARTED_EPOCH=$(date -d "$STARTED_AT" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$STARTED_AT" +%s 2>/dev/null || echo 0)
NOW_EPOCH=$(date +%s)
TOTAL_SECONDS=$((NOW_EPOCH - STARTED_EPOCH))
TOTAL_MINUTES=$((TOTAL_SECONDS / 60))
HOURS=$((TOTAL_MINUTES / 60))
MINUTES=$((TOTAL_MINUTES % 60))

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
echo "  Quality Gate Status: $FEATURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Current Gate: $CURRENT_GATE - $(gate_name $CURRENT_GATE)"
echo ""
echo "Progress:"

# Show all gates
for i in {1..7}; do
  STATUS_FILE="$GATE_DIR/gate_${i}_*.status"

  if compgen -G "$STATUS_FILE" >/dev/null 2>&1; then
    STATUS=$(cat $STATUS_FILE 2>/dev/null || echo "PENDING")
  else
    STATUS="PENDING"
  fi

  if [ "$STATUS" = "PASSED" ]; then
    echo "  ✅ Gate $i: $(gate_name $i)"
  elif [ "$i" -eq "$CURRENT_GATE" ]; then
    echo "  🔄 Gate $i: $(gate_name $i) (IN PROGRESS)"
  else
    echo "  ⏸️  Gate $i: $(gate_name $i)"
  fi
done

echo ""
echo "Time Tracking:"
if [ $HOURS -gt 0 ]; then
  echo "  Total time: ${HOURS}h ${MINUTES}m"
else
  echo "  Total time: ${MINUTES}m"
fi

# Show requirements for current gate
echo ""
echo "Gate $CURRENT_GATE Requirements:"

case $CURRENT_GATE in
  1)
    echo "  - [ ] Specification file exists in .ian/spec_*.md"
    echo "  - [ ] All required sections complete"
    echo "  - [ ] User has approved spec"
    echo "  - [ ] Status field = 'Approved'"
    echo ""
    echo "Next: /spec"
    ;;
  2)
    echo "  - [ ] Tests written BEFORE implementation"
    echo "  - [ ] Tests reflect spec success criteria"
    echo "  - [ ] Tests are FAILING (Red phase)"
    echo "  - [ ] No implementation code exists"
    echo ""
    echo "Next: Write tests in tests/ directory"
    ;;
  3)
    echo "  - [ ] All tests PASSING (Green phase)"
    echo "  - [ ] Success criteria met"
    echo "  - [ ] No TODOs in production code"
    echo "  - [ ] No debug statements"
    echo ""
    echo "Next: Implement code to make tests pass"
    ;;
  4)
    echo "  - [ ] Code follows DRY principles"
    echo "  - [ ] SOLID principles applied"
    echo "  - [ ] Function/class names clear"
    echo "  - [ ] Tests still passing"
    echo ""
    echo "Next: Refactor implementation"
    ;;
  5)
    echo "  - [ ] OpenAPI spec regenerated (make openapi)"
    echo "  - [ ] Frontend types synced (make types)"
    echo "  - [ ] Code graphs updated"
    echo "  - [ ] Documentation updated"
    echo ""
    echo "Next: make openapi && make types"
    ;;
  6)
    echo "  - [ ] Backend starts successfully"
    echo "  - [ ] Frontend builds and loads"
    echo "  - [ ] API endpoints respond"
    echo "  - [ ] No runtime errors"
    echo ""
    echo "Next: /e2e-verify"
    ;;
  7)
    echo "  - [ ] /validator agent review completed"
    echo "  - [ ] All CRITICAL issues addressed"
    echo "  - [ ] All HIGH PRIORITY issues addressed"
    echo "  - [ ] Production readiness confirmed"
    echo ""
    echo "Next: /validator"
    ;;
esac

echo ""
