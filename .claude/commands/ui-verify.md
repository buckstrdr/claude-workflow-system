---
name: ui-verify
description: Enforce Playwright UI testing standards at 1920x1080 resolution with mandatory interaction testing and artifact management
---

Invoke the playwright-ui-testing skill when testing UI changes, modifying frontend components, or committing style changes.

This skill enforces:
- Mandatory Playwright MCP testing (manual browser testing NOT acceptable)
- 1920x1080 resolution requirement per CLAUDE.md
- 7-step workflow (Start Frontend → Navigate → Resize → Screenshot → Interact → Verify → Save)
- Interaction testing (screenshots alone are never sufficient)
- Artifact management in .ian/ directory
- No pressure accommodation (standards don't change for deadlines/exhaustion)
- Pre-commit hook compliance (.claude/hooks/enforce-playwright-ui-tests.sh)

Use this when:
- Modifying React components in topstepx_frontend/src/components/
- Changing CSS or SCSS files
- About to commit UI changes
- Asked to "test the UI" or "verify visual changes"
- Developer mentions UI testing at wrong resolution

```
Skill("playwright-ui-testing")
```
