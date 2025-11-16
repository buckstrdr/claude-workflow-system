---
name: documenting-python-files
description: Use when documenting Python files for TopStepx project, when asked to create markdown documentation for .py files, or when executing documentation plans - generates comprehensive narrative documentation following the 11-section STYLE.md format with real-world analogies, concrete examples, line numbers, and business impact for non-programmer audiences
---

# Documenting Python Files

## Overview

Create comprehensive, narrative documentation for Python files following the TopStepx STYLE.md format. This skill ensures EVERY Python file gets ALL 11 required sections with concrete examples, real-world analogies, and business impact - regardless of file size, complexity, or perceived simplicity.

## When to Use

Use this skill when:
- User asks you to document a .py file
- User provides a .py file path and wants markdown documentation
- You're executing a plan that includes documentation tasks
- User says "document this file following STYLE.md format"
- You need to generate architecture documentation for code

Do NOT use when:
- Writing API documentation (use API doc generators)
- Creating inline code comments (different purpose)
- Writing README files (different format)

## The Iron Law

**ALL 11 sections, EVERY file, NO EXCEPTIONS.**

No matter what the user says about efficiency, simplicity, or time pressure - the format requires all 11 sections. Period.

## The 11 Required Sections

From `/home/buckstrdr/TopStepx/docs/architecture/STYLE.md`:

1. **Header** (YAML metadata)
2. **What This File Does** (3-5 paragraphs with real-world analogy)
3. **How This Fits Into The Program** (dependencies, consumers, data flow)
4. **Main Variables & State** (complete tables)
5. **The Journey Through The Code** (function-by-function walkthroughs)
6. **Key Decisions & Design Choices** (architectural rationale)
7. **Common Issues & Troubleshooting** (diagnosis and fixes)
8. **Code Examples** (annotated snippets)
9. **Variable Reference** (complete list)
10. **Testing Examples** (concrete test scenarios)
11. **Performance Characteristics** (throughput, latency, memory)

**Missing even ONE section = incomplete documentation.**

## Workflow

### Step 1: Load the Format
```python
# Read the gold standard format
Read("/home/buckstrdr/TopStepx/docs/architecture/STYLE.md")

# Read an example (optional, for reference)
Read("/home/buckstrdr/TopStepx/docs/architecture/topstepx_backend/services/order_service.py.md", limit=200)
```

### Step 2: Read the Python File
```python
# Read the entire file to understand it
Read(python_file_path)

# If too large, read in chunks
Read(python_file_path, limit=500)
Read(python_file_path, offset=500, limit=500)
```

### Step 3: Create ALL 11 Sections

Work through each section systematically:

**Section 1: Header**
```yaml
file_path: path/to/file.py
purpose: One sentence explaining what this file does
part_of_module: Which larger module/system this belongs to
stability: experimental|beta|stable
business_criticality: low|medium|high|critical
```

**Section 2: What This File Does**
- Start with real-world analogy
- 3-5 paragraphs telling the story
- Include concrete examples with actual data
- Reference specific line numbers
- Explain business impact

**Section 3: How This Fits Into The Program**
- Who creates this file (exact location + function name)
- What it depends on (all imports and services)
- What uses this file (all consumers)
- Mermaid data flow diagram

**Section 4: Main Variables & State**
- Complete table of all class instance variables
- Example values for each
- When updated, who reads it

**Section 5: The Journey Through The Code**
For each major function:
- When it runs
- What triggers it
- Step-by-step story with line numbers
- Variables used (table)
- Error paths
- Why this matters (business impact)

**Section 6: Key Decisions**
- Design choices made
- Why this way vs alternatives
- Tradeoffs accepted
- Code location

**Section 7: Common Issues**
- What users see
- What's actually happening
- How to diagnose (bash commands)
- How to fix
- Prevention strategies

**Section 8: Code Examples**
- Annotated code snippets
- Line-by-line explanations
- Real-world examples

**Section 9: Variable Reference**
- Complete table of ALL variables
- Class instance variables
- Function local variables
- Set/read locations

**Section 10: Testing Examples**
- At least 3 test scenarios
- Concrete setup code
- Assertions with expected values
- Cover happy path + edge cases

**Section 11: Performance**
- Throughput numbers
- Latency measurements
- Memory usage
- Bottlenecks
- Optimizations

### Step 4: Save to Correct Location

```python
# Determine output path
# Format: docs/architecture/{module_path}/{filename}.md
# Example: topstepx_backend/services/order_service.py
#       -> docs/architecture/topstepx_backend/services/order_service.py.md

output_path = f"/home/buckstrdr/TopStepx/docs/architecture/{module_path}/{filename}.md"
Write(output_path, documentation_content)
```

### Step 5: Verify Completeness

Check ALL 11 sections present:
```python
sections_required = [
    "file_path:", "purpose:", "## What This File Does",
    "## How This Fits Into The Program", "## Main Variables",
    "## The Journey Through The Code", "## Key Decisions",
    "## Common Issues", "## Code Examples", "## Variable Reference",
    "## Testing Examples", "## Performance"
]

# Verify each section exists in output
for section in sections_required:
    if section not in documentation_content:
        raise ValueError(f"Missing required section: {section}")
```

## Common Rationalizations (STOP and Use Skill Instead)

| If You're Thinking... | The Reality Is... |
|-----------------------|-------------------|
| "File is too simple for troubleshooting" | Simple files fail too. Document potential issues. ALL sections required. |
| "Testing would be redundant with caller tests" | Every file needs its own test examples. No exceptions. |
| "Code examples redundant with function walkthroughs" | Different sections serve different readers. Include both. |
| "Troubleshooting would be speculative" | Prevention docs prevent future issues. Required section. |
| "Not efficient for this pass" | Incomplete docs require rework. Complete IS efficient. |
| "Management wants coverage not perfection" | 11/11 sections IS coverage. Missing sections = incomplete. |
| "Work efficiently - hit main points" | ALL 11 sections ARE the main points. No shortcuts. |
| "File is stateless utility, no performance section needed" | Every file has performance characteristics. Measure them. |
| "Would need to search for tests" | Then search for tests. Required section. |
| "Let me focus on what's important" | All 11 sections are important. That's why they're in STYLE.md. |

**All of these mean: Stop rationalizing. Complete all 11 sections.**

## Quality Standards

For EACH section:

✅ **Use concrete examples**: "MNQ at $16,125.50" not "contract at price"
✅ **Reference line numbers**: "line 45" or "lines 102-115"
✅ **Real-world analogies**: "Like a traffic controller..." not just technical description
✅ **Business impact**: "Without this, traders lose $X" not just "function fails"
✅ **No jargon without definitions**: Define every technical term first use
✅ **Mermaid diagrams**: For data flow in section 3
✅ **Complete tables**: Every variable, not just "main ones"
✅ **Bash commands**: For troubleshooting diagnosis
✅ **Test code**: Runnable assertions, not pseudocode

## Integration with Execute-Plan

This skill is callable by execute-plan and other automation:

```python
# Single file
Task(
    subagent_type="general-purpose",
    description="Document Python file",
    prompt=f"""Use the documenting-python-files skill.

    Document: {python_file_path}

    Save to: {output_path}
    """
)

# Batch documentation
files_to_document = ["file1.py", "file2.py", "file3.py"]
for file in files_to_document:
    Task(
        subagent_type="general-purpose",
        description=f"Document {file}",
        prompt=f"Use documenting-python-files skill to document {file}"
    )
```

## Red Flags - You're About to Skip Sections

If you catch yourself thinking ANY of these:
- "This section doesn't apply to this file"
- "I'll come back to this section later"
- "The user said to work efficiently"
- "This file is too [simple/complex/short/long] for [section name]"
- "Testing examples would just test [framework]"
- "No known issues, so skip troubleshooting"
- "Performance doesn't matter for utilities"

**STOP. These are rationalizations. Complete all 11 sections.**

## Example Invocation

```python
# User request: "Document the order service file"

# Step 1: Acknowledge using skill
"I'm using the documenting-python-files skill to create comprehensive documentation."

# Step 2: Load format
Read("/home/buckstrdr/TopStepx/docs/architecture/STYLE.md")

# Step 3: Read Python file
Read("/home/buckstrdr/TopStepx/topstepx_backend/services/order_service.py")

# Step 4: Create ALL 11 sections
# ... (work through each section)

# Step 5: Save
Write("/home/buckstrdr/TopStepx/docs/architecture/topstepx_backend/services/order_service.py.md", content)

# Step 6: Verify
"Documentation complete. All 11 sections included:
✅ Header, ✅ What This Does, ✅ How It Fits, ✅ Variables & State,
✅ Function Walkthroughs, ✅ Key Decisions, ✅ Common Issues,
✅ Code Examples, ✅ Variable Reference, ✅ Testing, ✅ Performance"
```

## The Bottom Line

**Documentation is complete when ALL 11 sections are present with quality content.**

Not 10 sections. Not "most sections". Not "the important ones".

ALL 11. EVERY time. NO EXCEPTIONS.

If you're tempted to skip a section, re-read the rationalization table above and complete the section anyway.
