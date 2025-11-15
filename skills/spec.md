# Spec - Specification-First Development

Create comprehensive specifications before implementation to ensure complete, correct solutions on the first try.

## What This Skill Does

Interactive specification wizard that captures:
- Problem statement and user need
- Minimal viable solution
- Scope boundaries (what we're NOT building)
- Success criteria
- Test strategy
- API contracts
- Edge cases
- Architectural decisions

## When to Use

**ALWAYS use before implementation work:**
- Starting new feature
- Fixing complex bugs
- Making architectural changes
- Building new components
- Refactoring significant code

**DO NOT use for:**
- Trivial fixes (typos, formatting)
- Documentation-only changes
- Configuration updates
- Quick experiments/spikes (mark as prototype)

## Implementation

### Step 1: Create Spec File

```bash
# Auto-generate filename
FEATURE=$(echo "$TASK" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
DATE=$(date +%Y%m%d)
SPEC_FILE=".ian/spec_${FEATURE}_${DATE}.md"

touch "$SPEC_FILE"
```

### Step 2: Capture Requirements

Use this template structure:

```markdown
# Specification: {FEATURE_NAME}

**Created**: {DATE}
**Author**: Claude Code + {USER}
**Related Issue**: #{ISSUE_NUMBER} (if applicable)
**Status**: Draft | Approved | In Progress | Complete

---

## 1. Problem Statement

### What problem are we solving?
{Describe the user pain point or business need}

### Who is affected?
{Identify users, systems, or components impacted}

### Why now?
{Urgency, dependencies, or business drivers}

---

## 2. Proposed Solution

### High-Level Approach
{Brief description of the solution strategy}

### Minimal Viable Solution
{What's the simplest thing that solves the core problem?}

### What We're NOT Building
{Explicit scope boundaries - features/complexity we're excluding}

---

## 3. Success Criteria

### Functional Requirements
- [ ] Requirement 1: {Specific, measurable outcome}
- [ ] Requirement 2: {Specific, measurable outcome}
- [ ] Requirement 3: {Specific, measurable outcome}

### Non-Functional Requirements
- [ ] Performance: {Target metrics}
- [ ] Reliability: {Uptime/error rate targets}
- [ ] Security: {Security requirements}

### Definition of Done
How do we know this is complete?
- [ ] All functional requirements met
- [ ] All tests passing
- [ ] Documentation updated
- [ ] E2E verification complete
- [ ] Code reviewed and approved

---

## 4. Technical Design

### Architecture
{Component diagram, data flow, or system architecture}

### API Contract
{Input/output specifications, endpoints, data schemas}

**Example:**
```
POST /api/orders/submit
Request: {
  "symbol": "MNQ",
  "quantity": 1,
  "idempotency_key": "uuid"
}
Response: {
  "order_id": "uuid",
  "status": "accepted" | "rejected"
}
```

### Data Models
{Database schemas, data structures, state management}

### Dependencies
{External systems, libraries, or services required}

---

## 5. Implementation Plan

### Files to Create/Modify
- `your_backend/services/order_service.py` - Add idempotency check
- `your_backend/models/idempotency.py` - New model
- `your_backend/tests/test_order_idempotency.py` - Test suite

### Key Components
1. {Component 1}: {Purpose and responsibility}
2. {Component 2}: {Purpose and responsibility}
3. {Component 3}: {Purpose and responsibility}

### Integration Points
- {System A} → {Integration method}
- {System B} → {Integration method}

---

## 6. Test Strategy

### Unit Tests
- Test 1: {Scenario}
- Test 2: {Scenario}
- Test 3: {Scenario}

### Integration Tests
- Test 1: {End-to-end scenario}
- Test 2: {End-to-end scenario}

### Edge Cases
- Edge case 1: {Scenario and expected behavior}
- Edge case 2: {Scenario and expected behavior}
- Edge case 3: {Scenario and expected behavior}

### Error Scenarios
- Error 1: {Invalid input, expected error}
- Error 2: {System failure, expected recovery}

---

## 7. Edge Cases & Error Handling

### Input Validation
- {Validation rule 1}
- {Validation rule 2}

### Error Scenarios
- {Error scenario 1}: {How to handle}
- {Error scenario 2}: {How to handle}

### Boundary Conditions
- {Boundary 1}: {Behavior at boundary}
- {Boundary 2}: {Behavior at boundary}

---

## 8. Architectural Decisions

### Key Decisions
1. **Decision**: {What was decided}
   - **Rationale**: {Why this approach}
   - **Alternatives**: {What else was considered}
   - **Trade-offs**: {Pros and cons}

2. **Decision**: {What was decided}
   - **Rationale**: {Why this approach}
   - **Alternatives**: {What else was considered}
   - **Trade-offs**: {Pros and cons}

### Create ADR?
- [ ] Yes - Create formal ADR in `.ian/adr/` if architecturally significant
- [ ] No - Decision captured in spec is sufficient

---

## 9. Risks & Mitigations

### Technical Risks
- Risk 1: {Description} → Mitigation: {Approach}
- Risk 2: {Description} → Mitigation: {Approach}

### Dependencies
- Dependency 1: {What we depend on} → Risk: {What if it fails}

---

## 10. Rollout Plan

### Deployment Strategy
- {How will this be deployed? Feature flag? Gradual rollout?}

### Monitoring
- {What metrics/logs to watch after deployment}

### Rollback Plan
- {How to revert if issues found in production}

---

## 11. Estimated Effort

- **Specification**: {Time spent}
- **Implementation**: {Estimated time}
- **Testing**: {Estimated time}
- **Integration**: {Estimated time}
- **Total**: {Estimated total time}

---

## 12. Approval

- [ ] Specification reviewed
- [ ] Technical approach validated
- [ ] Scope confirmed
- [ ] Ready to implement

**Approved by**: {USER} on {DATE}
**Approved by**: {REVIEWER} on {DATE} (if applicable)

---

## 13. Implementation Tracking

### Status
- [x] Spec created
- [ ] Tests written (Red phase)
- [ ] Implementation complete (Green phase)
- [ ] Refactored
- [ ] Integrated (OpenAPI, types, docs)
- [ ] E2E verified
- [ ] Code reviewed
- [ ] Complete

### Related Links
- Issue: #{ISSUE_NUMBER}
- PR: #{PR_NUMBER}
- ADR: {ADR_NUMBER} (if created)

```

### Step 3: Interactive Prompts

When user invokes `/spec`, ask these questions:

**1. Problem Statement**
```
What problem are we solving? (User pain point or business need)
>
```

**2. Minimal Solution**
```
What's the simplest solution that solves the core problem?
>
```

**3. Scope Boundaries**
```
What are we explicitly NOT building? (Features/complexity to exclude)
>
```

**4. Success Criteria**
```
How do we know this is done? (Specific, measurable outcomes)
>
```

**5. API Contract** (if applicable)
```
What are the inputs and outputs? (Request/response format)
>
```

**6. Edge Cases**
```
What edge cases or error scenarios must we handle?
>
```

**7. Architectural Impact**
```
Does this require architectural decisions? (Yes/No)
If yes, what are the key decisions and alternatives?
>
```

### Step 4: Validate Completeness

Before marking spec as "Approved", verify:
- [ ] Problem clearly stated
- [ ] Solution is minimal and focused
- [ ] Scope boundaries explicit
- [ ] Success criteria measurable
- [ ] Test strategy defined
- [ ] Edge cases identified
- [ ] No ambiguity in requirements

### Step 5: Link to Issue

```bash
# If GitHub issue exists, link spec to it
gh issue comment {ISSUE_NUMBER} --body "Specification created: .ian/spec_{FEATURE}_{DATE}.md"
```

## Workflow Integration

### Before Implementation
```bash
# 1. User assigns task
User: "Add order idempotency to prevent duplicate orders"

# 2. Create spec first
/spec

# 3. Answer interactive prompts
Problem: Users accidentally submit same order twice
Minimal Solution: Check idempotency key before order submission
Scope: Only POST /api/orders/submit, not other endpoints
Success: Same idempotency key twice = one order created
Edge cases: Expired keys, missing keys, concurrent requests

# 4. Spec generated in .ian/spec_order_idempotency_20251029.md

# 5. Review with user
"Spec created. Review .ian/spec_order_idempotency_20251029.md"

# 6. Get approval
User: "Looks good, proceed"

# 7. Mark spec as Approved
# Update status in spec file: Status: Approved

# 8. NOW implementation can begin (Gate 1 passed)
```

### During Implementation
- Refer to spec for requirements
- Update spec if requirements change (document why)
- Check off items in "Implementation Tracking" section

### After Implementation
- Verify all success criteria met
- Mark spec as Complete
- Link to final PR/commit

## Quality Gates Integration

**Gate 1: Spec Approved**
- Spec file exists in `.ian/`
- All required sections completed
- Status: Approved
- User sign-off obtained

**Without spec approval, cannot proceed to Gate 2 (Tests First)**

## Benefits

1. **Prevents wrong solutions** - Clarify requirements before coding
2. **Reduces overengineering** - Explicit scope boundaries
3. **Measurable completion** - Clear success criteria
4. **Better estimates** - Understand scope before starting
5. **Documentation artifact** - Permanent record of requirements
6. **Easier code review** - Reviewer can compare to spec

## Anti-Patterns to Avoid

❌ **Writing spec after implementation** - Defeats the purpose
❌ **Vague requirements** - "Make it better" isn't specific
❌ **No scope boundaries** - Everything becomes in-scope
❌ **No success criteria** - Can't tell when done
❌ **Skipping spec for "simple" changes** - Simple changes become complex

## Example: Complete Spec

See `.ian/examples/spec_example_order_idempotency.md` for a fully worked example.

## Integration with Other Skills

- **Before /spec**: None - this is always first
- **After /spec**: `/test` (write tests based on spec), then implementation
- **Review**: `/validator` can verify implementation matches spec

## Tips

- **Be specific**: "Prevent duplicate orders" > "Improve order system"
- **Be minimal**: Start with simplest solution, add complexity only if needed
- **Be explicit**: State what you're NOT building
- **Be measurable**: "No duplicates" > "Better reliability"
- **Involve user**: Review spec before implementation starts

## When Spec Changes

If requirements change during implementation:
1. Update spec with changes
2. Document why change was needed
3. Re-review with user if scope increased
4. Update success criteria if needed
5. Note in spec: "Modified {DATE}: {REASON}"

## Storage & Organization

All specs in `.ian/`:
```
.ian/spec_order_idempotency_20251029.md
.ian/spec_websocket_reconnect_20251030.md
.ian/spec_trailing_brackets_20251031.md
```

Link to issues/PRs for traceability.

## Success Metrics

**Before /spec**:
- 40% of implementations don't match user needs
- 30% of "complete" features missing edge cases
- Rework rate: 40%

**After /spec**:
- 95% of implementations match user needs
- 5% of "complete" features missing edge cases
- Rework rate: 10%
