---
name: pm
description: Launch Project Manager agent for full project orchestration with discovery, planning, and agent coordination
---

# Project Manager Agent Invocation

You are invoking the Project Manager (PM) agent to orchestrate a complete development workflow.

## What PM Agent Does

The PM agent will:
1. **Discovery**: Ask 3-5 clarifying questions to understand your project needs
2. **Planning**: Create sprint breakdown with TodoWrite tasks
3. **Orchestration**: Launch specialized agents (architect, engineer, QA, docs) automatically
4. **Approval Gates**: Request approval at sprint boundaries
5. **Memory**: Save session context to `.serena/memories/pm-context-topstepx.md` for continuity

## PM Agent Workflow

```
Discovery (questions) → Planning (sprints) → [Approval] → Dispatch (agents) → Review → [Approval] → Next Sprint
```

## When to Use PM Agent

**Use PM agent when:**
- Starting a new feature that needs architecture and implementation
- You want guided workflow with approval checkpoints
- You need session context maintained across conversations
- You're unsure which agents to invoke (PM decides for you)

**Skip PM agent when:**
- You know exactly which agent you need (`/architect`, `/engineer`, `/qa`, `/docs`)
- Quick fix that doesn't need planning overhead
- You want direct control without orchestration layer

## Invocation

Launch PM agent with Task tool:

```python
Task(
    subagent_type="project-manager",
    model="opus",
    prompt=f"""
User request: {user_original_request}

Please begin with your discovery phase to understand the project needs.
""",
    description="PM orchestration for full development workflow"
)
```

Proceed with PM agent invocation using the user's original request.
