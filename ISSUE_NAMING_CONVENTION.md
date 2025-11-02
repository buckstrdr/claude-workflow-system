# GitHub Issue Naming Convention

## Overview

All GitHub issues in this repository follow a standardized naming convention for easy identification, filtering, and tracking.

---

## Naming Format

```
[PREFIX#] Title - Description
```

**Components**:
- `PREFIX`: Single letter category code (T, F, I, B, etc.)
- `#`: Sequential number within that category
- `Title`: Concise subject (2-8 words)
- `Description`: Optional clarifying phrase

**Examples**:
- `[T1] Entry Type Validation Suite - All 6 Order Types`
- `[F1] OCO AutoOcoBrackets Implementation - User API Integration`
- `[I1] Identify and Remove Legacy/Duplicate Bracket and Trailing Code`
- `[B1] Order Service Crashes on Invalid Contract ID`

---

## Category Prefixes

| Prefix | Category | Description | Label |
|--------|----------|-------------|-------|
| **Tx** | Testing | Test suites, integration tests, validation tests | `testing` |
| **Fx** | Feature | New features, enhancements, capabilities | `enhancement` |
| **Ix** | Improvement | Code quality, refactoring, technical debt | `improvement` |
| **Bx** | Bug | Bug fixes, error corrections | `bug` |
| **Dx** | Documentation | Documentation updates, guides, API docs | `documentation` |
| **Cx** | Chore | Build, CI/CD, tooling, dependencies | `chore` |
| **Px** | Performance | Performance optimizations, profiling | `performance` |
| **Sx** | Security | Security fixes, vulnerability patches | `security` |

---

## Numbering Rules

### Sequential Within Category

Each category maintains its own sequential numbering starting from 1.

**Example**:
- `[T1]` First test issue
- `[T2]` Second test issue
- `[T3]` Third test issue
- `[F1]` First feature issue (separate sequence)
- `[F2]` Second feature issue

### Finding Next Available Number

Before creating a new issue, check existing issues in that category:

```bash
# List all test issues
gh issue list --state all --json number,title | grep "\[T"

# List all feature issues
gh issue list --state all --json number,title | grep "\[F"

# List all improvement issues
gh issue list --state all --json number,title | grep "\[I"
```

Use the next available number in the sequence.

### Handling Closed Issues

**DO NOT REUSE NUMBERS** - Even if an issue is closed, do not reuse its number. Always use the next sequential number.

**Rationale**: Preserves historical context and prevents confusion in discussions/commits referencing old issue numbers.

---

## Creating Issues

### Via GitHub CLI

```bash
# Create a test issue (T5 is next available)
gh issue create \
  --title "[T5] Position Tracking Integration Tests" \
  --label "testing" \
  --body "Test suite for position tracking..."

# Create a feature issue (F3 is next available)
gh issue create \
  --title "[F3] Real-time PnL Dashboard" \
  --label "enhancement" \
  --body "Implement real-time profit/loss dashboard..."

# Create a bug issue (B1 is first)
gh issue create \
  --title "[B1] Order Service Crashes on Null Contract ID" \
  --label "bug" \
  --body "Error reproduction steps..."
```

### Via GitHub Web Interface

1. Go to **Issues** → **New Issue**
2. Choose appropriate template (if available)
3. **Title**: Enter `[PREFIX#] Title - Description`
4. **Labels**: Add corresponding label (testing, enhancement, bug, etc.)
5. **Body**: Fill in issue details
6. **Submit**

---

## Issue Templates

Issue templates in `.github/ISSUE_TEMPLATE/` should include naming convention guidance:

**Example Template Header**:
```markdown
---
name: Feature request
about: Propose a new capability or improvement
title: "[F#] <concise subject>"
labels: [enhancement]
---

**NOTE**: Replace # with next available F number (check existing F issues)
```

---

## Best Practices

### ✅ DO

- **Check existing numbers** before creating new issues
- **Use next sequential number** within category
- **Keep titles concise** (2-8 words for main title)
- **Add descriptive suffix** if needed (after dash)
- **Apply correct labels** matching prefix (T→testing, F→enhancement, etc.)
- **Reference issues** in commits and PRs using `[T1]`, `[F2]` format

### ❌ DON'T

- Don't reuse closed issue numbers
- Don't skip numbers (use sequential)
- Don't mix categories (one prefix per issue)
- Don't use vague titles like `[F1] Improvements` (be specific)
- Don't forget the brackets around prefix

---

## Examples by Category

### Testing (Tx)

```
[T1] Entry Type Validation Suite - All 6 Order Types
[T2] Exit Type Validation Suite - All 6 Exit Mechanisms
[T3] Bracket Editor Integration Tests - Fixed SL/TP Workflow
[T4] Trailing Bracket Integration Tests - Quote-Driven SL/TP
[T5] End-to-End Trading Workflow Test
```

### Features (Fx)

```
[F1] OCO AutoOcoBrackets Implementation - User API Integration
[F2] R-Multiple Bracket Support - Automatic Risk/Reward Calculation
[F3] Real-time PnL Dashboard
[F4] Strategy Backtesting Engine
[F5] Multi-Account Position Aggregation
```

### Improvements (Ix)

```
[I1] Identify and Remove Legacy/Duplicate Bracket Code
[I2] Refactor EventBus Consumer Pattern
[I3] Consolidate Duplicate TTL Cleanup Logic
[I4] Optimize Database Query Performance
[I5] Improve Error Message Clarity
```

### Bugs (Bx)

```
[B1] Order Service Crashes on Invalid Contract ID
[B2] Position Tracking Shows Incorrect Size After Partial Fill
[B3] Trailing SL Does Not Tighten on Favorable Move
[B4] Memory Leak in Quote Subscription Manager
[B5] WebSocket Reconnection Fails After Network Drop
```

### Documentation (Dx)

```
[D1] API Documentation for Bracket Editor Service
[D2] Trading System Architecture Diagram
[D3] Strategy Development Guide
[D4] Deployment Instructions for Production
[D5] Troubleshooting Guide for Common Issues
```

### Chores (Cx)

```
[C1] Update Dependencies to Latest Versions
[C2] Configure GitHub Actions CI/CD Pipeline
[C3] Add Pre-commit Hooks for Code Quality
[C4] Setup Docker Compose for Local Development
[C5] Migrate from npm to pnpm
```

### Performance (Px)

```
[P1] Optimize Quote Processing Latency
[P2] Reduce Memory Usage in Series Cache
[P3] Improve Order Submission Throughput
[P4] Database Query Optimization - Position Lookups
[P5] Minimize EventBus Message Copying
```

### Security (Sx)

```
[S1] Encrypt API Keys at Rest
[S2] Implement Rate Limiting for User API
[S3] Add Input Validation for Order Parameters
[S4] Audit Logging for Admin Actions
[S5] Fix SQL Injection Vulnerability in Reports
```

---

## Referencing Issues

### In Commit Messages

```bash
git commit -m "[T1] Add entry type validation tests for LIMIT orders"
git commit -m "[F2] Implement R-multiple bracket calculation helper"
git commit -m "[B1] Fix null pointer in order service - closes #42"
```

### In Pull Requests

```markdown
## Related Issues

- Implements [F1] OCO AutoOcoBrackets Implementation (#45)
- Fixes [B1] Order Service Crash (#52)
- Partially addresses [I1] Legacy Code Cleanup (#51)
```

### In Code Comments

```python
# TODO [F3]: Add real-time PnL calculation when dashboard is implemented
# See issue #48 for details

# FIXME [B2]: Position size incorrect after partial fill
# Tracked in issue #53
```

---

## Migration from Old Issues

### Existing Issues Without Prefix

Existing issues created before this convention can be:

1. **Renamed** to follow convention (if still open and active)
2. **Left as-is** (if closed or historical)
3. **Referenced by number** only in older commits

**Example**:
- Issue #10: `***HIGH PRIORITY***` → Can rename to `[F0] High Priority Initiatives`
- Issue #40: `Validate all entry and exit types` → Can close as superseded by `[T1]` and `[T2]`

---

## Automation

### GitHub Actions

Consider adding automation to validate issue naming:

```yaml
# .github/workflows/validate-issue-title.yml
name: Validate Issue Title
on:
  issues:
    types: [opened, edited]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Check issue title format
        run: |
          TITLE="${{ github.event.issue.title }}"
          if [[ ! "$TITLE" =~ ^\[[TFIBDCPS][0-9]+\] ]]; then
            echo "::error::Issue title must start with [PREFIX#] format"
            exit 1
          fi
```

### Issue Templates

Update `.github/ISSUE_TEMPLATE/*.md` files to include naming convention:

```markdown
---
name: Bug report
about: Report a bug or error
title: "[B#] <bug description>"
labels: [bug]
---

**Please replace # with the next available B number**
Check existing B issues: gh issue list --state all --json title | grep "\\[B"
```

---

## Quick Reference Card

| Prefix | Type | Next # | Label |
|--------|------|--------|-------|
| T | Test | Check with `gh issue list \| grep "\[T"` | testing |
| F | Feature | Check with `gh issue list \| grep "\[F"` | enhancement |
| I | Improvement | Check with `gh issue list \| grep "\[I"` | improvement |
| B | Bug | Check with `gh issue list \| grep "\[B"` | bug |
| D | Documentation | Check with `gh issue list \| grep "\[D"` | documentation |
| C | Chore | Check with `gh issue list \| grep "\[C"` | chore |
| P | Performance | Check with `gh issue list \| grep "\[P"` | performance |
| S | Security | Check with `gh issue list \| grep "\[S"` | security |

---

## FAQ

**Q: What if I'm not sure which category to use?**
A: Use the most specific category. If it's about testing, use T. If it adds functionality, use F. If it improves code quality without adding features, use I.

**Q: Can one issue have multiple prefixes?**
A: No. Choose the primary category. If an issue spans multiple types, break it into separate issues or use the most dominant category.

**Q: What if I create an issue with the wrong number?**
A: Edit the issue title immediately. GitHub allows title edits at any time.

**Q: Should I update commit messages if issue numbers change?**
A: No. Historical commit messages should remain unchanged. The mapping from old to new numbers can be documented in the issue itself.

**Q: What about sub-tasks or child issues?**
A: Use the same numbering scheme. Consider adding a suffix like `[T1a]`, `[T1b]` for sub-tasks if needed, but generally create separate issues with new numbers.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-17 | Initial naming convention established |

---

## See Also

- [Issue Templates](.github/ISSUE_TEMPLATE/)
- [Issue Closing Template](.github/ISSUE_CLOSING_TEMPLATE.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md)

---

**Questions?** Open an issue with `[D#]` prefix for documentation improvements to this guide.
