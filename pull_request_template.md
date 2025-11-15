Title: <type(scope): summary>

Summary
- What changed and why, in 2–4 lines.

Linked Issues
- Fixes #<issue-number>
- Related: #<issue-number>

Changes
- Backend:
  - [ ] Routes
  - [ ] Services
  - [ ] Persistence/DB
- Frontend:
  - [ ] Components
  - [ ] Stores
  - [ ] Types
- Docs/Dev tooling:
  - [ ] Makefile
  - [ ] CI/Actions

Verification
- [ ] Backend starts: `python -m your_backend`
- [ ] Status/health endpoints OK
- [ ] Critical flows smoke-tested
- [ ] Frontend builds (`npm run build`) and key UI paths work

Serena / Contracts & Types
- [ ] `.serena/knowledge/openapi.json` updated if backend routes changed (`make openapi`)
- [ ] FE API types regenerated (auto post-commit) — or run `make types`
- [ ] Optional: `make session-note m="PR: <summary>" src=codex`

Notes
- Backward compatibility, rollout plan, or migration notes if any.
