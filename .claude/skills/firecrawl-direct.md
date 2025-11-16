---
name: firecrawl-direct
description: Use when you need to scrape websites or crawl documentation - instructs Claude Code how to call Firecrawl API directly using curl to extract web content, documentation, or structured data (replaces Firecrawl MCP server)
---

# Firecrawl Direct API Usage

## Your Role

You are Claude Code. When users ask you to scrape websites, fetch documentation, or extract web content, you should use Firecrawl API directly. This replaces the Firecrawl MCP server.

## When to Use This Skill

Use this skill when:
- User asks to "scrape [website]"
- User wants content from a webpage
- User needs documentation from a website
- User asks "What's on [URL]?"
- User wants to extract structured data from a site
- User mentions crawling multiple pages

## API Endpoints

**Base URL:** `https://api.firecrawl.dev/v1`

**Authentication:** Bearer token from `.ian/.env`

### Available Endpoints

| Endpoint | Purpose | Use When |
|----------|---------|----------|
| `/scrape` | Single page | User wants one specific page |
| `/map` | List URLs | User wants to discover pages on a site |
| `/crawl` | Multiple pages (async) | User wants many pages, can wait |
| `/batch/scrape` | Known URL list | User has specific list of URLs |
| `/extract` | Structured data | User wants data matching a schema |

## How to Scrape a Page

### Step 1: Load API Key

```bash
# Extract API key from .ian/.env
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)
```

### Step 2: Scrape Page

```bash
curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "formats": ["markdown"],
    "onlyMainContent": true
  }'
```

### Step 3: Use the Content

Parse the JSON response and use the content to answer user's question.

## Common Operations

### 1. Scrape Single Page (Most Common)

**User:** "Scrape https://example.com"

```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)

curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "formats": ["markdown"],
    "onlyMainContent": true
  }' | jq -r '.data.markdown'
```

### 2. Scrape with Caching (Static Content)

**Use for documentation, specs, static pages (500% faster):**

```bash
curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://docs.example.com",
    "formats": ["markdown"],
    "onlyMainContent": true,
    "maxAge": 172800000
  }' | jq -r '.data.markdown'
```

**maxAge values:**
- `172800000` = 48 hours (recommended for docs)
- `86400000` = 24 hours
- `3600000` = 1 hour
- Omit for real-time data

### 3. Map Site URLs (Discovery)

**User:** "Find all pages on https://docs.example.com"

```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)

curl -s -X POST "https://api.firecrawl.dev/v1/map" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://docs.example.com"
  }' | jq -r '.data.links[]'
```

### 4. Batch Scrape (Multiple Known URLs)

**User provides list of URLs:**

```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)

curl -s -X POST "https://api.firecrawl.dev/v1/batch/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "urls": [
      "https://example.com/page1",
      "https://example.com/page2",
      "https://example.com/page3"
    ],
    "formats": ["markdown"],
    "onlyMainContent": true
  }'
```

### 5. Extract Structured Data

**User wants specific data fields:**

```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)

curl -s -X POST "https://api.firecrawl.dev/v1/extract" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/products",
    "schema": {
      "type": "object",
      "properties": {
        "name": {"type": "string"},
        "price": {"type": "number"},
        "description": {"type": "string"}
      }
    }
  }'
```

## Response Formats

Firecrawl can return content in multiple formats:

```json
{
  "formats": ["markdown"],        // Clean markdown (recommended)
  "formats": ["html"],           // Raw HTML
  "formats": ["markdown", "html"] // Both
}
```

**Use `markdown` for most cases** - it's clean and easy to parse.

## Performance Optimization

### Use maxAge for Static Content

**ALWAYS use maxAge when content doesn't change frequently:**

| Content Type | maxAge | Why |
|--------------|--------|-----|
| Documentation | 172800000 (48h) | Rarely changes, 500% faster |
| Blog posts | 86400000 (24h) | Static after publishing |
| Product pages | 3600000 (1h) | Updated occasionally |
| News/Real-time | Omit | Needs fresh data |

### Filter to Main Content

**Always use `onlyMainContent: true`** to skip navbars, footers, ads:

```json
{
  "url": "https://example.com",
  "onlyMainContent": true  // Removes noise
}
```

## Error Handling

**401 Unauthorized:**
```bash
grep "FIRECRAWL_API_KEY" .ian/.env || echo "ERROR: API key not found"
```

**403 Forbidden:**
- Site may be blocking scrapers
- Try without `onlyMainContent` or adjust headers

**429 Rate Limited:**
- Free tier: 2 requests/second
- Wait and retry
- Use maxAge caching to reduce requests

**Timeout:**
- Large pages may take time
- Try increasing timeout
- Consider using `/crawl` for async processing

## Async Crawling (Large Jobs)

For crawling many pages, use async `/crawl`:

```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)

# Start crawl job
JOB_RESPONSE=$(curl -s -X POST "https://api.firecrawl.dev/v1/crawl" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://docs.example.com",
    "limit": 50,
    "scrapeOptions": {
      "formats": ["markdown"]
    }
  }')

JOB_ID=$(echo "$JOB_RESPONSE" | jq -r '.id')

# Check status
curl -s "https://api.firecrawl.dev/v1/crawl/$JOB_ID" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" | jq
```

## Decision Tree

**User request → Your action:**

```
"Scrape this URL" → /scrape (single page)
"What's on this page?" → /scrape (single page)
"Crawl this documentation site" → /crawl (async, many pages)
"Get all URLs from site" → /map (discover)
"Scrape these 5 URLs" → /batch/scrape (known list)
"Extract product data" → /extract (structured)
```

## Full Example

**User:** "Scrape the Python FastAPI documentation homepage"

**You execute:**

```bash
# Load API key
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)

# Scrape with caching (docs are static)
CONTENT=$(curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://fastapi.tiangolo.com",
    "formats": ["markdown"],
    "onlyMainContent": true,
    "maxAge": 172800000
  }')

# Extract markdown content
echo "$CONTENT" | jq -r '.data.markdown'
```

**Then:** Show user the scraped content or answer their question using it.

## Common Patterns

### Pattern: Documentation Scraping
```bash
# Always use maxAge for docs
curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://docs.example.com",
    "formats": ["markdown"],
    "onlyMainContent": true,
    "maxAge": 172800000
  }'
```

### Pattern: Article/Blog Scraping
```bash
# Main content only, no caching for fresh articles
curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://blog.example.com/article",
    "formats": ["markdown"],
    "onlyMainContent": true
  }'
```

### Pattern: Site Discovery Then Scrape
```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)

# Step 1: Map site
URLS=$(curl -s -X POST "https://api.firecrawl.dev/v1/map" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://docs.example.com"}' | jq -r '.data.links[]')

# Step 2: Batch scrape discovered URLs
curl -s -X POST "https://api.firecrawl.dev/v1/batch/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"urls\": $(echo "$URLS" | jq -R -s -c 'split("\n")[:-1]'),
    \"formats\": [\"markdown\"],
    \"onlyMainContent\": true,
    \"maxAge\": 172800000
  }"
```

## Red Flags - You're Doing It Wrong

- ❌ Not using maxAge for documentation/static content
- ❌ Hardcoding API key instead of loading from `.ian/.env`
- ❌ Using `/crawl` when user has specific URL list (use `/batch/scrape`)
- ❌ Not using `onlyMainContent: true` (gets too much noise)
- ❌ Requesting HTML when markdown is cleaner
- ❌ Not checking for API key before making request

## Quick Commands Reference

### Single Page
```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)
curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "URL_HERE", "formats": ["markdown"], "onlyMainContent": true}'
```

### With Caching (Static Content)
```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)
curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "URL_HERE", "formats": ["markdown"], "onlyMainContent": true, "maxAge": 172800000}'
```

### Discover URLs
```bash
FIRECRAWL_API_KEY=$(grep "^FIRECRAWL_API_KEY=" .ian/.env | cut -d '=' -f2)
curl -s -X POST "https://api.firecrawl.dev/v1/map" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "URL_HERE"}'
```

## Remember

You have DIRECT ACCESS to web scraping. When users ask you to scrape websites or fetch web content, USE THIS SKILL to get the data directly instead of saying "I can't access websites."

**This replaces the Firecrawl MCP server - you call the API directly.**
