---
name: playwright-ui-testing-standards
description: Use when testing UI changes, modifying frontend components, or committing style changes - enforces mandatory Playwright testing at 1920x1080 resolution with interaction verification and artifact management in .ian/ directory per CLAUDE.md standards
---

# Playwright UI Testing Standards

## Overview

All UI changes MUST be tested with Playwright before committing. **Manual browser testing is NOT acceptable.** Testing standards are enforced by pre-commit hook at `.claude/hooks/enforce-playwright-ui-tests.sh`.

**CRITICAL:** Resolution MUST be 1920x1080 per CLAUDE.md:13-18. Testing at other resolutions fails to meet project standards.

**WARNING:** Pre-commit hook WILL BLOCK your commit if these standards are not met. The hook checks:
- Playwright test execution in session
- 1920x1080 resolution verification
- Screenshot artifacts in `.ian/` directory

## Mandatory Workflow Checklist

**Use TodoWrite to create todos for EACH step before starting. COMPLETE ALL STEPS IN ORDER. NO EXCEPTIONS.**

☐ Step 1: Start Frontend (npm run dev)
☐ Step 2: Create/Run Playwright test script
☐ Step 3: Set 1920x1080 resolution (MANDATORY)
☐ Step 4: Take screenshots (save to .ian/)
☐ Step 5: Test interactions (NOT just screenshots)
☐ Step 6: Verify data flow
☐ Step 7: Save all artifacts

## Mandatory Workflow (Detailed)

### Step 1: Start Frontend
```bash
cd topstepx_frontend && npm run dev
# Wait for: "Local: http://localhost:5173"
```

### Step 2: Create Playwright Test Script
```typescript
// tests/ui/verify-component.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Component UI Verification', () => {
  test.use({ viewport: { width: 1920, height: 1080 } }); // MANDATORY

  test('verify StrategyCard styling', async ({ page }) => {
    await page.goto('http://localhost:5173');

    // Take baseline screenshot
    await page.screenshot({
      path: '.ian/ui-verify-strategycard-baseline.png',
      fullPage: true
    });

    // Test interactions (examples below)
  });
});
```

### Step 3: Set MANDATORY Resolution
```typescript
// In test file
test.use({ viewport: { width: 1920, height: 1080 } });
```

**Why this resolution:**
- Project standard per CLAUDE.md
- Most common desktop resolution worldwide
- Enforced by pre-commit hook
- Visual regression baseline uses this resolution

### Step 4: Take Screenshots
```typescript
// Save to .ian/ with descriptive names
await page.screenshot({
  path: '.ian/ui-verify-{component}-{feature}.png',
  fullPage: true
});
```

**Naming convention:**
- Format: `ui-verify-{component}-{feature}.png`
- Examples: `ui-verify-strategycard-colors.png`, `ui-verify-dashboard-export-button.png`
- Always save to `.ian/` directory

### Step 5: Test Interactions
```typescript
// Click elements
await page.click('button[data-testid="export-strategy"]');

// Fill forms
await page.fill('input[name="strategy_name"]', 'Test Strategy');

// Verify state changes
await expect(page.locator('.success-message')).toBeVisible();

// Take screenshot after interaction
await page.screenshot({ path: '.ian/ui-verify-after-click.png' });
```

### Step 6: Verify Data Flow
- Check if data displays correctly
- Verify form submissions work
- Test error states
- Confirm success messages appear

### Step 7: Save All Artifacts
- Screenshots in `.ian/`
- Note any issues found
- Document what was tested

## What Qualifies as UI Change

**MUST test if you modified:**
- `topstepx_frontend/src/components/**/*.tsx`
- Any `.css` or `.scss` files
- Component props that affect display
- Styling utilities or theme files

**The pre-commit hook checks for these changes and enforces testing.**

## Interaction Testing Requirements

**Screenshots alone are NEVER sufficient.** You must:

| Change Type | Required Testing |
|-------------|------------------|
| New button | Click it, verify action |
| Form field | Type in it, submit, verify |
| Data display | Verify data loads, updates |
| Modal/dialog | Open, interact, close |
| Navigation | Click links, verify routing |
| Interactive chart | Hover, click, verify tooltips |

**Rule:** If user can interact with it, you must test that interaction.

## Pressure Accommodation = Violation

**CRITICAL:** Standards are NOT negotiable. They don't change for deadlines, exhaustion, or convenience.

| Excuse | Response |
|--------|----------|
| "Tight deadline" | Standards don't change. Testing prevents production bugs that take longer to fix. |
| "I'm exhausted" | Take a break, then test. Exhausted commits create more work later. Code ships forever. |
| "I tested manually" | Manual testing is not reproducible. Use Playwright tests. Hook will block commit. |
| "Just screenshots" | Screenshots don't test functionality. Interactions are MANDATORY per workflow. |
| "My laptop is 1366x768" | Use Playwright viewport configuration to set 1920x1080. Your screen size is irrelevant. |
| "I'll add tests tomorrow" | No. Test before committing. Tomorrow never comes. Hook blocks commit TODAY. |
| "It's just CSS" | Visual changes need visual verification. No "just CSS" exception exists. |
| "Small change" | If worth committing, worth testing. Size doesn't matter. |

**All of these mean: STOP. Follow the mandatory workflow. The pre-commit hook will enforce this.**

## What Happens If You Skip Steps

**Attempt to commit without testing:**
```bash
$ git commit -m "style: update colors"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  UI Testing Enforcement Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  UI changes detected:
  topstepx_frontend/src/components/StrategyCard.tsx

✗ UI changes detected but no Playwright testing found!

Required UI Testing Standards:
  1. Use Playwright MCP tools for UI verification
  2. Test at 1920x1080 resolution (MANDATORY)
  3. Take screenshots of changed components
  4. Verify interactive elements work correctly

❌ Commit blocked - Add UI tests first
```

**The hook gives you ONE choice:** Add proper testing or force override (not recommended).

**Force override creates technical debt and violates project standards.**

## Pre-Commit Hook Integration

The hook at `.claude/hooks/enforce-playwright-ui-tests.sh` checks:

1. ✅ Playwright MCP tool usage in session
2. ✅ 1920x1080 resolution verification
3. ✅ Screenshot artifacts in `.ian/`

**If checks fail:**
- Commit will be blocked (or require override)
- You'll see error message with guidance
- Hook will prompt for confirmation

**Don't fight the hook.** It enforces these standards for a reason.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Testing at wrong resolution | Use test.use({ viewport: { width: 1920, height: 1080 } }) |
| Using browser DevTools | Write Playwright test scripts instead |
| Only taking screenshots | Test interactions too |
| Saving screenshots elsewhere | Always use .ian/ directory |
| Manual clicking in browser | Use await page.click() in test script |
| Skipping frontend startup | Must run npm run dev first |
| "Visually looks good" | Not enough - test functionality |
| Deferring testing | Test before commit, not after |

## Rationalization Counters

| Rationalization | Reality |
|-----------------|---------|
| "Manual testing is faster" | Automated testing is reproducible. Manual is not. |
| "My screen size is different" | Playwright sets viewport programmatically. Screen irrelevant. |
| "Just a small CSS change" | Visual changes need visual verification. No exceptions. |
| "Hook will let me override" | Override is for emergencies only. Not for skipping standards. |
| "Testing is overkill for this" | If it's worth committing, it's worth testing. |
| "I'll test in production" | Production is not a testing environment. |

## Red Flags - STOP and Follow Workflow

If you're doing ANY of these, STOP and start over with Step 1:

- Suggesting browser DevTools instead of Playwright tests
- Accepting non-1920x1080 resolution
- Allowing screenshots without interaction testing
- Compromising standards due to deadlines/exhaustion
- Suggesting "test after commit"
- Not mentioning .ian/ directory
- Skipping frontend startup
- Accepting manual testing

**All of these mean: Restart from Step 1 of mandatory workflow.**

## Quick Reference: Required Playwright Commands

| Task | Playwright Code | Example |
|------|-----------------|---------|
| Set viewport | `test.use({ viewport: {...} })` | test.use({ viewport: { width: 1920, height: 1080 } }) |
| Navigate | `await page.goto()` | await page.goto('http://localhost:5173') |
| Screenshot | `await page.screenshot()` | await page.screenshot({ path: '.ian/ui-verify-component.png' }) |
| Click | `await page.click()` | await page.click('button[data-testid="export"]') |
| Type | `await page.fill()` | await page.fill('input#name', 'Test Strategy') |
| Verify | `await expect()` | await expect(page.locator('.message')).toBeVisible() |

## Real-World Impact

**Before this skill:**
- Agents suggest manual browser testing
- Standards negotiable under pressure
- No artifact management
- Wrong resolutions accepted
- Screenshots without interaction testing
- Pre-commit hook violations

**After this skill:**
- Playwright test scripts mandatory
- 1920x1080 enforced
- Structured workflow followed
- Artifacts in .ian/
- Interaction testing required
- Pre-commit hook compliance
