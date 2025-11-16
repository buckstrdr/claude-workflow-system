# API - API Testing Helper

Quick API endpoint testing and exploration tool.

## What This Skill Does

- Test API endpoints quickly
- Show available endpoints
- Format JSON responses
- Save common requests
- Debug API issues

## How to Use

```
/api list                              # List all endpoints
/api test /orders/submit               # Test specific endpoint
/api get /positions/live               # GET request
/api post /orders/submit <data>        # POST request
```

## Quick Testing

### Test Endpoint
```bash
# GET request
curl -s http://localhost:8000/api/positions/live | jq

# POST request
curl -X POST http://localhost:8000/api/orders/submit \
  -H "Content-Type: application/json" \
  -d '{"symbol": "MNQ", "quantity": 1, "order_type": "market"}' \
  | jq
```

### List Endpoints
```bash
# From OpenAPI spec
cat .serena/knowledge/openapi.json | jq '.paths | keys'

# Or visit
open http://localhost:8000/docs
```

### Test Health
```bash
curl -s http://localhost:8000/health | jq
```

## Common Endpoints

```bash
# Health check
GET /health

# Positions
GET /api/positions/live

# Orders
POST /api/orders/submit
GET /api/orders
DELETE /api/orders/{id}

# Strategy
GET /api/strategies/state
POST /api/strategies/start

# Logs
GET /api/logs/strategies
GET /api/logs/sources
```

## Debug API Issues

```bash
# Check if backend running
curl http://localhost:8000/health

# Test with verbose
curl -v http://localhost:8000/api/endpoint

# Check logs
/logs backend | grep "POST /api"
```

## Tips

- Use `/api list` to discover endpoints
- Check `/docs` for interactive API explorer
- Use `jq` for JSON formatting
- Save common requests as shell aliases
