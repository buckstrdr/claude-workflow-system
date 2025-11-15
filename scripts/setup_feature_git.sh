#!/bin/bash
# Convenience wrapper for git setup

set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <feature_name>"
    exit 1
fi

./scripts/bootstrap/20-git-setup.sh "$1"
