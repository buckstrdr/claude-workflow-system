---
name: Code improvement
about: Track technical debt, refactoring, and code quality issues
title: "[improve] <concise subject>"
labels: [improvement]
assignees: []
---

## Summary

Describe the code quality issue or improvement opportunity in 1–2 sentences.

## Issue Type

- [ ] Technical debt
- [ ] Duplicate code
- [ ] Unused code
- [ ] Performance optimization
- [ ] Code clarity/readability
- [ ] Architecture refactoring

## Current State

Describe what exists now and why it needs improvement.

## Proposed Improvement

Describe the minimal viable refactoring or cleanup.

## Impact / Benefits

- Maintainability:
- Performance:
- Developer experience:

## Affected Areas

- [ ] Backend (routes/services)
- [ ] Frontend (components/stores)
- [ ] Database/migrations
- [ ] Tests
- [ ] Documentation

## Risks & Considerations

- [ ] Backward compatible
- [ ] Requires coordinated deployment
- [ ] Testing strategy defined

## Priority

- [ ] High - Blocking other work or critical path
- [ ] Medium - Should address soon
- [ ] Low - Nice to have

## Serena Context

- Suggested session note: `make session-note m="Refactor: <one-liner> (scope: files/modules)" src=codex`
- Run `make graphs-fast` to keep backend graph fresh during refactor cycles.
