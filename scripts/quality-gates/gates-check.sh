#!/bin/bash
# Check current quality gate status for a feature

set -euo pipefail

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: $0 <feature_name>"
    exit 1
fi

GATE_DIR=".git/quality-gates/$FEATURE_NAME"
STATUS_FILE="$GATE_DIR/status.json"

# Check if exists
if [ ! -f "$STATUS_FILE" ]; then
    echo "❌ No quality gate tracking found for: $FEATURE_NAME"
    echo "Initialize with: ./scripts/quality-gates/gates-start.sh $FEATURE_NAME"
    exit 1
fi

# Validate JSON
if ! jq empty "$STATUS_FILE" 2>/dev/null; then
    echo "❌ Invalid JSON in status file"
    echo "Run recovery: ./scripts/quality-gates/gates-recover.sh $FEATURE_NAME"
    exit 1
fi

# Display status
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Quality Gates: $FEATURE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Current gate
CURRENT_GATE=$(jq -r '.current_gate' "$STATUS_FILE")
CURRENT_GATE_NAME=$(jq -r ".gates[\"$CURRENT_GATE\"].name" "$STATUS_FILE")
echo "Current Gate: $CURRENT_GATE ($CURRENT_GATE_NAME)"
echo ""

# Display all gates
for i in {1..7}; do
    GATE_NAME=$(jq -r ".gates[\"$i\"].name" "$STATUS_FILE")
    GATE_STATUS=$(jq -r ".gates[\"$i\"].status" "$STATUS_FILE")

    if [ "$i" -eq "$CURRENT_GATE" ]; then
        echo "→ Gate $i: $GATE_NAME - $GATE_STATUS ◄ CURRENT"
    elif [ "$GATE_STATUS" = "PASSED" ]; then
        echo "✅ Gate $i: $GATE_NAME - $GATE_STATUS"
    else
        echo "  Gate $i: $GATE_NAME - $GATE_STATUS"
    fi
done

echo ""

# Show current gate requirements
echo "Current Gate Requirements:"
jq -r ".gates[\"$CURRENT_GATE\"].requirements[] | \"  [\(.status)] \(.check)\"" "$STATUS_FILE"
echo ""

# Started/completed timestamps
STARTED=$(cat "$GATE_DIR/started_at.txt")
echo "Started: $STARTED"

if [ -f "$GATE_DIR/completed_at.txt" ]; then
    COMPLETED=$(cat "$GATE_DIR/completed_at.txt")
    echo "Completed: $COMPLETED"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
