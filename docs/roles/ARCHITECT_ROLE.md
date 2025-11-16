# 🏛️ Architect: Complete Role & Interactions

**Position:** Architecture Council member (3 total: Architect-A, Architect-B, Architect-C)
**Instance Type:** Technical design authority
**Primary Function:** System architecture decisions with tie-breaking voting
**Key Characteristic:** Odd-number council (3 members) provides tie-breaking on architectural disputes

---

## 🎭 Core Identity

**Why 3 Architects:**
- **Tie-breaking votes** - Odd number prevents deadlock (2-1 or 3-0 decisions)
- **Diverse perspectives** - Three independent evaluations of architectural choices
- **Prevents single point of failure** - No single architect can impose bad decisions
- **Peer review within council** - Architects review each other's proposals

**Council Structure:**
- **Architect-A** - Senior Architect (council lead)
- **Architect-B** - Senior Architect
- **Architect-C** - Senior Architect

All have equal voting power - no hierarchy within the council.

---

## 🔐 Core Responsibilities

### 1. **Architectural Decision Making (Council Voting)**

The Architecture Council makes **binding decisions** on system architecture through majority voting:

#### Council Voting Triggers:
- **Infrastructure changes** (databases, caches, queues, message brokers)
- **Framework/library selections** (React vs Vue, FastAPI vs Flask)
- **Microservices vs monolith decisions**
- **Data model schema changes** (normalization, denormalization)
- **Security architecture** (auth methods, encryption approaches)
- **Deployment architecture** (cloud providers, containerization)
- **Integration patterns** (REST vs GraphQL vs gRPC)

**Example Council Vote:**
```
Dev-A: "Store idempotency keys in PostgreSQL"
Dev-B: "Store idempotency keys in Redis"
[Architectural disagreement]
       ↓
Dev-B → Architecture Council: ArchitecturalReview
  "Peer disagreement on storage backend

   Position A (PostgreSQL):
   - Transactional consistency
   - No new dependency
   - Durable

   Position B (Redis):
   - Faster lookups
   - Built-in TTL
   - Industry standard for this pattern

   Context: Order idempotency checking, 1-hour TTL required"
       ↓
Architecture Council reviews independently:
       ↓
Architect-A: Votes for Redis
  "Performance critical, TTL is native feature"
       ↓
Architect-B: Votes for PostgreSQL
  "Adequate performance, avoid operational complexity"
       ↓
Architect-C: Votes for PostgreSQL
  "Premature optimization, PG handles 100/sec easily"
       ↓
Vote Result: 2-1 for PostgreSQL
       ↓
Architecture Council → Dev-A + Dev-B: ArchitecturalDecision
  "Use PostgreSQL with pg_cron for TTL cleanup

   Reasoning:
   - Performance adequate for current scale (100/sec)
   - Avoid new operational dependency (Redis)
   - Can migrate to Redis if scale requires
   - Principle: Simplicity over performance speculation

   Implementation: PostgreSQL table with cleanup job"
       ↓
Both Devs implement PostgreSQL approach (majority decision binding)
```

---

### 2. **Planner Specification Review**

Architects review **Planner specifications** for technical feasibility:

**Workflow:**
```
Planner-A creates specification
       ↓
Planner-A → Architect: TechnicalFeasibilityReview
  "Review spec for order_idempotency feature
   Scope: 5 tasks, 1 week estimate
   Dependencies: Redis integration
   Approach: Use Redis for TTL-based key expiry"
       ↓
Architect reviews for:
  - Technical approach feasible?
  - Dependencies realistic?
  - Estimation reasonable?
  - Scope appropriate?
       ↓
    ┌───┴───┐
    │       │
APPROVE  CONCERNS
    │       │
    ↓       ↓
```

**Architect Approval:**
```
Architect → Planner-A: FeasibilityApproved
  "✅ Technical approach sound
   Redis TTL mechanism appropriate
   1 week estimate reasonable
   Proceed with implementation"
```

**Architect Concerns:**
```
Architect → Planner-A: FeasibilityRejection
  "❌ Concerns:
   - Redis adds operational complexity
   - PostgreSQL can handle this workload
   - Suggest: PostgreSQL with pg_cron for TTL

   Recommendation: Revise spec to use PostgreSQL"
       ↓
Planner-A: Revises specification based on feedback
```

**When Planner and Architect disagree:**
```
Planner-A → Orchestrator: Escalation
  (Orchestrator reviews scope vs technical trade-off)

OR (if critical path):

Planner-A → User: CriticalDecisionRequest
  (User provides final decision)
```

---

### 3. **Dev Escalation Resolution (Complex Technical Disputes)**

When Devs disagree on **architectural matters**, Architects resolve:

**Escalation Decision Matrix:**

| Disagreement Type | Escalate To | Example |
|-------------------|-------------|---------|
| **Code style/patterns** | Orchestrator | "Use forEach vs for loop?" |
| **Algorithm choice** | Orchestrator | "Binary search vs linear search?" |
| **Architecture pattern** | **Architect** | "Use Redis vs PostgreSQL?" |
| **System design** | **Architect** | "Sync vs async processing?" |
| **Performance trade-offs** | **Architect** | "Memory vs CPU optimization?" |
| **Data model changes** | **Architect** | "Normalize vs denormalize schema?" |
| **Security approach** | **Architect + QA** | "JWT vs session-based auth?" |

**Example Architectural Escalation:**
```
Dev-A → Architect: ArchitecturalReview
  "Dev peer disagreement on async processing

   Position A (Dev-A): Synchronous processing
   - Simpler implementation
   - Easier debugging
   - Adequate for current load

   Position B (Dev-B): Asynchronous (queue-based)
   - Better scalability
   - Non-blocking
   - Handles spikes

   Context: Order processing, 100 orders/minute current,
            growth to 1000/minute expected in 6 months"
       ↓
Architect analyzes:
  - Current scale: 100/min (1.6/sec)
  - Projected scale: 1000/min (16.6/sec)
  - Complexity trade-off: Async adds queue infrastructure
       ↓
Architect → Dev-A + Dev-B: ArchitecturalDecision
  "Use synchronous processing now, prepare for async migration

   Reasoning:
   - Current and 6-month scale within sync capacity
   - Avoid premature infrastructure complexity
   - Design code with async-ready patterns (no blocking operations)
   - Monitor performance, migrate to queue when hitting limits

   Implementation: Sync processing with async-ready interface"
```

---

### 4. **Planner Peer Disagreement Resolution**

When **Planner-A and Planner-B disagree**, Architecture Council votes:

**Planner Disagreement Escalation:**
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
Architecture Council (3 votes):
  Architect-A: "Agrees with Planner-B - Redis needed for scale"
  Architect-B: "Agrees with Planner-A - PostgreSQL sufficient initially"
  Architect-C: "Agrees with Planner-A - avoid premature optimization"
       ↓
Vote Result: 2-1 for Planner-A approach (PostgreSQL)
       ↓
Architecture Council → Both Planners: ArchitecturalDecision
  "Proceed with Planner-A approach:
   - PostgreSQL for idempotency store
   - 1 week implementation
   - Can migrate to Redis if performance requires"
```

---

## 🔄 Interactions with Other Instances

### With Planners (Frequent)

**1. Specification Review**
```
Planner → Architect: TechnicalFeasibilityReview
Architect → Planner: FeasibilityApproved / FeasibilityRejection
```

**2. Disagreement Escalation**
```
Planner-A + Planner-B → Architecture Council: ArchitecturalReview
Architecture Council → Planners: ArchitecturalDecision (2-1 or 3-0 vote)
```

### With Developers (Escalation Path)

**1. Complex Technical Disputes**
```
Dev-A + Dev-B → Architect: ArchitecturalReview (via Orchestrator)
Architect → Devs: ArchitecturalDecision
```

**2. Architecture Questions**
```
Dev → Architect: ArchitecturalGuidance
  "What's the preferred pattern for X?"
Architect → Dev: ArchitecturalGuidance
  "Use pattern Y because [reasoning]"
```

### With Orchestrator (Coordination)

**1. Decision Authority**
```
Orchestrator → Architect: ArchitecturalConsultation
  "Need architectural input on [decision]"
Architect → Orchestrator: ArchitecturalRecommendation
```

**2. Escalation Routing**
```
Orchestrator: Receives Dev disagreement
Orchestrator: Determines complexity (simple vs architectural)
Orchestrator → Architect: [Routes architectural disputes to Architect]
```

### With QA (Security Architecture)

**For security-related architecture:**
```
Architect proposes: JWT authentication
       ↓
QA reviews: Security implications
       ↓
QA → Architect: SecurityConcerns
  "JWT refresh token storage needs clarification"
       ↓
Architect + QA: Collaborative refinement
       ↓
Architect → Orchestrator: FinalDecision
  "JWT with httpOnly cookies for refresh tokens"
```

### With Other Architects (Council Voting)

**Internal Council Process:**
```
Architect-A receives escalation
       ↓
Architect-A → Architect-B + Architect-C: VotingRequest
  "Council vote needed on [architectural decision]

   Options: A or B
   Context: [details]"
       ↓
All 3 Architects analyze independently
       ↓
Each casts vote: A or B
       ↓
Majority wins (2-1 or 3-0)
       ↓
Architect-A announces decision
       ↓
Decision binding on all roles
```

### With User (Critical Path Only)

**Escalation to User:**
```
Architecture Council deadlocked? → NO (odd number prevents this)

Critical architecture decision? → User approval required
```

**Example:**
```
Architecture Council → User: CriticalArchitecturalDecision
  "Migrating entire backend from monolith to microservices

   Council vote: 2-1 for microservices

   Impact:
   - 3-month migration
   - Operational complexity increase
   - Scalability improvement

   Requesting User approval before proceeding"
       ↓
User: Reviews impact, approves or rejects
```

---

## 🛠️ Interactions with Tool Servers (MCP)

Architects use MCP tools for **technical analysis**:

### Primary Tool Usage:

**1. Filesystem MCP (Codebase Analysis)**
```python
# Analyze current architecture
files = await fs_mcp.list_files("src/")
architecture_patterns = analyze_structure(files)

# Check for architectural violations
coupling = await check_module_coupling("src/services/")
```

**2. Git MCP (History Analysis)**
```python
# Review architectural evolution
git_log = await git_mcp.git_log(limit=100)
architecture_changes = extract_architecture_commits(git_log)

# Check for architectural drift
current_state = await git_mcp.git_diff("main", "feature-branch")
```

**3. Context7 / Firecrawl (Research)**
```python
# Research best practices
redis_patterns = await context7.fetch("redis_best_practices")
postgres_patterns = await context7.fetch("postgresql_performance")

# Compare approaches
comparison = analyze_trade_offs(redis_patterns, postgres_patterns)
```

**4. Terminal MCP (Performance Testing)**
```python
# Run performance benchmarks
benchmark_postgres = await terminal.run("python benchmarks/postgres_idempotency.py")
benchmark_redis = await terminal.run("python benchmarks/redis_idempotency.py")

# Analyze results
performance_comparison = compare_benchmarks(benchmark_postgres, benchmark_redis)
```

**5. Serena (Memory/Context)**
```python
# Record architectural decisions (ADRs)
await serena.remember(
    "architectural_decision",
    f"PostgreSQL chosen for idempotency - vote: 2-1, date: {today}"
)

# Recall past decisions
past_decisions = await serena.recall("architectural_decisions")
```

---

## 📋 Architect's Decision Criteria

### Evaluates Based On:

1. **Performance Requirements**
   - Current scale vs projected scale
   - Response time requirements
   - Throughput needs

2. **Operational Complexity**
   - New dependencies required?
   - Operational overhead (monitoring, maintenance)
   - Team expertise with technology

3. **Scalability**
   - Horizontal scaling capability
   - Vertical scaling limits
   - Cost of scaling

4. **Maintainability**
   - Code complexity
   - Team familiarity
   - Long-term maintenance burden

5. **Cost**
   - Infrastructure costs
   - Development time
   - Operational costs

6. **Risk**
   - Technology maturity
   - Vendor lock-in
   - Migration difficulty

**Decision Framework:**
- ✅ **Pragmatist Principle** - Simplicity over speculation
- ✅ **YAGNI** - You Aren't Gonna Need It (avoid premature optimization)
- ✅ **Evidence-based** - Benchmark before optimizing
- ✅ **Reversibility** - Prefer reversible decisions when possible

---

## 🎯 Key Design Principles

### 1. **Tie-Breaking Authority**
- **3-member council** prevents deadlock (odd number)
- **Majority rule** (2-1 or 3-0 decisions)
- **Independent analysis** (each architect evaluates separately)

### 2. **Escalation Hierarchy**
- **Simple disputes** → Orchestrator decides
- **Architectural disputes** → Architect(s) decide
- **Critical path** → User approves

### 3. **Documentation Requirements**
- All architectural decisions logged (ADRs)
- Reasoning documented (why not alternatives)
- Migration path noted (if decision needs reversal)

---

## 📊 Architect's Audit Trail

Architects log all decisions:

```bash
.git/audit/architectural-decisions.log
  - All council votes
  - Vote breakdown (2-1, 3-0, etc.)
  - Reasoning for each vote

.git/audit/architecture-reviews.log
  - Planner spec reviews
  - Dev escalations resolved
  - QA security consultations

docs/architecture/ADRs/
  - ADR-001-idempotency-storage.md
  - ADR-002-async-processing.md
  - [Architectural Decision Records]
```

---

## 💡 Why Architecture Council is Critical

**Without 3-member council:**
- **2 architects** = deadlock risk (1-1 votes)
- **1 architect** = single point of failure (no peer review)
- **4+ architects** = slow decision-making (too many voices)

**With 3-member council:**
- ✅ **Tie-breaking** guaranteed (2-1 minimum)
- ✅ **Diverse perspectives** (3 independent evaluations)
- ✅ **Prevents bad decisions** (requires majority, not unanimity)
- ✅ **Peer review built-in** (architects review each other's votes)

---

## 🔄 Message Flow Examples

### Example 1: Architecture Council Vote
```
Dev-A + Dev-B disagree on Redis vs PostgreSQL
       ↓
Orchestrator determines: Architectural dispute
       ↓
Orchestrator → Architecture Council: ArchitecturalReview
       ↓
Architect-A: Analyzes independently → Votes Redis
Architect-B: Analyzes independently → Votes PostgreSQL
Architect-C: Analyzes independently → Votes PostgreSQL
       ↓
Vote Result: 2-1 for PostgreSQL
       ↓
Architecture Council → Devs: ArchitecturalDecision (PostgreSQL)
       ↓
Both Devs implement PostgreSQL (decision binding)
```

### Example 2: Planner Spec Review
```
Planner-A → Architect-B: TechnicalFeasibilityReview
  "Spec for order_idempotency, 1 week, Redis"
       ↓
Architect-B: Reviews specification
       ↓
Architect-B → Planner-A: FeasibilityRejection
  "Redis adds complexity, PostgreSQL sufficient"
       ↓
Planner-A: Revises spec (PostgreSQL, 1 week)
       ↓
Planner-A → Architect-B: RevisedSpecReview
       ↓
Architect-B → Planner-A: FeasibilityApproved
  "✅ Revised approach sound"
```

### Example 3: Planner Disagreement
```
Planner-A: "1 week, PostgreSQL"
Planner-B: "3 weeks, Redis"
       ↓
Planner-B → Architecture Council: ArchitecturalReview
       ↓
Council votes: 2-1 for Planner-A approach
       ↓
Architecture Council → Both Planners: ArchitecturalDecision
  "Proceed with 1 week, PostgreSQL"
       ↓
Both Planners align on decision
```

---

## Summary Table

| Aspect | Details |
|--------|---------|
| **Council Size** | 3 members (Architect-A, Architect-B, Architect-C) |
| **Voting** | Majority rule (2-1 or 3-0 decisions) |
| **Authority** | Binding decisions on architecture |
| **Primary Tools** | Filesystem MCP, Git MCP, Context7, Terminal MCP, Serena |
| **Interactions** | Planners (review), Devs (escalation), QA (security), Council (voting) |
| **Escalates To** | User (critical path only) |
| **Escalates From** | Planners, Devs, QA, Orchestrator |
| **Decision Criteria** | Performance, complexity, scalability, maintainability, cost, risk |
| **Principles** | Pragmatist, YAGNI, evidence-based, reversibility |

---

## 🔒 Security Features Implementation

Architects participate in implementing and enforcing security features, particularly around architectural decisions. For comprehensive implementation details, see **[SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md)**.

### Architect-Specific Security Responsibilities:

#### 1. **Message Passing System Usage**
Architects use the message passing system for council voting and architectural reviews:
- Send/receive architectural review requests
- Coordinate council votes via messages
- Verify message integrity for critical decisions
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Passing](SECURITY_IMPLEMENTATION.md#1-message-passing-system)

**Example Council Vote Message:**
```yaml
---
message_id: MSG-ARCH-12345
from: Orchestrator
to: Architecture-Council
type: ArchitecturalReview
timestamp: 2025-11-16T21:00:00Z
hash: a1b2c3d4e5f6...
---

# Architectural Review Request

**Dispute:** Storage backend for idempotency keys

**Position A (Dev-A):** PostgreSQL
- Transactional consistency
- No new dependency

**Position B (Dev-B):** Redis
- Faster lookups
- Built-in TTL

**Context:** 100 requests/sec, 1-hour TTL required

**Deadline:** 24 hours
```

#### 2. **Write Lock Coordination** (Architectural Documentation)
Architects may request write locks when creating/updating architectural decision records (ADRs):
```python
# When creating ADR requiring multiple file updates
request_write_lock(
    requester="Architect-A",
    files=["docs/architecture/ADRs/ADR-015-cache-strategy.md",
           "docs/architecture/diagrams/cache-flow.png",
           "docs/architecture/README.md"],
    estimated_time=1800  # 30 minutes
)
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Write Lock Coordination](SECURITY_IMPLEMENTATION.md#2-write-lock-coordination)

#### 3. **GPG Commit Signing** (ADR Documentation)
Architects sign all commits to architectural documentation:
```bash
# Architect-A's GPG key for ADR commits
gpg --sign-key architect-a@workflow.local

# All ADR commits must be signed
git commit -S -m "ADR-015: Cache strategy decision

Architecture Council vote: 2-1 for Redis caching

Reasoning:
- 100k req/sec projected scale
- Sub-10ms latency requirement
- PostgreSQL insufficient at this scale

Voting:
- Architect-A: Redis (performance critical)
- Architect-B: PostgreSQL (simplicity)
- Architect-C: Redis (evidence-based benchmarking)

Decision: Redis with fallback to PostgreSQL"
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § GPG Signing](SECURITY_IMPLEMENTATION.md#3-gpg-commit-signing)

#### 4. **Tertiary Review Participation**
Architects may be assigned as tertiary reviewers for architectural decisions made by Developers:
```python
def handle_tertiary_review_request(primary, peer, feature):
    # Architect provides independent architectural review
    review = {
        "architectural_soundness": analyze_architecture(feature),
        "technical_debt": assess_technical_debt(feature),
        "scalability": evaluate_scalability(feature),
        "maintainability": check_maintainability(feature)
    }

    # Flag if primary + peer missed architectural issues
    if review["architectural_soundness"] == "POOR":
        escalate_to_librarian("Peer review missed architectural issues")
        send_message(primary, "ArchitecturalConcerns", review)
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Tertiary Reviews](SECURITY_IMPLEMENTATION.md#4-tertiary-reviews-random-10)

#### 5. **Collusion Detection** (Council Voting Patterns)
Architects' voting patterns are monitored to detect collusion within the council:
```python
def detect_council_collusion():
    # Check if 2 architects always vote together
    patterns = load_council_voting_history()

    for pair in [("Architect-A", "Architect-B"),
                 ("Architect-B", "Architect-C"),
                 ("Architect-A", "Architect-C")]:
        agreement_rate = calculate_agreement_rate(pair, patterns)

        # 90%+ agreement over 20+ votes = collusion risk
        if agreement_rate > 0.90 and len(patterns) > 20:
            alert_librarian("COUNCIL_COLLUSION_RISK", {
                "pair": pair,
                "agreement_rate": agreement_rate,
                "severity": "HIGH"
            })
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Collusion Detection](SECURITY_IMPLEMENTATION.md#5-collusion-detection)

#### 6. **2FA User Confirmation** (Critical Architectural Decisions)
Certain architectural decisions require 2FA user confirmation:
```python
def architectural_decision_requires_2fa(decision):
    # 2FA required for:
    # - New infrastructure dependencies (databases, caches)
    # - Security architecture changes (auth methods)
    # - Data model breaking changes
    # - Cloud provider changes

    critical_keywords = ["database", "auth", "security", "cloud", "breaking"]

    if any(kw in decision.lower() for kw in critical_keywords):
        return request_2fa_confirmation(
            decision_type="ARCHITECTURAL_DECISION",
            details=decision
        )
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § 2FA Confirmation](SECURITY_IMPLEMENTATION.md#6-2fa-user-confirmation)

#### 7. **Cumulative Change Detection** (ADR Documentation)
Architects' ADR commits are tracked for cumulative change detection:
- Large volumes of architectural changes (many ADRs in short time) trigger alerts
- Prevents "architecture creep" without proper review
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Cumulative Change Detection](SECURITY_IMPLEMENTATION.md#7-cumulative-change-detection)

#### 8. **Rate Limiting** (Council Votes)
Architects are subject to rate limiting:
```python
ARCHITECT_RATE_LIMITS = {
    "adr_commits_per_day": 5,          # Max 5 ADR commits/day
    "council_votes_per_day": 10,       # Max 10 votes/day
    "messages_per_minute": 10          # Max 10 messages/min
}

def check_architect_rate_limit(architect, action):
    count = count_actions(architect, action, window)
    if count >= threshold:
        send_message(architect, "RateLimitExceeded", {
            "action": action,
            "limit": threshold,
            "current": count,
            "reason": "Prevent automation abuse"
        })
        return False
    return True
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Rate Limiting](SECURITY_IMPLEMENTATION.md#8-rate-limiting)

#### 9. **Message Integrity Verification** (Council Votes)
All council vote messages are integrity-verified:
```python
def cast_council_vote(architect, decision, vote):
    # Create vote message
    vote_message = {
        "architect": architect,
        "decision": decision,
        "vote": vote,
        "reasoning": reasoning,
        "timestamp": datetime.now().isoformat()
    }

    # Calculate hash for integrity
    content = json.dumps(vote_message, sort_keys=True)
    hash = hashlib.sha256(content.encode()).hexdigest()

    # Register message
    register_message(message_id, hash)

    # Send to council
    send_message("Architecture-Council", vote_message)
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Integrity](SECURITY_IMPLEMENTATION.md#9-message-integrity-verification)

#### 10. **Audit Trail Logging** (All Architectural Decisions)
All architectural decisions are comprehensively logged:
```bash
.git/audit/architectural-decisions.log
  - All council votes with timestamps
  - Vote breakdown (Architect-A: Redis, Architect-B: PostgreSQL, etc.)
  - Reasoning for each vote
  - Dissenting opinions documented
  - Decision outcome (binding)

.git/audit/architecture-reviews.log
  - Planner spec reviews (approved/rejected)
  - Dev escalations resolved
  - QA security consultations
  - Tertiary review assignments

docs/architecture/ADRs/
  - ADR-001-idempotency-storage.md (GPG signed)
  - ADR-002-async-processing.md (GPG signed)
  - [All architectural decision records]
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Audit Trail](SECURITY_IMPLEMENTATION.md#10-audit-trail-logging)

### Architect Security Workflow Example:

```
┌─────────────────────────────────────────────────────────┐
│ ARCHITECTURAL REVIEW REQUEST (via Message Passing)      │
└─────────────────────────────────────────────────────────┘
         │
         ├─> Receive message (verify SHA-256 hash)
         ├─> Request write lock (if creating ADR)
         ├─> Analyze architectural implications independently
         ├─> Cast vote (GPG-signed message)
         ├─> Create ADR if decision made (GPG-signed commit)
         ├─> Log to audit trail (vote + reasoning)
         └─> Send decision message (SHA-256 hash)
         │
         ▼
    [Decision Requires 2FA?]
         │
         ├─ YES ──> Request user confirmation (critical infrastructure)
         └─ NO ──> Proceed with decision
         │
         ▼
    [Release Write Lock]
    [Log to Audit Trail]
```

### Critical Security Considerations for Architects:

1. **Council Independence** - Each architect analyzes independently (no discussion before voting)
2. **Vote Integrity** - All votes GPG-signed and SHA-256 hashed for tampering detection
3. **Collusion Monitoring** - Voting patterns tracked to detect rubber-stamping
4. **2FA for Critical Decisions** - Infrastructure/security changes require user confirmation
5. **Audit Trail** - All votes, reasoning, and dissents permanently logged

**Purpose:** Ensure architectural decisions are made through independent analysis with cryptographic proof of authenticity and comprehensive audit trails.

---

**The Architecture Council is the tie-breaking authority that ensures system architecture decisions are made with diverse perspectives and cannot be deadlocked by single-architect disagreements.**
