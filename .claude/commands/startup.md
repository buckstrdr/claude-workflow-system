# Startup - Complete Session Initialization

Perform the comprehensive session initialization checklist to ensure optimal development environment with all tools and services verified.

## What This Skill Does

Automates the complete 21-step initialization process:
1. Verify environment (directory, CLAUDE.md, AGENTS.md)
2. Check and start MCP servers (Serena, Codex, etc.)
3. Verify development tools (skills, plugins, hooks)
4. Check auto-commit service
5. Load Serena memories
6. Verify git status and build artifacts
7. Test backend importability
8. Generate comprehensive readiness report
9. Ask user for task

## How to Use

```
/startup
```

No arguments needed - automatically performs full initialization.

## Complete Implementation

### Step 1: Verify Current Directory

```bash
pwd
# Expected: /home/buckstrdr/TopStepx
```

### Step 2-5: Load Core Documentation

Read these files to understand project context:
- `CLAUDE.md` - **Superpowers-first workflow** (primary), agents (secondary/optional), core principles
- `AGENTS.md` - Agent definitions and canonical config (use when superpowers recommends)
- `dev/devtools/mcp/WORKFLOW.md` - MCP architecture
- `Makefile` - Available commands

**CRITICAL**: CLAUDE.md now positions superpowers skills as the PRIMARY workflow. Before responding to ANY task:
1. ☐ Check if a superpowers skill matches the request
2. ☐ If yes → Use the skill (MANDATORY, not optional)
3. ☐ Agents are SECONDARY - only when superpowers recommends them

### Step 5.5: Session Continuity (Previous Session Context)

**CHECK**: Does `.ian/last_session_summary.md` exist?

```bash
if [ -f ".ian/last_session_summary.md" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Previous Session Context"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  cat .ian/last_session_summary.md
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

**If session summary exists:**
- Display previous session's work
- Show incomplete tasks
- Show quality gate status
- Recommend next actions based on previous context

**Session Summary Format** (`.ian/last_session_summary.md`):
```markdown
# Session Summary - 2025-10-29 14:30

## What Was Worked On
- Feature: Order idempotency implementation
- Files modified:
  - topstepx_backend/services/order_service.py
  - topstepx_backend/tests/test_order_idempotency.py

## Quality Gate Status
- Current Gate: 5/7 (Integrated)
- Completed Gates: Spec, Tests First, Implementation, Refactor
- Next Gate: E2E Verified
- Blockers: None

## Incomplete Tasks
- [ ] Run /e2e-verify to validate end-to-end functionality
- [ ] Advance to Gate 6 after E2E passes
- [ ] Run /validator for final code review

## Git State
- Branch: issue/42-order-idempotency
- Uncommitted changes: 0
- Ready to push: No (needs Gate 7)

## Recommended Next Actions
1. Run /e2e-verify to validate implementation
2. If passing, advance to Gate 6: .git/quality-gates/gates-pass.sh order_idempotency
3. Run /validator for code review
4. Address any validator issues
5. Close issue #42 when Gate 7 passed

## Notes
- Idempotency store using Redis with 5-minute TTL
- All tests passing
- OpenAPI and types already synced
```

**Action**: If summary exists, read it and present to user:

```
📋 Continuing from previous session...

Last worked on: Order idempotency implementation
Current gate: 5/7 (Integrated)

Next recommended actions:
  1. Run /e2e-verify
  2. Advance to Gate 6
  3. Run /validator

Ready to continue with this feature, or start new task?
```

**If no session summary exists:**
- This is a fresh start
- No previous context to load
- Continue with normal initialization

### Step 6-9: MCP Server Check

```bash
# Check MCP status
make mcp-status

# Expected output shows running servers:
# - Serena (:9121)
# - Codex
# - OpenAPI
# - Playwright
# - etc.

# If any stopped, start them
if ! make mcp-status | grep -q "Serena.*RUNNING"; then
  echo "Starting MCPs..."
  make mcp-start
fi
```

Verify Serena tools available by checking for `mcp__serena__*` tools.

### Step 10-13: Development Tools Verification

```bash
# Check skills count (expect 34 skills)
SKILL_COUNT=$(ls .claude/skills/*.md | grep -v README | wc -l)
echo "Skills: $SKILL_COUNT/34"

# List all skills
ls -1 .claude/skills/*.md | grep -v README | sed 's|.claude/skills/||; s|.md||'

# Check git hooks (expect 13+ hooks)
HOOK_COUNT=$(ls -1 .git/hooks/ | grep -v ".sample" | wc -l)
echo "Git Hooks: $HOOK_COUNT"

# List active hooks
ls -1 .git/hooks/ | grep -v ".sample"

# Check if Superpowers plugin loaded
# (Check available tools for superpowers-related tools)
```

Expected development tools:
- **20+ Superpowers skills** (PRIMARY workflow):
  - Core: brainstorming, writing-plans, executing-plans, subagent-driven-development
  - Development: test-driven-development, systematic-debugging, root-cause-tracing, defense-in-depth
  - Quality: verification-before-completion, requesting-code-review, receiving-code-review, testing-anti-patterns
  - Workflow: using-git-worktrees, finishing-a-development-branch, dispatching-parallel-agents, condition-based-waiting
- **40+ Project skills**: startup, status, logs, find, validator, karen, pragmatist, api, asyncio, clean, debug, fastapi, pydantic, python, react, restart, smoke, start, strategy, sync, tailwind, test, trading, triage, typescript, websocket, zustand, github, spec, verify-complete, e2e-verify, adr, gates, session-end, backend-expert, strategy-sme, create-plugin, ui-verify, etc.
- **Superpowers plugin**: Loaded and active via SessionStart hook (MANDATORY)
- **13+ git hooks**:
  - Repo: pre-commit, commit-msg, post-commit, pre-push, post-checkout, post-merge
  - Local: prepare-commit-msg, pre-rebase, pre-push-cleanup-wip

### Step 14-16: Auto-Commit Service Verification

```bash
# Check service status
systemctl --user status auto-commit.service | head -5

# Expected: active (running)
# If not running: systemctl --user start auto-commit.service

# Verify watching correct directories
tail -10 /tmp/auto-commit.log | grep "ONLY watching"

# Expected output:
#   ONLY watching: topstepx_backend topstepx_frontend
#   Ignoring: .serena/, dev/, docs/, data/, etc.

# Test commands available
type commitstatus commitlog undo commits goback 2>/dev/null && echo "✓ Auto-commit commands available" || echo "⚠ Source ~/.bashrc"
```

### Step 17-19: Repository State

```bash
# Git status
git status

# Recent commits
git log --oneline -5

# Check frontend types synced
test -f topstepx_frontend/src/types/api.d.ts && echo "✓ FE types" || echo "⚠ Run: make types"

# Check if types are in sync with OpenAPI
if [ -f .serena/knowledge/openapi.json ]; then
  OPENAPI_MOD=$(stat -c %Y .serena/knowledge/openapi.json 2>/dev/null || stat -f %m .serena/knowledge/openapi.json)
  TYPES_MOD=$(stat -c %Y topstepx_frontend/src/types/api.d.ts 2>/dev/null || stat -f %m topstepx_frontend/src/types/api.d.ts)

  if [ "$OPENAPI_MOD" -gt "$TYPES_MOD" ]; then
    echo "⚠ Types out of sync - run: make types"
  fi
fi

# Check for loose .md files in root (should be in .ian/)
LOOSE_MD=$(find . -maxdepth 1 -type f -name "*.md" ! -name "README.md" ! -name "CLAUDE.md" ! -name "AGENTS.md" ! -name "CONTRIBUTING.md" ! -name "CHANGELOG.md" ! -name "SESSION_INIT_PROMPT.md" ! -name "INIT_QUICK.md" ! -name "AUTO_COMMIT_README.md" ! -name "AUTOSAVE_QUICK_START.md" ! -name "GIT_AUTOSAVE_GUIDE.md" ! -name "COMPLETE_SYSTEM_ARCHITECTURE.md" ! -name "EXIT_POLICY_TESTING_GUIDE.md" ! -name "PERPETUITY_ARCHITECTURE_ANALYSIS.md" ! -name "PERPETUITY_FIXES.md" ! -name "STRATEGY_ANALYTICS_ROADMAP.md" ! -name "STRATEGY LOGS*.md" 2>/dev/null || true)

# Check for loose test files in root (should be in .ian/ or proper test dirs)
LOOSE_TESTS=$(find . -maxdepth 1 -type f \( -name "test_*.py" -o -name "*_test.py" -o -name "*.test.js" -o -name "*.test.ts" -o -name "*.spec.js" -o -name "*.spec.ts" \) 2>/dev/null || true)

if [ -n "$LOOSE_MD" ] || [ -n "$LOOSE_TESTS" ]; then
  echo "⚠ LOOSE SESSION FILES DETECTED in root (should be in .ian/):"
  if [ -n "$LOOSE_MD" ]; then
    echo "$LOOSE_MD" | sed 's|^\./|  - |' | sed 's/$/ (markdown)/'
  fi
  if [ -n "$LOOSE_TESTS" ]; then
    echo "$LOOSE_TESTS" | sed 's|^\./|  - |' | sed 's/$/ (test file)/'
  fi
  echo "  Move to .ian/: mv <file> .ian/"
  echo "  Production tests: use topstepx_backend/tests/ or topstepx_frontend/src/__tests__/"
fi
```

### Step 20: Generate Session Summary

Present results in this format:

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TopStepX Session Initialization Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**MCP Status**: RUNNING
- Serena: ✓
- Codex: ✓
- OpenAPI: ✓
- Playwright: ✓
- Filesystem: ✓
- Git: ✓
- Other MCPs: 8 total

**Development Tools**:
- Skills: 34 skills available
  (/startup, /status, /logs, /find, /validator, /karen, /pragmatist, /api,
   /asyncio, /clean, /debug, /fastapi, /pydantic, /python, /react, /restart,
   /smoke, /start, /strategy, /sync, /tailwind, /test, /trading, /triage,
   /typescript, /websocket, /zustand, /github, /spec, /verify-complete,
   /e2e-verify, /adr, /gates, /session-end)
- Plugins: Superpowers loaded ✓
- Git Hooks: 13 hooks active
  (pre-commit, commit-msg, post-commit, pre-push, post-checkout, post-merge,
   prepare-commit-msg, pre-rebase, pre-push-cleanup-wip)

**Auto-Commit Service**:
- Status: RUNNING ✓
- Watching: topstepx_backend/, topstepx_frontend/
- Recent activity: Auto-commit: 2025-10-29 12:15:30

**Knowledge Base**:
- Memories loaded: 2 (program_architecture_2025_10_26, operational_deep_dive_2025_10_26)
- Semantic index: ✓ Present
- OpenAPI spec: ✓ Present
- Frontend types: ✓ Synced

**Repository State**:
- Branch: main
- Uncommitted changes: 0 files
- Recent commits:
  • abc1234 Auto-commit: 2025-10-29 12:45:00
  • def5678 feat: add order idempotency
  • 9876543 fix: frontend logs 405 error

**Available Commands**:
- Auto-commit: commitstatus, commitlog, undo, commits, goback, filehistory, commitswhen
- Skills: /startup, /status, /logs, /find, /validator, /karen, /pragmatist, /api, etc.
- Standard: make dev, make openapi, make types, make ci-check, make hooks-install

**Backend**:
- Import test: ✓ Backend imports successfully
- API server: Check with /status

**Readiness Level**: ✓ OPTIMAL

All systems ready for development!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 21: Ask User for Task

**If OPTIMAL:**
```
What issue or task should I work on?
```

**If DEGRADED:**
```
⚠ DEGRADED status - found issues:
  1. [List specific issues]

Recommended actions:
  1. [Specific commands to fix]

Should I fix these issues first, or proceed with task?
What should I work on?
```

**If CRITICAL:**
```
✗ CRITICAL status - multiple issues found:
  1. [List all issues]

Strongly recommend running full rebuild:
  make full

This will regenerate all artifacts and fix most issues.

Should I run this now?
```

## Readiness Levels

### OPTIMAL (All Green)
- ✓ All MCP servers running
- ✓ 28 skills available
- ✓ Superpowers plugin loaded
- ✓ 13+ git hooks active
- ✓ Auto-commit service running
- ✓ Semantic index present
- ✓ OpenAPI spec present
- ✓ Frontend types synced
- ✓ Backend imports successfully

### DEGRADED (Some Issues)
- ⚠ Some MCP servers stopped (but Serena running)
- ⚠ Types out of sync
- ⚠ Auto-commit service stopped
- ⚠ Some uncommitted changes
Can still work, but with limitations.

### CRITICAL (Major Issues)
- ✗ Serena MCP not running (no semantic search)
- ✗ Backend import failed
- ✗ No OpenAPI spec
- ✗ No semantic index
Should fix before proceeding.

## Important Reminders

After initialization, remind user of:

- **SUPERPOWERS FIRST (MANDATORY)**: Before responding to ANY task, check if a superpowers skill matches. If yes, you MUST use it - not optional. Common rationalizations ("this is simple", "I'll just...", "skill is overkill") are WRONG. If skill exists, use it or fail.
- **Discovery patterns**: Explore before asking - check `.claude/skills/` and `.claude/commands/` before saying "I don't know how"
- **Agents are SECONDARY**: Only use agents when superpowers skills recommend them, or for complex work requiring specialized expertise
- **Focus on program surface**: topstepx_backend/, topstepx_frontend/, data/
- **Use Serena for code discovery**: Don't build/fix tooling, use it to find code fast
- **Test actual functionality**: Run server, test endpoints, check UI - not just syntax
- **DELETE legacy code aggressively**: Delete > Consolidate, no sacred cows
- **Auto-commit has your back**: Every change auto-commits to backend/frontend, use `undo` to roll back
- **Use skills proactively**: /validator after implementing, /karen for reality checks, /pragmatist for code review

## When to Use

- **Start of every session** - Mandatory initialization
- **After pulling changes** - Verify everything still works
- **When something feels off** - Quick health check
- **Before major work** - Ensure optimal setup

## Tips

- Always run this at session start (or use /startup skill)
- If DEGRADED, consider fixing issues before coding
- If CRITICAL, always fix issues first
- Auto-commit service should always be RUNNING
- Check commitlog occasionally to see auto-commits happening
- Use undo liberally - you have 30-second checkpoints
