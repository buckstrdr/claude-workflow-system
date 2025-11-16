# UI Testing Checklist (Playwright Enforcement)

This hook enforces proper UI testing standards for all frontend changes.

## What It Checks

1. **UI Changes Detection**
   - Monitors `topstepx_frontend/src/components/**/*.tsx`
   - Monitors style files (`.css`, `.scss`)

2. **Playwright Usage Verification**
   - Checks for `mcp__playwright__*` tool calls in session
   - Looks for UI verification screenshots in `.ian/`
   - Validates testing was performed

3. **Resolution Standards**
   - Enforces 1920x1080 viewport (per CLAUDE.md:13-18)
   - Checks viewport configuration in Playwright calls

4. **Screenshot Artifacts**
   - Verifies screenshots were taken
   - Encourages visual regression testing

## Required Testing Flow

When you modify UI components, you MUST:

### 1. Start Frontend
```bash
cd topstepx_frontend && npm run dev
# Frontend runs on http://localhost:5173
```

### 2. Use Playwright MCP
```python
# Navigate to frontend
mcp__playwright__browser_navigate("http://localhost:5173")

# Set MANDATORY 1920x1080 resolution
mcp__playwright__browser_resize(width=1920, height=1080)

# Take screenshot of changed component
mcp__playwright__browser_take_screenshot(
    filename=".ian/ui-verify-component-name.png"
)
```

### 3. Test Interactions
```python
# Click elements
mcp__playwright__browser_click(
    element="Submit Button",
    ref="button[type='submit']"
)

# Fill forms
mcp__playwright__browser_type(
    element="Strategy Name Input",
    ref="input[name='strategy_name']",
    text="Test Strategy"
)

# Verify results
mcp__playwright__browser_snapshot()
```

### 4. Save Screenshots
- Store in `.ian/` directory
- Name descriptively: `ui-verify-{component}-{feature}.png`
- Include in session notes

## Integration with Git Hooks

Add to `.git/hooks/pre-commit`:
```bash
# Run UI testing enforcement
.claude/hooks/enforce-playwright-ui-tests.sh || exit 1
```

Or use existing `verify-ui-changes` hook that's already installed.

## Quick UI Testing with /ui-verify Skill

Use the `/ui-verify` skill for guided UI testing:
```
/ui-verify
```

This will:
1. Start frontend if not running
2. Open Playwright browser
3. Navigate to localhost:5173
4. Set 1920x1080 viewport
5. Guide you through testing changed components
6. Save screenshots automatically

## Standards Enforcement

**BLOCKING (commit will fail):**
- UI changes without any Playwright usage

**WARNING (commit continues with warning):**
- Missing 1920x1080 resolution verification
- No screenshot artifacts

## Override

If you absolutely must commit UI changes without tests:
- Hook will prompt for confirmation
- Type `y` to override (not recommended)
- Add TODO comment in code to add tests later

## Best Practices

1. **Test every visible change** - If users see it, test it
2. **Use actual viewport size** - 1920x1080 is our standard
3. **Save screenshots** - Visual regression baseline
4. **Test interactions** - Don't just screenshot, interact
5. **Verify data flow** - Check if data displays correctly
