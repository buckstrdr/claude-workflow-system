# Setup Guide - Applying This Workflow System to Your Project

This guide explains how to customize and apply the Claude Code Workflow System to your own project.

## Overview

This workflow system provides:
- **7-stage quality gates** for disciplined development
- **44 specialized skills** for common development tasks
- **Git hooks** enforcing TDD and quality standards
- **GitHub Actions** for CI/CD automation
- **MCP server integration** for enhanced AI capabilities

---

## Quick Setup (5 Minutes)

### 1. Clone or Copy This Repository

```bash
# Option A: Clone this repo
git clone https://github.com/your-org/claude-workflow-system.git
cd claude-workflow-system

# Option B: Copy into existing project
cp -r claude-workflow-system/.claude ~/your-project/.claude
cp -r claude-workflow-system/workflows ~/your-project/.github/workflows
cp -r claude-workflow-system/hooks ~/your-project/.git/hooks
```

### 2. Customize Path References

Replace generic placeholders with your actual project paths:

```bash
# Find and replace in all files
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" -o -name "*.json" \) \
  -exec sed -i 's/your_backend/YOUR_BACKEND_DIR/g' {} \;

find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" -o -name "*.json" \) \
  -exec sed -i 's/your_frontend/YOUR_FRONTEND_DIR/g' {} \;
```

**Common directory structures:**
- **Python/React**: `backend/` and `frontend/`
- **FastAPI/Next.js**: `server/` and `client/`
- **Django/Vue**: `backend/` and `frontend/`
- **Monorepo**: `packages/api/` and `packages/web/`

### 3. Configure MCP Servers

Edit `mcp.json` to match your environment:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "uvx",
      "args": ["mcp-server-filesystem", "/ABSOLUTE/PATH/TO/YOUR/PROJECT"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "/ABSOLUTE/PATH/TO/YOUR/PROJECT"]
    }
  }
}
```

**Replace:**
- `/path/to/your/project` → Your actual project path
- `/path/to/mcp-server-deep-research` → Install location
- `your-api-key-here` → Your actual Firecrawl API key (if using)

### 4. Install Git Hooks

```bash
# Make hooks executable
chmod +x hooks/*

# Install hooks (if not already in .git/hooks/)
cp hooks/* .git/hooks/

# Or create symlinks
ln -sf ../../hooks/* .git/hooks/
```

### 5. Test the System

```bash
# Start a Claude Code session and run:
/startup

# Expected output:
# ✓ MCP servers detected
# ✓ Git repository found
# ✓ Skills loaded: 44 skills
# ✓ Hooks active
```

---

## Customization Guide

### Customize for Your Tech Stack

#### Backend Paths

Files to update:
- `workflows/quality-gates.yml` - Test and build commands
- `workflows/ci.yml` - CI pipeline paths
- `quality-gates/gates-pass.sh` - Test discovery
- `hooks/pre-mark-complete` - Integration checks
- All skill files in `skills/` and `commands/`

**Example - Django Project:**
```bash
# Replace in all files
your_backend → django_app
python -m pytest your_backend/tests/ → python manage.py test
```

**Example - Node.js Backend:**
```bash
your_backend → server
python -m pytest → npm test
```

#### Frontend Paths

Files to update:
- `workflows/quality-gates.yml` - Build paths
- `workflows/ci.yml` - Lint and type-check
- `workflows/auto-label-pr.yml` - File pattern matching
- `hooks/verify-ui-changes` - UI verification paths

**Example - Next.js:**
```bash
your_frontend → apps/web
npm run build → next build
```

**Example - Vue:**
```bash
your_frontend → client
npm run type-check → vue-tsc --noEmit
```

### Customize Quality Gates

Edit `quality-gates/gates-pass.sh` to match your testing strategy:

**Gate 2 - Test Discovery:**
```bash
# Python/pytest
TEST_COUNT=$(find your_backend/tests/ -name "test_*.py" | wc -l)

# JavaScript/Jest
TEST_COUNT=$(find your_frontend/__tests__/ -name "*.test.ts" | wc -l)

# Go
TEST_COUNT=$(find . -name "*_test.go" | wc -l)
```

**Gate 3 - Test Execution:**
```bash
# Python
python -m pytest your_backend/tests/ -v

# Node.js
npm test

# Rust
cargo test

# Go
go test ./...
```

**Gate 5 - Integration:**
```bash
# OpenAPI → TypeScript (current)
make openapi && make types

# GraphQL → TypeScript
npm run codegen

# Protobuf → Multiple languages
make proto

# Prisma → Client generation
npx prisma generate
```

### Customize GitHub Workflows

#### Enable/Disable Workflows

Comment out workflows you don't need in `.github/workflows/`:

```yaml
# Disable frontend lint if no frontend
# jobs:
#   frontend-lint:
#     runs-on: ubuntu-latest
#     ...
```

#### Adjust Quality Gates Enforcement

Edit `workflows/quality-gates.yml`:

```yaml
# Strict mode - blocks merge without Gate 7
- name: Verify Gate 7 Complete
  run: |
    if [ ! -f .git/quality-gates/*/gate_7_code_reviewed ]; then
      echo "❌ Gate 7 not complete"
      exit 1
    fi

# Relaxed mode - warning only
- name: Verify Gate 7 Complete
  run: |
    if [ ! -f .git/quality-gates/*/gate_7_code_reviewed ]; then
      echo "⚠️  Warning: Gate 7 not complete"
      # Don't exit 1
    fi
```

### Customize Git Hooks

#### TDD Enforcement Level

Edit `hooks/enforce-test-first`:

```bash
# Strict TDD (default) - blocks mixing tests and implementation
STRICT=${STRICT_TDD:-1}

# Relaxed - allow mixing (bypass available)
STRICT=${STRICT_TDD:-0}

# Warning only - never blocks
# Remove the `exit 1` line
```

#### Pre-push Checks

Edit `hooks/pre-push`:

```bash
# Require Gate 7 (strict)
if [ ! -f ".git/quality-gates/*/gate_7_code_reviewed" ]; then
  exit 1
fi

# Optional Gate 7 (warning)
if [ ! -f ".git/quality-gates/*/gate_7_code_reviewed" ]; then
  echo "⚠️  Warning: Consider completing Gate 7"
  # Continue
fi
```

### Customize Skills

#### Remove Unused Skills

Delete skills you don't need:

```bash
# Remove trading-specific skills
rm skills/trading.md skills/strategy.md skills/create-strategy.md
rm commands/trading.md commands/strategy.md commands/create-strategy.md

# Remove language-specific skills you don't use
rm skills/{python,fastapi,pydantic,asyncio}.md
rm commands/{python,fastapi,pydantic,asyncio}.md
```

#### Add Custom Skills

Create new skills in `skills/` and `commands/`:

```bash
# Create a custom skill
cat > skills/deploy.md <<'EOF'
# Deploy - Production Deployment

Deploy the application to production.

## What This Skill Does

- Build production artifacts
- Run pre-deployment checks
- Deploy to environment
- Verify deployment health

## How to Use

```
/deploy staging    # Deploy to staging
/deploy production # Deploy to production
```

## Implementation

[Your deployment commands here]
EOF

# Copy to commands/
cp skills/deploy.md commands/deploy.md
```

### Customize Issue Templates

Edit `ISSUE_TEMPLATE/*.yml` and `ISSUE_NAMING_CONVENTION.md`:

**Add custom issue types:**
```yaml
# ISSUE_TEMPLATE/infra_issue.yml
name: Infrastructure issue
description: Issues related to infrastructure, DevOps, deployment
title: "[infra] {{summary}}"
labels: infrastructure, area:ops
```

**Add custom prefixes:**
```markdown
# ISSUE_NAMING_CONVENTION.md

[Ix] Infrastructure - Infrastructure and DevOps (I1, I2, I3...)
[Dx] Deployment - Deployment and release (D1, D2, D3...)
```

---

## Optional Features

### Serena Knowledge Base (Advanced)

If using Serena MCP server:

1. **Install Serena**: Follow [Serena setup docs](https://docs.anthropic.com)
2. **Configure URL**: Update `mcp.json` with your Serena endpoint
3. **Ingest codebase**: Run initial knowledge ingestion

```bash
# Configure in mcp.json
"serena": {
  "transport": {
    "type": "streamable-http",
    "url": "http://localhost:9121/mcp"
  }
}
```

### Auto-Commit System (Optional)

The workflow guide mentions an auto-commit system. To implement:

```bash
# Create systemd service (Linux)
cat > ~/.config/systemd/user/auto-commit.service <<'EOF'
[Unit]
Description=Auto-commit changes every 30 seconds

[Service]
ExecStart=/path/to/auto-commit-script.sh
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user enable auto-commit
systemctl --user start auto-commit
```

### Makefile Integration

Create a `Makefile` with common commands:

```makefile
.PHONY: openapi types test

openapi:
	python -m your_backend.generate_openapi > .serena/knowledge/openapi.json

types:
	npx openapi-typescript .serena/knowledge/openapi.json -o your_frontend/src/types/api.d.ts

test:
	python -m pytest your_backend/tests/ -v
	cd your_frontend && npm test

mcp-start:
	# Start MCP servers
	./scripts/start-mcp-servers.sh
```

---

## Verification Checklist

After setup, verify everything works:

- [ ] `/startup` runs without errors
- [ ] `/status` shows correct project paths
- [ ] `/gates start test_feature` creates tracking directory
- [ ] Git hooks are executable (`ls -la .git/hooks/`)
- [ ] GitHub Actions workflows are in `.github/workflows/`
- [ ] MCP servers can connect (if using)
- [ ] Test commands work: `python -m pytest` or `npm test`
- [ ] Build commands work: `npm run build`

---

## Troubleshooting

### MCP Servers Won't Start

```bash
# Check if ports are in use
lsof -i :9121  # Serena
lsof -i :9122  # OpenAPI
lsof -i :9123  # Playwright

# Kill conflicting processes
kill -9 <PID>

# Check permissions
ls -la /path/to/mcp-server-deep-research
```

### Git Hooks Not Running

```bash
# Check if hooks are executable
ls -la .git/hooks/

# Make executable
chmod +x .git/hooks/*

# Verify hook path
git config core.hooksPath  # Should be .git/hooks or custom path
```

### Quality Gates Not Tracking

```bash
# Initialize gates manually
.claude/quality-gates/gates-start.sh my_feature

# Check tracking directory
ls -la .git/quality-gates/my_feature/
```

### Tests Not Found

```bash
# Verify test paths in gates-pass.sh
cat quality-gates/gates-pass.sh | grep "find.*tests"

# Update to match your structure
sed -i 's|your_backend/tests/|actual/test/path/|g' quality-gates/gates-pass.sh
```

---

## Migration from Existing System

If you have an existing Claude Code setup:

1. **Backup current config**: `cp -r .claude .claude.backup`
2. **Merge skills**: Copy new skills you want to `skills/`
3. **Update hooks gradually**: Start with non-blocking hooks
4. **Test in feature branch**: Don't apply to main immediately
5. **Review conflicts**: Compare and merge configs

---

## Support & Documentation

- **Full workflow guide**: See `workflow_guide.md`
- **Quality gates reference**: See `STRICT_MODE_QUICK_REF.md`
- **Issue naming**: See `ISSUE_NAMING_CONVENTION.md`
- **Skills reference**: See `skills/README.md`

---

## Example: Complete Setup for a New Project

```bash
# 1. Clone this repo into your project
cd ~/my-awesome-project
git clone https://github.com/your-org/claude-workflow-system.git .claude-system
mv .claude-system/* .
mv .claude-system/.* .
rmdir .claude-system

# 2. Customize paths
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" \) \
  -exec sed -i 's/your_backend/backend/g' {} \;
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" \) \
  -exec sed -i 's/your_frontend/frontend/g' {} \;

# 3. Update MCP config
sed -i "s|/path/to/your/project|$(pwd)|g" mcp.json

# 4. Install hooks
chmod +x hooks/*
ln -sf ../../hooks/* .git/hooks/

# 5. Test
claude /startup
```

---

## What to Customize vs. Keep

### ✅ MUST Customize
- Project paths (`your_backend`, `your_frontend`)
- MCP server URLs and API keys
- Test commands and paths
- Build commands
- Repository structure references

### ⚠️  SHOULD Customize
- Issue templates
- PR template
- Skill files (remove unused, add custom)
- GitHub workflow jobs
- Hook strictness levels

### ❌ DON'T Change (Core System)
- Quality gate structure (7 gates)
- Gate tracking scripts logic
- TDD enforcement philosophy
- Hook names and triggers
- Workflow file structure

---

## Next Steps

1. ✅ Complete this setup guide
2. ✅ Run `/startup` to verify
3. ✅ Create a test feature: `/gates start test_setup`
4. ✅ Go through all 7 gates once to learn the flow
5. ✅ Customize skills and hooks for your workflow
6. ✅ Onboard team members with this guide

**Happy coding with discipline! 🚀**
