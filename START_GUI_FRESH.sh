#!/bin/bash
# Bulletproof GUI starter - kills old processes and starts fresh
set -e

cd /home/buckstrdr/claude-workflow-system

echo "=== Killing any existing GUI processes ==="
pkill -f "python.*startup_gui.py" || true
sleep 2

echo ""
echo "=== Verifying we're in the right directory ==="
pwd
ls -la startup_gui.py

echo ""
echo "=== Starting fresh GUI ==="
python3 ./startup_gui.py
