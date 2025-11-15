# Debug - Debugging Assistant

Intelligent debugging assistant that helps diagnose and fix issues across the YourProject stack.

## What This Skill Does

Provides guided debugging workflows:
- Check service health and connections
- Analyze error logs and stack traces
- Verify data flows (WebSocket, API, database)
- Suggest diagnostics based on symptoms
- Generate reproduction steps
- Provide fix recommendations

## How to Use

```
/debug                    # General health check + recent errors
/debug backend            # Backend-specific debugging
/debug frontend           # Frontend-specific debugging
/debug websocket          # WebSocket connection issues
/debug orders             # Order flow debugging
/debug "error message"    # Search for specific error
```

## Common Debugging Workflows

### General Health Check
```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  YourProject Debugging - Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Check services running
echo ""
echo "Services:"
ps aux | grep "[p]ython -m your_backend" && echo "  Backend: RUNNING" || echo "  Backend: STOPPED ✗"
ps aux | grep "[v]ite" && echo "  Frontend: RUNNING" || echo "  Frontend: STOPPED ✗"

# 2. Check ports
echo ""
echo "Ports:"
ss -ltnp 2>/dev/null | grep -q ":8000" && echo "  8000 (backend): OPEN" || echo "  8000: CLOSED ✗"
ss -ltnp 2>/dev/null | grep -q ":5173" && echo "  5173 (frontend): OPEN" || echo "  5173: CLOSED ✗"

# 3. Test endpoints
echo ""
echo "API Health:"
if curl -s http://localhost:8000/health >/dev/null 2>&1; then
  curl -s http://localhost:8000/health | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'  Status: {d[\"overall_status\"]}')"
else
  echo "  Health endpoint: UNREACHABLE ✗"
fi

# 4. Recent errors
echo ""
echo "Recent Errors:"
echo "  Backend:"
grep -i "error\|exception" /tmp/backend_vibe.err 2>/dev/null | tail -3 || echo "    None found"

echo "  Frontend:"
grep -i "error\|failed" /tmp/vite_vibe.err 2>/dev/null | tail -3 || echo "    None found"
```

### Backend Debugging
```bash
echo "Backend Debugging..."

# Check if running
if ! ps aux | grep -q "[p]ython -m your_backend"; then
  echo "✗ Backend not running!"
  echo "  Start with: make backend-start"
  exit 1
fi

# Check imports
echo "Testing backend imports..."
if python3 -c "import your_backend" 2>/dev/null; then
  echo "✓ Backend imports OK"
else
  echo "✗ Backend import failed!"
  python3 -c "import your_backend"  # Show error
  exit 1
fi

# Check database connection
echo "Database connection..."
# Could test with actual query if DB connection info available

# Recent exceptions
echo ""
echo "Recent Exceptions:"
grep -A 5 "Traceback" /tmp/backend_vibe.err | tail -20

# WebSocket connections
echo ""
echo "WebSocket Connections:"
grep "WebSocket" /tmp/backend_vibe.err | tail -5
```

### Frontend Debugging
```bash
echo "Frontend Debugging..."

# Check if running
if ! ps aux | grep -q "[v]ite"; then
  echo "✗ Frontend not running!"
  echo "  Start with: make frontend-start"
  exit 1
fi

# Check for build errors
echo "Build Errors:"
grep -i "error\|failed" /tmp/vite_vibe.err | tail -10

# Check TypeScript errors
echo ""
echo "TypeScript Issues:"
grep "TS[0-9]" /tmp/vite_vibe.err | tail -5

# Check network errors
echo ""
echo "Network Errors:"
grep -i "ECONNREFUSED\|fetch failed\|network" /tmp/vite_vibe.err | tail -5
```

### WebSocket Debugging
```bash
echo "WebSocket Debugging..."

# Check backend WebSocket endpoint
echo "Backend WebSocket Status:"
grep -i "websocket" /tmp/backend_vibe.err | tail -10

# Check for connection/disconnection events
echo ""
echo "Connection Events:"
grep -E "WebSocket.*connect|WebSocket.*disconnect" /tmp/backend_vibe.err | tail -5

# Check for message errors
echo ""
echo "Message Errors:"
grep -i "websocket.*error\|failed to send" /tmp/backend_vibe.err | tail -5

# Frontend WebSocket errors
echo ""
echo "Frontend WebSocket:"
grep -i "websocket\|ws.*error" /tmp/vite_vibe.err | tail -5
```

## Symptom-Based Debugging

### Symptom: "API calls failing"
```
Diagnostic Steps:
1. Check if backend running: ps aux | grep backend
2. Test health endpoint: curl http://localhost:8000/health
3. Check recent errors: tail -f /tmp/backend_vibe.err
4. Test specific endpoint: curl http://localhost:8000/api/endpoint
5. Check CORS if browser: Look for CORS errors in browser console

Common Causes:
- Backend not started
- Port conflict (8000 in use)
- Route not registered
- Validation error in request
- Database connection failed
```

### Symptom: "WebSocket keeps disconnecting"
```
Diagnostic Steps:
1. Check WebSocket endpoint: grep "WebSocket" /tmp/backend_vibe.err
2. Look for errors before disconnect
3. Check heartbeat/ping-pong logic
4. Verify reconnection attempts in frontend
5. Check for uncaught exceptions in WS handler

Common Causes:
- Uncaught exception in WebSocket handler
- No heartbeat (connection timeout)
- Backend restarted
- Network instability
- Frontend not handling disconnection
```

### Symptom: "Orders not submitting"
```
Diagnostic Steps:
1. Check order service logs: grep "order" /tmp/backend_vibe.err -i
2. Test order endpoint: curl -X POST http://localhost:8000/api/orders/submit
3. Check for validation errors
4. Verify account/contract data
5. Check for idempotency cache issues

Common Causes:
- Invalid order parameters (validation)
- Missing account configuration
- Exchange connection down
- Idempotency collision
- Insufficient permissions
```

### Symptom: "Frontend not updating"
```
Diagnostic Steps:
1. Check WebSocket connection in browser DevTools
2. Verify messages being received
3. Check Zustand store updates
4. Look for React rendering issues
5. Check if component subscribed to correct state

Common Causes:
- WebSocket disconnected
- Message parsing errors
- Store not being updated
- Component not subscribed to state
- Selector not triggering re-render
```

## Diagnostic Commands

```bash
# Test backend health
curl -s http://localhost:8000/health | jq

# Test specific API endpoint
curl -s http://localhost:8000/api/positions/live | jq

# Check WebSocket (requires websocat or similar)
websocat ws://localhost:8000/ws/test

# Monitor logs in real-time
tail -f /tmp/backend_vibe.err /tmp/vite_vibe.err

# Search logs for specific error
grep -rn "OrderRejected" /tmp/*.err

# Check Python exceptions
grep -A 10 "Traceback" /tmp/backend_vibe.err | tail -30

# Check database queries (if logged)
grep "SELECT\|INSERT\|UPDATE" /tmp/backend_vibe.err | tail -10
```

## Quick Fixes

```bash
# Fix: Port conflict
kill $(lsof -t -i:8000)
make backend-start

# Fix: Stale Python cache
find . -name "*.pyc" -delete
find . -name "__pycache__" -type d -exec rm -rf {} +
make backend-start

# Fix: Types out of sync
make openapi && make types

# Fix: Frontend stuck
make frontend-stop
rm -rf your_frontend/node_modules/.vite
make frontend-start

# Fix: Everything is broken
make backend-stop && make frontend-stop
sleep 2
make backend-start && sleep 3 && make frontend-start
```

## Integration with Logs Skill

For deeper log analysis, use `/logs`:

```bash
/debug              # Quick diagnostics
/logs errors        # Deep dive into errors
/logs search "..."  # Search for specific issue
```

## Tips

- Always check service status first (/status or /debug)
- Recent errors often show the problem
- Stack traces point to exact line numbers
- WebSocket issues are usually backend exceptions
- Frontend errors often mean backend API changed
- When stuck, try `/restart clean`
