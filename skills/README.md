# YourProject Claude Code Skills - Complete Library

Comprehensive skill library with 27 specialized skills for accelerated YourProject development.

## 📊 Complete Skill Library (27 Skills)

### 🔧 Workflow Automation (13 skills)
Essential daily-use and automation skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/startup` | Session initialization | Start of every session |
| `/status` | System health dashboard | Frequently, for quick checks |
| `/start` | Smart stack startup | Session start, after restart |
| `/restart` | Quick service restart | During development |
| `/sync` | Schema synchronization | After backend API changes |
| `/logs` | Log viewer/analyzer | Debugging, monitoring |
| `/find` | Smart code search | Locating code, exploring |
| `/debug` | Debugging assistant | When stuck, troubleshooting |
| `/test` | Intelligent test runner | After code changes |
| `/clean` | Nuclear cleanup | When everything is broken |
| `/strategy` | Strategy operations | Strategy work |
| `/smoke` | Smoke test orchestrator | Before commits/PRs |
| `/api` | API testing helper | Testing endpoints |
| `/triage` | GitHub issue triage | Issue analysis |

### 💻 Technology Experts (9 skills)
Specialized coding assistants for each tech stack

| Skill | Technology | Expertise |
|-------|-----------|-----------|
| `/python` | Python 3.11+ | Async, type hints, patterns |
| `/fastapi` | FastAPI | API design, WebSocket, DI |
| `/pydantic` | Pydantic | Schema validation, models |
| `/asyncio` | Asyncio | Event loop, concurrency |
| `/react` | React 18+ | Hooks, performance, composition |
| `/typescript` | TypeScript | Advanced types, generics |
| `/zustand` | Zustand | State management, selectors |
| `/websocket` | WebSocket | Real-time, reconnection |
| `/tailwind` | Tailwind CSS | Utility-first, responsive |

### 🔍 Quality Assurance (3 skills)
Code quality and validation agents

| Skill | Purpose | Use Case |
|-------|---------|----------|
| `/validator` | Task completion validator | Before marking work complete |
| `/karen` | Reality check manager | Brutal honesty about what actually works |
| `/pragmatist` | Code quality reviewer | Catch over-engineering, enforce simplicity |

### 📊 Domain-Specific (1 skill)

| Skill | Domain | Expertise |
|-------|--------|-----------|
| `/trading` | Trading systems | Orders, brackets, risk, P&L |

---

## 🚀 Quick Start

### First Time Setup
```bash
/startup           # Initialize session (ALWAYS RUN FIRST)
/start             # Start all services
/status            # Verify everything running
```

### Daily Workflow
```bash
# Morning routine
/startup           # Check environment
/status            # Health check
/start             # Start services

# During development
/find "code"       # Locate code
/python            # Get expert help
/sync              # Keep schemas in sync
/restart backend   # Apply changes
/logs errors       # Check for issues

# Before committing
/validator         # Validate implementation
/pragmatist        # Check for over-engineering
/test              # Run tests
/karen             # Reality check
```

### Debugging Workflow
```bash
/status            # What's running?
/debug             # Diagnose issues
/logs errors       # Recent errors
/restart clean     # Fresh start
```

---

## 💡 Skill Categories by Use Case

### Session Management
Start here every time:
- `/startup` → `/status` → `/start`

### Code Development
Use while coding:
- `/find` → `/python`/`/react`/etc → `/sync` → `/restart`

### Testing & Quality
Before commits:
- `/test` → `/validator` → `/pragmatist` → `/karen`

### Debugging
When stuck:
- `/debug` → `/logs` → `/restart` → `/clean`

### Domain Work
Specialized tasks:
- `/trading` - Trading operations
- `/strategy` - Strategy management  
- `/smoke` - Integration testing
- `/api` - API testing
- `/triage` - Issue triage

---

## 🎯 Skill Usage Patterns

### Pattern 1: New Feature Implementation
```bash
/startup                       # Start session
/find "similar feature"        # Find examples
/python                        # Backend guidance
> Design service for X

/react                         # Frontend guidance
> Design component for X

# Implement...

/sync                          # Sync schemas
/restart                       # Apply changes
/test                          # Run tests
/validator                     # Validate completion
/pragmatist                    # Check quality
```

### Pattern 2: Bug Investigation
```bash
/status                        # Check services
/debug                         # Initial diagnosis
/logs errors                   # Find error
/find "error location"         # Locate code

# Fix...

/restart                       # Test fix
/logs tail                     # Verify fixed
/validator                     # Validate fix
```

### Pattern 3: Code Review Prep
```bash
/test                          # Run all tests
/validator                     # Validate complete
/pragmatist                    # Check quality
/karen                         # Reality check
/smoke                         # Integration tests

# If all pass → ready for PR
```

---

## 📖 Detailed Skill Descriptions

### Workflow Skills

#### `/startup` - Session Initialization ⭐ CRITICAL
**Must run at start of every session**

Performs CLAUDE.md mandatory initialization:
- Check/start MCP servers
- Load Serena memories
- Verify git status
- Check build artifacts
- Test backend imports
- Generate readiness report

```bash
/startup
```

#### `/status` - System Health Dashboard
Quick environment overview:
- Service status (backend/frontend/MCPs)
- Git state
- Schema sync status
- Recent errors
- Recommendations

```bash
/status
```

#### `/sync` - Schema Synchronization ⭐ IMPORTANT
Keep backend and frontend in sync:
- Generate OpenAPI from FastAPI
- Generate TypeScript types
- Update semantic index

```bash
/sync              # Full sync
/sync fast         # Skip semantic
/sync check        # Just check status
```

**Run after:** Any backend API/schema changes

#### `/restart` - Quick Service Restart
Fast restart during development:
- Graceful shutdown
- Optional cache clear
- Health verification

```bash
/restart           # All services
/restart backend   # Backend only
/restart clean     # Clear caches
```

#### `/debug` - Debugging Assistant
Intelligent debugging workflows:
- Health checks
- Log analysis
- Symptom-based diagnostics
- Fix recommendations

```bash
/debug                   # General check
/debug backend           # Backend-specific
/debug websocket         # WebSocket issues
/debug "error message"   # Search for error
```

#### `/test` - Intelligent Test Runner
Smart test execution:
- Auto-detect changed code
- Run relevant tests
- Backend/frontend/smoke tests
- Result analysis

```bash
/test              # Auto-detect
/test backend      # Backend only
/test frontend     # Frontend only
/test all          # Everything
```

#### `/clean` - Nuclear Cleanup
Deep environment cleaning:
- Stop all services
- Clear all caches
- Clear logs
- Optional: clear runtime state

```bash
/clean             # Safe clean
/clean all         # Everything (dangerous!)
/clean cache       # Just caches
```

**Use when:** Everything is broken, need fresh start

### Quality Assurance Skills

#### `/validator` - Task Completion Validator ⭐ USE BEFORE COMMITS
Validates work actually functions:
- End-to-end testing
- Edge case verification
- Regression checks
- Returns APPROVED or REJECTED

```bash
/validator
> CONTEXT: Implemented order idempotency in OrderService
```

**Use:** Before marking work complete, before commits

#### `/karen` - Reality Check Manager
Brutal honesty about project state:
- Tests what actually works
- Compares claims vs reality
- Identifies incomplete work
- Prevents premature "done"

```bash
/karen
> CONTEXT: Multiple tasks marked complete but system doesn't work end-to-end
```

**Use:** Before PRs, releases, when something feels off

#### `/pragmatist` - Code Quality Reviewer ⭐ USE BEFORE COMMITS
Catches over-engineering:
- Identifies unnecessary complexity
- Suggests simplifications
- Enforces "less is more"
- Finds premature optimization

```bash
/pragmatist
> CONTEXT: Added IdempotencyStore service with caching layer
```

**Use:** After implementing, before committing

### Technology Expert Skills

#### Core Stack
- `/python` - Python 3.11+, async patterns, type hints
- `/fastapi` - API design, WebSocket, dependency injection
- `/pydantic` - Schema validation, model composition
- `/asyncio` - Event loop, concurrency, task management

#### Frontend Stack
- `/react` - Hooks, performance, component patterns
- `/typescript` - Advanced types, generics, type guards
- `/zustand` - State management, selectors, middleware
- `/tailwind` - Utility-first CSS, responsive design

#### Real-time & Communication
- `/websocket` - Connection management, reconnection, heartbeat

### Domain Skills

#### `/trading` - Trading Systems Expert
Complete trading domain expertise:
- Order lifecycle management
- Bracket orders (TP/SL)
- Trailing stops
- Position tracking & P&L
- Risk management
- Idempotency patterns

```bash
/trading
> How do I implement bracket orders with proper fill handling?
```

### Operational Skills

#### `/strategy` - Strategy Operations
Strategy management helper:
- List available strategies
- Test configurations
- Debug execution
- View logs

```bash
/strategy list
/strategy logs <name>
```

#### `/smoke` - Smoke Test Orchestrator
Integration test runner:
- List smoke tests
- Run specific or all tests
- Report results

```bash
/smoke all
/smoke bars
/smoke brackets
```

#### `/api` - API Testing Helper
Quick API endpoint testing:
- Test endpoints
- List available endpoints
- Format JSON
- Debug API issues

```bash
/api list
/api test /orders/submit
/api get /positions/live
```

#### `/triage` - GitHub Issue Triage
Automated issue triage:
- Fetch issue details
- Search codebase
- Generate reproduction steps
- Suggest labels & severity

```bash
/triage 123
```

---

## 🎓 Best Practices

### Session Start Checklist
1. **Always run `/startup` first** - Critical for environment setup
2. Run `/status` - Verify healthy state
3. Run `/start` if needed - Start services
4. Review init report - Address any DEGRADED status

### During Development
1. Use `/find` before reading code - Locate faster
2. Invoke experts while coding - Real-time guidance  
3. Run `/sync` after backend changes - Keep types in sync
4. Use `/restart` not `/start` - Faster iteration

### Before Committing
1. Run `/test` - Catch issues early
2. Run `/validator` - Verify completion
3. Run `/pragmatist` - Check quality
4. Run `/karen` - Reality check
5. Run `/smoke` - Integration tests

### When Debugging
1. Start with `/status` - Quick health check
2. Use `/debug` - Diagnostic workflow
3. Check `/logs errors` - Recent errors
4. Try `/restart` - Apply fixes
5. Last resort: `/clean` - Nuclear option

### Code Quality
1. Simpler is better - Use `/pragmatist`
2. Test what works - Use `/karen`
3. Validate completion - Use `/validator`
4. Delete > refactor - Less code principle

---

## 📚 Skill Combinations

### Full Feature Workflow
```bash
/startup → /find → /python → /react → /sync → /restart → 
/test → /validator → /pragmatist → /karen → commit
```

### Quick Bug Fix
```bash
/status → /debug → /logs → fix → /restart → /test → /validator
```

### Code Review Prep
```bash
/test → /validator → /pragmatist → /karen → /smoke
```

---

## 📈 Statistics

- **Total Skills:** 27
- **Workflow:** 13
- **Tech Experts:** 9  
- **QA:** 3
- **Domain:** 1
- **Total Guidance:** ~10,000+ lines
- **Coverage:** Complete development lifecycle

---

## 🆘 Troubleshooting

**Skill not working?**
1. Check `/status` - Services running?
2. Run `/startup` - Environment setup?
3. Check skill file exists: `ls .claude/skills/`
4. Review skill documentation
5. Check Claude Code docs

**Common Issues:**
- MCPs not running → `/startup` detects and recommends fix
- Types out of sync → `/sync`
- Service won't start → `/debug` for diagnostics
- Tests failing → `/test` shows details
- Everything broken → `/clean` then `/start`

---

## 🎯 Skill Selection Guide

**I want to...**
- Start my session → `/startup`
- Check what's running → `/status`
- Start services → `/start`
- Find code → `/find`
- Get coding help → `/python`, `/react`, etc.
- Sync schemas → `/sync`
- Restart services → `/restart`
- Debug issues → `/debug`
- View logs → `/logs`
- Run tests → `/test`
- Validate work → `/validator`
- Reality check → `/karen`
- Check quality → `/pragmatist`
- Clean environment → `/clean`
- Test API → `/api`
- Run integration tests → `/smoke`
- Work with strategies → `/strategy`
- Triage issue → `/triage`

---

## 🚀 Remember

1. **Start with `/startup`** - Every session, no exceptions
2. **Use `/status` frequently** - Quick health checks
3. **Run QA before commits** - Validator, pragmatist, karen
4. **Combine skills** - Powerful workflows
5. **Keep it simple** - Pragmatist philosophy
6. **Test reality** - Karen's honesty
7. **Validate completion** - Validator's thoroughness

**Skills accelerate development. Use them liberally!**

---

**Last Updated:** 2025-10-28  
**Total Skills:** 27  
**Ready for:** Production use

**Questions?** Check individual skill files for detailed documentation.
