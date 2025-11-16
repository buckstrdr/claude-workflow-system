# Project Spec (PoC): Multi-Instance Claude Code Orchestration with Quality Enforcement

> **Status:** Proof of Concept (PoC) v3 – Complete design integrating multi-instance architecture with production-grade quality enforcement.
> **Based on:** v2 architecture + v1 quality enforcement mechanisms
> **Important:** Any lists of MCP servers, skills, hooks, plugins, or agents in this document are **illustrative, not exhaustive**. The architecture must support adding, removing, or swapping tools without structural changes.
> **Goal:** Build this once, with all behaviours included from day one, with **enforced quality at every step**.

---

## 1. Context

We want a **multi-instance Claude Code development environment** where:

- Each **role** (Orchestrator, Librarian, Planner, Architect, Dev-A, Dev-B, QA-A, QA-B, Docs) runs in its **own tmux pane/window**.
- All instances share a **single unified toolset** consisting of (non-exhaustive):
  - MCP servers & tools (e.g. Serena, filesystem, terminal, git, Puppeteer/Playwright, Context 7, Firecrawl, etc.).
  - **Skills** (e.g. Superpowers Brainstorming, Superpowers Plan Writer, validation skills, architecture skills).
  - **Plugins**.
  - **Hooks** (feature isolation, auto-commit, quality gates, TDD enforcement, UI verification, doc/memory sync, etc.).
  - **Specialist agents** (architecture agent, refactor agent, security agent, etc.).

The actual set of MCP servers, skills, hooks, plugins, and agents is expected to **evolve over time**; this spec defines how they are wired and orchestrated, not a fixed menu.

The **Orchestrator instance** is the single "brain" that:

- Knows **what tools/skills/hooks/agents exist** (by symbolic ID, not by reading all configs at once).
- Decides **which roles use which tools** for each task.
- Coordinates the work of all other instances.
- **Enforces quality gates** throughout the workflow.

Hard, non-negotiable constraints:

- **Git Safety**
  - All work happens in a **feature-isolated branch or Git worktree**.
  - No role ever touches `main` directly until an explicit merge.
  - An **auto-commit service** runs continuously (30-second intervals), creating automatic commits with rollback capability.
  - An **auto-commit hook** ensures that after each coherent change (code + tests + docs), a descriptive commit is created.

- **Quality Gate Enforcement (NEW in v3)**
  - Every feature MUST progress through **7 mandatory quality gates**.
  - Gates are **tracked persistently** in `.git/quality-gates/<feature>/`.
  - **Pre-push hooks block** merging to main without Gate 7 (Code Reviewed) completion.
  - **TDD is enforced** at the git level – implementation cannot be committed before tests.
  - **UI changes require Playwright verification** at 1920x1080 resolution.

- **Live Canonical Documentation**
  - Every code file has a **paired markdown "file doc"** that is the canon for that file.
  - Every feature has its own **feature changelog doc**.
  - Documentation is updated **live**; the Docs role learns about changes **before** they happen via `DocIntent`, not by reverse-engineering diffs.
  - Documentation is mirrored to:
    - Markdown in the repo.
    - A markdown backup store.
    - Serena (or equivalent) as a long-term memory layer.

- **Context Hygiene**
  - System prompts remain **compact and role-focused**.
  - Toolset configs (MCP servers, skills, hooks, agents) live **outside the context window** in files like `toolset.yaml`.
  - Roles refer to tools by **short IDs** (`superpowers_brainstorming`, `auto_commit`, `feature_isolation`, etc.), and only load detailed docs **on demand**.

---

## 2. Objectives (All Required)

All objectives below are **mandatory features** of this PoC.

- **O-01: Multi-instance Claude orchestration in tmux**
  A single tmux session hosts named panes/windows for each role (Orchestrator, Librarian, Planner, Architect, Dev-A, Dev-B, QA-A, QA-B, Docs), with a predictable layout.

- **O-02: Unified toolset shared across all instances**
  A central config (`toolset.yaml`) defines MCP servers, skills, hooks, plugins, and agents; every Claude Code instance uses this same config. The architecture must allow **adding new MCP servers, skills, hooks, plugins, and agents** without changing role prompts or tmux layout.

- **O-03: Orchestrator-driven tool/skill/hook/agent usage**
  The Orchestrator knows the toolset by symbolic ID and **explicitly instructs** each role which tools/skills/hooks/agents to use for a given task, including any future tools that may be added.

- **O-04: Safe Git workflow with automatic feature isolation**
  On startup for a new feature, hooks create and enforce a **feature branch or Git worktree**, ensuring main is untouched until an explicit merge step.

- **O-05: Auto-commit service with rollback**
  A systemd user service runs continuously, auto-committing changes every 30 seconds to backend/frontend code. Bash aliases (`undo`, `undo!`, `goback N`) provide fine-grained rollback capability.

- **O-06: Auto-commit hook after meaningful changes**
  An auto-commit hook creates small, descriptive commits after each coherent slice of work (code + tests + docs), triggered by Orchestrator when QA+Docs confirm readiness.

- **O-07: 7-Stage Quality Gate System (NEW)**
  Every feature MUST progress through 7 mandatory gates:
  1. Spec Approved
  2. Tests First (TDD)
  3. Implementation Complete
  4. Refactored
  5. Integrated
  6. E2E Verified
  7. Code Reviewed

  Gates are tracked in `.git/quality-gates/<feature>/` and enforced by git hooks.

- **O-08: TDD Enforcement at Git Level (NEW)**
  Pre-commit hook enforces test-first development:
  - Tests must be committed BEFORE implementation
  - Cannot commit tests + implementation together
  - `STRICT_TDD=1` blocks violations

- **O-09: UI Verification Enforcement (NEW)**
  Frontend changes require Playwright verification:
  - Pre-commit hook detects UI changes
  - Requires Playwright MCP usage evidence
  - Enforces 1920x1080 resolution
  - Requires screenshot artifacts
  - `STRICT_UI=1` blocks commits without verification

- **O-10: Quality Validation Skills (NEW)**
  Three validation skills run automatically:
  - `/validator` - Task completion validation (Gate 7)
  - `/pragmatist` - Anti-over-engineering check (Gate 4)
  - `/karen` - Brutal honesty reality check (milestones/releases)

- **O-11: Live canonical documentation per file and feature**
  Every code file has a canonical markdown doc; every feature has a changelog. Changes are documented **as they happen**, driven by `DocIntent` messages from roles.

- **O-12: Integrated memory and markdown backup**
  Documentation and design knowledge are mirrored to:
  - Repo docs (per-file, feature, ADRs, changelog).
  - A markdown backup location.
  - Serena (or similar) as a searchable memory service.

- **O-13: Architecture Council role for major design work**
  An Architect role is the first port of call for large design/architecture changes, producing ADR-ready material and coordinating with Librarian & Docs.

- **O-14: Superpowers 3-Step Workflow Integration (NEW)**
  Complex features follow mandatory workflow:
  1. `/superpowers:brainstorm` - Socratic refinement of ideas
  2. `/superpowers:write-plan` - Detailed PRD with sprints
  3. `/superpowers:execute-plan` - Batch execution with review checkpoints

- **O-15: System prompt composition ("system-comps")**
  Role prompts are assembled from reusable prompt fragments (system-comps) under version control, ensuring consistent policies across roles (TDD, DocIntent, hooks, tool usage, quality gates).

- **O-16: Strict Mode Progressive Enforcement (NEW)**
  Environment variables control enforcement levels:
  - `STRICT_HOOKS=1` - Enforce all hooks (block on fail)
  - `STRICT_TDD=1` - Enforce test-first development
  - `STRICT_UI=1` - Enforce UI verification
  - Can be disabled for emergencies (with appropriate warnings)

- **O-17: MCP Lifecycle Management (NEW)**
  Bootstrap script includes MCP server management:
  - Verifies MCP servers running before instance launch
  - Provides commands: `mcp-start`, `mcp-stop`, `mcp-status`, `mcp-logs`
  - Handles MCP failures gracefully

- **O-18: Workflow Visibility System (NEW)**
  Workflow reminders keep quality gates visible:
  - Session-start hook displays workflow overview
  - Post-checkout hook shows gate workflow
  - Orchestrator pane displays current gate status

- **O-19: Bootstrap script to spin everything up**
  A script creates the tmux layout, sets up the feature Git branch/worktree and hooks, assembles system prompts from system-comps, verifies MCP servers, launches all Claude instances with the unified toolset, and attaches to the Orchestrator pane.

---

## 3. High-Level Architecture

### 3.1 Components

- **tmux Session (per feature)**
  One session per feature (e.g. `claude-feature-xyz`), containing windows/panes:

  - `orchestrator` (single pane).
  - `core-roles` window with panes: `librarian`, `planner`, `architect`.
  - `implementation` window with panes: `dev-a`, `dev-b`, `qa-a`, `qa-b`.
  - `docs` window with pane: `docs`.
  - Optional: `tests`, `git` windows for human use.

- **Claude Code Instances (roles)**
  Each pane runs a Claude Code CLI instance with:

  - A **role-specific system prompt** assembled from system-comps.
  - The **same MCP config** (`toolset.yaml`), exposing the unified toolset.
  - Role-specific behaviour (Orchestrator, Librarian, Planner, Architect, Dev, QA, Docs).

- **Unified Toolset Layer**
  Defined in `toolset.yaml` and associated hook scripts/skill docs. Includes, but is not limited to:

  - MCP servers: Serena, filesystem, terminal, git, Puppeteer/Playwright, Context 7, Firecrawl, etc.
    Additional MCP servers can be added at any time, provided they are registered in `toolset.yaml`.
  - Skills: superpowers_brainstorming, superpowers_plan_writer, superpowers_execute_plan, validator, pragmatist, karen, markdown_elementary, ui_verify, etc.
    Additional skills can be added without changing the architecture; Orchestrator just references new IDs.
  - Hooks: feature_isolation, auto_commit, auto_commit_service, quality_gates_check, enforce_test_first, enforce_ui_verification, markdown_backup, serena_index_refresh, session_start, post_checkout_reminder, etc.
    Additional hooks may be created for other lifecycle events (e.g. post-merge, security scan, metrics).
  - Agents: architecture_agent, refactor_agent, security_agent, etc.
    Further specialist agents can be plugged in as needed.

- **Message Board (shared files)**
  A simple `messages/` directory storing inbox/outbox markdown files for each role, allowing structured, persistent cross-role communications that tools can read/write via filesystem MCP.

- **Git Repository & Feature Worktree**
  The codebase is in a Git repo. Each feature run creates either:

  - A feature branch; and/or
  - A dedicated Git worktree rooted on that branch;

  and all file operations occur in that worktree.

- **Quality Gates Tracking (NEW)**
  Persistent tracking in `.git/quality-gates/<feature>/`:
  - `status.json` - Current gate and overall status
  - `gate_1_spec.status` through `gate_7_review.status` - Individual gate completion
  - `started_at.txt`, `completed_at.txt` - Timestamps
  - `notes.md` - Optional notes and decisions

---

## 4. Unified Toolset & MCP Topology

### 4.1 `toolset.yaml` (Conceptual)

`toolset.yaml` defines all MCP servers, skills, hooks, and agents. The following is an **example configuration**, not a complete or fixed list:

```yaml
mcpServers:
  serena:
    type: http
    url: http://localhost:3001

  filesystem:
    type: local-fs
    root: /path/to/feature-worktree

  terminal:
    type: shell
    cwd: /path/to/feature-worktree

  git:
    type: git
    repo: /path/to/feature-worktree

  playwright:
    type: browser
    endpoint: http://localhost:9222

  context7:
    type: context-service
    url: http://localhost:4000

  firecrawl:
    type: crawler
    url: http://localhost:5000

skills:
  # Superpowers workflow skills
  superpowers_brainstorming:
    server: serena
    capability: brainstorming
    when: "Complex features requiring design refinement"

  superpowers_plan_writer:
    server: serena
    capability: plan_writer
    when: "After brainstorming, before implementation"

  superpowers_execute_plan:
    server: serena
    capability: execute_plan
    when: "Executing implementation plans in batches"

  # Quality validation skills
  validator:
    server: serena
    capability: task_validation
    when: "Gate 7 - Code Review"
    automatic: true

  pragmatist:
    server: serena
    capability: anti_over_engineering
    when: "Gate 4 - Refactoring"
    automatic: true

  karen:
    server: serena
    capability: reality_check
    when: "Milestones and releases"
    automatic: false

  # UI verification
  ui_verify:
    server: serena
    capability: ui_verification
    when: "After frontend changes"
    automatic: true
    requires:
      - playwright
      - resolution: "1920x1080"

  # Other skills
  markdown_elementary:
    server: serena
    capability: elementary_markdown

  architecture_pattern_advisor:
    server: serena
    capability: architecture_patterns

  master_demonstrator_writer:
    server: serena
    capability: master_demonstrator

hooks:
  # Git workflow hooks
  feature_isolation:
    type: shell
    script: scripts/hooks/feature_isolation.sh
    trigger: bootstrap

  auto_commit:
    type: shell
    script: scripts/hooks/auto_commit.sh
    trigger: orchestrator_command

  auto_commit_service:
    type: systemd
    service: auto-commit-watch
    interval: 30s
    provides:
      - undo
      - undo!
      - goback

  # Quality enforcement hooks
  quality_gates_check:
    type: shell
    script: scripts/hooks/quality_gates_check.sh
    trigger: pre-push
    blocks: true
    requires: gate_7_passed

  enforce_test_first:
    type: shell
    script: scripts/hooks/enforce_test_first.sh
    trigger: pre-commit
    blocks: true
    env: STRICT_TDD

  enforce_ui_verification:
    type: shell
    script: scripts/hooks/enforce_ui_verification.sh
    trigger: pre-commit
    blocks: true
    env: STRICT_UI
    requires:
      - playwright_evidence
      - resolution_1920x1080
      - screenshot_artifacts

  # Documentation hooks
  markdown_backup:
    type: shell
    script: scripts/hooks/markdown_backup.sh
    trigger: post-commit

  serena_index_refresh:
    type: api
    target: serena
    endpoint: /refresh-index
    trigger: post-commit

  # Session hooks
  session_start:
    type: shell
    script: scripts/hooks/session_start.sh
    trigger: session-start
    displays:
      - workflow_reminder
      - superpowers_first_message

  post_checkout_reminder:
    type: shell
    script: scripts/hooks/post_checkout_reminder.sh
    trigger: post-checkout
    displays:
      - quality_gate_workflow

agents:
  architecture_agent:
    server: serena
    capability: architecture_deep_review

  refactor_agent:
    server: serena
    capability: refactor_large

  security_agent:
    server: serena
    capability: security_review
```

Implementation MUST allow:

- Adding new `mcpServers`, `skills`, `hooks`, and `agents` entries over time.
- Orchestrator and roles referring to these by symbolic ID without changes to core orchestration.

All Claude instances are launched with:

```bash
claude code --mcp-config toolset.yaml --system "<assembled role prompt>"
```

This ensures:

- Same **servers and tools** for every role.
- Filesystem, terminal, and git tools are rooted in the **feature worktree**.

### 4.2 Shared but Not Dumped into Context

- The contents of `toolset.yaml` **never** get dumped wholesale into prompts.
- Roles only see **tool IDs and categories** in their prompts (e.g. "You may be told to use `superpowers_brainstorming` or `auto_commit`.").
- Detailed usage semantics live in separate markdown cards in `tools/` and are loaded only when needed.

---

## 5. Quality Gate System (NEW in v3)

### 5.1 The 7 Mandatory Gates

Every feature MUST progress through these gates in order:

**Gate 1: Spec Approved**
- Specification file exists (e.g. `.ian/spec_<feature>.md`)
- All required sections complete
- User has approved spec
- Can use `/superpowers:brainstorm` → `/superpowers:write-plan` workflow
- Status field = "Approved"

**Gate 2: Tests First (TDD)**
- Tests written BEFORE implementation code
- Tests reflect success criteria from spec
- Tests are FAILING (Red phase)
- No implementation code exists yet
- Pre-commit hook enforces this

**Gate 3: Implementation Complete**
- All tests now PASSING (Green phase)
- Success criteria from spec are met
- No TODOs in production code
- No debug statements

**Gate 4: Refactored**
- Code follows DRY principles
- SOLID principles applied
- Function/class names clear
- Tests still passing
- `/pragmatist` skill runs automatically

**Gate 5: Integrated**
- OpenAPI spec regenerated (if backend changes)
- Frontend types synced (if API changes)
- Code graphs updated
- Semantic index updated
- Documentation updated

**Gate 6: E2E Verified**
- Backend starts successfully
- Frontend builds and loads
- API endpoints respond
- Feature-specific tests pass
- No runtime errors
- If UI changes: `/ui-verify` passed at 1920x1080

**Gate 7: Code Reviewed**
- `/validator` agent review completed
- All CRITICAL issues addressed
- All HIGH PRIORITY issues addressed
- Production readiness confirmed

### 5.2 Gate Tracking Storage

Gates tracked in `.git/quality-gates/<feature_name>/`:

```
.git/quality-gates/
  <feature_name>/
    status.json              # Current gate, overall status
    gate_1_spec.status       # PASSED or PENDING
    gate_2_tests.status      # PASSED or PENDING
    gate_3_impl.status       # PASSED or PENDING
    gate_4_refactor.status   # PASSED or PENDING
    gate_5_integration.status # PASSED or PENDING
    gate_6_e2e.status        # PASSED or PENDING
    gate_7_review.status     # PASSED or PENDING
    started_at.txt           # ISO timestamp
    completed_at.txt         # ISO timestamp (when gate 7 passed)
    notes.md                 # Optional notes
```

### 5.3 Gate Management Scripts

```bash
# Start tracking new feature
scripts/quality-gates/gates-start.sh <feature_name>

# Check current gate status
scripts/quality-gates/gates-check.sh <feature_name>

# Advance to next gate (validates requirements first)
scripts/quality-gates/gates-pass.sh <feature_name>

# View all features
scripts/quality-gates/gates-status.sh
```

### 5.4 Gate Enforcement

**Pre-push hook (`quality_gates_check.sh`)**:
- Checks if pushing to main/master
- Verifies Gate 7 is PASSED
- Blocks push if Gate 7 not complete (when `STRICT_HOOKS=1`)
- Warns about incomplete gates

**Integration with Orchestrator**:
- Orchestrator tracks current gate for feature
- Explicitly tells roles which gate they're working toward
- Coordinates gate advancement with all roles
- Only triggers auto-commit hook after gate requirements met

---

## 6. Git Workflow & Hooks

### 6.1 Feature Isolation Hook (`feature_isolation`)

**Purpose:** Guarantee all work happens in a feature-isolated branch/worktree, not on main.

- On start of a feature run (`bootstrap_tmux.sh feature-xyz`):
  - `scripts/setup_feature_git.sh` is invoked (directly or via `feature_isolation` hook).
  - It creates a new branch `feature/xyz` and corresponding worktree, e.g. `../wt-feature-xyz`.
  - Initializes quality gate tracking: `scripts/quality-gates/gates-start.sh feature-xyz`
  - `toolset.yaml` is rewritten/templated so:
    - `filesystem.root`, `terminal.cwd`, and `git.repo` point at the feature worktree.
- All file operations by all roles happen in that worktree; `main` is read-only.

### 6.2 Auto-Commit Service (`auto_commit_service`)

**Purpose:** Continuous safety net with fine-grained rollback.

- **Implementation:** Systemd user service (`auto-commit-watch.service`)
- **Behavior:**
  - Watches `backend/` and `frontend/` directories
  - Auto-commits every 30 seconds if changes detected
  - Commit format: `Auto-commit: YYYY-MM-DD HH:MM:SS`
  - Ignores: `.serena/`, `dev/`, `docs/`, `data/`, `.ian/`

- **Rollback commands (bash aliases):**
  ```bash
  undo        # Roll back last commit (keep changes)
  undo!       # Roll back last commit (discard changes)
  goback 3    # Go back 3 commits (keep changes)
  goback! 3   # Go back 3 commits (discard changes)
  ```

- **Pre-push warning:**
  - Pre-push hook detects auto-commits
  - Warns user to squash before pushing
  - Suggests: `git rebase -i origin/main`

### 6.3 Auto-Commit Hook (`auto_commit`)

**Purpose:** Descriptive commits after coherent slices of work.

- Triggered only when Orchestrator decides a slice is complete:
  - QA returns `QAResult` with `Status: PASS`.
  - Docs sends `DocsUpdated` with `OK for Auto-Commit: YES`.
  - Current gate requirements met.

- The hook:
  - Uses git MCP (or shell) to:
    - Stage relevant files.
    - Use a structured commit message (e.g. `feat: add delete_user endpoint (Gate 3 - DEV-001)`).
  - Optionally tags the commit with feature name / task IDs / gate number.

- No role is allowed to run `git commit` directly; only hooks (service or orchestrator-triggered) may commit.

### 6.4 TDD Enforcement Hook (`enforce_test_first`)

**Purpose:** Make test-first development structurally required.

- **Trigger:** Pre-commit
- **Behavior:**
  - Detects if implementation files are staged
  - Checks if corresponding test files exist and are committed
  - Blocks commit if implementation staged without prior test commit
  - Blocks commit if tests and implementation staged together

- **Environment variable:** `STRICT_TDD=1` (default: 1)
  - `STRICT_TDD=1` - Blocks violations
  - `STRICT_TDD=0` - Warns only (emergency bypass)

- **Example enforcement:**
  ```bash
  # BLOCKED: Committing implementation without tests
  git add backend/services/order_service.py
  git commit -m "feat: add order service"
  > ERROR: STRICT_TDD=1 requires tests before implementation
  > No test file found for backend/services/order_service.py
  > Expected: backend/tests/test_order_service.py

  # CORRECT: Tests first, then implementation
  git add backend/tests/test_order_service.py
  git commit -m "test: add order service tests"
  git add backend/services/order_service.py
  git commit -m "feat: implement order service"
  ```

### 6.5 UI Verification Enforcement Hook (`enforce_ui_verification`)

**Purpose:** Ensure frontend changes are visually verified before commit.

- **Trigger:** Pre-commit
- **Behavior:**
  - Detects if frontend files modified (`frontend/src/components/**/*.{tsx,ts,jsx,js}`, `**/*.{css,scss}`)
  - Checks for Playwright MCP usage evidence in recent session
  - Verifies 1920x1080 resolution was used
  - Checks for screenshot artifacts in `.ian/`
  - Blocks commit if verification missing

- **Environment variable:** `STRICT_UI=1` (default: 1)
  - `STRICT_UI=1` - Blocks violations
  - `STRICT_UI=0` - Warns only (emergency bypass)

- **Verification evidence required:**
  - Playwright MCP tool calls in session history
  - Resolution: 1920x1080 in tool parameters
  - Screenshot artifacts in `.ian/ui_verify_*.png`
  - Verification report in `.ian/ui_verify_*.md`

- **Recommended workflow:**
  - Use `/ui-verify` skill for guided testing
  - Or manually use Playwright MCP tools
  - Hook automatically validates evidence exists

### 6.6 Quality Gates Check Hook (`quality_gates_check`)

**Purpose:** Block pushing incomplete work to main.

- **Trigger:** Pre-push
- **Behavior:**
  - Checks if pushing to main/master
  - Verifies quality gate tracking exists for branch
  - Confirms Gate 7 (Code Reviewed) is PASSED
  - Runs full CI validation (`make ci-check` equivalent)
  - Blocks push if gates not complete

- **Environment variable:** `STRICT_HOOKS=1` (default: 1)
  - `STRICT_HOOKS=1` - Blocks violations
  - `STRICT_HOOKS=0` - Warns only

- **Example:**
  ```bash
  git push origin main
  > Checking quality gates for feature: order_idempotency
  > Current gate: Gate 6 (E2E Verified)
  > ERROR: Gate 7 (Code Reviewed) not passed
  > Run: /validator to complete code review
  > Then: scripts/quality-gates/gates-pass.sh order_idempotency
  > Push BLOCKED
  ```

### 6.7 Session Start Hook (`session_start`)

**Purpose:** Set expectations and display workflow at session start.

- **Trigger:** SessionStart (Claude Code hook)
- **Behavior:**
  - Backs up CLAUDE.md to `.claude/backups/`
  - Displays Superpowers-first workflow reminder
  - Shows quality gate workflow overview
  - Lists available skills/commands
  - Keeps only last 10 backups

### 6.8 Post-Checkout Reminder Hook (`post_checkout_reminder`)

**Purpose:** Display workflow reminder when switching branches.

- **Trigger:** Post-checkout (git hook)
- **Behavior:**
  - Displays 7-stage quality gate workflow
  - Shows current gate for feature (if tracking exists)
  - Reminds about mandatory skills (`/validator`, `/ui-verify`, etc.)

### 6.9 Doc & Memory Hooks

- **`markdown_backup`**
  Syncs updated docs to an external backup location (e.g. second repo or storage).

- **`serena_index_refresh`**
  Notifies Serena/memory to re-index updated markdown docs.

Additional hooks may be created for:

- Pushing docs to other knowledge systems.
- Triggering CI/CD pipelines after key milestones.
- Emitting metrics/telemetry for observability.

Docs uses the current hooks after updating docs and **before** signalling `DocsUpdated` to Orchestrator.

---

## 7. Documentation & Memory Model

*(Unchanged structurally from v2, still allows more docs/ADR types to be added as needed)*

### 7.1 Per-File Canonical Docs

For each code file `path/to/foo.ext`, there is a canonical markdown doc:

- e.g. `docs/files/path_to_foo_ext.md`

It records:

- Purpose and responsibilities.
- Public API (functions, classes, endpoints).
- Invariants and important constraints.
- Dependencies (inbound/outbound).
- Known risks or TODOs.
- Recent changes with references to commits / features.

**Rules:**

- Any change to `foo.ext` requires updating `docs/files/path_to_foo_ext.md` in the same slice.
- A slice is not complete until:
  - Code + tests + per-file docs + feature changelog are consistent.
  - Relevant quality gate passed.
  - Auto-commit hook has run (if Orchestrator-triggered).

### 7.2 Feature Changelog Docs

Each feature has:

- `docs/feature/<feature-name>.md`

It records:

- Feature description.
- Quality gate progression with timestamps.
- Tasks done.
- Changes across files with references to commits.
- QA outcomes and decisions.
- Architecture decisions (linked to ADRs).

After merge into `main`:

- Docs summarise into global `CHANGELOG.md` and any relevant overview docs.
- Detailed feature doc is archived or kept per policy.

### 7.3 ADRs & Architecture Docs

Architecture decisions are stored as ADRs, e.g.:

- `docs/adr/0001-initial-architecture.md`
- `docs/adr/00xx-feature-xyz-decision.md`

Architect produces content; Docs turns it into structured ADR markdown and hooks it into Serena.

New ADR types or structures can be added over time.

### 7.4 Memory & Backup Layers

We maintain three layers:

1. **Repo docs** – canonical markdown in Git (per-file, feature, ADRs, changelog).
2. **Markdown backup** – mirrored docs (e.g. separate repo, storage bucket, or mirror).
3. **Serena / memory** – indexes doc content for semantic search and context retrieval.

Hooks ensure:

- After doc updates + commit, backup and memory are refreshed.

Future memory backends (other than Serena) can be swapped in by updating the MCP config and related hooks.

---

## 8. Roles & Responsibilities

### 8.1 Orchestrator

- Single point of contact for the human user.
- Maintains the current feature spec, plan, and task status.
- **Owns quality gate progression** for the feature:
  - Tracks current gate.
  - Coordinates roles to meet gate requirements.
  - Validates gate completion before advancement.
  - Triggers gate-specific validation skills automatically.
- Owns the **tool/skill/hook/agent policy**:
  - Knows which tool IDs exist (via high-level summary and/or Librarian).
  - Tells each role **exactly** which tools to use for a given task, including future tools that may be added.
- Enforces:
  - Feature isolation (no work on main).
  - DocIntent-before-change.
  - Docs-updated-before-commit.
  - Quality gates before auto-commit.
- Triggers:
  - Auto-commit hook when QA+Docs confirm a slice is ready AND gate requirements met.
  - Validation skills at appropriate gates (`/pragmatist` at Gate 4, `/validator` at Gate 7).

### 8.2 Librarian

- Reads everything:
  - Code, tests, docs, ADRs, messages, quality gate status.
- Provides **ContextPacks** with:
  - Relevant files, tests, docs.
  - Historical/architectural notes.
  - Current quality gate context.
- Works with Docs to ensure Serena/memory (and future memory systems) reflect current docs.
- Can query quality gate status to provide context about feature progress.

### 8.3 Planner

- On `PlanRequest`, uses orchestrator-approved skills:
  - **Superpowers 3-step workflow (for complex features):**
    1. `superpowers_brainstorming` - Socratic questioning to refine vague ideas
    2. `superpowers_plan_writer` - Creates detailed PRD with sprints, tasks, acceptance criteria
    3. (Execution happens via Dev/QA roles or `superpowers_execute_plan`)

- For simpler features: can create plan directly without full brainstorming.

- Produces a plan where each task includes:
  - Files to modify.
  - File docs to update.
  - Intended DocIntent summary.
  - **Quality gate alignment** - which gate each task contributes to.
  - Test requirements (for Gate 2).

- Plan becomes the basis for Gate 1 (Spec Approved).

### 8.4 Architect (Architecture Council)

- Handles large design changes first.
- Uses architecture skills/agents and Librarian context.
- Outputs:
  - Architecture decisions.
  - ADR-ready drafts.
  - Design considerations for quality gates (e.g. refactoring strategy for Gate 4).
- Coordinates with Docs to have decisions codified and committed.

### 8.5 Dev Instances (Dev-A, Dev-B, …)

- Follow TDD (enforced by `enforce_test_first` hook):
  - Write/extend tests before implementing behaviour (Gate 2).
  - Implement to make tests pass (Gate 3).
  - Refactor while maintaining green tests (Gate 4).

- **Always emit DocIntent** before making changes.
- Use only tools authorised by Orchestrator, from the dynamic toolset defined in `toolset.yaml`.
- Coordinate with Docs:
  - Confirm which docs need updating.
- Mark tasks as "ready for QA" when code + tests appear solid.
- **Aware of current quality gate** - Orchestrator tells them which gate they're working toward.

### 8.6 QA Instances (QA-A, QA-B)

- Validate code against:
  - Tests.
  - Spec/plan.
  - Quality gate requirements.

- For Gate 6 (E2E Verified):
  - Run end-to-end tests.
  - If UI changes: verify `/ui-verify` has been run and passed.
  - Verify backend/frontend integration.

- Emit DocIntents for test-related changes and new behaviours found.
- Work with Docs to ensure edge cases are recorded.
- Report results via `QAResult` messages.
- **Gate 7 trigger:** When Dev marks work ready for final review, QA coordinates with Orchestrator to run `/validator` skill.

### 8.7 Docs Instance

- Receives DocIntents from all roles.
- Updates:
  - Per-file docs.
  - Feature changelog.
  - Quality gate progression notes.
  - ADRs based on Architect outputs.

- Runs doc hooks:
  - `markdown_backup`.
  - `serena_index_refresh`.

- Signals Orchestrator via `DocsUpdated` when a slice is doc-complete.
- **Quality gate awareness:** Tracks which gate feature is on, includes gate context in documentation.

---

## 9. Inter-Instance Communication

*(Unchanged conceptually from v2; supports any future message types as needed)*

### 9.1 Design Principles

- **Explicit message types** (not free-form chatter):
  - `ContextRequest`, `ContextPack`, `PlanRequest`, `Plan`, `TaskAssignment`,
    `DocIntent`, `QAResult`, `DocsUpdated`, `GateStatusUpdate`, etc.
  New message types can be introduced as the system evolves.

- **Orchestrator-centric** routing:
  - Official communication flows via Orchestrator, even if panes can also "chat" directly.

- **Two transports**:
  1. tmux copy/paste + helper scripts (`tmux send-keys`, `capture-pane`).
  2. Shared "message board" files in `messages/` accessible via filesystem MCP.

### 9.2 New Message Types for Quality Gates

**GateStatusUpdate**
```markdown
## GateStatusUpdate

**From:** Orchestrator
**To:** All Roles
**Feature:** order_idempotency
**Current Gate:** 3 (Implementation Complete)
**Status:** In Progress
**Requirements:**
- All tests passing ✓
- No TODOs in production code (pending)
- No debug statements (pending)

**Next Steps:** Remove TODOs and debug statements, then request gate advancement.
```

**GateAdvanceRequest**
```markdown
## GateAdvanceRequest

**From:** Dev-A
**To:** Orchestrator
**Feature:** order_idempotency
**Current Gate:** 3
**Requesting Advance To:** Gate 4 (Refactored)
**Justification:** All tests passing, code clean, ready for refactoring review.
```

*(Other message templates from v2 remain unchanged)*

---

## 10. Context Hygiene & Tool Exposure

*(Clarifies that lists are open-ended and tools are referenced by IDs only)*

- Tools, skills, hooks, plugins, and agents are referred to **only by symbolic IDs**.
- No role is allowed to dump the full contents of `toolset.yaml` or tool docs into the conversation.
- When new tools are added, Orchestrator may:
  - Ask Librarian to summarise new capabilities.
  - Instruct roles to use new IDs with minimal additional context.
- The design supports an **open-ended toolset** without bloating prompts.
- **Quality gate status** is tracked externally in `.git/quality-gates/` and queried on-demand, not kept in context.

---

## 11. System-Comps & Prompt Assembly

*(Unchanged from v2, but implicitly supports new comps for quality gates and validation)*

System-comps live in `system-comps/` and include:

- `tdd.md` - TDD principles and practices
- `docintent.md` - DocIntent protocol
- `quality_gates.md` (NEW) - Quality gate workflow and requirements
- `validation_skills.md` (NEW) - When to use validator/pragmatist/karen
- `superpowers_workflow.md` (NEW) - 3-step brainstorm→plan→execute workflow
- `hooks_usage.md` - Hook policies and bypass protocols
- `tool_usage.md` - General tool usage policies

`prompts.yaml` defines role-specific prompt assembly:

```yaml
roles:
  orchestrator:
    system_comps:
      - core/orchestrator_identity.md
      - shared/tdd.md
      - shared/docintent.md
      - shared/quality_gates.md  # NEW
      - shared/validation_skills.md  # NEW
      - shared/superpowers_workflow.md  # NEW
      - shared/hooks_usage.md
      - shared/tool_usage.md

  dev:
    system_comps:
      - core/dev_identity.md
      - shared/tdd.md
      - shared/docintent.md
      - shared/quality_gates.md  # NEW
      - shared/hooks_usage.md
      - shared/tool_usage.md

  qa:
    system_comps:
      - core/qa_identity.md
      - shared/quality_gates.md  # NEW
      - shared/validation_skills.md  # NEW
      - shared/docintent.md
      - shared/tool_usage.md

  # ... etc for other roles
```

The `build_prompt.py` script assembles prompts from these comps, injecting role-specific context while keeping total size manageable.

New system-comps and roles can be added over time; the assembly mechanism remains the same.

---

## 12. Repo Layout & Bootstrap Scripts

### 12.1 Repository Structure

```
project-root/
├── toolset.yaml                   # Unified MCP/skills/hooks/agents config
├── bootstrap_tmux.sh              # Main bootstrap script (with MCP checks)
├── scripts/
│   ├── setup_feature_git.sh       # Feature branch/worktree setup
│   ├── build_prompt.py            # System prompt assembly
│   ├── mcp/
│   │   ├── mcp-start.sh           # Start all MCP servers
│   │   ├── mcp-stop.sh            # Stop all MCP servers
│   │   ├── mcp-status.sh          # Check MCP server status
│   │   └── mcp-logs.sh            # View MCP logs
│   ├── hooks/
│   │   ├── feature_isolation.sh
│   │   ├── auto_commit.sh
│   │   ├── quality_gates_check.sh      # NEW
│   │   ├── enforce_test_first.sh       # NEW
│   │   ├── enforce_ui_verification.sh  # NEW
│   │   ├── session_start.sh            # NEW
│   │   ├── post_checkout_reminder.sh   # NEW
│   │   ├── markdown_backup.sh
│   │   └── serena_index_refresh.sh
│   ├── quality-gates/
│   │   ├── gates-start.sh              # NEW
│   │   ├── gates-check.sh              # NEW
│   │   ├── gates-pass.sh               # NEW
│   │   └── gates-status.sh             # NEW
│   └── auto-commit-service/
│       ├── auto-commit-watch.service   # NEW - systemd service
│       ├── auto-commit-watch.sh        # NEW - watch script
│       └── install.sh                  # NEW - service installer
├── system-comps/
│   ├── core/
│   │   ├── orchestrator_identity.md
│   │   ├── librarian_identity.md
│   │   ├── planner_identity.md
│   │   ├── architect_identity.md
│   │   ├── dev_identity.md
│   │   ├── qa_identity.md
│   │   └── docs_identity.md
│   └── shared/
│       ├── tdd.md
│       ├── docintent.md
│       ├── quality_gates.md            # NEW
│       ├── validation_skills.md        # NEW
│       ├── superpowers_workflow.md     # NEW
│       ├── hooks_usage.md
│       └── tool_usage.md
├── prompts.yaml                   # Prompt assembly config
├── tools/
│   ├── superpowers_brainstorming.md
│   ├── superpowers_plan_writer.md
│   ├── superpowers_execute_plan.md    # NEW
│   ├── validator.md                    # NEW
│   ├── pragmatist.md                   # NEW
│   ├── karen.md                        # NEW
│   ├── ui_verify.md                    # NEW
│   ├── markdown_elementary.md
│   └── ... (other tool capability cards)
├── messages/
│   ├── orchestrator/
│   │   ├── inbox.md
│   │   └── outbox.md
│   ├── librarian/
│   ├── planner/
│   ├── dev-a/
│   ├── qa-a/
│   └── docs/
├── .git/
│   └── quality-gates/                  # NEW - persistent gate tracking
│       ├── README.md
│       └── <feature_name>/
│           ├── status.json
│           ├── gate_1_spec.status
│           ├── gate_2_tests.status
│           ├── gate_3_impl.status
│           ├── gate_4_refactor.status
│           ├── gate_5_integration.status
│           ├── gate_6_e2e.status
│           ├── gate_7_review.status
│           ├── started_at.txt
│           ├── completed_at.txt
│           └── notes.md
└── docs/
    ├── files/                     # Per-file canonical docs
    ├── feature/                   # Per-feature changelogs
    ├── adr/                       # Architecture Decision Records
    └── CHANGELOG.md               # Global changelog
```

### 12.2 Bootstrap Script (`bootstrap_tmux.sh`)

**Enhanced with quality gate initialization and MCP management:**

```bash
#!/bin/bash
# bootstrap_tmux.sh <feature-name>

FEATURE_NAME="$1"
SESSION_NAME="claude-feature-$FEATURE_NAME"

# 1. Check MCP servers are running
echo "Checking MCP servers..."
./scripts/mcp/mcp-status.sh || {
    echo "MCP servers not running. Starting..."
    ./scripts/mcp/mcp-start.sh
}

# 2. Create feature branch/worktree
echo "Setting up feature isolation..."
./scripts/setup_feature_git.sh "$FEATURE_NAME"

# 3. Initialize quality gates
echo "Initializing quality gates..."
./scripts/quality-gates/gates-start.sh "$FEATURE_NAME"

# 4. Update toolset.yaml with worktree paths
echo "Configuring toolset..."
WORKTREE_PATH="../wt-feature-$FEATURE_NAME"
sed "s|/path/to/feature-worktree|$WORKTREE_PATH|g" toolset.yaml.template > toolset.yaml

# 5. Build system prompts from system-comps
echo "Building system prompts..."
./scripts/build_prompt.py orchestrator > /tmp/prompt_orchestrator.txt
./scripts/build_prompt.py librarian > /tmp/prompt_librarian.txt
./scripts/build_prompt.py planner > /tmp/prompt_planner.txt
./scripts/build_prompt.py architect > /tmp/prompt_architect.txt
./scripts/build_prompt.py dev > /tmp/prompt_dev.txt
./scripts/build_prompt.py qa > /tmp/prompt_qa.txt
./scripts/build_prompt.py docs > /tmp/prompt_docs.txt

# 6. Create tmux session and layout
echo "Creating tmux session: $SESSION_NAME"
tmux new-session -d -s "$SESSION_NAME" -n orchestrator

# 7. Create windows and panes
tmux new-window -t "$SESSION_NAME" -n core-roles
tmux split-window -t "$SESSION_NAME:core-roles" -h
tmux split-window -t "$SESSION_NAME:core-roles" -h
tmux select-layout -t "$SESSION_NAME:core-roles" even-horizontal

tmux new-window -t "$SESSION_NAME" -n implementation
tmux split-window -t "$SESSION_NAME:implementation" -h
tmux split-window -t "$SESSION_NAME:implementation.0" -v
tmux split-window -t "$SESSION_NAME:implementation.2" -v
tmux select-layout -t "$SESSION_NAME:implementation" tiled

tmux new-window -t "$SESSION_NAME" -n docs

# 8. Launch Claude Code instances with role-specific prompts
echo "Launching Claude Code instances..."

tmux send-keys -t "$SESSION_NAME:orchestrator" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_orchestrator.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:core-roles.0" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_librarian.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:core-roles.1" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_planner.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:core-roles.2" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_architect.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:implementation.0" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_dev.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:implementation.1" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_dev.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:implementation.2" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_qa.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:implementation.3" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_qa.txt)\"" C-m

tmux send-keys -t "$SESSION_NAME:docs" \
  "claude code --mcp-config toolset.yaml --system \"\$(cat /tmp/prompt_docs.txt)\"" C-m

# 9. Display quality gate workflow in orchestrator pane
sleep 2
tmux send-keys -t "$SESSION_NAME:orchestrator" \
  "cat scripts/quality-gates/workflow-reminder.txt" C-m

# 10. Attach to session (orchestrator pane)
echo "Attaching to orchestrator pane..."
tmux attach-session -t "$SESSION_NAME:orchestrator"
```

### 12.3 Auto-Commit Service Installation

```bash
# Install auto-commit systemd service
./scripts/auto-commit-service/install.sh

# Service will:
# - Watch backend/ and frontend/ directories
# - Auto-commit every 30 seconds
# - Provide undo/goback bash aliases
# - Start automatically on login
```

---

## 13. Example PoC Usage Flow (with Quality Gates)

### 13.1 Starting a New Feature

```bash
# 1. Bootstrap the multi-instance environment
./bootstrap_tmux.sh order_idempotency

# This creates:
# - Feature branch: feature/order_idempotency
# - Git worktree: ../wt-feature-order_idempotency
# - Quality gate tracking: .git/quality-gates/order_idempotency/
# - Tmux session: claude-feature-order_idempotency
# - All Claude instances with unified toolset

# 2. User attaches to orchestrator pane
# Orchestrator displays workflow reminder from session-start hook
```

### 13.2 Gate 1: Spec Approved

```
[In Orchestrator pane]

User: "I need to add order idempotency to prevent duplicate submissions"

Orchestrator: "I'll coordinate with Planner to create a specification. Since this is a
complex feature, we'll use the Superpowers 3-step workflow."

Orchestrator → Planner: "PlanRequest for order_idempotency feature. Use superpowers_brainstorming
for design refinement, then superpowers_plan_writer for detailed planning."

[In Planner pane]

Planner: "Using superpowers_brainstorming skill..."
[Socratic questioning process]
- What triggers a duplicate? Network retry? User double-click?
- How long should idempotency window be?
- What storage mechanism?
[Result: Refined design]

Planner: "Using superpowers_plan_writer skill..."
[Creates detailed PRD]
- Sprint 1: Idempotency store infrastructure
- Sprint 2: Integration with OrderService
- Sprint 3: Testing and validation
[Saves to: docs/feature/order_idempotency.md]

Planner → Orchestrator: "Plan complete and saved. Ready for Gate 1 approval."

User: "Plan looks good, approved."

Orchestrator: "Advancing to Gate 1..."
[Runs: ./scripts/quality-gates/gates-pass.sh order_idempotency]
[Gate 1: PASSED]

Orchestrator → All Roles: "GateStatusUpdate: Now on Gate 2 (Tests First)"
```

### 13.3 Gate 2: Tests First (TDD)

```
Orchestrator → Dev-A: "TaskAssignment: Create idempotency store tests. Remember: tests
BEFORE implementation. Gate 2 requirement."

[In Dev-A pane]

Dev-A: "Creating test file: backend/tests/test_idempotency_store.py"
[Writes failing tests]

Dev-A: "Committing tests..."
git add backend/tests/test_idempotency_store.py
git commit -m "test: add idempotency store tests (Gate 2)"
[enforce_test_first hook: ✓ ALLOWED - tests only, no implementation]

Dev-A → Orchestrator: "Tests committed. Ready for implementation (Gate 3)."

Orchestrator: "Advancing to Gate 2..."
[Runs: ./scripts/quality-gates/gates-pass.sh order_idempotency]
[Gate 2: PASSED]
```

### 13.4 Gate 3: Implementation Complete

```
Orchestrator → Dev-A: "TaskAssignment: Implement idempotency store to pass tests. Gate 3."

[In Dev-A pane]

Dev-A: "Implementing: backend/services/idempotency_store.py"
[Implements code, tests pass]

Dev-A: "Committing implementation..."
git add backend/services/idempotency_store.py
git commit -m "feat: implement idempotency store (Gate 3)"
[enforce_test_first hook: ✓ ALLOWED - tests already committed]

Dev-A → QA-A: "Ready for testing"

[In QA-A pane]

QA-A: "Running tests... All passing ✓"
QA-A → Orchestrator: "QAResult: Tests PASS, no TODOs, no debug statements. Gate 3 complete."

Orchestrator: "Advancing to Gate 3..."
[Runs: ./scripts/quality-gates/gates-pass.sh order_idempotency]
[Gate 3: PASSED]
```

### 13.5 Gate 4: Refactored

```
Orchestrator: "Triggering pragmatist skill for Gate 4..."
[Automatically runs /pragmatist skill]

Pragmatist: "Reviewing for over-engineering...
- ✓ Code is appropriately simple
- ✓ No premature optimization
- ⚠️ Suggestion: Extract magic number 3600 to named constant IDEMPOTENCY_WINDOW_SECONDS"

Dev-A: "Applying suggestion..."
[Refactors code]
git commit -m "refactor: extract idempotency window constant (Gate 4)"

Orchestrator: "Advancing to Gate 4..."
[Runs: ./scripts/quality-gates/gates-pass.sh order_idempotency]
[Gate 4: PASSED]
```

### 13.6 Gate 5: Integrated

```
Orchestrator → Dev-A: "Run integration: make openapi && make types"

[Post-commit hook automatically runs]
[OpenAPI spec regenerated]
[Frontend types synced]
[Semantic index updated]

Orchestrator → Docs: "DocIntent: Idempotency store added, update file docs and feature changelog"

[In Docs pane]

Docs: "Updating docs/files/backend_services_idempotency_store.md"
Docs: "Updating docs/feature/order_idempotency.md with Gate 5 completion"
[Runs markdown_backup and serena_index_refresh hooks]

Docs → Orchestrator: "DocsUpdated: All docs current, OK for Auto-Commit"

Orchestrator: "Advancing to Gate 5..."
[Runs: ./scripts/quality-gates/gates-pass.sh order_idempotency]
[Gate 5: PASSED]
[Triggers auto_commit hook with descriptive message]
```

### 13.7 Gate 6: E2E Verified

```
Orchestrator → QA-A: "Run E2E verification for Gate 6"

[In QA-A pane]

QA-A: "Running end-to-end tests..."
- ✓ Backend starts successfully
- ✓ API endpoints respond
- ✓ Idempotency store integration works
- ✓ No runtime errors

QA-A: "No UI changes in this feature, skipping ui-verify"

QA-A → Orchestrator: "QAResult: E2E verification PASSED"

Orchestrator: "Advancing to Gate 6..."
[Runs: ./scripts/quality-gates/gates-pass.sh order_idempotency]
[Gate 6: PASSED]
```

### 13.8 Gate 7: Code Reviewed

```
Orchestrator: "Triggering validator skill for Gate 7..."
[Automatically runs /validator skill]

Validator: "Reviewing implementation against spec...

✓ All success criteria met
✓ Tests comprehensive
✓ Documentation complete
✓ No security issues
✓ Production ready

ASSESSMENT: APPROVED for merge"

Orchestrator: "Advancing to Gate 7..."
[Runs: ./scripts/quality-gates/gates-pass.sh order_idempotency]
[Gate 7: PASSED]

Orchestrator: "Feature complete! All quality gates passed. Ready to merge to main."
```

### 13.9 Merging to Main

```
User: "Merge to main"

Orchestrator → Dev-A: "Squash auto-commits and push to main"

[In Dev-A pane]

Dev-A: "Squashing auto-commits..."
git rebase -i origin/main
[Squashes auto-commits into meaningful commits]

Dev-A: "Pushing to main..."
git push origin main

[quality_gates_check hook runs]
- ✓ Gate tracking exists
- ✓ Gate 7 PASSED
- ✓ CI validation passes
[Push ALLOWED]

Orchestrator: "Feature merged successfully! Quality gates archived."
```

---

## 14. Strict Mode and Progressive Enforcement

### 14.1 Environment Variables

```bash
# Quality enforcement levels
export STRICT_HOOKS=1      # Enforce all hooks (default: 1)
export STRICT_TDD=1        # Enforce test-first (default: 1)
export STRICT_UI=1         # Enforce UI verification (default: 1)

# Disable for emergencies (use sparingly)
export STRICT_HOOKS=0
export STRICT_TDD=0
export STRICT_UI=0
```

### 14.2 Gradual Adoption Strategy

**Phase 1: Warn-only (Learning)**
```bash
export STRICT_HOOKS=0
export STRICT_TDD=0
export STRICT_UI=0
# All hooks warn but don't block
# Team learns workflow
```

**Phase 2: TDD Enforcement**
```bash
export STRICT_TDD=1
# Test-first required
# Other checks still warn-only
```

**Phase 3: Full Enforcement**
```bash
export STRICT_HOOKS=1
export STRICT_TDD=1
export STRICT_UI=1
# All quality checks enforced
# Production-grade workflow
```

### 14.3 Emergency Bypass

```bash
# Hotfix scenario: production is down
export STRICT_HOOKS=0
git commit -m "hotfix: critical security patch"
git push origin main

# After emergency:
export STRICT_HOOKS=1
# Return to normal enforcement
# Create follow-up task to add missing tests/docs
```

---

## 15. MCP Lifecycle Management

### 15.1 MCP Management Commands

```bash
# Start all MCP servers
./scripts/mcp/mcp-start.sh

# Check status
./scripts/mcp/mcp-status.sh

# Stop all
./scripts/mcp/mcp-stop.sh

# Restart all
./scripts/mcp/mcp-restart.sh

# View logs
./scripts/mcp/mcp-logs.sh
```

### 15.2 Bootstrap MCP Check

Bootstrap script verifies MCP servers before launching instances:

```bash
# In bootstrap_tmux.sh

echo "Checking MCP servers..."
./scripts/mcp/mcp-status.sh || {
    echo "MCP servers not running. Starting..."
    ./scripts/mcp/mcp-start.sh

    # Wait for servers to be ready
    sleep 5

    ./scripts/mcp/mcp-status.sh || {
        echo "ERROR: MCP servers failed to start"
        exit 1
    }
}

echo "✓ All MCP servers running"
```

### 15.3 Critical vs Optional MCPs

**Critical (required for operation):**
- Filesystem MCP
- Git MCP
- Terminal MCP
- Serena MCP (for skills and memory)

**Optional (enhance capabilities):**
- Playwright MCP (required only for UI verification)
- Context7 MCP
- Firecrawl MCP

Bootstrap can proceed with warnings if optional MCPs are down, but blocks on critical MCPs.

---

## 16. Key Improvements Over v2

### 16.1 What v3 Adds to v2's Architecture

1. **Enforced Quality Gates**
   - v2: Mentions TDD and documentation
   - v3: **7 mandatory gates with git hook enforcement**

2. **TDD Structural Enforcement**
   - v2: Roles are told to follow TDD
   - v3: **Git hooks make skipping TDD impossible**

3. **UI Verification Requirements**
   - v2: Mentions Playwright/Puppeteer
   - v3: **Mandatory verification with resolution standards**

4. **Auto-Commit Service**
   - v2: Auto-commit hook for coherent slices
   - v3: **Continuous auto-commit service + rollback capability**

5. **Quality Validation Skills**
   - v2: Generic QA role
   - v3: **Automatic validation skills at specific gates**

6. **Superpowers Workflow Integration**
   - v2: Lists skills in toolset
   - v3: **Explicit 3-step workflow with gate mapping**

7. **Progressive Enforcement**
   - v2: No enforcement levels
   - v3: **Strict mode controls for gradual adoption**

8. **MCP Lifecycle Management**
   - v2: Assumes MCPs are running
   - v3: **Bootstrap verifies and manages MCP servers**

9. **Workflow Visibility**
   - v2: No workflow reminders
   - v3: **Session-start and post-checkout reminders**

10. **Production-Proven Patterns**
    - v2: Theoretical architecture
    - v3: **Integrates battle-tested v1 patterns**

### 16.2 Philosophy Shift

**v2:** "Here's a multi-instance architecture with good practices"

**v3:** "Here's a multi-instance architecture that **structurally enforces** good practices"

Quality is not suggested—it's **required by design**.

---

## 17. Summary

This v3 spec combines:

- **v2's multi-instance orchestration architecture** (tmux, unified toolset, role separation, DocIntent, memory layers)
- **v1's quality enforcement mechanisms** (7-stage gates, TDD hooks, UI verification, validation skills, auto-commit service)

The result is a **production-grade orchestrated development system** where:

- Multiple Claude instances work in concert
- Quality is enforced at every step
- Tests are written first (structurally required)
- UI changes are verified visually
- Documentation is live and canonical
- Git history is safe and granular
- Incomplete work cannot reach main
- Progressive enforcement allows gradual adoption

**This is the complete PoC specification**, ready for implementation.

---

**Document Version**: 3.0
**Based on**: v2 architecture + v1 quality enforcement
**Status**: Complete PoC design
**Date**: November 15, 2025
