#!/bin/bash
# Test Runner Hook - Runs tests on changed Python modules

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get changed Python files in backend
CHANGED_FILES=$(git diff --cached --name-only | grep "^topstepx_backend/.*\.py$" | grep -v "__pycache__" | grep -v "migrations/")

if [ -z "$CHANGED_FILES" ]; then
    exit 0
fi

echo -e "${YELLOW}🧪 Running tests for changed modules...${NC}"

# Check if pytest is available
if ! command -v pytest &> /dev/null; then
    echo -e "${YELLOW}⚠️  pytest not installed - skipping tests${NC}"
    exit 0
fi

# Run tests for changed modules
FAILED=0
for file in $CHANGED_FILES; do
    # Convert file path to test path
    TEST_FILE="${file//topstepx_backend/topstepx_backend\/tests}"
    TEST_FILE="${TEST_FILE//.py/_test.py}"

    if [ -f "$TEST_FILE" ]; then
        echo -e "  Testing: $TEST_FILE"
        if ! pytest "$TEST_FILE" -v --tb=short 2>&1 | tail -5; then
            FAILED=1
        fi
    fi
done

if [ $FAILED -eq 1 ]; then
    echo -e "${RED}✗ Some tests failed${NC}"
    read -p "Commit anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓ All tests passed${NC}"
fi

exit 0
