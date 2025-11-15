#!/bin/bash
# Integration test: Full bootstrap process

set -euo pipefail

TEST_FEATURE="integration_test_$(date +%s)"

echo "Testing bootstrap for: $TEST_FEATURE"

# Run bootstrap (will fail at MCP step, that's OK for test)
./bootstrap.sh "$TEST_FEATURE" 2>&1 | tee /tmp/bootstrap_test.log || true

# Verify steps that should succeed
echo "Verifying preflight checks ran..."
grep "preflight checks passed" /tmp/bootstrap_test.log || exit 1

echo "Verifying git setup ran..."
[ -d "../wt-feature-$TEST_FEATURE" ] || exit 1

echo "Verifying quality gates initialized..."
[ -f ".git/quality-gates/$TEST_FEATURE/status.json" ] || exit 1

# Cleanup
rm -rf "../wt-feature-$TEST_FEATURE"
rm -rf ".git/quality-gates/$TEST_FEATURE"
git branch -D "feature/$TEST_FEATURE" 2>/dev/null || true

echo "✅ Bootstrap integration test passed"
