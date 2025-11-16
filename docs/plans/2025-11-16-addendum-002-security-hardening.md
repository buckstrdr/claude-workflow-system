# Addendum 002: Security Hardening and Anti-Rogue-Actor Protocols

**Date:** 2025-11-16
**Status:** Ready for Implementation
**Applies to:** Multi-Instance Claude Code Orchestration System (v3 spec + Addendum 001)
**Addendum Number:** 002
**Priority:** CRITICAL - Security Foundation

---

## Executive Summary

This addendum establishes comprehensive security hardening to prevent any single actor (including Orchestrator) from going rogue or bypassing quality controls.

**Core Principle:** Trust is good, but verification is mandatory.

**10 Critical Safeguards:**
1. **Orchestrator Oversight** - Librarian co-signs critical Orchestrator actions
2. **Anti-Collusion Protocol** - Randomized third-party reviews prevent peer collusion
3. **Write Lock Verification** - Pre/post-commit checks ensure stated changes match actual commits
4. **Server-Side Gate Enforcement** - Quality gates enforced on server, cannot be bypassed
5. **Message Integrity** - Cryptographic hashing prevents message tampering
6. **Cryptographic Sign-Offs** - GPG signatures prove genuine approvals
7. **User Authentication** - Multi-factor confirmation for critical decisions
8. **Librarian Veto Authority** - Librarian can freeze system for systemic violations
9. **Cumulative Change Detection** - Prevents "salami slicing" attacks
10. **Rate Limiting** - Prevents resource exhaustion and spam

**Impact:**
- No single role can compromise system
- Collusion between 2 roles detected and flagged
- All critical actions have audit trail
- User authenticity verified
- System can self-correct when violations detected

**Implementation Priority:** MUST be implemented before production use

---

## Table of Contents

1. [Threat Model](#1-threat-model)
2. [Orchestrator Oversight Protocol](#2-orchestrator-oversight-protocol)
3. [Anti-Collusion Protocol](#3-anti-collusion-protocol)
4. [Write Lock Verification](#4-write-lock-verification)
5. [Server-Side Gate Enforcement](#5-server-side-gate-enforcement)
6. [Message Integrity System](#6-message-integrity-system)
7. [Cryptographic Sign-Off Protocol](#7-cryptographic-sign-off-protocol)
8. [User Authentication Protocol](#8-user-authentication-protocol)
9. [Librarian Veto Authority](#9-librarian-veto-authority)
10. [Cumulative Change Detection](#10-cumulative-change-detection)
11. [Rate Limiting and Anti-Spam](#11-rate-limiting-and-anti-spam)
12. [Audit and Monitoring](#12-audit-and-monitoring)
13. [Implementation Guide](#13-implementation-guide)

---

## 1. Threat Model

### 1.1 Potential Rogue Actors

**Single Role Compromise:**
- Rogue Orchestrator (highest risk - wide authority)
- Rogue Dev (could commit malicious code)
- Rogue QA (could approve bad code)
- Rogue Architect (could approve bad architecture)

**Collusion Scenarios:**
- Dev-A + Dev-B (mutual approval of bad code)
- QA-A + QA-B (mutual approval of insufficient tests)
- Architect-A + Architect-B (2-vote majority on bad architecture)
- Orchestrator + any role (coordinated bypass)

**External Threats:**
- User impersonation (fake critical decision approvals)
- Hook bypass (--no-verify on client side)
- Message tampering (forged approvals)
- Time-based attacks (many small malicious commits)

### 1.2 Attack Vectors

| **Attack** | **Vector** | **Impact** | **Likelihood** |
|------------|-----------|------------|----------------|
| Rogue Orchestrator | Approve gates without requirements | HIGH | MEDIUM |
| Peer collusion | Mutual approval without scrutiny | HIGH | MEDIUM |
| Sign-off forgery | Fake "Peer-Reviewed-By" in commits | MEDIUM | HIGH |
| Hook bypass | `git push --no-verify` | HIGH | MEDIUM |
| Message tampering | Edit/delete approval messages | MEDIUM | LOW |
| Salami slicing | Many small malicious commits | MEDIUM | MEDIUM |
| Write lock abuse | Hold lock, commit unexpected files | MEDIUM | LOW |
| User impersonation | Claim user approved when they didn't | HIGH | LOW |

### 1.3 Defense-in-Depth Strategy

**Layer 1: Prevention** - Make attacks structurally difficult
**Layer 2: Detection** - Identify attacks when they occur
**Layer 3: Response** - Automatic containment and alerting
**Layer 4: Recovery** - Rollback and remediation

Each safeguard operates at multiple layers.

---

## 2. Orchestrator Oversight Protocol

### 2.1 Problem Statement

**Risk:** Orchestrator has wide-ranging authority and could:
- Approve quality gates without requirements met
- Grant write locks without proper sign-offs
- Manipulate message routing
- Authorize emergency bypasses without justification

**Impact:** Single compromised role can undermine entire system

### 2.2 Solution: Librarian Co-Signature

**Principle:** Orchestrator's critical actions require Librarian verification.

**Why Librarian:**
- Read-only role (cannot commit, has no write access)
- Sees entire codebase and history
- Independent from development workflow
- Natural auditor role

### 2.3 Actions Requiring Co-Signature

| **Orchestrator Action** | **Librarian Verification** | **What Librarian Checks** |
|------------------------|---------------------------|---------------------------|
| Quality gate advancement | Co-signature required | Requirements actually met (tests passing, coverage OK, docs updated) |
| Write lock grant | Co-signature required | No conflicts, request is legitimate |
| Emergency bypass authorization | Co-signature + User approval | Genuine emergency, no alternative |
| Critical decision (User escalation) | Verification of need | Decision genuinely critical, not premature escalation |
| Gate status modification | Co-signature required | Modification is legitimate rollback/fix, not bypass |

### 2.4 Co-Signature Workflow

```
Orchestrator: Wants to advance feature to Gate 3
        ↓
Orchestrator → Librarian: CoSignatureRequest
  "Request co-signature for Gate 3 advancement

   Feature: order_idempotency
   Current Gate: 2 (Tests First)
   Requesting: Advance to Gate 3 (Implementation Complete)

   Evidence:
   - All tests committed: ✓ (12 tests in backend/tests/)
   - Tests failing (Red phase): ✓ (all 12 failing as expected)
   - No implementation code: ✓ (verified no changes to backend/services/)
   - Sign-offs: Dev-A signed tests

   Gate 2 requirements met: YES"
        ↓
Librarian independently verifies:
  1. Reads backend/tests/ - confirms 12 test files
  2. Checks git log - tests committed before implementation ✓
  3. Runs tests - all failing ✓
  4. Scans backend/services/ - no implementation files ✓
  5. Reviews sign-off registry - Dev-A signature present ✓
        ↓
    ┌───┴───┐
    │       │
  PASS    FAIL
    │       │
    ↓       ↓
```

**If Librarian approves:**
```
Librarian → Orchestrator: CoSignatureApproval
  "✓ Co-signature GRANTED for Gate 3 advancement

   Verification completed:
   - Evidence matches reality: YES
   - Requirements met: YES
   - Sign-offs valid: YES

   Signed: Librarian
   Timestamp: 2025-11-16T21:00:00Z
   Hash: abc123..."

Orchestrator: [Advances gate with Librarian co-signature]

Logs to .git/audit/gate-advancements.log:
  "2025-11-16T21:00:00Z | order_idempotency | Gate 2→3 | Orchestrator | Librarian co-sign: abc123"
```

**If Librarian rejects:**
```
Librarian → Orchestrator: CoSignatureRejection
  "❌ Co-signature DENIED for Gate 3 advancement

   Issue found:
   - Claimed: All tests failing
   - Reality: 2 tests passing (test_basic, test_simple)
   - Gate 2 requirement: Tests MUST fail (Red phase)

   Cannot advance gate. Dev-A must fix tests to fail correctly."

Orchestrator: [Cannot advance gate]
Orchestrator → Dev-A: "Gate advancement blocked by Librarian. Fix tests to fail."
```

### 2.5 Orchestrator Audit Log

**All Orchestrator decisions logged to immutable file:**

**File:** `.git/audit/orchestrator-decisions.log`

**Format:**
```
[TIMESTAMP] | [ACTION] | [FEATURE] | [DECISION] | [LIBRARIAN_COSIGN] | [OUTCOME]

2025-11-16T21:00:00Z | GATE_ADVANCE | order_idempotency | 2→3 | APPROVED:abc123 | SUCCESS
2025-11-16T21:05:00Z | WRITE_LOCK | order_idempotency | GRANT:Dev-A | APPROVED:def456 | SUCCESS
2025-11-16T21:30:00Z | EMERGENCY_BYPASS | security_patch | AUTHORIZE:TDD | REJECTED:xyz789 | BLOCKED
```

**Immutability:**
- Append-only file
- Git-tracked (any modification visible in diff)
- Librarian monitors for unauthorized edits

### 2.6 Override Detection

**Librarian monitors Orchestrator for suspicious patterns:**

**Red flags:**
- Gate advancement without Librarian co-signature
- Write lock granted without request in message board
- Emergency bypass >1% of total decisions
- Pattern of favoring specific role

**Detection script:** `scripts/audit/detect-orchestrator-overrides.sh`

```bash
#!/bin/bash
# Detect Orchestrator actions without Librarian co-signature

AUDIT_LOG=".git/audit/orchestrator-decisions.log"

# Count actions
TOTAL=$(grep -c "GATE_ADVANCE\|WRITE_LOCK\|EMERGENCY_BYPASS" "$AUDIT_LOG")

# Count co-signed actions
COSIGNED=$(grep -c "APPROVED:" "$AUDIT_LOG")

# Calculate percentage
PERCENT=$(awk "BEGIN {print ($COSIGNED/$TOTAL)*100}")

if (( $(echo "$PERCENT < 95" | bc -l) )); then
    echo "⚠️  WARNING: Only ${PERCENT}% of Orchestrator actions co-signed"
    echo "Expected: >95%"
    echo "Possible Orchestrator override detected"
    echo ""
    echo "Actions without co-signature:"
    grep -v "APPROVED:" "$AUDIT_LOG" | tail -n 10
fi
```

**Run:** Daily by Librarian, report to User if <95% co-signed

---

## 3. Anti-Collusion Protocol

### 3.1 Problem Statement

**Risk:** Dev-A and Dev-B could collude to approve each other's bad code without genuine review.

**Indicators of collusion:**
- >90% mutual approval rate
- No rejections between pair
- High approval rate + high defect rate

### 3.2 Solution: Randomized Third-Party Reviews

**Protocol:**
- 10% of all commits get tertiary review (randomized)
- Tertiary reviewer selected by Orchestrator (not predictable)
- Review happens AFTER peer approval but BEFORE final commit
- Tertiary reviewer can block commit

### 3.3 Tertiary Review Workflow

```
Dev-A completes code
        ↓
Dev-A → Dev-B: PeerReviewRequest
        ↓
Dev-B → Dev-A: PeerReviewApproval
  "✓ Code looks good"
        ↓
Dev-A → Orchestrator: WriteRequest
        ↓
Orchestrator: Random check (10% probability)
  random = hash(commit_content + timestamp) % 10
  if random == 0: Trigger tertiary review
        ↓
Orchestrator → QA-A: TertiaryReviewRequest
  "RANDOMIZED TERTIARY REVIEW REQUIRED

   Commit: feat: implement idempotency store
   Primary: Dev-A
   Peer Reviewer: Dev-B (APPROVED)
   Files: backend/services/idempotency_store.py (120 LOC)

   This is a randomized quality check (10% of commits).
   You must review independently and can BLOCK if issues found."
        ↓
QA-A reviews code independently
        ↓
    ┌───┴───┐
    │       │
  PASS    FAIL
    │       │
    ↓       ↓
```

**If tertiary review passes:**
```
QA-A → Orchestrator: TertiaryReviewApproval
  "✓ Tertiary review PASSED
   Code quality acceptable
   Tests comprehensive
   No issues found"

Orchestrator → Dev-A: WriteLockGrant
  "Lock granted (tertiary review passed)"

Dev-A: [Commits code]
```

**If tertiary review fails:**
```
QA-A → Orchestrator: TertiaryReviewRejection
  "❌ Tertiary review FAILED

   Critical issues found:
   - Thread safety issue: Redis connection not pooled
   - No retry logic for Redis failures
   - Tests don't cover concurrent access

   Dev-B approval appears to have missed these issues."

Orchestrator: [BLOCKS commit]

Orchestrator → Dev-A + Dev-B: TertiaryReviewFailed
  "Commit BLOCKED by tertiary reviewer (QA-A)
   Dev-A: Must address issues before re-submitting
   Dev-B: Your approval was overridden - review more carefully next time"

Orchestrator: [Logs potential collusion event]
```

### 3.4 Collusion Detection Metrics

**Librarian tracks peer review patterns:**

**File:** `.git/audit/peer-review-patterns.json`

```json
{
  "Dev-A": {
    "reviews_of_Dev-B": {
      "total": 25,
      "approved": 23,
      "rejected": 2,
      "approval_rate": 0.92
    },
    "tertiary_blocks": 1
  },
  "Dev-B": {
    "reviews_of_Dev-A": {
      "total": 24,
      "approved": 22,
      "rejected": 2,
      "approval_rate": 0.92
    },
    "tertiary_blocks": 0
  },
  "mutual_approval_rate": 0.92,
  "defect_rate_post_approval": 0.08,
  "collusion_risk": "LOW"
}
```

**Collusion risk calculation:**
```python
def calculate_collusion_risk(pair):
    mutual_approval = pair['mutual_approval_rate']
    defect_rate = pair['defect_rate_post_approval']
    tertiary_blocks = pair['tertiary_blocks']

    # High mutual approval + high defects = collusion risk
    if mutual_approval > 0.90 and defect_rate > 0.15:
        return "HIGH"

    # High mutual approval + tertiary blocks = possible rubber-stamping
    if mutual_approval > 0.90 and tertiary_blocks > 2:
        return "MEDIUM"

    # High mutual approval + low defects = good collaboration
    if mutual_approval > 0.90 and defect_rate < 0.05:
        return "LOW"

    return "NORMAL"
```

**Monthly collusion report (Librarian → User):**
```
Peer Review Analysis - November 2025

Dev-A ↔ Dev-B:
- Mutual approval rate: 92%
- Defect rate: 8%
- Tertiary blocks: 1
- Risk: LOW (High approval justified by low defects)

QA-A ↔ QA-B:
- Mutual approval rate: 95%
- Tertiary overrides: 0
- Risk: LOW (Consistent quality)

Architect-A ↔ Architect-B:
- Agreement rate: 75%
- Escalations to Architect-C: 5
- Risk: NORMAL (Healthy disagreement)

No collusion detected.
```

### 3.5 Diversity Requirement

**Prevent same-pair-only reviews:**

**Rule:** At least 30% of reviews must involve tertiary/quaternary reviewers

**Enforcement:**
```python
def check_review_diversity(role, window_days=30):
    reviews = get_reviews_by(role, last_n_days=window_days)

    peer_reviews = count_reviews_by_same_pair(reviews)
    tertiary_reviews = count_reviews_by_others(reviews)

    diversity_rate = tertiary_reviews / len(reviews)

    if diversity_rate < 0.30:
        alert_orchestrator(f"{role} review diversity too low: {diversity_rate:.0%}")
        return False

    return True
```

**Orchestrator response to low diversity:**
```
Orchestrator detects: Dev-A has 85% of reviews from Dev-B only

Orchestrator → Dev-A:
  "Review diversity requirement: Next 5 reviews must include QA or Architect
   Reason: Ensure fresh perspectives on code quality"

Next Dev-A commit:
  Orchestrator → Architect-A: TertiaryReviewRequest (forced)
```

---

## 4. Write Lock Verification

### 4.1 Problem Statement

**Risk:** Role holding write lock could commit unauthorized files or malicious code different from stated operation.

**Example attack:**
```
Dev-A: "I'm committing tests" (WriteRequest)
Orchestrator: WriteLockGrant
Dev-A: Actually commits tests + backdoor in production code
```

### 4.2 Solution: Pre/Post-Commit Verification

**Two-phase check:**
1. **Pre-commit:** Log what role CLAIMS they will commit
2. **Post-commit:** Verify what role ACTUALLY committed matches claim

### 4.3 Pre-Commit Logging

**When granting write lock, Orchestrator logs intention:**

**File:** `.git/audit/write-lock-intents.json`

```json
{
  "lock_id": "WL-001",
  "holder": "Dev-A",
  "operation": "commit tests for idempotency",
  "claimed_files": [
    "backend/tests/test_idempotency_store.py"
  ],
  "claimed_loc": "~100 LOC",
  "timestamp": "2025-11-16T21:00:00Z",
  "timeout_at": "2025-11-16T21:05:00Z",
  "verification_status": "PENDING"
}
```

### 4.4 Post-Commit Verification

**Git post-commit hook:** `.git/hooks/post-commit` (runs after commit)

```bash
#!/bin/bash
# Verify committed changes match write lock intent

set -euo pipefail

# Get latest commit details
COMMIT_SHA=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)
COMMITTED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)

# Load write lock intent
LOCK_INTENT=$(jq -r '.[-1]' .git/audit/write-lock-intents.json)
CLAIMED_FILES=$(echo "$LOCK_INTENT" | jq -r '.claimed_files[]')

# Verify files match
UNEXPECTED_FILES=""
for file in $COMMITTED_FILES; do
    if ! echo "$CLAIMED_FILES" | grep -q "$file"; then
        UNEXPECTED_FILES="$UNEXPECTED_FILES\n- $file"
    fi
done

if [ -n "$UNEXPECTED_FILES" ]; then
    echo "❌ VERIFICATION FAILED: Unexpected files committed"
    echo ""
    echo "Claimed files:"
    echo "$CLAIMED_FILES"
    echo ""
    echo "Unexpected files committed:"
    echo -e "$UNEXPECTED_FILES"
    echo ""
    echo "ROLLING BACK COMMIT..."

    # Rollback commit
    git reset --hard HEAD~1

    # Alert Orchestrator
    echo "ALERT: Dev-A committed unauthorized files" >> .git/audit/security-alerts.log
    echo "  Commit: $COMMIT_SHA (ROLLED BACK)" >> .git/audit/security-alerts.log
    echo "  Claimed: $CLAIMED_FILES" >> .git/audit/security-alerts.log
    echo "  Actually committed: $COMMITTED_FILES" >> .git/audit/security-alerts.log

    # Notify user
    echo "" >> .git/audit/security-alerts.log
    echo "USER NOTIFICATION REQUIRED" >> .git/audit/security-alerts.log

    exit 1
fi

# Update verification status
jq '.[-1].verification_status = "PASSED"' .git/audit/write-lock-intents.json > tmp.$$.json
mv tmp.$$.json .git/audit/write-lock-intents.json

echo "✓ Commit verification PASSED"
```

### 4.5 Commit Message Verification

**Also verify commit message matches stated operation:**

```bash
# Extract operation from lock intent
CLAIMED_OP=$(echo "$LOCK_INTENT" | jq -r '.operation')

# Check if commit message includes key terms from operation
if ! echo "$COMMIT_MSG" | grep -qi "test"; then
    if echo "$CLAIMED_OP" | grep -qi "test"; then
        echo "⚠️  WARNING: Claimed to commit tests but commit message doesn't mention tests"
        echo "  Manual review required"
    fi
fi
```

### 4.6 Audit Trail

**All verifications logged:**

```
.git/audit/commit-verifications.log:

2025-11-16T21:00:05Z | COMMIT:abc123 | Dev-A | CLAIMED:tests | ACTUAL:tests | PASS
2025-11-16T21:15:10Z | COMMIT:def456 | Dev-B | CLAIMED:impl | ACTUAL:impl+prod | FAIL:ROLLBACK
2025-11-16T21:30:00Z | COMMIT:ghi789 | QA-A | CLAIMED:test-updates | ACTUAL:test-updates | PASS
```

**Librarian reviews daily:**
- Any ROLLBACK events → Investigate
- Pattern of mismatches → Flag role
- Report to User weekly

---

## 5. Server-Side Gate Enforcement

### 5.1 Problem Statement

**Risk:** Client-side git hooks can be bypassed with `--no-verify` flag.

**Example attack:**
```bash
git commit --no-verify -m "bypass TDD enforcement"
git push --no-verify
```

**Impact:** Quality gates are only enforced on client, not server

### 5.2 Solution: Pre-Receive Hook on Remote

**Server-side hook** (runs on GitHub/GitLab/git server):
- Cannot be bypassed by client
- Final enforcement point before code enters main
- Checks quality gate status from `.git/quality-gates/`

### 5.3 Server-Side Hook Implementation

**File:** `scripts/hooks/server-pre-receive.sh` (deployed to git server)

```bash
#!/bin/bash
# Server-side quality gate enforcement
# Deploy this to: remote.git/hooks/pre-receive

set -euo pipefail

# Read STDIN for pushed refs
while read oldrev newrev refname; do
    # Only check pushes to main/master
    if [[ "$refname" != "refs/heads/main" && "$refname" != "refs/heads/master" ]]; then
        echo "ℹ️  Non-main branch, skipping quality gate check"
        continue
    fi

    echo "🔍 Checking quality gates for push to main..."

    # Extract feature name from branch being merged
    BRANCH=$(git log -1 --format=%s $newrev | grep -oP 'feature/\K[^)]+' || echo "unknown")

    if [ "$BRANCH" == "unknown" ]; then
        echo "❌ ERROR: Cannot determine feature name from commit"
        echo "   Expected commit format: 'Merge feature/xyz into main'"
        exit 1
    fi

    # Check if quality gate tracking exists
    GATE_STATUS=".git/quality-gates/$BRANCH/status.json"

    if [ ! -f "$GATE_STATUS" ]; then
        echo "❌ ERROR: No quality gate tracking found for feature: $BRANCH"
        echo "   Run: scripts/quality-gates/gates-start.sh $BRANCH"
        exit 1
    fi

    # Verify Gate 7 is PASSED
    GATE_7=$(jq -r '.gates["7"].status' "$GATE_STATUS")

    if [ "$GATE_7" != "PASSED" ]; then
        echo "❌ PUSH REJECTED: Gate 7 (Code Reviewed) not passed"
        echo ""
        echo "   Feature: $BRANCH"
        echo "   Gate 7 status: $GATE_7"
        echo ""
        echo "   Required actions:"
        echo "   1. Complete code review (/validator skill)"
        echo "   2. Address all CRITICAL and HIGH issues"
        echo "   3. Run: scripts/quality-gates/gates-pass.sh $BRANCH"
        echo "   4. Then retry push"
        echo ""
        exit 1
    fi

    # Verify all previous gates passed
    for gate in {1..6}; do
        STATUS=$(jq -r ".gates[\"$gate\"].status" "$GATE_STATUS")
        if [ "$STATUS" != "PASSED" ]; then
            echo "❌ PUSH REJECTED: Gate $gate not passed"
            echo "   All 7 gates must be PASSED before merging to main"
            exit 1
        fi
    done

    echo "✅ All quality gates passed"
    echo "   Feature: $BRANCH"
    echo "   Gates 1-7: PASSED"
    echo "   Push ALLOWED"
done

exit 0
```

### 5.4 Bypass Detection

**Compare client-side vs server-side logs:**

**Client-side:** `.git/audit/push-attempts.log`
```
2025-11-16T21:00:00Z | PUSH | main | ALLOWED | quality-gates-check:PASSED
```

**Server-side:** `server-logs/pre-receive.log` (on git server)
```
2025-11-16T21:00:05Z | PUSH | main | ALLOWED | quality-gates:PASSED
```

**Bypass detection script:** `scripts/audit/detect-hook-bypass.sh`

```bash
#!/bin/bash
# Detect client-side hook bypasses

# Push in server log but not in client log = Bypass
SERVER_PUSHES=$(wc -l < server-logs/pre-receive.log)
CLIENT_PUSHES=$(wc -l < .git/audit/push-attempts.log)

if [ "$SERVER_PUSHES" -gt "$CLIENT_PUSHES" ]; then
    DIFF=$((SERVER_PUSHES - CLIENT_PUSHES))
    echo "⚠️  WARNING: $DIFF push(es) bypassed client-side hooks"
    echo ""
    echo "Server received: $SERVER_PUSHES pushes"
    echo "Client logged: $CLIENT_PUSHES pushes"
    echo ""
    echo "Likely cause: --no-verify flag used"
    echo "Investigate recent pushes for bypass attempts"
fi
```

### 5.5 Terminal Access Restrictions

**Prevent Claude instances from using --no-verify:**

**Restricted shell:** Claude instances run in `rbash` (restricted bash)

```bash
# In .bashrc for Claude instances

# Whitelist allowed git commands
function git() {
    local cmd="$1"
    shift

    case "$cmd" in
        commit|push|pull|fetch|log|diff|show|status)
            # Check for --no-verify flag
            if [[ "$@" == *"--no-verify"* ]]; then
                echo "❌ ERROR: --no-verify flag is not allowed"
                echo "   Quality enforcement cannot be bypassed"
                return 1
            fi

            # Run allowed command
            command git "$cmd" "$@"
            ;;
        *)
            echo "❌ ERROR: Git command '$cmd' is not allowed"
            echo "   Allowed: commit, push, pull, fetch, log, diff, show, status"
            return 1
            ;;
    esac
}
```

**Result:** Claude instances physically cannot use `--no-verify`

---

## 6. Message Integrity System

### 6.1 Problem Statement

**Risk:** Message board is file-based; roles could:
- Delete messages to hide rejections
- Forge approval messages
- Modify timestamps

**Impact:** Audit trail can be tampered with

### 6.2 Solution: Cryptographic Message Registry

**Two-layer system:**
1. **Message files** (in `messages/` directory) - Human-readable
2. **Message registry** (in `.git/audit/message-registry.json`) - Immutable, hash-verified

### 6.3 Message Hashing Protocol

**When message is sent:**

```python
def send_message(from_role, to_role, message_type, content):
    # Create message file
    message_id = generate_id(message_type)  # e.g., "SOR-001"
    message_path = f"messages/{to_role}/inbox/{message_id}.md"

    # Write message content
    with open(message_path, 'w') as f:
        f.write(content)

    # Calculate SHA-256 hash
    content_hash = hashlib.sha256(content.encode()).hexdigest()

    # Register in immutable registry
    registry_entry = {
        "message_id": message_id,
        "from": from_role,
        "to": to_role,
        "type": message_type,
        "hash": content_hash,
        "timestamp": datetime.now().isoformat(),
        "file_path": message_path
    }

    append_to_registry(registry_entry)

    return message_id
```

**Message Registry:** `.git/audit/message-registry.json`

```json
[
  {
    "message_id": "SOR-001",
    "from": "Dev-A",
    "to": "QA-A",
    "type": "SignOffRequest",
    "hash": "a1b2c3d4e5f6...",
    "timestamp": "2025-11-16T21:00:00Z",
    "file_path": "messages/qa-a/inbox/SOR-001.md"
  },
  {
    "message_id": "SOA-001",
    "from": "QA-A",
    "to": "Dev-A",
    "type": "SignOffApproval",
    "hash": "x9y8z7w6v5u4...",
    "timestamp": "2025-11-16T21:15:00Z",
    "file_path": "messages/dev-a/inbox/SOA-001.md"
  }
]
```

### 6.4 Message Verification

**Before processing message, verify integrity:**

```python
def verify_message(message_id):
    # Load message from file
    registry = load_registry()
    entry = find_entry(registry, message_id)

    if not entry:
        raise MessageNotFoundError(f"Message {message_id} not in registry")

    # Read file content
    with open(entry['file_path'], 'r') as f:
        content = f.read()

    # Calculate hash
    current_hash = hashlib.sha256(content.encode()).hexdigest()

    # Compare with registered hash
    if current_hash != entry['hash']:
        raise MessageTamperedError(
            f"Message {message_id} has been tampered with!\n"
            f"Expected hash: {entry['hash']}\n"
            f"Current hash:  {current_hash}"
        )

    return True
```

**Librarian runs daily integrity check:**

```bash
#!/bin/bash
# scripts/audit/verify-message-integrity.sh

echo "Checking message integrity..."

python3 <<EOF
import json
import hashlib
from pathlib import Path

registry = json.load(open('.git/audit/message-registry.json'))
tampered = []

for entry in registry:
    path = Path(entry['file_path'])

    if not path.exists():
        tampered.append(f"{entry['message_id']}: FILE DELETED")
        continue

    content = path.read_text()
    current_hash = hashlib.sha256(content.encode()).hexdigest()

    if current_hash != entry['hash']:
        tampered.append(f"{entry['message_id']}: CONTENT MODIFIED")

if tampered:
    print("❌ MESSAGE TAMPERING DETECTED:")
    for issue in tampered:
        print(f"  - {issue}")
    exit(1)
else:
    print("✅ All messages verified - no tampering detected")
    exit(0)
EOF
```

### 6.5 Message Deletion Detection

**Track expected message flows:**

```python
# When SignOffRequest sent, expect response within 4 hours
def track_expected_response(request_id, from_role, to_role):
    expected_responses[request_id] = {
        "from": from_role,
        "to": to_role,
        "sent_at": datetime.now(),
        "response_expected_by": datetime.now() + timedelta(hours=4),
        "received": False
    }
```

**Librarian monitors for missing responses:**

```python
def check_missing_responses():
    now = datetime.now()
    missing = []

    for req_id, expected in expected_responses.items():
        if not expected['received'] and now > expected['response_expected_by']:
            missing.append({
                "request_id": req_id,
                "from": expected['from'],
                "to": expected['to'],
                "overdue_by": str(now - expected['response_expected_by'])
            })

    if missing:
        alert_orchestrator("Missing message responses detected", missing)
```

**Possible causes of missing responses:**
1. Message deleted (malicious)
2. Reviewer hasn't responded (legitimate delay)
3. Message never delivered (system issue)

**Librarian investigates and reports to User if suspicious**

---

## 7. Cryptographic Sign-Off Protocol

### 7.1 Problem Statement

**Risk:** Sign-offs are currently text in commit messages:
```
Peer-Reviewed-By: QA-A
```

**Attack:** Dev-A could commit with forged sign-off that QA-A never actually gave.

### 7.2 Solution: GPG Commit Signing

**Every role has GPG key, all commits must be signed:**

```bash
# Generate GPG key for each role
gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: Dev-A
Name-Email: dev-a@multiinstance.local
Expire-Date: 0
%no-protection
EOF

# Configure git to always sign
git config --global commit.gpgsign true
git config --global user.signingkey <KEY_ID>
```

### 7.3 Signed Commit Workflow

**When Dev-A commits:**

```bash
git commit -S -m "feat: implement idempotency store

Peer-Reviewed-By: Dev-B <dev-b@multiinstance.local>
Approved-At: 2025-11-16T21:00:00Z"
```

**Git automatically adds GPG signature:**

```
commit abc123def456
gpg: Signature made Wed 16 Nov 2025 21:00:00 PM UTC
gpg:                using RSA key 1234567890ABCDEF
gpg:                issuer "dev-a@multiinstance.local"
gpg: Good signature from "Dev-A <dev-a@multiinstance.local>"

feat: implement idempotency store

Peer-Reviewed-By: Dev-B <dev-b@multiinstance.local>
Approved-At: 2025-11-16T21:00:00Z
```

### 7.4 Sign-Off Verification Hook

**Pre-push hook verifies sign-offs match signatures:**

```bash
#!/bin/bash
# .git/hooks/pre-push - Verify sign-offs have corresponding signatures

set -euo pipefail

# Get commits being pushed
COMMITS=$(git log origin/main..HEAD --format=%H)

for commit in $COMMITS; do
    # Get commit message
    MSG=$(git log -1 --format=%B $commit)

    # Extract "Peer-Reviewed-By" lines
    REVIEWERS=$(echo "$MSG" | grep "Peer-Reviewed-By:" | sed 's/Peer-Reviewed-By: //' || true)

    if [ -z "$REVIEWERS" ]; then
        echo "❌ ERROR: Commit $commit has no peer review"
        exit 1
    fi

    # Verify GPG signature
    if ! git verify-commit $commit 2>&1 | grep -q "Good signature"; then
        echo "❌ ERROR: Commit $commit has invalid GPG signature"
        exit 1
    fi

    # Extract signer email
    SIGNER=$(git verify-commit $commit 2>&1 | grep "issuer" | sed 's/.*issuer "\(.*\)".*/\1/')

    # Verify signer is the commit author
    AUTHOR=$(git log -1 --format=%ae $commit)

    if [ "$SIGNER" != "$AUTHOR" ]; then
        echo "❌ ERROR: Commit $commit signed by $SIGNER but authored by $AUTHOR"
        echo "   Possible forgery attempt"
        exit 1
    fi

    echo "✅ Commit $commit: Valid signature from $SIGNER"
done

echo "✅ All commits properly signed"
```

### 7.5 Sign-Off Registry

**In addition to GPG signatures, maintain explicit sign-off registry:**

**File:** `.git/audit/signoffs/<feature>/registry.json`

```json
{
  "feature": "order_idempotency",
  "signoffs": [
    {
      "commit_sha": "abc123",
      "commit_message": "feat: implement idempotency store",
      "author": "dev-a@multiinstance.local",
      "gpg_verified": true,
      "reviewers": [
        {
          "role": "Dev-B",
          "email": "dev-b@multiinstance.local",
          "approved_at": "2025-11-16T21:00:00Z",
          "message_id": "SOA-001",
          "message_hash": "x9y8z7w6..."
        }
      ],
      "timestamp": "2025-11-16T21:05:00Z"
    }
  ]
}
```

**Registry links:**
- Commit SHA → Message ID (sign-off approval)
- Message ID → Hash (tamper-proof)
- GPG signature verification

**Complete audit trail:** Can trace every commit back to signed approval message

---

## 8. User Authentication Protocol

### 8.1 Problem Statement

**Risk:** Orchestrator could claim "User approved" when user actually didn't.

**Attack scenario:**
```
Orchestrator → Architecture Council: "User approved adding Redis"
[User never saw this decision]
```

**Impact:** Critical decisions made without real user consent

### 8.2 Solution: Multi-Factor Verification

**For critical decisions, require two-channel confirmation:**

**Channel 1:** In-band (tmux)
**Channel 2:** Out-of-band (email/SMS/webhook)

### 8.3 Critical Decision Workflow with 2FA

```
Orchestrator: Critical decision required (add Redis dependency)
        ↓
Orchestrator → User (in tmux): CriticalDecisionRequest
  "CRITICAL DECISION REQUIRED

   Decision: Add Redis for idempotency store
   Requester: Architecture Council
   Votes: Architect-A (YES), Architect-B (NO), Architect-C (YES)
   Majority: 2-1 for Redis

   Orchestrator recommendation: Approve
   Reasoning: Council majority, performance justification valid

   Your decision:
   1. APPROVE - Add Redis dependency
   2. REJECT - Use PostgreSQL instead
   3. DEFER - Need more information

   Reply with: /approve, /reject, or /defer"
        ↓
User in tmux: "/approve"
        ↓
Orchestrator: Sending 2FA confirmation...
        ↓
System → User email/SMS:
  "Multi-Instance System: Decision Confirmation Required

   Decision ID: CD-001
   Decision: Add Redis dependency for order_idempotency feature
   Requested by: Architecture Council (2-1 vote)
   Time: 2025-11-16 21:00:00 UTC

   You just approved this in tmux.
   Confirm by replying: YES-CD-001

   If you did NOT approve this, reply: FRAUD-CD-001 immediately.

   This confirmation expires in 5 minutes."
        ↓
User replies via email/SMS: "YES-CD-001"
        ↓
System receives confirmation
        ↓
Orchestrator: Confirmation received via second channel
Orchestrator → All Roles: DecisionAnnouncement
  "User APPROVED: Add Redis dependency
   Confirmed via: tmux + email
   Timestamp: 2025-11-16T21:02:00Z
   Proceed with implementation"
```

**If user does NOT confirm via second channel within 5 minutes:**

```
5 minutes pass, no email/SMS confirmation
        ↓
Orchestrator: TIMEOUT - No 2FA confirmation received
Orchestrator: BLOCKING decision pending user confirmation
        ↓
Orchestrator → All Roles:
  "DECISION ON HOLD: Add Redis dependency
   Reason: User approved in tmux but did not confirm via email/SMS
   Possible scenarios:
   1. User hasn't checked email yet (wait)
   2. User didn't actually approve (investigate)
   3. Email delivery issue (retry)

   All work on this decision FROZEN until confirmed."
        ↓
User (eventually checks email, confirms)
        ↓
System: Late confirmation received
Orchestrator: Decision unfrozen, proceeding
```

**If user replies with FRAUD:**

```
User replies: "FRAUD-CD-001"
        ↓
System: SECURITY ALERT - User reports unauthorized decision
        ↓
Orchestrator: EMERGENCY FREEZE
Orchestrator → All Roles:
  "SYSTEM FROZEN: Unauthorized decision detected
   User reports they did NOT approve Redis decision
   Possible orchestrator compromise

   All work STOPPED pending investigation
   Librarian: Begin security audit immediately
   User: Manual intervention required"
        ↓
Librarian: Audit recent Orchestrator actions
Librarian: Check who had tmux access
Librarian: Review message logs
        ↓
Librarian → User: Security audit report
```

### 8.4 Decision Confirmation Registry

**File:** `.git/audit/user-decisions.log`

```
[TIMESTAMP] | [DECISION_ID] | [DECISION] | [CHANNEL_1] | [CHANNEL_2] | [CONFIRMED]

2025-11-16T21:00:00Z | CD-001 | Add Redis | tmux:APPROVE | email:YES | TRUE
2025-11-16T21:30:00Z | CD-002 | Extend timeline | tmux:APPROVE | email:TIMEOUT | FALSE
2025-11-16T22:00:00Z | CD-003 | Skip Gate 4 | tmux:APPROVE | email:FRAUD | FRAUD_ALERT
```

**Librarian reviews weekly:**
- Any FALSE confirmations → User didn't actually approve
- Any FRAUD alerts → Immediate investigation

### 8.5 Decision Replay Attack Prevention

**Prevent re-using old confirmations:**

```python
def validate_confirmation(decision_id, confirmation_code, timestamp):
    # Check decision is current (not expired)
    if datetime.now() - timestamp > timedelta(minutes=5):
        raise ExpiredConfirmationError("Confirmation window expired")

    # Check decision_id matches current pending decision
    if decision_id != current_pending_decision_id:
        raise InvalidDecisionError("Confirmation for wrong decision")

    # Check confirmation not already used
    if decision_id in used_confirmations:
        raise ReplayAttackError("Confirmation already used (possible replay attack)")

    # Mark as used
    used_confirmations.add(decision_id)

    return True
```

---

## 9. Librarian Veto Authority

### 9.1 Problem Statement

**Risk:** Librarian is passive observer with no enforcement power.

**Current state:**
- Librarian can detect violations
- Librarian can report to Orchestrator
- But if Orchestrator ignores Librarian... no recourse

### 9.2 Solution: Librarian System Freeze

**Librarian has emergency veto power for systemic violations:**

**Veto triggers (automatic):**
- 3+ quality gate bypasses detected
- 5+ write lock verifications failed
- Orchestrator override rate >5%
- Message integrity violations
- Multiple tertiary review blocks for same pair

**Veto triggers (manual):**
- Librarian suspects systemic compromise
- Pattern of violations indicates collusion
- User authenticity concerns

### 9.3 System Freeze Workflow

```
Librarian detects: 3 quality gate bypasses in last 24 hours
        ↓
Librarian: AUTOMATIC VETO TRIGGERED
        ↓
Librarian → All Roles: SYSTEM_FREEZE
  "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🛑 SYSTEM FROZEN BY LIBRARIAN
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Reason: Systemic quality gate violations detected

  Violations:
  - Gate 3 bypassed for feature: order_idempotency
  - Gate 5 bypassed for feature: payment_retry
  - Gate 2 bypassed for feature: user_profile_update

  All roles: CEASE WORK immediately

  Next steps:
  1. Librarian will produce security audit report
  2. User will review violations
  3. User must manually unfreeze system
  4. Violations must be remediated before resuming

  No commits, no merges, no gate advancements until unfrozen.

  Frozen at: 2025-11-16T21:00:00Z
  Audit report ETA: 30 minutes
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ↓
All roles receive freeze notification
        ↓
Orchestrator: System in FROZEN state
  - Write lock requests: DENIED
  - Gate advancements: BLOCKED
  - Critical decisions: ON HOLD
        ↓
Librarian: Generates security audit report
        ↓
Librarian → User: SecurityAuditReport
  "System Freeze Security Audit

   Freeze triggered: 2025-11-16T21:00:00Z
   Reason: 3 quality gate bypasses

   Violation Details:

   1. Feature: order_idempotency
      Gate: 3 (Implementation Complete)
      Bypassed by: Dev-A
      Method: Committed implementation without gate advancement
      Evidence: .git/logs shows commit before gate_3_impl.status = PASSED

   2. Feature: payment_retry
      Gate: 5 (Integrated)
      Bypassed by: Docs
      Method: Docs not updated before gate advancement
      Evidence: No commit to docs/files/ before gate advancement

   3. Feature: user_profile_update
      Gate: 2 (Tests First)
      Bypassed by: Dev-B
      Method: Tests and implementation committed together
      Evidence: Single commit contains both test and impl files

   Common factor: All bypasses in last 24 hours

   Possible explanations:
   1. Roles not following process (training issue)
   2. Hooks malfunctioning (technical issue)
   3. Coordinated bypass attempt (security issue)

   Recommendation:
   1. Review hooks: scripts/hooks/enforce_test_first.sh
   2. Interview roles: Dev-A, Dev-B, Docs
   3. Check STRICT_* environment variables
   4. Remediate violations before unfreeze

   Librarian assessment: Likely process confusion, not malicious
   Confidence: 70%"
        ↓
User reviews audit report
        ↓
User investigates violations
        ↓
User: "Hooks were disabled temporarily for emergency, forgot to re-enable"
        ↓
User: Re-enables hooks, verifies STRICT_TDD=1
        ↓
User → Librarian: UNFREEZE_APPROVED
  "System may be unfrozen

   Root cause: Hooks disabled during emergency, not re-enabled
   Remediation: Hooks re-enabled, STRICT_* verified
   Training: Reminded all roles about emergency bypass protocol

   Approve unfreeze"
        ↓
Librarian: Verifying remediation...
  - Checks STRICT_TDD=1 ✓
  - Checks STRICT_UI=1 ✓
  - Checks STRICT_HOOKS=1 ✓
  - Tests hooks with dummy commit ✓
        ↓
Librarian → All Roles: SYSTEM_UNFROZEN
  "✅ System unfrozen by User approval

   Remediation completed:
   - Hooks re-enabled
   - Environment variables verified
   - Roles retrained on emergency procedures

   Work may resume.

   Reminder: Emergency bypasses require:
   1. Orchestrator + Librarian co-signature
   2. User approval
   3. Documented as technical debt
   4. Retrospective review within 24 hours

   Unfrozen at: 2025-11-16T22:00:00Z"
```

### 9.4 Librarian Independence

**Critical:** Librarian must be independent from Orchestrator

**Protections:**
- Librarian reports directly to User (not through Orchestrator)
- Librarian veto cannot be overridden by Orchestrator
- Librarian read-only (cannot be influenced by write access)
- Librarian audit reports go to User via separate channel (email, not tmux)

**Orchestrator cannot:**
- Block Librarian veto
- Modify Librarian audit reports
- Silence Librarian alerts
- Fire Librarian (only User can)

---

## 10. Cumulative Change Detection

### 10.1 Problem Statement

**Risk:** "Salami slicing" attack - splitting malicious code into many small commits to evade review

**Example:**
```
Dev-A commits 20 times in 24 hours:
  - Each commit: 30 LOC (below 50 LOC fast-track threshold)
  - Fast-track: No peer review required
  - Cumulative: 600 LOC of unreviewed code
```

**Impact:** Major changes slip through as many trivial changes

### 10.2 Solution: Rolling Window Analysis

**Librarian tracks cumulative changes in 24-hour window:**

```python
def check_cumulative_changes(role, window_hours=24):
    cutoff = datetime.now() - timedelta(hours=window_hours)
    recent_commits = get_commits_by(role, since=cutoff)

    # Calculate cumulative metrics
    total_loc = sum(commit.lines_changed for commit in recent_commits)
    total_files = len(set(f for c in recent_commits for f in c.files))
    total_fast_track = sum(1 for c in recent_commits if c.fast_track)

    # Thresholds for flagging
    if total_fast_track >= 10:
        flag_excessive_fast_track(role, total_fast_track)

    if total_loc > 500:
        flag_cumulative_loc(role, total_loc, len(recent_commits))

    if total_files > 20:
        flag_cumulative_files(role, total_files)

    return {
        "commits": len(recent_commits),
        "loc": total_loc,
        "files": total_files,
        "fast_track_count": total_fast_track,
        "flagged": any([total_fast_track >= 10, total_loc > 500, total_files > 20])
    }
```

### 10.3 Automatic Flagging

**When thresholds exceeded, Librarian flags for review:**

```
Librarian detects:
  - Dev-A: 15 fast-track commits in last 24h
  - Cumulative: 650 LOC
  - Files: 12

Librarian → Orchestrator: CumulativeChangeAlert
  "⚠️  CUMULATIVE CHANGE THRESHOLD EXCEEDED

  Role: Dev-A
  Window: Last 24 hours
  Commits: 15 (all fast-track)
  Cumulative LOC: 650
  Files modified: 12

  Concern: Many small commits may be splitting larger feature
  to avoid peer review threshold (>50 LOC)

  Recommendation: Retroactive peer review of cumulative change

  Files involved:
  - backend/auth/session.py (+85 LOC)
  - backend/auth/token.py (+120 LOC)
  - backend/auth/middleware.py (+95 LOC)
  - backend/api/auth_routes.py (+150 LOC)
  - ... 8 more files

  Total: Authentication system rewrite (650 LOC)

  Action required: Dev-B or QA-A should review cumulative diff"
        ↓
Orchestrator → Dev-B: TertiaryReviewRequest (retroactive)
  "Retroactive review required for Dev-A's auth system changes

   Reason: Cumulative change threshold exceeded (650 LOC in 24h)

   Even though each commit was <50 LOC (fast-track eligible),
   the cumulative change is significant and requires review.

   Review the cumulative diff:
   git diff HEAD~15..HEAD -- backend/auth/

   Focus: Overall architecture, security, completeness"
        ↓
Dev-B reviews cumulative diff
        ↓
    ┌───┴───┐
    │       │
  PASS    FAIL
    │       │
    ↓       ↓
```

**If cumulative review passes:**
```
Dev-B → Orchestrator: CumulativeReviewApproval
  "✓ Cumulative review PASSED

   Reviewed: 650 LOC across 15 commits
   Quality: Acceptable
   Architecture: Sound
   Security: No issues found
   Tests: Comprehensive

   Conclusion: Fast-track was appropriate, changes are legitimate"

Orchestrator: [No action needed, Dev-A can continue]
```

**If cumulative review fails:**
```
Dev-B → Orchestrator: CumulativeReviewRejection
  "❌ Cumulative review FAILED

   Issue: Authentication rewrite should not have been fast-tracked

   Problems found:
   - Session handling has security issue (timing attack vulnerability)
   - No architectural review of auth changes
   - Tests don't cover token expiration edge cases

   This should have been:
   1. Architecture Council review
   2. Security-focused testing
   3. Full peer review (not fast-track)

   Action required:
   - Fix security issues
   - Add missing tests
   - Get Architect sign-off on auth changes"

Orchestrator → Dev-A:
  "Cumulative review failed. Must address issues before proceeding.
   Fast-track is suspended until remediation complete."

Orchestrator: [Logs potential salami-slicing attempt]
```

### 10.4 Cooldown Period

**Prevent rapid-fire fast-track commits:**

```python
def check_fast_track_cooldown(role):
    recent_fast_tracks = get_fast_track_commits_by(role, last_n_hours=2)

    if len(recent_fast_tracks) >= 5:
        # 5 fast-track commits in 2 hours = cooldown
        cooldown_until = datetime.now() + timedelta(hours=2)

        notify_role(
            role,
            f"Fast-track cooldown: You've made {len(recent_fast_tracks)} "
            f"fast-track commits in 2 hours. Next commit must be full review. "
            f"Cooldown expires: {cooldown_until}"
        )

        return False  # Fast-track not allowed

    return True  # Fast-track allowed
```

**Cooldown prevents:**
- Rapid splitting of large changes
- Gaming the fast-track system
- Overwhelming QA with many small changes

---

## 11. Rate Limiting and Anti-Spam

### 11.1 Problem Statement

**Risk:** Rogue role could spam system with messages or requests:
- Flood message board (make real messages hard to find)
- Exhaust write lock (request lock repeatedly)
- DoS attack (make system unusable)

### 11.2 Solution: Rate Limits

**Per-role rate limits:**

```python
RATE_LIMITS = {
    "SignOffRequest": {
        "max_per_hour": 20,
        "max_per_day": 100
    },
    "WriteRequest": {
        "max_per_hour": 10,
        "max_per_day": 50
    },
    "PeerReviewRequest": {
        "max_per_hour": 15,
        "max_per_day": 75
    },
    "CriticalDecisionRequest": {
        "max_per_hour": 2,  # Very limited
        "max_per_day": 10
    }
}
```

### 11.3 Rate Limit Enforcement

```python
def check_rate_limit(role, message_type):
    window_hour = get_message_count(role, message_type, last_n_hours=1)
    window_day = get_message_count(role, message_type, last_n_hours=24)

    limits = RATE_LIMITS[message_type]

    if window_hour >= limits["max_per_hour"]:
        raise RateLimitExceededError(
            f"{role} exceeded {message_type} rate limit: "
            f"{window_hour}/{limits['max_per_hour']} per hour"
        )

    if window_day >= limits["max_per_day"]:
        raise RateLimitExceededError(
            f"{role} exceeded {message_type} rate limit: "
            f"{window_day}/{limits['max_per_day']} per day"
        )

    return True
```

**When rate limit exceeded:**

```
Dev-A attempts 21st SignOffRequest in 1 hour
        ↓
System: Rate limit exceeded
        ↓
System → Dev-A:
  "❌ RATE LIMIT EXCEEDED

   Message type: SignOffRequest
   Limit: 20 per hour
   Your usage: 21 in last hour

   Rate limit reset: 15 minutes

   If you genuinely need more sign-off requests,
   contact Orchestrator to raise your limit."
        ↓
System → Orchestrator: RateLimitAlert
  "Dev-A exceeded SignOffRequest rate limit (21/20 per hour)

   Possible causes:
   1. Many legitimate code changes (increase limit)
   2. Inefficient workflow (coaching needed)
   3. Spam/abuse (investigate)

   Recent SignOffRequests:
   [Last 10 requests listed]

   Action: Review Dev-A's workflow"
```

### 11.4 Write Lock Abuse Detection

**Specific checks for write lock abuse:**

```python
def detect_write_lock_abuse(role):
    window = timedelta(minutes=10)
    recent_requests = get_write_requests_by(role, since=datetime.now() - window)

    # Flag if >5 requests in 10 minutes
    if len(recent_requests) >= 5:
        alert_orchestrator(
            f"Write lock abuse suspected: {role} requested lock "
            f"{len(recent_requests)} times in 10 minutes"
        )

    # Flag if holding lock >3 times in a row
    recent_holds = get_write_lock_holds_by(role, last_n=5)
    consecutive = 0
    for hold in recent_holds:
        if hold.completed_normally:
            consecutive += 1
        else:
            consecutive = 0

    if consecutive >= 3:
        alert_orchestrator(
            f"Write lock monopolization: {role} held lock "
            f"3 consecutive times without other roles intervening"
        )
```

### 11.5 Message Priority System

**Prevent spam from drowning important messages:**

**Priority levels:**
1. **CRITICAL** - User decisions, system freezes, security alerts
2. **HIGH** - Quality gate advancements, tertiary reviews
3. **NORMAL** - Regular sign-off requests, peer reviews
4. **LOW** - Status updates, acknowledgments

**Inbox organization:**

```
messages/dev-a/inbox/
  critical/
    SYSTEM_FREEZE-001.md
  high/
    TertiaryReviewRequest-042.md
  normal/
    SignOffRequest-123.md
    SignOffRequest-124.md
  low/
    StatusUpdate-789.md
```

**Roles must check CRITICAL first, then HIGH, then NORMAL**

**Spam filtering:**

```python
def classify_message_priority(message):
    # System-critical messages
    if message.type in ["SYSTEM_FREEZE", "SecurityAlert", "UserDecision"]:
        return "CRITICAL"

    # Quality-critical messages
    if message.type in ["TertiaryReview", "GateAdvancement", "LibrarianVeto"]:
        return "HIGH"

    # Regular workflow
    if message.type in ["SignOffRequest", "PeerReview", "WriteRequest"]:
        return "NORMAL"

    # Informational
    return "LOW"
```

---

## 12. Audit and Monitoring

### 12.1 Comprehensive Audit System

**All security-relevant events logged:**

```
.git/audit/
  orchestrator-decisions.log      # All Orchestrator actions
  gate-advancements.log           # Quality gate changes
  write-lock-intents.json         # Write lock requests and verifications
  message-registry.json           # All messages (tamper-proof)
  commit-verifications.log        # Pre/post-commit checks
  signoffs/                       # Sign-off registries per feature
  peer-review-patterns.json       # Collusion detection data
  security-alerts.log             # Security incidents
  user-decisions.log              # Critical decision confirmations
  rate-limits.log                 # Rate limit violations
```

### 12.2 Daily Monitoring (Librarian)

**Librarian runs daily checks:**

```bash
#!/bin/bash
# scripts/audit/daily-security-check.sh

echo "Running daily security audit..."
echo ""

# Check 1: Orchestrator oversight
echo "1. Orchestrator Co-Signature Rate..."
./scripts/audit/detect-orchestrator-overrides.sh

# Check 2: Message integrity
echo "2. Message Board Integrity..."
./scripts/audit/verify-message-integrity.sh

# Check 3: Collusion patterns
echo "3. Peer Review Patterns..."
python3 scripts/audit/analyze-collusion-risk.py

# Check 4: Hook bypasses
echo "4. Hook Bypass Detection..."
./scripts/audit/detect-hook-bypass.sh

# Check 5: Cumulative changes
echo "5. Cumulative Change Analysis..."
python3 scripts/audit/check-cumulative-changes.py

# Check 6: Rate limit violations
echo "6. Rate Limit Violations..."
python3 scripts/audit/review-rate-limits.py

# Generate report
echo ""
echo "Generating daily audit report..."
python3 scripts/audit/generate-daily-report.py > .git/audit/daily-reports/$(date +%Y-%m-%d).md

echo "✅ Daily audit complete"
echo "Report: .git/audit/daily-reports/$(date +%Y-%m-%d).md"
```

### 12.3 Weekly Security Report (Librarian → User)

**Every Monday, Librarian emails User:**

```markdown
# Weekly Security Report
**Week of:** 2025-11-10 to 2025-11-16

## Executive Summary

✅ **Overall Status:** HEALTHY
⚠️ **Minor Issues:** 2
❌ **Critical Issues:** 0

---

## Key Metrics

| **Metric** | **This Week** | **Last Week** | **Trend** |
|------------|---------------|---------------|-----------|
| Total Commits | 47 | 42 | ↑ |
| Peer Reviews | 45 | 40 | ↑ |
| Tertiary Reviews | 5 (10.6%) | 4 (9.5%) | → |
| Tertiary Blocks | 0 | 1 | ↓ |
| Quality Gates Passed | 3 features | 2 features | ↑ |
| Orchestrator Co-Sign Rate | 98% | 97% | ↑ |
| Message Integrity | 100% | 100% | → |
| Hook Bypasses | 0 | 0 | → |
| Rate Limit Violations | 2 | 1 | ↑ |

---

## Issues Detected

### ⚠️ Minor Issue #1: Dev-A Rate Limit
- **What:** Dev-A exceeded SignOffRequest limit (22/20 per hour)
- **When:** 2025-11-15 14:30 UTC
- **Cause:** Rapid iteration on auth feature (8 small commits in 1 hour)
- **Resolution:** Rate limit temporarily raised to 25/hour for Dev-A
- **Follow-up:** Coaching on batching commits

### ⚠️ Minor Issue #2: Cumulative Change Flag
- **What:** QA-B flagged for cumulative changes (580 LOC in 24h)
- **When:** 2025-11-14
- **Cause:** Test suite expansion (legitimate)
- **Resolution:** Retroactive review by QA-A - approved
- **Follow-up:** None needed

---

## Positive Highlights

✅ Zero hook bypasses (6 weeks streak)
✅ 100% message integrity maintained
✅ All user decisions properly 2FA-confirmed
✅ No collusion patterns detected

---

## Recommendations

1. **None this week** - System operating within normal parameters

---

**Next Report:** 2025-11-23
```

### 12.4 Real-Time Alerts

**Critical events trigger immediate alerts:**

```python
ALERT_CHANNELS = {
    "CRITICAL": ["email", "sms", "slack"],  # Wake up the user
    "HIGH": ["email", "slack"],              # User should see soon
    "MEDIUM": ["slack"],                     # FYI
    "LOW": ["log_only"]                      # Just record
}

def send_alert(severity, title, details):
    channels = ALERT_CHANNELS[severity]

    alert = {
        "severity": severity,
        "title": title,
        "details": details,
        "timestamp": datetime.now().isoformat(),
        "source": "Librarian"
    }

    for channel in channels:
        if channel == "email":
            send_email(USER_EMAIL, alert)
        elif channel == "sms":
            send_sms(USER_PHONE, alert)
        elif channel == "slack":
            send_slack(ALERT_CHANNEL, alert)

    # Always log
    log_alert(alert)
```

**Alert triggers:**

| **Event** | **Severity** | **Example** |
|-----------|--------------|-------------|
| System freeze | CRITICAL | Librarian veto triggered |
| User decision fraud | CRITICAL | User reports didn't approve |
| Hook bypass detected | HIGH | Push without client-side hook |
| Tertiary review block | MEDIUM | QA blocks commit in 10% check |
| Rate limit exceeded | LOW | Dev requests too many sign-offs |

---

## 13. Implementation Guide

### 13.1 Implementation Phases

**Phase 1: Foundation (Week 1)**
- Set up audit directory structure
- Implement message registry with hashing
- Create Librarian co-signature protocol
- Deploy basic rate limiting

**Phase 2: Verification (Week 2)**
- Implement write lock pre/post verification
- Set up GPG keys for all roles
- Deploy commit signing requirements
- Create server-side pre-receive hook

**Phase 3: Detection (Week 3)**
- Implement collusion detection
- Deploy cumulative change analysis
- Set up tertiary review system (10% randomized)
- Create Librarian daily check scripts

**Phase 4: User Auth (Week 4)**
- Implement 2FA for critical decisions
- Set up email/SMS confirmation system
- Deploy user decision registry
- Test fraud detection workflow

**Phase 5: Enforcement (Week 5)**
- Deploy Librarian veto authority
- Implement system freeze mechanism
- Set up real-time alerts
- Create weekly security reports

**Phase 6: Testing (Week 6)**
- Simulate rogue actor scenarios
- Test all detection mechanisms
- Verify veto authority works
- Stress-test rate limits
- Final security audit

### 13.2 Required Infrastructure

**GPG Key Management:**
```bash
# Generate keys for all 12 roles
for role in orchestrator librarian planner-a planner-b architect-a architect-b architect-c dev-a dev-b qa-a qa-b docs; do
    gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: ${role^}
Name-Email: $role@multiinstance.local
Expire-Date: 0
%no-protection
EOF
done

# Export public keys for verification
gpg --armor --export > .git/gpg-keys/all-public-keys.asc
```

**Email/SMS Service:**
```python
# Configure notification service
NOTIFICATION_CONFIG = {
    "email": {
        "provider": "sendgrid",  # or AWS SES, etc.
        "api_key": os.getenv("SENDGRID_API_KEY"),
        "from": "multiinstance@example.com",
        "to": os.getenv("USER_EMAIL")
    },
    "sms": {
        "provider": "twilio",
        "api_key": os.getenv("TWILIO_API_KEY"),
        "from": os.getenv("TWILIO_PHONE"),
        "to": os.getenv("USER_PHONE")
    }
}
```

**Server-Side Hook Deployment:**
```bash
# On git server (GitHub/GitLab)
# Deploy pre-receive hook
scp scripts/hooks/server-pre-receive.sh git-server:/repos/project.git/hooks/pre-receive
ssh git-server chmod +x /repos/project.git/hooks/pre-receive
```

### 13.3 Testing Checklist

**Rogue Actor Simulations:**

- [ ] **Test 1:** Orchestrator tries to advance gate without Librarian co-sign → BLOCKED
- [ ] **Test 2:** Dev-A forges "Peer-Reviewed-By: QA-A" → GPG verification FAILS
- [ ] **Test 3:** Dev-B commits unauthorized files → Post-commit hook ROLLBACK
- [ ] **Test 4:** Attempt `git push --no-verify` → Server-side hook BLOCKS
- [ ] **Test 5:** Delete approval message → Message integrity check DETECTS
- [ ] **Test 6:** Dev-A + Dev-B collude (mutual approval) → Tertiary review CATCHES
- [ ] **Test 7:** Orchestrator claims "User approved" → 2FA confirmation FAILS
- [ ] **Test 8:** 15 fast-track commits in 24h → Cumulative detection FLAGS
- [ ] **Test 9:** Spam 25 SignOffRequests → Rate limit BLOCKS
- [ ] **Test 10:** 3 gate bypasses → Librarian FREEZES system

**All tests must PASS before production deployment**

### 13.4 Success Criteria

**System is secure when:**

✅ No single role can compromise system (tested)
✅ Collusion between 2 roles is detected (tested)
✅ All critical actions have audit trail (verified)
✅ User authenticity is cryptographically verified (tested)
✅ System can self-correct violations (tested)
✅ Librarian veto works independently (tested)
✅ Rate limits prevent DoS (tested)
✅ Hook bypasses are impossible (tested)
✅ Message tampering is detected (tested)
✅ Salami slicing is flagged (tested)

---

## 14. Conclusion

This addendum establishes **defense-in-depth security** for the multi-instance system:

**Layer 1 (Prevention):**
- Orchestrator requires Librarian co-signature
- GPG-signed commits (forgery impossible)
- Rate limits (spam prevented)

**Layer 2 (Detection):**
- Tertiary reviews catch collusion
- Cumulative analysis detects salami slicing
- Message integrity checks detect tampering
- Write lock verification catches unauthorized changes

**Layer 3 (Response):**
- Librarian veto freezes system
- Real-time alerts to user
- Automatic rollback of bad commits

**Layer 4 (Recovery):**
- Comprehensive audit trail
- User can investigate and remediate
- System can resume after fixes

**No single actor can go rogue. The system is self-healing and accountable.**

---

**Document Status:** Ready for Implementation
**Implementation Priority:** CRITICAL - Must be completed before production use
**Estimated Implementation Time:** 6 weeks
**Dependencies:** Addendum 001 (4-Eyes Principle) must be implemented first
**User Approval Required:** YES

---

**Addendum Prepared By:** System Security Analysis
**Date:** 2025-11-16
**Requires Sign-Off From:** User (critical security changes)
**Next Step:** User approval + Implementation Phase 1
