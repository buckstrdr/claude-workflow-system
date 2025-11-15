#!/bin/bash
# Test helper functions

setup_test_repo() {
    # Create temp git repo for testing
    export TEST_REPO=$(mktemp -d)
    cd "$TEST_REPO"
    git init
    git config user.email "test@test.com"
    git config user.name "Test"
    mkdir -p .git/quality-gates
}

cleanup_test_repo() {
    cd /
    rm -rf "$TEST_REPO"
}

assert_exit_code() {
    local expected=$1
    local message=$2
    if [ $? -ne $expected ]; then
        echo "❌ FAIL: $message"
        exit 1
    fi
    echo "✓ $message"
}
