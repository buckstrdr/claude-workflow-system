# Tkinter GUI - Setup & Usage

## Installation

### 1. Install Tkinter

Run the automated installer:
```bash
./install-tkinter.sh
```

Or install manually for your distribution:

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install python3-tk
```

**Fedora/RHEL/CentOS:**
```bash
sudo dnf install python3-tkinter
```

**Arch/Manjaro:**
```bash
sudo pacman -S tk
```

### 2. Launch the GUI

Once Tkinter is installed:
```bash
./start.sh
```

Or run the Python script directly:
```bash
python3 startup_gui.py
```

## GUI Features

### Visual Interface

The Tkinter GUI provides a professional graphical interface with:

- **Header**: Title and subtitle
- **Status Light**: Large green/red circle indicator
  - 🔴 RED = Servers not ready
  - 🟢 GREEN = All systems go
- **Server Table**: Real-time status of all 7 MCP servers
  - Service name
  - Port number
  - Description
  - Status (● ONLINE / ● OFFLINE)
- **Control Buttons**:
  - 🚀 Start All MCP Servers
  - ⏹️ Stop All Servers
  - 🎯 Launch Orchestrator (enabled when all servers ready)
  - 🔄 Refresh Status

### Auto-Refresh

The GUI automatically refreshes server status every 2 seconds, so you always see the current state.

### Launching the Orchestrator

1. Click "🚀 Start All MCP Servers"
2. Wait for the green light (✅ ALL SYSTEMS GO)
3. Click "🎯 Launch Orchestrator"
4. Enter your feature name in the dialog
5. System launches tmux in a new terminal window

## GUI Layout

```
┌─────────────────────────────────────────────────────────┐
│  Claude Multi-Instance Orchestrator                     │
│  MCP Server Management & Control                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  🔴  ⚠️  SERVERS NOT READY                              │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ MCP Server Status                                │   │
│  ├──────────────┬──────┬───────────────┬──────────┤   │
│  │ Service      │ Port │ Description   │ Status   │   │
│  ├──────────────┼──────┼───────────────┼──────────┤   │
│  │ Serena       │ 3001 │ Memory & Coor │ ● OFFLINE│   │
│  │ Firecrawl    │ 3002 │ Web Scraping  │ ● OFFLINE│   │
│  │ Git MCP      │ 3003 │ Git Ops       │ ● OFFLINE│   │
│  │ Filesystem   │ 3004 │ File Ops      │ ● OFFLINE│   │
│  │ Terminal MCP │ 3005 │ Terminal Exec │ ● OFFLINE│   │
│  │ Skills MCP   │ 3006 │ Skills System │ ● OFFLINE│   │
│  │ Agents MCP   │ 3007 │ Agent Dispatch│ ● OFFLINE│   │
│  └──────────────┴──────┴───────────────┴──────────┘   │
│                                                          │
│  ┌────────────┐ ┌────────────┐ ┌──────────────────┐   │
│  │🚀 Start All│ │⏹️ Stop All │ │🎯 Launch Orch... │   │
│  └────────────┘ └────────────┘ └──────────────────┘   │
│                                                          │
│  🔄 Refresh Status  Auto-refresh every 2 seconds        │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## After Servers Start

When all servers are running, the display changes:

```
🟢  ✅ ALL SYSTEMS GO

Service          Port    Description       Status
─────────────────────────────────────────────────
Serena          3001    Memory & Coor     ● ONLINE
Firecrawl       3002    Web Scraping      ● ONLINE
Git MCP         3003    Git Ops           ● ONLINE
Filesystem      3004    File Ops          ● ONLINE
Terminal MCP    3005    Terminal Exec     ● ONLINE
Skills MCP      3006    Skills System     ● ONLINE
Agents MCP      3007    Agent Dispatch    ● ONLINE
```

The "🎯 Launch Orchestrator" button becomes enabled (changes from gray to blue).

## Troubleshooting

### Tkinter Not Found

If you get "ModuleNotFoundError: No module named 'tkinter'":
```bash
./install-tkinter.sh
```

### GUI Won't Launch

Check Python version (must be 3.8+):
```bash
python3 --version
```

### Display Issues

If running over SSH without X11 forwarding:
```bash
# Enable X11 forwarding
ssh -X user@host

# Or use the terminal UI instead
./scripts/mcp/startup-gui.sh
```

### Servers Won't Start

Check the logs:
```bash
tail -f /tmp/serena-mcp.log
tail -f /tmp/firecrawl-mcp.log
```

## Fallback: Terminal UI

If you can't use the Tkinter GUI (no X11, SSH session, etc.), use the terminal UI:

```bash
./scripts/mcp/startup-gui.sh
```

This provides the same functionality in a text-based interface.

## Files

- **startup_gui.py** - Main Tkinter GUI application
- **start.sh** - Launcher script (checks for Tkinter)
- **install-tkinter.sh** - Automated Tkinter installer
- **scripts/mcp/startup-gui.sh** - Terminal UI fallback

## Requirements

- Python 3.8+
- python3-tk (Tkinter)
- All MCP server dependencies (see MCP_SETUP.md)

## Next Steps

After launching the orchestrator:
1. New terminal window opens with tmux
2. 9 Claude instances running
3. Start giving tasks to the Orchestrator
4. Use Ctrl+B W to navigate between windows

See STARTUP_GUIDE.md for complete workflow documentation.
