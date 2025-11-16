# Claude Multi-Instance Startup Guide

## Quick Start

### 1. Launch the Startup GUI

```bash
./start.sh
```

This launches an interactive GUI that shows:
- Real-time status of all 7 MCP servers
- One-click "Start All" button
- Visual green/red light indicators
- Direct launch to orchestrator when ready

### 2. Start MCP Servers

In the GUI menu:
- Press `[1]` to start all MCP servers
- Wait for verification (takes ~10 seconds)
- Look for the **✅ ALL SYSTEMS GO** green light

### 3. Launch Orchestrator

Once all servers show green:
- Press `[4]` to launch orchestrator
- Enter your feature name when prompted
- System will automatically start tmux with 9 Claude instances

## Startup GUI Features

### Status Display

```
Service              Port    Status
────────────────────────────────────
Serena              3001    ● ONLINE
Firecrawl           3002    ● ONLINE
Git MCP             3003    ● ONLINE
Filesystem MCP      3004    ● ONLINE
Terminal MCP        3005    ● ONLINE
Skills MCP          3006    ● ONLINE
Agents MCP          3007    ● ONLINE
```

### Green Light System

**Green Light** (✅ ALL SYSTEMS GO):
- All 7 MCP servers running and verified
- System ready to launch orchestrator
- Can proceed with confidence

**Red Light** (⚠️ SERVERS NOT READY):
- One or more servers offline
- Must start servers before launching
- Shows which servers need attention

### Menu Options

1. **Start All MCP Servers** - Launches all 7 servers in background
2. **Refresh Status** - Updates server status display
3. **View Server Logs** - Inspect individual server logs
4. **Launch Orchestrator** - Start tmux multi-instance system (requires green light)
5. **Quit** - Exit the GUI

## Manual Startup (Alternative)

If you prefer command-line:

```bash
# Start all MCP servers
./scripts/mcp/start-all-mcp.sh

# Verify all are running
./scripts/mcp/verify-remote-mcp.sh

# Launch orchestrator
./bootstrap.sh my-feature-name
```

## What Gets Started

### MCP Servers (7 total)

1. **Serena (port 3001)** - Memory and multi-instance coordination
2. **Firecrawl (port 3002)** - Web scraping and content extraction
3. **Git MCP (port 3003)** - Git operations
4. **Filesystem MCP (port 3004)** - File system operations
5. **Terminal MCP (port 3005)** - Terminal command execution
6. **Skills MCP (port 3006)** - Skills system
7. **Agents MCP (port 3007)** - Agent dispatch and coordination

All servers run in background with logs in `/tmp/*-mcp.log`

### Claude Instances (9 total)

After launching orchestrator, you get:

1. **Orchestrator** - Master coordinator
2. **Librarian** - Context retrieval
3. **Planner** - Task planning
4. **Architect** - System design
5. **Dev-A** - Developer instance A
6. **Dev-B** - Developer instance B
7. **QA-A** - QA instance A
8. **QA-B** - QA instance B
9. **Docs** - Documentation specialist

## Process IDs and Logs

Each MCP server creates:
- **PID file**: `/tmp/<service>-mcp.pid`
- **Log file**: `/tmp/<service>-mcp.log`

View logs from GUI (option 3) or directly:
```bash
tail -f /tmp/serena-mcp.log
tail -f /tmp/firecrawl-mcp.log
# etc.
```

## Stopping Everything

### Stop MCP Servers

```bash
# Kill all MCP servers
pkill -f "serena start-mcp-server"
pkill -f "firecrawl-mcp"
pkill -f "@modelcontextprotocol"
```

### Stop Tmux Session

```bash
# List sessions
tmux list-sessions

# Kill specific feature session
tmux kill-session -t claude-feature-<name>
```

## Troubleshooting

### Server Won't Start

Check the log file:
```bash
cat /tmp/<service>-mcp.log
```

Common issues:
- **Port already in use**: Another process on that port
- **Missing API key**: Check `.env` file
- **Package not found**: NPM package needs installation

### Green Light Not Showing

Verify each server manually:
```bash
nc -z localhost 3001 && echo "Serena: OK"
nc -z localhost 3002 && echo "Firecrawl: OK"
nc -z localhost 3003 && echo "Git MCP: OK"
nc -z localhost 3004 && echo "Filesystem MCP: OK"
nc -z localhost 3005 && echo "Terminal MCP: OK"
nc -z localhost 3006 && echo "Skills MCP: OK"
nc -z localhost 3007 && echo "Agents MCP: OK"
```

### Bootstrap Fails

If bootstrap fails with "MCP servers not running":
```bash
# Return to startup GUI
./start.sh

# Or restart servers manually
./scripts/mcp/start-all-mcp.sh
```

## Architecture

```
┌─────────────────────────────────────────┐
│         Startup GUI (./start.sh)        │
│  - Visual status display                │
│  - One-click server start               │
│  - Green/red light system               │
│  - Direct orchestrator launch           │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│   Start All MCP Servers (background)    │
│  - Serena (3001)                        │
│  - Firecrawl (3002)                     │
│  - Git MCP (3003)                       │
│  - Filesystem MCP (3004)                │
│  - Terminal MCP (3005)                  │
│  - Skills MCP (3006)                    │
│  - Agents MCP (3007)                    │
└─────────────────────────────────────────┘
                    │
                    ▼ (Green Light)
┌─────────────────────────────────────────┐
│   Bootstrap Orchestrator                │
│  - Creates git worktree                 │
│  - Initializes quality gates            │
│  - Sets up message board                │
│  - Launches tmux with 9 instances       │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│   Multi-Instance Claude System          │
│  - 9 specialized roles                  │
│  - File-based message passing           │
│  - 7-stage quality gates                │
│  - TDD enforcement                      │
│  - Shared remote MCP infrastructure     │
└─────────────────────────────────────────┘
```

## Next Steps

Once the orchestrator is running:
1. You'll be attached to the Orchestrator pane
2. Give it a task to coordinate
3. Watch as it assigns work to team members
4. Monitor progress through quality gates
5. Use `Ctrl+B` then `W` to navigate between tmux windows

See `README.md` for full system documentation.
