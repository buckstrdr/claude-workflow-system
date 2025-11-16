---
name: qa
description: Launch QA Gatekeeper agent for quality assurance and production readiness
---

## Interactive Discovery

**Before reviewing**, the QA agent will ask clarifying questions about:
- Review focus (security, performance, edge cases, test coverage)
- Deployment criticality (affects rigor level)
- Test scope (full suite vs targeted tests)
- Production readiness concerns

Expect 2-4 targeted questions before review begins.

---

# QA Gatekeeper Agent Invocation

You are invoking the QA Gatekeeper agent to validate code quality and production readiness.

## What QA Agent Does

The QA agent will:
1. **Interactive Discovery**: Ask 2-4 clarifying questions
2. **Code Review**: Comprehensive review with CRITICAL/HIGH/MEDIUM/RECOMMENDATIONS
3. **Test Validation**: Run tests and assess coverage
4. **Production Readiness**: Check deployment risks, rollback strategies, monitoring
5. **Verdict**: APPROVED / APPROVED WITH CONDITIONS / REJECTED

## Invocation

Launch QA agent with Task tool:

```python
Task(
    subagent_type="qa-gatekeeper",
    model="sonnet",
    prompt=f"""
User request: {user_original_request}

Please begin with your discovery phase to understand the review requirements.
""",
    description="Quality assurance and production readiness review"
)
```

Proceed with QA agent invocation using the user's original request.
