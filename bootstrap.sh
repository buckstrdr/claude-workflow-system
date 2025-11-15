#!/bin/bash
# Master bootstrap script

set -euo pipefail

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: $0 <feature_name>"
    exit 1
fi

echo "=== Claude Multi-Instance Bootstrap ==="
echo "Feature: $FEATURE_NAME"
echo ""

# Run all bootstrap steps
for script in scripts/bootstrap/*.sh; do
    echo "Running: $(basename $script)"
    "$script" "$FEATURE_NAME" || {
        echo "❌ Bootstrap failed at: $(basename $script)"
        exit 1
    }
    echo ""
done

echo "✅ Bootstrap complete!"
tmux attach-session -t "claude-feature-$FEATURE_NAME:orchestrator"
