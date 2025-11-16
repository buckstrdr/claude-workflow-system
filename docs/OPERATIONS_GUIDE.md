# 🚀 Operations Guide: Multi-Instance Claude Code Workflow System

**Version:** 1.0
**Date:** 2025-11-16
**Status:** Production-Ready
**Audience:** DevOps, System Administrators, Developers

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Tmux Environment Setup](#2-tmux-environment-setup)
3. [Instance Startup and Initialization](#3-instance-startup-and-initialization)
4. [Instance Health Monitoring](#4-instance-health-monitoring)
5. [Emergency Procedures](#5-emergency-procedures)
6. [Troubleshooting](#6-troubleshooting)
7. [Maintenance and Operations](#7-maintenance-and-operations)

---

## 1. System Overview

### 1.1 Architecture

**12 Claude Instances** running in a single tmux session:
- 1 Orchestrator (master coordinator)
- 1 Librarian (independent oversight)
- 2 Planners (feature specification)
- 3 Architects (architectural decisions)
- 2 Developers (TDD implementation)
- 2 QA (quality assurance)
- 1 Docs (documentation)

### 1.2 Communication

**Tmux-based message passing:**
- Each instance runs in its own tmux pane
- Messages sent via file system (`.git/messages/`)
- Notifications via `tmux send-keys` to target pane
- SHA-256 message integrity verification

### 1.3 Coordination

**Write lock system:**
- File-based locking (`.git/locks/write-lock.json`)
- Prevents concurrent Git conflicts
- Queue management for lock requests

---

## 2. Tmux Environment Setup

### 2.1 Prerequisites

```bash
# Install tmux
sudo apt-get install tmux  # Ubuntu/Debian
brew install tmux          # macOS

# Verify installation
tmux -V  # Should be >= 3.0

# Install Claude Code CLI
# (Follow official Claude Code installation instructions)
```

### 2.2 Tmux Session Creation

**Create 4×3 grid layout (12 panes):**

```bash
#!/bin/bash
# scripts/setup-tmux-session.sh

SESSION="claude-multi"

# Create new session
tmux new-session -d -s $SESSION -n "workflow"

# Split into 4 columns
tmux split-window -h -t $SESSION:0.0
tmux split-window -h -t $SESSION:0.0
tmux split-window -h -t $SESSION:0.2

# Split each column into 3 rows
for pane in 0 1 2 3; do
    tmux split-window -v -t $SESSION:0.$pane
    tmux split-window -v -t $SESSION:0.$((pane * 3))
done

# Select even layout (balance pane sizes)
tmux select-layout -t $SESSION:0 tiled

# Attach to session
tmux attach-session -t $SESSION
```

### 2.3 Pane Assignment

**Assign roles to panes:**

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ 0           │ 1           │ 2           │ 3           │
│ Orchestrator│ Librarian   │ Planner-A   │ Planner-B   │
├─────────────┼─────────────┼─────────────┼─────────────┤
│ 4           │ 5           │ 6           │ 7           │
│ Architect-A │ Architect-B │ Architect-C │ Dev-A       │
├─────────────┼─────────────┼─────────────┼─────────────┤
│ 8           │ 9           │ 10          │ 11          │
│ Dev-B       │ QA-A        │ QA-B        │ Docs        │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

**Pane mapping:**
```bash
# Stored in .git/config or environment
ORCHESTRATOR_PANE=0
LIBRARIAN_PANE=1
PLANNER_A_PANE=2
PLANNER_B_PANE=3
ARCHITECT_A_PANE=4
ARCHITECT_B_PANE=5
ARCHITECT_C_PANE=6
DEV_A_PANE=7
DEV_B_PANE=8
QA_A_PANE=9
QA_B_PANE=10
DOCS_PANE=11
```

### 2.4 Tmux Navigation Commands

```bash
# Switch to specific pane
tmux select-pane -t $SESSION:0.0   # Orchestrator
tmux select-pane -t $SESSION:0.7   # Dev-A

# Send command to pane
tmux send-keys -t $SESSION:0.7 "echo 'Message received'" C-m

# List all panes
tmux list-panes -t $SESSION:0

# Kill session (shutdown all instances)
tmux kill-session -t $SESSION
```

---

## 3. Instance Startup and Initialization

### 3.1 Startup Sequence

**Instances MUST start in this order:**

1. **Orchestrator** (pane 0) - First instance, master coordinator
2. **Librarian** (pane 1) - Second instance, oversight
3. **All other instances** (panes 2-11) - Parallel startup

**Why this order:**
- Orchestrator initializes shared resources (`.git/messages/`, `.git/locks/`, `.git/audit/`)
- Librarian verifies Orchestrator's initialization
- Other instances register with Orchestrator on startup

### 3.2 Startup Script

```bash
#!/bin/bash
# scripts/start-instance.sh

ROLE=$1           # e.g., "Orchestrator", "Dev-A"
PANE_ID=$2        # e.g., 0, 7
SESSION="claude-multi"

# Set environment variables
export CLAUDE_ROLE=$ROLE
export CLAUDE_PANE=$PANE_ID
export CLAUDE_SESSION=$SESSION
export CLAUDE_WORKSPACE=$(pwd)

# Start Claude Code instance with role-specific prompt
tmux send-keys -t $SESSION:0.$PANE_ID "
export CLAUDE_ROLE=$ROLE
export CLAUDE_PANE=$PANE_ID
claude-code --role-file=docs/roles/${ROLE}_ROLE.md
" C-m

# Wait for initialization
sleep 2

# Send initialization command
tmux send-keys -t $SESSION:0.$PANE_ID "
# Instance $ROLE initialized in pane $PANE_ID
# Ready to receive messages
" C-m
```

### 3.3 Complete Startup Procedure

```bash
#!/bin/bash
# scripts/start-all-instances.sh

SESSION="claude-multi"

# 1. Create tmux session
./scripts/setup-tmux-session.sh

# 2. Start Orchestrator (FIRST)
./scripts/start-instance.sh "Orchestrator" 0
sleep 5  # Wait for Orchestrator to initialize shared resources

# 3. Start Librarian (SECOND)
./scripts/start-instance.sh "Librarian" 1
sleep 3  # Wait for Librarian to verify Orchestrator

# 4. Start all other instances (PARALLEL)
./scripts/start-instance.sh "Planner-A" 2 &
./scripts/start-instance.sh "Planner-B" 3 &
./scripts/start-instance.sh "Architect-A" 4 &
./scripts/start-instance.sh "Architect-B" 5 &
./scripts/start-instance.sh "Architect-C" 6 &
./scripts/start-instance.sh "Dev-A" 7 &
./scripts/start-instance.sh "Dev-B" 8 &
./scripts/start-instance.sh "QA-A" 9 &
./scripts/start-instance.sh "QA-B" 10 &
./scripts/start-instance.sh "Docs" 11 &

# Wait for all instances to start
wait

echo "✅ All 12 instances started successfully"
echo "Attach to session: tmux attach-session -t $SESSION"
```

### 3.4 Instance Discovery Protocol

**Each instance on startup:**

1. **Read environment variables:**
   ```bash
   ROLE=$CLAUDE_ROLE          # e.g., "Dev-A"
   PANE=$CLAUDE_PANE          # e.g., 7
   SESSION=$CLAUDE_SESSION    # "claude-multi"
   ```

2. **Register with Orchestrator:**
   ```python
   # Send registration message
   register_message = {
       "type": "INSTANCE_REGISTRATION",
       "from": ROLE,
       "pane": PANE,
       "timestamp": datetime.now().isoformat(),
       "status": "READY"
   }
   send_message("Orchestrator", register_message)
   ```

3. **Wait for Orchestrator acknowledgment:**
   ```python
   # Orchestrator responds with instance registry
   acknowledgment = wait_for_message("REGISTRATION_ACK", timeout=30)
   if not acknowledgment:
       raise InstanceRegistrationError("Orchestrator did not acknowledge")
   ```

4. **Load shared state:**
   ```python
   # Load message registry, lock state, audit logs
   load_message_registry()
   load_lock_state()
   load_audit_logs()
   ```

5. **Enter ready state:**
   ```python
   log("Instance $ROLE ready to receive messages")
   ```

### 3.5 Orchestrator Initialization (Special Case)

**Orchestrator creates shared resources on first startup:**

```python
def initialize_orchestrator():
    # Create directory structure
    os.makedirs(".git/messages", exist_ok=True)
    os.makedirs(".git/locks", exist_ok=True)
    os.makedirs(".git/audit", exist_ok=True)

    # Initialize message registry
    with open(".git/message-registry.json", "w") as f:
        json.dump({"messages": []}, f)

    # Initialize write lock state
    with open(".git/locks/write-lock.json", "w") as f:
        json.dump({
            "current_lock": None,
            "queue": []
        }, f)

    # Initialize instance registry
    with open(".git/instance-registry.json", "w") as f:
        json.dump({
            "instances": [],
            "last_heartbeat": {}
        }, f)

    # Log initialization
    log_audit("orchestrator-startup.log", "Orchestrator initialized")

    # Enter ready state
    broadcast_message("ALL", {
        "type": "ORCHESTRATOR_READY",
        "timestamp": datetime.now().isoformat()
    })
```

---

## 4. Instance Health Monitoring

### 4.1 Heartbeat Protocol

**All instances send heartbeat every 60 seconds:**

```python
import threading
import time

def heartbeat_loop():
    while True:
        send_heartbeat()
        time.sleep(60)  # 60 second interval

def send_heartbeat():
    heartbeat_message = {
        "type": "HEARTBEAT",
        "from": ROLE,
        "pane": PANE,
        "timestamp": datetime.now().isoformat(),
        "status": "ALIVE"
    }
    send_message("Orchestrator", heartbeat_message)

# Start heartbeat thread on instance startup
threading.Thread(target=heartbeat_loop, daemon=True).start()
```

### 4.2 Orchestrator Health Monitoring

**Orchestrator tracks last heartbeat from each instance:**

```python
def monitor_instance_health():
    while True:
        # Check for stale heartbeats (>2 minutes)
        now = datetime.now()
        stale_instances = []

        for instance, last_heartbeat in instance_registry["last_heartbeat"].items():
            age = (now - datetime.fromisoformat(last_heartbeat)).seconds

            if age > 120:  # 2 minutes = missed 2 heartbeats
                stale_instances.append(instance)

        if stale_instances:
            handle_stale_instances(stale_instances)

        time.sleep(30)  # Check every 30 seconds

def handle_stale_instances(stale_instances):
    for instance in stale_instances:
        log_audit("instance-health.log", f"Instance {instance} stale (no heartbeat)")

        # Alert Librarian
        alert_librarian("INSTANCE_HEALTH_WARNING", {
            "instance": instance,
            "last_heartbeat": instance_registry["last_heartbeat"][instance],
            "action": "Verify instance health"
        })

        # Check if instance crashed
        if not check_instance_alive(instance):
            handle_instance_crash(instance)
```

### 4.3 Instance Crash Detection

**Orchestrator detects crashed instances:**

```python
def check_instance_alive(instance):
    # Check tmux pane still exists
    pane_id = get_pane_id(instance)
    result = subprocess.run(
        ["tmux", "list-panes", "-t", f"{SESSION}:0.{pane_id}"],
        capture_output=True
    )
    return result.returncode == 0

def handle_instance_crash(instance):
    log_audit("instance-crashes.log", f"Instance {instance} CRASHED")

    # Alert Librarian + User
    alert_librarian("INSTANCE_CRASHED", {
        "instance": instance,
        "timestamp": datetime.now().isoformat(),
        "action": "SYSTEM_FREEZE recommended"
    })

    alert_user("CRITICAL: Instance Crash", {
        "instance": instance,
        "impact": get_crash_impact(instance),
        "options": ["Restart instance", "System freeze", "Manual intervention"]
    })

    # Reassign work if possible
    reassign_work(instance)
```

### 4.4 Automatic Instance Restart

**Orchestrator can auto-restart crashed instances:**

```python
def auto_restart_instance(instance):
    log_audit("instance-restarts.log", f"Auto-restarting {instance}")

    # Get pane ID
    pane_id = get_pane_id(instance)

    # Restart instance in same pane
    subprocess.run([
        "./scripts/start-instance.sh",
        instance,
        str(pane_id)
    ])

    # Wait for registration
    wait_for_registration(instance, timeout=60)

    # Restore state
    restore_instance_state(instance)

    log_audit("instance-restarts.log", f"{instance} restarted successfully")
```

### 4.5 Work Reassignment

**When instance crashes, reassign pending work:**

```python
def reassign_work(crashed_instance):
    # Get pending work for crashed instance
    pending_work = get_pending_work(crashed_instance)

    if not pending_work:
        return  # No work to reassign

    # Find available instance of same role type
    replacement = find_replacement_instance(crashed_instance)

    if replacement:
        # Reassign work to replacement
        for work in pending_work:
            send_message(replacement, {
                "type": "WORK_REASSIGNMENT",
                "original_assignee": crashed_instance,
                "work": work,
                "reason": "Instance crash"
            })

        log_audit("work-reassignment.log",
                  f"Reassigned {len(pending_work)} tasks from {crashed_instance} to {replacement}")
    else:
        # No replacement available - alert User
        alert_user("WORK_BLOCKED", {
            "crashed_instance": crashed_instance,
            "pending_work": pending_work,
            "action_required": "Manual reassignment or instance restart"
        })
```

### 4.6 Health Dashboard

**Orchestrator provides health status:**

```python
def get_health_dashboard():
    return {
        "timestamp": datetime.now().isoformat(),
        "instances": {
            instance: {
                "status": "ALIVE" if is_alive(instance) else "STALE/CRASHED",
                "last_heartbeat": get_last_heartbeat(instance),
                "pending_work": get_pending_work_count(instance),
                "current_task": get_current_task(instance)
            }
            for instance in ALL_INSTANCES
        },
        "system_status": get_system_status()  # RUNNING, FROZEN, etc.
    }
```

---

## 5. Emergency Procedures

### 5.1 Emergency Bypass Workflow

**When to use:** Production incident requires bypassing quality gates

**Authorization required:** User + Librarian approval

**Complete workflow:**

```
[Production Incident Detected]
         │
         ▼
    [Dev requests emergency bypass]
         │
Dev-A → Orchestrator: "EMERGENCY_BYPASS_REQUEST"
  Reason: "Production down - critical bug fix"
  Scope: "Skip peer review for hotfix commit abc123"
  Estimated impact: "1 commit, 5 LOC change"
         │
         ▼
Orchestrator → Librarian: "EMERGENCY_BYPASS_REVIEW"
  + Forward Dev-A request
         │
         ▼
Librarian reviews:
  - Is this genuinely an emergency? ✓
  - Is bypass scope minimal? ✓
  - Are there alternatives? ✗ (production down)
         │
         ▼
Librarian → Orchestrator: "BYPASS_APPROVED_PENDING_USER"
         │
         ▼
Orchestrator → User: "EMERGENCY_BYPASS_2FA_REQUEST"
  Show: Dev-A request + Librarian approval + context
  Request: 2FA code confirmation
         │
         ▼
User confirms via 2FA (email/SMS code)
         │
         ▼
Orchestrator → Dev-A: "BYPASS_GRANTED"
  Scope: Exactly as requested
  Validity: 1 hour
  Audit: Logged to .git/audit/emergency-bypasses.log
         │
         ▼
Dev-A commits hotfix (bypass active)
         │
         ▼
Orchestrator logs:
  - Bypass used: YES
  - Commit: abc123
  - Timestamp: 2025-11-16T23:00:00Z
  - Approved by: User + Librarian
         │
         ▼
Post-bypass remediation (required within 24h):
  - Retroactive peer review (Dev-B reviews hotfix)
  - Retroactive QA (QA-A tests hotfix)
  - Documentation update (Docs documents incident)
         │
         ▼
Orchestrator → User: "BYPASS_REMEDIATION_COMPLETE"
  All retroactive reviews passed
```

**Bypass justification requirements:**
- Production incident (service down, data loss, security breach)
- No alternative solution available
- Scope clearly defined and minimal
- Remediation plan in place

**Automatic bypass denial:**
- No justification provided
- Scope too broad (>100 LOC, >10 files)
- Not genuinely an emergency
- Recent bypass abuse detected

### 5.2 System Freeze Workflow

**Triggered by:** Librarian detects systemic violations

**Complete freeze/unfreeze protocol:**

```
[Librarian detects 3+ quality gate bypasses in 24h]
         │
         ▼
Librarian: AUTOMATIC_FREEZE_TRIGGERED
         │
         ▼
Librarian → ALL instances: "SYSTEM_FREEZE"
  Reason: "Systemic quality gate violations"
  Action: "CEASE ALL WORK immediately"
  Effect: "No commits, no merges, no gate advancements"
         │
         ▼
All instances enter FROZEN state:
  - In-progress work: PAUSE (save state, do not commit)
  - Pending messages: QUEUED (not processed)
  - Write locks: RELEASED (all locks freed)
  - New requests: REJECTED
         │
         ▼
Orchestrator enters FROZEN state:
  - All write lock requests: DENIED
  - All gate advancement requests: DENIED
  - All message routing: QUEUED
  - Status: SYSTEM_FROZEN
         │
         ▼
Librarian generates security audit report (30 min):
  - List all violations with evidence
  - Common factors analysis
  - Root cause investigation
  - Recommendations for remediation
         │
         ▼
Librarian → User: "SECURITY_AUDIT_REPORT"
  + Direct escalation (bypasses Orchestrator)
  + Full violation details
  + Remediation recommendations
         │
         ▼
User investigates:
  - Reviews audit report
  - Identifies root cause
  - Implements remediation
         │
         ▼
User → Librarian: "REMEDIATION_COMPLETE"
  Evidence: Changes made (e.g., hook fixes, env vars)
         │
         ▼
Librarian verifies remediation:
  - Check hooks reinstalled correctly
  - Verify environment variables set
  - Test write lock enforcement
  - Confirm violations cannot recur
         │
         ▼
    ┌───┴───┐
    │       │
 PASS     FAIL
    │       │
    ▼       ▼
UNFREEZE  REMAIN_FROZEN
```

**Unfreeze workflow:**
```
Librarian → ALL instances: "SYSTEM_UNFROZEN"
  Reason: "Remediation verified and complete"
  Action: "Work may resume"
         │
         ▼
All instances exit FROZEN state:
  - Resume in-progress work
  - Process queued messages
  - Accept new requests
         │
         ▼
Orchestrator exits FROZEN state:
  - Process queued write lock requests
  - Resume message routing
  - Status: SYSTEM_RUNNING
         │
         ▼
Log to audit:
  - Freeze duration
  - Remediation actions
  - Verification results
```

**What happens to in-progress work during freeze:**
- **Dev mid-implementation:** Save state, pause, do NOT commit
- **QA mid-testing:** Save test results, pause
- **Docs mid-writing:** Save draft, pause
- **Peer review in progress:** Pause, do not approve/reject
- **Write lock held:** RELEASE IMMEDIATELY

### 5.3 Instance Manual Shutdown

**Graceful shutdown procedure:**

```bash
# Shutdown specific instance
./scripts/shutdown-instance.sh "Dev-A" 7

# Shutdown all instances
./scripts/shutdown-all-instances.sh
```

**Shutdown script:**
```bash
#!/bin/bash
# scripts/shutdown-instance.sh

ROLE=$1
PANE_ID=$2
SESSION="claude-multi"

# Send shutdown command
tmux send-keys -t $SESSION:0.$PANE_ID "
# Shutting down $ROLE instance...
# Saving state...
exit
" C-m

# Wait for graceful exit
sleep 2

# Force kill if still running
tmux kill-pane -t $SESSION:0.$PANE_ID 2>/dev/null || true

echo "✅ Instance $ROLE (pane $PANE_ID) shutdown"
```

---

## 6. Troubleshooting

### 6.1 Common Issues

**Issue: Instance not receiving messages**
```bash
# Check tmux pane exists
tmux list-panes -t claude-multi:0

# Check message files
ls -la .git/messages/

# Check instance registration
cat .git/instance-registry.json | jq '.instances'

# Solution: Restart instance
./scripts/start-instance.sh "Dev-A" 7
```

**Issue: Write lock stuck**
```bash
# Check lock state
cat .git/locks/write-lock.json | jq '.'

# Force release lock (Orchestrator only)
python3 scripts/force-release-lock.py --requester "Orchestrator"

# Check lock audit trail
cat .git/audit/write-lock-intents.json
```

**Issue: Heartbeat failures**
```bash
# Check last heartbeat
cat .git/instance-registry.json | jq '.last_heartbeat'

# Manual heartbeat test
tmux send-keys -t claude-multi:0.7 "
send_heartbeat()
" C-m
```

### 6.2 Diagnostic Commands

```bash
# View all instance statuses
python3 scripts/health-check.py

# View audit logs
tail -f .git/audit/orchestrator-decisions.log

# Check message queue
ls -la .git/messages/ | wc -l

# View write lock queue
cat .git/locks/write-lock.json | jq '.queue'
```

---

## 7. Maintenance and Operations

### 7.1 Log Rotation

**Automated log rotation (daily):**

```bash
#!/bin/bash
# scripts/rotate-logs.sh

LOG_DIR=".git/audit"
ARCHIVE_DIR=".git/audit/archive"
RETENTION_DAYS=90

# Create archive directory
mkdir -p $ARCHIVE_DIR

# Rotate logs (keep last 7 days, archive older)
find $LOG_DIR -name "*.log" -mtime +7 -exec gzip {} \;
find $LOG_DIR -name "*.log.gz" -mtime +0 -exec mv {} $ARCHIVE_DIR/ \;

# Delete archives older than retention period
find $ARCHIVE_DIR -name "*.log.gz" -mtime +$RETENTION_DAYS -delete

echo "✅ Log rotation complete"
```

**Cron job:**
```cron
# Rotate logs daily at 2 AM
0 2 * * * /path/to/scripts/rotate-logs.sh
```

### 7.2 Backup and Recovery

**Daily backup of audit logs and state:**

```bash
#!/bin/bash
# scripts/backup-system-state.sh

BACKUP_DIR="backups/$(date +%Y-%m-%d)"
mkdir -p $BACKUP_DIR

# Backup audit logs
cp -r .git/audit $BACKUP_DIR/

# Backup registries
cp .git/message-registry.json $BACKUP_DIR/
cp .git/instance-registry.json $BACKUP_DIR/
cp .git/locks/write-lock.json $BACKUP_DIR/

# Create tarball
tar -czf $BACKUP_DIR.tar.gz $BACKUP_DIR
rm -rf $BACKUP_DIR

echo "✅ Backup saved to $BACKUP_DIR.tar.gz"
```

### 7.3 System Metrics

**Key metrics to monitor:**
- Instance uptime (heartbeat success rate)
- Message delivery latency
- Write lock wait times
- Quality gate advancement times
- Peer review turnaround times
- Security violation counts

**Metrics collection:**
```python
# scripts/collect-metrics.py

metrics = {
    "instance_uptime": calculate_uptime_per_instance(),
    "message_latency_avg": calculate_message_latency(),
    "write_lock_wait_avg": calculate_lock_wait_times(),
    "gate_advancement_avg": calculate_gate_times(),
    "peer_review_turnaround": calculate_review_times(),
    "security_violations": count_violations_last_24h()
}

# Export to monitoring system (Prometheus, Datadog, etc.)
export_metrics(metrics)
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│ QUICK REFERENCE: Multi-Instance Operations              │
├─────────────────────────────────────────────────────────┤
│ Start all instances:                                     │
│   ./scripts/start-all-instances.sh                       │
│                                                          │
│ Attach to tmux session:                                 │
│   tmux attach-session -t claude-multi                    │
│                                                          │
│ Navigate tmux panes:                                     │
│   Ctrl+b, arrow keys                                     │
│                                                          │
│ Health check:                                            │
│   python3 scripts/health-check.py                        │
│                                                          │
│ View logs:                                               │
│   tail -f .git/audit/orchestrator-decisions.log          │
│                                                          │
│ Emergency shutdown:                                      │
│   ./scripts/shutdown-all-instances.sh                    │
│                                                          │
│ Force release write lock:                                │
│   python3 scripts/force-release-lock.py                  │
└─────────────────────────────────────────────────────────┘
```

---

**End of Operations Guide**
