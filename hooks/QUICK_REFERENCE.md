# Quick Reference: Your Local Git Hooks

## What You Have

**9 Total Hooks Installed**:
- 6 from repository (`dev/devtools/hooks/` - shared with team)
- 3 custom LOCAL ONLY (yours only)

## The 3 Custom Hooks (Local Only)

### 1. prepare-commit-msg
Auto-adds issue numbers from branch names and suggests commit types.

**Example**:
```bash
git checkout -b feature/fix-order-216
# ... make changes ...
git commit
# → Message editor opens with "Refs #216" already added
# → Shows suggestions: "fix(services): ..." based on changed files
```

### 2. post-checkout (enhanced)
Warns about environment changes after branch switches.

**Example**:
```bash
git checkout feature/new-frontend-lib
# → [post-checkout] Checking environment sync...
# → ⚠️  package.json changed - run: cd topstepx_frontend && npm install
```

### 3. pre-rebase
Prevents dangerous rebases, warns about force-push requirements.

**Example**:
```bash
git checkout main
git rebase feature/something
# → ❌ ERROR: Cannot rebase main branch
```

## Important Notes

✅ **These hooks are LOCAL ONLY** - they will never be pushed to remote
✅ **Backed up** at: `/home/buckstrdr/git_hooks_backup/`
✅ **Documented** at: `.git/hooks/LOCAL_HOOKS_README.md`

⚠️ **If you run `make hooks-install`**:
- The 6 repository hooks will be reinstalled
- `post-checkout` will be overwritten with base version
- `prepare-commit-msg` and `pre-rebase` will remain (not in repository)
- To restore enhanced `post-checkout`, copy from backup

## Quick Commands

```bash
# List all installed hooks
ls -la .git/hooks/ | grep -v ".sample"

# View a hook
cat .git/hooks/prepare-commit-msg

# Disable a hook temporarily
mv .git/hooks/prepare-commit-msg .git/hooks/prepare-commit-msg.disabled

# Re-enable
mv .git/hooks/prepare-commit-msg.disabled .git/hooks/prepare-commit-msg

# Skip hooks for one commit (use sparingly!)
git commit --no-verify -m "emergency fix"
```

## Philosophy

Just like your `.claude/skills/` and local `CLAUDE.md`:
- **Yours only** - not shared with team
- **Enhances YOUR workflow** - without imposing on others
- **Safe and recoverable** - backed up at `/home/buckstrdr/git_hooks_backup/`

The team uses standard hooks from `dev/devtools/hooks/`.
You use those PLUS these 3 custom productivity enhancers.
