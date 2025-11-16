# Smoke - Smoke Test Orchestrator

Run integration smoke tests to verify system behavior and data flows.

## What This Skill Does

- List available smoke tests
- Run specific smoke tests
- Smart test selection based on changes
- Report results with timing

## How to Use

```
/smoke list                    # List all smoke tests
/smoke all                     # Run all smoke tests
/smoke <name>                  # Run specific test
/smoke bars                    # Test bar data flow
/smoke brackets                # Test bracket orders
```

## Available Smoke Tests

Located in `dev/smoke/`:
- `monitor_bars_parity.py` - Bar data flow validation
- `test_brackets_trailing.py` - Bracket order testing
- `test_startup_backfill.py` - Historical data backfill
- `test_historical_backfill.py` - Historical bar loading
- `test_strategies_imports.py` - Strategy import validation

## Running Tests

### All Tests
```bash
for test in dev/smoke/*.py; do
    echo "Running $test..."
    python "$test"
done
```

### Specific Test
```bash
# Monitor bars (5 minute test)
python dev/smoke/monitor_bars_parity.py --contract MNQ.F.US.MNQ.Z25 --duration-min 5

# Bracket orders
python dev/smoke/test_brackets_trailing.py

# Startup backfill
python dev/smoke/test_startup_backfill.py
```

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Smoke Test Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test: monitor_bars_parity
Status: PASSED ✓
Duration: 5m 12s
Details: Received 312 bars, all valid

Test: test_brackets_trailing
Status: PASSED ✓
Duration: 45s
Details: Bracket orders working correctly

Summary: 2/2 PASSED (100%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## When to Use

- Before commits/PRs
- After major changes
- Before releases
- When system behavior seems off
