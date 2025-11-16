"""
Test suite for Architecture Council voting system.

Tests quorum rules, timeout handling, tie-breaking, and escalation workflows.
"""

import pytest
import sys
from pathlib import Path
from datetime import datetime, timedelta

# Add scripts to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from architect.voting_system import (
    VoteStatus,
    QuorumScenario,
    initiate_council_vote,
    cast_vote,
    check_vote_status,
    resolve_vote,
    handle_tie,
    validate_quorum,
    escalate_to_user
)


class TestQuorumValidation:
    """Test quorum validation logic"""

    def test_full_council_3_votes_valid(self):
        """3 votes = full council quorum met"""
        result = validate_quorum(3)
        assert result["valid"] is True
        assert result["quorum_met"] is True
        assert result["scenario"] == QuorumScenario.FULL_COUNCIL

    def test_minimum_quorum_2_votes_valid(self):
        """2 votes = minimum quorum met (2/3)"""
        result = validate_quorum(2)
        assert result["valid"] is True
        assert result["quorum_met"] is True
        assert result["scenario"] == QuorumScenario.MINIMUM_QUORUM

    def test_insufficient_quorum_1_vote_invalid(self):
        """1 vote = insufficient quorum (<2/3)"""
        result = validate_quorum(1)
        assert result["valid"] is False
        assert result["quorum_met"] is False
        assert result["scenario"] == QuorumScenario.INSUFFICIENT_QUORUM

    def test_timeout_0_votes_invalid(self):
        """0 votes = timeout scenario"""
        result = validate_quorum(0)
        assert result["valid"] is False
        assert result["quorum_met"] is False
        assert result["scenario"] == QuorumScenario.TIMEOUT_NO_VOTES


class TestVoteResolution:
    """Test vote resolution logic"""

    def test_resolve_2_1_majority_approve(self):
        """2-1 vote approves correctly"""
        votes = [
            {"architect": "Architect-A", "decision": "APPROVE"},
            {"architect": "Architect-B", "decision": "APPROVE"},
            {"architect": "Architect-C", "decision": "REJECT"}
        ]
        result = resolve_vote(votes)
        assert result["outcome"] == VoteStatus.APPROVED
        assert result["approve_count"] == 2
        assert result["reject_count"] == 1

    def test_resolve_2_1_majority_reject(self):
        """2-1 vote rejects correctly"""
        votes = [
            {"architect": "Architect-A", "decision": "REJECT"},
            {"architect": "Architect-B", "decision": "REJECT"},
            {"architect": "Architect-C", "decision": "APPROVE"}
        ]
        result = resolve_vote(votes)
        assert result["outcome"] == VoteStatus.REJECTED
        assert result["approve_count"] == 1
        assert result["reject_count"] == 2

    def test_resolve_3_0_unanimous_approve(self):
        """3-0 unanimous approval"""
        votes = [
            {"architect": "Architect-A", "decision": "APPROVE"},
            {"architect": "Architect-B", "decision": "APPROVE"},
            {"architect": "Architect-C", "decision": "APPROVE"}
        ]
        result = resolve_vote(votes)
        assert result["outcome"] == VoteStatus.APPROVED
        assert result["approve_count"] == 3
        assert result["reject_count"] == 0

    def test_resolve_2_0_unanimous_with_quorum(self):
        """2-0 unanimous approval (quorum met, 1 unavailable)"""
        votes = [
            {"architect": "Architect-A", "decision": "APPROVE"},
            {"architect": "Architect-B", "decision": "APPROVE"}
        ]
        result = resolve_vote(votes)
        assert result["outcome"] == VoteStatus.APPROVED
        assert result["approve_count"] == 2
        assert result["reject_count"] == 0

    def test_resolve_1_1_tie_triggers_tie_breaker(self):
        """1-1 tie triggers tie-breaker workflow"""
        votes = [
            {"architect": "Architect-A", "decision": "APPROVE"},
            {"architect": "Architect-B", "decision": "REJECT"}
        ]
        result = resolve_vote(votes)
        assert result["outcome"] == VoteStatus.TIE
        assert result["approve_count"] == 1
        assert result["reject_count"] == 1


class TestTieBreaking:
    """Test tie-breaking workflows"""

    def test_tie_with_2_votes_requests_third_architect(self):
        """1-1 tie requests expedited vote from Architect-C"""
        votes = [
            {"architect": "Architect-A", "decision": "APPROVE"},
            {"architect": "Architect-B", "decision": "REJECT"}
        ]
        vote_id = "VOTE-123"
        result = handle_tie(vote_id, votes)
        assert result["status"] == VoteStatus.PENDING_TIE_BREAKER
        assert result["missing_architect"] == "Architect-C"
        assert result["expedited_deadline_hours"] == 12

    def test_tie_escalates_to_user_if_tie_breaker_unavailable(self):
        """Tie escalates to User if Architect-C unavailable after 12h"""
        votes = [
            {"architect": "Architect-A", "decision": "APPROVE"},
            {"architect": "Architect-B", "decision": "REJECT"}
        ]
        vote_id = "VOTE-123"
        # Simulate timeout for tie-breaker
        result = handle_tie(vote_id, votes, tie_breaker_timeout=True)
        assert result["status"] == VoteStatus.ESCALATED_TO_USER
        assert result["reason"] == "TIE_UNRESOLVED"


class TestVoteWorkflow:
    """Test complete voting workflow"""

    def test_initiate_vote_creates_record(self):
        """Initiating vote creates proper audit record"""
        proposal = {
            "title": "Storage backend selection",
            "description": "PostgreSQL vs Redis for idempotency keys"
        }
        vote_id = initiate_council_vote(proposal)
        assert vote_id.startswith("VOTE-")
        # Verify audit file created
        audit_file = Path(".git/audit/architectural-votes.json")
        assert audit_file.exists()

    def test_cast_vote_records_correctly(self):
        """Casting vote records architect's decision"""
        proposal = {"title": "Test proposal"}
        vote_id = initiate_council_vote(proposal)

        cast_vote(vote_id, "Architect-A", "APPROVE", "Performance critical")

        # Verify vote recorded
        status = check_vote_status(vote_id)
        assert len(status["votes"]) == 1
        assert status["votes"][0]["architect"] == "Architect-A"
        assert status["votes"][0]["decision"] == "APPROVE"

    def test_check_vote_status_pending_until_quorum(self):
        """Vote status is PENDING until quorum met"""
        proposal = {"title": "Test proposal"}
        vote_id = initiate_council_vote(proposal)

        cast_vote(vote_id, "Architect-A", "APPROVE", "Reasoning")

        status = check_vote_status(vote_id)
        assert status["status"] == VoteStatus.PENDING
        assert status["quorum_met"] is False

    def test_check_vote_status_resolved_with_quorum(self):
        """Vote resolves when quorum met with majority"""
        proposal = {"title": "Test proposal"}
        vote_id = initiate_council_vote(proposal)

        cast_vote(vote_id, "Architect-A", "APPROVE", "Reasoning A")
        cast_vote(vote_id, "Architect-B", "APPROVE", "Reasoning B")

        status = check_vote_status(vote_id)
        assert status["status"] == VoteStatus.APPROVED
        assert status["quorum_met"] is True


class TestTimeoutHandling:
    """Test timeout and reminder workflows"""

    def test_timeout_without_quorum_escalates_to_user(self):
        """Timeout with <2 votes escalates to User"""
        proposal = {"title": "Test proposal"}
        vote_id = initiate_council_vote(proposal)

        # Only 1 vote cast before timeout
        cast_vote(vote_id, "Architect-A", "APPROVE", "Reasoning")

        # Simulate 48h timeout
        status = check_vote_status(vote_id, timeout_reached=True)
        assert status["status"] == VoteStatus.ESCALATED_TO_USER
        assert status["reason"] == "QUORUM_NOT_MET"

    def test_timeout_with_0_votes_escalates_urgently(self):
        """Timeout with 0 votes is urgent escalation"""
        proposal = {"title": "Test proposal"}
        vote_id = initiate_council_vote(proposal)

        # No votes cast
        status = check_vote_status(vote_id, timeout_reached=True)
        assert status["status"] == VoteStatus.ESCALATED_TO_USER
        assert status["reason"] == "TIMEOUT_NO_VOTES"
        assert status["urgency"] == "HIGH"


class TestEscalation:
    """Test User escalation workflows"""

    def test_escalate_to_user_creates_notification(self):
        """Escalating to User creates proper notification"""
        vote_id = "VOTE-123"
        votes = [{"architect": "Architect-A", "decision": "APPROVE"}]

        result = escalate_to_user(vote_id, votes, reason="QUORUM_NOT_MET")

        assert result["escalated"] is True
        assert result["reason"] == "QUORUM_NOT_MET"
        # Verify notification file created
        notification_file = Path(".git/audit/user-escalations.json")
        assert notification_file.exists()

    def test_escalate_for_tie_includes_both_positions(self):
        """Tie escalation includes both architect positions"""
        vote_id = "VOTE-123"
        votes = [
            {"architect": "Architect-A", "decision": "APPROVE", "reasoning": "Reason A"},
            {"architect": "Architect-B", "decision": "REJECT", "reasoning": "Reason B"}
        ]

        result = escalate_to_user(vote_id, votes, reason="TIE_UNRESOLVED")

        assert result["escalated"] is True
        assert result["reason"] == "TIE_UNRESOLVED"
        assert len(result["positions"]) == 2
