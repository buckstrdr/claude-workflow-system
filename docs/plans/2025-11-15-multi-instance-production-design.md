# Multi-Instance Claude Code Orchestration - Production-Ready Design

**Date:** 2025-11-15
**Status:** Complete Design - Ready for Implementation
**Based on:** v3 Spec with Production Hardening
**Goal:** Production-ready system from day 1 - no iterative PoC

---

## Executive Summary

This document details the complete production-ready design for a multi-instance Claude Code orchestration system with 9 specialized roles, enforced quality gates, and robust coordination mechanisms.

**Key Achievements:**
- Solves context explosion through self-contained messages
- Prevents git conflicts through write lock coordination
- Ensures production quality through 7-stage quality gates
- Enables graceful failure recovery
- Supports day-1 production use with comprehensive testing

**Critical Design Decisions:**
1. **Write Lock Coordination** - Orchestrator serializes all write operations
2. **Self-Contained Messages** - No conversation history needed to act
3. **Role-Based MCP Access** - Prevents resource contention
4. **Modular Bootstrap** - Validates each step, fails fast
5. **Failure Recovery** - Graceful degradation with clear recovery procedures

---

## 1. System Architecture

### 1.1 Instance Configuration

**9 Claude Code Instances in tmux:**

```
Session: claude-feature-<name>

Window 1: orchestrator
├─ Pane 1: Orchestrator (coordination brain)

Window 2: core-roles
├─ Pane 1: Librarian (context retrieval)
├─ Pane 2: Planner (spec and planning)
└─ Pane 3: Architect (architecture decisions)

Window 3: implementation
├─ Pane 1: Dev-A (primary implementation)
├─ Pane 2: Dev-B (secondary implementation)
├─ Pane 3: QA-A (testing and validation)
└─ Pane 4: QA-B (testing and validation)

Window 4: docs
└─ Pane 1: Docs (documentation)
```

### 1.2 Shared Infrastructure

**All instances share:**
- Single `toolset.yaml` (MCP servers, skills, hooks, agents)
- Same feature Git worktree
- Message board (files in `messages/`)
- Quality gate tracking (`.git/quality-gates/<feature>/`)
- Write lock state (`messages/write-lock.json`)

**Each instance has:**
- Role-specific system prompt (assembled from system-comps)
- Dedicated message inbox/outbox
- Separate shell session (no terminal contention)

---

## 2. Write Coordination System

### 2.1 Problem Statement

With 9 instances sharing the same Git worktree and filesystem:
- Git conflicts if simultaneous commits
- File corruption if simultaneous writes
- Race conditions in MCP operations

### 2.2 Solution: Orchestrator-Managed Write Locks

**Write Lock Protocol:**

```
messages/
  write-lock.json       # Lock state file

{
  "locked": true,
  "holder": "Dev-A",
  "operation": "committing tests",
  "timestamp": "2025-11-15T21:00:00Z",
  "timeout_at": "2025-11-15T21:05:00Z",
  "queue": ["Docs", "Dev-B"]
}
```

**Request Flow:**

1. **Role wants to write:**
   ```markdown
   ## WriteRequest
   **From:** Dev-A
   **To:** Orchestrator
   **Operation:** Commit test files
   **Estimated Duration:** 30 seconds
   ```

2. **Orchestrator checks lock:**
   - Lock available? → Grant immediately
   - Lock held? → Add to queue, notify role to wait

3. **Orchestrator grants lock:**
   ```markdown
   ## WriteLockGrant
   **To:** Dev-A
   **Operation:** Commit test files
   **Timeout:** 5 minutes from now
   **Instructions:** Proceed with operation. Send WriteComplete when done.
   ```

4. **Role completes operation:**
   ```markdown
   ## WriteComplete
   **From:** Dev-A
   **Operation:** Commit test files
   **Result:** Success - SHA a1b2c3d
   ```

5. **Orchestrator releases lock:**
   - Remove Dev-A from lock
   - Grant to next in queue (Docs)

**Lock Timeout:**
- Default: 5 minutes
- Prevents deadlock if instance crashes
- After timeout: Lock auto-releases, warning logged

**Operations Requiring Lock:**
- Git commit
- Git push
- File writes to shared docs
- Message board writes (brief lock)

**Operations NOT Requiring Lock:**
- Reading files
- Creating new files in isolated directories
- Running tests
- MCP reads

### 2.3 Work Partitioning (Dev-A vs Dev-B)

To maximize parallelism:

**Orchestrator assigns different files to each Dev:**
- Dev-A: `backend/services/`
- Dev-B: `backend/api/`

**No file overlap = No lock needed for file operations**

**Lock only needed when committing:**
- Dev-A requests lock → commits services changes
- Dev-B requests lock → commits API changes
- Sequential commits prevent conflicts

---

## 3. Message Protocol Design

### 3.1 Problem Statement

With 9 instances and long-running features:
- Conversation history grows unbounded
- Context window exhaustion
- Roles lose track of prior context

### 3.2 Solution: Self-Contained Messages

**Core Principle:** Every message includes ALL context needed to act on it.

**Message Structure Template:**

```markdown
## MessageType

**From:** <sender_role>
**To:** <recipient_role>
**Timestamp:** <ISO 8601>
**Message ID:** <unique_id>

**Feature Context:**
- Name: <feature_name>
- Current Gate: <gate_number> (<gate_name>)
- Spec Location: <path_to_spec>

**Task/Request/Update:**
<Full description with all necessary details>

**Files Involved:**
- <file_path_1>
- <file_path_2>

**Dependencies:**
<What this depends on, or "None">

**Success Criteria:**
<Explicit criteria for completion>

**Quality Gate Requirements:**
<Relevant gate requirements this task addresses>

**Expected Response:**
<What message type to send back>
```

### 3.3 Example: TaskAssignment (Full Context)

```markdown
## TaskAssignment

**From:** Orchestrator
**To:** Dev-A
**Timestamp:** 2025-11-15T21:00:00Z
**Message ID:** TA-001

**Feature Context:**
- Name: order_idempotency
- Current Gate: 2 (Tests First - TDD)
- Spec Location: docs/feature/order_idempotency.md

**Task:**
Create comprehensive test file for IdempotencyStore class that validates:
1. Store can track order IDs with configurable TTL (default 3600 seconds)
2. Duplicate detection works within idempotency window
3. Expired entries are automatically cleaned up
4. Concurrent access is thread-safe

**Files to Create:**
- backend/tests/test_idempotency_store.py

**Dependencies:**
None - new test file, no existing code dependencies

**Test Requirements (Gate 2):**
- Tests MUST fail (Red phase) - no implementation exists yet
- Tests reflect all success criteria from spec (4 validation points above)
- Tests are comprehensive (happy path + edge cases + error cases)
- Test file follows project testing conventions

**Code Standards:**
- Use pytest framework
- Follow existing test patterns in backend/tests/
- Include docstrings for each test
- Use descriptive test names: test_<scenario>_<expected_outcome>

**Success Criteria:**
- Test file created with minimum 8 test cases
- All tests fail with clear failure messages
- No implementation code written
- Code passes linting (ruff, mypy)

**Quality Gate Requirements:**
- This task completes Gate 2 (Tests First)
- Must commit tests BEFORE implementation
- enforce_test_first hook will validate

**Expected Response:**
TaskComplete message when:
1. Test file created
2. Tests verified to fail
3. File committed to git
4. Include commit SHA in response
```

### 3.4 Message Board Structure

```
messages/
  orchestrator/
    inbox/
      TA-001-response.md       # TaskComplete from Dev-A
      WR-001-request.md        # WriteRequest from Docs
    outbox/
      TA-001-assignment.md     # TaskAssignment to Dev-A
      WL-001-grant.md          # WriteLockGrant to Docs
  dev-a/
    inbox/
      TA-001-assignment.md     # TaskAssignment from Orchestrator
      WL-001-grant.md          # WriteLockGrant from Orchestrator
    outbox/
      TA-001-response.md       # TaskComplete to Orchestrator
      WR-001-request.md        # WriteRequest to Orchestrator
  [... similar structure for all 9 roles ...]
```

**Message Delivery:**
- Initially: Human copies messages between panes (tmux copy-paste)
- Future: Helper scripts automate message delivery
- Each role polls inbox directory periodically

### 3.5 Benefits

✅ **No context dependency** - Each message is a complete snapshot
✅ **Token efficiency** - Roles only load messages for current task
✅ **Instance recovery** - Crashed instance can resume from last message
✅ **Audit trail** - Complete message history in files
✅ **Testability** - Can inject messages to test role behavior

---

## 4. MCP Resource Management

### 4.1 Role-Based Access Patterns

**Read-Only Roles:**
- Librarian: Reads code, docs, git history for ContextPacks
- QA-A, QA-B: Read code and run tests

**Write-Occasional Roles:**
- Orchestrator: Writes messages, lock state
- Planner: Writes specs and plans
- Architect: Writes ADRs

**Write-Frequent Roles:**
- Dev-A, Dev-B: Write code and tests
- Docs: Write documentation

### 4.2 MCP Server Configuration

**toolset.yaml:**

```yaml
mcpServers:
  filesystem:
    type: local-fs
    root: /path/to/feature-worktree
    # All instances: Read access
    # Write coordination via Orchestrator lock

  git:
    type: git
    repo: /path/to/feature-worktree
    # All instances: Read git history
    # Only Dev/Docs: Commit (via Orchestrator lock)

  terminal:
    type: shell
    cwd: /path/to/feature-worktree
    # Each instance: Separate shell session
    # No contention

  serena:
    type: http
    url: http://localhost:3001
    connection_pool: 10
    # Handles 9 concurrent connections
    # Skills: brainstorming, planning, validation

  playwright:
    type: browser
    endpoint: http://localhost:9222
    # For UI verification (Gate 6)
    # Used by QA roles only

  context7:
    type: context-service
    url: http://localhost:4000
    # Optional - library documentation
    # Used by Librarian primarily

  firecrawl:
    type: crawler
    url: http://localhost:5000
    # Optional - web research
    # Used by Librarian for external context
```

### 4.3 Preventing Contention

**Git Operations:**
- Only Orchestrator coordinates commits (via write lock)
- Reads (log, diff, show) - no coordination needed
- Result: No git conflicts possible

**Filesystem Operations:**
- Isolated file creation - no coordination needed
- Shared file writes - write lock required
- Result: No file corruption possible

**Terminal Operations:**
- Each instance gets separate shell session
- No shared state between sessions
- Result: No terminal contention

**Serena/Skills:**
- HTTP connection pool handles concurrency
- Stateless requests (no session state)
- Result: All instances can use skills concurrently

---

## 5. Bootstrap System Design

### 5.1 Modular Bootstrap Architecture

**scripts/bootstrap/**

```
00-preflight-check.sh       # Verify dependencies
10-mcp-setup.sh             # Start/verify MCP servers
20-git-setup.sh             # Create worktree, init gates
30-toolset-config.sh        # Template toolset.yaml
40-prompt-assembly.sh       # Build system prompts
50-tmux-layout.sh           # Create tmux layout
60-instance-launch.sh       # Launch Claude instances
70-post-launch-verify.sh    # Verify all running
```

**bootstrap.sh** (master):

```bash
#!/bin/bash
set -euo pipefail

FEATURE_NAME="$1"
SESSION_NAME="claude-feature-$FEATURE_NAME"

echo "=== Claude Multi-Instance Bootstrap ==="
echo "Feature: $FEATURE_NAME"
echo ""

# Run each step, exit if any fails
for script in scripts/bootstrap/*.sh; do
    echo "Running: $(basename $script)"
    "$script" "$FEATURE_NAME" || {
        echo "❌ Bootstrap failed at: $(basename $script)"
        exit 1
    }
    echo ""
done

echo "✅ Bootstrap complete!"
echo "Attaching to Orchestrator pane..."
tmux attach-session -t "$SESSION_NAME:orchestrator"
```

### 5.2 Preflight Checks (00-preflight-check.sh)

**Verifies:**
- ✅ Claude Code CLI installed (`claude --version`)
- ✅ tmux installed (`tmux -V`)
- ✅ Git repo initialized (`.git/` exists)
- ✅ Python 3.8+ for build_prompt.py
- ✅ Required directories exist (`system-comps/`, `scripts/`)
- ✅ No existing session with same name

**Exit on failure:** Clear error message with remediation steps

### 5.3 MCP Setup (10-mcp-setup.sh)

**Critical MCPs (must be running):**
- Serena (skills and memory)
- Filesystem (file operations)
- Git (version control)
- Terminal (shell access)

**Optional MCPs (warn if down):**
- Playwright (UI verification)
- Context7 (library docs)
- Firecrawl (web research)

**Logic:**

```bash
# Check Serena
if ! curl -s http://localhost:3001/health >/dev/null; then
    echo "❌ Serena MCP not running (CRITICAL)"
    echo "Start with: make mcp-start"
    exit 1
fi

# Check Playwright
if ! curl -s http://localhost:9222 >/dev/null; then
    echo "⚠️  Playwright MCP not running"
    echo "UI verification will be unavailable"
    read -p "Continue anyway? (y/N) " -n 1 -r
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Continue for other MCPs...
```

### 5.4 Git Setup (20-git-setup.sh)

**Creates:**
1. Feature branch: `feature/<name>`
2. Git worktree: `../wt-feature-<name>`
3. Quality gate tracking: `.git/quality-gates/<name>/`

**Initializes:**
- `status.json` with all 7 gates in PENDING
- Individual gate status files
- Timestamps

**Verifies:**
- Worktree created successfully
- Can commit to worktree (dry run)
- Quality gate files valid JSON

### 5.5 Toolset Configuration (30-toolset-config.sh)

**Templates toolset.yaml:**

```bash
# Replace placeholder paths with actual worktree path
WORKTREE_PATH="../wt-feature-$FEATURE_NAME"

sed "s|/path/to/feature-worktree|$WORKTREE_PATH|g" \
    toolset.yaml.template > toolset.yaml

# Verify YAML is valid
python3 -c "import yaml; yaml.safe_load(open('toolset.yaml'))" || {
    echo "❌ Generated toolset.yaml is invalid YAML"
    exit 1
}
```

### 5.6 Prompt Assembly (40-prompt-assembly.sh)

**Builds prompts for all 9 roles:**

```bash
for role in orchestrator librarian planner architect dev qa docs; do
    ./scripts/build_prompt.py "$role" > "/tmp/prompt_${role}.txt"

    # Verify under token limit
    tokens=$(wc -w < "/tmp/prompt_${role}.txt" | awk '{print int($1/0.75)}')
    if [ "$tokens" -gt 8000 ]; then
        echo "⚠️  Warning: $role prompt is ${tokens} tokens (budget: 8000)"
    fi
done
```

**Special handling for dev and qa (used twice each):**
- Dev prompt used for both Dev-A and Dev-B
- QA prompt used for both QA-A and QA-B

### 5.7 tmux Layout (50-tmux-layout.sh)

**Creates session and windows:**

```bash
# Create session with orchestrator window
tmux new-session -d -s "$SESSION_NAME" -n orchestrator

# Create core-roles window (3 panes)
tmux new-window -t "$SESSION_NAME" -n core-roles
tmux split-window -t "$SESSION_NAME:core-roles" -h
tmux split-window -t "$SESSION_NAME:core-roles" -h
tmux select-layout -t "$SESSION_NAME:core-roles" even-horizontal

# Create implementation window (4 panes)
tmux new-window -t "$SESSION_NAME" -n implementation
tmux split-window -t "$SESSION_NAME:implementation" -h
tmux split-window -t "$SESSION_NAME:implementation.0" -v
tmux split-window -t "$SESSION_NAME:implementation.2" -v
tmux select-layout -t "$SESSION_NAME:implementation" tiled

# Create docs window (1 pane)
tmux new-window -t "$SESSION_NAME" -n docs

# Return to orchestrator window
tmux select-window -t "$SESSION_NAME:orchestrator"
```

### 5.8 Instance Launch (60-instance-launch.sh)

**Launches all 9 instances:**

```bash
# Orchestrator
tmux send-keys -t "$SESSION_NAME:orchestrator" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_orchestrator.txt)\"" C-m

# Librarian
tmux send-keys -t "$SESSION_NAME:core-roles.0" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_librarian.txt)\"" C-m

# Planner
tmux send-keys -t "$SESSION_NAME:core-roles.1" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_planner.txt)\"" C-m

# ... continue for all 9 instances ...
```

**Wait for instances to initialize:**

```bash
sleep 5  # Allow Claude instances to start
```

### 5.9 Post-Launch Verification (70-post-launch-verify.sh)

**Verifies:**

```bash
# Check all panes exist
expected_panes=9
actual_panes=$(tmux list-panes -s -t "$SESSION_NAME" | wc -l)

if [ "$actual_panes" -ne "$expected_panes" ]; then
    echo "❌ Expected $expected_panes panes, found $actual_panes"
    exit 1
fi

# Check Claude Code is running in each pane
for pane in $(tmux list-panes -s -t "$SESSION_NAME" -F '#{pane_id}'); do
    content=$(tmux capture-pane -t "$pane" -p)
    if ! echo "$content" | grep -q "Claude Code"; then
        echo "⚠️  Pane $pane may not have Claude Code running"
    fi
done

# Create message board structure
mkdir -p messages/{orchestrator,librarian,planner,architect,dev-a,dev-b,qa-a,qa-b,docs}/{inbox,outbox}

# Initialize write lock (unlocked)
cat > messages/write-lock.json <<EOF
{
  "locked": false,
  "holder": null,
  "operation": null,
  "timestamp": null,
  "timeout_at": null,
  "queue": []
}
EOF

echo "✅ All instances launched and verified"
```

### 5.10 Bootstrap Success Summary

**Displays:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Bootstrap Complete: feature/order_idempotency
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ MCP Servers: All critical servers running
✅ Git Worktree: ../wt-feature-order_idempotency
✅ Quality Gates: Initialized at Gate 1
✅ tmux Session: claude-feature-order_idempotency
✅ Claude Instances: 9/9 running

Instance Layout:
- Window 1 (orchestrator): Orchestrator
- Window 2 (core-roles): Librarian, Planner, Architect
- Window 3 (implementation): Dev-A, Dev-B, QA-A, QA-B
- Window 4 (docs): Docs

Next Steps:
1. You'll be attached to the Orchestrator pane
2. Provide feature description to Orchestrator
3. Orchestrator will coordinate work through all roles
4. System will enforce 7-stage quality gates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 6. System Prompts and System-Comps

### 6.1 System-Comps Structure

```
system-comps/
  core/                          # Role identity definitions
    orchestrator_identity.md     # "You are the Orchestrator..."
    librarian_identity.md
    planner_identity.md
    architect_identity.md
    dev_identity.md
    qa_identity.md
    docs_identity.md

  shared/                        # Common policies
    tdd.md                       # TDD principles
    docintent.md                 # DocIntent protocol
    quality_gates.md             # 7-gate workflow
    validation_skills.md         # validator/pragmatist/karen
    superpowers_workflow.md      # Brainstorm→Plan→Execute
    write_coordination.md        # Write lock protocol
    message_protocol.md          # Message standards
    hooks_usage.md               # Hook policies
    tool_usage.md                # Tool usage policies

  role-specific/                 # Role-specific behaviors
    orchestrator_gates.md        # Gate advancement logic
    orchestrator_coordination.md # Multi-role coordination
    dev_tdd_strict.md            # Strict TDD for Dev
    docs_live_updates.md         # Live documentation
    qa_validation.md             # Validation procedures
    librarian_context.md         # ContextPack creation
```

### 6.2 Prompt Assembly Configuration

**prompts.yaml:**

```yaml
roles:
  orchestrator:
    system_comps:
      - core/orchestrator_identity.md
      - shared/quality_gates.md
      - shared/validation_skills.md
      - shared/write_coordination.md
      - shared/message_protocol.md
      - role-specific/orchestrator_gates.md
      - role-specific/orchestrator_coordination.md
      - shared/superpowers_workflow.md
    max_tokens: 8000

  librarian:
    system_comps:
      - core/librarian_identity.md
      - shared/message_protocol.md
      - role-specific/librarian_context.md
      - shared/tool_usage.md
    max_tokens: 6000

  planner:
    system_comps:
      - core/planner_identity.md
      - shared/quality_gates.md
      - shared/superpowers_workflow.md
      - shared/message_protocol.md
      - shared/tdd.md
    max_tokens: 7000

  architect:
    system_comps:
      - core/architect_identity.md
      - shared/message_protocol.md
      - shared/quality_gates.md
    max_tokens: 6000

  dev:
    system_comps:
      - core/dev_identity.md
      - shared/tdd.md
      - shared/docintent.md
      - shared/quality_gates.md
      - shared/write_coordination.md
      - shared/message_protocol.md
      - role-specific/dev_tdd_strict.md
    max_tokens: 7500

  qa:
    system_comps:
      - core/qa_identity.md
      - shared/quality_gates.md
      - shared/validation_skills.md
      - shared/message_protocol.md
      - role-specific/qa_validation.md
    max_tokens: 7000

  docs:
    system_comps:
      - core/docs_identity.md
      - shared/docintent.md
      - shared/quality_gates.md
      - shared/write_coordination.md
      - shared/message_protocol.md
      - role-specific/docs_live_updates.md
    max_tokens: 7000
```

### 6.3 Example System-Comp: write_coordination.md

```markdown
# Write Coordination Protocol

All file and git operations must coordinate through the Orchestrator to prevent conflicts.

## Write Lock System

**Write lock state:** `messages/write-lock.json`

**Before ANY write operation:**
1. Check if write lock is available
2. Send WriteRequest to Orchestrator
3. Wait for WriteLockGrant
4. Perform operation
5. Send WriteComplete to Orchestrator

## Operations Requiring Write Lock

✅ **MUST request lock:**
- Git commit
- Git push
- Writing to shared documentation files
- Writing to message board

❌ **NO lock needed:**
- Reading any files
- Creating new files in your assigned directory
- Running tests
- Using MCP tools for reads

## WriteRequest Message Format

\`\`\`markdown
## WriteRequest

**From:** <your_role>
**To:** Orchestrator
**Operation:** <brief description>
**Estimated Duration:** <seconds>
**Files:** <list of files to modify>
\`\`\`

## Handling WriteLockGrant

When you receive WriteLockGrant:
1. Proceed with your operation immediately
2. Complete within the timeout (default: 5 minutes)
3. Send WriteComplete when done
4. If operation fails, still send WriteComplete with error details

## Handling Lock Unavailable

If Orchestrator responds that lock is held by another role:
1. You will be queued
2. Wait for WriteLockGrant message
3. Do NOT retry or attempt to bypass
4. Use waiting time for other tasks (reading, analysis, planning)

## Lock Timeout

If you hold the lock for >5 minutes:
- Lock auto-releases
- Warning logged
- Orchestrator may assign your task to another role

**Critical:** Always complete operations quickly to avoid blocking other roles.
```

### 6.4 Build Prompt Script

**scripts/build_prompt.py:**

```python
#!/usr/bin/env python3
"""
Assemble role-specific system prompts from system-comps.

Usage: ./build_prompt.py <role_name>
Example: ./build_prompt.py orchestrator
"""

import sys
import yaml
from pathlib import Path

def estimate_tokens(text: str) -> int:
    """Rough token estimate: ~4 chars per token"""
    return len(text) // 4

def build_prompt(role_name: str) -> str:
    """Assemble system prompt from comps for given role"""

    # Load configuration
    config_path = Path('prompts.yaml')
    if not config_path.exists():
        print(f"Error: prompts.yaml not found", file=sys.stderr)
        sys.exit(1)

    with open(config_path) as f:
        config = yaml.safe_load(f)

    if role_name not in config['roles']:
        print(f"Error: Unknown role '{role_name}'", file=sys.stderr)
        print(f"Available roles: {', '.join(config['roles'].keys())}", file=sys.stderr)
        sys.exit(1)

    role_config = config['roles'][role_name]
    max_tokens = role_config.get('max_tokens', 8000)

    # Assemble prompt from comps
    prompt_parts = []
    total_tokens = 0

    for comp_path in role_config['system_comps']:
        full_path = Path('system-comps') / comp_path

        if not full_path.exists():
            print(f"Warning: System-comp not found: {comp_path}", file=sys.stderr)
            continue

        content = full_path.read_text()
        tokens = estimate_tokens(content)

        if total_tokens + tokens > max_tokens:
            print(f"Warning: Prompt for {role_name} exceeds {max_tokens} tokens at {comp_path}",
                  file=sys.stderr)
            print(f"Current total: {total_tokens + tokens} tokens", file=sys.stderr)
            # Continue anyway - Claude can handle it

        prompt_parts.append(content)
        total_tokens += tokens

    # Final prompt
    prompt = '\n\n---\n\n'.join(prompt_parts)

    # Add footer with metadata
    footer = f"""
---

**Role:** {role_name.title()}
**Prompt assembled from:** {len(prompt_parts)} system-comps
**Estimated tokens:** {total_tokens}
**Generated:** {datetime.now().isoformat()}
"""

    return prompt + footer

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: ./build_prompt.py <role_name>", file=sys.stderr)
        sys.exit(1)

    from datetime import datetime
    role = sys.argv[1]
    prompt = build_prompt(role)
    print(prompt)
```

---

## 7. Git Hook Implementation

### 7.1 Hook: enforce_test_first.sh

**Location:** `.git/hooks/pre-commit` (symlinked from `scripts/hooks/`)

**Purpose:** Enforce TDD by blocking implementation commits without prior test commits

**Full implementation in v3 spec Section 7, key features:**
- Detects staged implementation files
- Checks for corresponding test files in git history
- Blocks if tests don't exist or weren't committed first
- Blocks if tests and implementation staged together
- Clear error messages with remediation steps
- Emergency bypass via `STRICT_TDD=0`

### 7.2 Hook: quality_gates_check.sh

**Location:** `.git/hooks/pre-push`

**Purpose:** Enforce Gate 7 completion before pushing to main

**Key logic:**
```bash
# Extract feature name from current branch
current_branch=$(git branch --show-current)

if [[ "$current_branch" =~ ^feature/(.+)$ ]]; then
    feature_name="${BASH_REMATCH[1]}"
    gate_status=".git/quality-gates/$feature_name/status.json"

    # Check Gate 7 status
    gate_7_status=$(jq -r '.gates["7"].status' "$gate_status")

    if [ "$gate_7_status" != "PASSED" ]; then
        echo "❌ Gate 7 (Code Reviewed) NOT PASSED"
        echo "Push BLOCKED."
        exit 1
    fi
fi
```

### 7.3 Hook: enforce_ui_verification.sh

**Location:** `.git/hooks/pre-commit`

**Purpose:** Require Playwright verification for frontend changes

**Detection logic:**
```bash
# Detect UI changes
UI_CHANGED=$(git diff --cached --name-only | \
             grep -E "frontend/src/.*\.(tsx|ts|jsx|js|css|scss)$" | \
             wc -l)

if [ "$UI_CHANGED" -gt 0 ]; then
    # Check for Playwright evidence
    # - Screenshots in .ian/
    # - Verification report
    # - Recent Playwright MCP usage

    if [ "$PLAYWRIGHT_USED" -eq 0 ]; then
        echo "❌ UI changes require Playwright verification"
        echo "Run: /ui-verify"
        exit 1
    fi
fi
```

### 7.4 Hook Installation

**scripts/hooks/install-hooks.sh:**

```bash
#!/bin/bash
# Install git hooks by symlinking from scripts/hooks/

HOOKS=(
    "pre-commit:enforce_test_first.sh"
    "pre-push:quality_gates_check.sh"
    "post-checkout:workflow_reminder.sh"
)

for hook_def in "${HOOKS[@]}"; do
    IFS=':' read -r hook_name script_name <<< "$hook_def"

    ln -sf "../../scripts/hooks/$script_name" ".git/hooks/$hook_name"
    chmod +x ".git/hooks/$hook_name"

    echo "✅ Installed: $hook_name → $script_name"
done
```

---

## 8. Failure Recovery System

### 8.1 Instance Crash Recovery

**Detection:**
```bash
# scripts/health-check.sh <role>
tmux capture-pane -t "claude-feature-xyz:$role" -p | \
  grep -q "Claude Code" || echo "CRASHED"
```

**Recovery procedure:**

```markdown
## Instance Crash Recovery

**Symptoms:**
- Pane shows shell prompt instead of Claude interface
- No response to messages
- Tmux pane exists but inactive

**Recovery Steps:**

1. **Identify crashed instance:**
   ./scripts/health-check.sh dev-a
   > ❌ CRASHED - No Claude Code process

2. **Orchestrator actions:**
   - Load last TaskAssignment from messages/dev-a/inbox/
   - Check write-lock.json - was Dev-A holding lock?
     - YES → Release lock, notify queue
     - NO → Continue
   - Log crash event

3. **Human recovery:**
   - Navigate to crashed pane in tmux
   - Ctrl+C to clear any remnants
   - Re-run launch command:
     ```bash
     claude code --mcp-config toolset.yaml \
       --system "$(cat /tmp/prompt_dev.txt)"
     ```

4. **Instance resumes:**
   - Instance loads with same system prompt
   - Orchestrator re-sends last TaskAssignment
   - Dev-A continues from checkpoint (last committed state)

5. **Verification:**
   - Instance responds to test message
   - Write lock status correct
   - Task continues normally
```

### 8.2 MCP Server Failure Recovery

**Critical MCP failures (Serena, Filesystem, Git):**

```markdown
## Critical MCP Failure

**Symptoms:**
- Skill operations fail with connection errors
- File operations timeout
- Git commands fail

**Recovery:**

1. **Detect failure:**
   ./scripts/mcp/mcp-status.sh
   > serena: DOWN (connection refused)

2. **Attempt restart:**
   make mcp-restart

3. **If restart fails:**
   - System enters degraded mode
   - Orchestrator notifies all roles:
     "⚠️  CRITICAL: Serena MCP offline - skills unavailable"
   - Skills (pragmatist, validator) cannot run
   - Gate advancement blocked at Gates 4 and 7

4. **Workarounds:**
   - Gate 4: Manual refactoring review instead of pragmatist
   - Gate 7: Manual code review instead of validator
   - Continue with reduced automation

5. **Full recovery:**
   - Fix Serena service
   - Restart: make mcp-restart
   - Re-run failed skill operations
   - Resume normal workflow
```

**Non-critical MCP failures (Playwright, Context7):**
- Warn but continue
- Skip optional features (UI verification, library docs)
- Document degraded functionality in feature notes

### 8.3 Git Conflict Recovery

**Scenario:** Despite write locks, git conflict occurs

```markdown
## Git Conflict Recovery

**Symptoms:**
- Git commit fails with "lock file exists"
- Git reports diverged branches
- Worktree in inconsistent state

**Recovery:**

1. **Abort in-progress operation:**
   git reset --hard HEAD

2. **Check write lock state:**
   cat messages/write-lock.json

   If lock held by crashed instance:
   - Manually release lock
   - Update lock file: locked=false

3. **Sync worktree:**
   git fetch origin
   git rebase origin/main

   If conflicts:
   - Resolve manually
   - Continue rebase

4. **Re-request write lock:**
   Send new WriteRequest to Orchestrator

5. **Retry operation:**
   - Stage changes
   - Commit with new message
   - Verify success

6. **Prevent recurrence:**
   - Review: Why did lock fail?
   - Check: Auto-commit service interfering?
   - Fix: Adjust lock timeout or coordination logic
```

### 8.4 Quality Gate State Corruption

**Recovery script: scripts/quality-gates/gates-recover.sh**

```bash
#!/bin/bash
# Recover corrupted quality gate state

feature_name="$1"
gate_dir=".git/quality-gates/$feature_name"

echo "Recovering quality gate state for: $feature_name"

# 1. Backup corrupted state
if [ -f "$gate_dir/status.json" ]; then
    cp "$gate_dir/status.json" "$gate_dir/status.json.corrupted"
    echo "✅ Backed up corrupted state"
fi

# 2. Attempt recovery from git history
git show HEAD:"$gate_dir/status.json" > "$gate_dir/status.json.recovered" 2>/dev/null

if [ $? -eq 0 ]; then
    mv "$gate_dir/status.json.recovered" "$gate_dir/status.json"
    echo "✅ Recovered from git history"
else
    # 3. Rebuild from individual gate files
    echo "Rebuilding from individual gate status files..."
    ./scripts/quality-gates/gates-rebuild.sh "$feature_name"
fi

# 4. Validate recovered state
if ./scripts/quality-gates/gates-check.sh "$feature_name"; then
    echo "✅ Recovery successful"
    echo "Current status:"
    cat "$gate_dir/status.json" | jq .
else
    echo "❌ Recovery failed - manual intervention required"
    exit 1
fi
```

### 8.5 Emergency System Reset

**scripts/emergency-reset.sh:**

```bash
#!/bin/bash
# Emergency reset - return system to safe state

feature_name="$1"
session_name="claude-feature-$feature_name"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  EMERGENCY RESET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  This will:"
echo "  - Release all write locks"
echo "  - Clear message queues"
echo "  - Sync all instances to current git HEAD"
echo "  - Reset quality gate state to last valid checkpoint"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# 1. Release all write locks
cat > messages/write-lock.json <<EOF
{
  "locked": false,
  "holder": null,
  "operation": null,
  "timestamp": null,
  "timeout_at": null,
  "queue": []
}
EOF
echo "✅ Write locks released"

# 2. Clear message queues
for role in orchestrator librarian planner architect dev-a dev-b qa-a qa-b docs; do
    rm -f messages/$role/inbox/*
    rm -f messages/$role/outbox/*
done
echo "✅ Message queues cleared"

# 3. Sync worktree to HEAD
cd "../wt-feature-$feature_name"
git reset --hard HEAD
git clean -fd
echo "✅ Worktree synced to HEAD"

# 4. Recover quality gate state
cd -
./scripts/quality-gates/gates-recover.sh "$feature_name"

# 5. Display current state
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RESET COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
./scripts/quality-gates/gates-check.sh "$feature_name"
echo ""
echo "Next steps:"
echo "1. Verify all instances still running"
echo "2. Orchestrator: Resume feature work"
echo "3. If issues persist: Restart affected instances"
echo ""
```

---

## 9. Testing Strategy

### 9.1 Unit Tests (Component Level)

**tests/unit/**

```
test_gates_start.sh          # Quality gate initialization
test_gates_pass.sh           # Gate advancement
test_gates_check.sh          # Gate validation
test_enforce_test_first.sh   # TDD hook
test_write_lock.sh           # Lock coordination
test_message_parsing.sh      # Message format validation
test_prompt_assembly.sh      # System prompt building
```

**Example: tests/unit/test_write_lock.sh**

```bash
#!/bin/bash
source tests/test-helpers.sh

test_lock_grant_when_available() {
    setup_test_env

    # Initial state: unlocked
    assert_lock_available

    # Request lock
    request_lock "Dev-A" "commit tests"

    # Verify granted
    assert_lock_held_by "Dev-A"
    assert_exit_code 0
}

test_lock_queues_when_held() {
    setup_test_env

    # Dev-A holds lock
    grant_lock "Dev-A" "commit tests"

    # Dev-B requests lock
    request_lock "Dev-B" "commit implementation"

    # Verify queued
    assert_in_queue "Dev-B"
    assert_lock_still_held_by "Dev-A"
}

test_lock_releases_and_grants_next() {
    setup_test_env

    # Setup: Dev-A holds, Dev-B queued
    grant_lock "Dev-A" "commit tests"
    queue_lock_request "Dev-B" "commit implementation"

    # Dev-A releases
    release_lock "Dev-A"

    # Verify Dev-B now holds
    assert_lock_held_by "Dev-B"
    assert_queue_empty
}

test_lock_timeout_releases() {
    setup_test_env

    # Grant lock with 1-second timeout (for testing)
    grant_lock_with_timeout "Dev-A" "commit tests" 1

    # Wait for timeout
    sleep 2

    # Verify auto-released
    assert_lock_available
    assert_timeout_logged "Dev-A"
}

run_tests
```

### 9.2 Integration Tests

**tests/integration/**

```
test_bootstrap_full.sh           # Full bootstrap process
test_message_delivery.sh         # End-to-end message passing
test_quality_gates_workflow.sh   # Full gate progression
test_mcp_coordination.sh         # Multiple instances using MCPs
```

**Example: tests/integration/test_message_delivery.sh**

```bash
#!/bin/bash
source tests/test-helpers.sh

test_message_delivery_end_to_end() {
    # 1. Setup minimal system (Orchestrator + Dev-A)
    start_test_instances "orchestrator" "dev-a"

    # 2. Orchestrator sends TaskAssignment
    send_message orchestrator dev-a "TaskAssignment" \
      "Create test file for Feature X"

    # 3. Verify message appears in Dev-A inbox
    assert_file_exists "messages/dev-a/inbox/TA-001.md"
    assert_file_contains "messages/dev-a/inbox/TA-001.md" "Create test file"

    # 4. Dev-A sends TaskComplete
    send_message dev-a orchestrator "TaskComplete" \
      "Test file created successfully"

    # 5. Verify message appears in Orchestrator inbox
    assert_file_exists "messages/orchestrator/inbox/TC-001.md"
    assert_file_contains "messages/orchestrator/inbox/TC-001.md" "successfully"

    # 6. Cleanup
    stop_test_instances
}

run_tests
```

### 9.3 Smoke Test (Full System)

**tests/smoke/test_full_workflow.sh:**

```bash
#!/bin/bash
# Full end-to-end smoke test with minimal feature

set -euo pipefail

FEATURE_NAME="smoke_test_$(date +%s)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SMOKE TEST: Full Workflow"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Bootstrap
echo "Step 1: Bootstrap system"
./bootstrap.sh "$FEATURE_NAME" || {
    echo "❌ Bootstrap failed"
    exit 1
}

# 2. Verify all instances running
echo "Step 2: Verify instances"
./scripts/bootstrap/70-post-launch-verify.sh "$FEATURE_NAME" || {
    echo "❌ Verification failed"
    exit 1
}

# 3. Run through minimal workflow
echo "Step 3: Execute minimal feature workflow"

# Gate 1: Create minimal spec
echo "  Gate 1: Creating spec..."
# (Script simulates Planner creating spec)
./tests/smoke/helpers/create_minimal_spec.sh "$FEATURE_NAME"

# Gate 2: Write tests
echo "  Gate 2: Writing tests..."
# (Script simulates Dev writing tests)
./tests/smoke/helpers/write_minimal_tests.sh "$FEATURE_NAME"

# Gate 3: Implement
echo "  Gate 3: Implementing..."
./tests/smoke/helpers/implement_minimal_feature.sh "$FEATURE_NAME"

# Gates 4-6: Refactor, integrate, E2E
echo "  Gates 4-6: Refactor, integrate, verify..."
./tests/smoke/helpers/complete_remaining_gates.sh "$FEATURE_NAME"

# Gate 7: Code review
echo "  Gate 7: Code review..."
# (Trigger validator skill)

# 4. Verify all gates passed
echo "Step 4: Verify all gates passed"
gate_7_status=$(jq -r '.gates["7"].status' \
  ".git/quality-gates/$FEATURE_NAME/status.json")

if [ "$gate_7_status" != "PASSED" ]; then
    echo "❌ Gate 7 not passed: $gate_7_status"
    exit 1
fi

# 5. Attempt push to main (should succeed)
echo "Step 5: Test push to main"
cd "../wt-feature-$FEATURE_NAME"
git push origin feature/$FEATURE_NAME:main --dry-run || {
    echo "❌ Push validation failed"
    exit 1
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ SMOKE TEST PASSED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cleanup
echo "Cleaning up test environment..."
tmux kill-session -t "claude-feature-$FEATURE_NAME"
rm -rf "../wt-feature-$FEATURE_NAME"
```

### 9.4 Manual Validation Checklist

**docs/manual-validation-checklist.md:**

```markdown
# Pre-Launch Manual Validation Checklist

**Feature:** _____________
**Date:** _____________
**Validated By:** _____________

## Bootstrap (10 min)

- [ ] Run: `./bootstrap.sh test_feature`
- [ ] All MCP servers start successfully
- [ ] Git worktree created at correct path
- [ ] Quality gates initialized (status.json exists, valid JSON)
- [ ] tmux session has 4 windows, 9 panes
- [ ] All 9 Claude instances display prompt
- [ ] Message board directory structure created
- [ ] Write lock file initialized (unlocked)

## Communication (15 min)

- [ ] Orchestrator sends message to Dev-A
- [ ] Message appears in `messages/dev-a/inbox/`
- [ ] Message is self-contained (all context included)
- [ ] Dev-A sends response to Orchestrator
- [ ] Response appears in `messages/orchestrator/inbox/`
- [ ] All 9 roles can send/receive messages

## Write Coordination (10 min)

- [ ] Dev-A requests write lock (WriteRequest message)
- [ ] Orchestrator grants lock (WriteLockGrant message)
- [ ] Write-lock.json shows Dev-A as holder
- [ ] Dev-B requests lock while Dev-A holds
- [ ] Dev-B added to queue (not granted)
- [ ] Dev-A completes and releases lock
- [ ] Dev-B automatically granted lock
- [ ] Lock timeout works (grant with 5s timeout, wait 6s, auto-release)

## Quality Gates (20 min)

- [ ] Gates initialize at Gate 1 (PENDING)
- [ ] Cannot advance Gate 1 without spec
- [ ] Create minimal spec
- [ ] Advance to Gate 1 (PASSED)
- [ ] Current gate now 2 (Tests First)
- [ ] Gates track correctly in status.json
- [ ] Gates prevent advancement without requirements
- [ ] Pragmatist triggers at Gate 4 (automatic)
- [ ] Validator triggers at Gate 7 (automatic)

## Git Hooks (15 min)

- [ ] Stage implementation file
- [ ] Attempt commit (should BLOCK with TDD message)
- [ ] Stage test file only
- [ ] Commit tests (should ALLOW)
- [ ] Now stage implementation
- [ ] Commit implementation (should ALLOW - tests exist)
- [ ] Stage tests + implementation together
- [ ] Attempt commit (should BLOCK - must be separate)
- [ ] Try push without Gate 7
- [ ] Push blocked with quality gate message
- [ ] Complete Gate 7
- [ ] Push now allowed

## MCP Integration (10 min)

- [ ] All instances can read files (filesystem MCP)
- [ ] All instances can run shell commands (terminal MCP)
- [ ] All instances can read git history (git MCP)
- [ ] Librarian can use Serena for skills
- [ ] Planner can use brainstorming skill
- [ ] QA can use validator skill
- [ ] No MCP connection errors or timeouts

## Failure Recovery (15 min)

- [ ] Kill Dev-A instance (Ctrl+C in pane)
- [ ] Health check detects crash
- [ ] Restart Dev-A with launch command
- [ ] Dev-A resumes work normally
- [ ] If Dev-A held lock, lock released on crash
- [ ] Stop Serena MCP
- [ ] System enters degraded mode (graceful)
- [ ] Skills unavailable but work continues
- [ ] Restart Serena
- [ ] Skills available again
- [ ] Run emergency reset script
- [ ] System recovers to clean state

## Performance (5 min)

- [ ] Bootstrap completes in <2 minutes
- [ ] Message delivery <5 seconds
- [ ] Git operations <3 seconds
- [ ] MCP operations responsive (<1s)
- [ ] tmux responsive (no lag)

## Documentation (5 min)

- [ ] System prompts under 8K tokens each
- [ ] All 9 system prompts assemble correctly
- [ ] build_prompt.py runs without errors
- [ ] Prompts include all required system-comps
- [ ] Message templates are clear and complete

---

**Overall Status:** [ ] PASS / [ ] FAIL

**Issues Found:**
-
-
-

**Recommendations:**
-
-
-

**Sign-off:** _______________ Date: _______________
```

---

## 10. Implementation Roadmap

### 10.1 Phase 1: Foundation (Week 1)

**Deliverables:**
- ✅ Repository structure
- ✅ Quality gate scripts (start, check, pass, status)
- ✅ Git hooks (TDD, quality gates, UI verification)
- ✅ Write lock coordination files
- ✅ Message board structure
- ✅ Unit tests for all scripts

**Validation:**
- All unit tests pass
- Scripts execute without errors
- Hooks block/allow correctly (manual test)

### 10.2 Phase 2: System Prompts (Week 2)

**Deliverables:**
- ✅ System-comps (all 20+ files)
- ✅ prompts.yaml configuration
- ✅ build_prompt.py script
- ✅ Generated prompts for all 9 roles

**Validation:**
- All prompts under token budget
- Prompts include required comps
- build_prompt.py runs without errors
- Manual review of each role prompt

### 10.3 Phase 3: Bootstrap System (Week 3)

**Deliverables:**
- ✅ All 8 bootstrap scripts
- ✅ bootstrap.sh master script
- ✅ toolset.yaml template
- ✅ MCP management scripts
- ✅ Integration tests

**Validation:**
- Bootstrap runs end-to-end
- All instances launch successfully
- Integration tests pass
- Manual validation checklist complete

### 10.4 Phase 4: Failure Recovery (Week 4)

**Deliverables:**
- ✅ Health check scripts
- ✅ Recovery procedures
- ✅ Emergency reset script
- ✅ Failure scenario tests

**Validation:**
- Can recover from instance crash
- Can recover from MCP failure
- Can recover from git conflicts
- Emergency reset works

### 10.5 Phase 5: End-to-End Testing (Week 5)

**Deliverables:**
- ✅ Smoke test suite
- ✅ Full workflow test
- ✅ Performance benchmarks
- ✅ Documentation

**Validation:**
- Smoke test passes
- Bootstrap <2 minutes
- Full workflow completes
- Manual checklist 100% pass rate

### 10.6 Phase 6: Production Hardening (Week 6)

**Deliverables:**
- ✅ Error message improvements
- ✅ Logging and monitoring
- ✅ Performance optimizations
- ✅ User documentation

**Validation:**
- All error messages clear and actionable
- Logs capture critical events
- Performance meets targets
- Documentation complete

---

## 11. Success Criteria

### 11.1 Day-1 Launch Readiness

**System must:**
- ✅ Bootstrap in <2 minutes
- ✅ All 9 instances launch without manual intervention
- ✅ Execute full feature workflow end-to-end
- ✅ Enforce all 7 quality gates
- ✅ Prevent git conflicts (write lock coordination)
- ✅ Recover from common failures gracefully
- ✅ Pass smoke test suite 100%
- ✅ Pass manual validation checklist 100%

### 11.2 Production Quality Standards

**Code quality:**
- All scripts have error handling (`set -euo pipefail`)
- All error messages include remediation steps
- All hooks have emergency bypass mechanism
- All critical paths have unit tests

**Documentation quality:**
- Every script has header comment explaining purpose
- Every system-comp has clear examples
- Every message type has complete template
- Every failure scenario has recovery procedure

**Performance:**
- Bootstrap: <2 minutes
- Message delivery: <5 seconds
- Git operations: <3 seconds
- MCP operations: <1 second

---

## 12. Conclusion

This design provides a complete, production-ready multi-instance Claude Code orchestration system with:

✅ **Proven architecture** - Based on v1 patterns that work
✅ **Robust coordination** - Write locks prevent conflicts
✅ **Quality enforcement** - 7 gates ensure production-ready code
✅ **Graceful failure** - Recovery procedures for all scenarios
✅ **Day-1 readiness** - Complete testing and validation

**Key innovations:**
1. Write lock coordination (solves git conflicts)
2. Self-contained messages (prevents context explosion)
3. Modular bootstrap (validates each step)
4. Comprehensive failure recovery (production robustness)

**Implementation is ready to begin.**

---

**Document Status:** Complete - Ready for Implementation
**Next Step:** Phase 1 implementation (Foundation scripts)
**Estimated Time to Production:** 6 weeks
