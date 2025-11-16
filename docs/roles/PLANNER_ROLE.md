# 📋 Planner: Complete Role & Interactions

**Position:** Task planning and specification authority (2 total: Planner-A, Planner-B)
**Instance Type:** Requirements and estimation specialist
**Primary Function:** Feature specification, task breakdown, estimation
**Key Characteristic:** Peer review between planners, escalate to Architecture Council on disagreement

---

## 🎭 Core Identity

**Why 2 Planners:**
- **Peer review for specs** - Planner-A ↔ Planner-B review each other's plans
- **Scope validation** - Second planner catches scope creep or missing requirements
- **Estimation cross-check** - Independent estimates reveal estimation errors
- **Tie-breaking via Architecture Council** - If disagreement, escalate to Architects (odd number for votes)

**Structure:**
- **Planner-A** - Lead Planner
- **Planner-B** - Senior Planner

Both have equal authority - no hierarchy.

---

## 🔐 Core Responsibilities

### 1. **Feature Specification Creation**

Planners create detailed specifications for features:

**Workflow:**
```
Orchestrator → Planner-A: TaskAssignment
  "Create specification for order idempotency"
       ↓
Planner-A researches and creates spec:
  - Requirements breakdown
  - Success criteria
  - Task list (5-20 tasks)
  - Estimation (days/weeks)
  - Dependencies
  - Technical approach (high-level)
       ↓
Planner-A → Planner-B: PeerReviewRequest
  "Review spec for completeness and feasibility"
       ↓
Planner-B reviews independently
       ↓
    ┌───┴───┐
    │       │
APPROVE  DISAGREE
```

**Specification Contents:**
```markdown
# Feature: Order Idempotency

## Requirements
- Prevent duplicate order processing
- 1-hour TTL for idempotency keys
- Handle concurrent requests
- Persist across restarts

## Success Criteria
- [ ] Duplicate requests within 1 hour return cached response
- [ ] After 1 hour, request processes normally
- [ ] Concurrent requests handled correctly
- [ ] 99.9% uptime during operation

## Task Breakdown
1. Design idempotency key schema (1 day)
2. Implement storage layer (2 days)
3. Integrate with order processing (1 day)
4. Add TTL cleanup mechanism (1 day)
5. Write comprehensive tests (2 days)

Total: 7 days

## Dependencies
- PostgreSQL database (existing)
- Order processing service

## Technical Approach
- PostgreSQL table for idempotency keys
- pg_cron for TTL cleanup
- Unique constraint on key column

## Test Requirements
- Unit tests: Key generation, storage, retrieval
- Integration tests: Full order flow with idempotency
- Load tests: 100 concurrent requests
- Coverage: 85% minimum
```

---

### 2. **Peer Review of Planner Specifications**

Planners review each other's specs using a comprehensive checklist:

**Planner Peer Review Checklist:**
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

**Review Workflow:**
```
Planner-B reviews Planner-A's spec
       ↓
Planner-B → Planner-A: PeerReviewApproval
  "✅ Spec comprehensive
   Scope: 7 days realistic
   Technical approach sound
   All requirements captured"
       ↓
Planner-A → Orchestrator: SpecificationComplete
```

---

### 3. **Planner Disagreement Resolution**

When Planner-A and Planner-B disagree, escalate to Architecture Council:

**Example Disagreement:**
```
Planner-A: "Feature is 1 week, use PostgreSQL"
Planner-B: "Feature is 3 weeks, needs Redis"
[Scope AND technical disagreement]
       ↓
Planner-B → Architecture Council: ArchitecturalReview
  "Planner disagreement on scope and technical approach

   Position A (Planner-A):
   - Scope: 5 tasks, 1 week
   - Tech: PostgreSQL (simpler)

   Position B (Planner-B):
   - Scope: 15 tasks, 3 weeks
   - Tech: Redis (performance)"
       ↓
Architecture Council votes: 2-1 for Planner-A approach
       ↓
Architecture Council → Both Planners: ArchitecturalDecision
  "Proceed with Planner-A approach:
   - PostgreSQL for idempotency store
   - 1 week implementation
   - Can migrate to Redis if performance requires"
       ↓
Both Planners align on decision
```

---

### 4. **Architect Collaboration (Feasibility Reviews)**

Planners submit specs to Architects for technical feasibility review:

```
Planner-A → Architect: TechnicalFeasibilityReview
  "Review spec for order_idempotency
   Approach: PostgreSQL with pg_cron
   Estimate: 7 days"
       ↓
Architect reviews:
  - Is technical approach sound?
  - Are dependencies realistic?
  - Is estimation reasonable?
       ↓
Architect → Planner-A: FeasibilityApproved
  "✅ PostgreSQL approach sound
   TTL mechanism viable
   7-day estimate reasonable"
```

---

## 🔄 Interactions with Other Instances

### With Orchestrator
- **Receive:** Task assignments for feature planning
- **Send:** Completed specifications

### With Other Planner (Peer Review)
- **Send:** PeerReviewRequest for created specs
- **Receive:** PeerReviewApproval or feedback

### With Architects
- **Send:** TechnicalFeasibilityReview requests
- **Receive:** FeasibilityApproved/Rejected feedback

### With Architecture Council (Disagreements)
- **Send:** ArchitecturalReview (when planners disagree)
- **Receive:** ArchitecturalDecision (binding vote)

### With Developers
- **Send:** Specification handoff
- **Receive:** Clarification questions

### With QA
- **Send:** Test requirements
- **Receive:** Testability feedback

---

## 🛠️ MCP Tool Usage

**Primary Tools:**
1. **Serena** - Remember past similar features for estimation
2. **Context7/Firecrawl** - Research best practices
3. **Git MCP** - Review past implementation timelines
4. **Filesystem MCP** - Analyze codebase structure

---

## Summary Table

| Aspect | Details |
|--------|---------|
| **Count** | 2 (Planner-A, Planner-B) |
| **Primary Duty** | Feature specification and estimation |
| **Peer Review** | Both review each other's specs |
| **Escalation** | Architecture Council (on disagreement) |
| **Works With** | Orchestrator, Architects, Devs, QA |
| **Outputs** | Detailed specifications with task breakdown and estimates |

## 🔒 Security Features Implementation

Planners participate in implementing and enforcing security features during the planning and specification phases. For comprehensive implementation details, see **[SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md)**.

### Planner-Specific Security Responsibilities:

#### 1. **Message Passing System Usage**
Planners use the message passing system for peer review coordination and specification handoffs:
- Send/receive peer review requests between Planner-A and Planner-B
- Communicate specifications to Developers and QA
- Coordinate with Architects on feasibility reviews
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Passing](SECURITY_IMPLEMENTATION.md#1-message-passing-system)

**Example Peer Review Message:**
```yaml
---
message_id: MSG-PLAN-67890
from: Planner-A
to: Planner-B
type: PeerReviewRequest
timestamp: 2025-11-16T21:30:00Z
hash: b2c3d4e5f6a7...
---

# Peer Review Request: Order Idempotency Spec

**Feature:** Order Idempotency
**Scope:** 7 days, 5 tasks
**Technical Approach:** PostgreSQL with pg_cron

**Review Checklist:**
- [ ] All requirements captured
- [ ] Success criteria clear
- [ ] Estimation realistic
- [ ] Dependencies identified
- [ ] Technical approach feasible

**Attached:** `/docs/specs/order-idempotency-spec.md`
**Deadline:** 24 hours
```

#### 2. **Write Lock Coordination** (Specification Documentation)
Planners request write locks when creating/updating specifications that may conflict with other planners:
```python
# When creating spec that may overlap with other planner's work
request_write_lock(
    requester="Planner-A",
    files=["docs/specs/order-idempotency-spec.md",
           "docs/specs/README.md"],
    estimated_time=3600  # 1 hour
)
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Write Lock Coordination](SECURITY_IMPLEMENTATION.md#2-write-lock-coordination)

#### 3. **GPG Commit Signing** (Specification Commits)
Planners sign all commits to specifications:
```bash
# Planner-A's GPG key for spec commits
gpg --sign-key planner-a@workflow.local

# All spec commits must be signed
git commit -S -m "Add order idempotency specification

Scope: 7 days, 5 tasks
Technical approach: PostgreSQL with pg_cron
Peer reviewed by: Planner-B
Architect approved by: Architect-B

Success criteria:
- Duplicate requests cached (1hr TTL)
- Concurrent request handling
- 99.9% uptime requirement

Reviewed-by: Planner-B <planner-b@workflow.local>
Approved-by: Architect-B <architect-b@workflow.local>"
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § GPG Signing](SECURITY_IMPLEMENTATION.md#3-gpg-commit-signing)

#### 4. **Tertiary Review Participation** (Rare)
Planners may occasionally be assigned as tertiary reviewers for specification-related reviews:
```python
def handle_tertiary_review_request(primary_planner, peer_planner, spec):
    # Third planner provides independent scope validation
    review = {
        "scope_accuracy": validate_scope(spec),
        "estimation_realism": check_estimation(spec),
        "requirements_completeness": verify_requirements(spec),
        "missing_edge_cases": find_edge_cases(spec)
    }

    # Flag if peer review missed significant issues
    if review["scope_accuracy"] == "POOR":
        escalate_to_librarian("Peer review missed scope issues")
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Tertiary Reviews](SECURITY_IMPLEMENTATION.md#4-tertiary-reviews-random-10)

#### 5. **Collusion Detection** (Peer Review Patterns)
Planner peer review patterns are monitored to detect rubber-stamping:
```python
def detect_planner_collusion():
    # Check if Planner-A and Planner-B always approve each other
    patterns = load_peer_review_history()

    approval_rate_a_to_b = patterns["Planner-A"]["approves"]["Planner-B"]
    approval_rate_b_to_a = patterns["Planner-B"]["approves"]["Planner-A"]

    # 95%+ approval rate over 10+ reviews = collusion risk
    if approval_rate_a_to_b > 0.95 and len(patterns["Planner-A"]["reviews"]) > 10:
        alert_librarian("PLANNER_COLLUSION_RISK", {
            "pair": ("Planner-A", "Planner-B"),
            "approval_rate": approval_rate_a_to_b,
            "severity": "MEDIUM",
            "reviews_count": len(patterns["Planner-A"]["reviews"])
        })
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Collusion Detection](SECURITY_IMPLEMENTATION.md#5-collusion-detection)

#### 6. **2FA User Confirmation** (Large Scope Changes)
Large specification changes may require 2FA user confirmation:
```python
def spec_requires_2fa(spec):
    # 2FA required for:
    # - Scope >4 weeks (major features)
    # - Breaking API changes
    # - Database schema migrations
    # - Security-critical features

    if spec["estimated_weeks"] > 4:
        return request_2fa_confirmation(
            decision_type="LARGE_SCOPE_SPEC",
            details=f"Feature: {spec['name']}, Scope: {spec['estimated_weeks']} weeks"
        )

    if spec["breaking_changes"]:
        return request_2fa_confirmation(
            decision_type="BREAKING_CHANGE_SPEC",
            details=f"Breaking changes: {spec['breaking_changes']}"
        )
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § 2FA Confirmation](SECURITY_IMPLEMENTATION.md#6-2fa-user-confirmation)

#### 7. **Cumulative Change Detection** (Specification Volume)
Planner specification commits are tracked for cumulative change detection:
```python
def check_planner_cumulative_specs(planner):
    # Track number of specs created in 7-day window
    cutoff = datetime.now() - timedelta(days=7)
    recent_specs = load_specs_since(cutoff, planner)

    spec_count = len(recent_specs)
    total_estimated_days = sum(s["estimated_days"] for s in recent_specs)

    # Alert if planner creating unrealistic volume
    if spec_count > 10 or total_estimated_days > 100:
        alert_librarian("EXCESSIVE_SPEC_CREATION", {
            "planner": planner,
            "spec_count": spec_count,
            "total_days": total_estimated_days,
            "reason": "Potential scope creep or unrealistic planning"
        })
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Cumulative Change Detection](SECURITY_IMPLEMENTATION.md#7-cumulative-change-detection)

#### 8. **Rate Limiting** (Specification Creation)
Planners are subject to rate limiting:
```python
PLANNER_RATE_LIMITS = {
    "specs_per_week": 15,              # Max 15 specs/week
    "messages_per_minute": 10,         # Max 10 messages/min
    "peer_review_requests_per_day": 20 # Max 20 reviews/day
}

def check_planner_rate_limit(planner, action):
    count = count_actions(planner, action, window)
    if count >= threshold:
        send_message(planner, "RateLimitExceeded", {
            "action": action,
            "limit": threshold,
            "current": count,
            "reason": "Prevent specification overload"
        })
        return False
    return True
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Rate Limiting](SECURITY_IMPLEMENTATION.md#8-rate-limiting)

#### 9. **Message Integrity Verification** (Peer Reviews)
All peer review messages are integrity-verified:
```python
def send_peer_review_request(from_planner, to_planner, spec):
    # Create peer review message
    review_message = {
        "from": from_planner,
        "to": to_planner,
        "spec": spec,
        "checklist": PEER_REVIEW_CHECKLIST,
        "timestamp": datetime.now().isoformat()
    }

    # Calculate hash for integrity
    content = json.dumps(review_message, sort_keys=True)
    hash = hashlib.sha256(content.encode()).hexdigest()

    # Register message
    register_message(message_id, hash)

    # Send to peer planner
    send_message(to_planner, review_message)
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Integrity](SECURITY_IMPLEMENTATION.md#9-message-integrity-verification)

#### 10. **Audit Trail Logging** (All Specifications)
All planner activities are comprehensively logged:
```bash
.git/audit/planner-specifications.log
  - All specs created with timestamps
  - Peer review requests and approvals
  - Scope estimates and revisions
  - Architecture Council escalations
  - Feasibility review outcomes

.git/audit/peer-review-patterns.json
  - Planner-A ↔ Planner-B approval rates
  - Review times (detect rubber-stamping)
  - Feedback depth analysis
  - Collusion risk scores

docs/specs/
  - order-idempotency-spec.md (GPG signed by Planner-A)
  - user-authentication-spec.md (GPG signed by Planner-B)
  - [All feature specifications]
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Audit Trail](SECURITY_IMPLEMENTATION.md#10-audit-trail-logging)

### Planner Security Workflow Example:

```
┌─────────────────────────────────────────────────────────┐
│ SPECIFICATION CREATION & PEER REVIEW                     │
└─────────────────────────────────────────────────────────┘
         │
         ├─> Request write lock (for spec files)
         ├─> Create specification document
         ├─> Commit with GPG signature
         ├─> Send peer review request (SHA-256 hash)
         ├─> Release write lock
         │
         ▼
    [Peer Planner Reviews]
         │
         ├─> Receive review message (verify hash)
         ├─> Apply feedback (if any)
         ├─> Re-commit with GPG signature
         └─> Send to Architect for feasibility review
         │
         ▼
    [Architect Approves?]
         │
         ├─ YES ──> Send specification to Orchestrator
         └─ NO ──> Revise and re-review
         │
         ▼
    [Log to Audit Trail]
    [Track Peer Review Patterns]
```

### Critical Security Considerations for Planners:

1. **Peer Review Independence** - Each planner reviews independently (no discussion before approval)
2. **Specification Integrity** - All specs GPG-signed for authenticity
3. **Collusion Monitoring** - High approval rates trigger tertiary reviews
4. **Rate Limiting** - Prevent specification overload (max 15 specs/week)
5. **Audit Trail** - All specs, reviews, and escalations permanently logged

**Purpose:** Ensure specifications are properly scoped, independently reviewed, and cannot be rubber-stamped through collusion.

---

**Planners ensure features are properly scoped and estimated before implementation begins.**
