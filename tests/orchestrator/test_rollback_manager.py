"""
Test suite for Orchestrator rollback manager.

Tests QA rollback workflow, rollback authority, and audit trail.
"""

import pytest
import sys
from pathlib import Path

# Add scripts to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from orchestrator.rollback_manager import (
    determine_rollback_target_gate,
    requires_cosignature,
    execute_rollback,
    RollbackType
)


class TestRollbackTargetDetermination:
    """Test rollback target gate determination"""

    def test_qa_reject_major_fix_rolls_back_to_gate2(self):
        """QA rejection with >50 LOC fix rolls back to Gate 2"""
        target = determine_rollback_target_gate(
            current_gate="Gate 4 (QA)",
            fix_scope_loc=100,
            reason="Race condition"
        )
        assert target == "Gate 2 (GREEN)"

    def test_qa_reject_minor_fix_rolls_back_to_gate3(self):
        """QA rejection with <50 LOC fix rolls back to Gate 3"""
        target = determine_rollback_target_gate(
            current_gate="Gate 4 (QA)",
            fix_scope_loc=20,
            reason="Typo in error message"
        )
        assert target == "Gate 3 (PEER)"

    def test_peer_reject_rolls_back_to_gate2(self):
        """Peer rejection always rolls back to Gate 2"""
        target = determine_rollback_target_gate(
            current_gate="Gate 3 (PEER)",
            fix_scope_loc=75,
            reason="Code quality issues"
        )
        assert target == "Gate 2 (GREEN)"

    def test_implementation_broken_rolls_back_to_gate1(self):
        """Broken implementation rolls back to Gate 1"""
        target = determine_rollback_target_gate(
            current_gate="Gate 2 (GREEN)",
            fix_scope_loc=0,
            reason="Tests no longer pass"
        )
        assert target == "Gate 1 (RED)"


class TestCosignatureRequirements:
    """Test co-signature requirements for rollbacks"""

    def test_gate4_to_gate2_requires_cosign(self):
        """Gate 4→2 rollback requires Librarian co-sign"""
        requires = requires_cosignature(
            current_gate="Gate 4 (QA)",
            target_gate="Gate 2 (GREEN)"
        )
        assert requires is True

    def test_gate4_to_gate3_requires_cosign(self):
        """Gate 4→3 rollback requires Librarian co-sign"""
        requires = requires_cosignature(
            current_gate="Gate 4 (QA)",
            target_gate="Gate 3 (PEER)"
        )
        assert requires is True

    def test_gate3_to_gate2_requires_cosign(self):
        """Gate 3→2 rollback requires Librarian co-sign"""
        requires = requires_cosignature(
            current_gate="Gate 3 (PEER)",
            target_gate="Gate 2 (GREEN)"
        )
        assert requires is True

    def test_gate2_to_gate1_no_cosign(self):
        """Gate 2→1 rollback does not require co-sign (low risk)"""
        requires = requires_cosignature(
            current_gate="Gate 2 (GREEN)",
            target_gate="Gate 1 (RED)"
        )
        assert requires is False


class TestRollbackExecution:
    """Test rollback execution workflow"""

    def test_execute_rollback_with_cosign(self):
        """Execute rollback with Librarian co-sign"""
        result = execute_rollback(
            feature_id="FEAT-123",
            current_gate="Gate 4 (QA)",
            target_gate="Gate 2 (GREEN)",
            reason="Race condition bug",
            librarian_cosign=True
        )
        assert result["success"] is True
        assert result["rollback_type"] == RollbackType.FULL
        # Verify audit log created
        audit_file = Path(".git/audit/gate-rollbacks.json")
        assert audit_file.exists()

    def test_execute_rollback_without_required_cosign_fails(self):
        """Execute rollback without required co-sign should fail"""
        result = execute_rollback(
            feature_id="FEAT-123",
            current_gate="Gate 4 (QA)",
            target_gate="Gate 2 (GREEN)",
            reason="Race condition bug",
            librarian_cosign=False
        )
        assert result["success"] is False
        assert "authorization" in result["error"].lower()

    def test_partial_rollback_preserves_peer_signoff(self):
        """Partial rollback (Gate 4→3) preserves peer signoffs"""
        result = execute_rollback(
            feature_id="FEAT-456",
            current_gate="Gate 4 (QA)",
            target_gate="Gate 3 (PEER)",
            reason="Minor typo fix",
            librarian_cosign=True
        )
        assert result["success"] is True
        assert result["rollback_type"] == RollbackType.PARTIAL
        assert result["signoffs_cleared"] == ["Gate 4 (QA)"]

    def test_full_rollback_clears_all_downstream_signoffs(self):
        """Full rollback (Gate 4→2) clears peer and QA signoffs"""
        result = execute_rollback(
            feature_id="FEAT-789",
            current_gate="Gate 4 (QA)",
            target_gate="Gate 2 (GREEN)",
            reason="Major implementation fix",
            librarian_cosign=True
        )
        assert result["success"] is True
        assert result["rollback_type"] == RollbackType.FULL
        assert "Gate 3 (PEER)" in result["signoffs_cleared"]
        assert "Gate 4 (QA)" in result["signoffs_cleared"]

    def test_rollback_creates_notification(self):
        """Rollback creates notification for feature owner"""
        result = execute_rollback(
            feature_id="FEAT-999",
            current_gate="Gate 4 (QA)",
            target_gate="Gate 2 (GREEN)",
            reason="Bug found",
            librarian_cosign=True,
            owner="Dev-A"
        )
        assert result["success"] is True
        # Verify notification file created
        notification_file = Path(".git/audit/rollback-notifications.json")
        assert notification_file.exists()


class TestRollbackTypes:
    """Test rollback type classification"""

    def test_major_fix_is_full_rollback(self):
        """Fix >50 LOC is full rollback"""
        target = determine_rollback_target_gate(
            current_gate="Gate 4 (QA)",
            fix_scope_loc=100,
            reason="Race condition"
        )
        assert target == "Gate 2 (GREEN)"  # Full rollback

    def test_minor_fix_is_partial_rollback(self):
        """Fix <50 LOC is partial rollback"""
        target = determine_rollback_target_gate(
            current_gate="Gate 4 (QA)",
            fix_scope_loc=10,
            reason="Typo"
        )
        assert target == "Gate 3 (PEER)"  # Partial rollback


class TestAuditTrail:
    """Test rollback audit trail"""

    def test_rollback_logged_to_audit_trail(self):
        """All rollbacks must be logged"""
        execute_rollback(
            feature_id="FEAT-AUDIT-123",
            current_gate="Gate 4 (QA)",
            target_gate="Gate 2 (GREEN)",
            reason="Test audit trail",
            librarian_cosign=True
        )
        audit_file = Path(".git/audit/gate-rollbacks.json")
        assert audit_file.exists()

        import json
        data = json.loads(audit_file.read_text())
        assert len(data) > 0
        assert any(r["feature_id"] == "FEAT-AUDIT-123" for r in data)
