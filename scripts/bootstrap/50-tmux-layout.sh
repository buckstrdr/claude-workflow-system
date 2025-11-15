#!/bin/bash
# Create tmux session and layout

set -euo pipefail

FEATURE_NAME="$1"
SESSION_NAME="claude-feature-$FEATURE_NAME"

# Create session with orchestrator window
tmux new-session -d -s "$SESSION_NAME" -n orchestrator

# Create core-roles window (3 panes)
tmux new-window -t "$SESSION_NAME" -n core-roles
tmux split-window -t "$SESSION_NAME:core-roles" -h
tmux split-window -t "$SESSION_NAME:core-roles" -h
tmux select-layout -t "$SESSION_NAME:core-roles" even-horizontal

# Create implementation window (4 panes)
tmux new-window -t "$SESSION_NAME" -n implementation
tmux split-window -t "$SESSION_NAME:implementation" -h
tmux split-window -t "$SESSION_NAME:implementation.0" -v
tmux split-window -t "$SESSION_NAME:implementation.2" -v
tmux select-layout -t "$SESSION_NAME:implementation" tiled

# Create docs window
tmux new-window -t "$SESSION_NAME" -n docs

# Return to orchestrator
tmux select-window -t "$SESSION_NAME:orchestrator"

echo "✅ tmux layout created: $SESSION_NAME"
