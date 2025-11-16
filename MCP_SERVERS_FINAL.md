# Final MCP Server Configuration - 8 Servers

## Complete Remote MCP Architecture

All 8 MCP servers run as remote HTTPS endpoints using mcp-proxy.

### Server List

| Port | Server | Package | Purpose |
|------|--------|---------|---------|
| 3001 | Serena | serena (native HTTP) | Memory & Coordination |
| 3002 | Firecrawl | @mzxrai/mcp-webresearch | Web Scraping |
| 3003 | Git MCP | mcp-server-git (uvx) | Git Operations |
| 3004 | Filesystem MCP | @modelcontextprotocol/server-filesystem | File Operations |
| 3005 | Terminal MCP | @modelcontextprotocol/server-everything | Terminal Execution |
| 3006 | Playwright MCP | @playwright/mcp | Browser Automation |
| 3007 | Puppeteer MCP | puppeteer-mcp-server | Headless Browser |
| 3008 | Context7 MCP | @upstash/context7-mcp | Documentation Search |

## Startup Scripts

Each server has a startup script in `scripts/mcp/servers/`:
- `start-serena.sh` - Native HTTP (--transport sse)
- `start-firecrawl.sh` - Via mcp-proxy
- `start-git-mcp.sh` - Via mcp-proxy
- `start-filesystem-mcp.sh` - Via mcp-proxy
- `start-terminal-mcp.sh` - Via mcp-proxy
- `start-playwright-mcp.sh` - Via mcp-proxy
- `start-puppeteer-mcp.sh` - Via mcp-proxy
- `start-context7-mcp.sh` - Via mcp-proxy (requires API key)

## Required Tools

- `mcp-proxy` - Wraps stdio MCP servers in HTTP
- `uvx` - Python package executor (for mcp-server-git)
- `npx` - Node package executor (for npm packages)
- `nc` - Netcat for port checking

## Environment Variables

Required in `.env`:
```bash
FIRECRAWL_API_KEY=fc-...
CONTEXT7_API_KEY=ctx7sk-...
SERENA_URL=http://localhost:3001
```

All other URLs follow pattern: `http://localhost:300X`

## Master Start Script

`./scripts/mcp/start-all-mcp.sh` starts all 8 servers in sequence.

## GUI Integration

The Tkinter GUI at `./startup_gui.py` shows all 8 servers with:
- Real-time status (GREEN/RED)
- Auto-refresh every 2 seconds
- One-click start/stop
- Launch orchestrator when all green

## Skills & Agents

**NOT separate MCP servers** - handled by Claude CLI:
- **Skills**: Auto-loaded from `.claude/skills/` at startup
- **Agents**: Dispatched via Task tool + Serena coordination

## Bootstrap Check

`./bootstrap.sh` verifies all 8 ports (3001-3008) are listening before launching the orchestrator.

## Next Steps

1. Install Tkinter: `./install-tkinter.sh`
2. Launch GUI: `./start.sh`
3. Click "Start All MCP Servers"
4. Wait for all 8 green lights
5. Click "Launch Orchestrator"
6. Enter feature name
7. → 9 Claude instances with full MCP access!
