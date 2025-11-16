# 📚 Librarian: Complete Role & Interactions

**Position:** Independent oversight and veto authority
**Instance Type:** Read-only security monitor
**Primary Function:** System integrity guardian and emergency brake
**Key Characteristic:** Cannot commit code, has no write access (by design)

---

## 🔐 Core Responsibilities

### 1. **Orchestrator Oversight (Co-Signature Authority)**

The Librarian co-signs **critical Orchestrator decisions** to prevent rogue behavior:

| Orchestrator Action | Librarian's Verification |
|---------------------|-------------------------|
| **Quality gate advancement** | Verify requirements actually met (tests passing, coverage OK, docs updated) |
| **Write lock grant** | Verify no conflicts, request is legitimate |
| **Emergency bypass authorization** | Verify genuine emergency + User approval required |
| **Critical decisions** | Verify decision genuinely critical, not premature escalation |
| **Gate status modification** | Verify legitimate rollback/fix, not bypass attempt |

**Example Co-Signature Workflow:**
```
Orchestrator: "Want to advance feature to Gate 3"
       ↓
Orchestrator → Librarian: CoSignatureRequest
  - Feature: order_idempotency
  - Evidence: 12 tests committed, all failing (RED phase)
  - Gate 2 requirements met: YES
       ↓
Librarian: Independently verifies
  - Reads .git/logs to confirm test commits
  - Checks no implementation code committed yet
  - Verifies sign-offs present
       ↓
Librarian → Orchestrator: CoSignatureApproved
  "Verified independently. Gate advancement authorized."
       ↓
Orchestrator: Advances gate with Librarian co-signature logged
```

---

### 2. **System Freeze / Veto Authority**

The Librarian can **freeze the entire system** when violations are detected:

#### Automatic Veto Triggers:
- **3+ quality gate bypasses** detected
- **5+ write lock verifications** failed
- **Orchestrator override rate >5%**
- **Message integrity violations**
- **Multiple tertiary review blocks** for same pair (collusion detected)

#### Manual Veto Triggers:
- Librarian suspects **systemic compromise**
- Pattern of violations indicates **collusion**
- **User authenticity concerns**

**System Freeze Workflow:**
```
Librarian detects: 3 quality gate bypasses in 24 hours
       ↓
Librarian: AUTOMATIC VETO TRIGGERED
       ↓
Librarian → All Roles: SYSTEM_FREEZE
  "🛑 SYSTEM FROZEN BY LIBRARIAN

   Reason: Systemic quality gate violations

   All roles: CEASE WORK immediately

   No commits, no merges, no gate advancements until unfrozen."
       ↓
All roles stop work immediately
       ↓
Orchestrator: BLOCKED from granting write locks or advancing gates
       ↓
Librarian: Generates security audit report (30 min ETA)
       ↓
Librarian → User: SecurityAuditReport
  - Lists all violations with evidence
  - Common factors analysis
  - Recommendations for remediation
       ↓
User: Investigates root cause
       ↓
User: Remediates violations + approves unfreeze
       ↓
Librarian: Verifies remediation (checks hooks, env vars)
       ↓
Librarian → All Roles: SYSTEM_UNFROZEN
  "✅ Work may resume. Remediation completed."
```

**Critical:** Orchestrator **cannot override** Librarian veto. Only User can unfreeze after reviewing audit report.

---

### 3. **Documentation Review**

The Librarian reviews documentation for accuracy and completeness:

**Workflow:**
```
Docs → Librarian: ReviewRequest
  "Please review updated architecture docs"
       ↓
Librarian reviews for:
  - Accuracy (matches actual codebase)
  - Completeness (no missing critical info)
  - Context quality (properly explains design decisions)
       ↓
Librarian → Docs: Feedback
  "Approved" or "Revision needed: [specific issues]"
```

**Escalation:** For technical correctness, Docs also gets sign-off from Dev or QA.

---

### 4. **Tool/Skill Selection Consultation**

When roles need to select MCP tools or skills:

```
Dev-A → Orchestrator: "Need to fetch documentation, which tool?"
       ↓
Orchestrator → Librarian: "Firecrawl or Context7 for this use case?"
       ↓
Librarian: Reviews tool capabilities
       ↓
Librarian → Orchestrator: "Use Context7 - better for API docs retrieval"
       ↓
Orchestrator → Dev-A: "Use Context7 MCP tool"
```

---

## 🔄 Interactions with Other Instances

### With Orchestrator (Most Frequent)

**1. Co-Signature Requests**
```
Orchestrator → Librarian: CoSignatureRequest
Librarian → Orchestrator: CoSignatureApproved/Denied
```

**2. Tool Selection**
```
Orchestrator → Librarian: "Which tool for [task]?"
Librarian → Orchestrator: Recommendation
```

**3. Emergency Bypass**
```
Orchestrator → Librarian + User: EmergencyBypassRequest
  (Requires both Librarian + User approval)
```

### With Docs

**Documentation Review:**
```
Docs → Librarian: ReviewRequest
Librarian → Docs: Approved / RevisionNeeded
```

**Librarian's Own Reviews:**
```
Librarian → Docs: ReviewRequest (for Librarian's search quality)
Docs → Librarian: Feedback
```

### With All Roles (Broadcast)

**System Freeze:**
```
Librarian → ALL: SYSTEM_FREEZE
  (All roles must stop work immediately)
```

**System Unfreeze:**
```
Librarian → ALL: SYSTEM_UNFROZEN
  (Work may resume)
```

**Security Alerts:**
```
Librarian → ALL: SecurityAlert
  "Warning: Unusual pattern detected - [details]"
```

### With User (Direct Escalation)

**Security Audit Reports:**
```
Librarian → User: SecurityAuditReport
  (Bypasses Orchestrator - direct line to User)
```

**Unfreeze Approval:**
```
User → Librarian: UNFREEZE_APPROVED
  (After remediation verified)
```

---

## 🛠️ Interactions with Tool Servers (MCP)

The Librarian **uses MCP tools** for its oversight duties:

### Primary Tool Usage:

**1. Git MCP (Most Used)**
```python
# Verify gate requirements met
git_status = await git_mcp.git_status()
git_log = await git_mcp.git_log(limit=50)
git_diff = await git_mcp.git_diff()

# Check for commits since last gate
commits_since_gate = await git_mcp.git_log(since=last_gate_timestamp)
```

**2. Filesystem MCP**
```python
# Verify test files exist
test_files = await fs_mcp.list_files("tests/")

# Check implementation not committed yet (RED phase)
impl_files = await fs_mcp.list_files("src/")
```

**3. Serena (Memory/Context)**
```python
# Record co-signature in memory
await serena.remember(
    "co_signature",
    f"Gate 3 advancement approved for {feature_name}"
)

# Track violation patterns
violations = await serena.recall("security_violations")
```

**4. Context7 / Firecrawl (Documentation Verification)**
```python
# Verify docs match actual API behavior
api_docs = await context7.fetch("library_name")
# Compare against actual code implementation
```

**5. Terminal MCP**
```python
# Run verification commands
test_output = await terminal.run("pytest tests/ -v")
coverage_report = await terminal.run("pytest --cov=src tests/")
```

---

## 📋 Librarian's Decision Matrix

### Approves Co-Signature When:
- ✅ All requirements demonstrably met (verified via Git/FS MCP)
- ✅ Sign-offs present and valid (GPG signatures checked)
- ✅ No policy violations detected
- ✅ Audit trail complete

### Denies Co-Signature When:
- ❌ Requirements not met (tests missing, coverage low, etc.)
- ❌ Sign-offs missing or invalid
- ❌ Policy violations detected
- ❌ Suspicious patterns (timing, actors, frequency)

### Triggers System Freeze When:
- 🛑 Multiple violations detected (3+ gate bypasses)
- 🛑 Collusion patterns identified
- 🛑 Message integrity compromised
- 🛑 Orchestrator override rate excessive (>5%)

---

## 🎯 Key Design Principles

### 1. **Independence**
- **Read-only** - Cannot commit code (no conflict of interest)
- **Direct to User** - Reports bypass Orchestrator
- **Veto power** - Cannot be overridden by Orchestrator

### 2. **Verification Over Trust**
- **Always verifies independently** (doesn't trust Orchestrator's summary)
- **Uses MCP tools** to check actual state (Git logs, file system, etc.)
- **Checks cryptographic signatures** (GPG verification)

### 3. **Defense in Depth**
- **Layer 1 (Prevention):** Co-signature requirement makes bypasses hard
- **Layer 2 (Detection):** Monitors for violation patterns
- **Layer 3 (Response):** System freeze capability
- **Layer 4 (Recovery):** Audit reports guide remediation

---

## 📊 Librarian's Audit Trail

The Librarian logs all activities:

```bash
.git/audit/orchestrator-decisions.log
  - All co-signature requests/approvals
  - Reasons for denials

.git/audit/security-events.log
  - Violation detections
  - System freezes/unfreezes
  - Suspicious patterns

.git/audit/librarian-veto.json
  - Veto history
  - Remediation tracking
```

---

## 💡 Why Librarian is Critical

**Without Librarian:**
- Rogue Orchestrator could bypass all gates
- No independent verification of requirements
- No emergency brake for systemic violations
- Collusion between Orchestrator + any role succeeds

**With Librarian:**
- ✅ Orchestrator's critical actions verified independently
- ✅ System can freeze itself when compromised
- ✅ Direct escalation path to User (bypasses Orchestrator)
- ✅ Collusion requires 3+ roles (Orchestrator + Librarian + target role)

---

## 🔄 Message Flow Examples

### Example 1: Normal Gate Advancement
```
Dev-A → Orchestrator: "Tests complete, ready for Gate 3"
Orchestrator → Librarian: CoSignatureRequest (Gate 3)
Librarian: Verifies via Git MCP (12 tests committed, no impl)
Librarian → Orchestrator: Approved
Orchestrator → Dev-A: "Gate 3 approved, proceed with implementation"
```

### Example 2: Denied Co-Signature
```
Dev-B → Orchestrator: "Ready for Gate 4 (QA)"
Orchestrator → Librarian: CoSignatureRequest (Gate 4)
Librarian: Verifies via Terminal MCP (runs pytest)
Librarian: Detects only 65% coverage (requires 80%)
Librarian → Orchestrator: Denied - "Coverage insufficient: 65% < 80%"
Orchestrator → Dev-B: "Gate 4 denied by Librarian - add tests"
```

### Example 3: System Freeze
```
Librarian: Monitoring detects 3 gate bypasses in 24 hours
Librarian: AUTOMATIC VETO TRIGGERED
Librarian → ALL ROLES: SYSTEM_FREEZE broadcast
Orchestrator: Enters frozen state (all requests denied)
Librarian → User: SecurityAuditReport (direct, bypasses Orchestrator)
User: Investigates + remediates
User → Librarian: UNFREEZE_APPROVED
Librarian: Verifies remediation via MCP tools
Librarian → ALL ROLES: SYSTEM_UNFROZEN broadcast
```

---

## Summary Table

| Aspect | Details |
|--------|---------|
| **Authority** | Veto power over Orchestrator, system freeze capability |
| **Access** | Read-only (cannot commit), full visibility |
| **Primary Tools** | Git MCP, Filesystem MCP, Serena, Terminal MCP |
| **Interactions** | Orchestrator (co-sign), Docs (review), ALL (freeze), User (direct audit) |
| **Triggers** | 3+ gate bypasses, 5+ lock failures, >5% override rate, integrity violations |
| **Cannot Be** | Overridden by Orchestrator, bypassed via hooks |
| **Reports To** | User (direct path, not through Orchestrator) |

---

## 🔒 Security Features Implementation

The Librarian plays a critical role in implementing and enforcing all security features. For comprehensive implementation details, see **[SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md)**.

### Librarian-Specific Security Responsibilities:

#### 1. **Message Integrity Verification** (Primary Responsibility)
The Librarian monitors the message integrity system and can detect tampering:
- Verifies SHA-256 hashes for all critical messages (co-signature requests, gate advancements)
- Triggers system freeze if message tampering detected
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Integrity Verification](SECURITY_IMPLEMENTATION.md#9-message-integrity-verification)

#### 2. **Collusion Detection Monitoring** (Primary Responsibility)
The Librarian analyzes peer review patterns to detect rubber-stamping:
- Tracks approval rates between peer pairs (e.g., Dev-A ↔ Dev-B)
- Monitors review times and feedback depth
- Triggers tertiary reviews when collusion suspected
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Collusion Detection](SECURITY_IMPLEMENTATION.md#5-collusion-detection)

#### 3. **Cumulative Change Detection** (Primary Responsibility)
The Librarian prevents salami-slicing attacks (many small commits):
- Tracks aggregate LOC changes per role per 24-hour window
- Alerts when thresholds exceeded (500+ LOC in 24h)
- Analyzes patterns for evasion attempts
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Cumulative Change Detection](SECURITY_IMPLEMENTATION.md#7-cumulative-change-detection)

#### 4. **Rate Limiting Enforcement** (Monitoring)
The Librarian monitors for rate limit violations:
- Tracks commits/hour, messages/minute per role
- Alerts on excessive activity (potential automation abuse)
- Can trigger system freeze for severe violations
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Rate Limiting](SECURITY_IMPLEMENTATION.md#8-rate-limiting)

#### 5. **GPG Signature Verification** (Co-Verification)
The Librarian verifies GPG signatures on all commits during co-signature reviews:
```bash
# During co-signature review
verify_commit_signatures() {
    local feature=$1
    commits=$(git log --since="$last_gate" --format="%H")

    for commit in $commits; do
        if ! git verify-commit "$commit" 2>/dev/null; then
            deny_co_signature "Unsigned commit detected: $commit"
            return 1
        fi
    done

    return 0
}
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § GPG Signing](SECURITY_IMPLEMENTATION.md#3-gpg-commit-signing)

#### 6. **Tertiary Review Coordination** (Assignment)
The Librarian assigns independent tertiary reviewers for random 10% of peer reviews:
```python
def maybe_assign_tertiary_review(primary, peer, feature):
    # Librarian makes the random selection
    if random.random() < 0.10:
        # Select reviewer independent of both primary and peer
        tertiary = select_independent_reviewer(primary, peer)

        send_message(tertiary, "TertiaryReviewRequest", {
            "feature": feature,
            "primary_author": primary,
            "peer_reviewer": peer,
            "purpose": "Independent verification - detect collusion",
            "deadline": "24h"
        })

        log_audit("tertiary-reviews.json", {
            "primary": primary,
            "peer": peer,
            "tertiary": tertiary,
            "reason": "Random 10% selection"
        })
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Tertiary Reviews](SECURITY_IMPLEMENTATION.md#4-tertiary-reviews-random-10)

#### 7. **Audit Trail Integrity** (Primary Responsibility)
The Librarian maintains comprehensive audit logs:
```bash
.git/audit/
├── orchestrator-decisions.log       # Co-signature requests/approvals
├── message-log.log                   # All inter-instance messages
├── security-events.log               # Violations, freezes, alerts
├── write-lock-intents.json           # Lock request/grant/release
├── message-registry.json             # Message integrity hashes
├── peer-review-patterns.json         # Collusion detection data
├── tertiary-reviews.json             # Random review assignments
├── cumulative-changes.json           # LOC tracking per role
├── rate-limiting.json                # Activity rate tracking
└── 2fa-confirmations.log             # User confirmation events
```
- All logs are append-only (no deletion allowed)
- SHA-256 hashes for tamper detection
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Audit Trail](SECURITY_IMPLEMENTATION.md#10-audit-trail-logging)

#### 8. **Write Lock Verification** (Co-Verification)
The Librarian verifies write lock requests during co-signature reviews:
```python
def verify_write_lock_request(requester, files, estimated_time):
    # Check for file conflicts with current lock
    current_lock = load_lock_state()

    if has_file_conflict(files, current_lock):
        # Verify queue position is legitimate
        verify_queue_position(requester)

    # Check estimated time is reasonable
    if estimated_time > 4 * 3600:  # 4 hours
        escalate_to_user("Excessive lock duration requested")

    # Verify requester has legitimate need
    verify_write_lock_justification(requester, files)
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Write Lock Coordination](SECURITY_IMPLEMENTATION.md#2-write-lock-coordination)

#### 9. **2FA User Confirmation Verification** (Monitoring)
The Librarian monitors 2FA confirmation requests to prevent abuse:
- Verifies 2FA requests are for legitimate critical decisions
- Tracks frequency to detect fatigue attacks (excessive confirmations)
- Can trigger system freeze if 2FA bypass attempted
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § 2FA Confirmation](SECURITY_IMPLEMENTATION.md#6-2fa-user-confirmation)

#### 10. **Message Passing Monitoring** (Oversight)
The Librarian monitors the message passing system for anomalies:
- Unusual message volumes (DoS attack on message queue)
- Out-of-order messages (timing attack attempts)
- Orphaned messages (delivery failures)
- Message registry inconsistencies
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Passing](SECURITY_IMPLEMENTATION.md#1-message-passing-system)

### Security Enforcement Powers:

The Librarian has unique enforcement capabilities:

1. **System Freeze** - Can immediately halt all work across all roles
2. **Co-Signature Denial** - Can block any Orchestrator decision
3. **Direct User Escalation** - Reports bypass Orchestrator for security issues
4. **Audit Report Generation** - Comprehensive forensic analysis on demand
5. **Remediation Verification** - Must approve system unfreeze after violations

### Librarian Security Workflow Example:

```
┌─────────────────────────────────────────────────────────┐
│ LIBRARIAN SECURITY MONITORING (Continuous)              │
└─────────────────────────────────────────────────────────┘
         │
         ├─> Monitor message integrity (SHA-256 hashes)
         ├─> Track peer review patterns (collusion detection)
         ├─> Analyze cumulative changes (salami-slicing)
         ├─> Verify rate limits (abuse detection)
         ├─> Check GPG signatures (commit verification)
         ├─> Coordinate tertiary reviews (random 10%)
         └─> Maintain audit trail (comprehensive logging)
         │
         ▼
    [Violation Detected?]
         │
         ├─ YES ──> [Trigger System Freeze]
         │              │
         │              ├─> Broadcast SYSTEM_FREEZE to all roles
         │              ├─> Generate security audit report
         │              ├─> Escalate directly to User
         │              └─> Require remediation + User approval to unfreeze
         │
         └─ NO ──> [Continue Monitoring]
```

**Critical:** The Librarian is the only role with system-wide freeze authority and cannot be overridden by the Orchestrator.

---

**The Librarian is the independent guardian that ensures no single role—not even Orchestrator—can compromise the system's integrity.**
