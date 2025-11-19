---
name: brainstorming
description: Autonomous brainstorming for multi-instance workflow - explores alternatives and sends clarifying questions to orchestrator instead of user
---

# Autonomous Brainstorming Skill

This is a LOCAL override of the superpowers brainstorming skill, adapted for autonomous multi-instance workflow.

## Key Differences from Standard Brainstorming

- **NEVER ask the user directly** - You're in an autonomous workflow
- **Send questions to orchestrator** - Use send_message MCP tool with Question intent
- **Make reasonable assumptions** - Prefer proceeding with documented assumptions over blocking
- **Use structured analysis** - Explore alternatives, evaluate trade-offs, make recommendations

## When to Use This Skill

Use this skill when you need to:
- Explore multiple technical approaches before choosing one
- Evaluate trade-offs between different solutions
- Refine vague requirements into concrete specifications
- Document assumptions and reasoning for technical decisions

## Workflow

### 1. Analyze the Problem Space

Break down the request into:
- **Core Requirements** - What must be delivered
- **Constraints** - Technical, performance, compatibility limits
- **Unknowns** - What information is missing or unclear

### 2. Explore Alternatives (Minimum 2-3 approaches)

For each viable approach, document:
- **Architecture** - How it would be structured
- **Trade-offs** - Pros and cons (performance, complexity, maintainability)
- **Complexity** - Implementation difficulty (Low/Medium/High)
- **Fit** - How well it meets the requirements

### 3. Decision Making

**Option A: Requirements are clear enough**
- Make a recommendation based on trade-off analysis
- Document your assumptions
- Proceed with the recommendation

**Option B: Critical information is missing**
- Formulate specific questions (not open-ended)
- Send Question message to orchestrator via send_message
- Wait for response, then proceed

### 4. Only Ask Orchestrator If Truly Blocked

**DO ask orchestrator when:**
- Fundamental requirement is ambiguous or contradictory
- Choice between approaches has significant project-wide impact
- Technical constraint makes all obvious approaches infeasible

**DON'T ask orchestrator when:**
- You can make a reasonable default (document it instead)
- Industry best practices clearly favor one approach
- The choice is reversible or low-impact

## Example: Choosing Technical Approach

```markdown
# Technical Approach Analysis

## Explored Alternatives

### Approach 1: Canvas + requestAnimationFrame
**Architecture:** HTML5 Canvas for rendering, game loop via requestAnimationFrame
**Trade-offs:**
  ✅ Standard for browser games, 60fps guaranteed, simple collision detection
  ❌ More code than DOM manipulation (~300 LOC vs ~200 LOC)
**Complexity:** Medium
**Fit:** Excellent - meets all requirements

### Approach 2: DOM Manipulation
**Architecture:** Absolutely positioned divs, CSS transitions for movement
**Trade-offs:**
  ✅ Simpler code, easier debugging
  ❌ Performance degrades with >10 objects, reflow issues
**Complexity:** Low
**Fit:** Poor - won't scale to required difficulty levels

## Recommendation

**Going with Approach 1: Canvas + requestAnimationFrame**

**Rationale:**
1. Performance scales to high difficulty (20+ asteroids)
2. Standard practice for browser games
3. Better collision detection precision
4. Complexity increase is justified by scalability

**Assumptions Documented:**
- Target: 60 FPS on modern browsers (Chrome, Firefox, Safari)
- Max concurrent asteroids: 20
- Visual style: Vector graphics drawn on canvas (no image assets)

*Proceeding with Canvas-based specification.*
```

## Example: When to Ask Orchestrator

**WRONG - Asking about obvious defaults:**
```
Question to orchestrator: "What frame rate should we target for the game?"
```
**Right:** Assume 60 FPS (industry standard), document it

**WRONG - Open-ended exploration:**
```
Question to orchestrator: "Should we use any particular design patterns?"
```
**Right:** Choose appropriate patterns (MVC, ECS, etc.), document reasoning

**RIGHT - Fundamental ambiguity:**
```
If orchestrator said "make it multiplayer" but also "single HTML file":
→ Send Question to orchestrator: "Multiplayer requires server. Should I spec
   local multiplayer (same screen) or change to multi-file with WebSocket server?"
```

## Integration with Multi-Instance Workflow

When you need to ask orchestrator:

```javascript
// Use send_message MCP tool
from_role: planner-a  // or your role
to_role: orchestrator
subject: Question: [Specific topic]
content: |
  # Question: [Concise question]

  **Context:** [Why you're asking]

  **Options Evaluated:**
  1. Option A: [Description] - [Trade-offs]
  2. Option B: [Description] - [Trade-offs]

  **My Recommendation:** [Your analysis]

  **Blocked On:** [Why you need clarification to proceed]

  Please advise which direction to take, or I'll proceed with my recommendation
  if no response within reasonable timeframe.
```

## Remember

- **Structured exploration > user questions** - Do the analysis, make the call
- **Document assumptions** - Make them visible in your deliverable
- **Prefer autonomy** - Only escalate true blockers
- **Quality over speed** - But don't let perfect be enemy of good

This skill helps you think deeply about technical decisions while maintaining autonomous operation in the multi-instance workflow.
