# Clean - Nuclear Cleanup Option

Nuclear option to clean all caches, state, and temporary files. Use when everything is broken.

## What This Skill Does

Deep cleaning of the development environment:
- Stop all services
- Clear Python bytecode caches
- Clear frontend build caches
- Clear runtime state (optional)
- Clear log files
- Fresh start

## How to Use

```
/clean              # Full clean (safe, keeps runtime data)
/clean all          # Everything including runtime state
/clean cache        # Just caches
/clean logs         # Just logs
```

## Implementation

### Safe Clean (Default)
```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Nuclear Cleanup (Safe Mode)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Stop everything
echo "Stopping all services..."
make backend-stop
make frontend-stop
make mcp-stop

# 2. Clear Python caches
echo "Clearing Python bytecode..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "*.pyo" -delete 2>/dev/null || true

# 3. Clear test caches
echo "Clearing test caches..."
rm -rf .pytest_cache .mypy_cache htmlcov .coverage .coverage.* 2>/dev/null || true

# 4. Clear frontend caches
echo "Clearing frontend caches..."
rm -rf your_frontend/node_modules/.vite 2>/dev/null || true
rm -rf your_frontend/dist 2>/dev/null || true

# 5. Clear temporary files
echo "Clearing temporary files..."
rm -f /tmp/backend_vibe.* /tmp/vite_vibe.* 2>/dev/null || true
rm -f /tmp/mcp-*.log 2>/dev/null || true

echo ""
echo "✓ Cleanup complete"
echo ""
echo "Next steps:"
echo "  1. /start  - Start services fresh"
echo "  2. /status - Verify everything clean"
```

### Full Clean (Including Runtime State)
```bash
echo "⚠️  WARNING: This will clear ALL runtime state!"
echo "   - Account configurations"
echo "   - Market subscriptions"
echo "   - Strategy state"
echo "   - Idempotency cache"
echo ""

# All safe clean steps...

# Plus runtime state
echo "Clearing runtime state..."
rm -f data/accounts.json 2>/dev/null || true
rm -f data/idempotency_cache.json 2>/dev/null || true
rm -f data/market_subscriptions.json 2>/dev/null || true
rm -f data/strategies_state.json 2>/dev/null || true
rm -rf data/metrics/* 2>/dev/null || true

echo ""
echo "✓ FULL cleanup complete (runtime state cleared)"
```

### Cache Only
```bash
echo "Clearing caches only..."

# Python
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

# Test
rm -rf .pytest_cache .mypy_cache 2>/dev/null || true

# Frontend
rm -rf your_frontend/node_modules/.vite 2>/dev/null || true

echo "✓ Caches cleared"
```

### Logs Only
```bash
echo "Clearing logs..."

# Temporary logs
rm -f /tmp/backend_vibe.* /tmp/vite_vibe.* 2>/dev/null || true
rm -f /tmp/mcp-*.log 2>/dev/null || true

# Application logs (optional)
# rm -f logs/*.log 2>/dev/null || true

echo "✓ Logs cleared"
```

## When to Use

**Use /clean when:**
- Import errors that won't go away
- Weird caching issues
- Frontend build broken
- Services won't start properly
- After major dependency updates
- Everything is broken and you want fresh start

**Don't use /clean when:**
- Simple restart would work (`/restart`)
- Just testing code changes
- You want to keep runtime state

## Safety Checks

Before full clean (with runtime state):
```bash
# Warn user
echo "⚠️  This will delete:"
echo "  - Account configurations"
echo "  - Strategy state"
echo "  - Market subscriptions"
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted"
  exit 1
fi

# Backup before clearing
mkdir -p .backups/$(date +%Y%m%d_%H%M%S)
cp data/*.json .backups/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
echo "✓ Backed up runtime state to .backups/"
```

## After Clean

```bash
# Verify clean state
echo ""
echo "Verification:"
echo "  Python cache: $(find . -type d -name "__pycache__" | wc -l) dirs remaining"
echo "  Temp files: $(ls /tmp/*_vibe.* 2>/dev/null | wc -l) files remaining"
echo "  Runtime state: $(ls data/*.json 2>/dev/null | wc -l) files"
echo ""

# Next steps
echo "Ready for fresh start!"
echo ""
echo "Run: /start"
```

## Quick Reference

```bash
/clean          # Safe clean (caches only)
/clean all      # Nuclear (everything including state)
/clean cache    # Python + frontend caches
/clean logs     # Clear logs only

# Verify
/status         # Check clean state
/start          # Fresh start
```

## Tips

- Try `/restart clean` before `/clean`
- Use `/clean all` only when necessary
- Always have git commits before `/clean all`
- Check `/status` after cleaning
- Runtime state is valuable - backup before clearing
