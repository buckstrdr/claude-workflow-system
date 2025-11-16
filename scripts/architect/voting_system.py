"""
Architecture Council Voting System

Implements quorum rules, timeout handling, tie-breaking, and User escalation
for the 3-member Architecture Council.
"""

from enum import Enum
from typing import Dict, List, Any, Optional
import json
from pathlib import Path
from datetime import datetime, timedelta
import uuid


class VoteStatus(Enum):
    """Vote status states"""
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    TIE = "TIE"
    PENDING_TIE_BREAKER = "PENDING_TIE_BREAKER"
    ESCALATED_TO_USER = "ESCALATED_TO_USER"


class QuorumScenario(Enum):
    """Quorum validation scenarios"""
    FULL_COUNCIL = "FULL_COUNCIL"              # All 3 voted
    MINIMUM_QUORUM = "MINIMUM_QUORUM"          # 2/3 voted
    INSUFFICIENT_QUORUM = "INSUFFICIENT_QUORUM"  # Only 1 voted
    TIMEOUT_NO_VOTES = "TIMEOUT_NO_VOTES"      # 0 votes


# Configuration constants
MINIMUM_QUORUM = 2  # At least 2 out of 3 architects must vote
VOTING_TIMEOUT = 48  # hours
REMINDER_INTERVAL = 24  # hours
TIE_BREAKER_DEADLINE = 12  # hours (expedited)


def validate_quorum(votes_cast: int) -> Dict[str, Any]:
    """
    Validate if council vote has legitimate quorum.

    Args:
        votes_cast: Number of votes received

    Returns:
        Dict with keys:
            - valid: bool
            - quorum_met: bool
            - scenario: QuorumScenario
    """
    total_architects = 3

    if votes_cast == total_architects:
        # Normal case: all 3 architects voted
        return {
            "valid": True,
            "quorum_met": True,
            "scenario": QuorumScenario.FULL_COUNCIL
        }
    elif votes_cast >= MINIMUM_QUORUM:
        # 2 out of 3 voted: quorum met
        return {
            "valid": True,
            "quorum_met": True,
            "scenario": QuorumScenario.MINIMUM_QUORUM
        }
    elif votes_cast == 1:
        # Only 1 vote: quorum not met
        return {
            "valid": False,
            "quorum_met": False,
            "scenario": QuorumScenario.INSUFFICIENT_QUORUM
        }
    else:
        # No votes: timeout
        return {
            "valid": False,
            "quorum_met": False,
            "scenario": QuorumScenario.TIMEOUT_NO_VOTES
        }


def initiate_council_vote(proposal: Dict[str, Any]) -> str:
    """
    Start Architecture Council vote.

    Args:
        proposal: Dict with title, description, context

    Returns:
        vote_id: Unique identifier for this vote
    """
    vote_id = f"VOTE-{uuid.uuid4().hex[:8].upper()}"

    audit_log = Path(".git/audit/architectural-votes.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    vote_record = {
        "vote_id": vote_id,
        "proposal": proposal,
        "initiated_at": datetime.now().isoformat(),
        "deadline": (datetime.now() + timedelta(hours=VOTING_TIMEOUT)).isoformat(),
        "votes": [],
        "status": VoteStatus.PENDING.value
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(vote_record)
    audit_log.write_text(json.dumps(data, indent=2))

    return vote_id


def cast_vote(vote_id: str, architect: str, decision: str, reasoning: str) -> bool:
    """
    Cast a vote for an architectural proposal.

    Args:
        vote_id: Vote identifier
        architect: Architect name (Architect-A, Architect-B, Architect-C)
        decision: APPROVE or REJECT
        reasoning: Explanation for vote

    Returns:
        bool: True if vote recorded successfully
    """
    audit_log = Path(".git/audit/architectural-votes.json")

    if not audit_log.exists():
        return False

    data = json.loads(audit_log.read_text())

    for vote_record in data:
        if vote_record["vote_id"] == vote_id:
            # Check if architect already voted
            if any(v["architect"] == architect for v in vote_record["votes"]):
                return False  # Already voted

            # Record vote
            vote_record["votes"].append({
                "architect": architect,
                "decision": decision,
                "reasoning": reasoning,
                "timestamp": datetime.now().isoformat()
            })

            audit_log.write_text(json.dumps(data, indent=2))
            return True

    return False


def resolve_vote(votes: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Determine outcome when quorum is met.

    Args:
        votes: List of vote dicts with architect, decision, reasoning

    Returns:
        Dict with outcome, approve_count, reject_count
    """
    approve_count = sum(1 for v in votes if v["decision"] == "APPROVE")
    reject_count = sum(1 for v in votes if v["decision"] == "REJECT")

    if approve_count > reject_count:
        outcome = VoteStatus.APPROVED
    elif reject_count > approve_count:
        outcome = VoteStatus.REJECTED
    else:
        # Tie
        outcome = VoteStatus.TIE

    return {
        "outcome": outcome,
        "approve_count": approve_count,
        "reject_count": reject_count
    }


def handle_tie(vote_id: str, votes: List[Dict[str, Any]], tie_breaker_timeout: bool = False) -> Dict[str, Any]:
    """
    Handle tie scenarios.

    Args:
        vote_id: Vote identifier
        votes: Current votes (should be 1-1 tie)
        tie_breaker_timeout: If True, simulates timeout for testing

    Returns:
        Dict with status and next steps
    """
    if len(votes) == 2:
        # 1-1 tie, request expedited vote from missing architect
        all_architects = {"Architect-A", "Architect-B", "Architect-C"}
        voted_architects = {v["architect"] for v in votes}
        missing_architect = list(all_architects - voted_architects)[0]

        if tie_breaker_timeout:
            # Tie-breaker unavailable after expedited deadline
            return {
                "status": VoteStatus.ESCALATED_TO_USER,
                "reason": "TIE_UNRESOLVED",
                "votes": votes
            }

        # Send urgent tie-breaker request
        _send_tie_breaker_request(vote_id, missing_architect, votes)

        return {
            "status": VoteStatus.PENDING_TIE_BREAKER,
            "missing_architect": missing_architect,
            "expedited_deadline_hours": TIE_BREAKER_DEADLINE
        }
    else:
        # 3-way tie or other edge case
        return {
            "status": VoteStatus.ESCALATED_TO_USER,
            "reason": "TIE_UNRESOLVED",
            "votes": votes
        }


def check_vote_status(vote_id: str, timeout_reached: bool = False) -> Dict[str, Any]:
    """
    Check if vote can be resolved.

    Args:
        vote_id: Vote identifier
        timeout_reached: If True, enforce timeout logic

    Returns:
        Dict with status, quorum_met, votes, reason
    """
    audit_log = Path(".git/audit/architectural-votes.json")

    if not audit_log.exists():
        return {"status": VoteStatus.PENDING, "quorum_met": False}

    data = json.loads(audit_log.read_text())

    for vote_record in data:
        if vote_record["vote_id"] == vote_id:
            votes = vote_record["votes"]
            vote_count = len(votes)

            quorum_validation = validate_quorum(vote_count)

            if quorum_validation["quorum_met"]:
                # Quorum met - resolve vote
                resolution = resolve_vote(votes)

                if resolution["outcome"] == VoteStatus.TIE:
                    # Handle tie
                    return {
                        "status": VoteStatus.TIE,
                        "quorum_met": True,
                        "votes": votes,
                        "reason": "TIE_REQUIRES_BREAKING"
                    }
                else:
                    # Clear majority
                    return {
                        "status": resolution["outcome"],
                        "quorum_met": True,
                        "votes": votes,
                        "approve_count": resolution["approve_count"],
                        "reject_count": resolution["reject_count"]
                    }

            elif timeout_reached:
                # Timeout without quorum
                if vote_count == 0:
                    reason = "TIMEOUT_NO_VOTES"
                    urgency = "HIGH"
                else:
                    reason = "QUORUM_NOT_MET"
                    urgency = "MEDIUM"

                return {
                    "status": VoteStatus.ESCALATED_TO_USER,
                    "quorum_met": False,
                    "votes": votes,
                    "reason": reason,
                    "urgency": urgency
                }
            else:
                # Still waiting for votes
                return {
                    "status": VoteStatus.PENDING,
                    "quorum_met": False,
                    "votes": votes
                }

    return {"status": VoteStatus.PENDING, "quorum_met": False}


def escalate_to_user(vote_id: str, votes: List[Dict[str, Any]], reason: str) -> Dict[str, Any]:
    """
    Escalate to User when council cannot reach valid decision.

    Args:
        vote_id: Vote identifier
        votes: Current votes
        reason: Reason for escalation

    Returns:
        Dict with escalated status and notification details
    """
    audit_log = Path(".git/audit/user-escalations.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    escalation = {
        "vote_id": vote_id,
        "reason": reason,
        "votes": votes,
        "positions": [
            {
                "architect": v["architect"],
                "decision": v["decision"],
                "reasoning": v.get("reasoning", "")
            }
            for v in votes
        ],
        "escalated_at": datetime.now().isoformat(),
        "urgency": "HIGH" if reason == "TIMEOUT_NO_VOTES" else "MEDIUM"
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(escalation)
    audit_log.write_text(json.dumps(data, indent=2))

    return {
        "escalated": True,
        "reason": reason,
        "positions": escalation["positions"]
    }


def _send_tie_breaker_request(vote_id: str, architect: str, votes: List[Dict[str, Any]]) -> None:
    """Send urgent tie-breaker request to missing architect"""
    audit_log = Path(".git/audit/tie-breaker-requests.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    request = {
        "vote_id": vote_id,
        "architect": architect,
        "votes": votes,
        "deadline": (datetime.now() + timedelta(hours=TIE_BREAKER_DEADLINE)).isoformat(),
        "urgency": "HIGH",
        "message": "Council tie - your vote needed to break deadlock",
        "timestamp": datetime.now().isoformat()
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(request)
    audit_log.write_text(json.dumps(data, indent=2))
