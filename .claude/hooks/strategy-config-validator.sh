#!/bin/bash
# Strategy Config Validator - Validates strategies.yaml syntax

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

STRATEGIES_FILE="topstepx_backend/strategy/configs/strategies.yaml"

# Check if strategies.yaml changed
if git diff --cached --name-only | grep -q "$STRATEGIES_FILE"; then
    echo -e "${YELLOW}🔍 Validating strategy config...${NC}"

    # Check YAML syntax
    if ! python3 -c "import yaml; yaml.safe_load(open('$STRATEGIES_FILE'))" 2>/dev/null; then
        echo -e "${RED}✗ Invalid YAML syntax in $STRATEGIES_FILE${NC}"
        python3 -c "import yaml; yaml.safe_load(open('$STRATEGIES_FILE'))" 2>&1
        exit 1
    fi

    # Check for required fields
    VALIDATION_SCRIPT=$(cat <<'EOF'
import yaml
import sys

with open('topstepx_backend/strategy/configs/strategies.yaml') as f:
    config = yaml.safe_load(f)

errors = []

if not isinstance(config, dict) or 'strategies' not in config:
    errors.append("Missing 'strategies' root key")
    sys.exit(1)

for strategy_id, strategy in config['strategies'].items():
    # Check required top-level keys
    required_keys = ['name', 'contract_id', 'timeframe', 'plugin', 'params']
    for key in required_keys:
        if key not in strategy:
            errors.append(f"{strategy_id}: Missing required key '{key}'")

    # Check params structure
    if 'params' in strategy:
        params = strategy['params']
        if 'entry' not in params:
            errors.append(f"{strategy_id}: Missing 'params.entry' (canonical required)")

if errors:
    print("❌ Validation errors:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

print(f"✓ Validated {len(config['strategies'])} strategies")
EOF
)

    if ! python3 -c "$VALIDATION_SCRIPT" 2>&1; then
        echo -e "${RED}✗ Strategy config validation failed${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Strategy config valid${NC}"
fi

exit 0
