# Project Spec v3: Multi-Instance Claude Code Orchestration
## With V1 Quality Gates & Enhanced Reliability

> **Status:** Complete Proof of Concept - V2 + V1 Integration + Reliability Improvements
> **Philosophy:** All 9 roles, 7 quality gates, SQLite messaging, human oversight
> **Goal:** Production-ready multi-instance orchestration with proven v1 discipline

---

## 1. What's New in V3

### 1.1 Inherited from V2 (Unchanged)

✅ **9 specialized roles** (Orchestrator, Librarian, Planner, Architect, Dev-A, Dev-B, QA-A, QA-B, Docs)
✅ **Unified toolset** (toolset.yaml) with extensible MCP servers, skills, hooks, agents
✅ **Feature isolation** (Git worktrees per feature)
✅ **Live documentation** (DocIntent before changes)
✅ **Auto-commit hook** (after QA + Docs approval)
✅ **System-comps** (reusable prompt fragments)

### 1.2 Added from V1

🆕 **7 Quality Gates** - Orchestrator enforces mandatory progression:
```
1. Spec Approved     → /spec skill
2. Tests First (TDD) → Write failing tests
3. Implementation    → Make tests pass
4. Refactored       → /pragmatist skill
5. Integrated       → Schema sync (OpenAPI → TypeScript)
6. E2E Verified     → /e2e-verify skill
7. Code Reviewed    → /validator skill
```

🆕 **TDD Enforcement** - `enforce-test-first` hook prevents:
- Committing implementation without tests
- Mixing tests + implementation in same commit

🆕 **Skills Library** - V1's 44 skills mapped to toolset.yaml:
- `/validator`, `/pragmatist`, `/spec`, `/gates`
- `/python`, `/react`, `/fastapi`, `/typescript`
- `/test`, `/debug`, `/logs`, `/sync`

🆕 **Issue Naming Convention** - 8 prefixes: [T#], [F#], [B#], [I#], [D#], [C#], [P#], [S#]

### 1.3 Reliability Improvements (New)

🔧 **SQLite Message Queue** (replaces tmux copy/paste + files)
- Atomic operations, no corruption
- Persistent, survives crashes
- Queryable for debugging
- Message history audit trail

🔧 **Human Oversight Dashboard**
- Terminal UI showing all 9 roles' status
- Real-time message flow visualization
- Cost and time tracking
- Manual intervention capability

🔧 **Cost Management**
- Per-message cost estimation
- Budget limits per feature ($20 default)
- Automatic alerts at 80%, halt at 95%
- Cost tracking in commits

🔧 **Failure Recovery**
- Automatic rollback to previous gate on errors
- Escalation to human after 3 conflicts
- Message deadlock detection
- Role timeout handling (2min)

---

## 2. Architecture

### 2.1 Nine Roles (From V2)

**Orchestrator** - Coordination hub
- Enforces 7 quality gates (new from v1)
- Assigns tasks to all 8 other roles
- Tracks cost and time budgets (new)
- Escalates to human on conflicts (new)

**Librarian** - Context provider
- Searches code, docs, ADRs
- Builds ContextPacks for all roles
- Maintains Serena knowledge base

**Planner** - Task breakdown
- Uses `/spec` skill from v1 (new)
- Creates sprint-style task plans
- Coordinates with Architect

**Architect** - Design decisions
- Handles architecture changes
- Produces ADR-ready material
- Coordinates with Librarian + Docs

**Dev-A, Dev-B** - Parallel implementation
- Follow TDD: tests before implementation (new from v1)
- Emit DocIntent before every change
- Self-validate with `/pragmatist` (new from v1)

**QA-A, QA-B** - Parallel quality assurance
- Validate against tests and spec
- Report via `QAResult` messages
- Use `/e2e-verify` skill (new from v1)

**Docs** - Live documentation
- Receives DocIntent from all roles
- Updates per-file docs, feature changelog
- Runs `/validator` for Gate 7 (new from v1)
- Signals `DocsUpdated` for auto-commit

### 2.2 Quality Gates Integration (New from V1)

The Orchestrator's state machine maps to v1's 7 gates:

```python
class OrchestratorStateMachine:
    GATES = {
        1: {"name": "SPEC", "skill": "spec", "roles": ["planner", "architect"]},
        2: {"name": "TEST", "skill": "enforce_test_first", "roles": ["dev_a", "dev_b"]},
        3: {"name": "IMPL", "skill": None, "roles": ["dev_a", "dev_b"]},
        4: {"name": "REFACTOR", "skill": "pragmatist", "roles": ["dev_a", "dev_b"]},
        5: {"name": "INTEGRATE", "skill": "sync", "roles": ["dev_a", "dev_b"]},
        6: {"name": "E2E", "skill": "e2e_verify", "roles": ["qa_a", "qa_b"]},
        7: {"name": "REVIEW", "skill": "validator", "roles": ["docs"]}
    }

    def can_advance(self, from_gate, to_gate):
        # V1 gate validation rules
        if to_gate == 3:  # IMPL
            # Must have committed tests in gate 2
            if not self.tests_committed():
                raise GateViolation("TDD: Tests must be committed before implementation")

        if to_gate == 7:  # REVIEW
            # Must have docs updated
            if not self.docs_updated():
                raise GateViolation("Docs must be updated before review")

        return True
```

**Gate Enforcement:**
- Orchestrator blocks gate advancement until validation passes
- TDD hook prevents commits that violate test-first
- Auto-commit only fires after Gate 7 complete

### 2.3 Message Passing (SQLite, New)

**V2 used:** tmux copy/paste + filesystem files
**V3 uses:** SQLite message queue

**Schema:**
```sql
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  from_role TEXT NOT NULL,
  to_role TEXT NOT NULL,
  msg_type TEXT NOT NULL,
  payload JSON NOT NULL,
  priority INTEGER DEFAULT 0,
  gate INTEGER,  -- Which quality gate this relates to
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP,
  processed_at TIMESTAMP,
  status TEXT DEFAULT 'pending'
);

CREATE TABLE gate_progress (
  feature_id TEXT,
  gate_number INTEGER,
  gate_name TEXT,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  validated_by TEXT,
  PRIMARY KEY (feature_id, gate_number)
);

CREATE TABLE cost_tracking (
  feature_id TEXT PRIMARY KEY,
  total_cost REAL DEFAULT 0,
  total_messages INTEGER DEFAULT 0,
  budget_limit REAL DEFAULT 20.0,
  started_at TIMESTAMP,
  completed_at TIMESTAMP
);

CREATE INDEX idx_to_role_status ON messages(to_role, status);
CREATE INDEX idx_gate ON messages(gate);
```

**Access:** All roles use filesystem MCP to read/write `.messages.db`

### 2.4 Tmux Layout (From V2, Unchanged)

```
┌────────────────────────────────────────────────┐
│  orchestrator (main window)                    │
├────────────────────────────────────────────────┤
│  librarian │  planner  │  architect            │
├────────────────────────────────────────────────┤
│  dev-a     │  dev-b    │  qa-a     │  qa-b     │
├────────────────────────────────────────────────┤
│  docs (full width)                             │
└────────────────────────────────────────────────┘
```

---

## 3. Unified Toolset (V2 + V1 Skills)

### 3.1 toolset.yaml Structure

```yaml
version: "3.0"

mcpServers:
  # From V2
  serena:
    type: http
    url: http://localhost:9121/mcp

  filesystem:
    type: local-fs
    root: ${FEATURE_WORKTREE}

  terminal:
    type: shell
    cwd: ${FEATURE_WORKTREE}

  git:
    type: git
    repo: ${FEATURE_WORKTREE}

  sqlite_messages:
    type: sqlite
    db: ${FEATURE_WORKTREE}/.messages.db

  playwright:
    type: browser
    endpoint: http://localhost:9123

  context7:
    type: context-service
    url: http://localhost:4000

  firecrawl:
    type: crawler
    api_key: ${FIRECRAWL_API_KEY}

skills:
  # V1 Skills (mapped)
  validator:
    description: "Code review agent (Gate 7)"
    source: v1
    gate: 7
    capability: code_review

  pragmatist:
    description: "Anti-over-engineering review (Gate 4)"
    source: v1
    gate: 4
    capability: refactor_check

  spec:
    description: "Specification wizard (Gate 1)"
    source: v1
    gate: 1
    capability: spec_generation

  gates:
    description: "Quality gate tracking"
    source: v1
    capability: gate_management

  e2e_verify:
    description: "End-to-end verification (Gate 6)"
    source: v1
    gate: 6
    capability: e2e_testing

  test:
    description: "Test runner and analyzer"
    source: v1
    capability: test_execution

  sync:
    description: "Schema synchronization (Gate 5)"
    source: v1
    gate: 5
    capability: schema_sync

  # V1 Tech Expert Skills
  python:
    source: v1
    capability: python_expert

  fastapi:
    source: v1
    capability: fastapi_expert

  react:
    source: v1
    capability: react_expert

  typescript:
    source: v1
    capability: typescript_expert

  # V2 Skills
  superpowers_brainstorming:
    server: serena
    capability: brainstorming

  superpowers_plan_writer:
    server: serena
    capability: plan_writer

  markdown_elementary:
    server: serena
    capability: elementary_markdown

  architecture_pattern_advisor:
    server: serena
    capability: architecture_patterns

hooks:
  # V2 Hooks
  feature_isolation:
    type: shell
    script: scripts/hooks/feature_isolation.sh
    trigger: session_start

  auto_commit:
    type: shell
    script: scripts/hooks/auto_commit.sh
    trigger: gate_7_complete
    validation:
      - qa_approved: true
      - docs_updated: true

  markdown_backup:
    type: shell
    script: scripts/hooks/markdown_backup.sh
    trigger: docs_updated

  serena_index_refresh:
    type: api
    target: serena
    endpoint: /refresh-index
    trigger: docs_updated

  # V1 Hooks (adapted)
  enforce_test_first:
    type: validation
    script: scripts/hooks/enforce_test_first.sh
    trigger: gate_2_to_3
    strict_mode: true

agents:
  # V2 Agents
  architecture_agent:
    server: serena
    capability: architecture_deep_review

  refactor_agent:
    server: serena
    capability: refactor_large

  security_agent:
    server: serena
    capability: security_review

qualityGates:
  # V1 Gates embedded in V3
  enforce: true
  strict_mode: true

  gates:
    - id: 1
      name: "SPEC"
      description: "Specification approved"
      skills: ["spec"]
      roles: ["planner", "architect"]
      required_messages: ["DocIntent"]
      validation: spec_exists

    - id: 2
      name: "TEST"
      description: "Tests written first (TDD - Red phase)"
      skills: ["test"]
      roles: ["dev_a", "dev_b"]
      required_files: ["**/test_*.py", "**/*.test.ts"]
      validation: enforce_test_first
      hook: enforce_test_first

    - id: 3
      name: "IMPL"
      description: "Implementation complete (Green phase)"
      roles: ["dev_a", "dev_b"]
      validation: tests_passing
      required_messages: ["QAResult"]

    - id: 4
      name: "REFACTOR"
      description: "Code refactored (SOLID principles)"
      skills: ["pragmatist"]
      roles: ["dev_a", "dev_b"]
      validation: pragmatist_approved

    - id: 5
      name: "INTEGRATE"
      description: "Schemas synced (OpenAPI → TypeScript)"
      skills: ["sync"]
      roles: ["dev_a", "dev_b"]
      validation: types_synced
      commands: ["make openapi", "make types"]

    - id: 6
      name: "E2E"
      description: "End-to-end verified"
      skills: ["e2e_verify"]
      roles: ["qa_a", "qa_b"]
      validation: e2e_tests_pass

    - id: 7
      name: "REVIEW"
      description: "Code reviewed and documented"
      skills: ["validator"]
      roles: ["docs"]
      required_messages: ["DocsUpdated"]
      validation: validator_approved
      trigger: auto_commit

costManagement:
  # New in V3
  enabled: true
  budget_per_feature: 20.00
  alert_threshold: 0.80
  halt_threshold: 0.95
  cost_per_1k_tokens:
    input: 0.003
    output: 0.015

humanOversight:
  # New in V3
  dashboard_enabled: true
  auto_escalate_conflicts: 3
  role_timeout_minutes: 2
  dashboard_refresh_seconds: 5
```

---

## 4. Git Workflow (V2 + V1 TDD)

### 4.1 Feature Isolation (From V2)

- Every feature creates `feature/xyz` branch + worktree
- All MCP servers rooted in worktree
- `main` is read-only

### 4.2 TDD Enforcement (From V1)

**Hook: `enforce_test_first.sh`**

```bash
#!/usr/bin/env bash
# From V1, adapted for V3 multi-instance

STRICT=${STRICT_TDD:-1}
CURRENT_GATE=$(sqlite3 .messages.db "SELECT gate_number FROM gate_progress WHERE feature_id='${FEATURE_ID}' ORDER BY started_at DESC LIMIT 1")

if [ "$CURRENT_GATE" = "2" ]; then
  # Gate 2: Only allow test files
  STAGED_FILES=$(git diff --cached --name-only)
  TEST_FILES=$(echo "$STAGED_FILES" | grep -E "test_.*\.py|.*\.test\.ts" || true)
  IMPL_FILES=$(echo "$STAGED_FILES" | grep -vE "test_.*\.py|.*\.test\.ts" || true)

  if [ -n "$IMPL_FILES" ]; then
    echo "❌ BLOCKED: Gate 2 (TEST) - Cannot commit implementation files"
    echo "TDD requires tests FIRST, implementation SECOND"
    echo ""
    echo "Implementation files staged:"
    echo "$IMPL_FILES"
    echo ""
    echo "Unstage with: git reset HEAD <file>"
    exit 1
  fi
fi

if [ "$CURRENT_GATE" = "3" ]; then
  # Gate 3: Implementation allowed only if tests committed
  TESTS_COMMITTED=$(git log --all --oneline --grep="Gate 2" | wc -l)
  if [ "$TESTS_COMMITTED" -eq 0 ]; then
    echo "❌ BLOCKED: Gate 3 (IMPL) - No tests found in Git history"
    echo "Must commit tests in Gate 2 before implementing in Gate 3"
    exit 1
  fi
fi

exit 0
```

### 4.3 Auto-Commit (V2 + V1 Gate Tracking)

**Triggered when:**
- Orchestrator state = Gate 7 (REVIEW)
- QA-A or QA-B sent `QAResult` with `status: PASS`
- Docs sent `DocsUpdated` with `ok_for_commit: true`

**Commit message format (from V1):**
```bash
git commit -m "feat(delete-user): add DELETE /users/{id} with cascade

- Added endpoint in api/routes/users.py
- Added tests in tests/test_users.py
- Updated docs/files/api_routes_users.md
- Updated docs/feature/delete-user.md

Quality Gates: 7/7 ✅
Gate 1: SPEC ✓
Gate 2: TEST ✓ (TDD enforced)
Gate 3: IMPL ✓
Gate 4: REFACTOR ✓ (Pragmatist approved)
Gate 5: INTEGRATE ✓ (Types synced)
Gate 6: E2E ✓ (QA-A validated)
Gate 7: REVIEW ✓ (Validator approved)

Cost: $8.32 | Messages: 47 | Time: 18m42s
Refs: #42"
```

---

## 5. Documentation Model (V2, Unchanged)

### 5.1 Three Layers

1. **Repo docs** - Per-file, feature, ADRs
2. **Markdown backup** - External mirror
3. **Serena/Memory** - Semantic search

### 5.2 Live Documentation via DocIntent

Same as V2, every code change requires DocIntent BEFORE the change.

---

## 6. Message Protocol (V3 Enhanced)

### 6.1 Core Message Types (V2 + New)

**From V2:**
- `ContextRequest` / `ContextPack`
- `PlanRequest` / `Plan`
- `TaskAssignment`
- `DocIntent` / `DocsAcknowledged` / `DocsUpdated`
- `QAResult`

**New in V3:**
- `GateAdvance` - Orchestrator advances to next gate
- `GateValidation` - Role validates gate completion
- `TDDViolation` - Hook reports TDD violation
- `CostAlert` - Budget threshold reached
- `ConflictEscalation` - Roles disagree, need human
- `HumanIntervention` - Human decision/override

### 6.2 Enhanced Message Templates

#### GateAdvance (New)
```json
{
  "msg_type": "GateAdvance",
  "from_role": "orchestrator",
  "to_role": "all",
  "payload": {
    "feature_id": "delete-user",
    "from_gate": 2,
    "from_gate_name": "TEST",
    "to_gate": 3,
    "to_gate_name": "IMPL",
    "validation": {
      "tests_committed": true,
      "tests_failing": true,
      "tdd_enforced": true,
      "docs_updated": true
    },
    "assigned_roles": ["dev_a", "dev_b"],
    "estimated_duration": "15min",
    "timestamp": "2025-11-15T21:00:00Z"
  }
}
```

#### TDDViolation (New)
```json
{
  "msg_type": "TDDViolation",
  "from_role": "enforce_test_first_hook",
  "to_role": "orchestrator",
  "payload": {
    "feature_id": "delete-user",
    "gate": 2,
    "violation_type": "implementation_before_tests",
    "blocked_files": ["api/routes/users.py"],
    "message": "Cannot commit implementation without tests",
    "severity": "critical"
  }
}
```

#### CostAlert (New)
```json
{
  "msg_type": "CostAlert",
  "from_role": "orchestrator",
  "to_role": "HUMAN",
  "payload": {
    "feature_id": "delete-user",
    "current_cost": 16.24,
    "budget_limit": 20.00,
    "percent_used": 81.2,
    "threshold": "alert",
    "messages_sent": 112,
    "time_elapsed": "42min",
    "recommendation": "Feature is 81% over budget. Consider simplifying or increasing limit."
  }
}
```

---

## 7. Human Oversight Dashboard (New in V3)

### 7.1 Terminal UI

**Implementation:** Python with `rich` library

```python
from rich.live import Live
from rich.layout import Layout
from rich.panel import Panel
from rich.table import Table

def build_dashboard(feature_id):
    layout = Layout()

    # Top: Feature status
    layout.split_column(
        Layout(name="header", size=3),
        Layout(name="roles", size=12),
        Layout(name="gates", size=10),
        Layout(name="messages", size=8),
        Layout(name="footer", size=3)
    )

    # Header
    header = Panel(
        f"[bold cyan]Feature:[/] {feature_id} | "
        f"[bold yellow]Gate:[/] 3/7 (IMPL) | "
        f"[bold green]Cost:[/] $8.32 / $20.00 | "
        f"[bold magenta]Time:[/] 18m42s",
        title="Multi-Instance Orchestration v3"
    )
    layout["header"].update(header)

    # Roles status
    roles_table = Table(title="Role Status")
    roles_table.add_column("Role", style="cyan")
    roles_table.add_column("Status", style="green")
    roles_table.add_column("Current Task")
    roles_table.add_column("Messages")

    roles_table.add_row("Orchestrator", "● ACTIVE", "Managing Gate 3", "47")
    roles_table.add_row("Librarian", "○ IDLE", "Awaiting ContextRequest", "12")
    roles_table.add_row("Planner", "✓ COMPLETE", "Plan delivered", "8")
    roles_table.add_row("Architect", "✓ COMPLETE", "ADR approved", "15")
    roles_table.add_row("Dev-A", "● WORKING", "Writing delete endpoint", "23")
    roles_table.add_row("Dev-B", "○ IDLE", "Awaiting assignment", "5")
    roles_table.add_row("QA-A", "○ WAITING", "Waiting for Dev-A", "3")
    roles_table.add_row("QA-B", "○ IDLE", "Awaiting assignment", "2")
    roles_table.add_row("Docs", "● WORKING", "Updating file docs", "18")

    layout["roles"].update(Panel(roles_table))

    # Quality Gates
    gates_table = Table(title="Quality Gates Progress")
    gates_table.add_column("Gate", style="cyan")
    gates_table.add_column("Status")
    gates_table.add_column("Validator")
    gates_table.add_column("Time")

    gates_table.add_row("1. SPEC", "✅ COMPLETE", "Planner", "3m12s")
    gates_table.add_row("2. TEST", "✅ COMPLETE", "TDD Hook", "5m45s")
    gates_table.add_row("3. IMPL", "🔄 IN PROGRESS", "Dev-A", "9m30s")
    gates_table.add_row("4. REFACTOR", "⏸ PENDING", "-", "-")
    gates_table.add_row("5. INTEGRATE", "⏸ PENDING", "-", "-")
    gates_table.add_row("6. E2E", "⏸ PENDING", "-", "-")
    gates_table.add_row("7. REVIEW", "⏸ PENDING", "-", "-")

    layout["gates"].update(Panel(gates_table))

    # Recent messages
    messages_table = Table(title="Recent Messages (Last 5)")
    messages_table.add_column("Time")
    messages_table.add_column("From → To")
    messages_table.add_column("Type")
    messages_table.add_column("Status")

    messages_table.add_row("21:15:32", "Dev-A → Docs", "DocIntent", "✓ Processed")
    messages_table.add_row("21:15:28", "Orchestrator → Dev-A", "TaskAssignment", "✓ Processed")
    messages_table.add_row("21:15:15", "Docs → Orchestrator", "DocsUpdated", "✓ Complete")
    messages_table.add_row("21:14:52", "QA-A → Orchestrator", "QAResult", "✓ Complete")
    messages_table.add_row("21:14:30", "Dev-A → QA-A", "ReadyForQA", "✓ Complete")

    layout["messages"].update(Panel(messages_table))

    # Footer - Controls
    footer = Panel(
        "[P]ause All | [R]esume | [I]ntervene | [G]ate Status | [C]ost Detail | [Q]uit",
        style="bold blue"
    )
    layout["footer"].update(footer)

    return layout

# Main dashboard loop
with Live(build_dashboard(feature_id), refresh_per_second=0.2) as live:
    while True:
        live.update(build_dashboard(feature_id))
        time.sleep(5)
```

### 7.2 Human Intervention

**Pause all roles:**
```bash
# User presses 'P' in dashboard
→ Send HumanIntervention message to Orchestrator
→ Orchestrator broadcasts PauseAll to all roles
→ Roles stop processing messages
→ Dashboard shows "⏸ PAUSED - Human intervention"
```

**Manual message injection:**
```bash
# User presses 'I' in dashboard
→ Prompt for: to_role, msg_type, payload
→ Insert into messages table with from_role='HUMAN'
→ Resume roles
```

---

## 8. Cost Management (New in V3)

### 8.1 Cost Tracking

**Per-message estimation:**
```python
def estimate_cost(msg):
    # Rough token estimation
    payload_size = len(json.dumps(msg['payload']))
    input_tokens = payload_size / 4
    output_tokens = 500  # average response

    cost = (
        (input_tokens / 1000) * 0.003 +
        (output_tokens / 1000) * 0.015
    )

    # Update feature cost
    update_cost(msg['feature_id'], cost)
    return cost
```

**Budget enforcement:**
```python
def check_budget(feature_id):
    cost = get_total_cost(feature_id)
    limit = get_budget_limit(feature_id)

    if cost > limit * 0.95:
        send_message({
            "msg_type": "CostExceeded",
            "to_role": "HUMAN",
            "payload": {"cost": cost, "limit": limit}
        })
        halt_all_roles(feature_id)

    elif cost > limit * 0.80:
        send_message({
            "msg_type": "CostAlert",
            "to_role": "HUMAN",
            "payload": {"cost": cost, "limit": limit, "percent": cost/limit}
        })
```

### 8.2 Cost in Commits

Every auto-commit includes cost metadata:
```
Cost: $8.32 | Messages: 47 | Time: 18m42s
```

---

## 9. Failure Recovery (New in V3)

### 9.1 Rollback to Previous Gate

```python
def rollback_gate(feature_id, to_gate):
    # 1. Find last commit for target gate
    last_commit = get_gate_commit(feature_id, to_gate)

    # 2. Git reset
    git_reset(last_commit)

    # 3. Clear messages for current gate
    delete_messages(feature_id, current_gate)

    # 4. Update gate progress
    update_gate_progress(feature_id, to_gate)

    # 5. Notify all roles
    broadcast({
        "msg_type": "GateRollback",
        "payload": {"feature_id": feature_id, "to_gate": to_gate}
    })
```

### 9.2 Conflict Escalation

```python
def handle_conflict(feature_id, issue):
    conflict_count = get_conflict_count(feature_id, issue)

    if conflict_count >= 3:
        # Escalate to human
        send_message({
            "msg_type": "ConflictEscalation",
            "to_role": "HUMAN",
            "payload": {
                "issue": issue,
                "roles_involved": issue.roles,
                "history": get_message_history(issue)
            }
        })
        pause_all_roles(feature_id)

        # Wait for human decision
        decision = await_human_decision()

        if decision.action == "rollback":
            rollback_gate(feature_id, decision.to_gate)
        elif decision.action == "override":
            force_gate_advance(feature_id, decision.to_gate)

        resume_all_roles(feature_id)
```

---

## 10. System-Comps (V2 + V1 Integration)

### 10.1 V1 Gate Enforcement Comp

```markdown
# system-comps/quality_gates.md

This project enforces 7 mandatory quality gates:

1. **SPEC** - Specification approved (use /spec skill)
2. **TEST** - Tests written FIRST (TDD enforced by hook)
3. **IMPL** - Implementation complete (tests must pass)
4. **REFACTOR** - Code cleaned (use /pragmatist skill)
5. **INTEGRATE** - Schemas synced (make openapi && make types)
6. **E2E** - End-to-end verified (use /e2e-verify skill)
7. **REVIEW** - Code reviewed (use /validator skill)

You CANNOT skip gates. You CANNOT go backwards except via Orchestrator rollback.

Current gate: {CURRENT_GATE}
You may only work on tasks for the current gate.
```

### 10.2 V1 TDD Enforcement Comp

```markdown
# system-comps/tdd_enforcement.md

You MUST follow Test-Driven Development:

**Gate 2 (TEST):**
- Write FAILING tests first
- Commit tests ONLY (no implementation)
- Tests should fail when run

**Gate 3 (IMPL):**
- Implement code to make tests pass
- Tests committed in Gate 2 must now pass
- Can only proceed if tests are green

**Hook Enforcement:**
The enforce_test_first hook will BLOCK commits that:
- Mix tests and implementation
- Commit implementation without prior test commits

**Emergency Bypass:**
STRICT_TDD=0 git commit (NOT RECOMMENDED - only for emergencies)
```

### 10.3 V1 Skills Comp

```markdown
# system-comps/v1_skills.md

You have access to these V1 skills via toolset.yaml:

**Quality Gates:**
- /spec - Specification wizard (Gate 1)
- /validator - Code review agent (Gate 7)
- /pragmatist - Anti-over-engineering review (Gate 4)
- /gates - Gate status and management
- /e2e-verify - End-to-end verification (Gate 6)

**Development:**
- /test - Test runner and analyzer
- /sync - Schema synchronization (Gate 5)
- /debug - Debugging assistant
- /logs - Log viewer

**Tech Experts:**
- /python, /fastapi, /pydantic - Python stack
- /react, /typescript, /zustand - React stack

Reference these by ID when Orchestrator assigns tasks.
```

---

## 11. Bootstrap Script (V2 + V3 Enhancements)

### 11.1 bootstrap_v3.sh

```bash
#!/bin/bash
set -e

FEATURE=${1:-"unnamed-feature"}

echo "🚀 Bootstrapping Multi-Instance v3: $FEATURE"

# 1. Git isolation (V2)
echo "📂 Creating feature worktree..."
./scripts/setup_feature_git.sh "$FEATURE"
WORKTREE="../wt-$FEATURE"

# 2. SQLite message queue (V3)
echo "💬 Initializing SQLite message queue..."
cat > "$WORKTREE/.messages.db.sql" <<'EOF'
CREATE TABLE messages (...);
CREATE TABLE gate_progress (...);
CREATE TABLE cost_tracking (...);
CREATE INDEX idx_to_role_status ON messages(to_role, status);
EOF
sqlite3 "$WORKTREE/.messages.db" < "$WORKTREE/.messages.db.sql"

# 3. Initialize gate tracking (V1 integration)
echo "🎯 Initializing quality gates..."
sqlite3 "$WORKTREE/.messages.db" <<EOF
INSERT INTO gate_progress (feature_id, gate_number, gate_name, started_at)
VALUES ('$FEATURE', 1, 'SPEC', datetime('now'));

INSERT INTO cost_tracking (feature_id, budget_limit)
VALUES ('$FEATURE', 20.0);
EOF

# 4. Template toolset.yaml (V2)
echo "🔧 Configuring toolset..."
export FEATURE_WORKTREE="$WORKTREE"
export FEATURE_ID="$FEATURE"
envsubst < toolset.yaml.template > "$WORKTREE/.toolset.yaml"

# 5. Build prompts (V2 + V1 comps)
echo "📝 Assembling prompts..."
python3 scripts/build_prompt.py \
  --feature "$FEATURE" \
  --gate 1 \
  --include-v1-comps \
  --output "$WORKTREE/.prompts"

# 6. Launch tmux with 9 roles (V2)
echo "🖥️  Starting tmux session..."
tmux new-session -d -s "claude-$FEATURE" -n orchestrator

# Orchestrator pane
tmux send-keys -t "claude-$FEATURE:orchestrator" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/orchestrator.md)\"" C-m

# Core roles window
tmux new-window -t "claude-$FEATURE" -n core
tmux split-window -h -t "claude-$FEATURE:core"
tmux split-window -h -t "claude-$FEATURE:core"

tmux send-keys -t "claude-$FEATURE:core.0" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/librarian.md)\"" C-m
tmux send-keys -t "claude-$FEATURE:core.1" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/planner.md)\"" C-m
tmux send-keys -t "claude-$FEATURE:core.2" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/architect.md)\"" C-m

# Implementation window
tmux new-window -t "claude-$FEATURE" -n impl
tmux split-window -h -t "claude-$FEATURE:impl"
tmux split-window -h -t "claude-$FEATURE:impl.0"
tmux split-window -h -t "claude-$FEATURE:impl.1"

tmux send-keys -t "claude-$FEATURE:impl.0" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/dev_a.md)\"" C-m
tmux send-keys -t "claude-$FEATURE:impl.1" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/dev_b.md)\"" C-m
tmux send-keys -t "claude-$FEATURE:impl.2" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/qa_a.md)\"" C-m
tmux send-keys -t "claude-$FEATURE:impl.3" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/qa_b.md)\"" C-m

# Docs window
tmux new-window -t "claude-$FEATURE" -n docs
tmux send-keys -t "claude-$FEATURE:docs" \
  "cd $WORKTREE && claude code --mcp-config .toolset.yaml --system \"\$(cat .prompts/docs.md)\"" C-m

# 7. Launch dashboard (V3)
echo "📊 Starting dashboard..."
gnome-terminal -- python3 scripts/dashboard.py "$FEATURE" &

# 8. Attach to orchestrator
echo "✅ V3 ready with 9 roles + 7 quality gates!"
sleep 2
tmux select-window -t "claude-$FEATURE:orchestrator"
tmux attach-session -t "claude-$FEATURE"
```

---

## 12. Summary: What V3 Includes

### From V2 (Unchanged)
✅ 9 roles (Orchestrator, Librarian, Planner, Architect, Dev-A/B, QA-A/B, Docs)
✅ Unified toolset (toolset.yaml)
✅ Feature isolation (Git worktrees)
✅ Live documentation (DocIntent)
✅ Auto-commit hook
✅ System-comps (prompt assembly)

### From V1 (Integrated)
🆕 7 Quality Gates (enforced by Orchestrator)
🆕 TDD Enforcement (enforce_test_first hook)
🆕 44 Skills (mapped to toolset.yaml)
🆕 Issue Naming Convention ([T#], [F#], etc.)

### New in V3
🔧 SQLite message queue (reliable, persistent)
🔧 Human oversight dashboard (terminal UI)
🔧 Cost management (budget limits, alerts)
🔧 Failure recovery (rollback, escalation)
🔧 Message types for gates (GateAdvance, TDDViolation, etc.)

---

## 13. Usage Example

```bash
# Start feature
./scripts/bootstrap_v3.sh delete-user

# User in Orchestrator pane:
User: Add DELETE /users/{id} endpoint with cascade delete

# Orchestrator coordinates all 9 roles through 7 gates:
# Gate 1: SPEC (Planner + Architect)
# Gate 2: TEST (Dev-A writes tests, TDD enforced)
# Gate 3: IMPL (Dev-A implements, QA-A validates)
# Gate 4: REFACTOR (Dev-A uses /pragmatist)
# Gate 5: INTEGRATE (Dev-A runs make types)
# Gate 6: E2E (QA-A uses /e2e-verify)
# Gate 7: REVIEW (Docs uses /validator)

# Auto-commit fires after Gate 7
# Commit includes: cost, time, all 7 gates status

# Dashboard shows:
# - All 9 roles' current tasks
# - Gate progress: 7/7 ✅
# - Cost: $12.45 / $20.00
# - Time: 24m15s
# - Messages: 89

# Feature complete! 🎉
```

---

**V3 is production-ready: V2's vision + V1's discipline + reliability improvements**
