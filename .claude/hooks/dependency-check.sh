#!/bin/bash
# Dependency Check Hook - Alerts on import/dependency changes

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check for new imports in Python files
NEW_IMPORTS=$(git diff --cached | grep "^+import\|^+from.*import" | sed 's/^+//' | sort -u)

if [ -n "$NEW_IMPORTS" ]; then
    echo -e "${YELLOW}📦 New imports detected:${NC}"
    echo "$NEW_IMPORTS" | sed 's/^/  /'
    echo ""
    echo -e "${YELLOW}Remember to:${NC}"
    echo "  - Add to requirements.txt if external package"
    echo "  - Update pyproject.toml if development dependency"
    echo "  - Document breaking changes in CHANGELOG"
    echo ""
fi

# Check if requirements.txt or package.json changed
if git diff --cached --name-only | grep -qE "requirements.txt|package.json"; then
    echo -e "${YELLOW}⚠️  Dependency files changed${NC}"
    echo "  Remember to install: pip install -r requirements.txt OR npm install"
    echo ""
fi

exit 0
