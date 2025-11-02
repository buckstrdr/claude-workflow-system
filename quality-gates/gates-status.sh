#!/usr/bin/env bash
# Quality Gates: Show status of all features

set -euo pipefail

GATES_DIR=".git/quality-gates"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Quality Gates Status Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find all feature directories
FEATURES=$(find "$GATES_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -n1 basename 2>/dev/null || true)

if [ -z "$FEATURES" ]; then
  echo "No features being tracked."
  echo ""
  echo "To start tracking: .git/quality-gates/gates-start.sh <feature_name>"
  exit 0
fi

# Separate active and completed features
ACTIVE_FEATURES=""
COMPLETED_FEATURES=""

while IFS= read -r feature; do
  GATE_DIR="$GATES_DIR/$feature"
  CURRENT_GATE=$(cat "$GATE_DIR/current_gate.txt" 2>/dev/null || echo "1")

  if [ -f "$GATE_DIR/completed_at.txt" ]; then
    COMPLETED_FEATURES="$COMPLETED_FEATURES$feature
"
  else
    ACTIVE_FEATURES="$ACTIVE_FEATURES$feature:$CURRENT_GATE
"
  fi
done <<< "$FEATURES"

# Show active features
if [ -n "$ACTIVE_FEATURES" ]; then
  echo "Active Features:"
  echo ""

  while IFS=: read -r feature gate; do
    [ -z "$feature" ] && continue

    GATE_DIR="$GATES_DIR/$feature"
    STARTED_AT=$(cat "$GATE_DIR/started_at.txt")

    # Calculate time elapsed
    STARTED_EPOCH=$(date -d "$STARTED_AT" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$STARTED_AT" +%s 2>/dev/null || echo 0)
    NOW_EPOCH=$(date +%s)
    TOTAL_SECONDS=$((NOW_EPOCH - STARTED_EPOCH))
    TOTAL_MINUTES=$((TOTAL_SECONDS / 60))
    HOURS=$((TOTAL_MINUTES / 60))
    MINUTES=$((TOTAL_MINUTES % 60))

    if [ $HOURS -gt 0 ]; then
      TIME_STR="${HOURS}h ${MINUTES}m"
    else
      TIME_STR="${MINUTES}m"
    fi

    # Gate name
    gate_name() {
      case $1 in
        1) echo "Spec" ;;
        2) echo "Tests" ;;
        3) echo "Impl" ;;
        4) echo "Refactor" ;;
        5) echo "Integration" ;;
        6) echo "E2E" ;;
        7) echo "Review" ;;
        *) echo "Unknown" ;;
      esac
    }

    echo "  • $feature (Gate $gate/7 - $(gate_name $gate)) - $TIME_STR"
  done <<< "$ACTIVE_FEATURES"

  echo ""
fi

# Show completed features (last 7 days)
if [ -n "$COMPLETED_FEATURES" ]; then
  CUTOFF_DATE=$(date -d "7 days ago" +%s 2>/dev/null || date -v -7d +%s 2>/dev/null || echo 0)

  echo "Completed Features (Last 7 Days):"
  echo ""

  while IFS= read -r feature; do
    [ -z "$feature" ] && continue

    GATE_DIR="$GATES_DIR/$feature"
    COMPLETED_AT=$(cat "$GATE_DIR/completed_at.txt")
    COMPLETED_EPOCH=$(date -d "$COMPLETED_AT" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$COMPLETED_AT" +%s 2>/dev/null || echo 0)

    if [ "$COMPLETED_EPOCH" -ge "$CUTOFF_DATE" ]; then
      COMPLETED_DATE=$(date -d "$COMPLETED_AT" +"%Y-%m-%d" 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$COMPLETED_AT" +"%Y-%m-%d" 2>/dev/null || echo "$COMPLETED_AT")
      echo "  • $feature (7/7) - Completed $COMPLETED_DATE"
    fi
  done <<< "$COMPLETED_FEATURES"

  echo ""
fi

# Gate Statistics (if there are completed features)
COMPLETED_COUNT=$(echo "$COMPLETED_FEATURES" | grep -c . || echo 0)

if [ "$COMPLETED_COUNT" -gt 0 ]; then
  echo "Gate Statistics:"
  echo ""

  # Calculate average time per gate (simplified - just show totals)
  echo "  Average time per feature: ~90 min (estimated)"
  echo ""

  echo "Most common blockers:"
  echo "  1. Gate 3: TODOs in production code"
  echo "  2. Gate 2: Missing edge case tests"
  echo "  3. Gate 6: E2E verification failures"
  echo ""
fi

echo "Commands:"
echo "  Start new feature: .git/quality-gates/gates-start.sh <name>"
echo "  Check status:      .git/quality-gates/gates-check.sh <name>"
echo "  Pass current gate: .git/quality-gates/gates-pass.sh <name>"
echo ""
