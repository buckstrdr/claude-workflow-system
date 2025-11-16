#!/bin/bash
# Python Code Quality Hook
# Runs black, flake8, pylint, vulture on changed Python files before commit

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Python Code Quality Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get changed Python files
PYTHON_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.py$" | grep -v "migrations/" | grep -v "__pycache__")

if [ -z "$PYTHON_FILES" ]; then
    echo -e "${GREEN}✓ No Python files changed - skipping quality checks${NC}"
    exit 0
fi

echo -e "${YELLOW}Changed Python files:${NC}"
echo "$PYTHON_FILES" | sed 's/^/  /'
echo ""

FAILED=0

# Check if tools are installed
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${YELLOW}⚠️  $1 not installed - skipping${NC}"
        return 1
    fi
    return 0
}

# ============================================================
# 1. BLACK - Code Formatter
# ============================================================
if check_tool black; then
    echo -e "${BLUE}[1/4] Running Black (code formatter)...${NC}"

    # Run black in check mode (don't modify files)
    BLACK_OUTPUT=$(echo "$PYTHON_FILES" | xargs black --check --line-length 100 2>&1)
    BLACK_EXIT=$?

    if [ $BLACK_EXIT -ne 0 ]; then
        echo -e "${RED}✗ Black formatting issues found:${NC}"
        echo "$BLACK_OUTPUT" | grep -E "would reformat|reformatted" | sed 's/^/  /'
        echo ""
        echo -e "${YELLOW}To fix: black --line-length 100 topstepx_backend/${NC}"
        FAILED=1
    else
        echo -e "${GREEN}✓ Black: All files formatted correctly${NC}"
    fi
else
    echo -e "${YELLOW}Install: pip install black${NC}"
fi
echo ""

# ============================================================
# 2. FLAKE8 - Style Guide Enforcement
# ============================================================
if check_tool flake8; then
    echo -e "${BLUE}[2/4] Running Flake8 (style guide)...${NC}"

    FLAKE8_OUTPUT=$(echo "$PYTHON_FILES" | xargs flake8 --max-line-length=100 --extend-ignore=E203,W503 2>&1)
    FLAKE8_EXIT=$?

    if [ $FLAKE8_EXIT -ne 0 ]; then
        echo -e "${RED}✗ Flake8 issues found:${NC}"
        echo "$FLAKE8_OUTPUT" | head -20 | sed 's/^/  /'

        ERROR_COUNT=$(echo "$FLAKE8_OUTPUT" | wc -l)
        if [ "$ERROR_COUNT" -gt 20 ]; then
            echo -e "${YELLOW}  ... and $((ERROR_COUNT - 20)) more issues${NC}"
        fi

        FAILED=1
    else
        echo -e "${GREEN}✓ Flake8: No style issues${NC}"
    fi
else
    echo -e "${YELLOW}Install: pip install flake8${NC}"
fi
echo ""

# ============================================================
# 3. PYLINT - Code Analysis
# ============================================================
if check_tool pylint; then
    echo -e "${BLUE}[3/4] Running Pylint (code analysis)...${NC}"

    # Run pylint with reasonable config
    PYLINT_OUTPUT=$(echo "$PYTHON_FILES" | xargs pylint \
        --disable=C0111,C0103,R0903,R0913,W0212,C0301 \
        --max-line-length=100 \
        --good-names=i,j,k,x,y,z,_,id,df,f \
        --score=n 2>&1)
    PYLINT_EXIT=$?

    # Pylint exits 0 only if score is 10/10, so check for actual errors
    ERROR_LINES=$(echo "$PYLINT_OUTPUT" | grep -E "^[^:]+:[0-9]+:[0-9]+: [EF]")

    if [ -n "$ERROR_LINES" ]; then
        echo -e "${RED}✗ Pylint errors found:${NC}"
        echo "$ERROR_LINES" | head -15 | sed 's/^/  /'

        ERROR_COUNT=$(echo "$ERROR_LINES" | wc -l)
        if [ "$ERROR_COUNT" -gt 15 ]; then
            echo -e "${YELLOW}  ... and $((ERROR_COUNT - 15)) more errors${NC}"
        fi

        FAILED=1
    else
        WARNING_LINES=$(echo "$PYLINT_OUTPUT" | grep -E "^[^:]+:[0-9]+:[0-9]+: [WRC]")
        WARNING_COUNT=$(echo "$WARNING_LINES" | wc -l)

        if [ -n "$WARNING_LINES" ]; then
            echo -e "${YELLOW}⚠️  Pylint: $WARNING_COUNT warnings (non-blocking)${NC}"
        else
            echo -e "${GREEN}✓ Pylint: No errors${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Install: pip install pylint${NC}"
fi
echo ""

# ============================================================
# 4. VULTURE - Dead Code Detection
# ============================================================
if check_tool vulture; then
    echo -e "${BLUE}[4/4] Running Vulture (dead code detection)...${NC}"

    VULTURE_OUTPUT=$(echo "$PYTHON_FILES" | xargs vulture --min-confidence 80 2>&1)
    VULTURE_EXIT=$?

    if [ $VULTURE_EXIT -ne 0 ] && [ -n "$VULTURE_OUTPUT" ]; then
        DEAD_CODE_COUNT=$(echo "$VULTURE_OUTPUT" | grep -c "unused")

        if [ "$DEAD_CODE_COUNT" -gt 0 ]; then
            echo -e "${YELLOW}⚠️  Vulture: Found $DEAD_CODE_COUNT potential dead code items${NC}"
            echo "$VULTURE_OUTPUT" | head -10 | sed 's/^/  /'

            if [ "$DEAD_CODE_COUNT" -gt 10 ]; then
                echo -e "${YELLOW}  ... and $((DEAD_CODE_COUNT - 10)) more items${NC}"
            fi

            echo -e "${YELLOW}  (Non-blocking - review manually)${NC}"
        fi
    else
        echo -e "${GREEN}✓ Vulture: No dead code detected${NC}"
    fi
else
    echo -e "${YELLOW}Install: pip install vulture${NC}"
fi
echo ""

# ============================================================
# Summary
# ============================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -eq 1 ]; then
    echo -e "${RED}✗ Code quality checks FAILED${NC}"
    echo ""
    echo -e "${YELLOW}Quick fixes:${NC}"
    echo "  1. Format code:  black --line-length 100 topstepx_backend/"
    echo "  2. Check issues: flake8 --max-line-length=100 <file>"
    echo "  3. Fix errors:   pylint <file>"
    echo ""
    read -p "Commit anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ Commit blocked - Fix quality issues first${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ All quality checks passed!${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
exit 0
