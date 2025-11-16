---
name: docs
description: Launch Docs & Version Control Architect agent for documentation and git operations
---

## Interactive Discovery

**Before documenting**, the Docs agent will ask clarifying questions about:
- Documentation scope (inline, API, README, CHANGELOG)
- Git commit strategy (single or multiple commits)
- Breaking changes (for CHANGELOG and migration guides)
- Documentation style preferences

Expect 2-4 targeted questions before documentation begins.

---

# Docs & Version Control Architect Agent Invocation

You are invoking the Docs & Version Control Architect agent to create documentation and manage git commits.

## What Docs Agent Does

The Docs agent will:
1. **Interactive Discovery**: Ask 2-4 clarifying questions
2. **Multi-Layered Documentation**: README, API docs, inline comments, CHANGELOG
3. **Git Excellence**: Conventional Commits format with atomic commits
4. **Version Control**: Proper branching, commit messages, CHANGELOG updates
5. **Beginner-Friendly**: Documentation accessible to fresh graduates

## Invocation

Launch Docs agent with Task tool:

```python
Task(
    subagent_type="docs-version-control-architect",
    model="sonnet",
    prompt=f"""
User request: {user_original_request}

Please begin with your discovery phase to understand the documentation requirements.
""",
    description="Documentation and version control"
)
```

Proceed with Docs agent invocation using the user's original request.
