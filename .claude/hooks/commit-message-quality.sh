#!/bin/bash
# Commit Message Quality Hook - Enforces Conventional Commits

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Skip if auto-commit
if echo "$COMMIT_MSG" | grep -q "^Auto-commit:"; then
    exit 0
fi

# Conventional Commits pattern: type(scope): description
PATTERN="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{10,}"

if ! echo "$COMMIT_MSG" | head -1 | grep -qE "$PATTERN"; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  Commit message doesn't follow Conventional Commits${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${RED}Current message:${NC}"
    echo "$COMMIT_MSG" | sed 's/^/  /'
    echo ""
    echo -e "${YELLOW}Expected format:${NC}"
    echo "  <type>(<scope>): <description>"
    echo ""
    echo -e "${YELLOW}Types:${NC}"
    echo "  feat:     New feature"
    echo "  fix:      Bug fix"
    echo "  docs:     Documentation only"
    echo "  style:    Code style (formatting, no logic change)"
    echo "  refactor: Code refactoring"
    echo "  test:     Add/update tests"
    echo "  chore:    Maintenance (deps, config)"
    echo "  perf:     Performance improvement"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  feat(api): add order idempotency endpoint"
    echo "  fix(ui): resolve modal z-index issue"
    echo "  docs(readme): update installation instructions"
    echo ""
    read -p "Continue with this commit message? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ Commit blocked - Update commit message${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Commit message follows Conventional Commits${NC}"
fi

exit 0
