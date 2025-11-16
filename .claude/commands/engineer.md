---
name: engineer
description: Launch Senior Full-Stack Engineer agent for TDD-based implementation
---

## Interactive Discovery

**Before implementing**, the Engineer agent will ask clarifying questions about:
- Testing approach (TDD required for PM workflow)
- Implementation scope (backend, frontend, or both)
- Schema updates needed (OpenAPI/types regeneration)
- File locations and integration points

Expect 2-4 targeted questions before implementation begins.

---

# Senior Full-Stack Engineer Agent Invocation

You are invoking the Senior Full-Stack Engineer agent to implement features using TDD.

## What Engineer Agent Does

The Engineer agent will:
1. **Interactive Discovery**: Ask 2-4 clarifying questions
2. **TDD Implementation**: Use RED-GREEN-REFACTOR cycle (test-first)
3. **Full-Stack Development**: Backend (FastAPI) and/or Frontend (React)
4. **Schema Management**: Regenerate OpenAPI and types if needed
5. **Quality Assurance**: Ensure 80%+ test coverage for critical paths

## Invocation

Launch Engineer agent with Task tool:

```python
Task(
    subagent_type="senior-fullstack-engineer",
    model="sonnet",
    prompt=f"""
User request: {user_original_request}

Please begin with your discovery phase to understand the implementation requirements.
""",
    description="Feature implementation with TDD"
)
```

Proceed with Engineer agent invocation using the user's original request.
