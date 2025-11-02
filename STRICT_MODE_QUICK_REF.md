# Strict Enforcement Mode - Quick Reference

## TL;DR

**ALL development requires 7-stage quality gates. No exceptions.**

## The 7 Gates

```
1. Spec Approved     → /spec
2. Tests First (TDD) → Write tests (Red)
3. Implementation    → Make tests pass (Green)
4. Refactored       → Clean code
5. Integrated       → make openapi && make types
6. E2E Verified     → /e2e-verify
7. Code Reviewed    → /validator
```

## Quick Start (New Feature)

```bash
# 1. Branch
git checkout -b issue/42-my-feature

# 2. Init gates (hook reminds you)
/gates start my_feature

# 3. Spec
/spec
/gates pass

# 4. Tests FIRST
# Create: topstepx_backend/tests/test_my_feature.py
git commit -m "test: add my feature tests"
/gates pass

# 5. Implement
# Edit: topstepx_backend/services/my_service.py
git commit -m "feat: implement my feature"
/gates pass

# 6. Refactor
/pragmatist
/gates pass

# 7. Integrate
make openapi && make types
/gates pass

# 8. E2E
/e2e-verify
/gates pass

# 9. Review
/validator
/gates pass

# 10. Push
git push origin main
# Pre-push hook checks Gate 7 ✓
```

## What Blocks You

### Pre-Commit Hook
❌ Committing implementation without tests
❌ Committing tests + implementation together

**Fix**: Separate commits (tests first, implementation second)

### Pre-Push Hook
❌ Pushing to main without Gate 7
❌ Incomplete work (TODOs, failing tests)
❌ Failing CI checks

**Fix**: Complete all gates, fix issues

### CI/CD
❌ No gate tracking
❌ Gate 7 not complete
❌ Production code issues

**Fix**: Follow workflow, fix code

## Bypass (Emergency Only)

```bash
# Bypass TDD (NOT RECOMMENDED)
STRICT_TDD=0 git commit -m "emergency: hotfix"

# Bypass push checks (DANGEROUS)
STRICT_HOOKS=0 git push origin main
```

**Only use for**: Production emergencies

**Never use for**: "I'm in a hurry", "Tests are annoying"

## Common Errors

### "BLOCKED: STRICT_TDD=1 requires tests"

```bash
# Unstage implementation
git reset HEAD topstepx_backend/services/

# Commit tests first
git add topstepx_backend/tests/
git commit -m "test: add tests"

# Then commit implementation
git add topstepx_backend/services/
git commit -m "feat: implement"
```

### "BLOCKED: Cannot push without Gate 7"

```bash
# Check status
/gates

# Complete remaining gates
/e2e-verify
/validator

# Advance gates
/gates pass  # Gate 6
/gates pass  # Gate 7

# Push
git push origin main
```

### "BLOCKED: No quality gate tracking"

```bash
# Initialize
/gates start <feature_name>

# Follow workflow
/spec
# ... continue ...
```

## Skills Reference

```bash
/startup          # Start session (ALWAYS first)
/gates            # Check gate status
/gates pass       # Advance gate
/spec             # Create specification
/verify-complete  # Check completeness
/e2e-verify       # End-to-end verification
/validator        # Validate completion
/karen            # Reality check
/pragmatist       # Anti-over-engineering
```

## Why This Exists

**Problem**: "Vibe coding" leads to bugs, regressions, technical debt

**Solution**: Disciplined workflow ensures quality at every step

**Result**: High confidence in every deployment, comprehensive test coverage, clear documentation

## Philosophy

- Quality is non-negotiable
- Tests prevent regressions
- Specifications prevent scope creep
- Reviews catch issues early
- **Discipline beats motivation**

---

**Full Documentation**: See `CLAUDE.md` section "Strict Enforcement Mode"

**Git Hooks**:
- `.git/hooks/enforce-test-first` - TDD enforcement
- `.git/hooks/pre-push` - Gate 7 + CI enforcement
- `.git/hooks/post-checkout` - Workflow reminder

**CI/CD**: `.github/workflows/quality-gates.yml`
