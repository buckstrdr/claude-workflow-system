#!/bin/bash
# Kill any existing GUI and restart fresh

echo "Stopping any running GUI..."
pkill -9 -f startup_gui
sleep 2

echo "Starting fresh GUI..."
cd /home/buckstrdr/claude-workflow-system
python3 ./startup_gui.py
