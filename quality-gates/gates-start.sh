#!/usr/bin/env bash
# Quality Gates: Start tracking a new feature

set -euo pipefail

FEATURE="${1:-}"

if [ -z "$FEATURE" ]; then
  echo "Usage: $0 <feature_name>"
  echo ""
  echo "Example: $0 order_idempotency"
  exit 1
fi

GATE_DIR=".git/quality-gates/$FEATURE"

if [ -d "$GATE_DIR" ]; then
  echo "⚠️  Feature '$FEATURE' already has gate tracking"
  echo ""
  echo "Current gate: $(cat "$GATE_DIR/current_gate.txt")"
  echo ""
  echo "To reset: rm -rf $GATE_DIR && $0 $FEATURE"
  exit 1
fi

# Create feature directory
mkdir -p "$GATE_DIR"

# Initialize gate tracking
echo "1" > "$GATE_DIR/current_gate.txt"
echo "PENDING" > "$GATE_DIR/gate_1_spec.status"
echo "PENDING" > "$GATE_DIR/gate_2_tests.status"
echo "PENDING" > "$GATE_DIR/gate_3_impl.status"
echo "PENDING" > "$GATE_DIR/gate_4_refactor.status"
echo "PENDING" > "$GATE_DIR/gate_5_integration.status"
echo "PENDING" > "$GATE_DIR/gate_6_e2e.status"
echo "PENDING" > "$GATE_DIR/gate_7_review.status"
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$GATE_DIR/started_at.txt"

echo "✅ Quality gate tracking started for: $FEATURE"
echo ""
echo "Feature: $FEATURE"
echo "Current Gate: 1 - Spec Approved"
echo "Started: $(cat "$GATE_DIR/started_at.txt")"
echo ""
echo "Next steps:"
echo "  1. Create specification: /spec"
echo "  2. Get user approval"
echo "  3. Update spec status to 'Approved'"
echo "  4. Advance gate: .git/quality-gates/gates-pass.sh $FEATURE"
echo ""
