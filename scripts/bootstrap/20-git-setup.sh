#!/bin/bash
# Create feature branch and worktree

set -euo pipefail

FEATURE_NAME="$1"
BRANCH_NAME="feature/$FEATURE_NAME"
WORKTREE_PATH="../wt-feature-$FEATURE_NAME"

# Prune any missing worktrees first (cleanup from previous runs)
git worktree prune 2>/dev/null || true

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "⚠️  Worktree already exists: $WORKTREE_PATH"
    echo "⚠️  Using existing worktree"
else
    # Check if branch exists
    if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
        echo "Branch $BRANCH_NAME already exists, creating worktree from it"
        git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
    else
        # Create new branch and worktree
        echo "Creating new branch: $BRANCH_NAME"
        git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"
    fi
fi

# Initialize quality gates in main repo .git directory (if script exists)
if [ -f ./scripts/quality-gates/gates-start.sh ]; then
    # Quality gates are stored in main repo's .git, not worktree
    ./scripts/quality-gates/gates-start.sh "$FEATURE_NAME"
else
    echo "⚠️  Quality gates script not found (optional)"
fi

echo "✅ Git setup complete"
echo "Branch: $BRANCH_NAME"
echo "Worktree: $WORKTREE_PATH"
echo "Working directory: $(pwd)"
