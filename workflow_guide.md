# Claude Code Workflow System Guide

**Last Updated**: November 15, 2025
**Purpose**: Comprehensive guide to all development workflows, tools, skills, hooks, and automation

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Session Initialization](#session-initialization)
3. [Claude Code Skills](#claude-code-skills)
4. [Git Hooks System](#git-hooks-system)
5. [Auto-Commit System](#auto-commit-system)
6. [Quality Gate Workflow](#quality-gate-workflow)
7. [UI Verification](#ui-verification)
8. [Makefile Commands](#makefile-commands)
9. [Bash Aliases](#bash-aliases)
10. [MCP Servers](#mcp-servers)
11. [Plugins](#plugins)
12. [Best Practices](#best-practices)

---

## Quick Start

### Starting a New Session

```bash
# 1. Start all MCP servers first (CRITICAL)
make mcp-start

# 2. Initialize session (MANDATORY)
/startup

# 3. Check system status
/status

# 4. Start coding!
```

### Ending a Session

```bash
# 1. Run session end workflow
/session-end

# 2. Review any uncommitted changes
git status

# 3. Create PR if needed
git push origin <branch>
```

---

## Session Initialization

### The `/startup` Skill (MANDATORY)

**Every new Claude Code session MUST run `/startup` first.**

#### What It Does

1. ✅ Verifies MCP servers are running
2. ✅ Loads available memories dynamically
3. ✅ Checks git status
4. ✅ Assesses repository state (OpenAPI, semantic index, types)
5. ✅ Verifies skills, plugins, and hooks
6. ✅ Checks auto-commit service status
7. ✅ Provides session readiness report

#### Example Output

```
## Session Initialization Summary

**MCP Status**: RUNNING
- Serena: ✓
- Context7: ✓
- Firecrawl: ✓
- Playwright: ✓

**Knowledge Base**:
- Memories loaded: 2 (operational_deep_dive_2025_10_26, program_architecture_2025_10_26)
- Semantic index: ✓
- OpenAPI spec: ✓
- Frontend types: SYNCED

**Repository State**:
- Branch: main
- Uncommitted changes: 0 files
- Recent commits: [last 3 subjects]

**Development Tools**:
- Skills: 36 skills available
- Plugins: Superpowers loaded ✓
- Git Hooks: 9 hooks active
- Auto-commit: RUNNING

**Readiness Level**: OPTIMAL
```

---

## Claude Code Skills

### All Available Skills (36 Total)

#### Workflow Skills (14)

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/startup` | Initialize session | **MANDATORY** at session start |
| `/status` | Check system health | When services might be down |
| `/start` | Start backend/frontend | When servers aren't running |
| `/logs` | View service logs | Debugging issues |
| `/find` | Smart code search | Finding code quickly |
| `/sync` | Sync OpenAPI + types | After backend API changes |
| `/restart` | Restart services | When services hang |
| `/debug` | Debug assistance | When stuck on a bug |
| `/test` | Run tests | After code changes |
| `/clean` | Clean caches | When build issues occur |
| `/strategy` | Strategy development | Working with strategies |
| `/smoke` | Run smoke tests | Validating system behavior |
| `/api` | API development | Working with FastAPI |
| `/triage` | Issue triage | Handling GitHub issues |
| `/github` | GitHub operations | Creating issues/PRs |

#### Technology Expert Skills (11)

| Skill | Expertise | When to Use |
|-------|-----------|-------------|
| `/python` | Python 3.11+ patterns | Python best practices |
| `/fastapi` | FastAPI development | API endpoint work |
| `/react` | React 18+ patterns | React component work |
| `/typescript` | TypeScript guidance | Type definitions |
| `/pydantic` | Pydantic models | Data validation |
| `/asyncio` | Async patterns | Async/await code |
| `/websocket` | WebSocket patterns | Real-time features |
| `/zustand` | Zustand state | Frontend state management |
| `/tailwind` | Tailwind CSS | UI styling |
| `/trading` | Trading systems | Trading domain logic |

#### Quality Assurance Skills (3)

| Skill | Purpose | **AUTOMATIC TRIGGER** |
|-------|---------|----------------------|
| `/validator` | Task completion validation | After completing features |
| `/karen` | Reality check (brutal honesty) | Before milestones/releases |
| `/pragmatist` | Anti-over-engineering | After implementations |

**⚠️ IMPORTANT**: These skills should be invoked **AUTOMATICALLY** based on triggers, not just on request.

#### Development Process Skills (8)

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/spec` | Create feature specification | Before implementing features |
| `/gates` | Quality gate management | Managing 7-stage workflow |
| `/verify-complete` | Verify work completion | Before marking work done |
| `/e2e-verify` | End-to-end verification | After major changes |
| `/ui-verify` | UI verification (Playwright) | **AUTOMATIC** after frontend changes |
| `/adr` | Architecture decision records | Documenting design decisions |
| `/session-end` | End session workflow | At session end |
| `/create-strategy` | Create new strategy | Adding new trading strategies |

### Skill Usage Patterns

#### Standard Workflow

```bash
# 1. Initialize
/startup

# 2. Create specification
/spec
> Feature: Order idempotency
> [Detailed spec...]

# 3. Implement with TDD
# Write tests first...
# Then implement...

# 4. Validate
/validator
> CONTEXT: Implemented order idempotency...

# 5. Check for over-engineering
/pragmatist
> CONTEXT: Order idempotency implementation...

# 6. End-to-end verification
/e2e-verify

# 7. End session
/session-end
```

---

## Git Hooks System

### Active Hooks (9 Total)

#### Repository Hooks (6)

| Hook | Trigger | Purpose | Strict Mode |
|------|---------|---------|-------------|
| `pre-commit` | Before commit | Fast hygiene (semantic + graphs) | Warn-only |
| `commit-msg` | After commit message | Conventional Commits check | Warn-only |
| `post-commit` | After commit | Regenerate OpenAPI + types if backend changed | Always |
| `pre-push` | Before push | Full CI validation (`make ci-check`) | `STRICT_HOOKS=1` |
| `post-checkout` | After branch switch | Show quality gate workflow reminder | Always |
| `post-merge` | After merge | Rebuild artifacts | Always |

#### Local Custom Hooks (3)

| Hook | Purpose |
|------|---------|
| `prepare-commit-msg` | Add commit templates |
| `pre-rebase` | Safety checks before rebase |
| `pre-push-cleanup-wip` | Clean up WIP commits |

### Hook Management

```bash
# Install hooks (symlinked from dev/devtools/hooks/)
make hooks-install

# Enable strict mode (blocks on failures)
make hooks-strict-on
export STRICT_HOOKS=1

# Disable strict mode (warnings only)
make hooks-strict-off
export STRICT_HOOKS=0
```

### Hook Behavior

#### Pre-Commit Hook

**What it does**:
1. Incremental semantic index update
2. Minimal graphs update (fast)
3. Check for loose documentation files in root
4. Enforce `.ian/` for new session files

**Blocks if**:
- New `.md` files added to root (should be in `.ian/`)
- New test files in root (should be in proper test directories)

**Bypass**:
```bash
SKIP_HOOKS=1 git commit -m "emergency: bypass hooks"
```

#### Pre-Push Hook

**What it does**:
1. Checks if pushing to main/master
2. Verifies quality gates (if feature branch)
3. Runs full CI validation (`make ci-check`)
4. Checks for auto-commits (warns to squash)

**Blocks if** (when `STRICT_HOOKS=1`):
- Quality Gate 7 not passed
- CI validation fails
- Work marked incomplete

**Bypass**:
```bash
STRICT_HOOKS=0 git push origin main
```

#### Post-Commit Hook

**What it does**:
1. Detects if backend code changed
2. Regenerates OpenAPI spec (`make openapi`)
3. Regenerates frontend types (`make types`)
4. Ensures API contract stays in sync

**Result**: Frontend types always match backend API.

---

## Auto-Commit System

### Overview

**A systemd user service runs continuously, auto-committing changes every 30 seconds.**

### What It Watches

- ✅ `your_backend/` - All backend code (customize to your project structure)
- ✅ `your_frontend/` - All frontend code (customize to your project structure)
- ❌ `.serena/` - Ignored
- ❌ `dev/` - Ignored
- ❌ `docs/` - Ignored
- ❌ `data/` - Ignored

### Commands

```bash
# Check service status
commitstatus

# Watch commits happen in real-time
commitlog

# Roll back last commit (keep changes)
undo

# Roll back last commit (discard everything)
undo!

# Go back multiple commits
goback 3        # Keep changes
goback! 3       # Discard changes

# Restart service
commitrestart

# Stop service (will auto-start on next login)
commitstop

# Start service
commitstart
```

### Commit Format

```
Auto-commit: 2025-10-31 15:02:26
```

### Before Pushing

**Pre-push hook warns about auto-commits:**

```
⚠️  WARNING: You have auto-commits that will be pushed
Consider squashing: git rebase -i origin/main
Continue? (y/N)
```

**Recommended**: Squash auto-commits into meaningful commits before pushing.

```bash
# Interactive rebase
git rebase -i origin/main

# Mark commits to squash, write proper message
# Then push
git push origin main
```

---

## Quality Gate Workflow

### The 7-Stage Workflow (MANDATORY for main)

Every feature MUST progress through these gates:

```
Gate 1: Spec Approved          → /spec
Gate 2: Tests First (TDD)      → Write tests FIRST (Red phase)
Gate 3: Implementation         → Make tests pass (Green phase)
Gate 4: Refactored             → Clean code (maintain Green)
Gate 5: Integrated             → make openapi && make types
Gate 6: E2E Verified           → /e2e-verify
Gate 7: Code Reviewed          → /validator
```

### Quality Gate Commands

```bash
# Start tracking new feature
/gates start order_idempotency

# Check current status
/gates

# Advance to next gate (validates requirements first)
/gates pass

# View all features
/gates status
```

### Gate Storage

Gates are tracked in:
```
.git/quality-gates/<feature_name>/
├── status.json
├── gate_1_spec.md
├── gate_2_tests.txt
└── ...
```

### Enforcement

**Pre-push hook enforces**:
- ✅ Gate 7 (Code Reviewed) MUST be PASSED before pushing to main/master
- ✅ Completeness verification must pass
- ✅ Full CI validation must pass

**CI workflow enforces**:
- ✅ Quality gate tracking exists for PR
- ✅ Gate 7 is PASSED
- ✅ No TODOs/FIXMEs in production
- ✅ Backend tests pass
- ✅ Frontend builds

---

## UI Verification

### The `/ui-verify` Skill (AUTOMATIC)

**EVERY frontend change MUST be verified with Playwright. Git hook enforces this.**

### What It Does

1. ✅ Checks backend/frontend servers running
2. ✅ Navigates to UI with Playwright
3. ✅ Captures console logs (errors, warnings)
4. ✅ Takes full-page screenshot at 1920x1080
5. ✅ Verifies key UI elements present
6. ✅ Generates verification report

### When It Runs

**Automatically triggered**:
- After modifying files in `your_frontend/src/`
- Pre-commit hook detects frontend changes
- Blocks commit if verification failed or missing

### Usage

```bash
# Manual verification
/ui-verify

# Output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  UI Verification - 2025-10-31 15:45:30
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Step 1: Checking servers...
✓ Backend running (PID: 1847003)
✓ Frontend running (PID: 1848123)

→ Step 2: Navigating to UI...
✓ Page loaded: http://localhost:5173

→ Step 3: Checking console logs...
✓ No critical console errors

→ Step 4: Taking screenshot...
✓ Screenshot saved

→ Step 5: Verifying UI elements...
✓ All key UI elements present

✅ UI verification PASSED
```

### Verification Report

Saved to: `.ian/ui_verify_{timestamp}.md`

**Contains**:
- Status: PASSED/FAILED
- Console log analysis
- Screenshot location
- Missing elements (if any)
- Timestamp and git context

### Bypass (NOT RECOMMENDED)

```bash
STRICT_UI=0 git commit -m "emergency: skip UI verification"
```

---

## Makefile Commands

### Quick Commands

```bash
# Fast refresh (semantic index only)
make dev

# Full rebuild (all artifacts + types)
make full

# Start all MCP servers (do this first!)
make mcp-start
```

### Individual Artifacts

```bash
# Generate OpenAPI from FastAPI
make openapi

# Build code graphs (BE/FE/API)
make graphs
make graphs-fast  # Minimal graphs (faster)

# Update semantic search index
make semantic              # Incremental
make semantic-rebuild      # Full rebuild

# Sync FE types from OpenAPI
make types
```

### MCP Management

```bash
# Start all shared MCP servers
make mcp-start

# Stop all MCP servers
make mcp-stop

# Restart all MCP servers
make mcp-restart

# Show MCP server logs
make mcp-logs

# Check which MCPs are running
make mcp-status
```

### CI/Validation

```bash
# Run all CI validations locally
make ci-check

# Clean bytecode/caches
make hygiene
```

### Git Hooks

```bash
# Install local git hooks (symlinked)
make hooks-install

# Enforce hooks (fail on issues)
make hooks-strict-on

# Warn-only hooks
make hooks-strict-off
```

### Service Management

```bash
# Start backend in background
make backend-start

# Stop backend
make backend-stop

# Start frontend dev server
make frontend-start

# Stop frontend
make frontend-stop
```

---

## Bash Aliases

### Auto-Commit Aliases

```bash
commitstatus      # Check auto-commit service status
commitlog         # Watch commits in real-time
commitrestart     # Restart auto-commit service
commitstop        # Stop auto-commit service
commitstart       # Start auto-commit service
```

### Undo Aliases

```bash
undo             # Roll back last commit (keep changes)
undo!            # Roll back last commit (discard changes)
goback 3         # Go back 3 commits (keep changes)
goback! 3        # Go back 3 commits (discard changes)
```

### Commit History Aliases

```bash
commits          # Show last 20 commits
commitswhen      # Show commits with timestamps
commitfind       # Search commit messages
filehistory      # Show commit history for specific file
commits1h        # Commits from last hour
commitstoday     # Commits from today
```

---

## MCP Servers

### Available MCP Servers

| Server | Purpose | Port/Status |
|--------|---------|-------------|
| **Serena** | Code navigation, symbol search, memory | Critical |
| **Context7** | Library documentation | Optional |
| **Firecrawl** | Web scraping | Optional |
| **Playwright** | Browser automation (UI verify) | Critical for UI |
| **OpenAPI** | API documentation | Optional |
| **Filesystem** | File operations | Core |
| **Git** | Git operations | Core |
| **Sequential Thinking** | Reasoning | Core |

### MCP Commands

```bash
# Start all MCPs
make mcp-start

# Check status
make mcp-status

# Restart if issues
make mcp-restart

# View logs
make mcp-logs
```

### Critical MCPs

**Serena** is CRITICAL - session capability severely degraded without it.

**Playwright** is CRITICAL for UI verification workflow.

---

## Plugins

### Superpowers Plugin

**Status**: Loaded and active

**Provides**:
- Advanced workflow skills
- Code review agents
- QA gatekeeper
- Documentation architect
- Full-stack engineer

**Skills from Superpowers**:
- `brainstorming` - Refine ideas before coding
- `test-driven-development` - TDD workflow enforcement
- `systematic-debugging` - 4-phase debugging framework
- `verification-before-completion` - Verify before claiming done
- `code-reviewer` - Automated code review
- Plus 15 more...

**Usage**: Skills are invoked via `/skill-name` or Skill tool.

### The 3-Step Superpowers Workflow (MANDATORY for Complex Features)

For any complex feature or significant implementation, use this 3-step workflow:

#### Step 1: `/superpowers:brainstorm` - Refine Ideas

**Purpose**: Transform rough ideas into fully-formed designs through Socratic questioning.

**When to Use**:
- Before implementing any new feature
- When requirements are unclear or vague
- Before writing specifications
- When exploring alternative approaches

**What It Does**:
1. Asks clarifying questions about your idea
2. Explores edge cases and alternatives
3. Identifies potential issues early
4. Validates assumptions
5. Produces a refined design ready for planning

**Example**:
```bash
/superpowers:brainstorm

> User: I want to add order idempotency to prevent duplicate submissions
> Skill: [Asks Socratic questions]
> - What triggers a duplicate? Network retry? User double-click?
> - How long should idempotency window be? 1 minute? 1 hour?
> - What storage mechanism? In-memory? Redis? Database?
> - How do we handle order modifications vs true duplicates?
> [Explores alternatives, validates design]
> Result: Fully-formed idempotency design ready for planning
```

#### Step 2: `/superpowers:write-plan` - Create Implementation Plan

**Purpose**: Convert refined design into detailed, testable implementation tasks.

**When to Use**:
- After brainstorming is complete
- Before any coding begins
- When you have a clear design

**What It Does**:
1. Creates comprehensive PRD (Product Requirements Document)
2. Breaks down into discrete, testable sprints
3. Defines TDD/SDD approach
4. Establishes acceptance criteria
5. Documents dependencies and risks
6. Creates verification steps

**Output**: Detailed plan with:
- Architecture design
- Data models
- API contracts
- Sprint breakdown
- Test requirements
- Success metrics

**Example**:
```bash
/superpowers:write-plan

> Input: [Refined idempotency design from brainstorming]
> Output: Detailed plan saved to .ian/plan_order_idempotency.md

Plan includes:
- Sprint 1: Idempotency store infrastructure (2 days)
  - Task 1.1: Create IdempotencyStore class
  - Task 1.2: Add Redis persistence
  - Task 1.3: Write unit tests
  - Acceptance: Store can track order IDs with TTL

- Sprint 2: Integration with OrderService (1 day)
  - Task 2.1: Add deduplication check before submission
  - Task 2.2: Handle idempotency key generation
  - Task 2.3: Write integration tests
  - Acceptance: Duplicate orders rejected

- Sprint 3: Testing and validation (1 day)
  - Task 3.1: Load testing
  - Task 3.2: Race condition testing
  - Task 3.3: Documentation
  - Acceptance: 99.9% duplicate prevention
```

#### Step 3: `/superpowers:execute-plan` - Execute in Batches

**Purpose**: Execute the plan in controlled batches with review checkpoints.

**When to Use**:
- After plan is created and approved
- When ready to implement

**What It Does**:
1. Loads the implementation plan
2. Reviews plan critically (sanity check)
3. Executes tasks in batches
4. Reports progress after each batch
5. Waits for your review/approval before next batch
6. Maintains quality gates throughout

**Workflow**:
```bash
/superpowers:execute-plan

> Loading plan: .ian/plan_order_idempotency.md
> Reviewing plan... ✓ Plan looks good

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  BATCH 1: Idempotency Store Infrastructure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Task 1.1: Create IdempotencyStore class
  [Implementation...]
  ✓ Complete

→ Task 1.2: Add Redis persistence
  [Implementation...]
  ✓ Complete

→ Task 1.3: Write unit tests
  [Tests...]
  ✓ All tests pass

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  BATCH 1 COMPLETE - Review Requested
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Changes:
- Created: your_backend/services/idempotency_store.py
- Created: your_backend/tests/test_idempotency_store.py
- Modified: your_backend/services/__init__.py

Please review before proceeding to Batch 2.
Continue? (y/n)
```

### When to Use the 3-Step Workflow

**MANDATORY for**:
- ✅ New features (any non-trivial implementation)
- ✅ Complex refactoring
- ✅ Architecture changes
- ✅ Multi-sprint projects
- ✅ Unclear requirements

**Optional for**:
- ⚠️ Small bug fixes (can skip directly to implementation)
- ⚠️ Trivial changes (typos, formatting)
- ⚠️ Well-defined tasks (specification already clear)

### Complete 3-Step Workflow Example

```bash
# Starting with vague idea
User: "I want better error handling in order submission"

# Step 1: Brainstorm
/superpowers:brainstorm
> Skill explores: What errors? Network? Validation? How to handle?
> Result: Refined design with retry logic, circuit breaker, detailed error codes

# Step 2: Write Plan
/superpowers:write-plan
> Input: Refined design
> Output: .ian/plan_order_error_handling.md
> Contains: 3 sprints, 12 tasks, acceptance criteria, test plan

# Step 3: Execute Plan
/superpowers:execute-plan
> Loads plan
> Executes Batch 1 (Tasks 1-4)
> Reports completion, waits for review
> User approves
> Executes Batch 2 (Tasks 5-8)
> ... continues through all batches
> Final result: Fully implemented, tested feature
```

### Benefits of 3-Step Workflow

1. **Clarity Before Coding**: No coding until design is clear
2. **Reduced Rework**: Catch issues in design phase, not implementation
3. **Testable Plans**: Every task has acceptance criteria
4. **Review Checkpoints**: Human review between batches prevents runaway implementation
5. **Quality Enforcement**: TDD/SDD baked into every sprint
6. **Traceable Decisions**: All design decisions documented

### Integration with Quality Gates

The 3-step workflow naturally maps to quality gates:

```
/superpowers:brainstorm     → Refined design
/superpowers:write-plan     → Gate 1 (Spec Approved)
/superpowers:execute-plan   → Gates 2-6 (execution)
/validator                  → Gate 7 (Code Reviewed)
```

---

## Best Practices

### Session Workflow

1. ✅ **ALWAYS** start with `/startup`
2. ✅ Check MCP status first (`make mcp-status`)
3. ✅ Use skills proactively (don't wait to be asked)
4. ✅ Run `/validator` after completing features
5. ✅ Run `/ui-verify` after frontend changes
6. ✅ End with `/session-end`

### Code Quality

1. ✅ Write tests FIRST (TDD)
2. ✅ Follow 7-stage quality gate workflow
3. ✅ Run `/pragmatist` to avoid over-engineering
4. ✅ Use `/karen` for reality checks before milestones
5. ✅ Never skip UI verification for frontend changes

### Commit Hygiene

1. ✅ Let auto-commit handle frequent checkpoints
2. ✅ Squash auto-commits before pushing
3. ✅ Use Conventional Commits format
4. ✅ Create meaningful commit messages
5. ✅ Don't bypass hooks without good reason

### File Organization

1. ✅ Backend code in `your_backend/`
2. ✅ Frontend code in `your_frontend/`
3. ✅ Session research/temp files in `.ian/`
4. ✅ Production tests in proper test directories
5. ✅ NEVER commit `.ian/` files to git

### Quality Gates

1. ✅ Always use `/gates start <feature>` for new features
2. ✅ Validate requirements before advancing gates
3. ✅ Gate 7 (Code Reviewed) required before pushing to main
4. ✅ Document all gate completions
5. ✅ Use `/verify-complete` before marking done

---

## Common Workflows

### New Feature Development (with 3-Step Superpowers Workflow)

```bash
# 1. Initialize session
/startup

# 2. Brainstorm and refine the idea (MANDATORY for complex features)
/superpowers:brainstorm
> User: I want to add order idempotency
> [Socratic questioning process...]
> Result: Fully-formed design

# 3. Create detailed implementation plan
/superpowers:write-plan
> Input: Refined design from brainstorming
> Output: .ian/plan_order_idempotency.md (detailed plan with sprints)

# 4. Create feature branch
git checkout -b feature/order-idempotency

# 5. Start quality gates
/gates start order_idempotency

# 6. Mark Gate 1 complete (spec approved)
/gates pass

# 7. Execute plan in batches with review checkpoints
/superpowers:execute-plan
> Loading plan: .ian/plan_order_idempotency.md
> Batch 1: [Implements tasks 1-3]
> Review requested...
> User approves
> Batch 2: [Implements tasks 4-6]
> ... continues through all batches

# 8. Final code review
/validator
> CONTEXT: Order idempotency implementation complete

# 9. Mark Gate 7 complete
/gates pass

# 10. Push to main
git push origin main
# Pre-push hook validates Gate 7 ✓
```

### Alternative: Traditional Step-by-Step (for simpler features)

```bash
# 1. Initialize session
/startup

# 2. Create feature branch
git checkout -b feature/order-idempotency

# 3. Start quality gates
/gates start order_idempotency

# 4. Create specification (manual)
/spec
> Feature: Order idempotency...

# 5. Advance Gate 1
/gates pass

# 6. Write tests FIRST (TDD Red)
# Create tests...
git add tests/
git commit -m "test: add order idempotency tests"

# 7. Advance Gate 2
/gates pass

# 8. Implement (TDD Green)
# Write implementation...
git add src/
git commit -m "feat: implement order idempotency"

# 9. Advance Gate 3
/gates pass

# 10. Refactor (TDD Refactor)
/pragmatist
> CONTEXT: Order idempotency implementation...
# Apply suggestions...

# 11. Advance Gate 4
/gates pass

# 12. Integrate
make openapi && make types
/gates pass  # Gate 5

# 13. E2E verification
/e2e-verify
/gates pass  # Gate 6

# 14. Code review
/validator
> CONTEXT: Order idempotency implementation...
/gates pass  # Gate 7

# 15. Push to main
git push origin main
# Pre-push hook validates Gate 7 ✓
```

### Bug Fix Workflow

```bash
# 1. Initialize
/startup

# 2. Create fix branch
git checkout -b fix/order-duplication

# 3. Start gates (even for fixes)
/gates start order_duplication_fix

# 4. Minimal spec
/spec
> Bug: Orders submitted twice...

# 5. Write regression test FIRST
# Test reproduces bug...
git commit -m "test: regression test for order duplication"

# 6. Fix bug
# Implementation...
git commit -m "fix: prevent duplicate order submission"

# 7. Follow remaining gates
/gates pass  # Progress through gates
make openapi && make types
/e2e-verify
/validator

# 8. Push
git push origin main
```

### Frontend UI Change

```bash
# 1. Modify component
# Edit: your_frontend/src/components/OrderEntry.tsx

# 2. Run UI verification (MANDATORY)
/ui-verify

# Output:
✅ UI verification PASSED

# 3. Review report
cat .ian/ui_verify_20251031_154530.md

# 4. Check screenshot
open .playwright-mcp/.ian/ui_verify_20251031_154530.png

# 5. Commit (pre-commit hook checks for verification)
git commit -m "feat: update order entry UI"
# Hook validates recent verification exists ✓
```

---

## Troubleshooting

### MCP Servers Not Running

```bash
# Check status
make mcp-status

# Restart if needed
make mcp-restart

# View logs for errors
make mcp-logs
```

### Auto-Commit Service Down

```bash
# Check status
commitstatus

# Restart
commitrestart

# Check logs
commitlog
```

### UI Verification Failed

```bash
# Check backend running
curl http://localhost:8000/health

# Check frontend running
curl http://localhost:5173

# Restart services
make backend-restart
make frontend-restart

# Re-run verification
/ui-verify
```

### Git Hook Blocking Commit

```bash
# Check what's blocking
git commit -m "test"

# Fix issues, or bypass (NOT RECOMMENDED)
STRICT_HOOKS=0 git commit -m "emergency"
```

---

## Quick Reference

### Most Used Commands

```bash
# Session management
/startup                      # Start session (MANDATORY)
/status                       # Check health
/session-end                  # End session

# 3-Step Superpowers Workflow (for complex features)
/superpowers:brainstorm       # Step 1: Refine ideas (Socratic questioning)
/superpowers:write-plan       # Step 2: Create detailed plan (PRD + sprints)
/superpowers:execute-plan     # Step 3: Execute in batches (with review)

# Development
/find <query>          # Smart code search
/test                  # Run tests
/logs                  # View logs

# Quality assurance
/validator             # Validate completion
/pragmatist            # Check for over-engineering
/karen                 # Reality check

# Frontend
/ui-verify             # UI verification (Playwright)

# Backend
/sync                  # Sync OpenAPI + types

# Git
make hooks-install     # Install hooks
undo                   # Roll back last commit
commits                # View recent commits
```

### Environment Variables

```bash
# Git hooks
STRICT_HOOKS=1         # Enforce hooks (block on fail)
STRICT_HOOKS=0         # Warn-only mode

STRICT_TDD=1           # Enforce test-first development
STRICT_TDD=0           # Allow implementation without tests

STRICT_UI=1            # Enforce UI verification
STRICT_UI=0            # Skip UI verification (emergency)

# Development
DEBUG=1                # Enable debug logging
```

---

## Summary

This workflow guide documents the complete Claude Code workflow system:

- **36 Claude Code Skills** for automation and guidance
- **9 Git Hooks** for code quality and automation
- **Auto-Commit System** for continuous checkpoints
- **7-Stage Quality Gates** for production-ready code
- **UI Verification** with Playwright
- **Makefile Commands** for common operations
- **Bash Aliases** for productivity
- **MCP Servers** for enhanced capabilities

**Philosophy**: Automate quality, enforce discipline, make production-ready code the default.

**Next Steps**:
1. Always run `/startup` at session start
2. Follow quality gate workflow for features
3. Use skills proactively
4. Let automation handle repetitive tasks
5. Focus on writing great code

---

**Document Version**: 1.0
**Last Updated**: October 31, 2025
**Note**: Customize paths and project-specific details for your project
**Location**: `.ian/workflow_guide.md`
