#!/bin/bash
# Simplified Claude Code Launcher - Team 3
# Only terminal naming functionality

set -euo pipefail

PROJECT_DIR="/home/buckstrdr/claude-workflow-system"

# Update Claude to latest version
echo "→ Updating Claude to latest version..."
npm install -g @anthropic-ai/claude-code@latest

# Verify Claude Code binary
CLAUDE_BINARY="/home/buckstrdr/.nvm/versions/node/v22.20.0/bin/claude"
if [ ! -f "$CLAUDE_BINARY" ]; then
    if command -v claude &> /dev/null; then
        CLAUDE_BINARY="claude"
    else
        echo "ERROR: Claude Code not found!"
        exit 1
    fi
fi

# Display current version
CLAUDE_VERSION=$($CLAUDE_BINARY --version 2>/dev/null | head -1 || echo "unknown")
echo "✓ Claude Code version: $CLAUDE_VERSION"
echo ""

# Launch Claude with fixed terminal title
xterm -xrm 'XTerm.vt100.allowTitleOps: false' -T "CC-TSX-DEV - Team 3" -e bash -c "
    # Prevent bash/shell from changing the title
    export DISABLE_AUTO_TITLE=1
    export CLAUDE_BINARY='$CLAUDE_BINARY'

    # Set fixed terminal title and actively enforce it
    echo -ne '\033]0;CC-TSX-DEV - Team 3\007'
    PROMPT_COMMAND='printf \"\033]0;CC-TSX-DEV - Team 3\007\"'

    cd $PROJECT_DIR || { echo 'Failed to cd to claude-workflow-system'; sleep 3; exit 1; }

    # Re-lock the title
    echo -ne '\033]0;CC-TSX-DEV - Team 3\007'
    PROMPT_COMMAND='printf \"\033]0;CC-TSX-DEV - Team 3\007\"'

    clear
    echo '══════════════════════════════════════════════════════'
    echo '  Claude Code Session - Team 3'
    echo '══════════════════════════════════════════════════════'
    echo ''
    echo \"  Project: \$(pwd)\"
    echo ''
    echo '══════════════════════════════════════════════════════'
    echo ''

    # Run Claude
    \$CLAUDE_BINARY --dangerously-skip-permissions

    # Keep terminal open if Claude exits
    echo ''
    echo 'Claude Code exited. Press Enter to close...'
    read
" &

echo "Claude Code launched successfully"
