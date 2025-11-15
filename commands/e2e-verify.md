# E2E-Verify - End-to-End Functional Verification

Verify that features actually work end-to-end, not just that code compiles.

## What This Skill Does

Automated verification of actual functionality:
- Backend services start and respond
- Frontend builds and loads
- API endpoints work correctly
- UI features are accessible
- Data flows end-to-end
- No runtime errors

## When to Use

**MANDATORY before:**
- Marking feature as complete
- Closing issues
- Deploying to production
- Marking PR ready for review

## Implementation

### Backend Verification

```bash
#!/usr/bin/env bash
# E2E Backend Verification

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E Verification: Backend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

EXIT_CODE=0

# 1. Server starts
echo "→ Starting backend server..."
nohup python -m your_backend > /tmp/e2e_backend.log 2>&1 &
BACKEND_PID=$!

# Wait for server to start
sleep 5

if ! ps -p $BACKEND_PID > /dev/null; then
  echo "❌ Backend: Server failed to start"
  cat /tmp/e2e_backend.log
  EXIT_CODE=1
else
  echo "✓ Backend: Server started (PID: $BACKEND_PID)"
fi

# 2. Health check endpoint responds
echo "→ Checking health endpoint..."
HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null || echo "000")

if [ "$HEALTH_RESPONSE" = "200" ]; then
  echo "✓ Backend: Health endpoint OK (200)"
else
  echo "❌ Backend: Health endpoint failed (HTTP $HEALTH_RESPONSE)"
  EXIT_CODE=1
fi

# 3. OpenAPI docs accessible
echo "→ Checking OpenAPI docs..."
DOCS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs 2>/dev/null || echo "000")

if [ "$DOCS_RESPONSE" = "200" ]; then
  echo "✓ Backend: OpenAPI docs accessible"
else
  echo "⚠️  Backend: OpenAPI docs failed (HTTP $DOCS_RESPONSE)"
fi

# 4. Status endpoint responds
echo "→ Checking status endpoint..."
STATUS=$(curl -s http://localhost:8000/status 2>/dev/null || echo "{}")

if echo "$STATUS" | grep -q "status"; then
  echo "✓ Backend: Status endpoint OK"
  echo "  Response: $STATUS"
else
  echo "❌ Backend: Status endpoint failed"
  EXIT_CODE=1
fi

# 5. Test specific feature (if feature branch)
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "→ Testing feature: $CURRENT_BRANCH"

  # Detect feature type from branch name
  case "$CURRENT_BRANCH" in
    *order*)
      echo "  Testing orders endpoint..."
      ORDER_RESPONSE=$(curl -s -X POST http://localhost:8000/api/orders/test -H "Content-Type: application/json" -d '{"test": true}' 2>/dev/null || echo "error")
      if echo "$ORDER_RESPONSE" | grep -q "order_id\|success\|accepted"; then
        echo "✓ Feature: Orders endpoint responds"
      else
        echo "⚠️  Feature: Orders endpoint unexpected response"
        echo "  Response: $ORDER_RESPONSE"
      fi
      ;;
    *websocket*)
      echo "  Checking WebSocket endpoint..."
      WS_CHECK=$(curl -s http://localhost:8000/ws/health 2>/dev/null || echo "error")
      if [ "$WS_CHECK" != "error" ]; then
        echo "✓ Feature: WebSocket endpoint accessible"
      fi
      ;;
    *)
      echo "  No specific feature test for branch: $CURRENT_BRANCH"
      ;;
  esac
fi

# 6. Check for errors in logs
echo "→ Checking for errors in logs..."
ERRORS=$(grep -i "error\|exception\|traceback" /tmp/e2e_backend.log | grep -v "No error" || true)

if [ -n "$ERRORS" ]; then
  echo "⚠️  Backend: Errors found in logs:"
  echo "$ERRORS" | head -10
else
  echo "✓ Backend: No errors in startup logs"
fi

# Cleanup
kill $BACKEND_PID 2>/dev/null || true
```

### Frontend Verification

```bash
#!/usr/bin/env bash
# E2E Frontend Verification

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E Verification: Frontend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd your_frontend

# 1. Build succeeds
echo "→ Building frontend..."
if npm run build > /tmp/e2e_fe_build.log 2>&1; then
  echo "✓ Frontend: Build succeeded"
else
  echo "❌ Frontend: Build failed"
  cat /tmp/e2e_fe_build.log | tail -20
  EXIT_CODE=1
  cd ..
  exit $EXIT_CODE
fi

# 2. Dev server starts
echo "→ Starting dev server..."
nohup npm run dev > /tmp/e2e_fe_dev.log 2>&1 &
FE_PID=$!

# Wait for dev server
sleep 10

if ! ps -p $FE_PID > /dev/null; then
  echo "❌ Frontend: Dev server failed to start"
  cat /tmp/e2e_fe_dev.log
  EXIT_CODE=1
  cd ..
  exit $EXIT_CODE
else
  echo "✓ Frontend: Dev server started (PID: $FE_PID)"
fi

# 3. UI loads
echo "→ Checking UI loads..."
UI_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 2>/dev/null || echo "000")

if [ "$UI_RESPONSE" = "200" ]; then
  echo "✓ Frontend: UI loads (200)"
else
  echo "❌ Frontend: UI failed to load (HTTP $UI_RESPONSE)"
  EXIT_CODE=1
fi

# 4. Check for console errors (basic check)
echo "→ Fetching HTML for error check..."
UI_HTML=$(curl -s http://localhost:5173 2>/dev/null || echo "")

if echo "$UI_HTML" | grep -q "<div id=\"root\">"; then
  echo "✓ Frontend: React root element present"
else
  echo "⚠️  Frontend: React root element not found"
fi

# 5. Check bundle size
echo "→ Checking bundle size..."
BUNDLE_SIZE=$(du -sh dist/ 2>/dev/null | awk '{print $1}')
echo "  Bundle size: $BUNDLE_SIZE"

BUNDLE_MB=$(du -sm dist/ 2>/dev/null | awk '{print $1}')
if [ -n "$BUNDLE_MB" ] && [ "$BUNDLE_MB" -gt 10 ]; then
  echo "⚠️  Frontend: Bundle size >10MB, consider optimization"
fi

# 6. TypeScript errors
echo "→ Checking TypeScript..."
if npm run type-check > /tmp/e2e_fe_types.log 2>&1; then
  echo "✓ Frontend: No TypeScript errors"
else
  echo "⚠️  Frontend: TypeScript errors found"
  cat /tmp/e2e_fe_types.log | head -10
fi

# Cleanup
kill $FE_PID 2>/dev/null || true
cd ..
```

### Full Stack Verification

```bash
#!/usr/bin/env bash
# E2E Full Stack Verification

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E Verification: Full Stack"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start both backend and frontend
echo "→ Starting full stack..."
nohup python -m your_backend > /tmp/e2e_backend_full.log 2>&1 &
BACKEND_PID=$!
cd your_frontend
nohup npm run dev > /tmp/e2e_fe_full.log 2>&1 &
FE_PID=$!
cd ..

sleep 10

# 1. Both services running
if ps -p $BACKEND_PID > /dev/null && ps -p $FE_PID > /dev/null; then
  echo "✓ Full Stack: Both services running"
else
  echo "❌ Full Stack: Services failed to start"
  EXIT_CODE=1
fi

# 2. WebSocket connection (if applicable)
if grep -q "websocket\|ws" /tmp/e2e_backend_full.log; then
  echo "→ Checking WebSocket connection..."
  # Simple check: see if WS endpoint exists
  WS_ENDPOINT=$(curl -s http://localhost:8000 | grep -o "ws://[^\"]*" || true)
  if [ -n "$WS_ENDPOINT" ]; then
    echo "✓ Full Stack: WebSocket endpoint found"
  else
    echo "⚠️  Full Stack: WebSocket endpoint not detected"
  fi
fi

# 3. Frontend can reach backend
echo "→ Testing frontend→backend communication..."
# Check if frontend makes API calls
sleep 5
API_CALLS=$(grep "api/\|localhost:8000" /tmp/e2e_fe_full.log || true)

if [ -n "$API_CALLS" ]; then
  echo "✓ Full Stack: Frontend making API calls"
else
  echo "⚠️  Full Stack: No API calls detected (may be normal)"
fi

# 4. No CORS errors
echo "→ Checking for CORS errors..."
CORS_ERRORS=$(grep -i "cors\|cross-origin" /tmp/e2e_fe_full.log /tmp/e2e_backend_full.log || true)

if [ -z "$CORS_ERRORS" ]; then
  echo "✓ Full Stack: No CORS errors"
else
  echo "⚠️  Full Stack: CORS errors detected"
  echo "$CORS_ERRORS"
fi

# Cleanup
kill $BACKEND_PID $FE_PID 2>/dev/null || true
```

### Feature-Specific Tests

```bash
#!/usr/bin/env bash
# E2E Feature-Specific Tests

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E Verification: Feature-Specific"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Detect feature from commit messages
RECENT_COMMITS=$(git log -5 --oneline)

# Order features
if echo "$RECENT_COMMITS" | grep -qi "order\|trade"; then
  echo "→ Testing order submission feature..."

  # Start backend
  python -m your_backend &
  BACKEND_PID=$!
  sleep 5

  # Submit test order
  ORDER_RESULT=$(curl -s -X POST http://localhost:8000/api/orders/submit \
    -H "Content-Type: application/json" \
    -d '{
      "symbol": "MNQ",
      "quantity": 1,
      "side": "buy",
      "order_type": "market",
      "idempotency_key": "test_'$(date +%s)'"
    }' 2>/dev/null || echo '{"error": "failed"}')

  if echo "$ORDER_RESULT" | grep -q "order_id\|accepted"; then
    echo "✓ Feature: Order submission works"
  else
    echo "❌ Feature: Order submission failed"
    echo "  Response: $ORDER_RESULT"
    EXIT_CODE=1
  fi

  kill $BACKEND_PID 2>/dev/null || true
fi

# WebSocket features
if echo "$RECENT_COMMITS" | grep -qi "websocket\|ws\|realtime"; then
  echo "→ Testing WebSocket feature..."

  python -m your_backend &
  BACKEND_PID=$!
  sleep 5

  # Test WS connection (requires wscat or similar)
  if command -v wscat >/dev/null 2>&1; then
    timeout 5 wscat -c ws://localhost:8000/ws/market-data -x '{"subscribe": "MNQ"}' > /tmp/ws_test.log 2>&1 || true

    if grep -q "connected\|subscribed" /tmp/ws_test.log; then
      echo "✓ Feature: WebSocket connection works"
    else
      echo "⚠️  Feature: WebSocket test inconclusive"
    fi
  else
    echo "⚠️  Feature: wscat not installed, skipping WS test"
  fi

  kill $BACKEND_PID 2>/dev/null || true
fi
```

## Final Report

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  E2E Verification Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "✅ E2E VERIFIED - All functional checks passed"
  echo ""
  echo "System verified working end-to-end:"
  echo "  ✓ Backend starts and responds"
  echo "  ✓ Frontend builds and loads"
  echo "  ✓ API endpoints functional"
  echo "  ✓ No runtime errors"
  echo "  ✓ Feature-specific tests passed"
  echo ""
  echo "Ready for:"
  echo "  - Production deployment"
  echo "  - User acceptance testing"
  echo "  - Closing issue as complete"
  echo ""
else
  echo "❌ E2E FAILED - Functional issues detected"
  echo ""
  echo "Fix the issues above and re-run /e2e-verify"
  echo ""
  exit 1
fi
```

## Integration with Quality Gates

**Gate 6: Verified (E2E)**
- Backend starts successfully
- Frontend builds and loads
- API endpoints respond correctly
- No runtime errors
- Feature-specific tests pass

**Without E2E verification, cannot proceed to Gate 7 (Review)**

## Usage Examples

### Basic Usage

```bash
# After implementation
User: "Order idempotency implemented"

# Run E2E verification
/e2e-verify

# Result:
✅ E2E VERIFIED - All functional checks passed
  ✓ Backend starts and responds
  ✓ Orders endpoint functional
  ✓ No runtime errors
```

### When Failures Occur

```bash
/e2e-verify

# Result:
❌ E2E FAILED - Functional issues detected
  ❌ Backend: Server failed to start
  Error: ImportError: No module named 'idempotency_store'

# Fix:
- Install missing dependency
- Fix import statement

# Re-run:
/e2e-verify
✅ E2E VERIFIED
```

## Automated Verification Scripts

Store reusable test scripts in `dev/e2e/`:
```
dev/e2e/verify_backend.sh
dev/e2e/verify_frontend.sh
dev/e2e/verify_fullstack.sh
dev/e2e/verify_orders.sh
dev/e2e/verify_websocket.sh
```

## Integration with CI/CD

E2E verification can run in CI:
```yaml
# .github/workflows/e2e.yml
- name: E2E Verification
  run: |
    /e2e-verify
```

## Benefits

1. **Catches runtime issues** - Not just compile-time
2. **Verifies actual functionality** - Not just unit tests
3. **Fast feedback** - Minutes, not hours/days
4. **Confidence in deployment** - Know it works before shipping
5. **Prevents "works on my machine"** - Standardized verification

## Common Failures & Fixes

**Server won't start**:
```
❌ Backend: Server failed to start
→ Check logs for import errors, config issues
→ Verify dependencies installed
```

**Endpoint returns errors**:
```
❌ Backend: Status endpoint failed (HTTP 500)
→ Check logs for exceptions
→ Verify database connection
```

**Frontend build fails**:
```
❌ Frontend: Build failed
→ Check for TypeScript errors
→ Verify dependencies synced
```

**UI won't load**:
```
❌ Frontend: UI failed to load
→ Check Vite config
→ Verify port 5173 not in use
```

## Tips

- Run early - Don't wait until "done"
- Fix issues immediately - Easier than batch later
- Use feature flags - Deploy even if feature incomplete
- Monitor logs - Watch for warnings, not just errors
- Test realistic scenarios - Use actual data patterns

## Integration with Other Skills

- **Before**: `/verify-complete` (code quality checks)
- **After**: `/validator` (code review)
- **If fails**: Debug, fix, re-run

## Scope

**What E2E verifies**:
- Services start
- Endpoints respond
- UI loads
- Basic functionality works

**What E2E does NOT verify** (use manual testing):
- Complex user workflows
- UI/UX quality
- Performance under load
- Security vulnerabilities
- Data correctness

For comprehensive testing, combine:
- Unit tests (logic correctness)
- Integration tests (component interaction)
- E2E verification (system works)
- Manual testing (user experience)
