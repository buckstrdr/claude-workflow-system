# Write Coordination Protocol

All file and git operations must coordinate through the Orchestrator to prevent conflicts.

## Write Lock System

**Write lock state:** `messages/write-lock.json`

**Before ANY write operation:**
1. Check if write lock is available
2. Send WriteRequest to Orchestrator
3. Wait for WriteLockGrant
4. Perform operation
5. Send WriteComplete to Orchestrator

## Operations Requiring Write Lock

✅ **MUST request lock:**
- Git commit
- Git push
- Writing to shared documentation files
- Writing to message board

❌ **NO lock needed:**
- Reading any files
- Creating new files in your assigned directory
- Running tests
- Using MCP tools for reads

## WriteRequest Message Format

```markdown
## WriteRequest

**From:** <your_role>
**To:** Orchestrator
**Operation:** <brief description>
**Estimated Duration:** <seconds>
**Files:** <list of files to modify>
```

## Handling WriteLockGrant

When you receive WriteLockGrant:
1. Proceed with your operation immediately
2. Complete within the timeout (default: 5 minutes)
3. Send WriteComplete when done
4. If operation fails, still send WriteComplete with error details

## Handling Lock Unavailable

If Orchestrator responds that lock is held by another role:
1. You will be queued
2. Wait for WriteLockGrant message
3. Do NOT retry or attempt to bypass
4. Use waiting time for other tasks (reading, analysis, planning)

## Lock Timeout

If you hold the lock for >5 minutes:
- Lock auto-releases
- Warning logged
- Orchestrator may assign your task to another role

**Critical:** Always complete operations quickly to avoid blocking other roles.
