# Status - System Health Dashboard

Generate a comprehensive status report of the TopStepX development environment.

## What This Skill Does

Checks and reports on:
- Backend service status (running/stopped, health endpoint)
- Frontend service status (running/stopped, Vite dev server)
- MCP servers (Serena, OpenAPI)
- Git repository state (branch, uncommitted changes, recent commits)
- Schema sync status (OpenAPI, frontend types, semantic index)
- Recent errors from logs
- Quick diagnostics and recommendations

## How to Use

Simply invoke this skill to get a health dashboard:

```
/status
```

## Implementation

Check the following in parallel:

1. **Backend Status**
   - Check if process running: `ps aux | grep "[p]ython -m topstepx_backend"`
   - Test health endpoint: `curl -s http://localhost:8000/health`
   - Show PID, CPU, memory if running

2. **Frontend Status**
   - Check if Vite running: `ps aux | grep "[v]ite"`
   - Test dev server: `curl -s http://localhost:5173`
   - Show PID if running

3. **MCP Server Status**
   - Serena: Check process `ps aux | grep "serena start-mcp-server"`
   - OpenAPI: Check port `ss -ltnp | grep :9122`
   - Report RUNNING or STOPPED for each

4. **Git Status**
   - Current branch: `git branch --show-current`
   - Uncommitted changes: `git status --short`
   - Recent commits: `git log --oneline -3`

5. **Schema Sync Status**
   - Check OpenAPI exists: `test -f .serena/knowledge/openapi.json`
   - Check semantic index: `test -f .serena/graphs/semantic.index`
   - Check frontend types: `test -f topstepx_frontend/src/types/api.d.ts`

6. **Recent Errors**
   - Backend errors: `tail -50 /tmp/backend_vibe.err | grep -i error | tail -5`
   - Frontend errors: `tail -50 /tmp/vite_vibe.err | grep -i error | tail -5`

7. **Diagnostics**
   - If backend stopped: "Run: make backend-start"
   - If MCPs stopped: "Run: make mcp-start or ./dev/devtools/mcp/start_all_mcps.sh"
   - If schema out of sync: "Run: make openapi && make types"

## Output Format

Present results in a clear, scannable format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TopStepX Status Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Services:
  Backend  (port 8000):  ✓ RUNNING (PID 12345, healthy)
  Frontend (port 5173):  ✓ RUNNING (PID 12346)

MCP Servers:
  Serena  (:9121):  ✓ RUNNING
  OpenAPI (:9122):  ✓ RUNNING

Git:
  Branch: claude/add-skills-feature-011CUaK5grfHn1ckoPf6GTov
  Changes: 2 modified, 1 new
  Recent:
    - ca01d30 chore: update semantic index
    - b2524e2 fix(order-entry): correct ATR/R:R basis

Schema Sync:
  OpenAPI spec:     ✓ Present
  Semantic index:   ✓ Present
  Frontend types:   ✓ Synced

Recent Errors:
  Backend:  None in last 50 lines
  Frontend: None in last 50 lines

Overall Status: ✓ HEALTHY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If there are issues, add a **Recommended Actions** section:

```
Recommended Actions:
  1. Start MCP servers: make mcp-start
  2. Sync schema: make openapi && make types
  3. Review backend errors in /tmp/backend_vibe.err
```

## Tips

- Use color indicators: ✓ (good) ✗ (bad) ⚠ (warning)
- Show URLs for running services
- Highlight actionable issues
- Keep output concise but informative
- Run checks in parallel for speed
