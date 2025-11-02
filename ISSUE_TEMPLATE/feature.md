---
name: Feature request
about: Propose a new capability or improvement
title: "[feat] <concise subject>"
labels: [enhancement]
assignees: []
---

## Problem / Opportunity

What outcome do we want? Who benefits?

## Proposed Solution

Describe the minimal viable change. Include API/route shapes if relevant.

## Acceptance Criteria

- [ ] 
- [ ] 

## Impacted Areas

- [ ] Backend (routes/services)
- [ ] Frontend (components/stores)
- [ ] OpenAPI/types regeneration needed

## Risks & Rollout

- [ ] Backward compatible
- [ ] Feature-flagged or guarded by config

## Serena Context

- Suggested session note: `make session-note m="Feature: <one-liner> (area: backend/frontend)" src=claude`
- Update graphs? Consider `make graphs` if architecture changes are expected.
- If backend routes change, FE types will auto-sync post-commit.
