---
name: sp-wait-condition
description: Replace arbitrary timeouts with condition polling for reliable tests
---

Invoke the superpowers:condition-based-waiting skill when tests have race conditions, timing dependencies, or inconsistent pass/fail behavior.

Use this to replace arbitrary timeouts with condition polling that waits for actual state changes.

```
Skill("superpowers:condition-based-waiting")
```
