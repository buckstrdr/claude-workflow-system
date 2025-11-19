#!/bin/bash
# Launch Claude Code instances in each tmux pane with role-specific prompts

set -euo pipefail

FEATURE_NAME="$1"
BASE_NAME="claude-$FEATURE_NAME"
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
    local session="$1"  # Now takes full session name like "claude-test-orchestrator"
    local pane="$2"     # Pane number within that session
    local role="$3"
    local role_name="$4"

    # Map role name to message board directory name FIRST (needed for prompt)
    local msg_role="$role"
    case "$role_name" in
        "Orchestrator") msg_role="orchestrator" ;;
        "Planner-A") msg_role="planner-a" ;;
        "Planner-B") msg_role="planner-b" ;;
        "Architect-A") msg_role="architect-a" ;;
        "Architect-B") msg_role="architect-b" ;;
        "Architect-C") msg_role="architect-c" ;;
        "Dev-A") msg_role="dev-a" ;;
        "Dev-B") msg_role="dev-b" ;;
        "QA-A") msg_role="qa-a" ;;
        "QA-B") msg_role="qa-b" ;;
        "Docs") msg_role="docs" ;;
        "Librarian") msg_role="librarian" ;;
    esac

    # Build system prompt and save to temp file
    local prompt_file="/tmp/prompt_${msg_role}.txt"
    build_prompt "$role" > "$prompt_file"

    # Append instance-specific identity to prompt
    # This ensures each instance knows their specific identity (A, B, C) and inbox
    cat >> "$prompt_file" <<EOF

---

# Instance Identity

**Role:** $role_name
**Inbox:** $msg_role
**MCP Message Store:** Use \`check_inbox\` MCP tool with role="$msg_role" to read messages
**Send Messages:** Use \`send_message\` MCP tool with from_role="$msg_role"

When other instances send messages to you, they will address them to: **$msg_role**

You are part of a 12-instance multiagent system. Each instance has a unique identity and inbox.
EOF

    # Source .env for API keys (SERENA_API_KEY, FIRECRAWL_API_KEY, CONTEXT7_API_KEY)
    # All instances connect to vMCP aggregation layer (http://localhost:10985)
    # vMCP "claude multiagent" composition aggregates 9 servers: serena, git, filesystem, terminal, context7, firecrawl, playwright, puppeteer, hf-mcp
    # Connection reduction: 108 (12 instances × 9 servers) → 21 (12 instances → 1 vMCP → 9 servers)

    # Launch Claude Code with role-specific prompt from file
    # MCP servers loaded from mcp-config-vmcp.json (vMCP aggregation on port 10985)
    tmux send-keys -t "$session.$pane" \
      "cd $WORKTREE_PATH && source $PROJECT_ROOT/.env && $CLAUDE_CLI --mcp-config $PROJECT_ROOT/mcp-config-vmcp.json --system-prompt \"\$(cat $prompt_file)\" --dangerously-skip-permissions" C-m

    # Start inbox watcher in background for ALL roles (including orchestrator)
    if true; then

        # Start inbox watcher as independent background process
        # Does NOT use tmux send-keys to avoid blocking Claude's input
        (
            sleep 10  # Wait for Claude to fully initialize (needs ~10 seconds)
            ROLE_NAME=$msg_role FEATURE_NAME=$FEATURE_NAME WORKTREE_PATH=$WORKTREE_PATH \
            "$PROJECT_ROOT/scripts/roles/inbox_watcher.sh" "$msg_role" "$WORKTREE_PATH" \
            > "/tmp/inbox-watcher-$msg_role.log" 2>&1 &
        ) &
    fi
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

# Launch all 12 instances across 4 separate sessions
if [ "$LAUNCH_MODE" = "full" ]; then
    # Session 1: Orchestrator (1 pane)
    launch_instance "${BASE_NAME}-orchestrator" "0" "orchestrator" "Orchestrator"

    # Session 2: Planning (3 panes)
    launch_instance "${BASE_NAME}-planning" "0" "librarian" "Librarian"
    launch_instance "${BASE_NAME}-planning" "1" "planner" "Planner-A"
    launch_instance "${BASE_NAME}-planning" "2" "planner" "Planner-B"

    # Session 3: Architecture (4 panes)
    launch_instance "${BASE_NAME}-architecture" "0" "architect" "Architect-A"
    launch_instance "${BASE_NAME}-architecture" "1" "architect" "Architect-B"
    launch_instance "${BASE_NAME}-architecture" "2" "architect" "Architect-C"
    launch_instance "${BASE_NAME}-architecture" "3" "dev" "Dev-A"

    # Session 4: Dev+QA+Docs (4 panes)
    launch_instance "${BASE_NAME}-dev-qa-docs" "0" "dev" "Dev-B"
    launch_instance "${BASE_NAME}-dev-qa-docs" "1" "qa" "QA-A"
    launch_instance "${BASE_NAME}-dev-qa-docs" "2" "qa" "QA-B"
    launch_instance "${BASE_NAME}-dev-qa-docs" "3" "docs" "Docs"
else
    # Placeholder mode (tmux layout ready, manual launch required)
    launch_placeholder "${BASE_NAME}-orchestrator" "Orchestrator"
    launch_placeholder "${BASE_NAME}-planning" "Librarian"
    launch_placeholder "${BASE_NAME}-planning" "Planner-A"
    launch_placeholder "${BASE_NAME}-planning" "Planner-B"
    launch_placeholder "${BASE_NAME}-architecture" "Architect-A"
    launch_placeholder "${BASE_NAME}-architecture" "Architect-B"
    launch_placeholder "${BASE_NAME}-architecture" "Architect-C"
    launch_placeholder "${BASE_NAME}-architecture" "Dev-A"
    launch_placeholder "${BASE_NAME}-dev-qa-docs" "Dev-B"
    launch_placeholder "${BASE_NAME}-dev-qa-docs" "QA-A"
    launch_placeholder "${BASE_NAME}-dev-qa-docs" "QA-B"
    launch_placeholder "${BASE_NAME}-dev-qa-docs" "Docs"
fi

echo ""
echo "✅ All instances launched in $LAUNCH_MODE mode"
echo ""
echo "📍 Feature: $FEATURE_NAME"
echo "📂 Worktree: $WORKTREE_PATH"
echo "🪟 Tmux sessions: ${BASE_NAME}-*"
echo ""

if [ "$LAUNCH_MODE" = "placeholder" ]; then
    echo "⚙️ To manually launch Claude Code in each pane:"
    echo "   1. Attach to any session: tmux attach-session -t ${BASE_NAME}-orchestrator"
    echo "   2. Navigate panes: Ctrl-b + arrow keys"
    echo "   3. Run in each pane: claude code --mcp-config .toolset.yaml"
    echo ""
fi

echo "To attach to orchestrator: tmux attach-session -t ${BASE_NAME}-orchestrator"
echo "To attach to planning: tmux attach-session -t ${BASE_NAME}-planning"
echo "To detach from session: Press Ctrl-b, then d"
echo ""
