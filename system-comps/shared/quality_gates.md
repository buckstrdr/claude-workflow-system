# Quality Gates Workflow

Every feature progresses through 7 mandatory quality gates. No gate may be skipped.

## The 7 Gates

### Gate 1: Spec Approved
**Requirements:**
- ✅ Specification document exists
- ✅ Spec approved by architect/planner
- ✅ Acceptance criteria clear and testable

**Roles:** Planner, Architect
**Script:** `./scripts/quality-gates/gates-start.sh <feature>`

### Gate 2: Tests First
**Requirements:**
- ✅ Tests exist for all planned functionality
- ✅ Tests currently FAIL (Red phase)
- ✅ No implementation code committed yet

**Roles:** Dev, QA
**Validation:** Git history shows test commits before implementation

### Gate 3: Implementation Complete
**Requirements:**
- ✅ All tests now PASS (Green phase)
- ✅ No TODO comments in production code
- ✅ No debug/console.log statements

**Roles:** Dev
**Validation:** Full test suite runs clean

### Gate 4: Refactored
**Requirements:**
- ✅ DRY principles applied (no duplication)
- ✅ SOLID principles followed
- ✅ Tests still pass after refactoring

**Roles:** Dev
**Validation:** `/pragmatist` skill reviews for quality

### Gate 5: Integrated
**Requirements:**
- ✅ OpenAPI spec updated (if API changes)
- ✅ TypeScript types synced with backend
- ✅ Documentation updated

**Roles:** Docs, Dev
**Validation:** Type checking passes, docs reflect implementation

### Gate 6: E2E Verified
**Requirements:**
- ✅ Backend starts without errors
- ✅ Frontend builds successfully
- ✅ E2E tests pass (Playwright)

**Roles:** QA
**Validation:** `/e2e-verify` skill runs full stack

### Gate 7: Code Reviewed
**Requirements:**
- ✅ `/validator` skill passed
- ✅ All critical issues resolved
- ✅ Production-ready assessment complete

**Roles:** QA, Orchestrator
**Validation:** Validator report shows no blockers

## Gate Advancement

**Only Orchestrator advances gates.**

To advance:
```bash
./scripts/quality-gates/gates-pass.sh <feature>
```

**Pre-push hook** blocks pushing to main unless Gate 7 is PASSED.

## Checking Gate Status

```bash
./scripts/quality-gates/gates-check.sh <feature>
```

Shows current gate, requirements, and completion status.

## Gate Bypass (EMERGENCY ONLY)

Gates can be bypassed in emergencies:
```bash
STRICT_HOOKS=0 git push origin main
```

**Use only for:**
- Production hotfixes
- Security patches
- Critical bug fixes

Document the bypass reason in commit message.

## Why Gates Matter

- **Gate 2 (Tests First):** Prevents untested code
- **Gate 4 (Refactored):** Prevents technical debt accumulation
- **Gate 7 (Code Reviewed):** Prevents production incidents

Skipping gates = shipping problems to production.
