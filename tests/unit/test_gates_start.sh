#!/bin/bash
# Unit tests for gates-start.sh

source tests/test-helpers.sh

test_gates_start_creates_directory() {
    setup_test_repo
    ./scripts/quality-gates/gates-start.sh test_feature
    [ -d ".git/quality-gates/test_feature" ]
    assert_exit_code 0 "Creates gate directory"
    cleanup_test_repo
}

test_gates_start_creates_status_json() {
    setup_test_repo
    ./scripts/quality-gates/gates-start.sh test_feature
    jq empty .git/quality-gates/test_feature/status.json
    assert_exit_code 0 "Creates valid status.json"
    cleanup_test_repo
}

# Run tests
test_gates_start_creates_directory
test_gates_start_creates_status_json
echo "✅ All gates-start tests passed"
