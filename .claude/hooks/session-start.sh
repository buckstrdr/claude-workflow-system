#!/bin/bash
# Session Start Hook - Runs at beginning of every Claude Code session

# Backup CLAUDE.md before session starts
BACKUP_DIR=".claude/backups"
mkdir -p "$BACKUP_DIR"
cp CLAUDE.md "$BACKUP_DIR/CLAUDE.md.$(date +%Y%m%d_%H%M%S).bak"

# Keep only last 10 backups
ls -t "$BACKUP_DIR"/CLAUDE.md.*.bak | tail -n +11 | xargs -r rm

echo "✓ Session started - CLAUDE.md backed up"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SUPERPOWERS-FIRST WORKFLOW - MANDATORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Before responding to ANY task:"
echo "  1. ☐ Check if a superpowers skill matches the request"
echo "  2. ☐ If yes → Use the skill (MANDATORY, not optional)"
echo "  3. ☐ Agents are SECONDARY - only when superpowers recommends"
echo ""
echo "Discovery commands:"
echo "  • List skills: ls .claude/skills/"
echo "  • List commands: ls .claude/commands/ (or type / + Tab)"
echo "  • Check hooks: cat .claude/settings.local.json"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
