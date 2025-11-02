---
name: Bug report
about: Report a problem to fix
title: "[bug] <concise subject>"
labels: [bug]
assignees: []
---

## Summary

Describe the bug and impact in 1–2 sentences.

## Steps To Reproduce

1. 
2. 
3. 

## Expected vs Actual

- Expected:
- Actual:

## Logs / Screenshots

Paste relevant logs (backend/FE console) or screenshots.

## Environment

- App version/branch:
- Backend DB (Timescale) present?:
- Live mode or sim:

## Scope

- [ ] Backend
- [ ] Frontend
- [ ] Docs/Dev tooling

## Safeguards

- [ ] Reproducible locally
- [ ] Minimal change surface identified

## Serena Context

- Suggested session note: `make session-note m="Bug: <one-liner> (area: backend/frontend)" src=codex`
- Relevant graphs to consult: `.serena/graphs/graph_backend.json`, `graph_frontend.json`, `api_map.json`
- Routes/Files suspected:
