#!/bin/bash
# Launch Claude Code instances in each tmux pane with role-specific prompts

set -euo pipefail

FEATURE_NAME="$1"
SESSION_NAME="claude-feature-$FEATURE_NAME"
WORKTREE_PATH="../wt-feature-$FEATURE_NAME"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "Launching Claude Code instances..."

# Build role-specific prompts
build_prompt() {
    local role="$1"
    python3 "$PROJECT_ROOT/scripts/build_prompt.py" "$role" 2>/dev/null || echo "Role: $role"
}

# Launch function with actual Claude Code command
launch_instance() {
    local pane="$1"
    local role="$2"
    local role_name="$3"

    # Build system prompt and save to temp file
    local prompt_file="/tmp/prompt_${role}.txt"
    build_prompt "$role" > "$prompt_file"

    # Source .env to make MCP server URLs available
    # Claude Code will discover remote MCP servers via environment variables
    # Empty mcp-config.json keeps context clean - servers accessed on-demand via HTTPS

    # Launch Claude Code with role-specific prompt from file
    # MCP servers accessible via environment but not in config (clean context)
    tmux send-keys -t "$SESSION_NAME:$pane" \
      "cd $WORKTREE_PATH && source $PROJECT_ROOT/.env && $CLAUDE_CLI --mcp-config $PROJECT_ROOT/mcp-config.json --system-prompt \"\$(cat $prompt_file)\" --dangerously-skip-permissions" C-m
}

# Alternative: Launch with simple echo if Claude Code not available
launch_placeholder() {
    local pane="$1"
    local role_name="$2"

    tmux send-keys -t "$pane" \
      "cd $WORKTREE_PATH && echo '[$role_name] Instance ready. Start work on feature: $FEATURE_NAME'" C-m
}

# Check if Claude Code CLI is available
CLAUDE_CLI=""
if command -v claude &> /dev/null; then
    CLAUDE_CLI="claude"
elif [ -f "$HOME/.nvm/versions/node/v22.20.0/bin/claude" ]; then
    CLAUDE_CLI="$HOME/.nvm/versions/node/v22.20.0/bin/claude"
elif [ -f "$HOME/.nvm/versions/node/v20.*/bin/claude" ]; then
    CLAUDE_CLI=$(find "$HOME/.nvm/versions/node/" -name "claude" -type l 2>/dev/null | head -1)
fi

if [ -n "$CLAUDE_CLI" ]; then
    echo "✓ Claude Code CLI found at: $CLAUDE_CLI"
    CLAUDE_VERSION=$($CLAUDE_CLI --version 2>&1 || echo "unknown")
    echo "  Version: $CLAUDE_VERSION"
    LAUNCH_MODE="full"
else
    echo "⚠ Claude Code CLI not found, using placeholder mode"
    echo "  Install with: npm install -g @anthropic-ai/claude-code"
    LAUNCH_MODE="placeholder"
fi

# Launch all 12 instances across 4 windows
if [ "$LAUNCH_MODE" = "full" ]; then
    # Window 0: Orchestrator (1 pane)
    launch_instance "w0-orchestrator" "orchestrator" "Orchestrator"

    # Window 1: Librarian, Planner-A, Planner-B (3 panes)
    launch_instance "w1-planning.0" "librarian" "Librarian"
    launch_instance "w1-planning.1" "planner" "Planner-A"
    launch_instance "w1-planning.2" "planner" "Planner-B"

    # Window 2: Architect-A, Architect-B, Architect-C, Dev-A (4 panes)
    launch_instance "w2-arch-dev1.0" "architect" "Architect-A"
    launch_instance "w2-arch-dev1.1" "architect" "Architect-B"
    launch_instance "w2-arch-dev1.2" "architect" "Architect-C"
    launch_instance "w2-arch-dev1.3" "dev" "Dev-A"

    # Window 3: Dev-B, QA-A, QA-B, Docs (4 panes)
    launch_instance "w3-dev2-qa-docs.0" "dev" "Dev-B"
    launch_instance "w3-dev2-qa-docs.1" "qa" "QA-A"
    launch_instance "w3-dev2-qa-docs.2" "qa" "QA-B"
    launch_instance "w3-dev2-qa-docs.3" "docs" "Docs"
else
    # Placeholder mode (tmux layout ready, manual launch required)
    launch_placeholder "$SESSION_NAME:w0-orchestrator" "Orchestrator"
    launch_placeholder "$SESSION_NAME:w1-planning.0" "Librarian"
    launch_placeholder "$SESSION_NAME:w1-planning.1" "Planner-A"
    launch_placeholder "$SESSION_NAME:w1-planning.2" "Planner-B"
    launch_placeholder "$SESSION_NAME:w2-arch-dev1.0" "Architect-A"
    launch_placeholder "$SESSION_NAME:w2-arch-dev1.1" "Architect-B"
    launch_placeholder "$SESSION_NAME:w2-arch-dev1.2" "Architect-C"
    launch_placeholder "$SESSION_NAME:w2-arch-dev1.3" "Dev-A"
    launch_placeholder "$SESSION_NAME:w3-dev2-qa-docs.0" "Dev-B"
    launch_placeholder "$SESSION_NAME:w3-dev2-qa-docs.1" "QA-A"
    launch_placeholder "$SESSION_NAME:w3-dev2-qa-docs.2" "QA-B"
    launch_placeholder "$SESSION_NAME:w3-dev2-qa-docs.3" "Docs"
fi

echo ""
echo "✅ All instances launched in $LAUNCH_MODE mode"
echo ""
echo "📍 Feature: $FEATURE_NAME"
echo "📂 Worktree: $WORKTREE_PATH"
echo "🪟 Tmux session: $SESSION_NAME"
echo ""

if [ "$LAUNCH_MODE" = "placeholder" ]; then
    echo "⚙️ To manually launch Claude Code in each pane:"
    echo "   1. Attach: tmux attach-session -t $SESSION_NAME"
    echo "   2. Navigate panes: Ctrl-b + arrow keys"
    echo "   3. Run in each pane: claude code --mcp-config .toolset.yaml"
    echo ""
fi

echo "To attach to session: tmux attach-session -t $SESSION_NAME"
echo "To detach from session: Press Ctrl-b, then d"
echo ""
