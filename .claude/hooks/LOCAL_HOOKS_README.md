# Local Git Hooks (User Customizations)

**IMPORTANT**: These hooks are LOCAL ONLY and should NOT be pushed to the repository.

## Custom Hooks (Not in dev/devtools/hooks/)

### 1. prepare-commit-msg (NEW - Local Only)
**Location**: `.git/hooks/prepare-commit-msg`
**Purpose**: Auto-enhance commit messages with issue numbers and conventional commit suggestions
**Trigger**: Before commit message editor opens

**Features**:
- Extracts issue number from branch name (e.g., `feature/fix-order-bug-216` → adds `Refs #216`)
- Suggests conventional commit type based on changed files:
  - `topstepx_backend/api/routes` → `feat(api):`
  - `topstepx_backend/services` → `fix(services):`
  - `topstepx_backend/strategy` → `feat(strategy):`
  - `topstepx_frontend/src/components` → `feat(ui):`
  - Files with `test` → `test:`
  - `*.md` files → `docs:`

**Created**: 2025-10-29

---

### 2. post-checkout (ENHANCED - Local Only)
**Location**: `.git/hooks/post-checkout`
**Purpose**: Environment sync + fast session refresh
**Trigger**: After branch checkout

**Features**:
- Original: Runs `make session-refresh` for semantic index update
- **ENHANCED (Local Only)**:
  - Warns if `package.json` changed → suggests `npm install`
  - Warns if Python dependencies changed → suggests `pip install -e .`
  - Warns if backend code changed and backend is running → suggests restart
  - Warns if Makefile changed → suggests `make dev`

**Base version in**: `dev/devtools/hooks/post-checkout` (tracked)
**Enhanced version**: `.git/hooks/post-checkout` (local only)
**Created**: 2025-10-29

---

### 3. pre-rebase (NEW - Local Only)
**Location**: `.git/hooks/pre-rebase`
**Purpose**: Prevent dangerous rebase operations
**Trigger**: Before rebase operation

**Features**:
- **BLOCKS**: Rebasing main/master/production branches (always blocked)
- **WARNS**: Rebasing pushed branches (requires confirmation)
  - Shows commit statistics
  - Warns about force-push requirements
  - Interactive confirmation prompt
- **ALLOWS**: Rebasing unpushed feature branches (no warning)

**Created**: 2025-10-29

---

## Repository-Tracked Hooks (in dev/devtools/hooks/)

These hooks ARE tracked and shared with the team:
1. **pre-commit** - Semantic index + graphs + hygiene
2. **commit-msg** - Conventional Commits validation
3. **post-commit** - Auto-sync OpenAPI + types
4. **pre-push** - Full CI validation
5. **post-checkout** - Basic cleanup (base version)
6. **post-merge** - Basic sync

---

## Maintenance

**To reinstall tracked hooks**:
```bash
make hooks-install
```
⚠️ **WARNING**: This will overwrite `.git/hooks/post-checkout` with base version.

**To restore custom hooks after reinstall**:
```bash
# The 3 custom hooks are backed up in this directory
cp /home/buckstrdr/git_hooks_backup/* .git/hooks/
chmod +x .git/hooks/prepare-commit-msg
chmod +x .git/hooks/pre-rebase
# For post-checkout, manually re-add the enhanced section
```

**Backup location**: `/home/buckstrdr/git_hooks_backup/`

---

## Philosophy

These local hooks enhance YOUR workflow without imposing them on the team:
- **prepare-commit-msg**: Your personal commit message helper
- **post-checkout (enhanced)**: Your environment sync assistant
- **pre-rebase**: Your safety guard against git mistakes

The team gets the standard hooks from `dev/devtools/hooks/`.
You get enhanced productivity with these local customizations.

Similar to your `.claude/skills/` and local `CLAUDE.md` - these are YOUR tools.
