# 🔐 Security Implementation Reference

**Purpose:** Comprehensive security implementation details referenced by all role documents

**Version:** 1.0
**Date:** 2025-11-16

---

## 📋 Table of Contents

1. [Message Passing System](#1-message-passing-system)
2. [Write Lock Coordination](#2-write-lock-coordination)
3. [GPG Commit Signing](#3-gpg-commit-signing)
4. [Tertiary Reviews](#4-tertiary-reviews)
5. [Collusion Detection](#5-collusion-detection)
6. [2FA User Confirmation](#6-2fa-user-confirmation)
7. [Cumulative Change Detection](#7-cumulative-change-detection)
8. [Rate Limiting](#8-rate-limiting)
9. [Message Integrity Verification](#9-message-integrity-verification)
10. [Audit Trail Logging](#10-audit-trail-logging)

---

## 1. Message Passing System

### Overview
All 12 instances communicate via **tmux-based file messages** with SHA-256 integrity verification.

### Message Format (YAML frontmatter + Markdown)

```markdown
---
message_id: MSG-12345
from: Orchestrator
to: Dev-A
type: TaskAssignment
timestamp: 2025-11-16T21:00:00Z
hash: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
priority: normal
---

# Task Assignment: Implement Order Idempotency

## Details
[Message content here]

## Deadline
2025-11-18

## References
- Specification: docs/specs/order-idempotency.md
- Architecture Decision: docs/ADRs/ADR-001-postgresql.md
```

### Message Types by Category

**Task Management:**
- `TaskAssignment` - Orchestrator → Planner/Dev/QA/Docs
- `SpecificationComplete` - Planner → Orchestrator
- `ImplementationComplete` - Dev → Orchestrator
- `QAComplete` - QA → Orchestrator
- `DocumentationComplete` - Docs → Orchestrator

**Quality Gates:**
- `GateAdvancementRequest` - Dev/QA → Orchestrator
- `GateAdvancementApproved` - Orchestrator → Dev/QA
- `GateAdvancementDenied` - Orchestrator → Dev/QA

**Peer Review:**
- `PeerReviewRequest` - Dev/QA/Planner → Peer
- `PeerReviewApproval` - Peer → Requester
- `PeerReviewRejection` - Peer → Requester
- `TertiaryReviewRequest` - Orchestrator → Third Reviewer

**Write Locks:**
- `WriteRequest` - Dev/QA/Docs → Orchestrator
- `WriteLockGrant` - Orchestrator → Requester
- `WriteLockQueued` - Orchestrator → Requester
- `WriteComplete` - Dev/QA/Docs → Orchestrator

**Architectural:**
- `TechnicalFeasibilityReview` - Orchestrator → Architect
- `ArchitecturalReview` - Orchestrator → Architecture Council
- `ArchitecturalDecision` - Architecture Council → All
- `FeasibilityApproved` - Architect → Planner
- `FeasibilityRejection` - Architect → Planner

**Security/Oversight:**
- `CoSignatureRequest` - Orchestrator → Librarian
- `CoSignatureApproved` - Librarian → Orchestrator
- `CoSignatureDenied` - Librarian → Orchestrator
- `SYSTEM_FREEZE` - Librarian → ALL
- `SYSTEM_UNFROZEN` - Librarian → ALL
- `SecurityAuditReport` - Librarian → User
- `CollisionAlert` - Orchestrator/Librarian → ALL
- `RateLimitExceeded` - Orchestrator → Violator
- `LockTimeoutViolation` - Orchestrator → Librarian

**User Escalation:**
- `CriticalDecisionRequest` - Orchestrator → User
- `DecisionResponse` - User → Orchestrator
- `EmergencyNotification` - Orchestrator → User
- `UNFREEZE_APPROVED` - User → Librarian

### Technical Implementation

**Sending Messages (Bash):**
```bash
# scripts/messaging/send_message.sh
#!/bin/bash

send_message() {
    local from_role=$1
    local to_role=$2
    local message_type=$3
    local message_file=$4

    # Generate message ID
    message_id="MSG-$(date +%s)-$(shuf -i 1000-9999 -n 1)"

    # Calculate content hash
    content=$(cat "$message_file")
    hash=$(echo -n "$content" | sha256sum | awk '{print $1}')

    # Create message with frontmatter
    cat > ".git/messages/${message_id}.md" <<EOF
---
message_id: ${message_id}
from: ${from_role}
to: ${to_role}
type: ${message_type}
timestamp: $(date -Iseconds)
hash: ${hash}
---

${content}
EOF

    # Register in message registry
    python3 scripts/security/message_registry.py register \
        --message-id "${message_id}" \
        --message-path ".git/messages/${message_id}.md"

    # Notify recipient via tmux
    tmux send-keys -t "claude-multi:${to_role}" \
        "# New message: ${message_type} from ${from_role}" C-m
    tmux send-keys -t "claude-multi:${to_role}" \
        "cat .git/messages/${message_id}.md" C-m
}
```

**Receiving Messages (Role checks):**
```bash
# Each role periodically checks for messages
check_messages() {
    local role=$1

    # Find messages addressed to this role
    for msg in .git/messages/*.md; do
        [ -f "$msg" ] || continue

        # Extract 'to' field from frontmatter
        to=$(grep "^to:" "$msg" | awk '{print $2}')

        if [ "$to" == "$role" ]; then
            # Verify message integrity
            if python3 scripts/security/message_registry.py verify \
                --message-path "$msg"; then
                # Process message
                process_message "$msg"
            else
                # Message tampered with!
                alert_librarian "MESSAGE_TAMPERING" "$msg"
            fi
        fi
    done
}
```

---

## 2. Write Lock Coordination

### Purpose
Prevents concurrent Git commits that would cause conflicts.

### Lock State File
```json
{
  "current_lock": {
    "holder": "Dev-A",
    "files": ["src/idempotency.py", "tests/test_idempotency.py"],
    "granted_at": "2025-11-16T21:00:00Z",
    "expires_at": "2025-11-16T21:05:00Z",
    "purpose": "implement idempotency feature"
  },
  "queue": [
    {
      "requester": "QA-A",
      "files": ["tests/integration/test_orders.py"],
      "requested_at": "2025-11-16T21:02:00Z",
      "estimated_time": 120,
      "priority": "normal"
    }
  ],
  "history": [
    {
      "holder": "Docs",
      "files": ["docs/api/orders.md"],
      "granted_at": "2025-11-16T20:45:00Z",
      "released_at": "2025-11-16T20:48:00Z",
      "duration": 180
    }
  ]
}
```

### Implementation (Python)

**File:** `scripts/security/write_lock.py`

```python
import json
import fcntl
from datetime import datetime, timedelta
from pathlib import Path

LOCK_STATE_FILE = ".git/audit/write-lock-intents.json"
DEFAULT_TIMEOUT = 300  # 5 minutes

def request_write_lock(requester, files, estimated_time=None):
    """Request write lock for files"""
    with file_lock(LOCK_STATE_FILE):
        state = load_lock_state()

        # Check if lock available
        if state["current_lock"] is None:
            # Grant immediately
            grant_lock(state, requester, files, estimated_time)
            return {"status": "GRANTED", "timeout": estimated_time or DEFAULT_TIMEOUT}
        else:
            # Check for file conflicts
            if has_file_conflict(files, state["current_lock"]["files"]):
                # Queue the request
                queue_request(state, requester, files, estimated_time)
                position = len(state["queue"])
                wait_time = estimate_wait_time(state)
                return {"status": "QUEUED", "position": position, "wait_time": wait_time}
            else:
                # No conflict - different files
                grant_lock(state, requester, files, estimated_time)
                return {"status": "GRANTED", "timeout": estimated_time or DEFAULT_TIMEOUT}

def release_write_lock(requester):
    """Release write lock"""
    with file_lock(LOCK_STATE_FILE):
        state = load_lock_state()

        if state["current_lock"] is None:
            raise LockError(f"{requester} tried to release lock but none held")

        if state["current_lock"]["holder"] != requester:
            raise LockError(f"{requester} tried to release lock held by {state['current_lock']['holder']}")

        # Log to history
        state["history"].append({
            **state["current_lock"],
            "released_at": datetime.now().isoformat(),
            "duration": (datetime.now() - datetime.fromisoformat(state["current_lock"]["granted_at"])).seconds
        })

        # Release current lock
        state["current_lock"] = None

        # Process queue
        if state["queue"]:
            next_request = state["queue"].pop(0)
            grant_lock(state, next_request["requester"], next_request["files"], next_request["estimated_time"])
            notify_lock_grant(next_request["requester"])

        save_lock_state(state)

def check_lock_timeout():
    """Background task to enforce lock timeouts"""
    with file_lock(LOCK_STATE_FILE):
        state = load_lock_state()

        if state["current_lock"]:
            expires = datetime.fromisoformat(state["current_lock"]["expires_at"])
            if datetime.now() > expires:
                # Timeout - force release
                holder = state["current_lock"]["holder"]
                duration = (datetime.now() - datetime.fromisoformat(state["current_lock"]["granted_at"])).seconds

                log_violation(f"Lock timeout: {holder} held lock for {duration}s (>{DEFAULT_TIMEOUT}s)")
                alert_librarian("LOCK_TIMEOUT", holder, duration)

                # Force release
                state["current_lock"] = None
                save_lock_state(state)
```

### Git Hook Verification

**Pre-commit hook:**
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if role holds write lock
ROLE=$(git config user.name)
LOCK_HOLDER=$(python3 scripts/security/write_lock.py get-holder)

if [ "$LOCK_HOLDER" != "$ROLE" ]; then
    echo "❌ Write lock not held by $ROLE"
    echo "Current lock holder: $LOCK_HOLDER"
    echo "Request write lock before committing"
    exit 1
fi

# Verify committed files match lock request
LOCKED_FILES=$(python3 scripts/security/write_lock.py get-files)
STAGED_FILES=$(git diff --cached --name-only)

for file in $STAGED_FILES; do
    if ! echo "$LOCKED_FILES" | grep -q "$file"; then
        echo "❌ Committing file not in lock request: $file"
        echo "Locked files: $LOCKED_FILES"
        exit 1
    fi
done
```

---

## 3. GPG Commit Signing

### Purpose
Cryptographically prove who made each commit (prevent impersonation).

### GPG Key Generation (Per Role)

**File:** `scripts/security/generate_gpg_keys.sh`

```bash
#!/bin/bash

ROLES=("Orchestrator" "Librarian" "Planner-A" "Planner-B"
       "Architect-A" "Architect-B" "Architect-C"
       "Dev-A" "Dev-B" "QA-A" "QA-B" "Docs")

for role in "${ROLES[@]}"; do
    echo "Generating GPG key for $role..."

    # Create key configuration
    cat > /tmp/gpg-key-${role}.conf <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: ${role}
Name-Email: ${role}@claude-workflow.local
Expire-Date: 0
%commit
EOF

    # Generate key
    gpg --batch --generate-key /tmp/gpg-key-${role}.conf

    # Export public key
    KEY_ID=$(gpg --list-keys "${role}@claude-workflow.local" | grep -A 1 "pub" | tail -1 | awk '{print $1}')
    gpg --armor --export "$KEY_ID" > ".git/gpg-keys/${role}.pub"

    echo "✓ Key generated for $role: $KEY_ID"
done
```

### Git Configuration (Per Role)

```bash
# Configure git to use role's GPG key
ROLE="Dev-A"
KEY_ID=$(gpg --list-keys "${ROLE}@claude-workflow.local" | grep -A 1 "pub" | tail -1 | awk '{print $1}')

git config user.name "$ROLE"
git config user.email "${ROLE}@claude-workflow.local"
git config user.signingkey "$KEY_ID"
git config commit.gpgsign true  # Auto-sign all commits
```

### Commit Signing (Required)

```bash
# All commits must be GPG-signed
git commit -S -m "feat: implement idempotency

Peer-Reviewed-By: Dev-B
Approved-At: 2025-11-16T21:00:00Z

Implements order idempotency with 1-hour TTL.
Uses PostgreSQL for storage per ADR-001."
```

### Signature Verification (Git Hook)

**Pre-receive hook (server-side enforcement):**
```bash
#!/bin/bash
# .git/hooks/pre-receive

while read oldrev newrev refname; do
    commits=$(git rev-list $oldrev..$newrev)

    for commit in $commits; do
        # Verify GPG signature exists
        if ! git verify-commit $commit 2>/dev/null; then
            echo "❌ Commit $commit is NOT GPG-signed"
            echo "All commits MUST be signed with GPG key"
            echo "Configure: git config commit.gpgsign true"
            exit 1
        fi

        # Verify signature is from valid role
        signer_email=$(git log -1 --format='%GS' $commit | grep -oP '(?<=<).*(?=>)')
        signer_role=$(echo "$signer_email" | cut -d'@' -f1)

        VALID_ROLES=("Orchestrator" "Librarian" "Planner-A" "Planner-B"
                     "Architect-A" "Architect-B" "Architect-C"
                     "Dev-A" "Dev-B" "QA-A" "QA-B" "Docs")

        if [[ ! " ${VALID_ROLES[@]} " =~ " ${signer_role} " ]]; then
            echo "❌ Commit signed with invalid role: $signer_role"
            echo "Valid roles: ${VALID_ROLES[*]}"
            exit 1
        fi

        echo "✓ Commit $commit signed by $signer_role - verified"
    done
done
```

---

## 4. Tertiary Reviews

### Purpose
Prevent collusion between peer reviewers through random independent third-party review.

### Selection Algorithm

**10% random selection** after peer review approval:

```python
import random

def maybe_assign_tertiary_review(primary_author, peer_reviewer, feature):
    """After peer review approved, randomly assign tertiary review"""

    # Random 10% selection
    if random.random() < 0.10:
        # Select independent reviewer
        tertiary = select_independent_reviewer(primary_author, peer_reviewer)

        # Log assignment
        log_tertiary_review({
            "feature": feature,
            "primary_author": primary_author,
            "peer_reviewer": peer_reviewer,
            "tertiary_reviewer": tertiary,
            "selected_at": datetime.now().isoformat(),
            "reason": "Random 10% verification"
        })

        # Send tertiary review request
        send_message(tertiary, "TertiaryReviewRequest", {
            "feature": feature,
            "primary": primary_author,
            "peer": peer_reviewer,
            "purpose": "Independent verification - detect rubber-stamping",
            "focus": [
                "Verify peer review was thorough",
                "Check for missed issues",
                "Confirm code quality standards met"
            ]
        })

        return "TERTIARY_REVIEW_REQUIRED"
    else:
        return "PEER_REVIEW_SUFFICIENT"

def select_independent_reviewer(author, peer):
    """Select reviewer independent from both author and peer"""
    all_reviewers = [
        "Dev-A", "Dev-B",
        "QA-A", "QA-B",
        "Architect-A", "Architect-B", "Architect-C"
    ]

    # Exclude author and peer
    independent = [r for r in all_reviewers if r not in [author, peer]]

    # Random selection
    return random.choice(independent)
```

### Tertiary Review Log

**File:** `.git/audit/tertiary-reviews.json`

```json
[
  {
    "feature": "order_idempotency",
    "primary_author": "Dev-A",
    "peer_reviewer": "Dev-B",
    "tertiary_reviewer": "QA-A",
    "selected_at": "2025-11-16T21:00:00Z",
    "completed_at": "2025-11-16T21:15:00Z",
    "outcome": "approved",
    "findings": "Peer review was thorough. No issues found. Code quality excellent.",
    "issues_found": []
  },
  {
    "feature": "payment_retry",
    "primary_author": "Dev-B",
    "peer_reviewer": "Dev-A",
    "tertiary_reviewer": "Architect-B",
    "selected_at": "2025-11-17T10:00:00Z",
    "completed_at": "2025-11-17T10:30:00Z",
    "outcome": "rejected",
    "findings": "Peer review missed error handling issues. Requires fixes before approval.",
    "issues_found": [
      "Missing retry timeout configuration",
      "No exponential backoff implemented",
      "Error logging insufficient"
    ]
  }
]
```

---

## 5. Collusion Detection

### Purpose
Detect when two roles consistently approve each other without scrutiny (rubber-stamping).

### Pattern Tracking

**File:** `.git/audit/peer-review-patterns.json`

```json
{
  "Dev-A->Dev-B": {
    "total_reviews": 25,
    "approvals": 24,
    "rejections": 1,
    "approval_rate": 0.96,
    "avg_review_time_seconds": 120,
    "avg_feedback_length": 45,
    "last_rejection": "2025-11-10T15:30:00Z"
  },
  "Dev-B->Dev-A": {
    "total_reviews": 23,
    "approvals": 22,
    "rejections": 1,
    "approval_rate": 0.957,
    "avg_review_time_seconds": 90,
    "avg_feedback_length": 38,
    "last_rejection": "2025-11-12T09:15:00Z"
  }
}
```

### Detection Algorithm

```python
def detect_collusion(reviewer, reviewee):
    """Detect rubber-stamping patterns"""
    patterns = load_review_patterns()
    pair = f"{reviewer}->{reviewee}"

    if pair not in patterns or patterns[pair]["total_reviews"] < 10:
        # Not enough data
        return None

    p = patterns[pair]

    # Suspicious indicators
    alerts = []

    # 1. High approval rate (>95% over 10+ reviews)
    if p["approval_rate"] > 0.95 and p["total_reviews"] > 10:
        alerts.append({
            "type": "HIGH_APPROVAL_RATE",
            "value": p["approval_rate"],
            "threshold": 0.95,
            "severity": "HIGH"
        })

    # 2. Fast review times (avg <2 minutes for >100 LOC)
    if p["avg_review_time_seconds"] < 120:
        alerts.append({
            "type": "FAST_REVIEW_TIME",
            "value": p["avg_review_time_seconds"],
            "threshold": 120,
            "severity": "MEDIUM"
        })

    # 3. Minimal feedback (avg <50 characters)
    if p["avg_feedback_length"] < 50:
        alerts.append({
            "type": "MINIMAL_FEEDBACK",
            "value": p["avg_feedback_length"],
            "threshold": 50,
            "severity": "MEDIUM"
        })

    # 4. Mutual high approval (both directions >95%)
    reverse_pair = f"{reviewee}->{reviewer}"
    if reverse_pair in patterns:
        if p["approval_rate"] > 0.95 and patterns[reverse_pair]["approval_rate"] > 0.95:
            alerts.append({
                "type": "MUTUAL_RUBBER_STAMPING",
                "forward_rate": p["approval_rate"],
                "reverse_rate": patterns[reverse_pair]["approval_rate"],
                "severity": "CRITICAL"
            })

    if alerts:
        alert_librarian("COLLUSION_DETECTED", {
            "pair": pair,
            "alerts": alerts,
            "recommendation": "Increase tertiary review rate or assign different peer reviewers"
        })

        return alerts

    return None
```

---

## 6. 2FA User Confirmation

### Purpose
Ensure critical decisions are actually approved by real user (not impersonation).

### When Required

- Architecture changes (microservices, new dependencies)
- Scope changes >20%
- Quality exceptions (skip TDD, lower coverage)
- Emergency bypasses
- System unfreeze (after Librarian veto)

### Implementation

**File:** `scripts/security/user_2fa.py`

```python
import smtplib
import random
import string
from twilio.rest import Client

def request_2fa_confirmation(decision_type, details):
    """Request user confirmation with 2FA code"""

    # Generate 6-digit code
    code = ''.join(random.choices(string.digits, k=6))
    expiry = datetime.now() + timedelta(minutes=5)

    # Store code
    store_2fa_code(decision_type, code, expiry)

    # Send via email
    send_email_code(code, decision_type, details)

    # Send via SMS (backup)
    send_sms_code(code)

    # Show in tmux pane
    show_tmux_prompt(decision_type, details)

    # Wait for user input
    user_code = wait_for_user_input(timeout=300)  # 5 minute timeout

    if verify_2fa_code(decision_type, user_code):
        log_2fa_success(decision_type)
        return True
    else:
        log_2fa_failure(decision_type, user_code)
        return False

def show_tmux_prompt(decision_type, details):
    """Display decision request in user's tmux pane"""
    message = f"""
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🔐 2FA CONFIRMATION REQUIRED
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Decision Type: {decision_type}

    Details:
    {details}

    A 6-digit code has been sent to:
    - Email: user@example.com
    - SMS: ***-***-1234

    Enter code to approve (expires in 5 minutes):
    >
    """

    tmux.send_keys("claude-multi:user", message)
```

### 2FA Log

**File:** `.git/audit/2fa-confirmations.log`

```
[2025-11-16T21:00:00Z] | ARCHITECTURE_CHANGE | Redis dependency | CODE_SENT | email+sms
[2025-11-16T21:02:30Z] | ARCHITECTURE_CHANGE | Redis dependency | CODE_VERIFIED | approved
[2025-11-17T09:15:00Z] | QUALITY_EXCEPTION | Skip TDD for hotfix | CODE_SENT | email+sms
[2025-11-17T09:20:00Z] | QUALITY_EXCEPTION | Skip TDD for hotfix | CODE_EXPIRED | timeout
[2025-11-17T09:21:00Z] | QUALITY_EXCEPTION | Skip TDD for hotfix | CODE_SENT | email+sms
[2025-11-17T09:22:15Z] | QUALITY_EXCEPTION | Skip TDD for hotfix | CODE_VERIFIED | approved
```

---

## 7. Cumulative Change Detection

### Purpose
Prevent "salami-slicing" attacks where many small commits aggregate to significant unauthorized change.

### Tracking

**File:** `.git/audit/cumulative-changes.json`

```json
{
  "Dev-A": [
    {
      "timestamp": "2025-11-16T20:00:00Z",
      "commit": "abc123",
      "files": 2,
      "loc_added": 45,
      "loc_removed": 12,
      "net_loc": 33
    },
    {
      "timestamp": "2025-11-16T20:30:00Z",
      "commit": "def456",
      "files": 1,
      "loc_added": 38,
      "loc_removed": 5,
      "net_loc": 33
    }
  ]
}
```

### Detection Algorithm

```python
def check_cumulative_changes(role):
    """Check if role has exceeded cumulative change threshold"""
    changes = load_cumulative_changes()

    # Get changes in last 24 hours
    cutoff = datetime.now() - timedelta(hours=24)
    recent = [
        c for c in changes.get(role, [])
        if datetime.fromisoformat(c["timestamp"]) > cutoff
    ]

    # Calculate totals
    total_commits = len(recent)
    total_files = sum(c["files"] for c in recent)
    total_loc = sum(c["net_loc"] for c in recent)

    # Check thresholds
    THRESHOLDS = {
        "commits_24h": 20,
        "files_24h": 50,
        "loc_24h": 500
    }

    violations = []

    if total_commits > THRESHOLDS["commits_24h"]:
        violations.append(f"{total_commits} commits (>{THRESHOLDS['commits_24h']})")

    if total_files > THRESHOLDS["files_24h"]:
        violations.append(f"{total_files} files (>{THRESHOLDS['files_24h']})")

    if total_loc > THRESHOLDS["loc_24h"]:
        violations.append(f"{total_loc} LOC (>{THRESHOLDS['loc_24h']})")

    if violations:
        alert_librarian("CUMULATIVE_CHANGE_EXCEEDED", {
            "role": role,
            "time_window": "24 hours",
            "violations": violations,
            "commits": total_commits,
            "files": total_files,
            "loc": total_loc,
            "reason": "Potential salami-slicing attack - many small commits totaling significant change"
        })

        return True

    return False
```

---

## 8. Rate Limiting

### Purpose
Prevent resource exhaustion and spam attacks.

### Rate Limits

```python
RATE_LIMITS = {
    # Commits
    "commits_per_hour": 20,
    "commits_per_day": 100,

    # Messages
    "messages_per_minute": 10,
    "messages_per_hour": 300,

    # Write locks
    "write_lock_requests_per_hour": 30,

    # Gate advancements
    "gate_advancements_per_hour": 10,

    # Peer reviews
    "peer_reviews_per_hour": 15
}
```

### Enforcement

```python
def check_rate_limit(role, action):
    """Check if action would exceed rate limit"""
    limits = load_rate_limits()

    # Determine time window
    if "per_minute" in action:
        window_seconds = 60
        threshold_key = action
    elif "per_hour" in action:
        window_seconds = 3600
        threshold_key = action
    elif "per_day" in action:
        window_seconds = 86400
        threshold_key = action
    else:
        return True  # Unknown action type

    # Count actions in window
    cutoff = datetime.now() - timedelta(seconds=window_seconds)

    role_limits = limits.get(role, [])
    recent_actions = [
        a for a in role_limits
        if a["action"] == action and datetime.fromisoformat(a["timestamp"]) > cutoff
    ]

    count = len(recent_actions)
    threshold = RATE_LIMITS.get(threshold_key, float('inf'))

    if count >= threshold:
        # Rate limit exceeded
        retry_after = calculate_retry_time(recent_actions[0]["timestamp"], window_seconds)

        send_message(role, "RateLimitExceeded", {
            "action": action,
            "count": count,
            "threshold": threshold,
            "window": f"{window_seconds}s",
            "retry_after": retry_after
        })

        # Alert if excessive (>2x threshold)
        if count > threshold * 2:
            alert_librarian("EXCESSIVE_RATE_VIOLATION", {
                "role": role,
                "action": action,
                "count": count,
                "threshold": threshold
            })

        return False

    # Record action
    record_action(role, action)

    return True
```

---

## 9. Message Integrity Verification

### Purpose
Cryptographically verify messages haven't been tampered with.

### Implementation

**Message Registration:**
```python
def register_message(message_id, message_path):
    """Register message with SHA-256 hash"""
    with open(message_path, 'r') as f:
        content = f.read()

    # Calculate hash of entire message
    hash_value = hashlib.sha256(content.encode()).hexdigest()

    # Load registry
    registry = load_registry()

    # Add entry
    registry.append({
        "message_id": message_id,
        "hash": hash_value,
        "registered_at": datetime.now().isoformat()
    })

    save_registry(registry)

    return hash_value
```

**Message Verification:**
```python
def verify_message(message_id, message_path):
    """Verify message integrity"""
    with open(message_path, 'r') as f:
        content = f.read()

    # Calculate current hash
    current_hash = hashlib.sha256(content.encode()).hexdigest()

    # Get registered hash
    registry = load_registry()
    entry = next((e for e in registry if e["message_id"] == message_id), None)

    if entry is None:
        raise MessageError(f"Message {message_id} not found in registry")

    registered_hash = entry["hash"]

    # Compare
    if current_hash != registered_hash:
        # TAMPERING DETECTED!
        alert_librarian("MESSAGE_TAMPERING", {
            "message_id": message_id,
            "registered_hash": registered_hash,
            "current_hash": current_hash,
            "message_path": message_path
        })

        raise MessageTamperingError(
            f"Message {message_id} has been tampered with! "
            f"Expected hash: {registered_hash}, Got: {current_hash}"
        )

    return True
```

---

## 10. Audit Trail Logging

### Purpose
Comprehensive logging of all security-relevant events for forensics and compliance.

### Audit Log Files

```bash
.git/audit/
├── orchestrator-decisions.log       # All Orchestrator decisions
├── message-log.log                  # All messages sent/received
├── security-events.log              # Security violations, alerts
├── write-lock-intents.json          # Write lock state and history
├── message-registry.json            # Message hash registry
├── peer-review-patterns.json        # Collusion detection data
├── tertiary-reviews.json            # Tertiary review assignments
├── cumulative-changes.json          # Salami-slicing detection
├── rate-limiting.json               # Rate limit tracking
├── 2fa-confirmations.log            # User 2FA verifications
├── 4eyes-compliance.log             # 4-eyes sign-offs
├── quality-gates.json               # Gate progression tracking
└── daily-reports/                   # Daily security summaries
    ├── 2025-11-16-security-report.md
    └── 2025-11-17-security-report.md
```

### Log Format Standards

**Structured logs (tab-separated):**
```
[TIMESTAMP] | [EVENT_TYPE] | [ROLE] | [DETAILS] | [SEVERITY]
```

**Example:**
```
[2025-11-16T21:00:00Z] | GATE_ADVANCEMENT | Dev-A | Gate 1->2: order_idempotency | INFO
[2025-11-16T21:05:00Z] | PEER_REVIEW | Dev-B->Dev-A | APPROVED: 120 LOC | INFO
[2025-11-16T21:10:00Z] | COLLUSION_ALERT | Dev-A<->Dev-B | 96% approval rate | WARNING
[2025-11-16T21:15:00Z] | SYSTEM_FREEZE | Librarian | 3 gate bypasses detected | CRITICAL
[2025-11-16T21:20:00Z] | 2FA_CONFIRMATION | User | Architecture change approved | INFO
```

### Log Retention

- **30 days:** Detailed logs (all events)
- **1 year:** Security events, violations, 2FA confirmations
- **Indefinite:** Daily summaries, ADRs, critical incidents

---

## Summary

All 10 security features are implemented across the 12-instance system:

1. ✅ **Message Passing** - tmux-based with SHA-256 integrity
2. ✅ **Write Locks** - File-based coordination with timeout enforcement
3. ✅ **GPG Signing** - All commits cryptographically signed
4. ✅ **Tertiary Reviews** - Random 10% for collusion detection
5. ✅ **Collusion Detection** - Pattern tracking and alerting
6. ✅ **2FA Confirmation** - User verification for critical decisions
7. ✅ **Cumulative Detection** - Salami-slicing prevention
8. ✅ **Rate Limiting** - Resource exhaustion prevention
9. ✅ **Message Integrity** - Tampering detection via hashes
10. ✅ **Audit Trail** - Comprehensive forensic logging

**All roles reference this document** for security implementation details.
