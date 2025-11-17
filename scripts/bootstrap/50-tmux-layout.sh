#!/bin/bash
# Create tmux session and layout for 12 Claude Code instances
# Layout: 4 windows with 1, 3, 4, 4 panes

set -euo pipefail

FEATURE_NAME="$1"
SESSION_NAME="claude-feature-$FEATURE_NAME"

# Window 0: Orchestrator (1 pane)
# Force window size: 240 cols x 67 rows (full 1920px screen)
tmux new-session -d -s "$SESSION_NAME" -n "w0-orchestrator" -x 240 -y 67

# Enable aggressive-resize GLOBALLY so each window sizes independently
tmux set-window-option -g aggressive-resize on

# Window 1: Librarian, Planner-A, Planner-B (3 panes)
tmux new-window -t "$SESSION_NAME" -n "w1-planning"
tmux split-window -t "$SESSION_NAME:w1-planning" -h
tmux split-window -t "$SESSION_NAME:w1-planning" -h
tmux select-layout -t "$SESSION_NAME:w1-planning" even-horizontal
# Force window size: 240 cols x 67 rows (full 1920px screen)
tmux resize-window -t "$SESSION_NAME:w1-planning" -x 240 -y 67

# Window 2: Architect-A, Architect-B, Architect-C, Dev-A (4 panes in 2x2 grid)
tmux new-window -t "$SESSION_NAME" -n "w2-arch-dev1"
tmux split-window -t "$SESSION_NAME:w2-arch-dev1" -h
tmux split-window -t "$SESSION_NAME:w2-arch-dev1.0" -v
tmux split-window -t "$SESSION_NAME:w2-arch-dev1.2" -v
tmux select-layout -t "$SESSION_NAME:w2-arch-dev1" tiled
# Force window size: 120 cols x 67 rows (half 1920px screen = 960px)
tmux resize-window -t "$SESSION_NAME:w2-arch-dev1" -x 120 -y 67

# Window 3: Dev-B, QA-A, QA-B, Docs (4 panes in 2x2 grid)
tmux new-window -t "$SESSION_NAME" -n "w3-dev2-qa-docs"
tmux split-window -t "$SESSION_NAME:w3-dev2-qa-docs" -h
tmux split-window -t "$SESSION_NAME:w3-dev2-qa-docs.0" -v
tmux split-window -t "$SESSION_NAME:w3-dev2-qa-docs.2" -v
tmux select-layout -t "$SESSION_NAME:w3-dev2-qa-docs" tiled
# Force window size: 120 cols x 67 rows (half 1920px screen = 960px)
tmux resize-window -t "$SESSION_NAME:w3-dev2-qa-docs" -x 120 -y 67

# Return to orchestrator window and resize it
tmux select-window -t "$SESSION_NAME:w0-orchestrator"
# Window 0 already sized from new-session, but ensure it's correct
tmux resize-window -t "$SESSION_NAME:w0-orchestrator" -x 240 -y 67

echo "✅ tmux layout created: $SESSION_NAME (4 windows, 12 panes total)"
