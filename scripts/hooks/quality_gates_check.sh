#!/bin/bash
# Pre-push hook: Enforce Gate 7 completion before pushing to main

set -euo pipefail

STRICT_HOOKS="${STRICT_HOOKS:-1}"

# Get the remote and branch being pushed to
remote="$1"
url="$2"

# Read branch info from stdin
while read local_ref local_sha remote_ref remote_sha; do
    # Check if pushing to main/master
    if [[ "$remote_ref" =~ refs/heads/(main|master) ]]; then

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Quality Gate Enforcement"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Pushing to: ${remote_ref##*/}"
        echo ""

        # Extract feature name from branch
        current_branch=$(git branch --show-current)

        if [[ "$current_branch" =~ ^feature/(.+)$ ]]; then
            feature_name="${BASH_REMATCH[1]}"
            gate_status=".git/quality-gates/$feature_name/status.json"

            if [ ! -f "$gate_status" ]; then
                echo "❌ No quality gate tracking found for: $feature_name"
                echo ""
                echo "Initialize gates with:"
                echo "  ./scripts/quality-gates/gates-start.sh $feature_name"
                echo ""

                if [ "$STRICT_HOOKS" = "1" ]; then
                    exit 1
                else
                    echo "⚠️  WARNING: Continuing without gates (STRICT_HOOKS=0)"
                fi
            else
                # Check Gate 7 status
                current_gate=$(jq -r '.current_gate' "$gate_status")
                gate_7_status=$(jq -r '.gates["7"].status' "$gate_status")

                if [ "$gate_7_status" != "PASSED" ]; then
                    echo "❌ Gate 7 (Code Reviewed) NOT PASSED"
                    echo ""
                    echo "Current gate: $current_gate"
                    echo "Gate 7 status: $gate_7_status"
                    echo ""
                    echo "Required steps:"
                    echo "  1. Complete all remaining gates"
                    echo "  2. Run: /validator (for code review)"
                    echo "  3. Run: ./scripts/quality-gates/gates-pass.sh $feature_name"
                    echo "  4. Verify Gate 7 is PASSED"
                    echo ""

                    if [ "$STRICT_HOOKS" = "1" ]; then
                        echo "Push BLOCKED."
                        echo ""
                        echo "To bypass (EMERGENCY ONLY):"
                        echo "  STRICT_HOOKS=0 git push $remote ${remote_ref##*/}"
                        echo ""
                        exit 1
                    else
                        echo "⚠️  WARNING: Continuing without Gate 7 (STRICT_HOOKS=0)"
                    fi
                else
                    echo "✅ Gate 7 (Code Reviewed) PASSED"
                    echo ""
                fi
            fi
        else
            echo "⚠️  Not a feature branch: $current_branch"
            echo "   Skipping quality gate check"
            echo ""
        fi
    fi
done

echo "✅ Pre-push checks passed"
exit 0
