# Logs - Log Viewer and Analyzer

View, filter, and analyze logs from YourProject services.

## What This Skill Does

Provides intelligent log viewing:
- Tail backend/frontend logs in real-time
- Filter by log level (ERROR, WARNING, INFO, DEBUG)
- Search for specific keywords or patterns
- Show recent errors with context
- Parse structured logs (JSON)
- Correlate events across services

## How to Use

```
/logs                    # Show recent logs from all services
/logs backend            # Backend only
/logs frontend           # Frontend only
/logs errors             # Recent errors only
/logs search "order"     # Search for keyword
/logs tail               # Follow logs in real-time
```

## Implementation

### Show Recent Logs (Default)

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Backend Logs (last 20 lines)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
tail -20 /tmp/backend_vibe.err

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Frontend Logs (last 20 lines)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
tail -20 /tmp/vite_vibe.err

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Serena MCP Logs (last 20 lines)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
tail -20 /tmp/mcp-serena.log
```

### Backend Logs Only

```bash
echo "Showing backend logs from: /tmp/backend_vibe.err"
echo ""
tail -50 /tmp/backend_vibe.err
```

### Frontend Logs Only

```bash
echo "Showing frontend logs from: /tmp/vite_vibe.err"
echo ""
tail -50 /tmp/vite_vibe.err
```

### Errors Only

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Recent Errors (All Services)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Backend Errors:"
grep -i "error\|exception\|traceback" /tmp/backend_vibe.err | tail -10

echo ""
echo "Frontend Errors:"
grep -i "error\|failed\|✘" /tmp/vite_vibe.err | tail -10

echo ""
echo "MCP Errors:"
grep -i "error\|failed" /tmp/mcp-serena.log | tail -10
```

### Search Logs

```bash
keyword="$1"  # e.g., "order", "websocket", "database"

echo "Searching for: '$keyword'"
echo ""

echo "Backend matches:"
grep -i "$keyword" /tmp/backend_vibe.err | tail -20

echo ""
echo "Frontend matches:"
grep -i "$keyword" /tmp/vite_vibe.err | tail -20
```

### Tail Logs (Real-time)

```bash
echo "Following logs (Ctrl+C to stop)..."
echo ""
echo "Backend + Frontend combined:"
tail -f /tmp/backend_vibe.err /tmp/vite_vibe.err
```

### Structured Log Parsing

If logs are JSON structured:

```bash
# Parse JSON logs and extract fields
echo "Parsing structured logs..."

# Show recent structured log events
tail -50 /tmp/backend_vibe.err | \
  grep '^{' | \
  jq -r '[.timestamp, .level, .message] | @tsv' | \
  column -t -s $'\t'
```

### Log Analysis

Provide insights:

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Log Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Count log levels
echo ""
echo "Backend Log Levels (last 100 lines):"
tail -100 /tmp/backend_vibe.err | \
  grep -oE "ERROR|WARNING|INFO|DEBUG" | \
  sort | uniq -c | sort -rn

# Recent error patterns
echo ""
echo "Common Error Patterns:"
tail -100 /tmp/backend_vibe.err | \
  grep -i "error" | \
  sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}.*ERROR/ERROR/' | \
  sort | uniq -c | sort -rn | head -5

# WebSocket connection issues
echo ""
echo "WebSocket Events:"
grep -i "websocket" /tmp/backend_vibe.err | tail -5

# Database queries (if logged)
echo ""
echo "Recent Database Activity:"
grep -i "SELECT\|INSERT\|UPDATE\|DELETE" /tmp/backend_vibe.err | tail -5
```

## Log Locations Reference

Show where logs are stored:

```
Log Files:
  Backend stderr:  /tmp/backend_vibe.err
  Backend stdout:  /tmp/backend_vibe.out
  Frontend stderr: /tmp/vite_vibe.err
  Frontend stdout: /tmp/vite_vibe.out
  Serena MCP:      /tmp/mcp-serena.log
  OpenAPI MCP:     /tmp/mcp-openapi.log
  Git MCP:         /tmp/mcp-git.log

Application Logs:
  Main log:        logs/app.log (if exists)
  Strategy logs:   Check backend endpoints: /api/logs/*
```

## Common Patterns to Look For

Guide the user on what to look for:

**Backend Issues:**
- `ERROR` - Application errors
- `exception` - Python exceptions with tracebacks
- `Traceback` - Stack traces
- `websocket.*disconnect` - Connection issues
- `database.*error` - DB problems
- `rejected` - Order rejections

**Frontend Issues:**
- `✘` - Vite build errors
- `error` - Runtime errors
- `failed` - Failed requests
- `Cannot find module` - Missing dependencies
- `ECONNREFUSED` - Backend not running

**MCP Issues:**
- `Failed to start` - Startup problems
- `Connection refused` - Port conflicts
- `error` - General errors

## Interactive Debugging Session

If user needs deeper analysis:

```
I see several errors. Let me analyze:

1. Backend Error (last occurrence: 2 minutes ago):
   "OrderRejected: Insufficient margin"

   Context (5 lines before):
   [Show context from logs]

   Likely Cause: Order quantity too large for available margin
   Location: your_backend/services/order_service.py:142

   Suggested Fix: Check account margin before submitting orders

2. Frontend Warning (recurring):
   "WebSocket connection lost, retrying..."

   Pattern: Occurs every ~30 seconds
   Likely Cause: Backend WebSocket handler crashing

   Suggested Investigation:
   - Check backend websocket handler code
   - Look for uncaught exceptions in WS route
   - Review backend logs around same timestamp
```

## Tips

- Use Grep tool for log searching (it's optimized)
- Correlate timestamps between frontend and backend
- Look for patterns, not just individual errors
- Check logs before and after the error for context
- Suggest specific file:line locations when possible
- Offer to dig deeper if needed
