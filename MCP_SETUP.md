# Remote MCP Server Setup Guide

## Architecture: Remote-Only HTTPS

**CRITICAL:** This system uses **ONLY remote MCP servers** accessed via HTTPS.

- ❌ NO local stdio servers managed by Claude CLI
- ✅ ALL MCP services are remote HTTPS endpoints
- ✅ Complete separation from Claude CLI MCP configuration
- ✅ Scalable multi-instance coordination

## Prerequisites

Before starting the multi-instance system, ensure ALL required remote MCP servers are running and accessible.

## Required Remote MCP Servers

### 1. Serena (Memory & Coordination) - REQUIRED

Serena provides memory storage and coordinates between Claude instances.

**Environment Variable:**
```bash
SERENA_URL=http://localhost:3001
```

**Start Serena:**
```bash
serena start-mcp-server --transport sse --port 3001
```

**Health Check:**
```bash
curl http://localhost:3001/
```

**Expected:** Port responds (may be 404, but connection succeeds)

---

### 2. Firecrawl (Web Scraping) - REQUIRED

Web scraping and content extraction via remote API.

**Environment Variables:**
```bash
FIRECRAWL_URL=http://localhost:3002
FIRECRAWL_API_KEY=fc-your-api-key-here
```

**Start Firecrawl MCP Server:**
```bash
# Start your Firecrawl MCP server on port 3002
# (Command depends on your Firecrawl server implementation)
```

**Health Check:**
```bash
curl http://localhost:3002/
```

---

### 3. Git MCP Server - REQUIRED

Git operations (commit, branch, status, diff, etc.) via remote MCP server.

**Environment Variable:**
```bash
GIT_MCP_URL=http://localhost:3003
```

**Start Git MCP Server:**
```bash
# Start your Git MCP server on port 3003
# Example: npx @modelcontextprotocol/server-git --port 3003
```

**Health Check:**
```bash
curl http://localhost:3003/
```

---

### 4. Filesystem MCP Server - REQUIRED

File system operations (read, write, list, delete, etc.) via remote MCP server.

**Environment Variable:**
```bash
FILESYSTEM_MCP_URL=http://localhost:3004
```

**Start Filesystem MCP Server:**
```bash
# Start your Filesystem MCP server on port 3004
# Example: npx @modelcontextprotocol/server-filesystem --port 3004
```

**Health Check:**
```bash
curl http://localhost:3004/
```

---

### 5. Terminal MCP Server - REQUIRED

Terminal command execution via remote MCP server.

**Environment Variable:**
```bash
TERMINAL_MCP_URL=http://localhost:3005
```

**Start Terminal MCP Server:**
```bash
# Start your Terminal MCP server on port 3005
# Example: npx @modelcontextprotocol/server-terminal --port 3005
```

**Health Check:**
```bash
curl http://localhost:3005/
```

---

### 6. Skills MCP Server - REQUIRED

Remote skills system for specialized workflows.

**Environment Variable:**
```bash
SKILLS_MCP_URL=http://localhost:3006
```

**Start Skills MCP Server:**
```bash
# Start your Skills MCP server on port 3006
# (Implementation specific to your skills system)
```

**Health Check:**
```bash
curl http://localhost:3006/
```

---

### 7. Agents MCP Server - REQUIRED

Remote agent dispatch and coordination.

**Environment Variable:**
```bash
AGENTS_MCP_URL=http://localhost:3007
```

**Start Agents MCP Server:**
```bash
# Start your Agents MCP server on port 3007
# (Implementation specific to your agent system)
```

**Health Check:**
```bash
curl http://localhost:3007/
```

---

## Optional Remote MCP Servers

### Context7 (Documentation Retrieval) - OPTIONAL

Documentation context retrieval via remote API.

**Environment Variables:**
```bash
CONTEXT7_URL=https://api.context7.com
CONTEXT7_API_KEY=ctx7sk-your-api-key-here
```

Get your key: https://context7.com/dashboard

---

### Playwright (UI Testing) - OPTIONAL

UI testing and verification.

**Environment Variable:**
```bash
PLAYWRIGHT_URL=http://localhost:9222
```

**Start Playwright MCP Server:**
```bash
# Start your Playwright MCP server on port 9222
```

---

## Environment File (.env)

Create `.env` in the project root with ALL required URLs and API keys:

```bash
# ==============================================================================
# REMOTE MCP CONFIGURATION - ALL SERVICES VIA HTTPS
# ==============================================================================

# API Keys
FIRECRAWL_API_KEY=fc-your-api-key-here
CONTEXT7_API_KEY=ctx7sk-your-api-key-here

# Remote MCP Server URLs (REQUIRED)
FIRECRAWL_URL=http://localhost:3002
CONTEXT7_URL=https://api.context7.com
SERENA_URL=http://localhost:3001
GIT_MCP_URL=http://localhost:3003
FILESYSTEM_MCP_URL=http://localhost:3004
TERMINAL_MCP_URL=http://localhost:3005
SKILLS_MCP_URL=http://localhost:3006
AGENTS_MCP_URL=http://localhost:3007

# Optional
PLAYWRIGHT_URL=http://localhost:9222
```

The bootstrap script automatically loads `.env` - no manual sourcing required.

---

## Verification

### Step 1: Check Configuration

Verify all URLs are configured:
```bash
./scripts/mcp/test-all-mcp.sh
```

### Step 2: Check Server Status

Verify all servers are online:
```bash
./scripts/mcp/mcp-status.sh
```

Expected output:
```
✅ All critical MCP services ready
```

### Step 3: Start Multi-Instance System

Once all servers are verified:
```bash
./bootstrap.sh my-feature
```

---

## Troubleshooting

### Server Not Reachable

```
✗ Git MCP not reachable at http://localhost:3003
```

**Solutions:**
1. Verify server is running: `ps aux | grep mcp`
2. Check port is listening: `nc -z localhost 3003`
3. Review server logs
4. Check firewall rules

### URL Not Configured

```
✗ GIT_MCP_URL not configured
```

**Solution:**
Add the missing URL to `.env`:
```bash
GIT_MCP_URL=http://localhost:3003
```

### API Key Missing

```
✗ FIRECRAWL_API_KEY not set
```

**Solution:**
Add API key to `.env`:
```bash
FIRECRAWL_API_KEY=fc-your-key-here
```

---

## Production Deployment

For production environments:

1. **Use HTTPS:** Replace `http://localhost` with `https://your-domain.com`
2. **Secure API Keys:** Use secrets management (not plain .env)
3. **Load Balancing:** Run multiple instances of each MCP server
4. **Monitoring:** Add health check monitoring for all endpoints
5. **Firewall:** Restrict access to authorized IPs only

Example production .env:
```bash
SERENA_URL=https://serena.yourdomain.com
GIT_MCP_URL=https://git-mcp.yourdomain.com
FILESYSTEM_MCP_URL=https://fs-mcp.yourdomain.com
# etc.
```

---

## MCP Configuration File

The `mcp-config.yaml` file defines all remote servers:

```yaml
servers:
  serena:
    type: remote
    url: "${SERENA_URL}"
    transport: https
    required: true
    description: "Memory and context storage"
```

**Note:** All servers use `type: remote` with `transport: https`. No `stdio` transport is used.

---

## Summary

**Before Bootstrap:**
1. ✅ Start all 7 required MCP servers (Serena, Firecrawl, Git, Filesystem, Terminal, Skills, Agents)
2. ✅ Configure all URLs in `.env`
3. ✅ Run `./scripts/mcp/mcp-status.sh` to verify
4. ✅ Ensure all critical services show `✓ ONLINE`

**Then:**
```bash
./bootstrap.sh my-feature
```

The system will launch 9 Claude instances, all accessing shared remote MCP infrastructure via HTTPS.
