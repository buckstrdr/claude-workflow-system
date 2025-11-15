# Start - Smart Stack Startup

Start the YourProject development stack intelligently, handling dependencies and health checks.

## What This Skill Does

Starts the full development environment in the correct order:
1. MCP servers (if not already running)
2. Backend service (in background)
3. Frontend dev server (in background)
4. Wait for health checks
5. Report URLs and access information

## How to Use

```
/start
```

Optional: Start specific components only
```
/start backend
/start frontend
/start mcps
```

## Implementation

### Full Stack Startup

1. **Check and Start MCPs**
   ```bash
   # Check if Serena running
   ps aux | grep "serena start-mcp-server" | grep -v grep

   # If not running, start
   if [ $? -ne 0 ]; then
     echo "Starting MCP servers..."
     ./dev/devtools/mcp/start_all_mcps.sh
     sleep 3
   else
     echo "✓ MCPs already running"
   fi
   ```

2. **Start Backend**
   ```bash
   # Check if already running
   ps aux | grep "[p]ython -m your_backend" | grep -v grep

   # If not running, start in background
   if [ $? -ne 0 ]; then
     echo "Starting backend..."
     make backend-start

     # Wait for health check
     for i in {1..30}; do
       curl -s http://localhost:8000/health >/dev/null && break
       sleep 1
     done

     if [ $? -eq 0 ]; then
       echo "✓ Backend healthy at http://localhost:8000"
     else
       echo "⚠ Backend started but health check failed"
     fi
   else
     echo "✓ Backend already running"
   fi
   ```

3. **Start Frontend**
   ```bash
   # Check if already running
   ps aux | grep "[v]ite" | grep -v grep

   # If not running, start in background
   if [ $? -ne 0 ]; then
     echo "Starting frontend..."
     make frontend-start

     # Wait for dev server
     for i in {1..30}; do
       curl -s http://localhost:5173 >/dev/null && break
       sleep 1
     done

     if [ $? -eq 0 ]; then
       echo "✓ Frontend ready at http://localhost:5173"
     else
       echo "⚠ Frontend started but not responding yet"
     fi
   else
     echo "✓ Frontend already running"
   fi
   ```

4. **Final Status Report**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     YourProject Development Stack Started
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   Services:
     Backend:   http://localhost:8000
     Frontend:  http://localhost:5173
     API Docs:  http://localhost:8000/docs

   MCP Servers:
     Serena:    http://localhost:9121/mcp
     OpenAPI:   http://localhost:9122/mcp

   Logs:
     Backend:   /tmp/backend_vibe.err
     Frontend:  /tmp/vite_vibe.err
     Serena:    /tmp/mcp-serena.log

   PIDs:
     Backend:   12345
     Frontend:  12346

   Next Steps:
     - Open frontend: http://localhost:5173
     - View API docs: http://localhost:8000/docs
     - Check logs: make mcp-logs
     - Stop all: /stop

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

### Component-Specific Startup

If user specifies a component:

**Backend Only:**
```bash
make backend-start
# Wait for health check
curl -s http://localhost:8000/health
echo "Backend: http://localhost:8000"
```

**Frontend Only:**
```bash
make frontend-start
# Wait for Vite
curl -s http://localhost:5173
echo "Frontend: http://localhost:5173"
```

**MCPs Only:**
```bash
./dev/devtools/mcp/start_all_mcps.sh
make mcp-status
```

## Error Handling

If startup fails:

1. **Check for port conflicts**
   ```bash
   ss -ltnp | grep -E ':(8000|5173|9121|9122)'
   ```

2. **Show error logs**
   ```bash
   tail -20 /tmp/backend_vibe.err
   tail -20 /tmp/vite_vibe.err
   ```

3. **Suggest diagnostics**
   ```
   Startup failed. Try:
     1. Check logs: tail -f /tmp/backend_vibe.err
     2. Check ports: ss -ltnp | grep 8000
     3. Clean restart: /stop && /start
     4. Manual start: cd your_frontend && npm run dev
   ```

## Tips

- Always check if services are already running first
- Use health checks, don't just assume success
- Show PIDs so users can monitor with `top` or kill if needed
- Provide clear next steps
- Be patient with health checks (services need time to start)
- If a service fails to start, show the error logs immediately
