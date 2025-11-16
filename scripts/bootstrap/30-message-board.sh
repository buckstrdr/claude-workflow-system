#!/bin/bash
# Initialize message board for the feature

set -euo pipefail

FEATURE_NAME="$1"

# Initialize message board structure
./scripts/init-message-board.sh

echo "✅ Message board initialized"
