# 🎭 Role Documentation Index

Complete documentation for all 12 Claude Code instance roles in the multi-instance workflow system.

---

## 📚 All Role Documentation

### Management & Oversight (2 roles)

1. **[Orchestrator](ORCHESTRATOR_ROLE.md)** - Master coordinator and decision authority
   - Task assignment and coordination
   - Quality gate management (5-stage progression)
   - Write lock management
   - Conflict resolution and dispute mediation
   - Emergency bypass authorization

2. **[Librarian](LIBRARIAN_ROLE.md)** - Independent oversight and veto authority
   - Orchestrator co-signature (critical decisions)
   - System freeze/veto capability
   - Documentation review
   - Tool/skill selection consultation

---

### Planning & Architecture (5 roles)

3. **[Planner-A](PLANNER_ROLE.md)** - Lead Planner (feature specifications)
4. **[Planner-B](PLANNER_ROLE.md)** - Senior Planner (peer review)
   - Feature specification creation
   - Task breakdown and estimation
   - Peer review protocol
   - Escalation to Architecture Council

5. **[Architect-A](ARCHITECT_ROLE.md)** - Senior Architect (Architecture Council)
6. **[Architect-B](ARCHITECT_ROLE.md)** - Senior Architect (Architecture Council)
7. **[Architect-C](ARCHITECT_ROLE.md)** - Senior Architect (Architecture Council)
   - Architectural decision making (3-member voting)
   - Planner specification review
   - Dev escalation resolution
   - Technical feasibility assessment

---

### Implementation (4 roles)

8. **[Dev-A](DEVELOPER_ROLE.md)** - TDD Developer
9. **[Dev-B](DEVELOPER_ROLE.md)** - TDD Developer (peer review)
   - Test-Driven Development (RED-GREEN-REFACTOR)
   - Peer review protocol (4-eyes principle)
   - Code implementation
   - Threshold-based review (>50 LOC, >3 files, high-risk)

10. **[QA-A](QA_ROLE.md)** - Quality Assurance Engineer
11. **[QA-B](QA_ROLE.md)** - Quality Assurance Engineer (peer review)
    - Test strategy design
    - Coverage verification (80% min, 90% critical paths)
    - Quality gate 4 verification
    - Peer review of test plans

---

### Documentation (1 role)

12. **[Docs](DOCS_ROLE.md)** - Documentation specialist
    - Feature documentation creation
    - Dual review process (Librarian + Dev/QA)
    - Living documentation maintenance
    - Architecture Decision Records (ADRs)

---

## 🎯 Quick Reference

### By Authority Level

| Level | Roles |
|-------|-------|
| **Highest** | Orchestrator (with Librarian co-sign) |
| **Veto** | Librarian (can freeze system) |
| **Voting** | Architecture Council (3 Architects) |
| **Peer Review** | Planners (2), Devs (2), QA (2) |
| **Specialist** | Docs (1) |

### By Review Requirements

| Review Type | Roles |
|-------------|-------|
| **Co-Signature** | Orchestrator + Librarian (critical decisions) |
| **Peer Review** | Planner-A ↔ Planner-B, Dev-A ↔ Dev-B, QA-A ↔ QA-B |
| **Council Vote** | Architect-A + Architect-B + Architect-C (majority rule) |
| **Dual Review** | Docs (Librarian + Dev/QA) |

### By Escalation Path

| Issue Type | Escalates To |
|------------|--------------|
| **Simple technical** | Orchestrator |
| **Architectural** | Architecture Council |
| **Critical path** | User (via Orchestrator) |
| **Standards dispute** | Orchestrator |
| **Planner disagreement** | Architecture Council |
| **System violations** | Librarian → User |

---

## 📊 Instance Distribution

```
Total Instances: 12

Management:
├── Orchestrator (1)
└── Librarian (1)

Planning & Architecture:
├── Planners (2)
└── Architects (3)

Implementation:
├── Developers (2)
└── QA Engineers (2)

Documentation:
└── Docs (1)
```

---

## 🔄 Workflow Summary

### Feature Lifecycle

```
User → Orchestrator: Feature request
Orchestrator → Planner-A: Create specification
Planner-A ↔ Planner-B: Peer review spec
Orchestrator → Architect: Technical feasibility
Orchestrator → Dev-A: Implement (TDD)
Dev-A: RED (tests first)
Dev-A: GREEN (implementation)
Dev-A ↔ Dev-B: Peer review (if >50 LOC)
Orchestrator → QA-A: Quality verification
QA-A ↔ QA-B: Peer review test strategy
Orchestrator → Docs: Create documentation
Docs → Librarian + Dev: Dual review
Orchestrator → User: Feature complete
```

### Quality Gates (5-Stage)

1. **RED** - Tests written, failing
2. **GREEN** - Implementation passes tests
3. **PEER** - 4-eyes peer review (if threshold met)
4. **QA** - Quality assurance verification
5. **DEPLOY** - Production deployment approval

---

## 🛠️ Common MCP Tool Usage by Role

| Role | Primary Tools |
|------|---------------|
| **Orchestrator** | Git MCP, Filesystem MCP, Serena, Terminal MCP |
| **Librarian** | Git MCP, Filesystem MCP, Serena, Terminal MCP, Context7 |
| **Planners** | Serena, Context7, Git MCP, Filesystem MCP |
| **Architects** | Filesystem MCP, Git MCP, Context7, Terminal MCP, Serena |
| **Developers** | Git MCP, Terminal MCP, Filesystem MCP, Context7, Serena |
| **QA** | Terminal MCP, Git MCP, Filesystem MCP, Context7, Serena |
| **Docs** | Filesystem MCP, Git MCP, Context7, Terminal MCP, Serena |

---

## 📖 Documentation Conventions

Each role document follows this structure:
1. **Core Identity** - Why this role exists, instance count
2. **Core Responsibilities** - Primary duties with workflows
3. **Interactions** - How role interacts with other instances
4. **MCP Tool Usage** - Tools and commands used
5. **Summary Table** - Quick reference

---

## 🎓 Reading Guide

### For New Team Members
1. Start with **Orchestrator** (central coordinator)
2. Read **Librarian** (oversight and veto)
3. Review your assigned role(s)

### For Implementers
1. Read **your role** documentation thoroughly
2. Understand **peer review** requirements
3. Review **escalation paths** for your role

### For System Designers
1. Read **all roles** to understand system
2. Focus on **interaction patterns**
3. Review **escalation and voting mechanisms**

---

## ✅ Key Takeaways

1. **No Single Point of Failure**
   - Peer review for Planners, Devs, QA
   - Architecture Council voting (3 members)
   - Librarian oversight of Orchestrator

2. **Clear Authority Levels**
   - Orchestrator coordinates but requires co-signatures
   - Librarian can veto/freeze system
   - Architecture Council decides architectural disputes
   - User decides critical path

3. **Comprehensive Checks**
   - 4-eyes principle (>50 LOC, >3 files, high-risk)
   - Peer-first review protocol
   - Dual review for documentation
   - Quality gates enforce progression

4. **Escalation Clarity**
   - Simple → Orchestrator
   - Architectural → Architecture Council
   - Critical path → User
   - Violations → Librarian → User

---

**All roles work together to ensure high-quality, well-tested, thoroughly documented features with no single point of failure.**
