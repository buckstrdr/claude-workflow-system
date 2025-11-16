#!/bin/bash
# Convenience script to launch the MCP Startup GUI
# This is the main entry point for starting the multi-instance system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make sure we're in the project root
cd "$SCRIPT_DIR"

# Kill any existing GUI processes to ensure fresh start
if pgrep -f "python3.*startup_gui.py" > /dev/null 2>&1; then
    echo "Stopping existing GUI process..."
    pkill -f "python3.*startup_gui.py" || true
    sleep 1
fi

# Check if Tkinter is available
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║  Tkinter GUI Not Available                            ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    echo "Python Tkinter is not installed."
    echo ""
    echo "To install it, run:"
    echo "  ./install-tkinter.sh"
    echo ""
    echo "Or install manually:"
    echo "  Ubuntu/Debian: sudo apt-get install python3-tk"
    echo "  Fedora/RHEL:   sudo dnf install python3-tkinter"
    echo "  Arch:          sudo pacman -S tk"
    echo ""
    echo "Alternatively, use the terminal UI:"
    echo "  ./scripts/mcp/startup-gui.sh"
    echo ""
    exit 1
fi

# Launch the Tkinter GUI
exec python3 ./startup_gui.py
