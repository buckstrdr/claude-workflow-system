# Sync - Schema Synchronization

Synchronize backend API schema, OpenAPI spec, and frontend TypeScript types to ensure consistency across the stack.

## What This Skill Does

Ensures the backend and frontend are in sync:
1. Generate OpenAPI spec from FastAPI backend
2. Generate TypeScript types from OpenAPI spec
3. Verify types are up-to-date
4. Update semantic index (optional)
5. Report sync status

## How to Use

```
/sync              # Full sync (OpenAPI + types + semantic)
/sync fast         # Just OpenAPI + types (skip semantic)
/sync check        # Check if sync needed (no changes)
```

## Why This Matters

When backend API changes:
- Frontend types become out of sync
- TypeScript shows incorrect types
- API calls may fail at runtime
- Developer confusion and bugs

**Solution:** Run `/sync` after backend schema changes.

## Implementation

### Full Sync
```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Schema Synchronization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Generate OpenAPI spec
echo ""
echo "Step 1/3: Generating OpenAPI spec..."
make openapi

if [ $? -eq 0 ]; then
  echo "✓ OpenAPI spec generated: .serena/knowledge/openapi.json"
else
  echo "✗ OpenAPI generation failed"
  exit 1
fi

# 2. Generate frontend types
echo ""
echo "Step 2/3: Generating TypeScript types..."
make types

if [ $? -eq 0 ]; then
  echo "✓ Frontend types generated: topstepx_frontend/src/types/api.d.ts"
else
  echo "✗ Type generation failed"
  exit 1
fi

# 3. Update semantic index
echo ""
echo "Step 3/3: Updating semantic index..."
make semantic

if [ $? -eq 0 ]; then
  echo "✓ Semantic index updated"
else
  echo "⚠ Semantic index update failed (non-critical)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Synchronization Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Fast Sync (Skip Semantic)
```bash
echo "Fast sync: OpenAPI + types only..."

make openapi && make types

if [ $? -eq 0 ]; then
  echo "✓ Fast sync complete"
else
  echo "✗ Sync failed"
  exit 1
fi
```

### Check Sync Status
```bash
echo "Checking sync status..."

# Check if OpenAPI exists
if [ ! -f .serena/knowledge/openapi.json ]; then
  echo "✗ OpenAPI spec missing - run: /sync"
  exit 1
fi

# Check if types exist
if [ ! -f topstepx_frontend/src/types/api.d.ts ]; then
  echo "✗ Frontend types missing - run: /sync"
  exit 1
fi

# Check modification times
OPENAPI_MOD=$(stat -c %Y .serena/knowledge/openapi.json 2>/dev/null || stat -f %m .serena/knowledge/openapi.json)
TYPES_MOD=$(stat -c %Y topstepx_frontend/src/types/api.d.ts 2>/dev/null || stat -f %m topstepx_frontend/src/types/api.d.ts)

# Check if backend schemas newer than OpenAPI
BACKEND_MOD=$(find topstepx_backend/api/schemas -name "*.py" -exec stat -c %Y {} \; 2>/dev/null | sort -rn | head -1)

if [ "$BACKEND_MOD" -gt "$OPENAPI_MOD" ]; then
  echo "⚠ Backend schemas modified since last sync"
  echo "  Run: /sync"
  exit 1
fi

if [ "$OPENAPI_MOD" -gt "$TYPES_MOD" ]; then
  echo "⚠ OpenAPI spec newer than frontend types"
  echo "  Run: /sync"
  exit 1
fi

echo "✓ Schemas are in sync"
```

## What Gets Updated

### 1. OpenAPI Spec (.serena/knowledge/openapi.json)
Generated from FastAPI routes and Pydantic schemas:
- All endpoints with request/response types
- Schema definitions
- Validation rules
- Descriptions and examples

### 2. Frontend Types (topstepx_frontend/src/types/api.d.ts)
TypeScript interfaces generated from OpenAPI:
```typescript
// Auto-generated from OpenAPI
export interface components {
  schemas: {
    OrderRequest: {
      symbol: string;
      quantity: number;
      order_type: "market" | "limit";
      limit_price?: number;
    };
    OrderResponse: {
      id: string;
      status: "pending" | "filled" | "rejected";
      fill_price?: number;
    };
    // ... all other schemas
  };
}
```

### 3. Semantic Index (optional)
Updates code search index for faster semantic queries.

## When to Run

**Always sync after:**
- Adding new API endpoints
- Changing request/response schemas
- Modifying Pydantic models
- Adding/removing fields
- Changing validation rules

**Before:**
- Working on frontend features
- Testing API integration
- Creating pull requests
- Running CI checks

## Automatic Sync

TopStepX has git hooks that auto-sync:

**post-commit hook:**
```bash
# If backend schemas changed, auto-regenerate OpenAPI and types
if git diff HEAD~1 --name-only | grep -q "topstepx_backend/api/"; then
  make openapi && make types
fi
```

So committing backend changes automatically triggers sync!

## Verification

After syncing, verify it worked:

```bash
# 1. Check files exist
ls -lh .serena/knowledge/openapi.json
ls -lh topstepx_frontend/src/types/api.d.ts

# 2. Check TypeScript compiles
cd topstepx_frontend && npm run build

# 3. Test an import
cd topstepx_frontend && node -e "
  const types = require('./src/types/api.d.ts');
  console.log('Types loaded successfully');
"
```

## Troubleshooting

**Issue: OpenAPI generation fails**
```
Solution:
  1. Check backend imports: python -c "import topstepx_backend"
  2. Check for syntax errors in schemas
  3. Run: python dev/devtools/docs/generate_openapi.py
  4. Check error output
```

**Issue: Type generation fails**
```
Solution:
  1. Verify OpenAPI spec is valid JSON
  2. Check npm is installed: npm --version
  3. Run manually: npx openapi-typescript .serena/knowledge/openapi.json -o /tmp/test.d.ts
  4. Check for OpenAPI spec issues
```

**Issue: Types don't match backend**
```
Solution:
  1. Ensure you saved backend changes
  2. Run full sync: /sync
  3. Check git status - uncommitted schema changes?
  4. Restart TypeScript server in VSCode
```

## Integration with CI

CI checks enforce sync:

```bash
# .github/workflows/ci.yml
- name: Check schema sync
  run: |
    make openapi
    make types
    git diff --exit-code topstepx_frontend/src/types/api.d.ts
```

If types are out of sync, CI fails!

## Tips

- Run `/sync` frequently during backend development
- Git hooks auto-sync on commit (usually sufficient)
- Check `/status` to see if sync needed
- Fast sync (`/sync fast`) is usually enough
- Full sync before commits/PRs
- Types are generated, never edit manually

## Quick Reference

```bash
# Full sync
make openapi && make types && make semantic

# Fast sync (common)
make openapi && make types

# Just OpenAPI
make openapi

# Just types (if OpenAPI already updated)
make types

# Check sync status
git diff topstepx_frontend/src/types/api.d.ts
```
