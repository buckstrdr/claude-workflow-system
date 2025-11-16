---
name: architect
description: Launch Senior Architect Planner agent for technical architecture and PRD creation
---

## Interactive Discovery

**Before creating architecture**, the Architect agent will ask clarifying questions about:
- Database choice and deployment environment
- Performance requirements and user scale
- Integration points and security needs
- Technical constraints and dependencies

Expect 2-4 targeted questions before the agent creates your PRD.

---

# Senior Architect Planner Agent Invocation

You are invoking the Senior Architect Planner agent to create technical architecture and PRD.

## What Architect Agent Does

The Architect agent will:
1. **Interactive Discovery**: Ask 2-4 clarifying questions
2. **Architecture Design**: Create system design with data models and API contracts
3. **PRD Creation**: Write comprehensive Product Requirements Document
4. **Sprint Planning**: Break down features into testable sprints
5. **Confirmation**: Get approval before proceeding

## Invocation

Launch Architect agent with Task tool:

```python
Task(
    subagent_type="senior-architect-planner",
    model="opus",
    prompt=f"""
User request: {user_original_request}

Please begin with your discovery phase to understand the technical requirements.
""",
    description="Architecture and PRD creation"
)
```

Proceed with Architect agent invocation using the user's original request.
