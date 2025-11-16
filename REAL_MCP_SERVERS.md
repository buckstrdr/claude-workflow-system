# Real MCP Server Configuration

This document explains which MCP servers are actually being used.

## Actually Available Official MCP Servers

Based on research of the `@modelcontextprotocol` npm packages:

1. **@modelcontextprotocol/server-filesystem** ✅ EXISTS
   - Purpose: Secure file operations
   - Install: `npx -y @modelcontextprotocol/server-filesystem`
   - Port: 3004 (via mcp-proxy)

2. **mcp-server-git** (Python via uvx) ✅ EXISTS
   - Purpose: Git operations
   - Install: `uvx mcp-server-git`
   - Port: 3003 (via mcp-proxy)

3. **@modelcontextprotocol/server-memory** ✅ EXISTS
   - Purpose: Knowledge graph memory
   - Could be used for: Skills/Agents storage
   - Port: 3006 (via mcp-proxy)

## What We're Using

### Production Servers (Official):
- **Serena** (port 3001) - Already running, provides memory + coordination
- **Filesystem MCP** (port 3004) - Official `@modelcontextprotocol/server-filesystem`
- **Git MCP** (port 3003) - Official `mcp-server-git`

### Placeholder/Optional Servers:
For the full 7-server setup, we need to either:

1. **Use existing MCP servers for similar purposes**:
   - Port 3002 (Firecrawl) → Use `@mzxrai/mcp-webresearch` or `@playwright/mcp`
   - Port 3005 (Terminal) → Use `@modelcontextprotocol/server-everything`
   - Port 3006 (Skills) → Use `@modelcontextprotocol/server-memory`
   - Port 3007 (Agents) → Use `@modelcontextprotocol/server-sequential-thinking`

2. **Keep mock servers** for features not needed immediately
3. **Build custom MCP servers** for specific needs

## Recommended Minimal Setup

For a working multi-instance system, you ONLY need:

1. **Serena** (3001) - Memory & coordination ✅ RUNNING
2. **Filesystem** (3004) - File operations
3. **Git** (3003) - Git operations

The other 4 servers (Firecrawl, Terminal, Skills, Agents) are optional and can be:
- Skipped (remove from startup)
- Mocked (simple HTTP servers as placeholders)
- Replaced with similar MCP servers

## How to Run Real Servers Only

Edit `scripts/mcp/start-all-mcp.sh` to only start:
```bash
SERVERS=(
    "serena:Serena (Memory & Coordination)"
    "git-mcp:Git Operations"
    "filesystem-mcp:Filesystem Operations"
)
```

## Next Steps

1. **Start with minimal setup** (3 servers: Serena, Git, Filesystem)
2. **Test the orchestrator** with just these 3
3. **Add more servers** as needed for specific features

The GUI will show servers as OFFLINE if they're not started, but the system will still work with the core 3 servers.
