# GitHub - Issue and PR Management

Comprehensive GitHub CLI operations for managing issues, pull requests, and repository workflows.

## What This Skill Does

Provides commands for:
- Creating and managing issues
- Adding comments and labels
- Closing issues with documentation
- Creating pull requests
- Viewing PR and issue status
- Searching issues and PRs

## Prerequisites

```bash
# Verify GitHub CLI is authenticated
gh auth status

# If not authenticated, run:
~/quick_github_auth.sh
```

## Common Operations

### 1. List Issues

```bash
# List all open issues
gh issue list

# List issues with specific label
gh issue list --label "backend"
gh issue list --label "bug"

# List issues assigned to you
gh issue list --assignee @me

# List by state
gh issue list --state "open"
gh issue list --state "closed"
gh issue list --state "all"
```

### 2. View Issue Details

```bash
# View specific issue
gh issue view 42

# View issue in browser
gh issue view 42 --web

# View issue comments
gh issue view 42 --comments
```

### 3. Create Issue

```bash
# Interactive creation
gh issue create

# Direct creation with title and body
gh issue create --title "Backend: Fix order submission" --body "Order submission fails when..."

# With labels
gh issue create --title "Title" --body "Body" --label "backend,bug"

# With assignee
gh issue create --title "Title" --body "Body" --assignee your-github-username
```

### 4. Update Issue

```bash
# Add comment
gh issue comment 42 --body "Investigation complete. Root cause identified..."

# Add labels
gh issue edit 42 --add-label "priority:high,backend"

# Remove labels
gh issue edit 42 --remove-label "needs-triage"

# Change title
gh issue edit 42 --title "New title"

# Assign/unassign
gh issue edit 42 --add-assignee your-github-username
gh issue edit 42 --remove-assignee your-github-username
```

### 5. Close Issue (WITH DOCUMENTATION)

**IMPORTANT**: Always create resolution doc in `.ian/` before closing:

```bash
# Step 1: Create resolution document
touch .ian/issue_42_resolution.md
# Document the fix, changes, verification, impact

# Step 2: Close with reference to resolution
gh issue close 42 --comment "$(cat .ian/issue_42_resolution.md)"

# OR close with simple comment
gh issue close 42 --comment "Fixed in commit abc123. See resolution doc for details."
```

### 6. Reopen Issue

```bash
gh issue reopen 42 --comment "Issue reoccurred. Reopening for further investigation."
```

### 7. Search Issues

```bash
# Search by keyword
gh issue list --search "order submission"

# Search in specific state
gh issue list --search "websocket" --state "closed"

# Advanced search
gh search issues "repo:your-github-username/TopStepx order submission"
```

## Pull Request Operations

### 1. List PRs

```bash
# List all open PRs
gh pr list

# List by state
gh pr list --state "open"
gh pr list --state "closed"
gh pr list --state "merged"
```

### 2. View PR

```bash
# View PR details
gh pr view 10

# View in browser
gh pr view 10 --web

# View diff
gh pr diff 10
```

### 3. Create PR

```bash
# Interactive creation
gh pr create

# Direct creation
gh pr create --title "Fix: Order idempotency" --body "Implementation details..."

# With base branch
gh pr create --title "Title" --body "Body" --base main

# Draft PR
gh pr create --title "Title" --body "Body" --draft
```

### 4. Update PR

```bash
# Add comment
gh pr comment 10 --body "Updated implementation based on review."

# Mark ready for review (from draft)
gh pr ready 10

# Request review
gh pr edit 10 --add-reviewer username
```

### 5. Merge PR

```bash
# Merge with squash
gh pr merge 10 --squash

# Merge with merge commit
gh pr merge 10 --merge

# Merge with rebase
gh pr merge 10 --rebase

# Delete branch after merge
gh pr merge 10 --squash --delete-branch
```

### 6. Check PR Status

```bash
# View checks
gh pr checks 10

# View review status
gh pr status
```

## Workflow Integration

### Issue Investigation Workflow

```bash
# 1. Create investigation doc
touch .ian/issue_42_investigation.md

# 2. Add initial findings
echo "# Issue #42 Investigation" > .ian/issue_42_investigation.md

# 3. Comment on issue with progress
gh issue comment 42 --body "Investigation started. Initial findings: ..."

# 4. After fix, create resolution
touch .ian/issue_42_resolution.md

# 5. Close with documentation
gh issue close 42 --comment "$(cat .ian/issue_42_resolution.md)"
```

### PR Creation Workflow

```bash
# 1. Create feature branch
git checkout -b feature/order-idempotency

# 2. Make changes and commit
git add . && git commit -m "feat: add order idempotency"

# 3. Push branch
git push -u origin feature/order-idempotency

# 4. Create PR with description
gh pr create --title "feat: Add order idempotency" --body "Implementation of duplicate order detection using idempotency store..."

# 5. Get PR URL
gh pr view --web
```

## Useful Aliases

Add to `~/.bashrc` or use directly:

```bash
# Quick issue operations
alias ghil='gh issue list'
alias ghic='gh issue create'
alias ghiv='gh issue view'
alias ghiclose='gh issue close'

# Quick PR operations
alias ghpl='gh pr list'
alias ghpc='gh pr create'
alias ghpv='gh pr view'
alias ghpm='gh pr merge --squash --delete-branch'
```

## Templates

### Issue Creation Template

```bash
gh issue create --title "Backend: [Component] Brief description" --body "$(cat <<'EOF'
## Problem
Describe what's happening

## Expected Behavior
What should happen

## Actual Behavior
What's actually happening

## Steps to Reproduce
1. Step one
2. Step two

## Environment
- Backend version:
- Affected component:

## Additional Context
Any other relevant info
EOF
)" --label "backend"
```

### PR Creation Template

```bash
gh pr create --title "feat: [Feature] Brief description" --body "$(cat <<'EOF'
## Summary
Brief description of changes

## Changes Made
- Change 1
- Change 2

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Related Issues
Closes #42

## Checklist
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] No breaking changes
EOF
)"
```

## Best Practices

1. **Always document before closing issues**
   - Create `.ian/issue_{NUMBER}_resolution.md`
   - Include: problem, solution, files changed, verification, impact
   - Use `gh issue close {N} --comment "$(cat .ian/issue_{N}_resolution.md)"`

2. **Use labels consistently**
   - `backend` / `frontend` - Component
   - `bug` / `feature` / `chore` - Type
   - `priority:high` / `priority:low` - Priority

3. **Comment frequently**
   - Keep issues updated with progress
   - Document blockers and decisions
   - Link related PRs and commits

4. **Link issues and PRs**
   - Use "Closes #42" in PR descriptions
   - Reference issues in commit messages
   - Cross-reference related issues

5. **Use draft PRs for work in progress**
   - Create as draft: `gh pr create --draft`
   - Mark ready when complete: `gh pr ready {N}`

## Tips

- **View in browser**: Add `--web` to most commands
- **JSON output**: Add `--json` for programmatic use
- **Batch operations**: Use bash loops for multiple items
- **Filter by date**: `gh issue list --search "created:>2025-10-01"`
- **Filter by author**: `gh issue list --author your-github-username`

## Troubleshooting

**Authentication expired:**
```bash
~/quick_github_auth.sh
```

**Check current repo:**
```bash
gh repo view
```

**Switch repository:**
```bash
cd /path/to/repo
# or
gh repo set-default
```

## When to Use This Skill

- Creating issues from bug discoveries
- Updating issues with investigation progress
- Closing issues after fixes (with documentation)
- Creating PRs for feature work
- Checking CI status on PRs
- Reviewing and merging PRs
- Searching for related issues

## Integration with Other Skills

- **/triage** → Investigate issue → Document in `.ian/` → Update issue with `gh issue comment`
- **/validator** → Verify fix → Create resolution doc → Close issue with `gh issue close`
- **/find** → Locate code → Create issue with findings
