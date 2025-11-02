# Restart - Quick Service Restart

Quickly restart backend and/or frontend services to apply changes or recover from issues.

## What This Skill Does

Provides fast, clean restart workflows:
- Stop services gracefully
- Clear cached state (optional)
- Restart services
- Verify health

## How to Use

```
/restart            # Restart everything (backend + frontend)
/restart backend    # Backend only
/restart frontend   # Frontend only
/restart clean      # Restart + clear caches
```

## Implementation

### Full Restart
```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Restarting TopStepX Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Stop services
echo "Stopping services..."
make backend-stop
make frontend-stop

# Wait for clean shutdown
sleep 2

# Start services
echo "Starting backend..."
make backend-start

# Wait for backend health
echo "Waiting for backend..."
for i in {1..30}; do
  curl -s http://localhost:8000/health >/dev/null && break
  sleep 1
done

echo "Starting frontend..."
make frontend-start

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Services Restarted"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Backend:  http://localhost:8000"
echo "  Frontend: http://localhost:5173"
echo ""
```

### Backend Only
```bash
echo "Restarting backend..."

make backend-stop
sleep 1
make backend-start

# Health check
for i in {1..20}; do
  if curl -s http://localhost:8000/health >/dev/null; then
    echo "✓ Backend healthy"
    exit 0
  fi
  sleep 1
done

echo "⚠ Backend started but health check timed out"
echo "Check logs: tail -f /tmp/backend_vibe.err"
```

### Frontend Only
```bash
echo "Restarting frontend..."

make frontend-stop
sleep 1
make frontend-start

echo "✓ Frontend restarting at http://localhost:5173"
echo "  (Vite dev server takes ~5s to be ready)"
```

### Clean Restart (Clear Caches)
```bash
echo "Clean restart: stopping services and clearing caches..."

# Stop everything
make backend-stop
make frontend-stop

# Clear Python caches
echo "Clearing Python bytecode..."
find topstepx_backend -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find topstepx_backend -name "*.pyc" -delete 2>/dev/null || true

# Clear any temporary state
echo "Clearing temporary files..."
rm -f /tmp/backend_vibe.* /tmp/vite_vibe.* 2>/dev/null || true

# Optional: Clear runtime state (careful!)
# rm -f data/idempotency_cache.json

# Restart
echo "Starting clean backend..."
make backend-start

sleep 2

echo "Starting frontend..."
make frontend-start

echo ""
echo "✓ Clean restart complete"
echo "  All caches cleared, services restarted"
```

## When to Use

**Restart backend when:**
- Code changes not taking effect
- Memory leaks or performance degradation
- Stuck connections or tasks
- After installing new dependencies
- Configuration changes

**Restart frontend when:**
- React hooks acting weird
- HMR (hot reload) broken
- Style changes not applying
- Module resolution issues

**Clean restart when:**
- Really stuck issues
- After package updates
- Stale cache suspected
- Fresh start needed

## Fast Restart Workflow

For iterative development:

```bash
# 1. Make code changes
# 2. Quick restart
/restart backend

# 3. Test changes
curl http://localhost:8000/api/endpoint

# 4. Check logs if needed
/logs backend
```

## Restart with Verification

```bash
#!/bin/bash

restart_and_verify() {
  echo "Restarting $1..."

  if [ "$1" = "backend" ]; then
    make backend-stop && make backend-start

    # Verify
    if curl -s http://localhost:8000/health >/dev/null; then
      echo "✓ Backend healthy"
    else
      echo "✗ Backend failed to start"
      tail -20 /tmp/backend_vibe.err
      return 1
    fi

  elif [ "$1" = "frontend" ]; then
    make frontend-stop && make frontend-start

    sleep 5  # Vite needs time

    if curl -s http://localhost:5173 >/dev/null; then
      echo "✓ Frontend ready"
    else
      echo "✗ Frontend failed to start"
      tail -20 /tmp/vite_vibe.err
      return 1
    fi
  fi
}
```

## Troubleshooting

**Issue: Process won't stop**
```bash
# Force kill
pkill -9 -f "python -m topstepx_backend"
pkill -9 -f "vite"

# Or by PID
kill -9 $(cat /tmp/backend_vibe.pid)
kill -9 $(cat /tmp/vite_vibe.pid)
```

**Issue: Port already in use**
```bash
# Find what's using the port
ss -ltnp | grep :8000
ss -ltnp | grep :5173

# Kill the process
kill $(lsof -t -i:8000)
kill $(lsof -t -i:5173)
```

**Issue: Backend won't start**
```bash
# Check logs immediately
tail -50 /tmp/backend_vibe.err

# Common issues:
# - Import errors (missing dependencies)
# - Port conflicts
# - Database connection failed
# - Environment variables missing
```

## Integration with Development Workflow

Typical workflow:

```bash
# 1. Start your session
/init

# 2. Start services
/start

# 3. Make code changes...

# 4. Quick restart to apply changes
/restart backend

# 5. Test changes
/logs backend

# 6. Iterate...

# 7. Full clean restart if things get weird
/restart clean
```

## Comparison with /start

**`/start`** - Initial startup (checks dependencies, starts from scratch)
**`/restart`** - Fast restart (assumes already configured)

Use `/start` at session beginning, `/restart` during development.

## Tips

- Backend restarts are fast (~2s)
- Frontend restarts take longer (~5-10s for Vite)
- Always check logs after restart if something feels wrong
- Clean restart is usually overkill - try regular restart first
- MCPs don't need restart (they're separate processes)
- Use `/status` after restart to verify everything running
