#!/bin/bash
# Before Write Hook - Runs before any Write tool use

FILE="$1"

# Protect CLAUDE.md from being overwritten
if [[ "$FILE" == *"CLAUDE.md"* ]]; then
    echo "⚠️  WARNING: Attempting to modify CLAUDE.md"
    echo "This file contains critical workflow instructions."
    echo "Are you CERTAIN you want to modify it? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Write to CLAUDE.md BLOCKED"
        exit 1
    fi
fi

# Protect AGENTS.md
if [[ "$FILE" == *"AGENTS.md"* ]]; then
    echo "⚠️  WARNING: Attempting to modify AGENTS.md"
    echo "This contains agent configurations. Proceed? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Write to AGENTS.md BLOCKED"
        exit 1
    fi
fi

exit 0
