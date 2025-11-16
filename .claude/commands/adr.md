# ADR - Architectural Decision Records

Document significant architectural decisions with context, rationale, and consequences.

## What This Skill Does

Creates lightweight Architectural Decision Records (ADRs) to capture:
- What decision was made
- Why it was made
- What alternatives were considered
- What are the consequences (good and bad)

Preserves institutional knowledge about "why things are the way they are".

## When to Use

**Create ADR for:**
- Technology choices (database, framework, library)
- Architectural patterns (microservices, monolith, event-driven)
- API design decisions (REST vs GraphQL, versioning strategy)
- Data model changes (schema design, migrations)
- Infrastructure decisions (deployment strategy, caching)
- Security decisions (authentication method, encryption)
- Performance optimizations (caching strategy, indexing)

**DO NOT create ADR for:**
- Routine bug fixes
- Code style preferences (use linter config)
- Temporary workarounds
- Implementation details (captured in code comments)

## Implementation

### Step 1: Create ADR Directory

```bash
mkdir -p .ian/adr
```

### Step 2: Number ADRs Sequentially

```bash
# Get next ADR number
LAST_ADR=$(ls .ian/adr/ 2>/dev/null | grep -E "^[0-9]+" | sort -n | tail -1 | grep -oE "^[0-9]+")
if [ -z "$LAST_ADR" ]; then
  NEXT_NUM="001"
else
  NEXT_NUM=$(printf "%03d" $((10#$LAST_ADR + 1)))
fi
```

### Step 3: ADR Template

```markdown
# ADR {NUMBER}: {TITLE}

**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-XXX

**Date**: {YYYY-MM-DD}

**Authors**: {NAME(S)}

**Related**: Issue #{NUMBER}, PR #{NUMBER}, ADR-{NUMBER}

---

## Context

### Problem
What problem are we trying to solve? What is the business or technical need?

### Background
What is the current state? What constraints exist?

### Stakeholders
Who is affected by this decision? (Users, developers, ops, business)

---

## Decision

### What We Decided
Clear statement of the decision made.

### Approach
How will this be implemented? What are the key technical details?

---

## Rationale

### Why This Decision
Reasoning behind choosing this approach.

### Key Factors
- Factor 1: Explanation
- Factor 2: Explanation
- Factor 3: Explanation

---

## Alternatives Considered

### Alternative 1: {NAME}
**Description**: {What it is}
**Pros**: {Benefits}
**Cons**: {Drawbacks}
**Why Not Chosen**: {Reason}

### Alternative 2: {NAME}
**Description**: {What it is}
**Pros**: {Benefits}
**Cons**: {Drawbacks}
**Why Not Chosen**: {Reason}

---

## Consequences

### Positive
- Benefit 1
- Benefit 2
- Benefit 3

### Negative
- Trade-off 1
- Trade-off 2
- Limitation 1

### Neutral
- Impact 1 (neither good nor bad, but noteworthy)

---

## Implementation

### Affected Components
- Component 1: {How it's affected}
- Component 2: {How it's affected}

### Migration Path
If applicable, how to migrate from old approach to new.

### Rollback Plan
If decision proves wrong, how to revert?

---

## Risks & Mitigations

### Risk 1
**Description**: {What could go wrong}
**Probability**: Low | Medium | High
**Impact**: Low | Medium | High
**Mitigation**: {How to reduce risk}

### Risk 2
**Description**: {What could go wrong}
**Probability**: Low | Medium | High
**Impact**: Low | Medium | High
**Mitigation**: {How to reduce risk}

---

## Validation

### Success Criteria
How do we know this decision is working?
- Metric 1: {Measurable outcome}
- Metric 2: {Measurable outcome}

### Review Date
When should we revisit this decision? (e.g., 3 months, 1 year)

---

## References

- Link to related documentation
- Link to research/blog posts
- Link to similar decisions in other projects
- Link to spec: `.ian/spec_*.md`

---

## Updates

### YYYY-MM-DD: {CHANGE}
{Description of update to this ADR}
```

## Example ADRs

### Example 1: Use Idempotency Store for Orders

```markdown
# ADR 001: Use Idempotency Store for Duplicate Order Prevention

**Status**: Accepted

**Date**: 2025-10-29

**Authors**: Claude Code, Ian

**Related**: Issue #42, Spec: .ian/spec_order_idempotency_20251029.md

---

## Context

### Problem
Users accidentally submit duplicate orders by clicking "submit" multiple times or due to network retries, resulting in unintended position doubling and potential losses.

### Background
Current order submission has no duplicate detection. Each POST to `/api/orders/submit` creates a new order, even if identical to a recent order.

### Stakeholders
- **Traders**: Need confidence their order submits exactly once
- **Backend**: Must implement efficient duplicate detection
- **Support**: Currently handles duplicate order complaints

---

## Decision

### What We Decided
Implement idempotency key system using in-memory store with TTL.

### Approach
- Clients include `idempotency_key` (UUID) in order request
- Backend checks idempotency store before order submission
- If key exists and within TTL (5 minutes): return original order
- If key expired or missing: process order normally
- Store keys in Redis with 5-minute expiration

---

## Rationale

### Why This Decision
- Industry standard approach (Stripe, AWS use idempotency keys)
- Simple to implement on both client and server
- Minimal performance impact
- Works with retries and multi-click scenarios

### Key Factors
- **Simplicity**: Redis provides TTL out of box
- **Performance**: In-memory lookup is fast (<1ms)
- **Reliability**: Handles race conditions correctly
- **Client Control**: Client generates key, server enforces

---

## Alternatives Considered

### Alternative 1: Database Deduplication
**Description**: Store order hashes in database, check before insert
**Pros**: Persistent, survives restarts
**Cons**: Slower (database query), more complex cleanup
**Why Not Chosen**: Performance critical for order submission, in-memory sufficient

### Alternative 2: Time-Window Deduplication
**Description**: Check last 5 seconds for identical orders (symbol, qty, side)
**Pros**: No client changes needed
**Cons**: Doesn't handle legitimate identical orders, race conditions
**Why Not Chosen**: False positives (user wants 2 identical orders), not reliable

### Alternative 3: UI Debouncing Only
**Description**: Disable submit button after click
**Pros**: Simple, no backend changes
**Cons**: Doesn't handle network retries, API direct calls
**Why Not Chosen**: Insufficient, must handle retries and API clients

---

## Consequences

### Positive
- Eliminates duplicate orders from multi-click
- Handles network retries correctly
- Low latency impact (<1ms)
- Industry-standard approach
- Works with API clients and UI

### Negative
- Clients must generate and track idempotency keys
- Redis adds dependency (already using for caching)
- Keys expire, very old retries won't be detected (acceptable)

### Neutral
- Requires client library update to include keys
- 5-minute window chosen (configurable if needed)

---

## Implementation

### Affected Components
- **OrderService**: Add idempotency check before submission
- **Redis**: Store idempotency keys with TTL
- **API Schema**: Add optional `idempotency_key` field
- **Frontend**: Generate UUIDs for order submissions
- **API Clients**: Update to include idempotency keys

### Migration Path
1. Deploy backend with idempotency key support (optional initially)
2. Update frontend to include keys
3. Update API clients to include keys
4. Monitor duplicate rate decrease
5. Consider making key required after adoption

### Rollback Plan
If issues arise:
1. Disable idempotency check (feature flag)
2. Orders process normally
3. Debug issue
4. Re-enable with fix

---

## Risks & Mitigations

### Risk 1: Redis Unavailable
**Probability**: Low
**Impact**: Medium
**Mitigation**: Fallback to processing order if Redis check fails (logged warning)

### Risk 2: Key Collisions
**Probability**: Very Low (UUID collision)
**Impact**: Medium (wrong order returned)
**Mitigation**: Use UUIDv4, collision probability negligible

### Risk 3: Legitimate Duplicate Orders
**Probability**: Low
**Impact**: Low (user confusion)
**Mitigation**: 5-minute TTL, user can retry after expiration

---

## Validation

### Success Criteria
- Duplicate order rate drops from 3% to <0.1%
- Order submission latency increases <5ms
- Redis hit rate >95% for duplicate checks
- Zero complaints about duplicate orders

### Review Date
3 months (2026-01-29) - Assess effectiveness and false positive rate

---

## References
- Stripe Idempotency: https://stripe.com/docs/api/idempotent_requests
- Redis TTL docs: https://redis.io/commands/expire
- RFC 4122 (UUID): https://tools.ietf.org/html/rfc4122
```

### Example 2: WebSocket Reconnection Strategy

```markdown
# ADR 002: Exponential Backoff for WebSocket Reconnection

**Status**: Accepted

**Date**: 2025-10-29

**Authors**: Claude Code, Ian

**Related**: Issue #27

---

## Context

### Problem
WebSocket connections drop due to network issues, server restarts, or timeouts. Currently no automatic reconnection, requiring page refresh.

### Background
Real-time market data critical for trading. Connection drops = missed quotes = poor trading decisions.

### Stakeholders
- **Traders**: Need reliable real-time data
- **Frontend**: Must handle reconnection gracefully
- **Backend**: Must handle reconnecting clients efficiently

---

## Decision

### What We Decided
Implement exponential backoff reconnection strategy with jitter and max retry limit.

### Approach
- Initial reconnect after 1 second
- Double delay each attempt: 1s, 2s, 4s, 8s, 16s
- Max delay: 30 seconds
- Add jitter (±25%) to prevent thundering herd
- Max retries: 10 attempts
- After max retries: show "reconnect" button

---

## Rationale

### Why This Decision
- **Exponential backoff**: Standard approach, prevents server overload
- **Jitter**: Spreads reconnection attempts, avoids spike
- **Max delay**: Prevents waiting minutes between attempts
- **Max retries**: Eventually stop, let user decide

### Key Factors
- Balance between quick recovery and server protection
- User experience: fast reconnect for brief issues, manual for outages
- Server load: Avoid thundering herd on server restart

---

## Alternatives Considered

### Alternative 1: Fixed Interval Reconnection
**Description**: Retry every 5 seconds indefinitely
**Pros**: Simple, predictable
**Cons**: Thundering herd, wastes resources
**Why Not Chosen**: Poor server behavior, no backpressure

### Alternative 2: Immediate Reconnect
**Description**: Retry instantly on disconnect
**Pros**: Fastest recovery
**Cons**: Hammers server, exacerbates outages
**Why Not Chosen**: Makes outages worse

---

## Consequences

### Positive
- Fast recovery from brief disconnects (1-2 seconds)
- Server-friendly during outages
- Standard, well-understood approach
- User control after max attempts

### Negative
- Longer waits for persistent issues
- Complexity in reconnection logic

---

## Implementation

### Affected Components
- **WebSocketManager**: Add reconnection logic
- **UI**: Show connection status indicator
- **Backend**: Handle reconnecting clients gracefully

### Rollback Plan
Remove reconnection logic, fall back to manual reconnect button.

---

## Validation

### Success Criteria
- 95% of brief disconnects recover within 5 seconds
- Zero server overload during outages
- User satisfaction with reconnection UX

### Review Date
1 month (2025-11-29)
```

## Interactive ADR Creation

When user invokes `/adr`, ask these questions:

**1. Decision Title**
```
What decision are you documenting?
(e.g., "Use Redis for idempotency store")
>
```

**2. Problem Statement**
```
What problem does this solve?
>
```

**3. Chosen Solution**
```
What did you decide to do?
>
```

**4. Alternatives**
```
What other options did you consider? (comma-separated)
>
```

**5. Rationale**
```
Why did you choose this approach?
>
```

**6. Consequences**
```
What are the positive and negative consequences?
>
```

**7. Related Items**
```
Related issue numbers, PR numbers, or spec files?
>
```

## Workflow Integration

### During Spec Creation

```bash
# If architecturally significant decision in spec:
/spec
# ... fill out spec ...

# In spec: "Create ADR? [x] Yes"

# Then create ADR:
/adr

# Link ADR to spec:
echo "Related ADR: .ian/adr/003-websocket-reconnection.md" >> .ian/spec_websocket_20251029.md
```

### During Implementation

```bash
# Realize architectural decision needed mid-implementation:

# Pause implementation
/adr

# Document decision
# Resume implementation with decision recorded
```

### During Code Review

```bash
# Reviewer: "Why did we choose Redis over database for this?"

# Create ADR to document reasoning:
/adr

# Reference in PR:
gh pr comment --body "Decision rationale: .ian/adr/004-redis-idempotency.md"
```

## ADR Status Lifecycle

```
Proposed → Accepted → (Deprecated or Superseded)
```

**Proposed**: Under discussion, not yet implemented
**Accepted**: Decided and implemented
**Deprecated**: No longer recommended, but still in use
**Superseded by ADR-XXX**: Replaced by newer decision

## Storage & Organization

```
.ian/adr/
  001-idempotency-store-for-orders.md
  002-websocket-reconnection-strategy.md
  003-trailing-bracket-calculation.md
  004-redis-caching-strategy.md
  README.md  # Index of all ADRs
```

## ADR Index

Maintain `.ian/adr/README.md`:

```markdown
# Architectural Decision Records

## Active ADRs
- ADR-001: Idempotency Store for Orders (Accepted)
- ADR-002: WebSocket Reconnection Strategy (Accepted)
- ADR-003: Trailing Bracket Calculation (Accepted)

## Superseded ADRs
- ADR-004: Original Caching Strategy (Superseded by ADR-010)

## Proposed ADRs
- ADR-005: GraphQL vs REST for New API (Proposed)
```

## Benefits

1. **Preserves knowledge** - "Why" doesn't get lost
2. **Onboarding** - New developers understand decisions
3. **Prevents revisiting** - Avoid rehashing same discussions
4. **Historical context** - See evolution of architecture
5. **Decision quality** - Forcing documentation improves thinking

## Tips

- **Be concise** - ADR should be readable in 5 minutes
- **Be honest** - Document trade-offs, not just benefits
- **Link everything** - Issues, PRs, specs, code
- **Update as learned** - Add notes when consequences discovered
- **Deprecate gracefully** - Explain why superseded

## Integration with Other Skills

- **Before**: `/spec` (if architecturally significant)
- **After**: Reference in implementation, code reviews
- **Related**: `/github` (link to issues/PRs)

## Common ADR Topics

- Technology selection
- API design
- Data modeling
- Deployment strategy
- Security approach
- Performance optimization
- Error handling strategy
- Testing approach
- Infrastructure choices
