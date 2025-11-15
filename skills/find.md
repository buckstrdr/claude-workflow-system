# Find - Smart Code Search

Intelligent code search across the YourProject codebase using semantic search (Serena MCP) with fallback to pattern matching.

## What This Skill Does

Finds code quickly using:
1. **Serena semantic search** (if MCP running) - Understands concepts
2. **Symbol search** (fallback) - Classes, functions, types
3. **Pattern matching** (fallback) - Regex/glob patterns
4. **Contextual search** - Understands what you're looking for

Returns file:line references for easy navigation.

## How to Use

```
/find OrderService                    # Find class/symbol
/find "submit order logic"            # Semantic search
/find pattern "async def.*order"      # Regex pattern
/find files "order*.py"                # File glob
/find usage handleWebSocket           # Find where used
```

## Implementation Strategy

Try search methods in order until successful:

### 1. Semantic Search (Serena MCP - Preferred)

Check if Serena is available:

```bash
ps aux | grep "serena start-mcp-server" | grep -v grep
```

If running, use Serena MCP tools (if available as MCP):

```python
# Attempt semantic search
try:
    # This would use mcp__serena__search_semantically if available
    results = semantic_search(query)
    present_results(results)
except:
    # Fall back to next method
    pass
```

**Output format:**
```
Found via semantic search:

1. your_backend/services/order_service.py:45
   class OrderService:
       """Handles order submission and lifecycle management."""

2. your_backend/api/routes/orders.py:23
   async def submit_order(order: OrderRequest, service: OrderServiceDep):
       """Submit a new order to the exchange."""
```

### 2. Symbol Search (Fast Fallback)

Use Glob to find symbol definitions:

```bash
# Search for class definitions
rg "^class\s+$SYMBOL" --type py

# Search for function definitions
rg "^(async\s+)?def\s+$SYMBOL" --type py --type ts --type tsx

# Search for TypeScript types/interfaces
rg "^(type|interface)\s+$SYMBOL" --type ts --type tsx
```

**Example:**
```
Query: OrderService

Searching for symbol 'OrderService'...

Found 3 definitions:

1. your_backend/services/order_service.py:45
   class OrderService:

2. your_backend/services/__init__.py:12
   from .order_service import OrderService

3. your_frontend/src/types/api.d.ts:234
   interface OrderService {
```

### 3. Pattern Search

Use Grep for pattern matching:

```bash
# User provided pattern
rg "$PATTERN" --type py --type ts --type tsx -n
```

**Example:**
```
Query: async def.*submit.*order

Pattern search results:

1. your_backend/services/order_service.py:87
   async def submit_order(self, order: OrderRequest) -> OrderResponse:

2. your_backend/api/routes/orders.py:34
   async def submit_order_endpoint(order: OrderRequest):
```

### 4. File Search

Use Glob for file patterns:

```bash
# Find files matching pattern
fd "$PATTERN"
# Or use glob
ls **/$PATTERN
```

**Example:**
```
Query: order*.py

File search results:

1. your_backend/api/routes/orders.py
2. your_backend/services/order_service.py
3. your_backend/api/schemas/orders.py
```

### 5. Usage Search (Find Callers)

Find where a symbol is used:

```bash
# Find imports
rg "import.*$SYMBOL|from.*import.*$SYMBOL" --type py --type ts

# Find references (not definitions)
rg "$SYMBOL" --type py --type ts | grep -v "^(class|def|type|interface)"
```

**Example:**
```
Query: usage submitOrder

Finding usages of 'submitOrder'...

Imported in:
1. your_backend/api/routes/orders.py:5
   from your_backend.services import OrderService

Used in:
2. your_backend/api/routes/orders.py:45
   result = await service.submit_order(order)

3. your_frontend/src/components/OrderForm.tsx:23
   const { submitOrder } = useStore();

4. your_frontend/src/components/OrderForm.tsx:67
   await submitOrder(orderData);
```

## Smart Query Interpretation

Analyze the query to choose the best search method:

```python
def interpret_query(query: str) -> SearchMethod:
    """Determine best search method from query."""

    # Explicit pattern
    if query.startswith("pattern "):
        return SearchMethod.PATTERN

    # File search
    if query.startswith("files ") or "*" in query or query.endswith(".py"):
        return SearchMethod.FILES

    # Usage search
    if query.startswith("usage ") or query.startswith("callers "):
        return SearchMethod.USAGE

    # Single word, capitalized = symbol
    if query[0].isupper() and " " not in query:
        return SearchMethod.SYMBOL

    # Natural language = semantic
    if len(query.split()) > 2:
        return SearchMethod.SEMANTIC

    # Default: try semantic, fall back to symbol
    return SearchMethod.SEMANTIC_WITH_FALLBACK
```

## Context-Aware Results

Provide context around matches:

```
Found: your_backend/services/order_service.py:87

Context:
  85:     async def validate_order(self, order: OrderRequest) -> None:
  86:         """Validate order before submission."""
  87:         if order.quantity <= 0:
  88:             raise ValueError("Quantity must be positive")
  89:
  90:     async def submit_order(self, order: OrderRequest) -> OrderResponse:
  91:         """Submit order to exchange after validation."""
  92:         await self.validate_order(order)
```

## Smart Filtering

Filter results by context:

- Backend code: `your_backend/**`
- Frontend code: `your_frontend/src/**`
- API routes: `your_backend/api/routes/**`
- Services: `your_backend/services/**`
- Components: `your_frontend/src/components/**`
- Types: `**/*.d.ts`, `**/schemas/**`

```
Query: OrderService backend

Searching in: your_backend/**

Results:
1. your_backend/services/order_service.py:45
2. your_backend/api/routes/orders.py:12
```

## Output Format

Always format as `file_path:line_number` for easy navigation:

```
Search: "order submission"

Results (3 matches):

Backend:
  your_backend/services/order_service.py:90
  your_backend/api/routes/orders.py:34

Frontend:
  your_frontend/src/components/OrderForm.tsx:45

Use Read tool with line numbers to view context.
```

## Error Handling

If no results:

```
No results found for: "xyz123"

Suggestions:
  - Check spelling
  - Try broader search: "xyz" or "123"
  - Search for related terms
  - Check if code exists in this branch

Or try:
  /find pattern "xyz.*123"  # Regex pattern
  /find files "*xyz*"       # File search
```

If Serena not running:

```
Note: Serena MCP not running (semantic search unavailable)
Falling back to symbol/pattern search.

For better results, start Serena:
  make mcp-start
```

## Tips

- Use semantic search for concepts ("where orders are validated")
- Use symbol search for exact names (OrderService)
- Use pattern search for regex ("async def.*order")
- Use file search for finding files ("order*.py")
- Combine with Read tool to view full context
- Results are sorted by relevance (semantic) or by path (symbol)
