"""
Orchestrator QA Rollback Manager

Implements quality gate rollback workflow, authority verification,
and audit trail for feature rollbacks.
"""

from enum import Enum
from typing import Dict, Any, List
import json
from pathlib import Path
from datetime import datetime


class RollbackType(Enum):
    """Rollback type classification"""
    PARTIAL = "PARTIAL"  # Minor fix, fast-track back
    FULL = "FULL"        # Major fix, full gate progression


# LOC threshold for partial vs full rollback
PARTIAL_ROLLBACK_LOC_THRESHOLD = 50


def determine_rollback_target_gate(
    current_gate: str,
    fix_scope_loc: int,
    reason: str
) -> str:
    """
    Determine which gate to roll back to based on rejection reason.

    Rollback logic:
    - QA rejects (Gate 4): Roll back to Gate 2 or Gate 3
      → Gate 2 if fix >50 LOC (needs peer re-review)
      → Gate 3 if fix <50 LOC (minor fix, can fast-track to QA)
    - Peer rejects (Gate 3): Roll back to Gate 2
    - Implementation broken (Gate 2): Roll back to Gate 1

    Args:
        current_gate: Current feature gate
        fix_scope_loc: Estimated LOC for fix
        reason: Rejection reason

    Returns:
        str: Target gate to roll back to
    """
    if current_gate == "Gate 4 (QA)":
        if fix_scope_loc > PARTIAL_ROLLBACK_LOC_THRESHOLD:
            # Major fix: needs peer re-review
            return "Gate 2 (GREEN)"
        else:
            # Minor fix: can fast-track back to QA
            return "Gate 3 (PEER)"

    elif current_gate == "Gate 3 (PEER)":
        # Peer rejection: fix implementation
        return "Gate 2 (GREEN)"

    elif current_gate == "Gate 2 (GREEN)":
        # Tests failing: re-write tests or implementation
        return "Gate 1 (RED)"

    else:
        # Rare case: full restart
        return "Gate 1 (RED)"


def requires_cosignature(current_gate: str, target_gate: str) -> bool:
    """
    Determine if rollback requires Librarian co-signature.

    Rules:
    - Gate 4→3 or 4→2: Librarian co-sign required
    - Gate 3→2: Librarian co-sign required
    - Gate 2→1: No co-sign (low risk)

    Args:
        current_gate: Current gate
        target_gate: Target rollback gate

    Returns:
        bool: True if co-signature required
    """
    # Map gates to numeric values
    gate_levels = {
        "Gate 1 (RED)": 1,
        "Gate 2 (GREEN)": 2,
        "Gate 3 (PEER)": 3,
        "Gate 4 (QA)": 4,
        "Gate 5 (DEPLOY)": 5
    }

    current_level = gate_levels.get(current_gate, 0)
    target_level = gate_levels.get(target_gate, 0)

    # Gate 2→1 is low risk, no co-sign needed
    if current_level == 2 and target_level == 1:
        return False

    # All other rollbacks require co-sign
    return True


def execute_rollback(
    feature_id: str,
    current_gate: str,
    target_gate: str,
    reason: str,
    librarian_cosign: bool,
    owner: str = "Unknown"
) -> Dict[str, Any]:
    """
    Execute feature rollback with comprehensive notifications.

    Args:
        feature_id: Feature identifier
        current_gate: Current feature gate
        target_gate: Target rollback gate
        reason: Rollback reason
        librarian_cosign: Whether Librarian co-signed
        owner: Feature owner (for notifications)

    Returns:
        Dict with success status and details
    """
    # 1. Verify Librarian co-signature (if required)
    if requires_cosignature(current_gate, target_gate):
        if not librarian_cosign:
            return {
                "success": False,
                "error": "Rollback authorization denied: Librarian co-signature required"
            }

    # 2. Determine rollback type
    rollback_type = _classify_rollback_type(current_gate, target_gate)

    # 3. Determine which signoffs to clear
    signoffs_to_clear = _get_signoffs_to_clear(target_gate)

    # 4. Log rollback to audit trail
    _log_rollback(feature_id, current_gate, target_gate, reason, librarian_cosign)

    # 5. Create notification for owner
    _notify_owner(feature_id, owner, current_gate, target_gate, reason)

    return {
        "success": True,
        "rollback_type": rollback_type,
        "signoffs_cleared": signoffs_to_clear,
        "target_gate": target_gate
    }


def _classify_rollback_type(current_gate: str, target_gate: str) -> RollbackType:
    """Classify rollback as PARTIAL or FULL"""
    # Gate 4→3 is partial (preserves peer signoff)
    if current_gate == "Gate 4 (QA)" and target_gate == "Gate 3 (PEER)":
        return RollbackType.PARTIAL
    else:
        return RollbackType.FULL


def _get_signoffs_to_clear(target_gate: str) -> List[str]:
    """Determine which signoffs to clear based on target gate"""
    if target_gate == "Gate 1 (RED)":
        return ["Gate 2 (GREEN)", "Gate 3 (PEER)", "Gate 4 (QA)"]
    elif target_gate == "Gate 2 (GREEN)":
        return ["Gate 3 (PEER)", "Gate 4 (QA)"]
    elif target_gate == "Gate 3 (PEER)":
        return ["Gate 4 (QA)"]
    else:
        return []


def _log_rollback(
    feature_id: str,
    current_gate: str,
    target_gate: str,
    reason: str,
    librarian_cosign: bool
) -> None:
    """Log rollback to audit trail"""
    audit_log = Path(".git/audit/gate-rollbacks.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    log_entry = {
        "feature_id": feature_id,
        "rollback_from": current_gate,
        "rollback_to": target_gate,
        "reason": reason,
        "librarian_cosign": librarian_cosign,
        "timestamp": datetime.now().isoformat()
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(log_entry)
    audit_log.write_text(json.dumps(data, indent=2))


def _notify_owner(
    feature_id: str,
    owner: str,
    current_gate: str,
    target_gate: str,
    reason: str
) -> None:
    """Create notification for feature owner"""
    notification_file = Path(".git/audit/rollback-notifications.json")
    notification_file.parent.mkdir(parents=True, exist_ok=True)

    notification = {
        "feature_id": feature_id,
        "owner": owner,
        "previous_gate": current_gate,
        "current_gate": target_gate,
        "reason": reason,
        "timestamp": datetime.now().isoformat(),
        "next_steps": _get_next_steps(target_gate)
    }

    if notification_file.exists():
        data = json.loads(notification_file.read_text())
    else:
        data = []

    data.append(notification)
    notification_file.write_text(json.dumps(data, indent=2))


def _get_next_steps(target_gate: str) -> List[str]:
    """Get next steps for developer after rollback"""
    if target_gate == "Gate 1 (RED)":
        return [
            "Review failing tests",
            "Fix implementation",
            "Ensure all tests pass",
            "Request Gate 1→2 advancement"
        ]
    elif target_gate == "Gate 2 (GREEN)":
        return [
            "Fix implementation issues",
            "Re-run all tests",
            "Request Gate 2→3 advancement",
            "Peer review will be required"
        ]
    elif target_gate == "Gate 3 (PEER)":
        return [
            "Apply minor fix",
            "Re-run tests",
            "Fast-track to QA re-test"
        ]
    else:
        return ["Unknown next steps"]
