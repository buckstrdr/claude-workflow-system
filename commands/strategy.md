# Strategy - Strategy Operations Helper

Manage trading strategy operations, configuration, execution, and debugging.

## What This Skill Does

- List available strategies
- Test strategy configurations
- Debug strategy execution
- View strategy logs
- Validate strategy schemas

## How to Use

```
/strategy list          # List all strategies
/strategy test <name>   # Test strategy config
/strategy logs <name>   # View strategy logs
/strategy validate      # Validate configurations
```

## Common Operations

### List Strategies
```bash
ls your_backend/strategy/plugins/*.py
```

### Test Configuration
```python
# Validate strategy config JSON
python -c "
from your_backend.api.schemas.strategies import StrategyConfig
import json

with open('strategy_config.json') as f:
    config = json.load(f)

validated = StrategyConfig(**config)
print('✓ Config valid')
"
```

### View Strategy Logs
```bash
# Backend strategy logs
/logs backend | grep strategy

# Structured logs via API
curl http://localhost:8000/api/logs/strategies
```

### Debug Strategy
```bash
# Check strategy state
curl http://localhost:8000/api/strategies/state

# Run smoke test
python dev/smoke/test_strategies_imports.py
```

## Quick Reference

Common strategy files:
- `your_backend/strategy/plugins/` - Strategy implementations
- `your_backend/strategy/policies/` - Exit policies
- `your_backend/api/schemas/strategies.py` - Config schemas
