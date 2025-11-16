# UI Verify - Mandatory UI Verification with Playwright

**MANDATORY: Run this after ANY frontend changes. No exceptions.**

## What This Skill Does

Systematically verifies UI changes work correctly using Playwright automation:
1. Ensures backend and frontend servers are running
2. Navigates to UI with Playwright
3. Captures console logs (errors, warnings, info)
4. Takes full-page screenshot at 1920x1080
5. Verifies key UI elements are present
6. Checks for critical errors
7. Saves verification report to `.ian/ui_verify_{timestamp}.md`

## When to Use

**AUTOMATIC triggers** (you MUST run this):
- After modifying any file in `topstepx_frontend/src/`
- After changing React components
- After updating UI logic or state management
- After modifying styles (CSS/Tailwind)
- Before marking UI-related todos as complete
- Before committing frontend changes

**Manual usage**:
```bash
/ui-verify
```

## Complete Implementation

### Step 1: Check Servers Running

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  UI Verification - $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "→ Step 1: Checking servers..."

# Check backend
BACKEND_PID=$(pgrep -f "python.*topstepx_backend" || echo "")
if [ -z "$BACKEND_PID" ]; then
  echo "❌ Backend NOT running"
  echo ""
  echo "Starting backend..."
  nohup python -m topstepx_backend > /tmp/topstepx_backend.log 2>&1 &
  BACKEND_PID=$!
  echo "Backend PID: $BACKEND_PID"
  sleep 5
else
  echo "✓ Backend running (PID: $BACKEND_PID)"
fi

# Check backend health
HEALTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null || echo "000")
if [ "$HEALTH_CODE" != "200" ]; then
  echo "❌ Backend health check failed (HTTP $HEALTH_CODE)"
  echo "Check logs: tail -50 /tmp/topstepx_backend.log"
  exit 1
fi
echo "✓ Backend health: OK"

# Check frontend
FRONTEND_PID=$(pgrep -f "vite.*topstepx_frontend" || echo "")
if [ -z "$FRONTEND_PID" ]; then
  echo "❌ Frontend NOT running"
  echo ""
  echo "Starting frontend..."
  cd topstepx_frontend
  npm run dev > /tmp/frontend_dev.log 2>&1 &
  FRONTEND_PID=$!
  echo "Frontend PID: $FRONTEND_PID"
  cd ..
  sleep 5
else
  echo "✓ Frontend running (PID: $FRONTEND_PID)"
fi

# Check frontend responds
FRONTEND_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 2>/dev/null || echo "000")
if [ "$FRONTEND_CODE" != "200" ]; then
  echo "❌ Frontend not responding (HTTP $FRONTEND_CODE)"
  echo "Check logs: tail -50 /tmp/frontend_dev.log"
  exit 1
fi
echo "✓ Frontend responding: OK"
```

### Step 2: Navigate UI with Playwright

**CRITICAL**: Always use Playwright MCP tools, never simulate

```javascript
// Navigate to UI (MANDATORY - use Playwright MCP tool)
mcp__playwright__browser_navigate({
  url: "http://localhost:5173"
})

// Wait for page to load
// Playwright automatically waits for navigation
```

**Expected output**:
- New console messages (capture ALL)
- Page state (YAML structure)
- Page URL, title

### Step 3: Capture Console Logs

**MANDATORY**: Check console logs for errors

```javascript
// Get console messages (Playwright provides this automatically)
// Check the "New console messages" section in navigate output

// Expected console messages to IGNORE (normal in dev):
// - [DEBUG] [vite] connecting...
// - [INFO] React DevTools download message
// - [LOG] [ws.ts] Module-level state reset on page load
// - [LOG] [App] WS patterns are managed by MainChart

// CRITICAL errors to FLAG:
// - [ERROR] Failed to load resource (unless expected 404s)
// - [ERROR] TypeError/ReferenceError in application code
// - [ERROR] Unhandled promise rejections
// - [ERROR] Component render errors
```

**Console log analysis**:
```bash
# After Playwright navigation, analyze console output
# Look for:
CRITICAL_ERRORS=$(echo "$CONSOLE_OUTPUT" | grep -E "ERROR.*TypeError|ERROR.*ReferenceError|ERROR.*Uncaught|ERROR.*Component" | grep -v "Failed to load resource.*ERR_CONNECTION_REFUSED" | grep -v "500 Internal Server Error" || echo "")

if [ -n "$CRITICAL_ERRORS" ]; then
  echo "❌ CRITICAL console errors found:"
  echo "$CRITICAL_ERRORS"
  VERIFICATION_STATUS="FAILED"
else
  echo "✓ No critical console errors"
  VERIFICATION_STATUS="PASSED"
fi
```

### Step 4: Take Screenshot (MANDATORY)

**Resolution**: ALWAYS 1920x1080 (per CLAUDE.md UI standards)

```javascript
// Take full-page screenshot
mcp__playwright__browser_take_screenshot({
  filename: ".ian/ui_verify_${TIMESTAMP}.png",
  type: "png",
  fullPage: true  // Capture entire page, not just viewport
})

// Screenshot saved to: /home/buckstrdr/TopStepx/.playwright-mcp/.ian/ui_verify_{timestamp}.png
```

**IMPORTANT**: Screenshot is saved in `.playwright-mcp/.ian/` by Playwright MCP

### Step 5: Verify Key UI Elements

**MANDATORY checks** using page snapshot:

```yaml
# Key elements that MUST be present:
- Navigation header with search box
- WS, UH, MH status indicators
- Main chart area
- Sidebar with:
  - Accounts section
  - Order Entry form
  - Strategies panel
  - Risk panel
- Order tables:
  - Active Positions
  - Pending Orders
  - Previous Orders
```

**Verification script**:
```bash
# Check for key elements in page snapshot
# Playwright provides YAML structure - verify critical elements exist

echo "→ Step 5: Verifying UI elements..."

REQUIRED_ELEMENTS=(
  "textbox \"Search...\""
  "button \"Collapse Accounts\""
  "button \"Collapse Order Entry\""
  "button \"Collapse Strategies\""
  "button \"Collapse Risk\""
  "heading \".*Select a contract\""
  "button \"Buy\""
  "button \"Sell\""
)

MISSING_ELEMENTS=()
for element in "${REQUIRED_ELEMENTS[@]}"; do
  if ! echo "$PAGE_SNAPSHOT" | grep -q "$element"; then
    MISSING_ELEMENTS+=("$element")
  fi
done

if [ ${#MISSING_ELEMENTS[@]} -gt 0 ]; then
  echo "❌ Missing UI elements:"
  printf '  - %s\n' "${MISSING_ELEMENTS[@]}"
  VERIFICATION_STATUS="FAILED"
else
  echo "✓ All key UI elements present"
fi
```

### Step 6: Generate Verification Report

**Save to**: `.ian/ui_verify_{timestamp}.md`

**Report format**:
```markdown
# UI Verification Report - {TIMESTAMP}

## Summary
**Status**: {PASSED/FAILED}
**Timestamp**: {ISO_TIMESTAMP}
**Branch**: {GIT_BRANCH}
**Last Commit**: {GIT_COMMIT_HASH}

## Servers
- Backend: {STATUS} (PID: {PID})
- Frontend: {STATUS} (PID: {PID})
- Backend Health: {HTTP_CODE}
- Frontend Response: {HTTP_CODE}

## Console Logs
### Critical Errors
{LIST_OF_CRITICAL_ERRORS or "None"}

### Warnings
{LIST_OF_WARNINGS}

### Info Messages
{FIRST_10_INFO_MESSAGES}

## UI Elements
### Present
{LIST_OF_FOUND_ELEMENTS}

### Missing
{LIST_OF_MISSING_ELEMENTS or "None"}

## Screenshot
Location: `.playwright-mcp/.ian/ui_verify_{timestamp}.png`

## Page State
URL: {PAGE_URL}
Title: {PAGE_TITLE}

## Verification Result
{DETAILED_PASS/FAIL_EXPLANATION}

---
Generated by /ui-verify skill
```

### Step 7: Output Summary

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  UI Verification Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Status: $VERIFICATION_STATUS"
echo ""
echo "Report saved: .ian/ui_verify_${TIMESTAMP}.md"
echo "Screenshot: .playwright-mcp/.ian/ui_verify_${TIMESTAMP}.png"
echo ""

if [ "$VERIFICATION_STATUS" = "FAILED" ]; then
  echo "❌ UI verification FAILED"
  echo ""
  echo "Issues found:"
  [ -n "$CRITICAL_ERRORS" ] && echo "  - Critical console errors"
  [ ${#MISSING_ELEMENTS[@]} -gt 0 ] && echo "  - Missing UI elements"
  echo ""
  echo "Review report for details: .ian/ui_verify_${TIMESTAMP}.md"
  exit 1
else
  echo "✅ UI verification PASSED"
  echo ""
  echo "All checks passed:"
  echo "  ✓ Servers running"
  echo "  ✓ No critical errors"
  echo "  ✓ All key elements present"
  echo "  ✓ Screenshot captured"
  echo ""
fi
```

## Playwright MCP Tools Reference

**Available tools** (use these, NEVER simulate):

```javascript
// 1. Navigate to page
mcp__playwright__browser_navigate({
  url: "http://localhost:5173"
})

// 2. Take screenshot
mcp__playwright__browser_take_screenshot({
  filename: ".ian/screenshot.png",
  type: "png",
  fullPage: true
})

// 3. Click element
mcp__playwright__browser_click({
  element: "button Add accounts",
  ref: "e234"  // From page snapshot
})

// 4. Type text
mcp__playwright__browser_type({
  element: "textbox Search...",
  ref: "e16",
  text: "MNQ"
})

// 5. Get current snapshot (included in navigate response)
// Page snapshot is YAML structure showing all elements

// 6. Console messages (automatic)
// New console messages appear in every Playwright response
```

## Expected Console Messages (Normal in Dev)

**IGNORE these** (development environment):
```
[DEBUG] [vite] connecting...
[INFO] React DevTools download message
[LOG] [ws.ts] Module-level state reset
[LOG] [App] WS patterns are managed by MainChart
[LOG] WebSocket already connecting, skipping duplicate
```

**FLAG these** (application errors):
```
[ERROR] TypeError: Cannot read property 'x' of undefined
[ERROR] ReferenceError: foo is not defined
[ERROR] Uncaught promise rejection
[ERROR] Failed to render component: XYZ
[ERROR] Failed to load resource: {non-404-non-expected}
```

## Common Issues & Solutions

### Issue: "Backend not running"
```bash
# Start backend
nohup python -m topstepx_backend > /tmp/topstepx_backend.log 2>&1 &
sleep 5
curl http://localhost:8000/health
```

### Issue: "Frontend not running"
```bash
# Start frontend
cd topstepx_frontend
npm run dev > /tmp/frontend_dev.log 2>&1 &
cd ..
sleep 5
curl http://localhost:5173
```

### Issue: "Playwright not responding"
```bash
# Check MCP servers
make mcp-status

# Restart if needed
make mcp-restart
```

### Issue: "Screenshot not saved"
```bash
# Playwright saves to .playwright-mcp/.ian/
# Check directory exists
ls -la .playwright-mcp/.ian/

# If directory missing
mkdir -p .playwright-mcp/.ian/
```

## Integration with Quality Gates

**Gate 3 (Implementation)**: Run /ui-verify after implementing UI features
**Gate 6 (E2E Verified)**: /e2e-verify calls /ui-verify automatically

## Enforcement Rules

**MANDATORY**:
1. Run /ui-verify after ANY `topstepx_frontend/src/` changes
2. Take screenshot at 1920x1080 (full page)
3. Check console logs for critical errors
4. Verify key UI elements present
5. Save report to `.ian/`
6. NEVER simulate - always use Playwright MCP tools

**PRE-COMMIT HOOK** enforces:
- If frontend files changed → /ui-verify MUST have been run
- Verification report MUST exist in `.ian/`
- Verification status MUST be PASSED

## Example Usage

```bash
# After modifying OrderEntry component
/ui-verify

# Output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  UI Verification - 2025-10-29 15:45:30
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Step 1: Checking servers...
✓ Backend running (PID: 1847003)
✓ Backend health: OK
✓ Frontend running (PID: 1848123)
✓ Frontend responding: OK

→ Step 2: Navigating to UI...
✓ Page loaded: http://localhost:5173
✓ Title: TopstepX Frontend

→ Step 3: Checking console logs...
✓ No critical console errors

→ Step 4: Taking screenshot...
✓ Screenshot saved: .playwright-mcp/.ian/ui_verify_20251029_154530.png

→ Step 5: Verifying UI elements...
✓ All key UI elements present

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  UI Verification Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: PASSED

Report saved: .ian/ui_verify_20251029_154530.md
Screenshot: .playwright-mcp/.ian/ui_verify_20251029_154530.png

✅ UI verification PASSED

All checks passed:
  ✓ Servers running
  ✓ No critical errors
  ✓ All key elements present
  ✓ Screenshot captured
```

## Tips

- Always run after UI changes (enforced by pre-commit hook)
- Review console logs - they reveal runtime issues
- Screenshots show actual rendered UI - visual verification
- Save reports in `.ian/` for debugging later
- Use Playwright MCP tools - they're reliable and fast
- Full-page screenshots capture everything, not just viewport

## Why This Exists

**Problem**: UI changes often break functionality silently
- Console errors go unnoticed
- Visual regressions not caught
- Runtime errors only appear in browser
- Manual testing is inconsistent

**Solution**: Automated Playwright verification
- Captures console logs automatically
- Takes screenshots for visual review
- Checks UI structure programmatically
- Runs consistently every time

**Result**: Confident UI changes with proof of correctness
