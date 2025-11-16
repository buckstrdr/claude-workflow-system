# ✅ QA: Complete Role & Interactions

**Position:** Quality assurance and testing specialist (2 total: QA-A, QA-B)
**Instance Type:** Test strategy and verification authority
**Primary Function:** Test design, execution, coverage verification
**Key Characteristic:** Peer-first review protocol for test strategies

---

## 🎭 Core Identity

**Why 2 QA:**
- **Peer review for test strategies** - QA-A ↔ QA-B review each other's test plans
- **Coverage validation** - Second QA ensures adequate test coverage
- **Test methodology review** - Catch missing edge cases and test types
- **Escalation when needed** - Testability issues → Dev consultation

**Structure:**
- **QA-A** - Quality Assurance Engineer
- **QA-B** - Quality Assurance Engineer

Both have equal authority - no hierarchy.

---

## 🔐 Core Responsibilities

### 1. **Test Strategy Design**

QA creates comprehensive test strategies for features:

**Test Strategy Contents:**
```markdown
# Test Strategy: Order Idempotency

## Test Types
### Unit Tests (12 tests)
- Key generation (3 tests)
- Storage operations (4 tests)
- Retrieval operations (3 tests)
- TTL cleanup (2 tests)

### Integration Tests (5 tests)
- Full order flow with idempotency (2 tests)
- Concurrent request handling (2 tests)
- TTL expiry behavior (1 test)

### E2E Tests (3 tests)
- Order creation with duplicate detection (1 test)
- Multiple orders in sequence (1 test)
- Order after TTL expiry (1 test)

## Coverage Target
- Minimum: 85% (exceeds 80% project standard)
- Critical paths: 90% (idempotency is order-critical)

## Edge Cases
- Concurrent requests for same key
- TTL expiry during request
- Database connection failure
- Invalid key format
- Expired key cleanup race condition

## Test Data
- Valid order payloads
- Duplicate request scenarios
- Edge case inputs

## Performance Tests
- Load test: 100 concurrent requests
- Response time: <100ms for cache hit
```

---

### 2. **QA Peer Review Protocol**

QA reviews each other's test strategies:

**QA Peer Review Checklist:**
- [ ] All success criteria from spec tested
- [ ] Happy path tests included
- [ ] Edge case tests identified
- [ ] Error case tests included
- [ ] Performance/load tests specified
- [ ] Security tests included (if applicable)
- [ ] Test data requirements clear
- [ ] Coverage target meets standards (80% min, 90% for critical)
- [ ] Test types appropriate (unit, integration, E2E)
- [ ] No missing scenarios

**Review Workflow:**
```
QA-A → QA-B: PeerReviewRequest
  "Review test plan for order_idempotency
   Test types: Unit (12), Integration (5), E2E (3)
   Coverage target: 85%
   Edge cases: Concurrency, TTL, failures"
       ↓
QA-B reviews independently
       ↓
    ┌───┴───┐
    │       │
APPROVE  DISAGREE
```

**Agreement:**
```
QA-B → QA-A: PeerReviewApproval
  "✅ Test plan comprehensive
   Coverage adequate (85% > 80%)
   Edge cases well-identified
   Approved for implementation"
       ↓
QA-A implements test plan
```

---

### 3. **QA Disagreement Resolution**

When QA-A and QA-B disagree:

**Standards Disagreement (Orchestrator):**
```
QA-A: "80% coverage sufficient"
QA-B: "Need 90% coverage for payment code"
[Standards interpretation]
       ↓
Both → Orchestrator: StandardsDisagreement
       ↓
Orchestrator applies documented standards:
  - Project standard: 80% minimum
  - Critical code paths: 90% minimum
       ↓
Orchestrator → Both: DecisionAnnouncement
  "Payment integration requires 90% coverage
   (Documented standard for critical paths)"
```

**Testing Methodology (Dev Consultation):**
```
QA-A: "Test with mocked database"
QA-B: "Test with real database (testcontainers)"
[Testing approach]
       ↓
Both → Dev-A: TestabilityReview
  "Which testing approach preferred?"
       ↓
Dev-A → Both: DeveloperRecommendation
  "Use testcontainers - catches real integration issues
   Worth 2s slowdown for confidence"
```

---

### 4. **Gate 4 (QA) Verification**

QA verifies implementation meets quality standards:

**QA Gate Verification:**
```
Dev-A → QA-A: QAVerificationRequest
  "Implementation complete, ready for QA gate
   All tests passing, 87% coverage"
       ↓
QA-A verifies:
  1. All tests passing? ✓
  2. Coverage meets 85%? ✓ (87%)
  3. Critical paths 90%? [Check]
  4. Edge cases covered? ✓
  5. Performance acceptable? [Test]
       ↓
QA-A runs additional verification:
  - Runs full test suite
  - Checks coverage report
  - Runs load tests
       ↓
    ┌───┴───┐
    │       │
  PASS    FAIL
    │       │
    ↓       ↓
```

**Pass:**
```
QA-A → Orchestrator: QAApproval
  "✅ QA verification passed
   Tests: 20/20 passing
   Coverage: 87% (meets 85% requirement)
   Load test: 100 concurrent requests handled
   Ready for Gate 5 (DEPLOY)"
```

**Fail:**
```
QA-A → Dev-A: QARejection
  "❌ QA verification failed
   Issues:
   - 2 tests failing: test_concurrent_access, test_ttl_cleanup
   - Coverage: 72% (below 85% requirement)
   - Load test: Timeout at 80 concurrent requests

   Required fixes before re-submission"
```

---

### 5. **Coverage Enforcement**

QA enforces coverage standards:

**Coverage Standards:**
- **Project standard:** 80% minimum
- **Critical code paths:** 90% minimum (auth, payment, security, data integrity)
- **New code:** 100% (all new code must have tests)

**Coverage Verification:**
```bash
# QA runs coverage report
pytest --cov=src tests/ --cov-report=term-missing

# Check critical paths specifically
pytest --cov=src/payment --cov-report=term-missing
# Must be ≥90%

pytest --cov=src/auth --cov-report=term-missing
# Must be ≥90%
```

---

## 🔄 Interactions with Other Instances

### With Orchestrator
- **Receive:** QA verification requests (Gate 4)
- **Send:** QA approval/rejection

### With Other QA (Peer Review)
- **Send:** PeerReviewRequest for test strategies
- **Receive:** PeerReviewApproval/Rejection

### With Developers
- **Receive:** Implementation complete notifications
- **Send:** Test failures, coverage requirements
- **Consult:** Testing methodology questions

### With Planner
- **Receive:** Test requirements from spec
- **Send:** Testability feedback on specifications

### With Architect
- **Consult:** Security testing approaches
- **Review:** Architectural decisions with security implications

---

## 🛠️ MCP Tool Usage

**Primary Tools:**
1. **Terminal MCP** - Run pytest, coverage reports, load tests
2. **Git MCP** - Verify test commits, check diff
3. **Filesystem MCP** - Read test files, check test coverage
4. **Context7** - Research testing best practices
5. **Serena** - Remember testing patterns, track coverage trends

**QA Commands:**
```bash
# Run full test suite
pytest tests/ -v

# Coverage report
pytest --cov=src tests/ --cov-report=html --cov-report=term-missing

# Run specific test types
pytest tests/unit/ -v
pytest tests/integration/ -v
pytest tests/e2e/ -v

# Load testing
pytest tests/load/test_idempotency_load.py -v

# Check for slow tests
pytest tests/ -v --durations=10
```

---

## Summary Table

| Aspect | Details |
|--------|---------|
| **Count** | 2 (QA-A, QA-B) |
| **Primary Duty** | Test strategy, execution, coverage verification |
| **Peer Review** | Test plans reviewed by peer QA |
| **Coverage Standards** | 80% min, 90% for critical paths, 100% for new code |
| **Gate Authority** | Gate 4 (QA) - verify implementation quality |
| **Escalation** | Standards disputes → Orchestrator, Methodology → Dev consultation |
| **Works With** | Orchestrator, other QA, Developers, Planner, Architect |

## 🔒 Security Features Implementation

QA plays a critical role in implementing and enforcing security features during the testing and verification phases. For comprehensive implementation details, see **[SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md)**.

### QA-Specific Security Responsibilities:

#### 1. **Message Passing System Usage**
QA uses the message passing system for peer review and coordination:
- Send/receive test strategy peer review requests between QA-A and QA-B
- Communicate test results to Orchestrator and Developers
- Coordinate with Architects on security testing approaches
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Passing](SECURITY_IMPLEMENTATION.md#1-message-passing-system)

**Example Test Strategy Review Message:**
```yaml
---
message_id: MSG-QA-98765
from: QA-A
to: QA-B
type: TestStrategyPeerReview
timestamp: 2025-11-16T22:30:00Z
hash: d4e5f6a7b8c9...
---

# Test Strategy Peer Review: Order Idempotency

**Feature:** Order Idempotency Testing
**Test Coverage Target:** 85% (exceeds 80% minimum)
**Test Types:** Unit (12), Integration (5), E2E (3)

**Review Checklist:**
- [ ] All success criteria tested
- [ ] Edge cases covered (concurrency, TTL, failures)
- [ ] Performance tests (100 concurrent requests)
- [ ] Security tests (idempotency key tampering)

**Files:**
- `tests/unit/test_idempotency.py` (12 tests)
- `tests/integration/test_order_flow.py` (5 tests)
- `tests/e2e/test_idempotency_e2e.py` (3 tests)

**Deadline:** 24 hours
```

#### 2. **Write Lock Coordination** (Test Documentation)
QA requests write locks when committing test plans and strategies:
```python
# When creating/updating test plans
request_write_lock(
    requester="QA-A",
    files=["docs/testing/test-strategy-idempotency.md",
           "docs/testing/README.md"],
    estimated_time=1800  # 30 minutes
)
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Write Lock Coordination](SECURITY_IMPLEMENTATION.md#2-write-lock-coordination)

#### 3. **GPG Commit Signing** (Test Commits)
QA signs all test commits:
```bash
# QA-A's GPG key for test commits
gpg --sign-key qa-a@workflow.local

# All test commits must be signed
git commit -S -m "test: add idempotency test suite

Test coverage: 85% (12 unit, 5 integration, 3 E2E)
Peer reviewed by: QA-B
Edge cases: Concurrency, TTL expiry, DB failures

Test strategy includes:
- Concurrent request handling (100 requests)
- TTL expiry edge cases
- Database failure scenarios
- Performance benchmarks (<100ms response)

Reviewed-by: QA-B <qa-b@workflow.local>
Coverage-Report: pytest --cov=src/idempotency tests/"
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § GPG Signing](SECURITY_IMPLEMENTATION.md#3-gpg-commit-signing)

#### 4. **Tertiary Review Participation**
QA may be assigned as tertiary reviewers for test strategy reviews:
```python
def handle_tertiary_test_review_request(primary_qa, peer_qa, test_strategy):
    # Third QA provides independent test strategy review
    review = {
        "coverage_adequacy": verify_coverage(test_strategy),
        "edge_cases_missed": find_missing_edge_cases(test_strategy),
        "test_type_balance": check_test_types(test_strategy),
        "peer_review_quality": assess_review_depth(primary_qa, peer_qa, test_strategy)
    }

    # Flag if peer review missed significant gaps
    if review["edge_cases_missed"]:
        escalate_to_librarian("Peer review missed edge cases", {
            "primary": primary_qa,
            "peer": peer_qa,
            "missed_cases": review["edge_cases_missed"]
        })
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Tertiary Reviews](SECURITY_IMPLEMENTATION.md#4-tertiary-reviews-random-10)

#### 5. **Collusion Detection** (Test Strategy Review Patterns)
QA peer review patterns are monitored:
```python
def detect_qa_collusion():
    # Monitor QA-A ↔ QA-B approval patterns
    patterns = load_qa_review_history()

    approval_rate_a_to_b = patterns["QA-A"]["approves"]["QA-B"]
    approval_rate_b_to_a = patterns["QA-B"]["approves"]["QA-A"]

    review_time_avg = patterns["avg_review_time_seconds"]
    feedback_depth_avg = patterns["avg_feedback_lines"]

    # Collusion indicators:
    # 1. High approval rate (>95% over 10+ reviews)
    # 2. Fast reviews (<10 min avg for comprehensive test strategy)
    # 3. Shallow feedback (<5 lines avg)

    if (approval_rate_a_to_b > 0.95 and
        review_time_avg < 600 and
        feedback_depth_avg < 5):

        alert_librarian("QA_COLLUSION_DETECTED", {
            "pair": ("QA-A", "QA-B"),
            "approval_rate": approval_rate_a_to_b,
            "avg_review_time": review_time_avg,
            "feedback_depth": feedback_depth_avg,
            "severity": "HIGH",
            "action": "Trigger tertiary reviews for all future QA peer reviews"
        })
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Collusion Detection](SECURITY_IMPLEMENTATION.md#5-collusion-detection)

#### 6. **2FA User Confirmation** (Security-Critical Testing)
Security-critical test strategies may require 2FA:
```python
def test_strategy_requires_2fa(test_strategy):
    # 2FA required for:
    # - Security testing (auth, encryption, access control)
    # - Payment system testing
    # - Data privacy testing
    # - Penetration testing plans

    security_keywords = ["auth", "password", "payment", "encryption", "security", "penetration"]

    if any(kw in test_strategy["description"].lower() for kw in security_keywords):
        return request_2fa_confirmation(
            decision_type="SECURITY_CRITICAL_TESTING",
            details=f"Test Strategy: {test_strategy['feature']}"
        )
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § 2FA Confirmation](SECURITY_IMPLEMENTATION.md#6-2fa-user-confirmation)

#### 7. **Cumulative Change Detection** (Test Volume Monitoring)
QA test commits are tracked for volume monitoring:
```python
def check_qa_cumulative_test_commits(qa):
    # Track number of test commits in 7-day window
    cutoff = datetime.now() - timedelta(days=7)
    recent_test_commits = load_test_commits_since(cutoff, qa)

    test_count = len(recent_test_commits)
    total_tests = sum(c["test_count"] for c in recent_test_commits)

    # Alert if excessive test commits (potential low-quality tests)
    # Threshold: 100+ tests/week or 30+ commits/week
    if test_count > 30 or total_tests > 100:
        alert_librarian("EXCESSIVE_TEST_COMMITS", {
            "qa": qa,
            "test_count": total_tests,
            "commit_count": test_count,
            "reason": "Verify test quality (many tests may indicate low-quality/redundant tests)"
        })
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Cumulative Change Detection](SECURITY_IMPLEMENTATION.md#7-cumulative-change-detection)

#### 8. **Rate Limiting** (Test Execution and Commits)
QA is subject to rate limiting:
```python
QA_RATE_LIMITS = {
    "test_commits_per_day": 20,          # Max 20 test commits/day
    "test_runs_per_hour": 50,            # Max 50 test suite runs/hour
    "messages_per_minute": 10,           # Max 10 messages/min
    "peer_review_requests_per_day": 30   # Max 30 reviews/day
}

def check_qa_rate_limit(qa, action):
    count = count_actions(qa, action, window)
    if count >= threshold:
        send_message(qa, "RateLimitExceeded", {
            "action": action,
            "limit": threshold,
            "current": count,
            "reason": "Prevent test suite abuse or rushed testing"
        })
        return False
    return True
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Rate Limiting](SECURITY_IMPLEMENTATION.md#8-rate-limiting)

#### 9. **Message Integrity Verification** (Test Results)
All test result messages are integrity-verified:
```python
def send_qa_approval(from_qa, to_orchestrator, test_results):
    # Create QA approval message
    approval_message = {
        "from": from_qa,
        "to": to_orchestrator,
        "feature": test_results["feature"],
        "coverage": test_results["coverage"],
        "tests_passed": test_results["passed"],
        "tests_failed": test_results["failed"],
        "status": "QA_APPROVED",
        "timestamp": datetime.now().isoformat()
    }

    # Calculate hash for integrity
    content = json.dumps(approval_message, sort_keys=True)
    hash = hashlib.sha256(content.encode()).hexdigest()

    # Register message
    register_message(message_id, hash)

    # Send to Orchestrator
    send_message(to_orchestrator, approval_message)

# When receiving QA approval
def receive_qa_approval(message):
    # Verify message integrity (prevent false approvals)
    if not verify_message_integrity(message["message_id"]):
        raise MessageTamperingError("QA approval message tampered!")

    # Verify GPG signature
    if not verify_gpg_signature(message["signature"]):
        raise InvalidSignatureError("QA approval not properly signed!")

    return message
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Message Integrity](SECURITY_IMPLEMENTATION.md#9-message-integrity-verification)

#### 10. **Audit Trail Logging** (All QA Activities)
All QA activities are comprehensively logged:
```bash
.git/audit/qa-test-strategies.log
  - All test strategies created with timestamps
  - Peer review requests and approvals
  - Coverage targets and actual coverage
  - Test execution results (pass/fail counts)
  - Quality gate approvals/rejections

.git/audit/peer-review-patterns.json
  - QA-A ↔ QA-B approval rates
  - Review times (median, avg, max)
  - Feedback depth analysis
  - Collusion risk scores

.git/audit/qa-coverage-tracking.json
  - Coverage per feature (unit, integration, E2E)
  - Critical path coverage (auth, payment: 90%+)
  - Coverage trends over time
  - Violations of coverage standards

docs/testing/
  - test-strategy-idempotency.md (GPG signed by QA-A)
  - test-strategy-authentication.md (GPG signed by QA-B)
  - [All test strategy documents]
```
- **Implementation:** See [SECURITY_IMPLEMENTATION.md § Audit Trail](SECURITY_IMPLEMENTATION.md#10-audit-trail-logging)

### QA Security Workflow Example:

```
┌─────────────────────────────────────────────────────────┐
│ QA VERIFICATION WITH SECURITY (QA-A)                     │
└─────────────────────────────────────────────────────────┘
         │
         ├─> STRATEGY PHASE
         │   ├─> Create test strategy document
         │   ├─> Request write lock (strategy files)
         │   ├─> Commit strategy (GPG signed)
         │   ├─> Send peer review request (SHA-256 hash)
         │   ├─> Release write lock
         │   └─> Receive peer approval (verify hash + GPG)
         │
         ├─> EXECUTION PHASE
         │   ├─> Request write lock (test files)
         │   ├─> Write tests following strategy
         │   ├─> Commit tests (GPG signed)
         │   ├─> Run full test suite
         │   ├─> Verify coverage meets standards
         │   └─> Release write lock
         │
         ├─> VERIFICATION PHASE
         │   ├─> Run tests on Dev implementation
         │   ├─> Check coverage (85% for this feature)
         │   ├─> Verify critical paths (90%+ if applicable)
         │   ├─> Log results to audit trail
         │   └─> Send approval/rejection (SHA-256 hash)
         │
         ├─> SECURITY CHECKS
         │   ├─> Verify no rate limits exceeded
         │   ├─> Check test commit volume (7-day window)
         │   ├─> Collusion detection (if peer review)
         │   ├─> Security testing 2FA (if auth/payment)
         │   └─> Audit trail logging
         │
         ▼
    [Gate Advancement to DEPLOY or back to Dev]
```

### Critical Security Considerations for QA:

1. **Test Strategy Integrity** - All strategies GPG-signed and peer-reviewed
2. **Coverage Standards Enforced** - 80% min, 90% critical paths, 100% new code
3. **Collusion Monitoring** - QA-A ↔ QA-B approval patterns tracked
4. **Message Integrity** - Test results SHA-256 hashed (prevent false approvals)
5. **Rate Limiting** - 20 test commits/day, 50 test runs/hour maximum
6. **Tertiary Reviews** - Random 10% for test strategy quality verification
7. **2FA for Security Testing** - Auth/payment/security tests require confirmation
8. **Audit Trail** - All tests, coverage, approvals permanently logged
9. **Write Lock Enforcement** - Cannot commit tests without holding lock
10. **GPG Signing Mandatory** - All test commits must be signed

**Purpose:** Ensure comprehensive test coverage with independent peer review and cryptographic proof of test authenticity, preventing false quality gate approvals.

---

**QA ensures comprehensive test coverage and quality standards before features advance to deployment, with peer review preventing single-point-of-failure test strategies.**
