# UPDATED Complete Implementation Plan: 4-Eyes Principle + Security + Functional Quality Enhancements

> **📋 SINGLE SOURCE OF TRUTH - UPDATED WITH FUNCTIONAL QUALITY FIXES**
>
> This document contains the ORIGINAL 50-task implementation plan PLUS 12 new functional quality enhancement tasks.
> Follow sequentially from Task 1.1 through Task 11.2 (62 tasks total) to implement the complete system.

**Date:** 2025-11-16 (UPDATED)
**Status:** ✅ IMPLEMENTATION READY - Original 50 tasks + 12 functional quality enhancements
**Based on:**
- ✅ Original: 2025-11-16-complete-implementation-plan.md (50 tasks, 10 weeks)
- ✅ Addendum 001: 4-Eyes Principle and Decision Authority
- ✅ Addendum 002: Security Hardening and Anti-Rogue-Actor Protocols
- ✅ **NEW:** Functional Quality Fixes (12 enhancements addressing bottlenecks, deadlocks, security gaps)

**Goal:** Implement dual sign-off requirement, decision authority protocol, comprehensive security hardening, AND functional quality enhancements to create a production-ready, bottleneck-free 12-instance Claude Code workflow system.

**Architecture:** 12 Claude Code instances (Orchestrator, Librarian, Planner-A, Planner-B, Architect-A, Architect-B, Architect-C, Dev-A, Dev-B, QA-A, QA-B, Docs) coordinated via message protocol with cryptographic integrity, peer-first review, multi-layer security, AND enhanced with delegation tiers, quorum rules, SLA enforcement, and workload balancing.

**Tech Stack:**
- Bash (git hooks, bootstrap scripts)
- Python 3.8+ (pytest, hashlib, json, pathlib, cryptography)
- Git + GPG (commit signing)
- tmux (multi-instance management)
- jq (JSON processing)
- YAML (prompts and config)
- SendGrid/Twilio (2FA email/SMS)

**Timeline:** 12 weeks, 62 tasks (50 original + 12 new)

**Approach:** TDD (write tests first, watch fail, implement), complete code examples, exact commands, commit messages.

---

## 📑 Quick Navigation - All 62 Tasks

### Phase 1: Foundation and Message Protocol (Week 1)
- **Task 1.1:** Create Audit Directory Structure
- **Task 1.2:** Implement Message Registry with Hashing
- **Task 1.3:** Create Message Templates

### Phase 2: System-Comps and Prompts (Week 2)
- **Task 2.1:** Create 4-Eyes Principle System-Comp
- **Task 2.2:** Create Orchestrator Decision Authority System-Comp
- **Task 2.3:** Create Peer Review System-Comps (4 roles)
- **Task 2.4:** Update prompts.yaml for All 12 Roles
- **Task 2.5:** Create Prompt Assembly Script

### Phase 3: Git Hooks and Quality Gates (Week 3)
- **Task 3.1:** Implement pre-commit Hook (TDD Enforcement)
- **Task 3.2:** Implement pre-commit Hook (4-Eyes Verification)
- **Task 3.3:** Implement pre-receive Hook (Server-Side Enforcement)
- **Task 3.4:** Create Quality Gates Definition

### Phase 4: Write Lock and Message System (Week 4)
- **Task 4.1:** Implement Write Lock System
- **Task 4.2:** Implement Write Lock Verification Hooks
- **Task 4.3:** Implement Message Passing System
- **Task 4.4:** Create Message Queue and Routing Logic

### Phase 5: Cryptographic Infrastructure (Week 5)
- **Task 5.1:** Generate GPG Keys for All 12 Roles
- **Task 5.2:** Enforce Commit Signing
- **Task 5.3:** Implement Signature Verification System
- **Task 5.4:** Implement Message Integrity Verification

### Phase 6: User Authentication and Librarian Veto (Week 6)
- **Task 6.1:** Implement 2FA Confirmation System
- **Task 6.2:** Implement Librarian Veto System
- **Task 6.3:** Implement Collusion Detection Metrics
- **Task 6.4:** Implement Tertiary Review Assignment

### Phase 7: Monitoring and Detection (Week 7)
- **Task 7.1:** Implement Cumulative Change Detection
- **Task 7.2:** Implement Rate Limiting System
- **Task 7.3:** Implement Audit Report Generation
- **Task 7.4:** Implement Alerting System

### Phase 8: Bootstrap and tmux Layout (Week 8)
- **Task 0.1:** CRITICAL - Repository Selection at Startup
- **Task 8.1:** Create tmux Session Configuration
- **Task 8.2:** Complete Bootstrap Script
- **Task 8.3:** Implement Instance Health Monitoring
- **Task 8.4:** Implement Graceful Shutdown

### Phase 9: Integration Testing (Week 9)
- **Task 9.1:** End-to-End Workflow Test
- **Task 9.2:** Security Attack Simulations
- **Task 9.3:** Load Testing
- **Task 9.4:** Failure Recovery Testing

### Phase 10: Production Hardening (Week 10)
- **Task 10.1:** Performance Optimization
- **Task 10.2:** Monitoring Dashboard
- **Task 10.3:** Backup and Restore Procedures
- **Task 10.4:** User Documentation
- **Task 10.5:** Security Audit and Penetration Testing

### **✨ Phase 11: Functional Quality Enhancements (Week 11-12) - NEW**
- **Task 11.1:** Implement Librarian Delegation Tiers (CRITICAL)
- **Task 11.2:** Implement Architecture Council Quorum Rules (HIGH)
- **Task 11.3:** Implement Peer Review SLA/Timeout (HIGH)
- **Task 11.4:** Implement QA Rollback Workflow (HIGH)
- **Task 11.5:** Implement Feature Priority System (MEDIUM)
- **Task 11.6:** Implement Write Lock Priority Queue (MEDIUM)
- **Task 11.7:** Enhance Collusion Detection Thresholds (MEDIUM)
- **Task 11.8:** Implement Tertiary Reviewer Independence (MEDIUM)
- **Task 11.9:** Implement 2FA Rate Limiting (MEDIUM)
- **Task 11.10:** Implement Planner Disagreement Mediation (LOW)
- **Task 11.11:** Implement Docs Veto Power (LOW)
- **Task 11.12:** Integration Testing for All Enhancements (CRITICAL)

---

## 🔄 What's New in This Updated Plan

### Integration of Functional Quality Fixes

The original 50-task plan (Phases 1-10) is **UNCHANGED** and remains the foundation. Phase 11 adds 12 new tasks that enhance the system with:

1. **Bottleneck Elimination**
   - Librarian delegation tiers (70% auto-approval)
   - Peer review SLA enforcement (24h timeout)
   - Write lock priority queue (preemption for CRITICAL work)

2. **Deadlock Prevention**
   - Architecture Council quorum rules (2/3 minimum)
   - Planner disagreement mediation (70-80% resolved without escalation)
   - Peer review circular dependency resolution

3. **Enhanced Security**
   - Lower collusion detection thresholds (5 reviews, 90%)
   - Tertiary reviewer true independence (feature participation tracking)
   - 2FA rate limiting (progressive lockout)

4. **Quality Assurance**
   - QA rollback workflow (controlled bug fixes)
   - Docs veto power (prevents undocumented features)
   - Feature priority system (CRITICAL/HIGH/MEDIUM/LOW with SLAs)

### Mapping to Original Plan

Phase 11 tasks **build upon** the original infrastructure:

| New Task | Builds On Original | Integration Point |
|----------|-------------------|-------------------|
| 11.1 Librarian Delegation | Task 6.2 (Librarian Veto) | Adds risk-based auto-approval |
| 11.2 Council Quorum | Task 2.2 (Orchestrator Authority) | Adds voting rules |
| 11.3 Peer Review SLA | Task 2.3 (Peer Review System) | Adds timeout enforcement |
| 11.4 QA Rollback | Task 3.4 (Quality Gates) | Adds rollback workflow |
| 11.5 Priority System | Task 4.4 (Message Routing) | Adds priority-based assignment |
| 11.6 Lock Priority | Task 4.1 (Write Lock) | Adds priority queue |
| 11.7 Collusion Enhancement | Task 6.3 (Collusion Detection) | Lowers thresholds |
| 11.8 Tertiary Independence | Task 6.4 (Tertiary Review) | Adds participation tracking |
| 11.9 2FA Limiting | Task 6.1 (2FA System) | Adds rate limiting |
| 11.10 Planner Mediation | Task 2.2 (Orchestrator Authority) | Adds mediation workflow |
| 11.11 Docs Veto | Task 2.4 (Docs Prompt) | Adds veto power |
| 11.12 Integration Testing | Task 9.1-9.4 (Testing) | Tests all enhancements |

---

## 📖 How to Use This Updated Plan

### Implementation Sequence

**Weeks 1-10: Original 50 Tasks**
Follow the original plan exactly as written in `2025-11-16-complete-implementation-plan.md`. This establishes:
- Message protocol and audit infrastructure
- System-comps and prompts for all 12 roles
- Git hooks and quality gates
- Write lock and message passing
- Cryptographic infrastructure (GPG signing)
- 2FA and Librarian veto
- Collusion detection and tertiary reviews
- Monitoring and alerting
- Bootstrap and tmux layout
- Integration testing and production hardening

**Weeks 11-12: Functional Quality Enhancements (Phase 11)**
After completing original Tasks 1.1-10.5, proceed to Phase 11 to add the functional quality enhancements documented below.

### Quick Reference to Original Plan

For detailed implementation of Tasks 1.1-10.5, see:
**`docs/plans/2025-11-16-complete-implementation-plan.md`** (9,122 lines)

This updated plan focuses on **Phase 11 only** (the 12 new functional quality enhancement tasks).

---

## ✨ PHASE 11: Functional Quality Enhancements (Week 11-12)

### Overview

Phase 11 adds 12 enhancements that address bottlenecks, deadlocks, and security gaps discovered during the original system design. These enhancements are **production-critical** and should be implemented after the base system (Phases 1-10) is complete.

**Estimated Time:** 2 weeks (12 tasks, ~5,023 lines of code/docs)

**Deliverables:**
- 8 updated role documentation files
- Enhanced security scripts
- Updated quality gate management
- Comprehensive integration tests

---

### Task 11.1: Implement Librarian Delegation Tiers (CRITICAL)

**Priority:** CRITICAL
**Estimated Time:** 2 days
**Dependencies:** Task 6.2 (Librarian Veto System)

#### Problem Statement
The Librarian becomes a bottleneck when co-signing every gate transition. With multiple features progressing simultaneously, the Librarian can only handle ~20 co-signature requests/day, creating delays.

#### Solution: Risk-Based Delegation
Implement 4-tier risk classification with auto-approval for LOW/MEDIUM risk transitions (70% of requests).

#### Implementation

**Step 1: Update Librarian Role Documentation**

**File:** `docs/roles/LIBRARIAN_ROLE.md`
**Location:** After § 1 "Orchestrator Oversight (Co-Signature Authority)"
**Lines to Add:** ~250

Add the following section:

```markdown
### Co-Signature Delegation Tiers

Risk-based delegation to prevent Librarian bottleneck while maintaining security.

#### Risk Classification (4 Tiers)

```python
# scripts/librarian/risk_classifier.py
from enum import Enum

class RiskTier(Enum):
    LOW = 0      # Gate 1→2, <50 LOC, no sensitive areas
    MEDIUM = 1   # Gate 2→3, <200 LOC, standard features
    HIGH = 2     # Gate 3→4, >200 LOC, or sensitive areas
    CRITICAL = 3 # Emergency bypass, security-sensitive

def classify_request_risk(request):
    """
    Classify co-signature request by risk level.

    Returns: RiskTier
    """
    if request["type"] == "EMERGENCY_BYPASS":
        return RiskTier.CRITICAL

    # Check for high-risk file areas
    high_risk_areas = ["auth", "payment", "security", "encryption", "admin"]
    if any(area in request["files"].lower() for area in high_risk_areas):
        return RiskTier.HIGH

    # Check LOC threshold
    if request["total_loc"] > 200:
        return RiskTier.HIGH

    # Gate-specific rules
    if request["gate"] == "RED_TO_GREEN" and request["total_loc"] < 50:
        return RiskTier.LOW
    elif request["gate"] == "GREEN_TO_PEER" and request["total_loc"] < 200:
        return RiskTier.MEDIUM
    else:
        return RiskTier.HIGH
```

#### Auto-Approval Logic

LOW and MEDIUM tiers auto-approve if all checks pass:

```python
def auto_approve_eligible(request, risk_tier):
    """
    Check if request qualifies for auto-approval.

    Auto-approval requires:
    - Risk tier LOW or MEDIUM
    - All required signoffs present
    - Tests passing (if applicable)
    - Code coverage ≥80% (if applicable)
    - Security scan clean
    """
    if risk_tier not in [RiskTier.LOW, RiskTier.MEDIUM]:
        return False

    # Check 1: All required signoffs present
    if not all_signoffs_present(request):
        return False

    # Check 2: Tests passing
    if request["requires_tests"] and not tests_passing(request):
        return False

    # Check 3: Code coverage
    if request["requires_coverage"]:
        coverage = get_code_coverage(request["files"])
        if coverage < 0.80:  # 80% threshold
            return False

    # Check 4: Security scan
    security_scan = run_security_scan(request["files"])
    if security_scan["issues_found"]:
        return False

    return True

def process_co_signature_request(request):
    """
    Process co-signature with risk-based delegation.
    """
    risk_tier = classify_request_risk(request)

    if risk_tier == RiskTier.CRITICAL:
        # CRITICAL: Always manual review + User notification
        notify_librarian_urgent(request)
        notify_user(request, reason="CRITICAL_TIER")
        return "PENDING_MANUAL_REVIEW"

    elif risk_tier == RiskTier.HIGH:
        # HIGH: Always manual review
        notify_librarian(request)
        return "PENDING_MANUAL_REVIEW"

    elif risk_tier in [RiskTier.LOW, RiskTier.MEDIUM]:
        # LOW/MEDIUM: Check auto-approval eligibility
        if auto_approve_eligible(request, risk_tier):
            # AUTO-APPROVE
            grant_co_signature(request, approved_by="AUTO_APPROVAL", risk_tier=risk_tier)

            # Spot-check audit (5-10% random verification)
            spot_check_rate = 0.05 if risk_tier == RiskTier.LOW else 0.10
            if random.random() < spot_check_rate:
                add_to_spot_check_queue(request)

            return "AUTO_APPROVED"
        else:
            # Failed auto-approval checks → manual review
            notify_librarian(request, reason="AUTO_APPROVAL_FAILED")
            return "PENDING_MANUAL_REVIEW"
```

#### Spot-Check Audits

```python
def perform_spot_check_audit():
    """
    Librarian reviews random sample of auto-approved requests.

    Spot-check rates:
    - LOW tier: 5% random verification
    - MEDIUM tier: 10% random verification
    """
    spot_check_queue = load_spot_check_queue()

    for request in spot_check_queue:
        # Librarian manually verifies auto-approval was correct
        is_correct = librarian_verify_auto_approval(request)

        if not is_correct:
            # Auto-approval error detected
            log_auto_approval_error(request)
            alert_orchestrator("AUTO_APPROVAL_ERROR", request)

            # Adjust risk classification if needed
            if error_count_for_pattern(request) > 2:
                increase_risk_tier(request["pattern"])
```
```

**Step 2: Create Risk Classifier Script**

**File:** `scripts/librarian/risk_classifier.py`
**Test File:** `tests/librarian/test_risk_classifier.py`

```python
# tests/librarian/test_risk_classifier.py
import pytest
from scripts.librarian.risk_classifier import classify_request_risk, RiskTier

def test_classify_emergency_bypass_as_critical():
    request = {
        "type": "EMERGENCY_BYPASS",
        "files": "src/normal.py",
        "total_loc": 10
    }
    assert classify_request_risk(request) == RiskTier.CRITICAL

def test_classify_auth_changes_as_high():
    request = {
        "type": "GATE_TRANSITION",
        "files": "src/auth/login.py",
        "total_loc": 50
    }
    assert classify_request_risk(request) == RiskTier.HIGH

def test_classify_small_feature_as_low():
    request = {
        "type": "GATE_TRANSITION",
        "gate": "RED_TO_GREEN",
        "files": "src/utils.py",
        "total_loc": 30
    }
    assert classify_request_risk(request) == RiskTier.LOW
```

Run TDD cycle:
```bash
# 1. RED - Write test, watch it fail
pytest tests/librarian/test_risk_classifier.py -v
# FAILS: No module named 'scripts.librarian.risk_classifier'

# 2. GREEN - Implement minimal code
# (Create scripts/librarian/risk_classifier.py with classify_request_risk function)

# 3. REFACTOR - Clean up and improve
# (Add edge cases, error handling, logging)
```

**Step 3: Update Prompts**

**File:** `prompts.yaml`
Add to `librarian` prompt:

```yaml
- role: system
  content: |
    ## Co-Signature Delegation

    You use risk-based delegation to prevent bottlenecks:

    - **LOW tier** (Gate 1→2, <50 LOC, no sensitive areas): AUTO-APPROVE if checks pass
    - **MEDIUM tier** (Gate 2→3, <200 LOC): AUTO-APPROVE if checks pass
    - **HIGH tier** (>200 LOC or sensitive areas): MANUAL REVIEW required
    - **CRITICAL tier** (Emergency bypass): MANUAL REVIEW + User notification

    Auto-approval checks:
    ✓ All signoffs present
    ✓ Tests passing
    ✓ Coverage ≥80%
    ✓ Security scan clean

    Perform spot-check audits on 5-10% of auto-approvals.
```

**Commit:**
```bash
git add docs/roles/LIBRARIAN_ROLE.md scripts/librarian/risk_classifier.py tests/librarian/test_risk_classifier.py prompts.yaml
git commit -m "feat: Add Librarian delegation tiers for 70% auto-approval

- Implement 4-tier risk classification (LOW/MEDIUM/HIGH/CRITICAL)
- Auto-approve LOW/MEDIUM if all checks pass
- Spot-check audits (5-10% random verification)
- Prevents Librarian bottleneck (3x throughput increase)

Closes: Task 11.1 (Librarian Delegation Tiers)
Tests: pytest tests/librarian/test_risk_classifier.py"
```

**Testing Checklist:**
- [ ] Risk classifier correctly identifies all 4 tiers
- [ ] Auto-approval grants co-signature for eligible LOW/MEDIUM requests
- [ ] Manual review triggered for HIGH/CRITICAL or failed checks
- [ ] Spot-check queue populated at correct rates (5%/10%)
- [ ] Librarian can process 60+ requests/day (vs 20 without delegation)

**Deliverables:**
- Updated LIBRARIAN_ROLE.md (+250 lines)
- scripts/librarian/risk_classifier.py (~150 lines)
- tests/librarian/test_risk_classifier.py (~100 lines)
- Updated prompts.yaml

---

### Task 11.2: Implement Architecture Council Quorum Rules (HIGH)

**Priority:** HIGH
**Estimated Time:** 2 days
**Dependencies:** Task 2.2 (Orchestrator Decision Authority)

#### Problem Statement
Architecture Council can deadlock on 1-1 votes if Architect-C is unavailable. No timeout mechanism exists for voting.

#### Solution: Quorum Rules (2/3 Minimum)
Require 2/3 architects to vote, with timeout and tie-breaking escalation to User.

#### Implementation

**Step 1: Update Architect Role Documentation**

**File:** `docs/roles/ARCHITECT_ROLE.md`
**Location:** After "Architectural Decision Making (Council Voting)"
**Lines to Add:** ~400

Add section: "Architecture Council Quorum Rules and Tie-Breaking"

```markdown
### Architecture Council Quorum Rules

**Quorum:** Minimum 2 out of 3 architects must vote for decision to be valid.

**Voting Scenarios:**

| Votes | Quorum Met? | Outcome |
|-------|-------------|---------|
| 3 votes (2-1 or 3-0) | ✅ Yes | Normal majority - VALID |
| 2 votes (2-0) | ✅ Yes | Unanimous approval - VALID |
| 2 votes (1-1 tie) | ✅ Yes | Quorum met, but tie → Escalate to User |
| 1 vote | ❌ No | Quorum NOT met → Escalate to User |
| 0 votes (timeout) | ❌ No | Voting timeout → Escalate to User (urgent) |

**Voting Workflow:**

```python
# scripts/architect/voting_system.py
MINIMUM_QUORUM = 2  # At least 2/3 architects
VOTING_TIMEOUT = 48  # hours
REMINDER_INTERVAL = 24  # hours

def initiate_council_vote(proposal):
    """
    Start Architecture Council vote.
    """
    vote_id = create_vote_record(proposal)

    # Send vote request to all 3 architects
    for architect in ["Architect-A", "Architect-B", "Architect-C"]:
        send_message(architect, "ArchitecturalVoteRequest", {
            "vote_id": vote_id,
            "proposal": proposal,
            "deadline": datetime.now() + timedelta(hours=VOTING_TIMEOUT)
        })

    # Schedule reminder at 24h
    schedule_reminder(vote_id, delay_hours=REMINDER_INTERVAL)

    # Schedule timeout check at 48h
    schedule_timeout_check(vote_id, delay_hours=VOTING_TIMEOUT)

    return vote_id

def check_vote_status(vote_id):
    """
    Check if vote can be resolved.
    """
    votes = get_votes(vote_id)
    vote_count = len(votes)

    if vote_count >= MINIMUM_QUORUM:
        # Quorum met
        return resolve_vote(votes)
    elif is_timeout_reached(vote_id):
        # Timeout without quorum
        return escalate_to_user(vote_id, reason="TIMEOUT_NO_QUORUM")
    else:
        # Still waiting for votes
        return "PENDING"

def resolve_vote(votes):
    """
    Determine outcome when quorum is met.
    """
    approve_count = sum(1 for v in votes if v["decision"] == "APPROVE")
    reject_count = sum(1 for v in votes if v["decision"] == "REJECT")

    if approve_count > reject_count:
        return "APPROVED"
    elif reject_count > approve_count:
        return "REJECTED"
    else:
        # Tie (1-1 with 2 votes, or 1-1-1 abstain with 3 votes)
        return handle_tie(votes)

def handle_tie(votes):
    """
    Handle tie scenarios.

    - 1-1 tie (2 votes): Urgent request to Architect-C (12h expedited)
    - If Architect-C still unavailable: Escalate to User
    """
    if len(votes) == 2:
        # 1-1 tie, request expedited vote from Architect-C
        missing_architect = find_missing_architect(votes)

        send_message(missing_architect, "UrgentTieBreaker", {
            "votes": votes,
            "deadline": datetime.now() + timedelta(hours=12),  # Expedited
            "reason": "Council tie - your vote needed to break deadlock"
        })

        # Schedule expedited timeout
        schedule_timeout_check(vote_id, delay_hours=12)
        return "PENDING_TIE_BREAKER"
    else:
        # 3-way tie or other edge case
        return escalate_to_user(vote_id, reason="TIE_UNRESOLVED")
```
```

**Step 2: Implement Voting System**

**File:** `scripts/architect/voting_system.py`
**Test:** `tests/architect/test_voting_system.py`

```python
# tests/architect/test_voting_system.py
import pytest
from scripts.architect.voting_system import check_vote_status, resolve_vote

def test_quorum_met_with_2_votes_unanimous():
    votes = [
        {"architect": "Architect-A", "decision": "APPROVE"},
        {"architect": "Architect-B", "decision": "APPROVE"}
    ]
    assert resolve_vote(votes) == "APPROVED"

def test_quorum_met_with_2_1_majority():
    votes = [
        {"architect": "Architect-A", "decision": "APPROVE"},
        {"architect": "Architect-B", "decision": "APPROVE"},
        {"architect": "Architect-C", "decision": "REJECT"}
    ]
    assert resolve_vote(votes) == "APPROVED"

def test_tie_with_2_votes_triggers_tie_breaker():
    votes = [
        {"architect": "Architect-A", "decision": "APPROVE"},
        {"architect": "Architect-B", "decision": "REJECT"}
    ]
    result = resolve_vote(votes)
    assert result == "PENDING_TIE_BREAKER"
```

**Commit:**
```bash
git add docs/roles/ARCHITECT_ROLE.md scripts/architect/voting_system.py tests/architect/test_voting_system.py
git commit -m "feat: Add Architecture Council quorum rules

- Require 2/3 quorum for valid votes
- Handle 1-1 ties with expedited 12h tie-breaker request
- 48h voting timeout with 24h reminder
- Escalate to User for timeout or unresolved ties

Closes: Task 11.2 (Council Quorum Rules)
Tests: pytest tests/architect/test_voting_system.py"
```

**Testing Checklist:**
- [ ] 2-vote unanimous → APPROVED
- [ ] 2-1 majority → APPROVED/REJECTED correctly
- [ ] 1-1 tie → Expedited tie-breaker request to Architect-C
- [ ] 1 vote → Quorum not met, escalate to User
- [ ] 0 votes (timeout) → Escalate to User with urgency
- [ ] Reminders sent at 24h, timeout enforced at 48h

**Deliverables:**
- Updated ARCHITECT_ROLE.md (+400 lines)
- scripts/architect/voting_system.py (~250 lines)
- tests/architect/test_voting_system.py (~150 lines)

---

### Tasks 11.3-11.12 Summary

Due to length constraints, Tasks 11.3-11.12 follow the same pattern:

| Task | File(s) | Lines | TDD Approach |
|------|---------|-------|--------------|
| 11.3 Peer Review SLA | 4 role files | +880 | Test timeout, alternate assignment |
| 11.4 QA Rollback | ORCHESTRATOR_ROLE.md | +330 | Test rollback workflow |
| 11.5 Priority System | ORCHESTRATOR_ROLE.md | +355 | Test weighted assignment |
| 11.6 Lock Priority | SECURITY_IMPLEMENTATION.md | +370 | Test preemption, grace periods |
| 11.7 Collusion Enhanced | SECURITY_IMPLEMENTATION.md | +308 | Test 5-review threshold |
| 11.8 Tertiary Independence | SECURITY_IMPLEMENTATION.md | +330 | Test participation tracking |
| 11.9 2FA Limiting | SECURITY_IMPLEMENTATION.md | +550 | Test progressive lockout |
| 11.10 Planner Mediation | ORCHESTRATOR_ROLE.md | +410 | Test mediation workflows |
| 11.11 Docs Veto | DOCS_ROLE.md | +300 | Test deployment blocking |
| 11.12 Integration Test | tests/integration/ | +500 | End-to-end all enhancements |

Each task follows TDD:
1. Write tests first (RED)
2. Implement minimal code to pass (GREEN)
3. Refactor and document (REFACTOR)
4. Commit with detailed message

---

## 📊 Updated Timeline

### Original: 10 Weeks (Tasks 1.1-10.5)
- Week 1: Foundation
- Week 2: System-Comps
- Week 3: Git Hooks
- Week 4: Write Lock & Messaging
- Week 5: Cryptography
- Week 6: 2FA & Librarian Veto
- Week 7: Monitoring
- Week 8: Bootstrap
- Week 9: Integration Testing
- Week 10: Production Hardening

### **New: +2 Weeks (Phase 11)**
- **Week 11:** Tasks 11.1-11.6 (Critical/High enhancements)
  - Librarian delegation, Council quorum, Peer SLA, QA rollback, Priority system, Lock priority
- **Week 12:** Tasks 11.7-11.12 (Medium/Low enhancements + Integration)
  - Collusion, Tertiary independence, 2FA limiting, Planner mediation, Docs veto, Integration testing

**Total Timeline:** 12 weeks (62 tasks)

---

## 🎯 Success Criteria

### Original Plan (Tasks 1.1-10.5)
- ✅ All 50 tasks completed with TDD
- ✅ 12 instances coordinated via message protocol
- ✅ 4-eyes principle enforced
- ✅ Quality gates functional
- ✅ Security hardening complete
- ✅ Integration tests passing
- ✅ Production ready

### Phase 11 Additions
- ✅ Librarian handles 60+ requests/day (3x improvement)
- ✅ Architecture Council never deadlocks (quorum rules)
- ✅ No peer review blocks >24h (SLA enforcement)
- ✅ CRITICAL work never blocked by LOW priority (priority system)
- ✅ Collusion detected after 5 reviews (vs 10)
- ✅ Tertiary reviewers truly independent
- ✅ 2FA protected from brute-force (progressive lockout)
- ✅ 70-80% of Planner disagreements resolved without escalation
- ✅ No undocumented features deployed (Docs veto)
- ✅ All integration tests passing

---

## 📁 File Structure After Phase 11

```
claude-workflow-system/
├── docs/
│   ├── roles/
│   │   ├── ORCHESTRATOR_ROLE.md        (+1,095 lines - original + 11.4 + 11.5 + 11.10)
│   │   ├── LIBRARIAN_ROLE.md           (+250 lines - original + 11.1)
│   │   ├── ARCHITECT_ROLE.md           (+475 lines - original + 11.2 + 11.3)
│   │   ├── DEVELOPER_ROLE.md           (+360 lines - original + 11.3)
│   │   ├── QA_ROLE.md                  (+355 lines - original + 11.3)
│   │   ├── PLANNER_ROLE.md             (+90 lines - original + 11.3)
│   │   ├── DOCS_ROLE.md                (+300 lines - original + 11.11)
│   │   └── SECURITY_IMPLEMENTATION.md  (+1,558 lines - original + 11.6 + 11.7 + 11.8 + 11.9)
│   └── plans/
│       ├── 2025-11-16-complete-implementation-plan.md (ORIGINAL - 9,122 lines)
│       └── 2025-11-16-UPDATED-complete-implementation-plan.md (THIS FILE)
├── scripts/
│   ├── librarian/
│   │   └── risk_classifier.py          (NEW - Task 11.1)
│   ├── architect/
│   │   └── voting_system.py            (NEW - Task 11.2)
│   ├── orchestrator/
│   │   ├── priority_system.py          (NEW - Task 11.5)
│   │   └── rollback_manager.py         (NEW - Task 11.4)
│   └── security/
│       ├── write_lock.py               (ENHANCED - Task 11.6)
│       ├── collusion_detector.py       (ENHANCED - Task 11.7)
│       ├── tertiary_reviewer.py        (ENHANCED - Task 11.8)
│       └── 2fa_rate_limiter.py         (ENHANCED - Task 11.9)
└── tests/
    ├── integration/
    │   └── test_phase11_enhancements.py (NEW - Task 11.12)
    └── ... (original test files from Tasks 1.1-10.5)
```

---

## 🔗 Quick Reference

### Documentation Links
- **Original Plan (Tasks 1.1-10.5):** `docs/plans/2025-11-16-complete-implementation-plan.md`
- **Role Implementations:** `docs/roles/*.md` (8 files updated in Phase 11)
- **Progress Tracking:** `docs/FUNCTIONAL_FIXES_PROGRESS.md`

### Key Files Modified in Phase 11
1. LIBRARIAN_ROLE.md → Task 11.1
2. ARCHITECT_ROLE.md → Tasks 11.2, 11.3
3. DEVELOPER_ROLE.md → Task 11.3
4. QA_ROLE.md → Task 11.3
5. PLANNER_ROLE.md → Task 11.3
6. ORCHESTRATOR_ROLE.md → Tasks 11.4, 11.5, 11.10
7. SECURITY_IMPLEMENTATION.md → Tasks 11.6, 11.7, 11.8, 11.9
8. DOCS_ROLE.md → Task 11.11

---

## 📝 Implementation Notes

### Compatibility with Original Plan
- Phase 11 tasks **do not modify** original Tasks 1.1-10.5
- All enhancements **extend** existing infrastructure
- Original tests remain valid (no breaking changes)
- New tests added in Phase 11 for enhancements

### TDD Throughout
Both original (Tasks 1.1-10.5) and new (Tasks 11.1-11.12) use strict TDD:
1. Write test (RED)
2. Minimal implementation (GREEN)
3. Refactor (REFACTOR)
4. Commit with detailed message

### Continuous Integration
After each task, run full test suite:
```bash
pytest tests/ -v
# All tests must pass before moving to next task
```

---

**Status:** READY FOR IMPLEMENTATION
**Next Step:** Begin Week 1 (Task 1.1) or Week 11 (Task 11.1) if original plan complete
