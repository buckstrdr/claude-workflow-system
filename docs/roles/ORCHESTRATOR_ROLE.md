# 🎯 Orchestrator: Complete Role & Interactions

**Position:** Master coordinator and decision authority
**Instance Type:** Central coordination hub
**Primary Function:** Task assignment, quality gate management, conflict resolution
**Key Characteristic:** Highest authority (but requires Librarian co-signature for critical actions)

---

## 🎭 Core Identity

**Why Orchestrator:**
- **Central coordination** - Single point of coordination for all instances
- **Task assignment** - Distributes work based on role capabilities
- **Quality gate management** - Tracks feature progress through 5 gates
- **Conflict resolution** - Resolves disputes between roles
- **Write lock management** - Prevents concurrent edit conflicts

**Authority Level:** Highest among instances, but:
- **Librarian co-signature required** for critical decisions
- **User escalation required** for critical path decisions
- **Cannot override** Librarian veto

---

## 🔐 Core Responsibilities

### 1. **Task Assignment and Coordination**

Orchestrator receives feature requests and coordinates implementation:

**Workflow:**
```
User → Orchestrator: FeatureRequest
  "Implement order idempotency with 1-hour TTL"
       ↓
Orchestrator analyzes:
  - Scope and complexity
  - Required roles (Planner, Architect, Dev, QA, Docs)
  - Dependencies
  - Priority
       ↓
Orchestrator → Planner-A: TaskAssignment
  "Create specification for order idempotency
   Requirements: 1-hour TTL, Redis or PostgreSQL
   Deadline: 2 days"
       ↓
Planner-A → Orchestrator: SpecificationComplete
       ↓
Orchestrator → Architect: TechnicalFeasibilityReview
       ↓
Architect → Orchestrator: FeasibilityApproved
       ↓
Orchestrator → Dev-A: ImplementationAssignment
  "Implement per specification [link]
   Architect approved: PostgreSQL approach
   Follow TDD: Tests first, then implementation"
       ↓
[Continues through all 5 quality gates]
```

---

### 2. **Quality Gate Management (5-Stage Progression)**

Orchestrator tracks features through **5 quality gates** and requires **Librarian co-signature** for advancement:

#### Gate 1: RED (Tests First)
```
Dev-A → Orchestrator: WriteRequest (commit tests)
       ↓
Orchestrator grants lock
       ↓
Dev-A commits tests (all failing - RED phase)
       ↓
Dev-A → Orchestrator: GateAdvancementRequest (Gate 1 → Gate 2)
  "Tests committed: 12 tests, all failing
   Files: tests/test_idempotency.py"
       ↓
Orchestrator → Librarian: CoSignatureRequest
  "Gate 1 advancement for order_idempotency
   Evidence: 12 tests committed, verified failing"
       ↓
Librarian verifies independently via Git MCP
       ↓
Librarian → Orchestrator: CoSignatureApproved
       ↓
Orchestrator advances feature to Gate 2
       ↓
Orchestrator → Dev-A: GateAdvancementApproved
  "✅ Gate 2 (GREEN) - Proceed with implementation"
```

#### Gate Progression:
1. **RED** - Tests written, failing
2. **GREEN** - Implementation passes tests
3. **PEER** - 4-eyes peer review (if >50 LOC or >3 files or high-risk)
4. **QA** - Quality assurance verification
5. **DEPLOY** - Production deployment approval

---

### 3. **Write Lock Management**

Orchestrator prevents concurrent edits through write lock coordination:

**Lock Request:**
```
Dev-A → Orchestrator: WriteRequest
  "Need to commit implementation for order_idempotency
   Files: src/idempotency.py
   Estimated time: 2 minutes"
       ↓
Orchestrator checks:
  - Is lock held by another role?
  - Is feature at appropriate gate?
  - Does requester have authorization?
       ↓
    ┌───┴───┐
    │       │
AVAILABLE  HELD
    │       │
    ↓       ↓
```

**Lock Available:**
```
Orchestrator → Dev-A: WriteLockGrant
  "Lock granted for 5 minutes
   Files: src/idempotency.py
   Proceed immediately"
       ↓
Dev-A commits changes
       ↓
Dev-A → Orchestrator: WriteComplete
  "Commit successful: abc123"
       ↓
Orchestrator releases lock
```

**Lock Held:**
```
Orchestrator → Dev-A: WriteLockQueued
  "Lock held by QA-A (3 minutes remaining)
   You are position #2 in queue
   Estimated wait: 5 minutes"
       ↓
Dev-A waits (uses time for other tasks)
       ↓
QA-A completes and releases lock
       ↓
Orchestrator → Dev-A: WriteLockGrant
  "Lock now available, proceed"
```

**Lock Timeout:**
- If lock held >5 minutes without WriteComplete
- Auto-release + warning logged
- Orchestrator may reassign task

---

### 4. **Decision Authority (Autonomous vs Escalation)**

Orchestrator decides autonomously with relevant sign-offs, escalates critical path to User:

#### Autonomous Decisions (Librarian/Role Co-Sign):

| Decision Type | Orchestrator + Required Sign-Off | Example |
|---------------|----------------------------------|---------|
| **Technical implementation** | Dev + QA | Which data structure to use |
| **Quality gate interpretation** | QA + (Librarian or Architect) | Whether coverage meets 80% standard |
| **Task prioritization** | Planner + (Dev or QA) | Order of task execution |
| **Tool/skill selection** | Librarian + requesting role | Which MCP tool to use (Context7 vs Firecrawl) |
| **Refactoring approach** | Dev + QA | How to restructure code |
| **Test strategy** | QA + Dev | Unit vs integration test mix |

**Process:**
```
Dev-A → Orchestrator: "Should I use Map or Set for lookup?"
       ↓
Orchestrator applies /pragmatist principles:
  - YAGNI (You Aren't Gonna Need It)
  - Simpler is better
  - Choose reversible decisions
       ↓
Orchestrator → Dev-B: "Dev-A asks Map vs Set, your input?"
       ↓
Dev-B → Orchestrator: "Set is simpler, no metadata needed currently"
       ↓
Orchestrator decides: Set
       ↓
Orchestrator → Dev-A: DecisionAnnouncement
  "Use Set for idempotency keys
   Reasoning: Simpler, meets current requirements (YAGNI)
   Can refactor to Map if metadata needed later"
       ↓
Decision logged in docs/feature/order_idempotency/decisions.md
```

#### User Escalation Required (Critical Path):

| Decision Type | Required Sign-Offs | Example |
|---------------|-------------------|---------|
| **Architecture changes** | Architect + Planner + Orchestrator → **User** | Microservices vs monolith |
| **Scope changes (>20%)** | Planner + (Dev or QA) + Orchestrator → **User** | Feature expands 1 week → 3 weeks |
| **Quality exceptions** | QA + Orchestrator → **User** | Skip TDD for emergency hotfix |
| **New dependencies** | Architect + Librarian + Orchestrator → **User** | Add Redis, new framework |
| **Timeline deviations (>50%)** | Planner + (Dev or QA) + Orchestrator → **User** | Estimated 2 days, actually 5 days |

**Example Critical Path Escalation:**
```
Architect → Orchestrator: "Need to add Redis for idempotency"
       ↓
Orchestrator: This is "new dependency" - requires User approval
       ↓
Orchestrator collects sign-offs:
  - Architect: Approves Redis
  - Librarian: Approves (operational complexity acceptable)
       ↓
Orchestrator → User: CriticalDecisionRequest
  "New dependency requested: Redis

   Reason: Idempotency with built-in TTL
   Impact: Operational complexity (new service to manage)
   Alternatives considered: PostgreSQL with pg_cron
   Recommendation: PostgreSQL sufficient for current scale

   Sign-offs:
   - Architect: Approves Redis
   - Librarian: Approves Redis

   Your decision required"
       ↓
User → Orchestrator: DecisionResponse
  "Approve PostgreSQL approach (simpler, adequate for scale)"
       ↓
Orchestrator → All roles: DecisionAnnouncement
  "User decision: PostgreSQL for idempotency
   Architect + Librarian + User agreed"
```

---

### 5. **Conflict Resolution and Dispute Mediation**

When roles disagree, Orchestrator mediates or escalates:

**Simple Technical Disputes (Orchestrator Resolves):**
```
Dev-A: "Use forEach loop"
Dev-B: "Use for...of loop"
       ↓
Dev-A + Dev-B → Orchestrator: DisputeResolution
       ↓
Orchestrator applies coding standards:
  - Check project standards doc
  - Apply pragmatist principle
       ↓
Orchestrator → Dev-A + Dev-B: DecisionAnnouncement
  "Use for...of (project standard, better readability)"
```

**Architectural Disputes (Escalate to Architect):**
```
Dev-A: "Use PostgreSQL"
Dev-B: "Use Redis"
       ↓
Orchestrator determines: Architectural decision
       ↓
Orchestrator → Architecture Council: ArchitecturalReview
  "Dev disagreement requires architectural input"
       ↓
Architecture Council votes: 2-1 for PostgreSQL
       ↓
Orchestrator → Dev-A + Dev-B: ArchitecturalDecision
  "Council decision: PostgreSQL (2-1 vote)"
```

---

### 6. **Emergency Bypass Authorization**

In genuine emergencies (production down, security breach), Orchestrator can authorize temporary single sign-off:

**Emergency Bypass Workflow:**
```
Production security vulnerability detected
       ↓
Dev-A → Orchestrator: EmergencyBypassRequest
  "CVE-2024-XXXX - critical SQL injection
   Need to patch immediately
   Cannot wait for full 4-eyes review"
       ↓
Orchestrator → Librarian: EmergencyBypassReview
  "Genuine emergency? Security breach confirmed?"
       ↓
Librarian → Orchestrator: EmergencyConfirmed
  "Yes, confirmed vulnerability, bypass justified"
       ↓
Orchestrator → User: EmergencyNotification
  "Emergency bypass authorized: Security patch
   Will require retrospective 4-eyes review within 24h"
       ↓
Orchestrator → Dev-A: EmergencyBypassGrant
  "✅ Emergency bypass approved
   Deploy immediately
   Create tech debt ticket for retrospective review"
       ↓
Dev-A deploys patch (single sign-off)
       ↓
Orchestrator creates: Tech debt ticket
  "Retrospective 4-eyes review of emergency security patch"
       ↓
Within 24 hours: QA-A + Dev-B perform full review
```

**Emergency Bypass Requirements:**
- **Librarian confirmation** (cannot be Orchestrator alone)
- **User notification** (immediate)
- **Technical debt ticket** created
- **Retrospective review** within 24 hours

---

## 🚀 System Initialization and Startup

### Orchestrator as First Instance

**The Orchestrator MUST be the first instance started** in the multi-instance system.

**Why Orchestrator starts first:**
1. Creates shared resources (message directories, lock files, registries)
2. Initializes coordination infrastructure
3. Provides registration service for other instances
4. Establishes health monitoring

### Startup Sequence

**Recommended startup order:**
```
1. Orchestrator (pane 0)     ← FIRST
2. Librarian (pane 1)        ← SECOND (verifies Orchestrator)
3. All other instances        ← PARALLEL
   (Planner-A/B, Architect-A/B/C, Dev-A/B, QA-A/B, Docs)
```

**See [OPERATIONS_GUIDE.md](../OPERATIONS_GUIDE.md) for complete tmux setup and startup procedures.**

### Orchestrator Initialization Workflow

When Orchestrator starts, it performs initialization:

```python
def initialize_orchestrator():
    """
    Orchestrator initialization on first startup.
    Creates all shared resources required by multi-instance system.
    """

    # 1. Create directory structure
    create_directories([
        ".git/messages",      # Inter-instance messages
        ".git/locks",         # Write lock coordination
        ".git/audit"          # Comprehensive audit logs
    ])

    # 2. Initialize message registry
    create_message_registry({
        "messages": [],
        "last_message_id": 0
    })

    # 3. Initialize write lock state
    create_write_lock_state({
        "current_lock": None,
        "queue": [],
        "lock_history": []
    })

    # 4. Initialize instance registry
    create_instance_registry({
        "instances": [],
        "last_heartbeat": {},
        "instance_status": {}
    })

    # 5. Initialize quality gate tracking
    create_gate_tracking({
        "features": {},
        "current_gates": {}
    })

    # 6. Initialize audit logs
    create_audit_logs([
        "orchestrator-decisions.log",
        "message-log.log",
        "write-lock-intents.json",
        "instance-health.log",
        "security-events.log"
    ])

    # 7. Log initialization complete
    log_audit("orchestrator-startup.log", {
        "event": "ORCHESTRATOR_INITIALIZED",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0"
    })

    # 8. Broadcast ready signal
    broadcast_ready_signal()
```

### Instance Registration Protocol

**When other instances start, they register with Orchestrator:**

```python
# Instance (e.g., Dev-A) on startup
def register_with_orchestrator():
    """
    All instances must register with Orchestrator on startup.
    """

    registration_message = {
        "type": "INSTANCE_REGISTRATION",
        "from": ROLE,              # e.g., "Dev-A"
        "pane": PANE_ID,           # e.g., 7
        "timestamp": datetime.now().isoformat(),
        "status": "READY",
        "capabilities": get_capabilities()
    }

    # Send registration to Orchestrator
    send_message("Orchestrator", registration_message)

    # Wait for acknowledgment (30 second timeout)
    ack = wait_for_message("REGISTRATION_ACK", timeout=30)

    if not ack:
        raise InstanceRegistrationError("Orchestrator did not acknowledge")

    # Load shared state
    load_message_registry()
    load_lock_state()
    load_instance_registry()

    # Enter ready state
    log("Instance $ROLE ready to receive messages")
```

**Orchestrator receives registration:**

```python
def handle_instance_registration(registration):
    """
    Orchestrator processes instance registration.
    """

    instance = registration["from"]
    pane = registration["pane"]

    # Add to instance registry
    instance_registry["instances"].append({
        "role": instance,
        "pane": pane,
        "status": "ACTIVE",
        "registered_at": datetime.now().isoformat()
    })

    # Initialize heartbeat tracking
    instance_registry["last_heartbeat"][instance] = datetime.now().isoformat()

    # Send acknowledgment
    send_message(instance, {
        "type": "REGISTRATION_ACK",
        "from": "Orchestrator",
        "registry": instance_registry,  # Share current registry
        "message": f"Welcome {instance}, registration successful"
    })

    # Log registration
    log_audit("instance-registrations.log", {
        "instance": instance,
        "pane": pane,
        "timestamp": datetime.now().isoformat()
    })

    # Broadcast to all instances (notify of new member)
    broadcast_message("ALL", {
        "type": "NEW_INSTANCE_JOINED",
        "instance": instance,
        "total_instances": len(instance_registry["instances"])
    })
```

### Health Monitoring (Orchestrator Responsibility)

**Orchestrator monitors all instance health via heartbeats:**

```python
def monitor_instance_health():
    """
    Orchestrator continuously monitors instance health.
    Runs in background thread.
    """

    while True:
        now = datetime.now()

        # Check for stale heartbeats (>2 minutes = 2 missed heartbeats)
        for instance, last_heartbeat in instance_registry["last_heartbeat"].items():
            age_seconds = (now - datetime.fromisoformat(last_heartbeat)).seconds

            if age_seconds > 120:  # 2 minutes
                handle_stale_instance(instance, age_seconds)

        # Sleep 30 seconds before next check
        time.sleep(30)

def handle_stale_instance(instance, age_seconds):
    """
    Handle instance with stale heartbeat.
    """

    log_audit("instance-health.log", {
        "event": "STALE_INSTANCE",
        "instance": instance,
        "last_heartbeat_age": age_seconds,
        "timestamp": datetime.now().isoformat()
    })

    # Alert Librarian
    send_message("Librarian", {
        "type": "INSTANCE_HEALTH_WARNING",
        "instance": instance,
        "last_heartbeat_age": age_seconds,
        "action": "Verify instance health"
    })

    # Check if instance actually crashed
    if not check_instance_alive(instance):
        handle_instance_crash(instance)

def handle_instance_crash(instance):
    """
    Handle crashed instance - critical event.
    """

    log_audit("instance-crashes.log", {
        "event": "INSTANCE_CRASHED",
        "instance": instance,
        "timestamp": datetime.now().isoformat()
    })

    # Alert Librarian + User (critical event)
    send_message("Librarian", {
        "type": "INSTANCE_CRASHED",
        "instance": instance,
        "severity": "CRITICAL",
        "action": "Consider SYSTEM_FREEZE"
    })

    alert_user("CRITICAL: Instance Crash", {
        "instance": instance,
        "impact": calculate_crash_impact(instance),
        "options": ["Auto-restart", "System freeze", "Manual intervention"]
    })

    # Reassign pending work (if possible)
    reassign_work_from_crashed_instance(instance)
```

### Instance Discovery

**Environment variables for each instance:**

```bash
# Set by startup script (see OPERATIONS_GUIDE.md)
export CLAUDE_ROLE="Orchestrator"      # Role name
export CLAUDE_PANE=0                   # Tmux pane ID
export CLAUDE_SESSION="claude-multi"   # Tmux session name
export CLAUDE_WORKSPACE=$(pwd)         # Project directory
```

**Instances use these to discover their identity and communicate:**

```python
# Read environment on startup
ROLE = os.environ["CLAUDE_ROLE"]           # e.g., "Dev-A"
PANE_ID = int(os.environ["CLAUDE_PANE"])   # e.g., 7
SESSION = os.environ["CLAUDE_SESSION"]     # "claude-multi"

# Calculate target pane for messages
def get_pane_for_role(target_role):
    """
    Map role name to tmux pane ID.
    """
    pane_map = {
        "Orchestrator": 0,
        "Librarian": 1,
        "Planner-A": 2,
        "Planner-B": 3,
        "Architect-A": 4,
        "Architect-B": 5,
        "Architect-C": 6,
        "Dev-A": 7,
        "Dev-B": 8,
        "QA-A": 9,
        "QA-B": 10,
        "Docs": 11
    }
    return pane_map.get(target_role)
```

### Complete Startup Example

```
[Start tmux session with 4×3 grid]
         │
         ▼
[Start Orchestrator in pane 0]
         │
         ├─> Orchestrator creates shared resources
         ├─> Initializes message registry
         ├─> Initializes write lock state
         ├─> Initializes instance registry
         ├─> Starts health monitoring thread
         └─> Broadcasts "ORCHESTRATOR_READY"
         │
         ▼
[Start Librarian in pane 1]
         │
         ├─> Librarian registers with Orchestrator
         ├─> Receives REGISTRATION_ACK
         ├─> Verifies Orchestrator initialization
         └─> Enters ready state
         │
         ▼
[Start all other instances in parallel]
         │
         ├─> Each instance registers with Orchestrator
         ├─> Each receives REGISTRATION_ACK + instance registry
         ├─> Each starts heartbeat thread (60s interval)
         └─> All enter ready state
         │
         ▼
[System fully initialized - ready for work]
```

**For complete tmux setup, startup scripts, and troubleshooting, see [OPERATIONS_GUIDE.md](../OPERATIONS_GUIDE.md).**

---

## 🔄 Interactions with Other Instances

### With All Roles (Broadcast/Coordination)

**Task Assignments:**
```
Orchestrator → Planner: "Create spec"
Orchestrator → Architect: "Review feasibility"
Orchestrator → Dev: "Implement feature"
Orchestrator → QA: "Verify implementation"
Orchestrator → Docs: "Update documentation"
```

**Quality Gate Updates:**
```
Orchestrator → ALL: GateProgressUpdate
  "Feature: order_idempotency advanced to Gate 3 (PEER)"
```

### With Librarian (Co-Signature)

**Critical Decision Co-Sign:**
```
Orchestrator → Librarian: CoSignatureRequest
Librarian → Orchestrator: CoSignatureApproved / Denied
```

**System Freeze Notification:**
```
Librarian → Orchestrator: SYSTEM_FREEZE
Orchestrator: Enters frozen state (denies all requests)
```

### With Planners (Task Planning)

**Specification Requests:**
```
Orchestrator → Planner-A: TaskAssignment (create spec)
Planner-A → Orchestrator: SpecificationComplete
```

**Planner Disagreement Routing:**
```
Planner-A + Planner-B → Orchestrator: Escalation
Orchestrator → Architecture Council: ArchitecturalReview
```

### With Architects (Technical Decisions)

**Feasibility Reviews:**
```
Orchestrator → Architect: TechnicalFeasibilityReview
Architect → Orchestrator: FeasibilityApproved / Rejected
```

**Dispute Escalation:**
```
Orchestrator → Architecture Council: ArchitecturalReview
Architecture Council → Orchestrator: ArchitecturalDecision
```

### With Developers (Implementation)

**Implementation Assignments:**
```
Orchestrator → Dev-A: ImplementationAssignment
Dev-A → Orchestrator: ImplementationComplete
```

**Write Lock Coordination:**
```
Dev-A → Orchestrator: WriteRequest
Orchestrator → Dev-A: WriteLockGrant
Dev-A → Orchestrator: WriteComplete
```

**Peer Review Routing:**
```
Dev-A → Orchestrator: PeerReviewNeeded (>50 LOC)
Orchestrator → Dev-B: PeerReviewRequest
Dev-B → Orchestrator: PeerReviewApproval
Orchestrator → Dev-A: GateAdvancementApproved (Gate 3)
```

### With QA (Quality Assurance)

**Test Strategy Approval:**
```
Orchestrator → QA-A: TestStrategyReview
QA-A → Orchestrator: TestStrategyApproved
```

**Coverage Verification:**
```
QA-A → Orchestrator: CoverageReport (85%)
Orchestrator: Verifies meets 80% standard
Orchestrator → QA-A: CoverageSufficient
```

### With Docs (Documentation)

**Documentation Assignments:**
```
Orchestrator → Docs: DocumentationRequest
  "Document order_idempotency feature
   Technical details from Dev-A
   Librarian will review for accuracy"
```

### With User (Critical Path Only)

**Critical Decision Escalation:**
```
Orchestrator → User: CriticalDecisionRequest
User → Orchestrator: DecisionResponse
```

**Emergency Notifications:**
```
Orchestrator → User: EmergencyNotification
  "Emergency bypass authorized for [reason]"
```

---

## 🛠️ Interactions with Tool Servers (MCP)

Orchestrator uses MCP tools for coordination and monitoring:

### Primary Tool Usage:

**1. Git MCP (Most Used)**
```python
# Track quality gate status
git_log = await git_mcp.git_log(limit=20)
recent_commits = parse_commits(git_log)

# Verify gate requirements
tests_committed = await git_mcp.git_diff("HEAD~1", "HEAD")
verify_only_tests(tests_committed)  # Gate 1 verification
```

**2. Filesystem MCP**
```python
# Check for file conflicts before granting lock
files_to_modify = ["src/idempotency.py"]
current_locks = get_active_locks()
if any_conflicts(files_to_modify, current_locks):
    queue_request()
else:
    grant_lock()
```

**3. Serena (Memory/Coordination)**
```python
# Track feature status across gates
await serena.remember(
    "feature_status",
    f"order_idempotency: Gate 3 (PEER) - awaiting Dev-B review"
)

# Recall ongoing work
active_features = await serena.recall("feature_status")

# Track write locks
await serena.remember("write_lock", {
    "holder": "Dev-A",
    "files": ["src/idempotency.py"],
    "granted_at": timestamp
})
```

**4. Terminal MCP**
```python
# Verify test execution
test_output = await terminal.run("pytest tests/ -v")
if "FAILED" in test_output:
    deny_gate_advancement("Tests failing")
else:
    approve_gate_advancement()
```

**5. Context7 / Firecrawl (Research for Decisions)**
```python
# Research best practices for dispute resolution
best_practices = await context7.fetch("python_loop_performance")
recommendation = analyze_best_practice(best_practices)
```

---

## 📋 Orchestrator's Decision Framework

### Decision Criteria:

1. **Documented Standards**
   - Check project coding standards
   - Check quality gate requirements
   - Check testing policies

2. **Pragmatist Principles**
   - YAGNI (You Aren't Gonna Need It)
   - Simpler is better
   - Evidence over speculation
   - Reversible > irreversible

3. **Risk Assessment**
   - Impact on timeline
   - Impact on quality
   - Impact on maintainability
   - Security implications

4. **Escalation Thresholds**
   - Simple technical → Orchestrator decides
   - Architectural → Architect decides
   - Critical path → User decides

---

## 🎯 Key Design Principles

### 1. **Coordination Not Control**
- Orchestrator **coordinates** work, doesn't dictate implementation
- Roles have autonomy within their domain
- Escalates when outside authority

### 2. **Checks and Balances**
- **Librarian co-signature** required for critical actions
- **User escalation** required for critical path
- **Cannot override** Librarian veto

### 3. **Transparency**
- All decisions logged and announced
- Reasoning documented
- Audit trail maintained

---

## 📊 Orchestrator's Audit Trail

Orchestrator logs all coordination activities:

```bash
.git/audit/orchestrator-decisions.log
  - All decisions made
  - Sign-offs collected
  - Reasoning documented

.git/audit/write-lock-intents.json
  - Lock requests/grants
  - Lock holders and duration
  - Queue status

.git/audit/quality-gates.json
  - Feature gate progression
  - Gate advancement approvals
  - Librarian co-signatures

docs/feature/<feature>/decisions.md
  - Feature-specific decisions
  - Rationale for technical choices
  - ADRs (Architectural Decision Records)
```

---

## 💡 Why Orchestrator is Critical

**Without Orchestrator:**
- No central coordination → chaos
- No write lock management → git conflicts
- No quality gate tracking → features bypass gates
- No dispute resolution → deadlocks

**With Orchestrator:**
- ✅ Central coordination hub
- ✅ Write lock prevents conflicts
- ✅ Quality gates enforced
- ✅ Disputes resolved efficiently
- ✅ Clear decision authority with checks (Librarian, User)

---

## 🔄 Message Flow Examples

### Example 1: Feature Implementation (Full Lifecycle)
```
User → Orchestrator: "Implement order idempotency"
Orchestrator → Planner-A: "Create specification"
Planner-A → Orchestrator: "Spec complete"
Orchestrator → Architect: "Review feasibility"
Architect → Orchestrator: "Feasibility approved (PostgreSQL)"
Orchestrator → Dev-A: "Implement per spec"
Dev-A → Orchestrator: "Need write lock for tests"
Orchestrator → Dev-A: "Lock granted"
Dev-A → Orchestrator: "Tests committed (Gate 1 complete)"
Orchestrator → Librarian: "Co-sign Gate 1 → 2?"
Librarian → Orchestrator: "Approved"
Orchestrator → Dev-A: "Gate 2 approved, implement"
[Continues through Gates 2-5]
```

### Example 2: Dispute Resolution
```
Dev-A + Dev-B → Orchestrator: "Disagree on Redis vs PostgreSQL"
Orchestrator: Determines architectural dispute
Orchestrator → Architecture Council: "Need vote"
Architecture Council → Orchestrator: "2-1 for PostgreSQL"
Orchestrator → Dev-A + Dev-B: "Council decision: PostgreSQL"
```

### Example 3: Emergency Bypass
```
Dev-A → Orchestrator: "Security CVE, need emergency bypass"
Orchestrator → Librarian: "Confirm emergency?"
Librarian → Orchestrator: "Confirmed, bypass justified"
Orchestrator → User: "Emergency bypass authorized"
Orchestrator → Dev-A: "Deploy immediately, retrospective review required"
```

---

## Summary Table

| Aspect | Details |
|--------|---------|
| **Authority** | Highest among instances (with Librarian co-sign for critical) |
| **Primary Duties** | Task assignment, quality gates, write locks, dispute resolution |
| **Autonomous Decisions** | Technical details (with role sign-off) |
| **User Escalation** | Critical path (architecture, scope, quality exceptions, dependencies, timeline) |
| **Cannot Override** | Librarian veto, User decisions |
| **Primary Tools** | Git MCP, Filesystem MCP, Serena, Terminal MCP |
| **Interactions** | ALL roles (central hub) |
| **Decision Framework** | Documented standards, pragmatist principles, risk assessment, escalation thresholds |

---

**The Orchestrator is the central coordination hub that ensures efficient work distribution, quality gate progression, and conflict resolution—while remaining subject to Librarian oversight and User authority on critical path decisions.**

---

## 🔐 Security Features Implementation

### 1. **Message Passing System (tmux-based)**

The Orchestrator coordinates all inter-instance communication via tmux-based message files:

**Technical Implementation:**
```bash
# Message file location
MESSAGE_DIR=".git/messages/"

# Message format (YAML frontmatter + Markdown)
---
message_id: MSG-001
from: Orchestrator
to: Dev-A
type: TaskAssignment
timestamp: 2025-11-16T21:00:00Z
hash: sha256_hash_of_content
---

# Task Assignment: Implement Order Idempotency

[Message content here]
```

**Message Types Orchestrator Sends:**
- `TaskAssignment` → Planner, Architect, Dev, QA, Docs
- `WriteLockGrant` → Dev, QA, Docs
- `WriteLockQueued` → Dev, QA, Docs
- `GateAdvancementApproved` → Dev, QA
- `DecisionAnnouncement` → ALL roles
- `CoSignatureRequest` → Librarian
- `ArchitecturalReview` → Architecture Council
- `CriticalDecisionRequest` → User
- `EmergencyNotification` → User

**Message Types Orchestrator Receives:**
- `SpecificationComplete` ← Planner
- `FeasibilityApproved` ← Architect
- `WriteRequest` ← Dev, QA, Docs
- `WriteComplete` ← Dev, QA, Docs
- `GateAdvancementRequest` ← Dev, QA
- `CoSignatureApproved` ← Librarian
- `PeerReviewApproval` ← Dev, QA
- `SYSTEM_FREEZE` ← Librarian

**Message Registry (SHA-256 Integrity):**
```python
# scripts/security/message_registry.py
import hashlib
import json

def register_message(message_id, message_path, registry_path):
    """Register message with SHA-256 hash"""
    with open(message_path, 'r') as f:
        content = f.read()
    
    # Calculate hash
    hash_value = hashlib.sha256(content.encode()).hexdigest()
    
    # Register in registry
    registry = load_registry(registry_path)
    registry.append({
        "message_id": message_id,
        "hash": hash_value,
        "timestamp": datetime.now().isoformat(),
        "from": extract_from(content),
        "to": extract_to(content)
    })
    save_registry(registry, registry_path)
    
    return hash_value

def verify_message(message_id, message_path, registry_path):
    """Verify message hasn't been tampered with"""
    with open(message_path, 'r') as f:
        content = f.read()
    
    current_hash = hashlib.sha256(content.encode()).hexdigest()
    
    registry = load_registry(registry_path)
    registered = next(m for m in registry if m["message_id"] == message_id)
    
    if current_hash != registered["hash"]:
        raise MessageTamperingError(f"Message {message_id} has been tampered with!")
    
    return True
```

**tmux Message Routing:**
```bash
# Orchestrator sends message to Dev-A
send_message() {
    local to_role=$1
    local message_file=$2
    
    # Write message file
    cat > ".git/messages/${message_file}" <<EOF
[message content]
EOF
    
    # Register message (SHA-256 hash)
    python3 scripts/security/message_registry.py register \
        --message-id "${message_file}" \
        --message-path ".git/messages/${message_file}"
    
    # Send notification to role's tmux pane
    tmux send-keys -t "claude-multi:${to_role}" \
        "cat .git/messages/${message_file}" C-m
}
```

---

### 2. **Write Lock Coordination**

**Lock Management Data Structure:**
```json
{
  "current_lock": {
    "holder": "Dev-A",
    "files": ["src/idempotency.py"],
    "granted_at": "2025-11-16T21:00:00Z",
    "expires_at": "2025-11-16T21:05:00Z",
    "purpose": "implement idempotency"
  },
  "queue": [
    {
      "requester": "QA-A",
      "files": ["tests/test_idempotency.py"],
      "requested_at": "2025-11-16T21:02:00Z",
      "estimated_time": 120
    }
  ]
}
```

**Lock Grant Algorithm:**
```python
# Orchestrator's write lock management
def handle_write_request(requester, files, estimated_time):
    lock_state = load_lock_state()
    
    # Check if lock is available
    if lock_state["current_lock"] is None:
        # Grant immediately
        grant_lock(requester, files, estimated_time)
        send_message(requester, "WriteLockGrant", {
            "timeout": estimated_time or 300,  # 5 min default
            "files": files
        })
    else:
        # Check for file conflicts
        if has_file_conflict(files, lock_state["current_lock"]["files"]):
            # Queue the request
            queue_request(requester, files, estimated_time)
            position = len(lock_state["queue"])
            send_message(requester, "WriteLockQueued", {
                "holder": lock_state["current_lock"]["holder"],
                "position": position,
                "estimated_wait": calculate_wait_time(lock_state)
            })
        else:
            # No conflict, grant lock
            grant_lock(requester, files, estimated_time)
    
def handle_write_complete(requester):
    lock_state = load_lock_state()
    
    # Verify requester holds lock
    if lock_state["current_lock"]["holder"] != requester:
        raise LockViolation(f"{requester} doesn't hold lock!")
    
    # Release lock
    release_lock()
    
    # Process queue
    if lock_state["queue"]:
        next_requester = lock_state["queue"][0]
        grant_lock(
            next_requester["requester"],
            next_requester["files"],
            next_requester["estimated_time"]
        )
        send_message(next_requester["requester"], "WriteLockGrant")
```

**Lock Timeout Enforcement:**
```python
# Background task checks for lock timeouts
def check_lock_timeout():
    while True:
        time.sleep(30)  # Check every 30 seconds
        
        lock_state = load_lock_state()
        if lock_state["current_lock"]:
            if datetime.now() > lock_state["current_lock"]["expires_at"]:
                # Lock timeout - force release
                holder = lock_state["current_lock"]["holder"]
                log_violation(f"Lock timeout: {holder} held lock >5 minutes")
                release_lock()
                
                # Alert Librarian
                send_message("Librarian", "LockTimeoutViolation", {
                    "holder": holder,
                    "duration": calculate_duration(lock_state["current_lock"])
                })
```

---

### 3. **GPG Commit Signing (Not Orchestrator, but Enforces)**

Orchestrator verifies all commits are GPG-signed via git hooks:

**Verification (git hook):**
```bash
# .git/hooks/pre-receive (server-side enforcement)
#!/bin/bash

while read oldrev newrev refname; do
    # Get commits being pushed
    commits=$(git rev-list $oldrev..$newrev)
    
    for commit in $commits; do
        # Verify commit is GPG-signed
        if ! git verify-commit $commit 2>/dev/null; then
            echo "❌ Commit $commit is not GPG-signed!"
            echo "All commits must be signed with GPG key"
            exit 1
        fi
        
        # Verify signature is from valid role
        signer=$(git log -1 --format='%GK' $commit)
        if ! is_valid_role_key "$signer"; then
            echo "❌ Commit signed with invalid key: $signer"
            exit 1
        fi
    done
done
```

---

### 4. **Tertiary Reviews (Random 10%)**

Orchestrator randomly assigns third-party reviewers to detect collusion:

**Implementation:**
```python
def handle_peer_review_approval(reviewer, reviewee, feature):
    """After peer review approved, maybe assign tertiary review"""
    
    # Random 10% selection
    if random.random() < 0.10:
        # Select independent third reviewer
        available_reviewers = get_independent_reviewers(reviewer, reviewee)
        tertiary_reviewer = random.choice(available_reviewers)
        
        # Log tertiary review assignment
        log_tertiary_review(feature, reviewee, reviewer, tertiary_reviewer)
        
        # Send tertiary review request
        send_message(tertiary_reviewer, "TertiaryReviewRequest", {
            "feature": feature,
            "primary_author": reviewee,
            "peer_reviewer": reviewer,
            "purpose": "Independent verification (random selection)",
            "focus": "Verify peer review was thorough, not rubber-stamped"
        })
        
        # Hold gate advancement until tertiary complete
        return "TERTIARY_REVIEW_PENDING"
    else:
        # No tertiary review, proceed
        return "PEER_REVIEW_COMPLETE"

def get_independent_reviewers(reviewer, reviewee):
    """Get reviewers who are independent from both parties"""
    all_roles = ["Dev-A", "Dev-B", "QA-A", "QA-B", "Architect-A", "Architect-B", "Architect-C"]
    
    # Exclude the reviewer and reviewee
    independent = [r for r in all_roles if r not in [reviewer, reviewee]]
    
    return independent
```

**Tertiary Review Log:**
```json
{
  "tertiary_reviews": [
    {
      "feature": "order_idempotency",
      "primary_author": "Dev-A",
      "peer_reviewer": "Dev-B",
      "tertiary_reviewer": "QA-A",
      "selected_at": "2025-11-16T21:00:00Z",
      "outcome": "approved",
      "findings": "Peer review was thorough, no issues found"
    }
  ]
}
```

---

### 5. **Collusion Detection Monitoring**

Orchestrator tracks peer review patterns and alerts Librarian:

**Pattern Tracking:**
```python
def track_peer_review_pattern(reviewer, reviewee, outcome):
    """Track who reviews whom and outcomes"""
    patterns = load_review_patterns()
    
    pair = f"{reviewer}->{reviewee}"
    if pair not in patterns:
        patterns[pair] = {
            "total_reviews": 0,
            "approvals": 0,
            "rejections": 0,
            "avg_review_time": 0,
            "feedback_depth": []
        }
    
    patterns[pair]["total_reviews"] += 1
    if outcome == "approved":
        patterns[pair]["approvals"] += 1
    else:
        patterns[pair]["rejections"] += 1
    
    # Check for suspicious patterns
    approval_rate = patterns[pair]["approvals"] / patterns[pair]["total_reviews"]
    
    if approval_rate > 0.95 and patterns[pair]["total_reviews"] > 10:
        # Suspicious: >95% approval rate over 10+ reviews
        alert_librarian("CollisionSuspicion", {
            "pair": pair,
            "approval_rate": approval_rate,
            "total_reviews": patterns[pair]["total_reviews"],
            "reason": "Unusually high approval rate suggests rubber-stamping"
        })
```

---

### 6. **Cumulative Change Detection**

Orchestrator tracks cumulative LOC changes to prevent salami-slicing:

**Tracking:**
```python
def track_cumulative_changes(role, files_changed, loc_changed):
    """Track cumulative changes by role over 24-hour window"""
    cumulative = load_cumulative_changes()
    
    # Add to 24-hour window
    cumulative[role].append({
        "timestamp": datetime.now().isoformat(),
        "files": files_changed,
        "loc": loc_changed
    })
    
    # Remove entries older than 24 hours
    cutoff = datetime.now() - timedelta(hours=24)
    cumulative[role] = [
        entry for entry in cumulative[role]
        if datetime.fromisoformat(entry["timestamp"]) > cutoff
    ]
    
    # Calculate total LOC in last 24 hours
    total_loc = sum(entry["loc"] for entry in cumulative[role])
    
    # Alert if exceeds threshold
    if total_loc > 500:  # Example threshold
        alert_librarian("CumulativeChangeExceeded", {
            "role": role,
            "total_loc": total_loc,
            "time_window": "24 hours",
            "individual_commits": len(cumulative[role]),
            "reason": "Many small commits totaling significant change"
        })
```

---

### 7. **Rate Limiting Enforcement**

Orchestrator enforces per-role rate limits:

**Rate Limits:**
```python
RATE_LIMITS = {
    "commits_per_hour": 20,
    "messages_per_minute": 10,
    "write_lock_requests_per_hour": 30,
    "gate_advancement_requests_per_hour": 10
}

def check_rate_limit(role, action):
    """Check if role has exceeded rate limit for action"""
    limits = load_rate_limits()
    
    # Get time window for action
    window = get_time_window(action)  # hour or minute
    
    # Count actions in window
    count = count_actions(role, action, window)
    threshold = RATE_LIMITS[f"{action}_per_{window}"]
    
    if count >= threshold:
        # Rate limit exceeded
        send_message(role, "RateLimitExceeded", {
            "action": action,
            "count": count,
            "threshold": threshold,
            "window": window,
            "retry_after": calculate_retry_time(limits, role, action)
        })
        
        # Alert Librarian if excessive
        if count > threshold * 2:
            alert_librarian("ExcessiveRateViolation", {
                "role": role,
                "action": action,
                "count": count,
                "threshold": threshold
            })
        
        return False
    
    return True
```

---

### 8. **Audit Trail Logging**

Orchestrator logs all coordination activities:

**Log Format:**
```bash
# .git/audit/orchestrator-decisions.log
[2025-11-16T21:00:00Z] | TASK_ASSIGNMENT | order_idempotency | Dev-A | Planner-A spec approved
[2025-11-16T21:05:00Z] | WRITE_LOCK_GRANT | Dev-A | src/idempotency.py | 5min timeout
[2025-11-16T21:07:00Z] | GATE_ADVANCEMENT | order_idempotency | Gate 1->2 | Librarian co-signed
[2025-11-16T21:10:00Z] | PEER_REVIEW | Dev-A->Dev-B | APPROVED | 120 LOC
[2025-11-16T21:11:00Z] | TERTIARY_REVIEW | QA-A assigned | Random 10% selection
[2025-11-16T21:15:00Z] | DECISION | Map vs Set | SET chosen | Pragmatist principle (YAGNI)
```

**Logging Implementation:**
```python
def log_decision(decision_type, details):
    """Log all Orchestrator decisions to audit trail"""
    timestamp = datetime.now().isoformat()
    
    log_entry = f"[{timestamp}] | {decision_type} | {format_details(details)}\n"
    
    with open(".git/audit/orchestrator-decisions.log", "a") as f:
        f.write(log_entry)
    
    # Also log to Serena for queryable history
    serena.remember("orchestrator_decision", {
        "timestamp": timestamp,
        "type": decision_type,
        "details": details
    })
```

