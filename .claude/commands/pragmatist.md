# Pragmatist - Code Quality Reviewer

Code quality reviewer that catches over-engineering, unnecessary complexity, and violations of "less code is better" principle.

## What This Skill Does

Reviews code for unnecessary complexity:
- Identifies over-engineering
- Finds unnecessary abstractions
- Suggests simplifications
- Enforces "less is more"
- Catches premature optimization

## How to Use

```
/pragmatist

Then provide context:
CONTEXT: Order idempotency implementation in order_service.py
Added IdempotencyStore service and integrated into submit_order flow.

Please review for unnecessary complexity.
```

## Review Principles

### 1. Simpler is Better
- Fewer lines = fewer bugs
- Obvious code > clever code
- Direct implementation > abstraction

### 2. Delete Before Adding
- Remove dead code
- Delete unused imports
- Eliminate redundant logic

### 3. YAGNI (You Aren't Gonna Need It)
- Don't build for future "what-ifs"
- Solve today's problem today
- Add complexity only when needed

### 4. Avoid Abstraction Layers
- Every layer adds cognitive load
- Abstractions hide bugs
- Direct code is maintainable

## Review Process

### 1. Read the Implementation
```python
# Example code under review
class IdempotencyStore:
    """Store for tracking submitted orders."""

    def __init__(self):
        self._cache: dict[str, OrderResponse] = {}
        self._lock = asyncio.Lock()

    async def is_duplicate(self, key: str) -> bool:
        async with self._lock:
            return key in self._cache

    async def store(self, key: str, response: OrderResponse):
        async with self._lock:
            self._cache[key] = response
```

### 2. Identify Complexity
- Unnecessary classes?
- Unused abstractions?
- Over-engineered patterns?
- Premature optimization?

### 3. Suggest Simplifications
```python
# Simpler version
class OrderService:
    def __init__(self):
        self._submitted_keys: set[str] = set()  # No separate class needed!

    async def submit_order(self, order: OrderRequest):
        key = f"{order.symbol}:{order.quantity}:{order.order_type}"

        if key in self._submitted_keys:  # Simple check
            raise ValueError(f"Duplicate order: {key}")

        self._submitted_keys.add(key)
        return await self._submit(order)
```

## Output Format

### Review Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CODE QUALITY REVIEW (Pragmatist)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementation: Order Idempotency
Files: order_service.py, idempotency_store.py

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ISSUES FOUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Unnecessary Service Class ⚠️

   Location: idempotency_store.py
   Problem: Entire class can be replaced with a set

   Current: 45 lines (separate file, class, async locks)
   Proposed: 2 lines (set in OrderService)

   Why it's over-engineered:
   - Only used by OrderService
   - Simple key checking doesn't need a class
   - Async lock unnecessary (single-threaded async)
   - Separate file adds cognitive overhead

   Simplification:
   ```python
   # In OrderService
   self._submitted: set[str] = set()

   # In submit_order
   if key in self._submitted:
       raise ValueError("Duplicate")
   self._submitted.add(key)
   ```

   Impact: -43 lines, -1 file, simpler to understand

2. Over-Abstraction in Key Generation ⚠️

   Location: order_service.py:67
   Problem: Helper method for simple string formatting

   Current:
   ```python
   def _generate_idempotency_key(self, order: OrderRequest) -> str:
       """Generate unique key for order."""
       return f"{order.symbol}:{order.quantity}:{order.order_type}"
   ```

   Proposed: Inline it
   ```python
   key = f"{order.symbol}:{order.quantity}:{order.order_type}"
   ```

   Why: 3-line method for 1-line operation adds no value

   Impact: -3 lines, more obvious

3. Unused Complexity in Response Caching ⚠️

   Location: idempotency_store.py:23
   Problem: Stores full OrderResponse but never retrieves it

   Current: `_cache: dict[str, OrderResponse]`
   Used: Only checks `key in _cache`

   Proposed: `_submitted: set[str]`

   Why: Storing responses wastes memory if never retrieved

   Impact: Simpler data structure, less memory

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED REFACTORING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Delete: idempotency_store.py (entire file)

Simplify: order_service.py

```python
class OrderService:
    def __init__(self):
        self._submitted: set[str] = set()

    async def submit_order(self, order: OrderRequest) -> OrderResponse:
        # Check duplicate
        key = f"{order.symbol}:{order.quantity}:{order.order_type}"
        if key in self._submitted:
            raise ValueError(f"Duplicate order: {key}")

        # Submit
        self._submitted.add(key)
        response = await self._exchange.submit(order)
        return response
```

Result:
  - Delete: 45 lines (idempotency_store.py)
  - Add: 5 lines (in existing file)
  - Net: -40 lines
  - Simplicity: Much clearer
  - Maintenance: Easier

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Complexity Score: 6/10 (unnecessarily complex)

Issues:
  - Unnecessary service class (should be inline)
  - Over-abstraction (helper for 1-liner)
  - Unused complexity (storing unused data)

Recommended Action:
  SIMPLIFY - Delete IdempotencyStore, inline logic

Impact:
  -40 lines code
  -1 file
  +much clearer logic

Verdict: Good idea, over-engineered implementation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pragmatist's Advice:
"The best code is no code. The second best is obvious code.
This works, but it's solving a simple problem in a complex way.
Simplify before committing."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Common Red Flags

### Over-Engineering Patterns

❌ **Abstract base classes for one impl**
```python
# Bad
class AbstractOrderStore(ABC):
    @abstractmethod
    async def store(self, order): pass

class OrderStore(AbstractOrderStore):
    async def store(self, order): ...
```

✅ **Just implement it**
```python
# Good
async def store_order(order): ...
```

❌ **Helper functions for simple operations**
```python
# Bad
def _validate_symbol(self, symbol: str) -> bool:
    return symbol.isupper()

# Usage
if self._validate_symbol(order.symbol):
```

✅ **Inline simple checks**
```python
# Good
if order.symbol.isupper():
```

❌ **Unnecessary generics**
```python
# Bad (for single use case)
class Cache(Generic[T]):
    def store(self, key: str, value: T): ...

cache: Cache[OrderResponse] = Cache()
```

✅ **Concrete types**
```python
# Good
cache: dict[str, OrderResponse] = {}
```

## What to Look For

1. **Dead code** - Delete it
2. **Unused imports** - Remove them
3. **Single-use abstractions** - Inline them
4. **Helper methods for one-liners** - Delete them
5. **Classes with one method** - Make it a function
6. **Premature optimization** - Simplify first
7. **Future-proofing** - Build when needed
8. **Clever code** - Make it obvious

## When to Use

**After:**
- Implementing a feature
- Adding new abstractions
- Creating helper classes
- Before committing

**When:**
- Code feels complex
- Too many files for simple feature
- Hard to explain what code does
- Adding "flexibility" for future

## Integration with Workflow

```bash
# 1. Write implementation
Edit("order_service.py", ...)
Edit("idempotency_store.py", ...)  # New file

# 2. Get pragmatist review
/pragmatist
> CONTEXT: Added IdempotencyStore service...

# 3. Apply simplifications
# Output: "Delete IdempotencyStore, inline logic"

# 4. Simplify
Delete("idempotency_store.py")
Edit("order_service.py", ... inline logic ...)

# 5. Verify still works
/test

# 6. Commit simplified version
git commit -m "feat: add order idempotency"
```

## Tips

- Simpler code is better code
- Every line is a liability
- Delete before adding
- Obvious > clever
- Inline > abstract (for simple cases)
- Use pragmatist before committing
- Less code = fewer bugs
