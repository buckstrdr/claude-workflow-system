# Claude Code Workflow System

**A production-ready, disciplined development workflow system for Claude Code.**

Enforce quality through automation, not motivation. This system provides 7-stage quality gates, 44 specialized AI skills, TDD enforcement, and comprehensive CI/CD automation for any software project.

---

## 🎯 What This System Provides

- **7-Stage Quality Gates** - Mandatory checkpoints from spec to code review
- **44 AI-Powered Skills** - Specialized assistants for Python, React, FastAPI, testing, debugging, etc.
- **TDD Enforcement** - Git hooks that physically block non-TDD commits
- **GitHub Actions** - Automated quality gates, code review, and CI/CD
- **MCP Integration** - Knowledge base, browser automation, deep research
- **Comprehensive Docs** - 1,200+ lines of workflow documentation

---

## 🚀 Quick Start

### 1. Install the System

```bash
# Clone into your project
git clone https://github.com/buckstrdr/claude-workflow-system.git

# Or copy to existing project
cp -r claude-workflow-system/* ~/my-project/
```

### 2. Customize for Your Project

```bash
# Replace generic paths with your actual structure
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" \) \
  -exec sed -i 's/your_backend/YOUR_ACTUAL_BACKEND_DIR/g' {} \;

find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.sh" \) \
  -exec sed -i 's/your_frontend/YOUR_ACTUAL_FRONTEND_DIR/g' {} \;
```

### 3. Configure MCP Servers

Edit `mcp.json` with your project paths:
```json
{
  "filesystem": {
    "args": ["mcp-server-filesystem", "/path/to/your/project"]
  },
  "git": {
    "args": ["mcp-server-git", "--repository", "/path/to/your/project"]
  }
}
```

### 4. Install Git Hooks

```bash
chmod +x hooks/*
ln -sf ../../hooks/* .git/hooks/
```

### 5. Test the System

```bash
# In Claude Code session:
/startup

# Expected: ✓ MCP servers, ✓ Git repo, ✓ 44 skills loaded
```

**📖 Full setup guide**: See [SETUP.md](./SETUP.md)

---

## 📂 What's Inside

### Core System
- **skills/** (44 files) - AI skill definitions (`/python`, `/react`, `/validator`, etc.)
- **commands/** (44 files) - Slash command implementations
- **quality-gates/** - 7-stage gate tracking scripts
- **hooks/** (30 files) - Git automation (TDD enforcement, verification, etc.)
- **workflows/** (7 files) - GitHub Actions CI/CD

### Documentation
- **workflow_guide.md** (1,239 lines) - Complete workflow documentation
- **SETUP.md** - Setup and customization guide
- **STRICT_MODE_QUICK_REF.md** - Quick reference for quality gates
- **ISSUE_NAMING_CONVENTION.md** - Issue tracking standards
- **ISSUE_CLOSING_TEMPLATE.md** - Issue resolution format

### Configuration
- **mcp.json** - MCP server configuration (9 servers)
- **settings.local.json** - Local permissions
- **ISSUE_TEMPLATE/** - GitHub issue templates

---

## 🎓 The 7-Stage Quality Gate System

Every feature must complete all 7 gates:

```
1. Spec Approved     → /spec
2. Tests First (TDD) → Write failing tests
3. Implementation    → Make tests pass
4. Refactored       → /pragmatist code review
5. Integrated       → Sync OpenAPI → TypeScript types
6. E2E Verified     → /e2e-verify
7. Code Reviewed    → /validator approval
```

**Enforcement:**
- Pre-commit hook blocks mixing tests + implementation
- Pre-push hook requires Gate 7 completion
- CI/CD workflow blocks PRs without Gate 7
- Git hooks track progress in `.git/quality-gates/`

**Quick Reference**: See [STRICT_MODE_QUICK_REF.md](./STRICT_MODE_QUICK_REF.md)

---

## 🛠️ Key Skills (Slash Commands)

### Workflow Automation
- `/startup` - Session initialization (MANDATORY - run first)
- `/gates` - Quality gate tracking
- `/spec` - Specification wizard (Gate 1)
- `/validator` - Code review agent (Gate 7)
- `/pragmatist` - Anti-over-engineering review (Gate 4)
- `/karen` - Reality check manager
- `/e2e-verify` - End-to-end verification (Gate 6)
- `/verify-complete` - Completion checklist

### Tech Stack Experts
- `/python`, `/fastapi`, `/pydantic`, `/asyncio` - Python backend
- `/react`, `/typescript`, `/zustand`, `/tailwind` - React frontend
- `/websocket` - WebSocket implementation

### Development Tools
- `/test` - Test runner and analyzer
- `/debug` - Debugging assistant
- `/logs` - Log viewer and analyzer
- `/find` - Smart code search
- `/sync` - Schema synchronization
- `/clean` - Cache cleanup

### Domain-Specific (Examples)
- `/trading` - Trading systems expert
- `/strategy` - Strategy operations
- `/create-strategy` - Strategy creation wizard

**Full skills reference**: See [skills/README.md](./skills/README.md)

---

## 🔒 TDD Enforcement

The `enforce-test-first` hook blocks:
- ❌ Committing implementation without tests first
- ❌ Committing tests and implementation together

**Workflow:**
```bash
# 1. Write failing tests (RED)
git add your_backend/tests/test_feature.py
git commit -m "test: add feature tests"

# 2. Implement (GREEN)
git add your_backend/services/feature.py
git commit -m "feat: implement feature"
```

**Emergency bypass:** `STRICT_TDD=0 git commit` (not recommended)

---

## 🤖 GitHub Actions

- **quality-gates.yml** - Enforces Gate 7 on PRs to main
- **ci.yml** - Runs tests, linting, type-checking
- **claude-code-review.yml** - Automated code review
- **auto-label-pr.yml** - Auto-labels PRs by files changed
- **commit-msg-check.yml** - Validates conventional commits

---

## 📋 Issue Naming Convention

Standardized format with prefixes:
```
[T#] Testing      - T1, T2, T3...
[F#] Feature      - F1, F2, F3...
[B#] Bug          - B1, B2, B3...
[I#] Improvement  - I1, I2, I3...
[D#] Documentation- D1, D2, D3...
[C#] Chore        - C1, C2, C3...
[P#] Performance  - P1, P2, P3...
[S#] Security     - S1, S2, S3...
```

**Example:** `[T1] Entry Type Validation Suite - All 6 Order Types`

**Full guide**: See [ISSUE_NAMING_CONVENTION.md](./ISSUE_NAMING_CONVENTION.md)

---

## 🔌 MCP Server Integration

Configured servers:
- **Serena** - Knowledge base and memory
- **OpenAPI Backend** - API contract management
- **Playwright** - Browser automation for E2E tests
- **Filesystem** - File operations
- **Git** - Git operations
- **Deep Research** - Web research capabilities
- **Context7** - Upstash context management
- **Sequential Thinking** - Extended reasoning
- **Firecrawl** - Web scraping

---

## 📚 Documentation

1. **[SETUP.md](./SETUP.md)** - Setup and customization guide
2. **[workflow_guide.md](./workflow_guide.md)** - Complete workflow documentation
3. **[STRICT_MODE_QUICK_REF.md](./STRICT_MODE_QUICK_REF.md)** - Quality gates quick reference
4. **[skills/README.md](./skills/README.md)** - Skills library reference
5. **[ISSUE_NAMING_CONVENTION.md](./ISSUE_NAMING_CONVENTION.md)** - Issue tracking standards
6. **[ISSUE_CLOSING_TEMPLATE.md](./ISSUE_CLOSING_TEMPLATE.md)** - Issue resolution format

---

## 🎨 Customization

This system is **designed to be generic** and work with any project structure:

- ✅ Python/Node.js/Go/Rust backends
- ✅ React/Vue/Angular/Svelte frontends
- ✅ Monorepos or multi-repo setups
- ✅ Any testing framework (pytest, jest, cargo test, etc.)
- ✅ Any CI/CD platform (GitHub Actions, GitLab CI, CircleCI)

**See [SETUP.md](./SETUP.md) for detailed customization instructions.**

---

## 🤝 Philosophy

**"Discipline Over Motivation"**

This system enforces quality through automation:
- Can't commit implementation before tests (TDD hook)
- Can't push without Gate 7 completion (pre-push hook)
- Can't merge PRs without quality validation (GitHub Actions)
- Can't skip specifications (Gate 1 tracking)

The goal: Make doing the right thing **easier than doing the wrong thing**.

---

## 📈 Stats

- **155 files** total
- **29,813 lines** of code and documentation
- **44 specialized skills** for AI-assisted development
- **30 git hooks** for automation
- **7 GitHub Actions** workflows
- **9 MCP servers** configured
- **1,200+ lines** of comprehensive documentation

---

## 🙏 Credits

Created for disciplined, high-quality AI-assisted software development.

Built for the **TopStepX** trading platform but **genericized for any project**.

---

## 📄 License

This workflow system is provided as-is for use in any project.

---

## 🚦 Getting Started

1. **Read**: [SETUP.md](./SETUP.md) - 5-minute setup guide
2. **Install**: Clone and customize for your project
3. **Test**: Run `/startup` in Claude Code
4. **Learn**: Complete one feature through all 7 gates
5. **Customize**: Adapt skills and hooks to your workflow
6. **Scale**: Onboard your team

**Need help?** Check the troubleshooting section in [SETUP.md](./SETUP.md)

---

**Ready to enforce quality through discipline? Let's go! 🚀**
