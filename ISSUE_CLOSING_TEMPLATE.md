# GitHub Issue Closing Template

## Standard Format for Closing Issues

When closing any GitHub issue, use this standardized format to ensure consistency across all Claude Code instances and team members.

---

## Template Structure

```markdown
# Issue #{NUMBER} Resolution - {BRIEF_TITLE}

## ✅ Issue Resolved

{ONE_LINE_SUMMARY_OF_WHAT_WAS_FIXED}

## 🔗 Files Modified

1. **Created**: `path/to/new/file.py` ({LINE_COUNT} lines)
2. **Modified**: `path/to/existing/file.py` (lines {START}-{END})
3. **Modified**: `path/to/another/file.py` (lines {START}-{END})

## 🔧 Changes Made

### {Section Title 1}

**File**: `path/to/file.py`

{Description of changes made}

**Before** ({LINE_COUNT} lines):
```{language}
{old code snippet}
```

**After** ({LINE_COUNT} lines):
```{language}
{new code snippet}
```

### {Section Title 2}

{Repeat for each major change}

## ✅ Verification Results

**Static Code Verification** (`tests/verify_issue_{NUMBER}_fix.py`):
```
✅ Check 1: {Description}
✅ Check 2: {Description}
✅ Check 3: {Description}
{...more checks...}

Issue #{NUMBER} is RESOLVED ✅
```

### Code Metrics:
- **Original**: {NUMBER} lines ({breakdown})
- **After refactoring**:
  - {Component 1}: {NUMBER} lines
  - {Component 2}: {NUMBER} lines
  - Total: {NUMBER} lines
- **Duplicate code eliminated**: {NUMBER} lines
- **{Key metric}**: {Description}

## 🎯 Impact

This {fix/refactoring/feature} provides:

### Immediate Benefits:
- **{Benefit 1}** - {Description}
- **{Benefit 2}** - {Description}
- **{Benefit 3}** - {Description}

### Future Benefits:
- **{Benefit 1}** - {Description}
- **{Benefit 2}** - {Description}
- **{Benefit 3}** - {Description}

### Code Quality:
- {Improvement 1}
- {Improvement 2}
- {Improvement 3}

## 📊 Related Issues

- Fixes #{NUMBER}: {Issue title}
- Part of #{NUMBER}: {Parent issue title}
- Related to #{NUMBER}: {Related issue title}

---

**Issue #{NUMBER} is RESOLVED and ready to close** ✅
```

---

## Required Sections

### 1. Title (Required)
Format: `# Issue #{NUMBER} Resolution - {BRIEF_TITLE}`

Example: `# Issue #26 Resolution - Contract Utility Methods Duplication`

### 2. Issue Resolved (Required)
One-line summary of what was accomplished.

Example: `Eliminated 33 lines of duplicate code by extracting contract utility methods to shared helper module.`

### 3. Files Modified (Required)
List ALL files changed with:
- Operation type: **Created**, **Modified**, **Deleted**
- Full path to file
- Line count for new files OR line range for modifications

Example:
```markdown
1. **Created**: `topstepx_backend/services/contract_helpers.py` (57 lines)
2. **Modified**: `topstepx_backend/services/bracket_editor.py` (lines 37, 558-560)
```

### 4. Changes Made (Required)
Detailed explanation of each change with before/after code snippets.

**Guidelines:**
- Show actual code, not pseudo-code
- Include line counts
- Use proper syntax highlighting
- Show context around changes

### 5. Verification Results (Required)
Output from verification script showing all checks passed.

**Must include:**
- Path to verification script
- List of all checks performed
- Status of each check (✅ or ❌)
- Final verdict

### 6. Code Metrics (Required for code changes)
Quantifiable measurements of the change impact.

**Common metrics:**
- Lines added/removed/changed
- Duplicate code eliminated
- Test coverage increase
- Performance improvements
- Memory savings

### 7. Impact (Required)
Explain the significance of the changes.

**Three categories:**
1. **Immediate Benefits** - What's better right now
2. **Future Benefits** - What this enables later
3. **Code Quality** - How code improved

### 8. Related Issues (Required)
Link to all related issues.

**Must include:**
- `Fixes #` - Issues this closes
- `Part of #` - Parent tracking issues
- `Related to #` - Connected issues

---

## Optional Sections

### Testing (Optional but Recommended)
If tests were created, include:
```markdown
## 🧪 Testing

Created test suite with {NUMBER} test cases:

**File**: `tests/test_{feature}.py` ({LINE_COUNT} lines)

### Test Coverage:
1. ✅ `test_case_1_description`
2. ✅ `test_case_2_description`
3. ❌ `test_case_3_description` (reason)

**Test Results**: {PASSED}/{TOTAL} tests passing
```

### Security Considerations (Optional)
For security-related changes:
```markdown
## 🔒 Security Considerations

- {Security improvement 1}
- {Security improvement 2}
- {Potential risks and mitigations}
```

### Breaking Changes (Required if applicable)
```markdown
## ⚠️ Breaking Changes

**BREAKING**: {Description of breaking change}

**Migration Path**:
1. {Step 1}
2. {Step 2}
3. {Step 3}
```

### Performance Impact (Optional)
```markdown
## ⚡ Performance Impact

**Before**:
- {Metric 1}: {Value}
- {Metric 2}: {Value}

**After**:
- {Metric 1}: {Value} ({+/-}% change)
- {Metric 2}: {Value} ({+/-}% change)
```

---

## Workflow for Closing Issues

### Step 1: Create Resolution Document
```bash
# Create resolution file in ian/ directory
touch ian/issue_{NUMBER}_resolution.md
```

### Step 2: Write Resolution Using Template
Follow the template structure above, filling in all required sections.

### Step 3: Create Verification Script (if applicable)
```bash
# Create verification script in tests/ directory
touch tests/verify_issue_{NUMBER}_fix.py
chmod +x tests/verify_issue_{NUMBER}_fix.py
```

### Step 4: Run Verification
```bash
python3 tests/verify_issue_{NUMBER}_fix.py
```

### Step 5: Close Issue with Resolution
```bash
gh issue close {NUMBER} --comment "$(cat ian/issue_{NUMBER}_resolution.md)"
```

### Step 6: Verify Closure
```bash
gh issue view {NUMBER} --web
```

---

## Examples

See these resolved issues for reference:
- Issue #21: `ian/issue_21_resolution.md` - Quote subscriptions leak fix
- Issue #23: `ian/issue_23_resolution.md` - Position polling duplication
- Issue #26: `ian/issue_26_resolution.md` - Contract utility methods

---

## Quality Checklist

Before closing an issue, verify:

- [ ] All required sections present
- [ ] Code metrics included with actual numbers
- [ ] Before/after code snippets included
- [ ] Verification script created and passing
- [ ] Related issues linked
- [ ] Impact clearly explained
- [ ] No TODOs or placeholders in resolution
- [ ] File paths are accurate
- [ ] Line numbers are correct
- [ ] Resolution saved to `ian/issue_{NUMBER}_resolution.md`

---

## Common Patterns

### Pattern 1: Code Duplication Elimination
Focus on:
- How many lines eliminated
- Where duplicate code existed
- What shared module was created
- How original code was refactored

### Pattern 2: Bug Fix
Focus on:
- Root cause of bug
- How bug was fixed
- Tests added to prevent regression
- Verification of fix

### Pattern 3: Feature Addition
Focus on:
- What feature was added
- How it integrates with existing code
- Tests covering new functionality
- Documentation updates

### Pattern 4: Refactoring
Focus on:
- Why refactoring was needed
- What improved (readability, performance, maintainability)
- Tests confirming behavior unchanged
- Migration guide if breaking changes

---

## Anti-Patterns to Avoid

❌ **Don't:**
- Close issues without resolution document
- Use vague descriptions ("fixed the bug")
- Skip verification steps
- Omit code metrics
- Forget to link related issues
- Leave TODOs in resolution
- Include incomplete code snippets
- Skip impact analysis

✅ **Do:**
- Follow template structure exactly
- Provide specific, measurable results
- Include all verification output
- Show before/after comparisons
- Link all related issues
- Complete all sections
- Use real code from actual files
- Explain significance of changes

---

**Template Version**: 1.0
**Last Updated**: 2025-10-17
**Maintained By**: Claude Code Team
