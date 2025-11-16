#!/bin/bash
# Master Hook Installer - Integrates .claude/hooks with .git/hooks

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installing .claude/hooks to Git Hooks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Backup existing pre-commit if it exists
if [ -f .git/hooks/pre-commit ]; then
    cp .git/hooks/pre-commit .git/hooks/pre-commit.backup-$(date +%Y%m%d_%H%M%S)
    echo -e "${YELLOW}📦 Backed up existing pre-commit${NC}"
fi

# Create comprehensive pre-commit hook
cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/bin/bash
# Master Pre-Commit Hook - Runs all .claude/hooks checks

echo "Running pre-commit checks..."

# 1. Python code quality (Black, Flake8, Pylint, Vulture)
if [ -f .claude/hooks/python-code-quality.sh ]; then
    .claude/hooks/python-code-quality.sh || exit 1
fi

# 2. UI testing enforcement (Playwright)
if [ -f .claude/hooks/enforce-playwright-ui-tests.sh ]; then
    .claude/hooks/enforce-playwright-ui-tests.sh || exit 1
fi

# 3. Strategy config validation
if [ -f .claude/hooks/strategy-config-validator.sh ]; then
    .claude/hooks/strategy-config-validator.sh || exit 1
fi

# 4. Dependency check (informational)
if [ -f .claude/hooks/dependency-check.sh ]; then
    .claude/hooks/dependency-check.sh
fi

# 5. OpenAPI sync check
if [ -f .claude/hooks/openapi-sync-check.sh ]; then
    .claude/hooks/openapi-sync-check.sh || exit 1
fi

# 6. Auto-sync types if API changed
if [ -f .claude/hooks/auto-sync-types.sh ]; then
    .claude/hooks/auto-sync-types.sh
fi

# 7. Test runner
if [ -f .claude/hooks/test-runner.sh ]; then
    .claude/hooks/test-runner.sh || exit 1
fi

# 8. Semantic index refresh (10+ files)
if [ -f .claude/hooks/semantic-index-refresh.sh ]; then
    .claude/hooks/semantic-index-refresh.sh
fi

exit 0
HOOK_EOF

chmod +x .git/hooks/pre-commit
echo -e "${GREEN}✓ Installed pre-commit hook${NC}"

# Create commit-msg hook
cat > .git/hooks/commit-msg << 'HOOK_EOF'
#!/bin/bash
# Commit Message Quality Hook

if [ -f .claude/hooks/commit-message-quality.sh ]; then
    .claude/hooks/commit-message-quality.sh "$1" || exit 1
fi

exit 0
HOOK_EOF

chmod +x .git/hooks/commit-msg
echo -e "${GREEN}✓ Installed commit-msg hook${NC}"

# Create prepare-commit-msg hook (session reminder)
cat > .git/hooks/prepare-commit-msg-claude << 'HOOK_EOF'
#!/bin/bash
# Workflow Reminder Hook (optional - uncomment to enable)

# Uncomment to show workflow reminders before commits:
# if [ -f .claude/hooks/workflow-reminder.sh ]; then
#     .claude/hooks/workflow-reminder.sh
# fi

exit 0
HOOK_EOF

chmod +x .git/hooks/prepare-commit-msg-claude
echo -e "${GREEN}✓ Created prepare-commit-msg-claude (optional)${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Installed hooks:${NC}"
echo "  ✓ pre-commit    - Runs all quality checks"
echo "  ✓ commit-msg    - Validates Conventional Commits"
echo ""
echo -e "${YELLOW}Pre-commit runs (in order):${NC}"
echo "  1. Python code quality (Black, Flake8, Pylint, Vulture)"
echo "  2. UI testing enforcement (Playwright)"
echo "  3. Strategy config validation"
echo "  4. Dependency check (warnings)"
echo "  5. OpenAPI sync check"
echo "  6. Auto-sync types (if API changed)"
echo "  7. Test runner"
echo "  8. Semantic index refresh (10+ files)"
echo ""
echo -e "${YELLOW}To test:${NC}"
echo "  1. Make a change to a Python file"
echo "  2. git add <file>"
echo "  3. git commit -m \"test: verify hooks\""
echo ""
echo -e "${YELLOW}To disable temporarily:${NC}"
echo "  git commit --no-verify"
echo ""
