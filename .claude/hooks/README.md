# Claude Code Workflow Hooks

This directory contains callback hooks that enhance your Claude Code workflow.

## Workflow Integration - Superpowers First

**IMPORTANT**: This project uses a **superpowers-first workflow**:

1. **Superpowers Skills** (PRIMARY) - 20+ battle-tested skills loaded via SessionStart hook:
   - Brainstorming, planning, TDD, debugging, verification, code review
   - MANDATORY to check for matching skills before responding to any task
   - Located in project skills directory and loaded as plugin

2. **Claude Hooks** (AUTOMATION) - This directory:
   - Automated quality gates, backups, reminders
   - Run at specific events (SessionStart, PreToolUse, etc.)
   - Support the workflow without manual intervention

3. **Project Skills** (SPECIALIZED) - 40+ domain-specific skills:
   - Located in `.claude/skills/` and `.claude/commands/`
   - Domain experts (backend, strategy, UI testing, etc.)
   - Complementary to superpowers

4. **Agents** (SECONDARY/OPTIONAL) - Only when superpowers recommends:
   - Architect, Engineer, QA, Documentation agents
   - Used for complex work requiring focused expertise

**Hook Purpose**: Hooks automate the mechanics (file protection, backups, quality checks) while superpowers skills guide the strategic decisions (when to TDD, how to debug, design patterns).

## Available Hooks

### session-start.sh
- Runs at the beginning of every Claude Code session
- Automatically backs up CLAUDE.md (keeps last 10 backups)
- Displays superpowers-first workflow reminder with mandatory skill-checking protocol
- Shows discovery commands for skills, commands, and hooks
- Backups stored in `.claude/backups/`

### before-write.sh
- Runs before any Write tool use
- Protects CLAUDE.md and AGENTS.md from accidental overwrites
- Requires explicit confirmation before modifying protected files

### workflow-reminder.sh
- Displays superpowers-first workflow reminders
- Shows primary workflow (superpowers skills - MANDATORY)
- Shows secondary workflow (agents - when superpowers recommends)
- Lists discovery commands and quality tools
- Reminds about auto-commit functionality
- Can be called manually or integrated into hooks

### enforce-playwright-ui-tests.sh
- Enforces Playwright usage for all UI changes
- Validates 1920x1080 resolution testing (per CLAUDE.md standards)
- Checks for screenshot artifacts
- Blocks commits without UI testing (with override option)
- See `ui-test-checklist.md` for detailed testing requirements

### python-code-quality.sh
- Runs Black (code formatter) - checks 100 char line length
- Runs Flake8 (style guide) - PEP 8 enforcement
- Runs Pylint (code analysis) - errors block, warnings don't
- Runs Vulture (dead code detection) - non-blocking warnings
- Only checks changed `.py` files
- Provides quick fix commands on failure

### install-quality-tools.sh
- Helper script to install all Python quality tools
- Run once: `.claude/hooks/install-quality-tools.sh`

### auto-sync-types.sh
- Auto-generates FE types when backend API changes
- Runs `make openapi && make types`
- Stages generated files automatically

### strategy-config-validator.sh
- Validates `strategies.yaml` syntax before commit
- Checks YAML validity and required canonical fields
- Ensures proper strategy structure

### test-runner.sh
- Runs pytest on changed Python modules
- Looks for corresponding test files
- Blocks commit if tests fail (with override)

### dependency-check.sh
- Alerts when new imports detected
- Reminds to update requirements.txt
- Warns when dependency files change

### commit-message-quality.sh
- Enforces Conventional Commits format
- Types: feat, fix, docs, style, refactor, test, chore, perf
- Provides helpful examples on failure

### openapi-sync-check.sh
- Checks if FE types match OpenAPI spec timestamps
- Blocks if types are outdated
- Prompts to run `make types`

### semantic-index-refresh.sh
- Auto-refreshes Serena index after 10+ file changes
- Runs `make semantic` incrementally
- Stages updated index files

## How Hooks Work

Claude Code supports callback hooks for events like:
- `SessionStart` - When a new session begins
- `UserPromptSubmit` - Before processing user input
- `ToolUse` - Before tool execution
- `SessionEnd` - When session closes

## Configuration

To enable these hooks, add to your `.claude/settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/before-write.sh"
          }
        ]
      }
    ]
  }
}
```

**Note**: The hooks configuration uses an array format where each event can have multiple hook objects with optional matchers and required hooks arrays.

## Custom Hooks

You can create custom hooks for:
- Auto-syncing types after backend changes
- Running smoke tests before commits
- Validating strategy configs
- Enforcing code standards

## Protected Files

Current hooks protect:
- `CLAUDE.md` - Workflow instructions
- `AGENTS.md` - Agent configurations

Add more protected files by editing `before-write.sh`.
