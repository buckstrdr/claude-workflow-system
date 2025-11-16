# MCP Server Setup Guide

This system supports both local and remote MCP servers.

## Remote MCP Servers (Recommended for Multi-Instance)

### Serena (Memory Server) - REQUIRED

Serena stores conversation context and coordinates between Claude instances.

**Environment Variable:**
```bash
export SERENA_URL=http://your-server:3001
```

**Health Check:**
```bash
curl http://your-server:3001/health
```

Expected response: `{"status":"ok"}`

### Playwright (UI Testing) - OPTIONAL

**Environment Variable:**
```bash
export PLAYWRIGHT_URL=http://your-server:9222
```

## Local MCP Servers (Managed by Claude CLI)

The following are managed automatically by Claude Code CLI:
- **filesystem** - File operations
- **git** - Git operations
- **terminal** - Command execution

These use stdio transport and don't require separate setup.

## Configuration

Edit `mcp-config.yaml` to customize server URLs and requirements:

```yaml
servers:
  serena:
    type: remote
    url: "${SERENA_URL:-http://localhost:3001}"
    required: true
```

## Verification

Check all MCP servers before bootstrap:

```bash
./scripts/mcp/mcp-status.sh
```

## Environment File

Create `.env` file for persistent configuration:

```bash
# .env
SERENA_URL=http://your-serena-server:3001
PLAYWRIGHT_URL=http://your-playwright-server:9222
```

Load before running bootstrap:
```bash
source .env
./bootstrap.sh my-feature
```

## Troubleshooting

### Serena Connection Failed

```
❌ Serena OFFLINE (CRITICAL)
```

**Solutions:**
1. Verify Serena server is running
2. Check SERENA_URL is correct
3. Test with curl: `curl $SERENA_URL/health`
4. Check firewall/network access

### Playwright Optional

Playwright is optional. The system will warn but continue if unavailable:
```
⚠️  Playwright offline (UI verification unavailable)
```

This only affects E2E UI testing (Gate 6).
