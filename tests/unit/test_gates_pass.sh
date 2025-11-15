#!/bin/bash
# Unit tests for gates-pass.sh

source tests/test-helpers.sh

test_gates_pass_advances_gate() {
    setup_test_repo
    ./scripts/quality-gates/gates-start.sh test_feature

    # Check initial gate
    GATE=$(jq -r '.current_gate' .git/quality-gates/test_feature/status.json)
    [ "$GATE" = "1" ]
    assert_exit_code 0 "Initial gate is 1"

    # Advance gate
    ./scripts/quality-gates/gates-pass.sh test_feature >/dev/null

    # Check new gate
    GATE=$(jq -r '.current_gate' .git/quality-gates/test_feature/status.json)
    [ "$GATE" = "2" ]
    assert_exit_code 0 "Gate advanced to 2"

    cleanup_test_repo
}

test_gates_pass_marks_complete() {
    setup_test_repo
    ./scripts/quality-gates/gates-start.sh test_feature

    # Pass all 7 gates
    for i in {1..7}; do
        ./scripts/quality-gates/gates-pass.sh test_feature >/dev/null 2>&1
    done

    # Check completion file exists
    [ -f ".git/quality-gates/test_feature/completed_at.txt" ]
    assert_exit_code 0 "Completion file created after Gate 7"

    cleanup_test_repo
}

# Run tests
test_gates_pass_advances_gate
test_gates_pass_marks_complete
echo "✅ All gates-pass tests passed"
