
# Project Spec (PoC): Multi-Instance Claude Code Orchestration with Unified Toolset, Hooks & Live Documentation

> **Status:** Proof of Concept (PoC) – design is intentionally complete, not split into “primary vs secondary” features.  
> **Important:** Any lists of MCP servers, skills, hooks, plugins, or agents in this document are **illustrative, not exhaustive**. The architecture must support adding, removing, or swapping tools without structural changes.  
> **Goal:** Build this once, with all behaviours included from day one.

---

## 1. Context

We want a **multi-instance Claude Code development environment** where:

- Each **role** (Orchestrator, Librarian, Planner, Architect, Dev-A, Dev-B, QA-A, QA-B, Docs) runs in its **own tmux pane/window**.
- All instances share a **single unified toolset** consisting of (non-exhaustive):
  - MCP servers & tools (e.g. Serena, filesystem, terminal, git, Puppeteer/Playwright, Context 7, Firecrawl, etc.).
  - **Skills** (e.g. Superpowers Brainstorming, Superpowers Plan Writer, markdown formatting, architecture skills).
  - **Plugins**.
  - **Hooks** (feature isolation, auto-commit, doc/memory sync, etc.).
  - **Specialist agents** (architecture agent, refactor agent, security agent, etc.).

The actual set of MCP servers, skills, hooks, plugins, and agents is expected to **evolve over time**; this spec defines how they are wired and orchestrated, not a fixed menu.

The **Orchestrator instance** is the single “brain” that:

- Knows **what tools/skills/hooks/agents exist** (by symbolic ID, not by reading all configs at once).
- Decides **which roles use which tools** for each task.
- Coordinates the work of all other instances.

Hard, non-negotiable constraints:

- **Git Safety**
  - All work happens in a **feature-isolated branch or Git worktree**.
  - No role ever touches `main` directly until an explicit merge.
  - An **auto-commit hook** ensures that after each coherent change (code + tests + docs), a descriptive commit is created, enabling easy rollback.

- **Live Canonical Documentation**
  - Every code file has a **paired markdown “file doc”** that is the canon for that file.
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

- **O-05: Auto-commit after each meaningful change**  
  An auto-commit hook creates small, descriptive commits after each coherent slice of work (code + tests + docs), enabling fine-grained rollback.

- **O-06: Live canonical documentation per file and feature**  
  Every code file has a canonical markdown doc; every feature has a changelog. Changes are documented **as they happen**, driven by `DocIntent` messages from roles.

- **O-07: Integrated memory and markdown backup**  
  Documentation and design knowledge are mirrored to:
  - Repo docs (per-file, feature, ADRs, changelog).
  - A markdown backup location.
  - Serena (or similar) as a searchable memory service.

- **O-08: Architecture Council role for major design work**  
  An Architect role is the first port of call for large design/architecture changes, producing ADR-ready material and coordinating with Librarian & Docs.

- **O-09: System prompt composition (“system-comps”)**  
  Role prompts are assembled from reusable prompt fragments (system-comps) under version control, ensuring consistent policies across roles (TDD, DocIntent, hooks, tool usage).

- **O-10: Bootstrap script to spin everything up**  
  A script creates the tmux layout, sets up the feature Git branch/worktree and hooks, assembles system prompts from system-comps, launches all Claude instances with the unified toolset, and attaches to the Orchestrator pane.

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
  - Skills: superpowers_brainstorming, superpowers_plan_writer, markdown_elementary, etc.  
    Additional skills can be added without changing the architecture; Orchestrator just references new IDs.
  - Hooks: feature_isolation, auto_commit, markdown_backup, serena_index_refresh, etc.  
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

  puppeteer:
    type: browser
    endpoint: http://localhost:9222

  context7:
    type: context-service
    url: http://localhost:4000

  firecrawl:
    type: crawler
    url: http://localhost:5000

skills:
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

  master_demonstrator_writer:
    server: serena
    capability: master_demonstrator

hooks:
  feature_isolation:
    type: shell
    script: scripts/hooks/feature_isolation.sh

  auto_commit:
    type: shell
    script: scripts/hooks/auto_commit.sh

  markdown_backup:
    type: shell
    script: scripts/hooks/markdown_backup.sh

  serena_index_refresh:
    type: api
    target: serena
    endpoint: /refresh-index

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
- Roles only see **tool IDs and categories** in their prompts (e.g. “You may be told to use `superpowers_brainstorming` or `auto_commit`.”).
- Detailed usage semantics live in separate markdown cards in `tools/` and are loaded only when needed.

---

## 5. Git Workflow & Hooks

### 5.1 Feature Isolation Hook (`feature_isolation`)

**Purpose:** Guarantee all work happens in a feature-isolated branch/worktree, not on main.

- On start of a feature run (`bootstrap_tmux.sh feature-xyz`):
  - `scripts/setup_feature_git.sh` is invoked (directly or via `feature_isolation` hook).
  - It creates a new branch `feature/xyz` and corresponding worktree, e.g. `../wt-feature-xyz`.
  - `toolset.yaml` is rewritten/templated so:
    - `filesystem.root`, `terminal.cwd`, and `git.repo` point at the feature worktree.
- All file operations by all roles happen in that worktree; `main` is read-only.
- **Note:** Additional hooks for more advanced branch/worktree workflows (e.g. hotfix branches, release branches) can be added later without affecting this core pattern.

### 5.2 Auto-Commit Hook (`auto_commit`)

**Purpose:** Small, descriptive commits after each coherent slice of work.

- Triggered only when Orchestrator decides a slice is complete:
  - QA returns `QAResult` with `Status: PASS`.
  - Docs sends `DocsUpdated` with `OK for Auto-Commit: YES`.
- The hook:

  - Uses git MCP (or shell) to:
    - Stage relevant files.
    - Use a structured commit message (e.g. `feat: add delete_user endpoint (DEV-001)`).
  - Optionally tags the commit with feature name / task IDs.

- No role is allowed to run `git commit` directly; only the hook (via Orchestrator) may commit.

Future extensions may introduce more hooks (e.g. pre-commit lint, security scan) without altering the high-level flow.

### 5.3 Doc & Memory Hooks

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

## 6. Documentation & Memory Model

*(unchanged structurally, still allows more docs/ADR types to be added as needed)*

### 6.1 Per-File Canonical Docs

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
  - Auto-commit hook has run.

### 6.2 Feature Changelog Docs

Each feature has:

- `docs/feature/<feature-name>.md`

It records:

- Feature description.
- Tasks done.
- Changes across files with references to commits.
- QA outcomes and decisions.
- Architecture decisions (linked to ADRs).

After merge into `main`:

- Docs summarise into global `CHANGELOG.md` and any relevant overview docs.
- Detailed feature doc is archived or kept per policy.

### 6.3 ADRs & Architecture Docs

Architecture decisions are stored as ADRs, e.g.:

- `docs/adr/0001-initial-architecture.md`
- `docs/adr/00xx-feature-xyz-decision.md`

Architect produces content; Docs turns it into structured ADR markdown and hooks it into Serena.

New ADR types or structures can be added over time.

### 6.4 Memory & Backup Layers

We maintain three layers:

1. **Repo docs** – canonical markdown in Git (per-file, feature, ADRs, changelog).
2. **Markdown backup** – mirrored docs (e.g. separate repo, storage bucket, or mirror).
3. **Serena / memory** – indexes doc content for semantic search and context retrieval.

Hooks ensure:

- After doc updates + commit, backup and memory are refreshed.

Future memory backends (other than Serena) can be swapped in by updating the MCP config and related hooks.

---

## 7. Roles & Responsibilities

*(no behavioural change here; roles are defined to work with any extended toolset that appears in `toolset.yaml`)*

### 7.1 Orchestrator

- Single point of contact for the human user.
- Maintains the current feature spec, plan, and task status.
- Owns the **tool/skill/hook/agent policy**:
  - Knows which tool IDs exist (via high-level summary and/or Librarian).
  - Tells each role **exactly** which tools to use for a given task, including future tools that may be added.
- Enforces:
  - Feature isolation (no work on main).
  - DocIntent-before-change.
  - Docs-updated-before-commit.
- Triggers:
  - Auto-commit hook when QA+Docs confirm a slice is ready.

### 7.2 Librarian

- Reads everything:
  - Code, tests, docs, ADRs, messages.
- Provides **ContextPacks** with:
  - Relevant files, tests, docs.
  - Historical/architectural notes.
- Works with Docs to ensure Serena/memory (and future memory systems) reflect current docs.

### 7.3 Planner

- On `PlanRequest`, uses orchestrator-approved skills:
  - `superpowers_brainstorming` for approach exploration.
  - `superpowers_plan_writer` for sprint-style, granular planning.
- Produces a plan where each task includes:
  - Files to modify.
  - File docs to update.
  - Intended DocIntent summary.

### 7.4 Architect (Architecture Council)

- Handles large design changes first.
- Uses architecture skills/agents and Librarian context.
- Outputs:
  - Architecture decisions.
  - ADR-ready drafts.
- Coordinates with Docs to have decisions codified and committed.

### 7.5 Dev Instances (Dev-A, Dev-B, …)

- Follow TDD:
  - Write/extend tests before implementing behaviour.
- **Always emit DocIntent** before making changes.
- Use only tools authorised by Orchestrator, from the dynamic toolset defined in `toolset.yaml`.
- Coordinate with Docs:
  - Confirm which docs need updating.
- Mark tasks as “ready for QA” when code + tests appear solid.

### 7.6 QA Instances

- Validate code against:
  - Tests.
  - Spec/plan.
- Emit DocIntents for test-related changes and new behaviours found.
- Work with Docs to ensure edge cases are recorded.
- Report results via `QAResult` messages.

### 7.7 Docs Instance

- Receives DocIntents from all roles.
- Updates:
  - Per-file docs.
  - Feature changelog.
  - ADRs based on Architect outputs.
- Runs doc hooks:
  - `markdown_backup`.
  - `serena_index_refresh`.
- Signals Orchestrator via `DocsUpdated` when a slice is doc-complete.

---

## 8. Inter-Instance Communication

*(unchanged conceptually; supports any future message types as needed)*

### 8.1 Design Principles

- **Explicit message types** (not free-form chatter):
  - `ContextRequest`, `ContextPack`, `PlanRequest`, `Plan`, `TaskAssignment`,
    `DocIntent`, `QAResult`, `DocsUpdated`, etc.  
  New message types can be introduced as the system evolves.

- **Orchestrator-centric** routing:
  - Official communication flows via Orchestrator, even if panes can also “chat” directly.
- **Two transports**:
  1. tmux copy/paste + helper scripts (`tmux send-keys`, `capture-pane`).
  2. Shared “message board” files in `messages/` accessible via filesystem MCP.

*(Message templates as in previous version; omitted here for brevity in comments, but fully included in the actual spec.)*

---

## 9. Context Hygiene & Tool Exposure

*(clarifies that lists are open-ended and tools are referenced by IDs only)*

- Tools, skills, hooks, plugins, and agents are referred to **only by symbolic IDs**.
- No role is allowed to dump the full contents of `toolset.yaml` or tool docs into the conversation.
- When new tools are added, Orchestrator may:
  - Ask Librarian to summarise new capabilities.
  - Instruct roles to use new IDs with minimal additional context.
- The design supports an **open-ended toolset** without bloating prompts.

---

## 10. System-Comps & Prompt Assembly

*(unchanged, but implicitly supports future system-comps and roles)*

System-comps and `prompts.yaml` can be extended with new comps and roles over time; the assembly mechanism (`build_prompt.py`) remains the same.

---

## 11. Repo Layout & Bootstrap Scripts

*(unchanged from previous version; inherently supports expanded toolset and roles)*

The repo structure is designed to remain stable while you add:

- More hooks under `scripts/hooks/`.
- More tool capability cards under `tools/`.
- More system-comps under `system-comps/`.
- More roles and message files under `messages/`.

---

## 12. Example PoC Usage Flow

*(unchanged; works no matter how many tools/skills/hooks/agents you later add, as long as they’re registered and referenced by ID)*

This spec is a complete PoC design, including the unified toolset, role layout, communication protocol, Git hooks, documentation model, context hygiene rules, and bootstrap scripts required to make it work in practice, while **explicitly allowing the toolset (MCP servers, skills, hooks, agents, plugins) to grow and change over time** without rewriting the architecture.
