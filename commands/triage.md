# Triage - GitHub Issue Triage

Automated GitHub issue triage workflow for TopStepX issues.

## What This Skill Does

- Fetch GitHub issue details
- Search codebase for relevant code
- Generate reproduction steps
- Suggest labels and severity
- Create triage comment

## How to Use

```
/triage <issue_number>   # Triage specific issue
/triage 123              # Triage issue #123
```

## Triage Workflow

### 1. Fetch Issue
```bash
# Get issue details
gh issue view 123 --json title,body,labels

# Or from URL
# User provides: https://github.com/ChillTrader/TopStepx/issues/123
```

### 2. Analyze Issue
- What is the reported problem?
- Which component (backend/frontend/strategy)?
- Severity (critical/high/medium/low)?
- Can it be reproduced?

### 3. Search Codebase
```bash
# Find relevant code
/find "error message from issue"
/find "affected component"

# Check recent changes
git log --oneline --grep="related keyword" -10
```

### 4. Generate Triage Comment

```markdown
## Triage Report

**Component**: Backend (Order Service)
**Severity**: High
**Type**: Bug

### Analysis

The issue describes orders being rejected with "invalid quantity" error despite valid input.

Relevant code: `topstepx_backend/services/order_service.py:67`

### Reproduction Steps

1. Start backend: `make backend-start`
2. Submit order: `curl -X POST http://localhost:8000/api/orders/submit -d '{"symbol": "MNQ", "quantity": 1, "order_type": "market"}'`
3. Observe: Error "invalid quantity"

### Root Cause

Validation logic in `order_service.py:67` checks `quantity > 0` but receives quantity as string from API, fails type check.

### Suggested Fix

Convert quantity to int before validation:
```python
quantity = int(order.quantity)
if quantity <= 0:
    raise ValueError("Invalid quantity")
```

### Recommended Labels

- `bug`
- `backend`
- `severity:high`
- `area:order-service`

### Branch Suggestion

`issue/123-fix-order-quantity-validation`

### Estimated Effort

- Fix: 15 minutes
- Test: 15 minutes
- Total: 30 minutes
```

### 5. Post Comment
```bash
gh issue comment 123 --body "$(cat triage_comment.md)"
```

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Issue Triage #123
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Title: Orders rejected with "invalid quantity"
Reporter: user123
Created: 2025-10-28

Component: Backend (Order Service)
Severity: HIGH
Type: Bug

Root Cause:
  Type mismatch in quantity validation
  Location: topstepx_backend/services/order_service.py:67

Reproduction:
  1. Submit order via API
  2. Quantity received as string
  3. Validation fails with type error

Suggested Labels:
  - bug
  - backend
  - severity:high
  - area:order-service

Branch: issue/123-fix-order-quantity-validation
Effort: 30 minutes

Triage comment posted to issue #123
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Tips

- Use `/find` to locate relevant code quickly
- Check git history for related changes
- Test reproduction steps before posting
- Be specific about root cause
- Provide actionable fix suggestions
- Label appropriately for filtering
