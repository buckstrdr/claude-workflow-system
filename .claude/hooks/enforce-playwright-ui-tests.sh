#!/bin/bash
# Enforce Playwright UI Testing Hook
# Ensures UI changes are tested with Playwright at 1920x1080 resolution

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  UI Testing Enforcement Check${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if UI files were modified
UI_CHANGED=0
FRONTEND_CHANGED=$(git diff --cached --name-only | grep -E "topstepx_frontend/src/components/.*\.(tsx|ts|jsx|js)$" | wc -l)
STYLE_CHANGED=$(git diff --cached --name-only | grep -E "\.(css|scss)$" | wc -l)

if [ "$FRONTEND_CHANGED" -gt 0 ] || [ "$STYLE_CHANGED" -gt 0 ]; then
    UI_CHANGED=1
    echo -e "${YELLOW}⚠️  UI changes detected:${NC}"
    git diff --cached --name-only | grep -E "topstepx_frontend/src/components/.*\.(tsx|ts|jsx|js)$|\.(css|scss)$"
    echo ""
fi

if [ "$UI_CHANGED" -eq 0 ]; then
    echo -e "${GREEN}✓ No UI changes - skipping UI test check${NC}"
    exit 0
fi

# Check for Playwright MCP usage
echo -e "\n${YELLOW}Checking for Playwright usage...${NC}"

# Look for Playwright MCP tool calls in recent conversation
PLAYWRIGHT_USED=0
if grep -q "mcp__playwright__" ~/.claude/history.jsonl 2>/dev/null | tail -100; then
    PLAYWRIGHT_USED=1
fi

# Check for UI verification screenshots in session
SCREENSHOTS_EXIST=$(find .ian -name "*screenshot*" -o -name "*ui-verify*" 2>/dev/null | wc -l)
if [ "$SCREENSHOTS_EXIST" -gt 0 ]; then
    PLAYWRIGHT_USED=1
fi

if [ "$PLAYWRIGHT_USED" -eq 0 ]; then
    echo -e "${RED}✗ UI changes detected but no Playwright testing found!${NC}"
    echo ""
    echo -e "${YELLOW}Required UI Testing Standards:${NC}"
    echo "  1. Use Playwright MCP tools for UI verification"
    echo "  2. Test at 1920x1080 resolution (MANDATORY)"
    echo "  3. Take screenshots of changed components"
    echo "  4. Verify interactive elements work correctly"
    echo ""
    echo -e "${YELLOW}To test UI changes:${NC}"
    echo "  1. Use: mcp__playwright__browser_navigate(\"http://localhost:5173\")"
    echo "  2. Set viewport: {\"width\": 1920, \"height\": 1080}"
    echo "  3. Take screenshots: mcp__playwright__browser_take_screenshot()"
    echo "  4. Verify functionality: mcp__playwright__browser_click(), etc."
    echo ""
    echo -e "${YELLOW}Or use the /ui-verify skill for guided testing${NC}"
    echo ""
    read -p "Continue commit without UI tests? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ Commit blocked - Add UI tests first${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Playwright usage detected${NC}"
fi

# Check for 1920x1080 resolution enforcement
echo -e "\n${YELLOW}Checking resolution standards...${NC}"

CORRECT_RESOLUTION=0
if grep -q "1920.*1080\|width.*1920.*height.*1080" ~/.claude/history.jsonl 2>/dev/null | tail -50; then
    CORRECT_RESOLUTION=1
    echo -e "${GREEN}✓ 1920x1080 resolution detected${NC}"
else
    echo -e "${RED}⚠️  Cannot verify 1920x1080 resolution was used${NC}"
    echo "  Standard: All UI testing must use 1920x1080 viewport"
fi

# Check for screenshot artifacts
if [ "$SCREENSHOTS_EXIST" -gt 0 ]; then
    echo -e "${GREEN}✓ UI verification screenshots found:${NC}"
    find .ian -name "*screenshot*" -o -name "*ui-verify*" 2>/dev/null | head -5
else
    echo -e "${YELLOW}⚠️  No screenshot artifacts found in .ian/${NC}"
    echo "  Consider saving screenshots for visual regression testing"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  UI Testing Check Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

exit 0
