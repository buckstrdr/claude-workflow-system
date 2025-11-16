#!/bin/bash
# Initialize quality gate tracking for a new feature

set -euo pipefail

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: $0 <feature_name>"
    exit 1
fi

GATE_DIR=".git/quality-gates/$FEATURE_NAME"

# Check if already exists
if [ -d "$GATE_DIR" ]; then
    echo "⚠️  Quality gates already initialized for: $FEATURE_NAME"
    echo "⚠️  Using existing quality gates"
    exit 0
fi

# Create directory
mkdir -p "$GATE_DIR"

# Create status.json
cat > "$GATE_DIR/status.json" <<EOF
{
  "feature": "$FEATURE_NAME",
  "current_gate": 1,
  "started_at": "$(date -Iseconds)",
  "gates": {
    "1": {
      "name": "Spec Approved",
      "status": "PENDING",
      "requirements": [
        {"check": "spec_exists", "status": "PENDING"},
        {"check": "spec_approved", "status": "PENDING"}
      ]
    },
    "2": {
      "name": "Tests First",
      "status": "PENDING",
      "requirements": [
        {"check": "tests_exist", "status": "PENDING"},
        {"check": "tests_fail", "status": "PENDING"},
        {"check": "no_implementation", "status": "PENDING"}
      ]
    },
    "3": {
      "name": "Implementation Complete",
      "status": "PENDING",
      "requirements": [
        {"check": "tests_pass", "status": "PENDING"},
        {"check": "no_todos", "status": "PENDING"},
        {"check": "no_debug", "status": "PENDING"}
      ]
    },
    "4": {
      "name": "Refactored",
      "status": "PENDING",
      "requirements": [
        {"check": "dry_principles", "status": "PENDING"},
        {"check": "solid_principles", "status": "PENDING"},
        {"check": "tests_still_pass", "status": "PENDING"}
      ]
    },
    "5": {
      "name": "Integrated",
      "status": "PENDING",
      "requirements": [
        {"check": "openapi_updated", "status": "PENDING"},
        {"check": "types_synced", "status": "PENDING"},
        {"check": "docs_updated", "status": "PENDING"}
      ]
    },
    "6": {
      "name": "E2E Verified",
      "status": "PENDING",
      "requirements": [
        {"check": "backend_starts", "status": "PENDING"},
        {"check": "frontend_builds", "status": "PENDING"},
        {"check": "e2e_tests_pass", "status": "PENDING"}
      ]
    },
    "7": {
      "name": "Code Reviewed",
      "status": "PENDING",
      "requirements": [
        {"check": "validator_passed", "status": "PENDING"},
        {"check": "critical_issues_resolved", "status": "PENDING"},
        {"check": "production_ready", "status": "PENDING"}
      ]
    }
  }
}
EOF

# Create individual gate status files
for i in {1..7}; do
    echo "PENDING" > "$GATE_DIR/gate_${i}.status"
done

# Create timestamps
echo "$(date -Iseconds)" > "$GATE_DIR/started_at.txt"

# Create notes file
cat > "$GATE_DIR/notes.md" <<EOF
# Quality Gates: $FEATURE_NAME

**Started:** $(date -Iseconds)

## Gate Progression Notes

### Gate 1: Spec Approved
-

### Gate 2: Tests First
-

### Gate 3: Implementation Complete
-

### Gate 4: Refactored
-

### Gate 5: Integrated
-

### Gate 6: E2E Verified
-

### Gate 7: Code Reviewed
-
EOF

echo "✅ Quality gates initialized for: $FEATURE_NAME"
echo "Location: $GATE_DIR"
echo "Current gate: 1 (Spec Approved)"
