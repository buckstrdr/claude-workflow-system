#!/bin/bash
# Show status of all features with quality gate tracking

set -euo pipefail

GATE_DIR=".git/quality-gates"

if [ ! -d "$GATE_DIR" ] || [ -z "$(ls -A $GATE_DIR 2>/dev/null)" ]; then
    echo "No features with quality gate tracking found."
    exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Quality Gates - All Features"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for feature_dir in "$GATE_DIR"/*; do
    if [ -d "$feature_dir" ]; then
        feature=$(basename "$feature_dir")
        status_file="$feature_dir/status.json"

        if [ -f "$status_file" ]; then
            current_gate=$(jq -r '.current_gate' "$status_file")
            gate_name=$(jq -r ".gates[\"$current_gate\"].name" "$status_file")
            started=$(cat "$feature_dir/started_at.txt" 2>/dev/null || echo "Unknown")

            # Check if complete
            if [ -f "$feature_dir/completed_at.txt" ]; then
                completed=$(cat "$feature_dir/completed_at.txt")
                echo "✅ $feature - COMPLETE (finished $completed)"
            else
                echo "🔄 $feature - Gate $current_gate: $gate_name (started $started)"
            fi
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
