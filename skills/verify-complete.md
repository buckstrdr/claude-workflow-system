# Verify-Complete - Completeness Verification System

Comprehensive automated verification that work is truly complete before marking done.

## What This Skill Does

Runs exhaustive checklist across 7 dimensions:
1. Code Quality
2. Tests
3. Documentation
4. Integration
5. Verification
6. Git
7. Production Readiness

Blocks marking work "complete" until ALL checks pass.

## When to Use

**MANDATORY before:**
- Marking todo as completed
- Closing GitHub issue
- Marking PR as "ready for review"
- Claiming feature is "done"

**DO NOT skip** - This is a quality gate, not optional.

## Implementation

### Check 1: Code Quality

```bash
# No TODOs in production code
TODOS=$(grep -r "TODO\|FIXME\|XXX\|HACK" your_backend/ your_frontend/ --exclude-dir="tests" --exclude-dir="__pycache__" --exclude-dir="node_modules" 2>/dev/null || true)

if [ -n "$TODOS" ]; then
  echo "❌ Code Quality: TODO/FIXME found in production code"
  echo "$TODOS"
  EXIT_CODE=1
else
  echo "✓ Code Quality: No TODOs in production code"
fi

# No commented-out code
COMMENTED=$(grep -rE "^[[:space:]]*#[[:space:]]*(def |class |import |from )" your_backend/ --exclude-dir="tests" --exclude-dir="__pycache__" 2>/dev/null || true)

if [ -n "$COMMENTED" ]; then
  echo "⚠️  Code Quality: Commented-out code detected"
  echo "$COMMENTED"
fi

# No debug statements
DEBUG=$(grep -rE "(console\.log|print\(|debugger|pdb\.set_trace)" your_backend/ your_frontend/src/ --exclude-dir="tests" --exclude-dir="__pycache__" --exclude-dir="node_modules" 2>/dev/null || true)

if [ -n "$DEBUG" ]; then
  echo "❌ Code Quality: Debug statements found"
  echo "$DEBUG"
  EXIT_CODE=1
else
  echo "✓ Code Quality: No debug statements"
fi

# Check for proper error handling (heuristic)
# Look for try/except or error handling patterns
ERROR_HANDLING=$(git diff HEAD~1 --name-only | grep "\.py$" | xargs grep -l "raise\|except" 2>/dev/null || true)

if [ -z "$ERROR_HANDLING" ]; then
  echo "⚠️  Code Quality: No error handling detected in changed files"
  echo "  Consider adding try/except or proper error handling"
fi
```

### Check 2: Tests

```bash
# Tests exist for changed code
CHANGED_PY=$(git diff HEAD~1 --name-only | grep "your_backend/.*\.py$" | grep -v "tests/" | grep -v "__pycache__" || true)
CHANGED_JS=$(git diff HEAD~1 --name-only | grep "your_frontend/src/.*\.(tsx?|jsx?)$" | grep -v "\.test\." | grep -v "\.spec\." || true)

if [ -n "$CHANGED_PY" ]; then
  for file in $CHANGED_PY; do
    # Convert path to test path
    TEST_FILE=$(echo "$file" | sed 's|your_backend/|your_backend/tests/test_|')
    if [ ! -f "$TEST_FILE" ]; then
      echo "⚠️  Tests: No test file for $file"
      echo "  Expected: $TEST_FILE"
    fi
  done
fi

# Run tests
echo "→ Running backend tests..."
if python -m pytest your_backend/tests/ -v 2>/dev/null; then
  echo "✓ Tests: Backend tests passing"
else
  echo "❌ Tests: Backend tests FAILING"
  EXIT_CODE=1
fi

# Check test coverage on changed files
COVERAGE=$(python -m pytest your_backend/tests/ --cov=your_backend --cov-report=term-missing 2>/dev/null | tail -20)
echo "$COVERAGE"

# Extract coverage percentage for changed files
COV_PERCENT=$(echo "$COVERAGE" | grep "TOTAL" | awk '{print $4}' | sed 's/%//')
if [ -n "$COV_PERCENT" ] && [ "$COV_PERCENT" -lt 80 ]; then
  echo "⚠️  Tests: Coverage ${COV_PERCENT}% below 80% target"
else
  echo "✓ Tests: Coverage ${COV_PERCENT}% meets target"
fi

# Check for edge case tests
EDGE_TESTS=$(grep -r "edge\|boundary\|limit" your_backend/tests/ || true)
if [ -z "$EDGE_TESTS" ]; then
  echo "⚠️  Tests: No edge case tests detected"
fi

# Check for error case tests
ERROR_TESTS=$(grep -r "error\|exception\|invalid" your_backend/tests/ || true)
if [ -z "$ERROR_TESTS" ]; then
  echo "⚠️  Tests: No error case tests detected"
fi
```

### Check 3: Documentation

```bash
# Function/class docstrings
CHANGED_PY=$(git diff HEAD~1 --name-only | grep "your_backend/.*\.py$" | grep -v "tests/" || true)

for file in $CHANGED_PY; do
  # Check for docstrings
  FUNCS_WITHOUT_DOCS=$(python3 -c "
import ast
try:
    with open('$file') as f:
        tree = ast.parse(f.read())
    missing = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.ClassDef)):
            if not ast.get_docstring(node):
                missing.append(f'{node.name} at line {node.lineno}')
    if missing:
        print('\n'.join(missing))
except: pass
" 2>/dev/null || true)

  if [ -n "$FUNCS_WITHOUT_DOCS" ]; then
    echo "⚠️  Documentation: Missing docstrings in $file:"
    echo "$FUNCS_WITHOUT_DOCS"
  fi
done

# README updated if API changed
if git diff HEAD~1 --name-only | grep -q "your_backend/api/"; then
  README_UPDATED=$(git diff HEAD~1 --name-only | grep -q "README\|CHANGELOG" && echo "yes" || echo "no")
  if [ "$README_UPDATED" = "no" ]; then
    echo "⚠️  Documentation: API changed but README/CHANGELOG not updated"
  else
    echo "✓ Documentation: README/CHANGELOG updated with API changes"
  fi
fi

# Check for .ian/ investigation doc (if bug fix)
COMMIT_MSG=$(git log -1 --pretty=%B)
if echo "$COMMIT_MSG" | grep -qi "fix:"; then
  ISSUE_NUM=$(echo "$COMMIT_MSG" | grep -oE "#[0-9]+" | head -1 | sed 's/#//')
  if [ -n "$ISSUE_NUM" ]; then
    if [ ! -f ".ian/issue_${ISSUE_NUM}_resolution.md" ]; then
      echo "⚠️  Documentation: Bug fix but no .ian/issue_${ISSUE_NUM}_resolution.md"
    else
      echo "✓ Documentation: Resolution doc exists"
    fi
  fi
fi
```

### Check 4: Integration

```bash
# Backend starts successfully
echo "→ Checking backend can start..."
if timeout 10 python -m your_backend --help >/dev/null 2>&1; then
  echo "✓ Integration: Backend imports successfully"
else
  echo "❌ Integration: Backend CANNOT import"
  EXIT_CODE=1
fi

# Frontend builds
echo "→ Checking frontend build..."
cd your_frontend
if npm run build >/dev/null 2>&1; then
  echo "✓ Integration: Frontend builds successfully"
else
  echo "❌ Integration: Frontend build FAILS"
  EXIT_CODE=1
fi
cd ..

# OpenAPI spec updated (if backend API changed)
if git diff HEAD~1 --name-only | grep -q "your_backend/api/"; then
  OPENAPI_UPDATED=$(git diff HEAD~1 --name-only | grep -q ".serena/knowledge/openapi.json" && echo "yes" || echo "no")
  if [ "$OPENAPI_UPDATED" = "no" ]; then
    echo "⚠️  Integration: API changed but OpenAPI spec not regenerated"
    echo "  Run: make openapi"
    EXIT_CODE=1
  else
    echo "✓ Integration: OpenAPI spec updated"
  fi
fi

# FE types synced (if OpenAPI changed)
if git diff HEAD~1 --name-only | grep -q ".serena/knowledge/openapi.json"; then
  TYPES_UPDATED=$(git diff HEAD~1 --name-only | grep -q "your_frontend/src/types/api.d.ts" && echo "yes" || echo "no")
  if [ "$TYPES_UPDATED" = "no" ]; then
    echo "⚠️  Integration: OpenAPI changed but FE types not regenerated"
    echo "  Run: make types"
    EXIT_CODE=1
  else
    echo "✓ Integration: FE types synced"
  fi
fi
```

### Check 5: Verification (Manual)

```bash
# Manual verification checklist
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Manual Verification Checklist"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Have you manually verified:"
echo "  [ ] Feature works as expected in UI"
echo "  [ ] All edge cases handled correctly"
echo "  [ ] Error messages are user-friendly"
echo "  [ ] No console errors in browser"
echo "  [ ] Data persists correctly"
echo "  [ ] No regressions (existing features still work)"
echo ""
read -p "All manual checks passed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Verification: Manual checks not complete"
  EXIT_CODE=1
else
  echo "✓ Verification: Manual checks passed"
fi
```

### Check 6: Git

```bash
# Clean commit history (no WIP commits)
WIP_COMMITS=$(git log origin/main..HEAD --oneline | grep -i "wip\|tmp\|test\|debug" || true)
if [ -n "$WIP_COMMITS" ]; then
  echo "⚠️  Git: WIP commits detected in history:"
  echo "$WIP_COMMITS"
  echo "  Consider squashing before push"
fi

# Conventional commit messages
NON_CONVENTIONAL=$(git log origin/main..HEAD --oneline | grep -vE "^[a-f0-9]+ (feat|fix|docs|style|refactor|test|chore|perf)(\(.*\))?:" || true)
if [ -n "$NON_CONVENTIONAL" ]; then
  echo "⚠️  Git: Non-conventional commit messages:"
  echo "$NON_CONVENTIONAL"
fi

# PR description complete (if PR exists)
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  PR_EXISTS=$(gh pr list --head "$CURRENT_BRANCH" 2>/dev/null | wc -l)
  if [ "$PR_EXISTS" -gt 0 ]; then
    PR_BODY=$(gh pr view "$CURRENT_BRANCH" --json body -q .body 2>/dev/null || true)
    if [ -z "$PR_BODY" ] || [ "$PR_BODY" = "null" ]; then
      echo "⚠️  Git: PR exists but description is empty"
      EXIT_CODE=1
    else
      echo "✓ Git: PR description complete"
    fi
  fi
fi
```

### Check 7: Production Readiness

```bash
# No sensitive data
SECRETS=$(grep -rE "(password|secret|token|api_key|private_key)" your_backend/ your_frontend/src/ --exclude-dir="tests" --exclude-dir="__pycache__" --exclude-dir="node_modules" | grep -v "\.env\." || true)
if [ -n "$SECRETS" ]; then
  echo "❌ Production: Possible secrets in code:"
  echo "$SECRETS"
  EXIT_CODE=1
fi

# Environment-specific config
if git diff HEAD~1 --name-only | grep -qE "config|settings"; then
  echo "⚠️  Production: Config files changed - verify environment handling"
fi

# Database migrations (if applicable)
if git diff HEAD~1 --name-only | grep -q "models\.py"; then
  echo "⚠️  Production: Models changed - create database migration?"
fi

# Feature flags (if applicable)
FEATURE_FLAGS=$(grep -r "feature_flag\|FEATURE_" your_backend/ || true)
if [ -n "$FEATURE_FLAGS" ]; then
  echo "✓ Production: Feature flags detected - verify configuration"
fi
```

## Final Report

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Completeness Verification Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "✅ COMPLETE - All checks passed"
  echo ""
  echo "Work is verified complete and ready to:"
  echo "  - Mark todo as completed"
  echo "  - Close GitHub issue"
  echo "  - Mark PR as ready for review"
  echo ""
else
  echo "❌ INCOMPLETE - Issues found"
  echo ""
  echo "Address the issues above before marking complete."
  echo "Re-run /verify-complete after fixes."
  echo ""
  exit 1
fi
```

## Integration with Quality Gates

**Gate 6: Verified**
- All /verify-complete checks pass
- Manual verification checklist complete
- No blocking issues

**Without passing verification, cannot proceed to Gate 7 (Review)**

## Usage Examples

### Before Marking Todo Complete

```bash
# You think you're done with a feature
User: "Order idempotency is done"

# Run verification
/verify-complete

# If passes:
✅ COMPLETE - All checks passed
# → Mark todo completed
# → Close issue

# If fails:
❌ INCOMPLETE - Issues found
  - Code Quality: Debug statements found
  - Tests: Coverage 65% below 80% target
  - Documentation: Missing docstrings
# → Fix issues
# → Re-run /verify-complete
```

### Before Closing Issue

```bash
# Ready to close issue
/verify-complete

# Verify all checks pass
# Then close issue:
gh issue close 42 --comment "$(cat .ian/issue_42_resolution.md)"
```

### Before PR Review

```bash
# Ready for code review
/verify-complete

# If passes, mark PR ready:
gh pr ready

# Request review:
gh pr edit --add-reviewer username
```

## Automation

Can be run automatically by hooks:
- `pre-mark-complete` hook (before todos marked done)
- `pre-close-issue` hook (before issues closed)
- `pre-pr-ready` hook (before marking PR ready)

## Benefits

1. **Catches incomplete work early** - Before claiming "done"
2. **Consistent quality bar** - Same checks every time
3. **Reduces rework** - Find issues before code review
4. **Enforces best practices** - Documentation, tests, clean code
5. **Production-ready** - Verifies deployment readiness

## Common Failures

**Code Quality Issues**:
```
❌ Code Quality: TODO found at line 42
→ Fix: Remove TODO or create issue for it
```

**Test Failures**:
```
❌ Tests: Backend tests FAILING
→ Fix: Make all tests pass before marking complete
```

**Missing Documentation**:
```
⚠️  Documentation: Missing docstrings in order_service.py
→ Fix: Add docstrings to public functions/classes
```

**Integration Issues**:
```
❌ Integration: Frontend build FAILS
→ Fix: Resolve build errors, ensure types are synced
```

## Progressive Rigor

**For critical features** (payments, auth, data integrity):
- All checks must pass
- No warnings allowed
- Manual verification mandatory

**For non-critical features** (UI tweaks, logging):
- Critical checks must pass
- Warnings acceptable with justification
- Manual verification recommended

**For prototypes/spikes** (experiments):
- Mark as "prototype" in commit message
- Verification optional
- Not deployed to production

## Tips

- Run early and often - Don't wait until "done"
- Fix issues as you go - Easier than batch at end
- Use warnings as learning - Improve over time
- Automate what you can - Let humans focus on design

## Integration with Other Skills

- **Before**: Implementation complete
- **After**: `/validator` (code review), `/karen` (reality check)
- **If fails**: Fix issues, re-run until passes
