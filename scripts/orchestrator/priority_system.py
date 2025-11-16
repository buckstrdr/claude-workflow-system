"""
Orchestrator Feature Priority System

Implements priority-based assignment (CRITICAL/HIGH/MEDIUM/LOW),
workload balancing, preemption rules, and SLA tracking.
"""

from enum import Enum
from typing import Dict, List, Any, Optional
import json
from pathlib import Path
from datetime import datetime, timedelta
import re


class PriorityLevel(Enum):
    """Feature priority levels"""
    CRITICAL = 0  # Production incidents, security breaches, data loss
    HIGH = 1      # User-facing bugs, broken features, payment issues
    MEDIUM = 2    # Standard features, enhancements, improvements
    LOW = 3       # Tech debt, refactoring, nice-to-haves


# Priority weights for workload calculation
PRIORITY_WEIGHTS = {
    PriorityLevel.CRITICAL: 10,
    PriorityLevel.HIGH: 5,
    PriorityLevel.MEDIUM: 2,
    PriorityLevel.LOW: 1
}

# SLA definitions (hours)
SLA_HOURS = {
    PriorityLevel.CRITICAL: 4,
    PriorityLevel.HIGH: 24,
    PriorityLevel.MEDIUM: None,  # No strict SLA
    PriorityLevel.LOW: None       # No SLA
}

# Preemption grace periods (minutes)
GRACE_PERIODS = {
    PriorityLevel.CRITICAL: 15,
    PriorityLevel.HIGH: 30
}


def assign_priority(feature: Dict[str, Any]) -> PriorityLevel:
    """
    Assign priority level based on feature characteristics.

    Args:
        feature: Dict with name, description

    Returns:
        PriorityLevel: Assigned priority
    """
    description = feature.get("description", "").lower()
    name = feature.get("name", "").lower()
    full_text = f"{name} {description}"

    # CRITICAL keywords
    critical_keywords = [
        "production", "down", "outage", "security breach", "data loss",
        "payment.*fail", "critical", "emergency"
    ]
    if any(re.search(keyword, full_text) for keyword in critical_keywords):
        return PriorityLevel.CRITICAL

    # HIGH keywords
    high_keywords = [
        "broken", "login.*fail", "user.*facing.*error", "500 error",
        "payment.*issue", "broken feature"
    ]
    if any(re.search(keyword, full_text) for keyword in high_keywords):
        return PriorityLevel.HIGH

    # LOW keywords
    low_keywords = [
        "refactor", "tech debt", "cleanup", "documentation",
        "nice.*to.*have", "minor"
    ]
    if any(re.search(keyword, full_text) for keyword in low_keywords):
        return PriorityLevel.LOW

    # Default to MEDIUM for feature requests
    return PriorityLevel.MEDIUM


def calculate_workload(pending_features: List[Dict[str, Any]]) -> int:
    """
    Calculate weighted workload for an instance.

    Args:
        pending_features: List of features with priority

    Returns:
        int: Weighted workload count
    """
    total_weight = 0
    for feature in pending_features:
        priority = feature.get("priority", PriorityLevel.MEDIUM)
        total_weight += PRIORITY_WEIGHTS[priority]
    return total_weight


def assign_feature(
    feature: Dict[str, Any],
    required_role: str,
    instances: Dict[str, List[Dict[str, Any]]]
) -> str:
    """
    Assign feature to least-loaded instance of required role.

    Args:
        feature: Feature to assign
        required_role: Required role (Developer, QA, etc.)
        instances: Dict mapping instance name to pending features

    Returns:
        str: Instance name assigned to
    """
    # Calculate workload for each instance
    workload = {}
    for instance_name, pending_features in instances.items():
        workload[instance_name] = calculate_workload(pending_features)

    # Find least-loaded instance
    least_loaded = min(workload, key=workload.get)

    # Log assignment
    _log_assignment(feature, least_loaded, workload)

    return least_loaded


def handle_preemption(
    new_feature: Dict[str, Any],
    current_work: Dict[str, Any]
) -> Dict[str, Any]:
    """
    Determine if new feature should preempt current work.

    Preemption rules:
    - CRITICAL can preempt MEDIUM/LOW (15 min grace)
    - HIGH can preempt LOW (30 min grace)
    - MEDIUM/LOW never preempt

    Args:
        new_feature: Incoming feature
        current_work: Currently active work

    Returns:
        Dict with preempt (bool) and grace_period_minutes (int)
    """
    new_priority = new_feature.get("priority", PriorityLevel.MEDIUM)
    current_priority = current_work.get("priority", PriorityLevel.MEDIUM)

    # CRITICAL preempts MEDIUM/LOW
    if new_priority == PriorityLevel.CRITICAL:
        if current_priority in [PriorityLevel.MEDIUM, PriorityLevel.LOW]:
            return {
                "preempt": True,
                "grace_period_minutes": GRACE_PERIODS[PriorityLevel.CRITICAL]
            }

    # HIGH preempts LOW
    if new_priority == PriorityLevel.HIGH:
        if current_priority == PriorityLevel.LOW:
            return {
                "preempt": True,
                "grace_period_minutes": GRACE_PERIODS[PriorityLevel.HIGH]
            }

    # No preemption
    return {"preempt": False, "grace_period_minutes": 0}


def check_sla_violation(feature: Dict[str, Any]) -> Dict[str, Any]:
    """
    Check if feature has violated SLA.

    Args:
        feature: Feature with priority and assigned_timestamp

    Returns:
        Dict with violated (bool), sla_hours, urgency
    """
    priority = feature.get("priority", PriorityLevel.MEDIUM)
    sla_hours = SLA_HOURS[priority]

    if sla_hours is None:
        # No SLA for MEDIUM/LOW
        return {"violated": False, "sla_hours": None}

    assigned_timestamp = feature.get("assigned_timestamp")
    if not assigned_timestamp:
        return {"violated": False, "sla_hours": sla_hours}

    age = datetime.now() - assigned_timestamp
    age_hours = age.total_seconds() / 3600

    violated = age_hours > sla_hours

    return {
        "violated": violated,
        "sla_hours": sla_hours,
        "age_hours": age_hours,
        "urgency": "HIGH" if priority == PriorityLevel.CRITICAL else "MEDIUM"
    }


class FeaturePriorityQueue:
    """
    Priority queue for managing feature assignments.

    Queue ordering:
    1. CRITICAL priority (immediate)
    2. HIGH priority (same day)
    3. MEDIUM priority (next sprint)
    4. LOW priority (backlog)

    Within same priority: FIFO
    """

    def __init__(self):
        self.queue = {
            PriorityLevel.CRITICAL: [],
            PriorityLevel.HIGH: [],
            PriorityLevel.MEDIUM: [],
            PriorityLevel.LOW: []
        }

    def add_feature(self, feature: Dict[str, Any]) -> None:
        """Add feature to appropriate priority queue."""
        priority = feature.get("priority", PriorityLevel.MEDIUM)
        self.queue[priority].append(feature)

    def get_next_feature(self) -> Optional[Dict[str, Any]]:
        """Get next feature to work on (highest priority first)."""
        for priority in [PriorityLevel.CRITICAL, PriorityLevel.HIGH,
                         PriorityLevel.MEDIUM, PriorityLevel.LOW]:
            if self.queue[priority]:
                return self.queue[priority].pop(0)
        return None

    def get_queue_depth(self) -> int:
        """Get total pending features."""
        return sum(len(features) for features in self.queue.values())

    def get_priority_breakdown(self) -> Dict[PriorityLevel, int]:
        """Get count by priority."""
        return {
            priority: len(features)
            for priority, features in self.queue.items()
        }

    def reorder_on_preemption(self, critical_feature: Dict[str, Any]) -> None:
        """Insert CRITICAL feature at front of queue."""
        self.queue[PriorityLevel.CRITICAL].insert(0, critical_feature)


def _log_assignment(
    feature: Dict[str, Any],
    assigned_instance: str,
    workload: Dict[str, int]
) -> None:
    """Log feature assignment to audit trail"""
    audit_log = Path(".git/audit/feature-priority.json")
    audit_log.parent.mkdir(parents=True, exist_ok=True)

    log_entry = {
        "feature": feature.get("name", "unknown"),
        "priority": feature.get("priority", PriorityLevel.MEDIUM).name,
        "assigned_to": assigned_instance,
        "workload_before": workload[assigned_instance],
        "timestamp": datetime.now().isoformat()
    }

    if audit_log.exists():
        data = json.loads(audit_log.read_text())
    else:
        data = []

    data.append(log_entry)
    audit_log.write_text(json.dumps(data, indent=2))
