"""
Librarian Risk Classification System

Implements 4-tier risk classification (LOW/MEDIUM/HIGH/CRITICAL) for co-signature requests.
Enables auto-approval of LOW/MEDIUM requests (70% of requests) while maintaining security.
"""

from enum import Enum
from typing import Dict, Any
import json
from pathlib import Path
from datetime import datetime
import random


class RiskTier(Enum):
    """Risk classification tiers for co-signature requests"""
    LOW = 0       # Gate 1→2, <50 LOC, no sensitive areas
    MEDIUM = 1    # Gate 2→3, <200 LOC, standard features
    HIGH = 2      # Gate 3→4, >200 LOC, or sensitive areas
    CRITICAL = 3  # Emergency bypass, security-sensitive


# High-risk code areas requiring manual review
HIGH_RISK_AREAS = ["auth", "payment", "security", "encryption", "admin", "credential"]

# LOC thresholds
LOC_HIGH_THRESHOLD = 200  # >200 LOC = HIGH risk
LOC_LOW_THRESHOLD = 50    # <50 LOC = potentially LOW risk


def classify_request_risk(request: Dict[str, Any]) -> RiskTier:
    """
    Classify co-signature request by risk level.

    Args:
        request: Dict with keys:
            - type: str (GATE_TRANSITION, EMERGENCY_BYPASS)
            - files: str (file paths, comma-separated or single)
            - total_loc: int (total lines of code changed)
            - gate: str (RED_TO_GREEN, GREEN_TO_PEER, etc.)

    Returns:
        RiskTier: Classification result
    """
    # CRITICAL: Emergency bypass always requires manual review + user notification
    if request.get("type") == "EMERGENCY_BYPASS":
        return RiskTier.CRITICAL

    # HIGH: Check for high-risk file areas
    files = request.get("files", "").lower()
    if any(area in files for area in HIGH_RISK_AREAS):
        return RiskTier.HIGH

    # HIGH: Check LOC threshold
    total_loc = request.get("total_loc", 0)
    if total_loc > LOC_HIGH_THRESHOLD:
        return RiskTier.HIGH

    # Gate-specific rules
    gate = request.get("gate", "")

    # LOW: Gate 1→2 (RED_TO_GREEN) with small changes
    if gate == "RED_TO_GREEN" and total_loc < LOC_LOW_THRESHOLD:
        return RiskTier.LOW

    # MEDIUM: Gate 2→3 (GREEN_TO_PEER) with moderate changes
    if gate == "GREEN_TO_PEER" and total_loc < LOC_HIGH_THRESHOLD:
        return RiskTier.MEDIUM

    # Default to HIGH for any edge cases
    return RiskTier.HIGH


def auto_approve_eligible(request: Dict[str, Any], risk_tier: RiskTier) -> bool:
    """
    Check if request qualifies for auto-approval.

    Auto-approval requires:
    - Risk tier LOW or MEDIUM
    - All required signoffs present
    - Tests passing (if applicable)
    - Code coverage ≥80% (if applicable)
    - Security scan clean

    Args:
        request: Co-signature request dict
        risk_tier: RiskTier classification

    Returns:
        bool: True if eligible for auto-approval
    """
    # Only LOW and MEDIUM tiers are eligible
    if risk_tier not in [RiskTier.LOW, RiskTier.MEDIUM]:
        return False

    # Check 1: All required signoffs present
    if not request.get("signoffs_present", False):
        return False

    # Check 2: Tests passing (if tests are required)
    if request.get("requires_tests", True):
        if not request.get("tests_passing", False):
            return False

    # Check 3: Code coverage ≥80% (if coverage tracking enabled)
    if request.get("requires_coverage", False):
        coverage = request.get("coverage", 0.0)
        if coverage < 0.80:  # 80% threshold
            return False

    # Check 4: Security scan clean
    if not request.get("security_clean", False):
        return False

    # All checks passed
    return True


def process_co_signature_request(request: Dict[str, Any]) -> Dict[str, Any]:
    """
    Process co-signature request with risk-based delegation.

    Returns:
        Dict with keys:
            - status: str (AUTO_APPROVED, PENDING_MANUAL_REVIEW)
            - risk_tier: str (LOW, MEDIUM, HIGH, CRITICAL)
            - reason: str (explanation)
            - user_notified: bool (for CRITICAL tier)
            - spot_check_scheduled: bool (for auto-approved)
    """
    # Classify risk
    risk_tier = classify_request_risk(request)

    # CRITICAL tier: Manual review + User notification
    if risk_tier == RiskTier.CRITICAL:
        _notify_librarian_urgent(request)
        _notify_user(request, reason="CRITICAL_TIER")
        return {
            "status": "PENDING_MANUAL_REVIEW",
            "risk_tier": risk_tier.name,
            "reason": "CRITICAL_TIER",
            "user_notified": True,
            "spot_check_scheduled": False
        }

    # HIGH tier: Manual review
    if risk_tier == RiskTier.HIGH:
        _notify_librarian(request)
        return {
            "status": "PENDING_MANUAL_REVIEW",
            "risk_tier": risk_tier.name,
            "reason": "HIGH_TIER",
            "user_notified": False,
            "spot_check_scheduled": False
        }

    # LOW/MEDIUM tier: Check auto-approval eligibility
    if auto_approve_eligible(request, risk_tier):
        # AUTO-APPROVE
        _grant_co_signature(request, approved_by="AUTO_APPROVAL", risk_tier=risk_tier)

        # Schedule spot-check audit
        spot_check_rate = 0.05 if risk_tier == RiskTier.LOW else 0.10
        spot_check_scheduled = random.random() < spot_check_rate
        if spot_check_scheduled:
            _add_to_spot_check_queue(request)

        return {
            "status": "AUTO_APPROVED",
            "risk_tier": risk_tier.name,
            "reason": "AUTO_APPROVAL_CHECKS_PASSED",
            "user_notified": False,
            "spot_check_scheduled": spot_check_scheduled
        }
    else:
        # Failed auto-approval checks → Manual review
        _notify_librarian(request, reason="AUTO_APPROVAL_FAILED")
        return {
            "status": "PENDING_MANUAL_REVIEW",
            "risk_tier": risk_tier.name,
            "reason": "AUTO_APPROVAL_FAILED",
            "user_notified": False,
            "spot_check_scheduled": False
        }


# Helper functions (would be implemented fully in production)
def _notify_librarian_urgent(request: Dict[str, Any]) -> None:
    """Send urgent notification to Librarian"""
    audit_log = Path(".git/audit/librarian-notifications.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    notification = {
        "timestamp": datetime.now().isoformat(),
        "type": "URGENT",
        "request": request,
        "reason": "CRITICAL_TIER"
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(notification)
    audit_log.write_text(json.dumps(data, indent=2))


def _notify_user(request: Dict[str, Any], reason: str) -> None:
    """Send notification to User"""
    audit_log = Path(".git/audit/user-notifications.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    notification = {
        "timestamp": datetime.now().isoformat(),
        "type": "CRITICAL_CO_SIGNATURE_REQUEST",
        "request": request,
        "reason": reason
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(notification)
    audit_log.write_text(json.dumps(data, indent=2))


def _notify_librarian(request: Dict[str, Any], reason: str = "HIGH_TIER") -> None:
    """Send standard notification to Librarian"""
    audit_log = Path(".git/audit/librarian-notifications.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    notification = {
        "timestamp": datetime.now().isoformat(),
        "type": "STANDARD",
        "request": request,
        "reason": reason
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(notification)
    audit_log.write_text(json.dumps(data, indent=2))


def _grant_co_signature(request: Dict[str, Any], approved_by: str, risk_tier: RiskTier) -> None:
    """Grant co-signature approval"""
    audit_log = Path(".git/audit/co-signatures.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    approval = {
        "timestamp": datetime.now().isoformat(),
        "request": request,
        "approved_by": approved_by,
        "risk_tier": risk_tier.name,
        "status": "APPROVED"
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(approval)
    audit_log.write_text(json.dumps(data, indent=2))


def _add_to_spot_check_queue(request: Dict[str, Any]) -> None:
    """Add request to spot-check audit queue"""
    queue_file = Path(".git/audit/spot-check-queue.json")
    queue_file.parent.mkdir(parents=True, exist_ok=True)

    item = {
        "timestamp": datetime.now().isoformat(),
        "request": request,
        "status": "PENDING_SPOT_CHECK"
    }

    if queue_file.exists():
        data = json.loads(queue_file.read_text())
    else:
        data = []

    data.append(item)
    queue_file.write_text(json.dumps(data, indent=2))
