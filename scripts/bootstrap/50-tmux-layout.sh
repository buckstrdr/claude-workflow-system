#!/bin/bash
# Create SEPARATE tmux sessions for each terminal (4 sessions, 12 panes total)
# This prevents cross-session resize interference

set -euo pipefail

FEATURE_NAME="$1"
BASE_NAME="claude-$FEATURE_NAME"

# Session 1: Orchestrator (1 pane)
tmux new-session -d -s "${BASE_NAME}-orchestrator" -x 240 -y 67

# Session 2: Planning (3 panes: Librarian, Planner-A, Planner-B)
tmux new-session -d -s "${BASE_NAME}-planning" -x 240 -y 67
tmux split-window -t "${BASE_NAME}-planning" -h
tmux split-window -t "${BASE_NAME}-planning" -h
tmux select-layout -t "${BASE_NAME}-planning" even-horizontal

# Session 3: Architecture (4 panes: Architect-A/B/C, Dev-A)
tmux new-session -d -s "${BASE_NAME}-architecture" -x 120 -y 67
tmux split-window -t "${BASE_NAME}-architecture" -h
tmux split-window -t "${BASE_NAME}-architecture.0" -v
tmux split-window -t "${BASE_NAME}-architecture.2" -v
tmux select-layout -t "${BASE_NAME}-architecture" tiled

# Session 4: Dev+QA+Docs (4 panes: Dev-B, QA-A/B, Docs)
tmux new-session -d -s "${BASE_NAME}-dev-qa-docs" -x 120 -y 67
tmux split-window -t "${BASE_NAME}-dev-qa-docs" -h
tmux split-window -t "${BASE_NAME}-dev-qa-docs.0" -v
tmux split-window -t "${BASE_NAME}-dev-qa-docs.2" -v
tmux select-layout -t "${BASE_NAME}-dev-qa-docs" tiled

echo "✅ tmux layout created: 4 separate sessions for $FEATURE_NAME (12 panes total)"
