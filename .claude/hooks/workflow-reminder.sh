#!/bin/bash
# Workflow Reminder Hook - Reminds about key workflows

echo "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Workflow Reminders - SUPERPOWERS FIRST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 PRIMARY WORKFLOW - Superpowers Skills (MANDATORY):
  • Before coding: /sp-brainstorm (refine ideas into designs)
  • Plan implementation: /sp-write-plan (bite-sized tasks)
  • Execute plans: /sp-execute-plan (batches with review)
  • TDD workflow: /sp-tdd (write tests first)
  • Debugging: /sp-debug (4-phase systematic approach)
  • Before claiming done: /sp-verify (evidence before assertions)
  • Request review: /sp-request-review (dispatch code-reviewer)

🔍 Discovery Commands:
  • List all skills: ls .claude/skills/
  • List all commands: ls .claude/commands/ (or type / + Tab)
  • Check active hooks: cat .claude/settings.local.json

🛠️ SECONDARY WORKFLOW - Agents (when superpowers recommends):
  • Complex planning: /architect or /pm
  • Implementation: /engineer
  • Quality review: /qa
  • Documentation: /docs

✅ Quality Tools:
  • After implementing: /validator
  • Before commits: /pragmatist
  • Before merging: /karen (reality check)

💾 Auto-commit (active - saves every 30s):
  • Roll back: undo
  • View history: commitlog
  • File history: filehistory <file>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"
