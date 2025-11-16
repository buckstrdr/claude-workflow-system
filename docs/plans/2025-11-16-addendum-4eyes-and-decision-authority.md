# Addendum: 4-Eyes Principle and Decision Authority Protocol

**Date:** 2025-11-16
**Status:** Ready for Implementation
**Applies to:** Multi-Instance Claude Code Orchestration System (v3 spec)
**Addendum Number:** 001
**Priority:** CRITICAL - Foundational Rule

---

## Executive Summary

This addendum establishes three critical governance protocols for the multi-instance system:

1. **4-Eyes Principle with Thresholds** - Dual sign-off required for significant changes (>50 LOC, high risk, commits), with fast-track for trivial changes
2. **Peer-First Review Protocol** - Dev-A ↔ Dev-B, QA-A ↔ QA-B, Planner-A ↔ Planner-B, Architect-A ↔ Architect-B/C cross-review FIRST, escalate only on disagreement
3. **Architecture Council (3-Member Voting)** - Odd-number council (Architect-A/B/C) provides tie-breaking votes for architectural decisions
4. **Decision Authority Protocol** - Clear matrix of what Orchestrator decides autonomously vs. escalates to user

**Critical System Changes:**
- **Instance count:** 12 (was 9)
  - Added: Planner-B, Architect-B, Architect-C
- **Peer review layers:** Dev, QA, Planner, Architect all have peer review
- **Escalation paths:** Peers → Orchestrator/Architect Council → User
- **Efficiency:** Fast-track for low-risk changes (<50 LOC, <3 files)

**Impact:**
- Prevents single-point-of-failure decisions
- Enables tie-breaking votes (Architecture Council)
- Faster peer reviews (context-aware peers)
- Maintains velocity (thresholds prevent overhead)
- Clear escalation paths for all dispute types

**Implementation Required:**
- System-comps updates (12 roles)
- Message protocol additions (PeerReviewRequest, voting messages)
- tmux layout changes (12 panes)
- Threshold detection logic
- Workflow changes across all roles

---

## Table of Contents

1. [4-Eyes Principle (Dual Sign-Off Requirement)](#1-4-eyes-principle-dual-sign-off-requirement)
2. [4-Eyes Threshold Criteria](#2-4-eyes-threshold-criteria)
3. [Peer Review First Protocol](#3-peer-review-first-protocol)
4. [Role Pairing Matrix](#4-role-pairing-matrix)
5. [Sign-Off Message Protocol](#5-sign-off-message-protocol)
6. [Decision Authority Matrix](#6-decision-authority-matrix)
7. [Escalation Protocol](#7-escalation-protocol)
8. [Implementation Guide](#8-implementation-guide)
9. [System-Comps Additions](#9-system-comps-additions)
10. [Examples and Workflows](#10-examples-and-workflows)

---

## 1. 4-Eyes Principle (Dual Sign-Off Requirement)

### 1.1 Core Principle

**MANDATORY RULE:**
No decision, implementation, or quality gate advancement is valid without sign-off from at least **two independent roles**.

**Rationale:**
- Prevents single-role errors from propagating
- Ensures peer review at every decision point
- Catches blind spots and assumptions
- Enforces collaboration over isolation
- Structurally enforces quality through redundancy

### 1.2 What Requires 4-Eyes

**ALL of the following require dual sign-off:**

1. **Code Changes**
   - Dev writes → QA signs off (tests pass, meets spec)
   - Dev-A writes → Dev-B reviews (code quality, patterns)

2. **Specifications and Plans**
   - Planner creates spec → Architect reviews (technical feasibility)
   - Architect designs → Planner reviews (meets requirements)

3. **Quality Gate Advancement**
   - Role requests advancement → Orchestrator + one validator sign off
   - Example: Dev-A completes Gate 3 → QA-A validates + Orchestrator approves

4. **Documentation Updates**
   - Docs writes → Librarian reviews (accuracy, completeness)
   - Docs writes → Dev/QA confirms technical accuracy

5. **Architecture Decisions**
   - Architect proposes → Planner + Orchestrator review
   - If critical path → User provides final sign-off (3rd eye)

6. **Technical Approach Selection**
   - Dev proposes approach → QA reviews testability
   - Architect reviews → Orchestrator approves or escalates

7. **Test Strategy**
   - QA designs tests → Dev reviews (implementable, sufficient)
   - QA runs tests → Dev confirms interpretation

8. **Merge to Main**
   - All quality gates passed (multiple role validations)
   - Orchestrator final approval
   - Git hook enforcement (automatic 2nd check)

### 1.3 What Does NOT Require 4-Eyes

**Fast-track items (single role sufficient):**

1. **Reading Operations**
   - File reads
   - Git history queries
   - Documentation lookups

2. **Intermediate Work Products**
   - Draft code (not committed)
   - Exploratory analysis
   - Research notes

3. **Message Passing**
   - Sending status updates
   - Requesting context
   - Acknowledging receipt

**Rationale:** These don't affect the system state permanently and can be self-corrected.

---

## 2. 4-Eyes Threshold Criteria

### 2.1 When 4-Eyes Is Required (Efficiency Principle)

**Problem:** Applying 4-eyes to every trivial decision creates unnecessary overhead and slows velocity.

**Solution:** Define clear thresholds that trigger 4-eyes requirement.

### 2.2 Complexity-Based Thresholds

**4-Eyes REQUIRED when ANY of the following is true:**

| **Criterion** | **Threshold** | **Example** |
|---------------|---------------|-------------|
| **Lines of Code** | Changes >50 LOC | Implementing new feature |
| **Files Modified** | >3 files | Refactoring across multiple modules |
| **Quality Gate** | Any gate advancement | Moving from Gate 2 to Gate 3 |
| **Risk Level** | High or Critical | Authentication, payment, security code |
| **Permanence** | Git commit/merge | Any code going into version control |
| **User-Facing** | Frontend changes | UI components, API endpoints |
| **Data Changes** | Schema migrations | Database changes, data model updates |
| **Dependencies** | Adding/updating libraries | New npm/pip packages |
| **Configuration** | Production config changes | Environment variables, deployment settings |

**4-Eyes NOT REQUIRED when ALL of the following are true:**

| **Criterion** | **Threshold** | **Example** |
|---------------|---------------|-------------|
| **Lines of Code** | Changes ≤50 LOC | Small utility function, bug fix |
| **Files Modified** | ≤3 files | Isolated change |
| **Risk Level** | Low | Internal helper, test utilities |
| **Reversible** | Easy to undo | Draft code, exploratory work |
| **Scope** | Self-contained | No external dependencies |

### 2.3 Automatic Threshold Detection

**Orchestrator automatically determines if 4-eyes required:**

```python
def requires_4_eyes(change) -> bool:
    """Determine if change requires 4-eyes sign-off"""

    # High-risk areas ALWAYS require 4-eyes
    high_risk_patterns = [
        'backend/auth/*',
        'backend/payments/*',
        'backend/api/v1/*',
        'frontend/src/components/Auth/*',
        '*.sql',  # Database migrations
        'config/production/*'
    ]

    for pattern in high_risk_patterns:
        if matches(change.files, pattern):
            return True

    # Quantitative thresholds
    if change.lines_of_code > 50:
        return True

    if len(change.files) > 3:
        return True

    if change.is_git_commit:
        return True

    if change.quality_gate_advancement:
        return True

    # Low-complexity changes can skip 4-eyes
    return False
```

### 2.4 Fast-Track Workflow (Single Role)

**For changes below threshold:**

```
Dev-A: Small bug fix (20 LOC, 1 file, low risk)
        ↓
Orchestrator: "Threshold check: Below 4-eyes threshold"
        ↓
Dev-A: Self-review checklist
        ↓
Dev-A: Request write lock
        ↓
Dev-A: Commit with "FAST-TRACK: Below 4-eyes threshold" tag
        ↓
Post-commit: QA-A spot-checks (async, non-blocking)
```

**Benefits:**
- Maintains velocity for trivial changes
- Reduces unnecessary coordination overhead
- QA still spot-checks (quality insurance)
- 4-eyes enforced where it matters most

### 2.5 Risk-Based Classification

**Every change is classified by risk:**

**CRITICAL (Always 4-Eyes + User Escalation):**
- Authentication/authorization
- Payment processing
- Data encryption/security
- Database schema changes
- Production deployment config

**HIGH (Always 4-Eyes):**
- User-facing features
- API endpoints
- Frontend components
- Data models
- Integration points

**MEDIUM (4-Eyes if >threshold):**
- Business logic
- Service layer code
- Utility functions
- Test code

**LOW (Fast-track allowed):**
- Code comments
- Documentation
- Test fixtures
- Internal helpers
- Debug logging

**Classification in commit:**
```bash
git commit -m "fix: Correct typo in error message

Risk: LOW
Fast-Track: Eligible (15 LOC, 1 file)
Self-Review: ✓ Checklist complete
Post-Review: QA-A spot-check scheduled"
```

---

## 3. Peer Review First Protocol

### 3.1 Principle: Peers Before Escalation

**Default workflow:** Dev-A ↔ Dev-B cross-review FIRST, escalate only on disagreement.

**Rationale:**
- Peers understand implementation details best
- Faster review turnaround (both Dev instances active)
- Escalation only when genuinely needed
- Reduces load on Orchestrator/Architect

### 3.2 Dev Peer Review Workflow

**Step 1: Dev-A completes work**
```
Dev-A implements feature
        ↓
Dev-A self-review (checklist)
        ↓
Dev-A → Dev-B: PeerReviewRequest
  "Review my implementation of idempotency store
   Files: backend/services/idempotency_store.py (120 LOC)
   Threshold: Above 4-eyes threshold (>50 LOC, High risk)
   Focus: Thread safety, Redis connection handling"
```

**Step 2: Dev-B reviews**
```
Dev-B reviews code
        ↓
    ┌───┴───┐
    │       │
AGREE   DISAGREE
    │       │
    ↓       ↓
```

**Step 3a: Agreement → Deploy**
```
Dev-B → Dev-A: PeerReviewApproval
  "✅ Code quality good
   Thread safety verified
   Redis handling correct
   Approved for commit"

Dev-A → Orchestrator: WriteRequest

Orchestrator → Dev-A: WriteLockGrant

Dev-A: git commit -m "feat: implement idempotency store

Peer-Reviewed-By: Dev-B
Approved-At: 2025-11-16T21:00:00Z"
```

**Step 3b: Disagreement → Escalate**
```
Dev-B → Dev-A: PeerReviewRejection
  "❌ Concerns:
   - Thread safety issue: Redis connection not pooled
   - No retry logic for Redis failures

   Disagreement: This needs architectural review"

Dev-A disagrees with rejection
        ↓
Determine escalation path:
  - Simple/Technical? → Orchestrator
  - Complex/Architectural? → Architect
```

### 3.3 Escalation Decision Matrix

**When Dev-A and Dev-B disagree, escalate based on complexity:**

| **Disagreement Type** | **Escalate To** | **Example** |
|----------------------|----------------|-------------|
| **Code style/patterns** | Orchestrator | "Use forEach vs for loop?" |
| **Algorithm choice** | Orchestrator | "Binary search vs linear search?" |
| **Error handling approach** | Orchestrator | "Throw exception vs return error?" |
| **Architecture pattern** | Architect | "Use Redis vs PostgreSQL?" |
| **System design** | Architect | "Sync vs async processing?" |
| **Performance trade-offs** | Architect | "Memory vs CPU optimization?" |
| **Data model changes** | Architect | "Normalize vs denormalize schema?" |
| **Security approach** | Architect + QA | "JWT vs session-based auth?" |

### 3.4 Escalation Process

**Simple Disagreement → Orchestrator:**

```
Dev-A: "Use Map for lookup"
Dev-B: "Use Set for lookup"
[Technical disagreement, both valid]

Dev-A → Orchestrator: DisputeResolution
  "Peer review disagreement (technical)

   Position A (Dev-A): Use Map
   - Allows storing metadata
   - Slightly more memory

   Position B (Dev-B): Use Set
   - Simpler
   - Faster lookup

   Context: Idempotency key storage (no metadata needed currently)"

Orchestrator applies /pragmatist principles:
  "Choose simpler approach: Set
   Can refactor to Map if metadata needed later (YAGNI)"

Orchestrator → Dev-A + Dev-B: DecisionAnnouncement
  "Use Set for idempotency keys
   Reasoning: Simpler, meets current requirements
   Both implement with Set approach"

Dev-A + Dev-B: [Both agree with decision, proceed]
```

**Complex Disagreement → Architect:**

```
Dev-A: "Store idempotency keys in PostgreSQL"
Dev-B: "Store idempotency keys in Redis"
[Architectural disagreement]

Dev-B → Architect: ArchitecturalReview
  "Peer disagreement on storage backend

   Position A (Dev-A): PostgreSQL
   - Transactional consistency
   - No new dependency
   - Durable

   Position B (Dev-B): Redis
   - Faster lookups
   - Built-in TTL
   - Industry standard for this pattern

   Context: Order idempotency checking, 1-hour TTL required"

Architect analyzes:
  - Current system: PostgreSQL primary DB
  - Performance needs: 100 requests/second
  - Operational complexity: Adding Redis

Architect → Dev-A + Dev-B: ArchitecturalDecision
  "Use PostgreSQL with pg_cron for TTL cleanup

   Reasoning:
   - Performance adequate for current scale (100/sec well within PG capacity)
   - Avoid new operational dependency (Redis)
   - Can migrate to Redis if scale requires (premature optimization)
   - /pragmatist principle: Simplicity over performance speculation

   Implementation: Use PostgreSQL table with cleanup job"

Dev-A + Dev-B: [Implement Architect's decision]
```

### 3.5 QA Peer Review Workflow

**Same principle applies to QA-A ↔ QA-B:**

```
QA-A designs test strategy
        ↓
QA-A → QA-B: PeerReviewRequest
  "Review test plan for idempotency feature"
        ↓
QA-B reviews
        ↓
    Agreement? → Approve
    Disagreement? → Escalate to Orchestrator
```

**QA disagreement escalation:**
- Test coverage disputes → Orchestrator (uses project standards)
- Test methodology → Orchestrator
- Performance testing approach → Architect

### 3.6 Benefits of Peer-First Protocol

✅ **Faster reviews** - Peers available and context-aware
✅ **Reduced escalation load** - Orchestrator/Architect only for genuine disputes
✅ **Knowledge sharing** - Devs learn from each other's code
✅ **Higher code quality** - Peer scrutiny before commit
✅ **Clearer escalation** - Only unresolvable disputes go up

---

## 4. Role Pairing Matrix

### 4.1 Updated Primary Pairings (Peer-First Protocol)

**Key Change:** Devs and QAs pair with peers FIRST, escalate only on disagreement.

| **Primary Role** | **Primary Sign-Off (Peer)** | **Escalation Sign-Off** | **Validates** |
|------------------|---------------------------|------------------------|---------------|
| **Dev-A** | Dev-B (peer first) | Orchestrator (technical) or Architect (complex) | Code quality, patterns, implementation |
| **Dev-B** | Dev-A (peer first) | Orchestrator (technical) or Architect (complex) | Code quality, patterns, implementation |
| **QA-A** | QA-B (peer first) | Orchestrator (standards) or Dev-A (implementability) | Test design, coverage, methodology |
| **QA-B** | QA-A (peer first) | Orchestrator (standards) or Dev-B (implementability) | Test design, coverage, methodology |
| **Planner** | Architect | Orchestrator (scope) or User (critical path) | Technical feasibility, completeness |
| **Architect** | Planner | Orchestrator or User (architecture decisions) | Meets requirements, scope appropriate |
| **Docs** | Librarian + (Dev or QA) | Orchestrator (formatting) | Accuracy, completeness, technical correctness |
| **Librarian** | Docs | Orchestrator (search quality) | Context accuracy, relevance |
| **Orchestrator** | User (critical path only) | N/A - Orchestrator is escalation point | Decision authority per matrix |

### 4.2 Escalation Paths Summary

**Workflow hierarchy:**
```
Dev-A ↔ Dev-B (Peer review)
    ↓ (on disagreement)
    ├─→ Orchestrator (technical/simple)
    └─→ Architect (architectural/complex)
        ↓ (on critical path)
        User (final authority)
```

**Same for QA:**
```
QA-A ↔ QA-B (Peer review)
    ↓ (on disagreement)
    ├─→ Orchestrator (standards/process)
    └─→ Dev (implementability concerns)
        ↓ (if unresolved)
        Architecture Council or Orchestrator
```

### 4.3 Architecture Council (3-Member Voting Body)

**CRITICAL UPDATE:** Architecture role expanded from 1 to 3 instances to enable tie-breaking votes.

**Composition:**
- **Architect-A** (Chief Architect)
- **Architect-B** (Senior Architect)
- **Architect-C** (Senior Architect)

**Total system instances:** 12 (was 9)
- 1 Orchestrator
- 1 Librarian
- **2 Planners** (Planner-A, Planner-B)
- **3 Architects** (Architecture Council)
- 2 Devs (Dev-A, Dev-B)
- 2 QAs (QA-A, QA-B)
- 1 Docs

**Why 3 Architects:**
- **Prevents deadlock** - Odd number ensures majority vote
- **Peer review for architecture** - Architect-A ↔ Architect-B/C
- **Breaking tie votes** - 2-1 decision when disagreement occurs
- **Knowledge distribution** - Architectural understanding across 3 roles
- **No single point of failure** - If one architect unavailable, 2 can still decide

**Architect Peer Review Workflow:**
```
Architect-A proposes architecture
        ↓
Architect-A → Architect-B: PeerReviewRequest
        ↓
Architect-B reviews
        ↓
    ┌───┴───┐
    │       │
AGREE   DISAGREE
    │       │
    ↓       ↓
Approve   Invoke Architect-C (tie-breaker)
```

**Architecture Council Vote:**
```
Major architectural decision required
        ↓
All 3 Architects review independently
        ↓
Each casts vote: Approach A or Approach B
        ↓
Majority wins (2-1 or 3-0)
        ↓
Orchestrator implements majority decision
```

**Council Voting Triggers:**
- Infrastructure changes (databases, caches, queues)
- Framework/library selections
- Microservices vs monolith decisions
- Data model schema changes
- Security architecture
- Deployment architecture
- Integration patterns

### 4.4 Planner Peer Review (2-Member with Escalation)

**CRITICAL UPDATE:** Planner role expanded from 1 to 2 instances for peer review.

**Composition:**
- **Planner-A** (Lead Planner)
- **Planner-B** (Senior Planner)

**Why 2 Planners:**
- **Peer review for specs** - Planner-A ↔ Planner-B review each other's plans
- **Scope validation** - Second planner catches scope creep or missing requirements
- **Estimation cross-check** - Independent estimates reveal estimation errors
- **Tie-breaking via Architecture Council** - If disagreement, escalate to Architects (odd number)

**Planner Peer Review Workflow:**
```
Planner-A creates specification
        ↓
Planner-A → Planner-B: PeerReviewRequest
  "Review spec for order_idempotency feature
   Scope: 5 tasks, 1 week estimate
   Dependencies: Redis integration
   Focus: Completeness, feasibility, estimation"
        ↓
Planner-B reviews independently
        ↓
    ┌───┴───┐
    │       │
AGREE   DISAGREE
    │       │
    ↓       ↓
Approve   Escalate to Architecture Council
```

**Planner Disagreement Escalation:**
```
Planner-A: "Feature is 1 week, use PostgreSQL"
Planner-B: "Feature is 3 weeks, needs Redis"
[Scope/technical disagreement]

Planner-B → Architecture Council: ArchitecturalReview
  "Planner disagreement on scope and technical approach

   Position A (Planner-A):
   - Scope: 5 tasks, 1 week
   - Tech: PostgreSQL (simpler)

   Position B (Planner-B):
   - Scope: 15 tasks, 3 weeks
   - Tech: Redis (performance)

   Disagreement: Scope AND technical approach"

Architecture Council (3 votes):
  Architect-A: "Agrees with Planner-B - Redis needed for scale"
  Architect-B: "Agrees with Planner-A - PostgreSQL sufficient initially"
  Architect-C: "Agrees with Planner-A - avoid premature optimization"

  Vote Result: 2-1 for Planner-A approach (PostgreSQL)

Architecture Council → Both Planners: ArchitecturalDecision
  "Proceed with Planner-A approach:
   - PostgreSQL for idempotency store
   - 1 week implementation
   - Can migrate to Redis if performance requires"

Planner-A + Planner-B: [Both implement Council's decision]
```

**Planner Peer Review Checklist:**

Planner-B reviews Planner-A's spec for:
- [ ] All requirements captured
- [ ] Success criteria clear and testable
- [ ] Scope reasonable (not over/under-scoped)
- [ ] Estimation realistic (cross-reference similar features)
- [ ] Dependencies identified
- [ ] Technical approach feasible
- [ ] Quality gate alignment clear
- [ ] Test requirements specified
- [ ] Documentation requirements included
- [ ] No missing edge cases

### 4.5 QA Peer Review Workflow (Explicit Protocol)

**QA-A and QA-B follow same peer-first protocol as Dev:**

```
QA-A designs test strategy
        ↓
QA-A → QA-B: PeerReviewRequest
  "Review test plan for order_idempotency
   Test types: Unit (12 tests), Integration (5 tests), E2E (3 tests)
   Coverage target: 85%
   Edge cases: Concurrent access, TTL expiry, Redis failure
   Focus: Completeness, coverage adequacy"
        ↓
QA-B reviews independently
        ↓
    ┌───┴───┐
    │       │
AGREE   DISAGREE
    │       │
    ↓       ↓
Approve   Escalate
```

**QA Agreement → Proceed:**
```
QA-B → QA-A: PeerReviewApproval
  "✅ Test plan comprehensive
   Coverage adequate (85% > 80% standard)
   Edge cases well-identified
   Approved for implementation"

QA-A: [Implements test plan]
```

**QA Disagreement → Escalate:**

**Simple disagreement (standards/coverage) → Orchestrator:**
```
QA-A: "80% coverage sufficient"
QA-B: "Need 90% coverage for payment code"
[Standards interpretation]

QA-B → Orchestrator: StandardsDisagreement
  "QA peer disagreement on coverage standard

   Position A (QA-A): 80% (project standard)
   Position B (QA-B): 90% (payment code is critical)

   Context: Order processing with payment integration"

Orchestrator applies documented standards:
  - Project standard: 80% minimum
  - Critical code paths (auth, payment, security): 90% minimum

Orchestrator → QA-A + QA-B: DecisionAnnouncement
  "Payment integration code requires 90% coverage
   Reasoning: Documented standard for critical paths
   QA-A: Increase coverage target to 90%"

QA-A: [Updates test plan to 90% coverage]
```

**Complex disagreement (testing approach) → Dev + Architect:**
```
QA-A: "Test idempotency with mocked Redis"
QA-B: "Test idempotency with real Redis (test container)"
[Testing methodology]

QA-B → Dev-A: TestabilityReview
  "QA disagreement on testing approach

   Position A (QA-A): Mock Redis
   - Faster tests
   - No infrastructure dependency

   Position B (QA-B): Real Redis (testcontainer)
   - Tests real behavior
   - Catches integration issues

   Developer input needed: Which is more valuable?"

Dev-A: "Real Redis preferred - found bugs in past with mocks
        Testcontainers adds ~2s per test but catches real issues"

Dev-A → QA-A + QA-B: DeveloperRecommendation
  "Use real Redis via testcontainers
   Speed trade-off worth it for integration confidence"

QA-A + QA-B: [Both agree with Dev recommendation, implement with testcontainers]
```

**QA Peer Review Checklist:**

QA-B reviews QA-A's test plan for:
- [ ] All success criteria from spec tested
- [ ] Happy path tests included
- [ ] Edge case tests identified
- [ ] Error case tests included
- [ ] Coverage target meets standards (80% min, 90% critical)
- [ ] Test data representative
- [ ] Performance tested (if relevant)
- [ ] Security tested (if relevant)
- [ ] Tests deterministic (no flaky tests)
- [ ] Mocking appropriate (not over-mocked)

### 4.6 Complete Escalation Hierarchy

**Final escalation paths with all peer reviews:**

```
Dev-A ↔ Dev-B (peer review)
    ↓ disagree
    ├─→ Orchestrator (technical: algorithms, patterns, error handling)
    └─→ Architecture Council (architectural: databases, frameworks, patterns)
        ↓ critical path
        User

Planner-A ↔ Planner-B (peer review)
    ↓ disagree
    Architecture Council (scope, approach, estimation)
        ↓ critical path (scope >20%, timeline >50%)
        User

QA-A ↔ QA-B (peer review)
    ↓ disagree
    ├─→ Orchestrator (standards: coverage, methodology)
    ├─→ Dev (implementability: mocking, testability)
    └─→ Architecture Council (complex testing approach)

Architect-A ↔ Architect-B (peer review)
    ↓ disagree
    Architect-C votes (tie-breaker)
    ↓ majority (2-1 or 3-0)
    Orchestrator implements
        ↓ critical path (architecture change, new dependency)
        User
```

### 2.2 Escalation Pairings (For Critical Decisions)

| **Decision Type** | **Primary** | **Secondary** | **Final Authority** |
|-------------------|-------------|---------------|---------------------|
| Architecture | Architect | Orchestrator | User |
| Scope Change | Planner | Orchestrator | User |
| Quality Exception | QA | Orchestrator | User |
| Technical Debt | Dev | QA + Orchestrator | User |
| Process Change | Orchestrator | All Roles | User |

---

## 3. Sign-Off Message Protocol

### 3.1 New Message Type: `SignOffRequest`

```markdown
## SignOffRequest

**From:** <requesting_role>
**To:** <reviewing_role>
**Timestamp:** <ISO 8601>
**Message ID:** SOR-<number>

**Feature Context:**
- Name: <feature_name>
- Current Gate: <gate_number> (<gate_name>)

**Sign-Off Type:**
- [ ] Code Implementation
- [ ] Test Design
- [ ] Documentation
- [ ] Architecture Decision
- [ ] Quality Gate Advancement
- [ ] Specification

**What Needs Sign-Off:**
<Clear description of what was done>

**Files Involved:**
- <file_path_1>
- <file_path_2>

**Changes Made:**
<Summary of changes>

**Success Criteria Met:**
- [x] Criterion 1: <description>
- [x] Criterion 2: <description>
- [x] Criterion 3: <description>

**Tests:**
- Status: <PASSING/FAILING>
- Coverage: <percentage>
- Edge cases covered: <list>

**Self-Review Checklist:**
- [x] Follows TDD principles
- [x] Meets quality gate requirements
- [x] Documentation updated
- [x] No TODOs or debug statements
- [x] Passes linting

**Specific Review Focus:**
<What you want reviewer to focus on>

**Expected Response:**
SignOffApproval or SignOffRejection with specific feedback
```

### 3.2 New Message Type: `SignOffApproval`

```markdown
## SignOffApproval

**From:** <reviewing_role>
**To:** <requesting_role>
**CC:** Orchestrator
**Timestamp:** <ISO 8601>
**Message ID:** SOA-<number>
**In Response To:** SOR-<number>

**Feature:** <feature_name>

**Review Completed:**
- Reviewed Files: <list>
- Tests Verified: <PASS/FAIL>
- Documentation Checked: <YES/NO>

**Sign-Off Status:** ✅ APPROVED

**Review Findings:**
- Meets all success criteria: YES
- Code quality acceptable: YES
- Tests comprehensive: YES
- Documentation accurate: YES

**Minor Suggestions (optional, non-blocking):**
- <suggestion 1>
- <suggestion 2>

**Signature:**
Role: <reviewing_role>
Date: <ISO 8601>

**Next Step:**
<requesting_role> may proceed with commit/gate advancement/merge
```

### 3.3 New Message Type: `SignOffRejection`

```markdown
## SignOffRejection

**From:** <reviewing_role>
**To:** <requesting_role>
**CC:** Orchestrator
**Timestamp:** <ISO 8601>
**Message ID:** SOR-<number>
**In Response To:** SOR-<number>

**Feature:** <feature_name>

**Sign-Off Status:** ❌ REJECTED

**Critical Issues (must fix before re-submission):**
1. <specific issue with file/line reference>
2. <specific issue with file/line reference>

**Quality Concerns:**
- Tests: <issue description>
- Code: <issue description>
- Documentation: <issue description>

**Required Changes:**
- [ ] Change 1: <specific action>
- [ ] Change 2: <specific action>
- [ ] Change 3: <specific action>

**Recommendations:**
- <optional suggestion>

**Re-Review Process:**
After addressing critical issues, send new SignOffRequest with:
- List of changes made
- Updated files
- Confirmation of test results

**Signature:**
Role: <reviewing_role>
Date: <ISO 8601>
```

---

## 4. Decision Authority Matrix

### 4.1 Orchestrator Autonomous Decisions (Dual Sign-Off Internal)

Orchestrator can decide **without user escalation** if it has sign-off from relevant role:

| **Decision Type** | **Orchestrator + Required Sign-Off** | **Example** |
|-------------------|--------------------------------------|-------------|
| Technical implementation details | Dev-A + QA-A | Which data structure to use |
| Quality gate interpretation | QA + (Librarian or Architect) | Whether coverage meets standard |
| Task prioritization | Planner + (Dev or QA) | Order of task execution |
| Tool/skill selection | Librarian + requesting role | Which MCP tool to use |
| Refactoring approach | Dev + QA | How to restructure code |
| Test strategy | QA + Dev | Unit vs integration test mix |

**Process:**
1. Orchestrator applies documented principles
2. Gets sign-off from relevant role
3. Announces decision to all roles
4. Documents in `docs/feature/<feature>/decisions.md`
5. Proceeds immediately

### 4.2 User Escalation Required (Orchestrator + 2 Roles + User)

**Critical path decisions** require:
- Orchestrator analysis
- Sign-off from 2 relevant roles
- Final approval from User

| **Decision Type** | **Required Sign-Offs** | **Example** |
|-------------------|------------------------|-------------|
| Architecture changes | Architect + Planner + Orchestrator → User | Microservices vs monolith |
| Scope changes (>20%) | Planner + (Dev or QA) + Orchestrator → User | Feature expands from 1 week to 3 weeks |
| Quality exceptions | QA + Orchestrator → User | Skip TDD for hotfix |
| New dependencies | Architect + Librarian + Orchestrator → User | Add Redis, new framework |
| Timeline deviations (>50%) | Planner + (Dev or QA) + Orchestrator → User | Estimated 2 days, actually 5 days |

**Process:**
1. Orchestrator coordinates with relevant roles
2. Collects sign-offs from 2+ roles
3. Escalates to User with `CriticalDecisionRequest`
4. User provides final decision
5. Orchestrator announces to all roles
6. Documents in ADR (if architectural)

### 4.3 Emergency Bypass (Single Sign-Off)

**ONLY in genuine emergencies** (production down, security breach):

- Orchestrator can authorize **temporary** single sign-off
- Must document as technical debt
- Requires follow-up 4-eyes review within 24 hours
- User notified immediately

**Example:**
```
Production security vulnerability detected
→ Orchestrator + Dev-A emergency patch (single sign-off)
→ Deploy immediately
→ Create tech debt ticket: "Retrospective 4-eyes review of security patch"
→ QA-A + Dev-B review within 24 hours
```

---

## 5. Escalation Protocol

### 5.1 Escalation Workflow

```
Role A completes work
        ↓
Role A sends SignOffRequest to Role B
        ↓
Role B reviews
        ↓
    ┌───┴───┐
    │       │
APPROVE   REJECT
    │       │
    │       └─→ Role A fixes issues
    │            └─→ Re-submit SignOffRequest
    ↓
Role A receives SignOffApproval
        ↓
Is this a critical path decision?
    │
    NO → Role A proceeds (Orchestrator informed)
    │
    YES → Role A sends to Orchestrator
          ↓
          Orchestrator evaluates
          ↓
          Orchestrator sends CriticalDecisionRequest to User
          ↓
          User approves/rejects
          ↓
          Orchestrator sends DecisionAnnouncement to all roles
          ↓
          Role A proceeds with approved approach
```

### 5.2 Deadlock Resolution

**Scenario:** Role A and Role B disagree, cannot reach consensus

**Resolution:**
1. **Attempt 1:** Invoke `/superpowers:brainstorming` for systematic exploration
2. **Attempt 2:** Escalate to Orchestrator for principle-based decision
3. **Attempt 3:** Orchestrator escalates to User with both positions

**Example:**
```
Dev-A: "Use approach X"
QA-A: "Approach X is not testable, use Y"
Dev-A: "Approach Y is too complex"
[Deadlock]

Orchestrator: "Deadlock detected. Invoking brainstorming skill..."
[Systematic analysis]
Result: "Approach Y with simplified interface - testable AND simple"

Dev-A + QA-A: Both sign off on compromise
```

---

## 6. Implementation Guide

### 6.1 Changes Required

**Priority 1: System-Comps (Week 1)**
- Create: `shared/4eyes_principle.md`
- Create: `role-specific/orchestrator_decision_authority.md`
- Update: `prompts.yaml` to include new comps for all roles

**Priority 2: Message Protocol (Week 1)**
- Add message types: `SignOffRequest`, `SignOffApproval`, `SignOffRejection`
- Update message board structure
- Create message templates in `tools/message_templates/`

**Priority 3: Quality Gates Integration (Week 2)**
- Update gate advancement scripts to require dual sign-off
- Modify `scripts/quality-gates/gates-pass.sh` to check for sign-offs
- Add sign-off tracking to `.git/quality-gates/<feature>/signoffs.json`

**Priority 4: Git Hooks (Week 2)**
- Update pre-commit hooks to verify sign-off exists
- Block commits without required approvals
- Add sign-off verification to pre-push hook

**Priority 5: Testing (Week 3)**
- Unit tests for sign-off protocol
- Integration tests for escalation workflow
- Smoke test with 4-eyes enforcement

### 6.2 File Structure Additions

```
system-comps/
  shared/
    4eyes_principle.md               # NEW - Core 4-eyes protocol
    decision_escalation.md           # NEW - Escalation criteria

  role-specific/
    orchestrator_decision_authority.md  # NEW - Authority matrix
    dev_signoff_requirements.md      # NEW - What Dev must get signed off
    qa_signoff_requirements.md       # NEW - What QA must get signed off
    docs_signoff_requirements.md     # NEW - What Docs must get signed off

tools/
  message_templates/
    SignOffRequest.md                # NEW - Template
    SignOffApproval.md               # NEW - Template
    SignOffRejection.md              # NEW - Template
    CriticalDecisionRequest.md       # NEW - Template (from previous discussion)
    DecisionAnnouncement.md          # NEW - Template (from previous discussion)

.git/
  quality-gates/
    <feature>/
      signoffs.json                  # NEW - Track who signed off on what
      decisions.json                 # NEW - Track Orchestrator decisions

scripts/
  quality-gates/
    gates-check-signoffs.sh          # NEW - Verify sign-offs before advancement

docs/
  feature/
    <feature>/
      decisions.md                   # NEW - Decision log with sign-offs
```

### 6.3 Backward Compatibility

**This is a breaking change** - all existing workflows must be updated.

**Migration path:**
1. Implement message types first (non-breaking)
2. Update system-comps (all instances get new prompts)
3. Enable sign-off checking in quality gates (enforced)
4. Update git hooks to require sign-offs (enforced)

**Timeline:** 3 weeks for full implementation

---

## 7. System-Comps Additions

### 7.1 File: `shared/4eyes_principle.md`

```markdown
# 4-Eyes Principle (Dual Sign-Off Requirement)

## Foundational Rule

**NO DECISION IS VALID WITHOUT SIGN-OFF FROM AT LEAST TWO INDEPENDENT ROLES.**

This is non-negotiable. It applies to:
- Code changes
- Specifications
- Architecture decisions
- Quality gate advancement
- Documentation updates
- Test strategies
- Merge operations

## Why This Matters

Single-role decisions create single points of failure:
- Missed edge cases
- Incorrect assumptions
- Quality shortcuts
- Scope creep
- Technical debt accumulation

Dual sign-off provides:
- Peer review at every step
- Error catching before propagation
- Shared understanding
- Quality enforcement
- Knowledge distribution

## Your Responsibilities

**Before you can proceed with ANY significant work:**
1. Complete your work
2. Self-review against checklist
3. Send SignOffRequest to appropriate reviewer
4. Wait for SignOffApproval
5. Only then proceed with commit/gate advancement

**When you receive a SignOffRequest:**
1. Review thoroughly (not rubber-stamp)
2. Test claims (run tests, verify coverage)
3. Check against quality gates
4. Provide specific feedback
5. Approve only if genuinely ready

**Never:**
- Skip sign-off to "move faster"
- Rubber-stamp without real review
- Approve your own work
- Bypass for "small changes" (all changes need sign-off)

## Sign-Off Protocol

### Requesting Sign-Off

Send `SignOffRequest` message with:
- What you did
- Files changed
- Tests run
- Self-review checklist
- What you want reviewer to focus on

### Reviewing Sign-Off Request

Spend time proportional to risk:
- Critical path code: 30+ min review
- Tests: 15+ min review
- Documentation: 10+ min review

Provide:
- `SignOffApproval` if ready
- `SignOffRejection` with specific issues if not ready

### Escalating Disagreements

If you and reviewer cannot agree:
1. Try to understand their concern
2. Explain your reasoning
3. If still stuck: Escalate to Orchestrator
4. Orchestrator may invoke brainstorming or escalate to User

## Emergency Exception

Only Orchestrator can authorize emergency single sign-off:
- Production down
- Security breach
- Data loss imminent

Even then:
- Document as technical debt
- Retrospective review within 24 hours
- User notified immediately
```

### 7.2 File: `role-specific/orchestrator_decision_authority.md`

```markdown
# Orchestrator Decision Authority and Escalation Protocol

## Your Authority as Orchestrator

You coordinate all roles and have decision-making authority, **but you are bound by the 4-Eyes Principle.**

### Autonomous Decisions (You + One Role Sign-Off)

You can decide WITHOUT user escalation for:

**Technical Implementation Details**
- Data structure choice
- Code organization
- Refactoring approach
- Tool/skill selection

**Process:**
1. Analyze using documented principles (pragmatist, TDD, quality gates)
2. Get sign-off from relevant role (Dev, QA, Architect, etc.)
3. Send `DecisionAnnouncement` to all roles
4. Document in `docs/feature/<feature>/decisions.md`
5. Proceed immediately

**Example:**
```
Dev-A: "Use dictionary or set for lookup?"
You: Apply pragmatist principles → Set is simpler, sufficient
You: Get QA-A sign-off (testability confirmed)
You: Announce decision to all roles
You: Proceed
```

### Critical Path Escalations (You + 2 Roles + User)

You MUST escalate to user for:

**Architecture Decisions**
- Microservices vs monolith
- Database selection
- Framework additions
- Major library dependencies

**Scope Changes**
- Effort increase >20%
- Timeline extension >50%
- Feature requirement changes

**Quality Exceptions**
- Skip TDD enforcement
- Bypass quality gates
- Reduce test coverage below standard
- Emergency deployments

**Process:**
1. Coordinate with relevant roles (Architect, Planner, Dev, QA)
2. Collect sign-offs from 2+ roles
3. Send `CriticalDecisionRequest` to User with:
   - Both/all positions
   - Pros/cons of each
   - Your recommendation
   - Quality gate impact
4. Wait for User decision
5. Send `DecisionAnnouncement` to all roles
6. Document in ADR if architectural
7. Proceed with approved approach

## Decision Criteria: "Is This Critical Path?"

Ask yourself:
- Does this affect long-term architecture? → YES = Critical
- Does this change scope significantly? → YES = Critical
- Does this violate quality standards? → YES = Critical
- Does this add external dependencies? → YES = Critical
- Would reversing this later be expensive? → YES = Critical

If ANY answer is YES → Escalate to User

## Deadlock Resolution

When two roles cannot agree:

**Level 1:** Invoke `/superpowers:brainstorming`
- Systematic exploration
- Socratic questioning
- Find compromise

**Level 2:** You decide based on principles
- Apply documented standards
- Get sign-off from third role
- Announce decision

**Level 3:** Escalate to User
- Present both positions objectively
- Provide recommendation
- User decides

## Emergency Bypass Authority

You are the ONLY role that can authorize emergency single sign-off.

**Criteria:**
- Production down
- Security breach
- Data loss imminent

**Process:**
1. Assess: Is this truly an emergency?
2. Authorize temporary single sign-off
3. Document as technical debt immediately
4. Notify User of emergency action
5. Schedule retrospective review within 24 hours
6. Ensure proper sign-off happens post-emergency

**Never abuse this.** Emergency bypass should be <1% of decisions.
```

### 7.3 File: `role-specific/dev_signoff_requirements.md`

```markdown
# Dev Sign-Off Requirements

## What You Must Get Signed Off Before Committing

**ALL code changes** require sign-off from QA or another Dev.

### Before Requesting Sign-Off

**Self-review checklist:**
- [ ] Tests written BEFORE implementation (TDD)
- [ ] All tests passing
- [ ] Code follows project conventions
- [ ] No TODOs in production code
- [ ] No debug statements (console.log, print, etc.)
- [ ] Documentation updated (DocIntent sent to Docs)
- [ ] Linting passes (ruff, mypy, eslint)
- [ ] No security vulnerabilities introduced

### Sign-Off Request Process

**Step 1:** Send `SignOffRequest` to QA or peer Dev
- Include: Files changed, tests run, coverage percentage
- Attach: Self-review checklist (all checked)
- Specify: What you want reviewer to focus on

**Step 2:** Wait for response
- DO NOT commit while waiting
- Use time for other tasks
- Check inbox for `SignOffApproval` or `SignOffRejection`

**Step 3:** If approved
- Request write lock from Orchestrator
- Commit with descriptive message
- Include sign-off reference in commit message:
  ```
  feat: add idempotency store (Gate 3)

  Signed-off-by: QA-A
  Reviewed-at: 2025-11-16T21:00:00Z
  ```

**Step 4:** If rejected
- Address all critical issues listed
- Re-run tests
- Send new `SignOffRequest` with changes documented

### Who Signs Off on What

| **Your Work** | **Sign-Off From** | **Validates** |
|---------------|-------------------|---------------|
| Backend code | QA-A or Dev-B | Correctness, tests, spec compliance |
| Frontend code | QA-B or Dev-A | UI/UX, tests, accessibility |
| Test code | QA | Test design, coverage, edge cases |
| Refactoring | QA + Architect | Maintains functionality, improves structure |
| Performance optimization | QA | Actually faster, no regressions |

### Red Flags (Auto-Reject)

QA will reject sign-off if:
- Tests not written before implementation
- Tests not passing
- Coverage below 80%
- TODOs in production code
- Missing documentation updates
- Linting failures
- Security issues (SQL injection, XSS, etc.)

### Time Expectations

**Your reviewer should respond within:**
- Critical path work: 30 minutes
- Normal work: 2 hours
- Non-urgent work: 4 hours

**If no response:** Escalate to Orchestrator

**You should complete sign-off fixes within:**
- Critical issues: 1 hour
- Normal issues: 4 hours
```

### 7.4 File: `role-specific/qa_signoff_requirements.md`

```markdown
# QA Sign-Off Requirements

## What You Must Get Signed Off

**ALL test strategies and QA validations** require sign-off from Dev or peer QA.

### Before Requesting Sign-Off

**Self-review checklist:**
- [ ] Test design covers all success criteria from spec
- [ ] Edge cases identified and tested
- [ ] Error cases tested (not just happy path)
- [ ] Test data representative
- [ ] Tests are deterministic (no flakiness)
- [ ] Coverage measured and documented
- [ ] Performance tested if relevant
- [ ] Security tested if relevant (auth, input validation)

### Sign-Off Request Process

**Step 1:** Send `SignOffRequest` to Dev or peer QA
- Include: Test plan, coverage report, test results
- Attach: Self-review checklist
- Specify: Areas of concern or complexity

**Step 2:** Wait for response
- Dev should confirm tests are implementable
- Dev should verify coverage is meaningful
- Peer QA should check test design quality

**Step 3:** If approved
- Proceed with test execution
- Document results in `QAResult` message to Orchestrator
- Update quality gate tracking

**Step 4:** If rejected
- Revise test strategy
- Add missing edge cases
- Re-submit for sign-off

### Who Signs Off on What

| **Your Work** | **Sign-Off From** | **Validates** |
|---------------|-------------------|---------------|
| Test strategy | Dev | Implementable, sufficient coverage |
| Test results | Dev + Orchestrator | Interpretation correct, ready for gate advancement |
| E2E verification | Dev + Docs | Comprehensive, docs match behavior |
| Performance tests | Dev + Architect | Methodology sound, metrics meaningful |

### Validation Criteria

**When reviewing Dev's code for sign-off, check:**
- [ ] Tests exist and were committed BEFORE implementation
- [ ] All tests passing (no skipped tests)
- [ ] Coverage ≥80% for new code
- [ ] Edge cases covered
- [ ] Error handling tested
- [ ] No test-only methods in production code
- [ ] Documentation updated
- [ ] No TODOs or debug statements

**Sign-Off Approval Criteria:**
- ALL items above checked
- You ran tests yourself (don't trust Dev's report)
- You reviewed code for quality issues
- You verified spec compliance

**Sign-Off Rejection Triggers:**
- Any test failures
- Coverage <80%
- Missing edge case tests
- Spec requirements not met
- Code quality concerns

### Time Expectations

**Review Dev's code within:**
- Gate 2 (Tests First): 15 minutes (just verify tests)
- Gate 3 (Implementation): 30 minutes (verify tests + code)
- Gate 6 (E2E): 1 hour (comprehensive validation)

**Your test strategy should be reviewed within:**
- 30 minutes for routine tests
- 1 hour for complex test scenarios
```

### 7.5 File: `role-specific/docs_signoff_requirements.md`

```markdown
# Docs Sign-Off Requirements

## What You Must Get Signed Off

**ALL documentation updates** require dual sign-off:
1. Librarian (accuracy, completeness)
2. Dev or QA (technical correctness)

### Before Requesting Sign-Off

**Self-review checklist:**
- [ ] All DocIntent messages addressed
- [ ] Per-file docs updated for changed files
- [ ] Feature changelog updated
- [ ] ADRs created for architecture decisions
- [ ] Code examples tested (actually work)
- [ ] Links verified (no 404s)
- [ ] Terminology consistent with existing docs
- [ ] Markdown formatting correct

### Sign-Off Request Process

**Step 1:** Send `SignOffRequest` to Librarian
- Include: List of docs updated, summary of changes
- Attach: Self-review checklist
- Reference: DocIntent messages that triggered updates

**Step 2:** Send second `SignOffRequest` to Dev or QA
- Focus: Technical accuracy of code examples, API descriptions
- Ask: "Is this how the code actually works?"

**Step 3:** Wait for both approvals
- Need BOTH Librarian AND (Dev OR QA) sign-off
- Address any rejections before proceeding

**Step 4:** After both approvals
- Run doc hooks (markdown_backup, serena_index_refresh)
- Send `DocsUpdated` to Orchestrator
- Orchestrator can now trigger auto-commit hook

### Who Signs Off on What

| **Your Work** | **Sign-Off From** | **Validates** |
|---------------|-------------------|---------------|
| Per-file docs | Librarian + Dev | Accuracy, completeness, technical correctness |
| Feature changelog | Librarian + (Dev or QA) | Complete record, accurate |
| ADRs | Librarian + Architect | Format correct, decision accurately captured |
| API documentation | Librarian + Dev | Matches actual API behavior |
| User guides | Librarian + QA | Usable, accurate, tested procedures |

### Validation Criteria

**Librarian checks:**
- [ ] Completeness (all files documented)
- [ ] Accuracy (matches DocIntent)
- [ ] Consistency (terminology, style)
- [ ] Searchability (good headings, structure)
- [ ] Markdown quality (proper formatting)

**Dev/QA checks:**
- [ ] Technical correctness (code examples work)
- [ ] API descriptions accurate
- [ ] Behavior matches actual implementation
- [ ] Security notes accurate
- [ ] Performance claims realistic

**Both approve only if:**
- Documentation is production-ready
- New developers could understand from these docs
- No misleading or incorrect information

### Red Flags (Auto-Reject)

Documentation rejected if:
- Code examples don't run
- API signatures wrong
- Missing critical files
- Contradicts existing docs
- Security information incorrect
- Links broken

### Time Expectations

**Librarian should review within:**
- 30 minutes for routine updates
- 1 hour for comprehensive new docs

**Dev/QA should review within:**
- 15 minutes for simple changes
- 30 minutes for complex technical docs
```

---

## 8. Examples and Workflows

### 8.1 Example: Code Implementation with 4-Eyes

**Scenario:** Dev-A implements idempotency store (Gate 3)

```
[Dev-A completes implementation]

Dev-A → QA-A: SignOffRequest
  "Implemented IdempotencyStore class
   Files: backend/services/idempotency_store.py
   Tests: All 12 tests passing
   Coverage: 95%
   Self-review: ✓ All items checked"

[QA-A reviews]
- Runs tests locally (confirms passing)
- Reviews code for quality issues
- Checks coverage report (95% confirmed)
- Verifies spec compliance

QA-A → Dev-A: SignOffApproval
  "✅ Approved
   - Tests comprehensive
   - Code quality good
   - Spec requirements met
   - Minor suggestion: Extract magic number 3600 to constant"

Dev-A → Orchestrator: WriteRequest
  "Need write lock to commit implementation"

Orchestrator → Dev-A: WriteLockGrant
  "Lock granted, timeout 5 minutes"

Dev-A: git commit -m "feat: implement idempotency store (Gate 3)

Implements Redis-backed idempotency checking with 1-hour TTL.
All 12 tests passing, 95% coverage.

Signed-off-by: QA-A
Reviewed-at: 2025-11-16T21:15:00Z"

Dev-A → Orchestrator: WriteComplete
  "Commit successful - SHA abc123"

Orchestrator: [Releases lock]

Dev-A → Orchestrator: GateAdvanceRequest
  "Gate 3 requirements met, requesting advancement"

Orchestrator → QA-A: "Confirm Gate 3 completion?"

QA-A → Orchestrator: "Confirmed - all tests passing, implementation complete"

Orchestrator: [Advances to Gate 3 PASSED]
Orchestrator → All Roles: GateStatusUpdate
  "Feature: order_idempotency
   Gate 3: PASSED
   Current Gate: 4 (Refactored)"

[Orchestrator automatically triggers /pragmatist skill for Gate 4]
```

### 8.2 Example: Architecture Decision with Escalation

**Scenario:** Architect proposes microservice architecture

```
User: "Add payment processing to the system"

Orchestrator → Librarian: ContextRequest
  "Payment processing requirements"

Librarian → Orchestrator: ContextPack
  "Existing architecture: monolith
   Current payment volume: 100/day
   Projected growth: 1000/day in 6 months"

Orchestrator → Planner: PlanRequest
  "Payment processing feature"

Planner → Architect: SignOffRequest
  "Created spec for payment processing
   Proposed approach: Add to existing monolith
   Reasoning: Volume doesn't justify microservice complexity"

Architect reviews, disagrees:

Architect → Planner: SignOffRejection
  "Payment processing should be separate microservice:
   - PCI compliance isolation
   - Independent scaling
   - Team separation

   Critical issue: Monolith approach risks compliance violations"

[Deadlock: Planner vs Architect]

Orchestrator detects disagreement

Orchestrator: Invoke /superpowers:brainstorming
[Socratic exploration]
Result: "Both approaches valid, depends on compliance requirements"

Orchestrator → Architect: "Sign off on assessment that this is critical path decision?"

Architect → Orchestrator: SignOffApproval
  "Yes, this is architecture decision with compliance implications"

Orchestrator → Planner: "Sign off on escalation to user?"

Planner → Orchestrator: SignOffApproval
  "Yes, agree this needs user decision"

Orchestrator → User: CriticalDecisionRequest
  "Payment Processing Architecture Decision

   Position A (Planner): Monolith Integration
   - Pros: Simpler, faster to implement (2 weeks)
   - Cons: Compliance complexity, coupled scaling

   Position B (Architect): Microservice
   - Pros: PCI compliance isolation, independent scaling
   - Cons: Added complexity, longer implementation (4 weeks)

   Quality Gate Impact: Affects Gate 5 (Integration) significantly

   Orchestrator Recommendation: Position B (microservice)
   Reasoning: PCI compliance isolation is critical, cost of violations high

   Your decision?"

User: "Go with microservice (Position B). Compliance is non-negotiable."

Orchestrator → All Roles: DecisionAnnouncement
  "Payment processing will be implemented as separate microservice
   Decision: User-approved (critical path)
   Signed off by: Architect + Planner + User
   Documented in: docs/adr/0005-payment-microservice.md"

Architect → Docs: DocIntent
  "Create ADR for payment microservice decision"

Docs creates ADR

Docs → Librarian: SignOffRequest
  "Created ADR-0005
   Captured: Decision, rationale, alternatives, compliance reasoning"

Librarian → Docs: SignOffApproval
  "✅ ADR accurate and complete"

Docs → Architect: SignOffRequest
  "ADR-0005 ready for technical sign-off"

Architect → Docs: SignOffApproval
  "✅ Technical accuracy confirmed"

Docs → Orchestrator: DocsUpdated
  "ADR-0005 created, dual sign-off received"

Orchestrator → Planner: "Proceed with microservice planning"
```

### 8.3 Example: Emergency Bypass

**Scenario:** Production security vulnerability

```
[Production monitoring detects active exploit]

User → Orchestrator: "EMERGENCY: SQL injection vulnerability being exploited in production"

Orchestrator → Dev-A: "Critical security patch needed immediately"

Dev-A: [Creates patch in 10 minutes]

Dev-A → Orchestrator: "Patch ready, but no time for normal sign-off process"

Orchestrator evaluates:
- Production down? → YES
- Security breach? → YES
- Data loss imminent? → YES
- Emergency criteria met? → YES

Orchestrator → User: "Authorizing emergency bypass of 4-eyes principle
                      Single sign-off deployment for security patch
                      Retrospective review scheduled for 24 hours"

User → Orchestrator: "Approved. Deploy immediately."

Orchestrator → Dev-A: WriteLockGrant (emergency)
  "Emergency bypass authorized
   Deploy immediately
   Technical debt ticket created: TD-001"

Dev-A: git commit -m "SECURITY HOTFIX: Patch SQL injection vulnerability

EMERGENCY BYPASS - Single sign-off deployment
Retrospective review required within 24 hours
Tracking: TD-001

Signed-off-by: Orchestrator (emergency authority)
Deployed-at: 2025-11-16T22:00:00Z"

Dev-A: [Deploys to production]

Orchestrator → All Roles: "Emergency deployment completed
                           Technical debt: TD-001
                           Retrospective review: 2025-11-17T22:00:00Z"

[24 hours later]

Orchestrator → QA-A + Dev-B: "Retrospective review of emergency security patch required"

QA-A → Dev-A: SignOffRequest (retrospective)
  "Review emergency SQL injection patch"

QA-A reviews patch:

QA-A → Dev-A: SignOffApproval
  "✅ Patch is correct, no issues found
   Recommendation: Add regression test"

Dev-B → Dev-A: SignOffRequest (peer review)
  "Second review of security patch"

Dev-B → Dev-A: SignOffApproval
  "✅ Code quality acceptable
   Suggestion: Extract to prepared statement helper"

Orchestrator: [Marks TD-001 as complete]
Orchestrator: [Documents lessons learned]
```

---

## 9. Implementation Timeline

### Week 1: System-Comps and Message Protocol
**Deliverables:**
- Create 5 new system-comp files (4eyes_principle, decision_authority, dev/qa/docs_signoff_requirements)
- Update prompts.yaml for all 9 roles
- Create message templates (SignOffRequest, SignOffApproval, SignOffRejection)
- Update message board structure

**Validation:**
- All prompts assemble correctly
- Message templates complete
- No syntax errors

### Week 2: Quality Gates and Git Hooks Integration
**Deliverables:**
- Update quality-gates scripts to track sign-offs
- Create signoffs.json tracking file
- Modify pre-commit hooks to verify sign-offs
- Modify pre-push hooks to check sign-off chain

**Validation:**
- Hooks block commits without sign-offs
- Sign-off tracking works correctly
- Gate advancement requires dual approval

### Week 3: Testing and Documentation
**Deliverables:**
- Unit tests for sign-off protocol
- Integration tests for escalation workflow
- Update manual validation checklist
- Create team training documentation

**Validation:**
- All tests pass
- Smoke test with 4-eyes enforcement works end-to-end
- Manual checklist updated

---

## 10. Team Implementation Instructions

### Step 1: Review This Document (30 minutes)

**Action:** All team members read this addendum completely

**Understanding check:**
- What is the 4-eyes principle?
- When can Orchestrator decide autonomously?
- When must decisions escalate to user?
- What happens in emergencies?

### Step 2: Update Local Environment (1 hour)

**Action:** Pull latest changes after implementation complete

```bash
# Pull updated system-comps
git pull origin main

# Verify new message types exist
ls tools/message_templates/

# Check quality-gates scripts updated
./scripts/quality-gates/gates-check.sh --help

# Verify hooks installed
ls -la .git/hooks/
```

### Step 3: Practice Sign-Off Workflow (2 hours)

**Action:** Run practice scenario with team

**Practice Exercise:**
1. Dev creates simple feature (e.g., add a utility function)
2. Dev sends SignOffRequest to QA
3. QA reviews and sends SignOffApproval
4. Dev commits with sign-off reference
5. Verify commit succeeded with proper sign-off trail

**Success criteria:**
- All team members can send/receive sign-off messages
- Understand approval vs rejection process
- Know how to document sign-offs

### Step 4: Implement First Real Feature (1 week)

**Action:** Execute full feature with 4-eyes enforcement

**Checkpoints:**
- [ ] Spec created (Planner) + signed off (Architect)
- [ ] Tests written (Dev) + signed off (QA)
- [ ] Implementation (Dev) + signed off (QA)
- [ ] Refactored (Dev) + signed off (QA + Architect)
- [ ] Documentation (Docs) + signed off (Librarian + Dev)
- [ ] All gates advanced with dual approvals
- [ ] Merge to main with complete sign-off chain

**Retrospective after first feature:**
- What worked well?
- What was confusing?
- Where did we have delays?
- How can we improve sign-off turnaround time?

### Step 5: Continuous Improvement

**Monthly review:**
- Sign-off turnaround times
- Emergency bypass frequency (should be <1%)
- User escalation frequency
- Deadlock resolution effectiveness

**Adjust as needed:**
- Update sign-off checklists
- Refine escalation criteria
- Improve message templates

---

## 11. Success Criteria

### This addendum is successfully implemented when:

✅ **No commits** reach main without dual sign-off trail
✅ **Git hooks** automatically enforce sign-off requirements
✅ **Quality gates** cannot advance without required approvals
✅ **Orchestrator** correctly identifies critical path decisions
✅ **User escalations** happen for architecture/scope/quality exceptions
✅ **Emergency bypasses** are <1% of total decisions
✅ **Sign-off turnaround** averages <2 hours for normal work
✅ **All roles** understand their sign-off responsibilities
✅ **Decision trail** is documented in every feature

---

## 12. Appendix: Quick Reference

### Sign-Off Decision Tree

```
Do I need to commit/merge/advance gate?
        ↓
    YES → Send SignOffRequest to reviewer
        ↓
    Wait for SignOffApproval
        ↓
    Approved? → Request write lock → Commit with sign-off reference
    Rejected? → Fix issues → Re-submit SignOffRequest
```

### Escalation Decision Tree (For Orchestrator)

```
Decision needed
        ↓
Can I decide using documented principles + one role sign-off?
    YES → Decide, announce, document, proceed
        ↓
    NO → Is this critical path?
        ↓
    YES → Get sign-offs from 2 roles → Escalate to User
    NO → Invoke brainstorming → Re-evaluate
```

### Message Type Quick Reference

| **Message** | **From** | **To** | **Purpose** |
|-------------|----------|--------|-------------|
| SignOffRequest | Any role | Reviewer | Request approval for work |
| SignOffApproval | Reviewer | Requester | Approve work, allow proceed |
| SignOffRejection | Reviewer | Requester | Reject work, require fixes |
| CriticalDecisionRequest | Orchestrator | User | Escalate critical decision |
| DecisionAnnouncement | Orchestrator | All roles | Announce decision, end debate |
| GateAdvanceRequest | Any role | Orchestrator | Request quality gate advancement |
| WriteRequest | Any role | Orchestrator | Request write lock |
| WriteLockGrant | Orchestrator | Requester | Grant write permission |

---

**Document Status:** Ready for Implementation
**Implementation Priority:** CRITICAL
**Estimated Implementation Time:** 3 weeks
**Team Review Required:** YES
**User Approval Required:** YES (this is a critical path decision!)

---

**Addendum Prepared By:** Orchestrator Analysis
**Date:** 2025-11-16
**Requires Sign-Off From:** User (final authority on process changes)
**Next Step:** User approval to begin implementation
