#!/bin/bash
# Create feature branch and worktree

set -euo pipefail

FEATURE_NAME="$1"
BRANCH_NAME="feature/$FEATURE_NAME"
WORKTREE_PATH="../wt-feature-$FEATURE_NAME"

# Create branch
git checkout -b "$BRANCH_NAME"

# Create worktree
git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"

# Initialize quality gates
./scripts/quality-gates/gates-start.sh "$FEATURE_NAME"

echo "✅ Git setup complete"
echo "Branch: $BRANCH_NAME"
echo "Worktree: $WORKTREE_PATH"
