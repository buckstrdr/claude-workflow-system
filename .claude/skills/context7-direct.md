---
name: context7-direct
description: Use when you need to fetch library documentation - instructs Claude Code how to call Context7 API directly using curl to retrieve up-to-date documentation for any library (replaces Context7 MCP server)
---

# Context7 Direct API Usage

## Your Role

You are Claude Code. When users ask about library documentation, you should fetch it directly from Context7 API using this skill. This replaces the Context7 MCP server.

## When to Use This Skill

Use this skill when:
- User asks about library documentation (e.g., "How does Next.js routing work?")
- User needs code examples from a specific library
- User asks "What's the latest on [library]?"
- You need up-to-date documentation to answer a question
- User mentions a library version (e.g., "Next.js v15", "React 18")

## API Endpoint

**Base URL:** `https://context7.com/api/v1/{owner}/{library}/{version?}`

**Authentication:** Bearer token from `.ian/.env`

**Query Parameters:**
- `tokens` - Amount of documentation to return (default: 5000, reduce for focused queries)
- `topic` - Filter by topic (e.g., "routing", "hooks", "authentication")

## How to Fetch Documentation

### Step 1: Load API Key

```bash
# Extract API key from .ian/.env
CONTEXT7_API_KEY=$(grep "^CONTEXT7_API_KEY=" .ian/.env | cut -d '=' -f2)
```

### Step 2: Make API Request

**Latest version:**
```bash
curl -s -H "Authorization: Bearer $CONTEXT7_API_KEY" \
  "https://context7.com/api/v1/vercel/next.js?tokens=3000&topic=routing"
```

**Specific version (recommended):**
```bash
curl -s -H "Authorization: Bearer $CONTEXT7_API_KEY" \
  "https://context7.com/api/v1/vercel/next.js/v15.1.8?tokens=3000&topic=routing"
```

### Step 3: Parse and Use Response

The API returns JSON with documentation content. Extract what you need and answer the user's question.

## Common Library Patterns

| User Asks About | Library ID | Common Topics |
|----------------|------------|---------------|
| Next.js | vercel/next.js | routing, api, deployment |
| React | facebook/react | hooks, components, state |
| FastAPI | python/fastapi | routes, dependencies, validation |
| Express | expressjs/express | middleware, routing, requests |
| Vue | vuejs/vue | components, reactivity, composition |

## Example Workflow

**User asks:** "How do I use Next.js App Router?"

**Your steps:**
1. Load API key from `.ian/.env`
2. Call Context7 API:
   ```bash
   CONTEXT7_API_KEY=$(grep "^CONTEXT7_API_KEY=" .ian/.env | cut -d '=' -f2)
   curl -s -H "Authorization: Bearer $CONTEXT7_API_KEY" \
     "https://context7.com/api/v1/vercel/next.js?tokens=3000&topic=routing" | jq
   ```
3. Read the returned documentation
4. Answer user's question with current, accurate information

## Token Optimization

Adjust `tokens` parameter based on query specificity:

| Query Type | Tokens | Example |
|------------|--------|---------|
| Specific question | 2000-3000 | "How does X work?" |
| Broad overview | 4000-5000 | "Tell me about Y" |
| Code example needed | 2000-3000 | "Show me example of Z" |

## Error Handling

**401 Unauthorized:**
```bash
# Check if API key exists
grep "CONTEXT7_API_KEY" .ian/.env || echo "ERROR: API key not found in .ian/.env"
```

**404 Not Found:**
- Library ID may be wrong
- Try without version first
- Check library name spelling

**429 Rate Limited:**
- Wait and retry (Retry-After header indicates seconds)
- Reduce token count for faster queries

## Best Practices

1. **Always load API key from `.ian/.env`** - Never hardcode
2. **Use specific topics** when possible to reduce tokens
3. **Pin versions** when user mentions specific version
4. **Cache mentally** - If user asks multiple questions about same library, you can reference previous fetch
5. **Parse JSON** - Use `jq` for cleaner output if needed

## Full Example

**User:** "Show me how to use React hooks"

**You execute:**
```bash
# Load API key
CONTEXT7_API_KEY=$(grep "^CONTEXT7_API_KEY=" .ian/.env | cut -d '=' -f2)

# Fetch React hooks documentation
DOCS=$(curl -s -H "Authorization: Bearer $CONTEXT7_API_KEY" \
  "https://context7.com/api/v1/facebook/react?tokens=3000&topic=hooks")

# Output for your reference (or parse with jq)
echo "$DOCS" | jq -r '.content' 2>/dev/null || echo "$DOCS"
```

**Then:** Use the returned documentation to answer user's question with accurate, up-to-date information.

## Common Commands

### Fetch Latest Docs
```bash
CONTEXT7_API_KEY=$(grep "^CONTEXT7_API_KEY=" .ian/.env | cut -d '=' -f2)
curl -s -H "Authorization: Bearer $CONTEXT7_API_KEY" \
  "https://context7.com/api/v1/{owner}/{library}?tokens=3000"
```

### Fetch Version-Specific Docs
```bash
CONTEXT7_API_KEY=$(grep "^CONTEXT7_API_KEY=" .ian/.env | cut -d '=' -f2)
curl -s -H "Authorization: Bearer $CONTEXT7_API_KEY" \
  "https://context7.com/api/v1/{owner}/{library}/{version}?tokens=3000"
```

### Fetch Topic-Filtered Docs
```bash
CONTEXT7_API_KEY=$(grep "^CONTEXT7_API_KEY=" .ian/.env | cut -d '=' -f2)
curl -s -H "Authorization: Bearer $CONTEXT7_API_KEY" \
  "https://context7.com/api/v1/{owner}/{library}?tokens=3000&topic={topic}"
```

## Red Flags - You're Doing It Wrong

- ❌ Answering from training data instead of fetching current docs
- ❌ Saying "I don't have access to latest documentation"
- ❌ Hardcoding API key instead of loading from `.ian/.env`
- ❌ Not using topic filter when user asks specific question
- ❌ Fetching 5000 tokens when 2000 would answer the question

## Remember

You have DIRECT ACCESS to current library documentation. When users ask about libraries, USE THIS SKILL to fetch the latest information instead of relying on your training data.

**This replaces the Context7 MCP server - you call the API directly.**
