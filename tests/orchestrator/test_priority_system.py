"""
Test suite for Orchestrator feature priority system.

Tests priority assignment, workload-based assignment, preemption, and SLA tracking.
"""

import pytest
import sys
from pathlib import Path
from datetime import datetime, timedelta

# Add scripts to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from orchestrator.priority_system import (
    PriorityLevel,
    assign_priority,
    assign_feature,
    calculate_workload,
    handle_preemption,
    check_sla_violation,
    FeaturePriorityQueue
)


class TestPriorityAssignment:
    """Test priority level assignment logic"""

    def test_assign_critical_for_production_down(self):
        """Production incidents should be CRITICAL"""
        feature = {
            "name": "payment_processing_fix",
            "description": "Production: Payment processing down for 10+ minutes"
        }
        priority = assign_priority(feature)
        assert priority == PriorityLevel.CRITICAL

    def test_assign_critical_for_security_breach(self):
        """Security breaches should be CRITICAL"""
        feature = {
            "name": "security_patch",
            "description": "Security breach: API keys exposed in logs"
        }
        priority = assign_priority(feature)
        assert priority == PriorityLevel.CRITICAL

    def test_assign_high_for_user_facing_bug(self):
        """User-facing bugs should be HIGH"""
        feature = {
            "name": "login_fix",
            "description": "Login broken for all users"
        }
        priority = assign_priority(feature)
        assert priority == PriorityLevel.HIGH

    def test_assign_medium_for_feature_request(self):
        """Feature requests should be MEDIUM"""
        feature = {
            "name": "new_feature",
            "description": "Add export to CSV functionality"
        }
        priority = assign_priority(feature)
        assert priority == PriorityLevel.MEDIUM

    def test_assign_low_for_tech_debt(self):
        """Tech debt should be LOW"""
        feature = {
            "name": "refactoring",
            "description": "Refactor legacy code for readability"
        }
        priority = assign_priority(feature)
        assert priority == PriorityLevel.LOW


class TestWorkloadCalculation:
    """Test workload calculation and assignment"""

    def test_calculate_workload_with_weighted_features(self):
        """Workload should be weighted by priority"""
        pending_features = [
            {"priority": PriorityLevel.CRITICAL},  # Weight: 10
            {"priority": PriorityLevel.HIGH},      # Weight: 5
            {"priority": PriorityLevel.MEDIUM}     # Weight: 2
        ]
        workload = calculate_workload(pending_features)
        assert workload == 17  # 10 + 5 + 2

    def test_calculate_empty_workload(self):
        """Empty workload should be 0"""
        workload = calculate_workload([])
        assert workload == 0

    def test_assign_to_least_loaded_instance(self):
        """Feature should be assigned to least-loaded instance"""
        instances = {
            "Dev-A": [{"priority": PriorityLevel.MEDIUM}],  # Weight: 2
            "Dev-B": [{"priority": PriorityLevel.HIGH}]     # Weight: 5
        }
        feature = {"name": "new_feature", "priority": PriorityLevel.MEDIUM}
        assigned_instance = assign_feature(feature, "Developer", instances)
        assert assigned_instance == "Dev-A"  # Least loaded

    def test_assign_to_idle_instance(self):
        """If one instance is idle, assign there"""
        instances = {
            "Dev-A": [{"priority": PriorityLevel.CRITICAL}],  # Weight: 10
            "Dev-B": []  # Weight: 0 (idle)
        }
        feature = {"name": "new_feature", "priority": PriorityLevel.MEDIUM}
        assigned_instance = assign_feature(feature, "Developer", instances)
        assert assigned_instance == "Dev-B"  # Idle instance


class TestPreemption:
    """Test work preemption rules"""

    def test_critical_preempts_medium_work(self):
        """CRITICAL should preempt MEDIUM work"""
        critical_feature = {"priority": PriorityLevel.CRITICAL}
        current_work = {"priority": PriorityLevel.MEDIUM}
        result = handle_preemption(critical_feature, current_work)
        assert result["preempt"] is True
        assert result["grace_period_minutes"] == 15

    def test_critical_preempts_low_work(self):
        """CRITICAL should preempt LOW work"""
        critical_feature = {"priority": PriorityLevel.CRITICAL}
        current_work = {"priority": PriorityLevel.LOW}
        result = handle_preemption(critical_feature, current_work)
        assert result["preempt"] is True
        assert result["grace_period_minutes"] == 15

    def test_critical_does_not_preempt_high(self):
        """CRITICAL should NOT preempt HIGH work"""
        critical_feature = {"priority": PriorityLevel.CRITICAL}
        current_work = {"priority": PriorityLevel.HIGH}
        result = handle_preemption(critical_feature, current_work)
        assert result["preempt"] is False

    def test_high_preempts_low_work(self):
        """HIGH should preempt LOW work"""
        high_feature = {"priority": PriorityLevel.HIGH}
        current_work = {"priority": PriorityLevel.LOW}
        result = handle_preemption(high_feature, current_work)
        assert result["preempt"] is True
        assert result["grace_period_minutes"] == 30

    def test_high_does_not_preempt_medium(self):
        """HIGH should NOT preempt MEDIUM work"""
        high_feature = {"priority": PriorityLevel.HIGH}
        current_work = {"priority": PriorityLevel.MEDIUM}
        result = handle_preemption(high_feature, current_work)
        assert result["preempt"] is False

    def test_medium_never_preempts(self):
        """MEDIUM should never preempt any work"""
        medium_feature = {"priority": PriorityLevel.MEDIUM}
        current_work = {"priority": PriorityLevel.LOW}
        result = handle_preemption(medium_feature, current_work)
        assert result["preempt"] is False


class TestSLATracking:
    """Test SLA violation detection"""

    def test_critical_sla_violation_after_4_hours(self):
        """CRITICAL feature SLA violated after 4 hours"""
        feature = {
            "priority": PriorityLevel.CRITICAL,
            "assigned_timestamp": datetime.now() - timedelta(hours=5)
        }
        violation = check_sla_violation(feature)
        assert violation["violated"] is True
        assert violation["sla_hours"] == 4
        assert violation["urgency"] == "HIGH"

    def test_critical_sla_not_violated_within_4_hours(self):
        """CRITICAL feature within SLA if <4 hours"""
        feature = {
            "priority": PriorityLevel.CRITICAL,
            "assigned_timestamp": datetime.now() - timedelta(hours=3)
        }
        violation = check_sla_violation(feature)
        assert violation["violated"] is False

    def test_high_sla_violation_after_24_hours(self):
        """HIGH feature SLA violated after 24 hours"""
        feature = {
            "priority": PriorityLevel.HIGH,
            "assigned_timestamp": datetime.now() - timedelta(hours=25)
        }
        violation = check_sla_violation(feature)
        assert violation["violated"] is True
        assert violation["sla_hours"] == 24

    def test_medium_no_strict_sla(self):
        """MEDIUM features have no strict SLA"""
        feature = {
            "priority": PriorityLevel.MEDIUM,
            "assigned_timestamp": datetime.now() - timedelta(days=20)
        }
        violation = check_sla_violation(feature)
        assert violation["violated"] is False  # No strict SLA


class TestPriorityQueue:
    """Test priority queue management"""

    def test_add_feature_to_queue(self):
        """Features should be added to correct priority queue"""
        queue = FeaturePriorityQueue()
        queue.add_feature({"name": "critical_fix", "priority": PriorityLevel.CRITICAL})
        assert queue.get_queue_depth() == 1

    def test_get_next_feature_returns_critical_first(self):
        """Critical features should be returned first"""
        queue = FeaturePriorityQueue()
        queue.add_feature({"name": "low_task", "priority": PriorityLevel.LOW})
        queue.add_feature({"name": "critical_fix", "priority": PriorityLevel.CRITICAL})
        queue.add_feature({"name": "medium_feat", "priority": PriorityLevel.MEDIUM})

        next_feature = queue.get_next_feature()
        assert next_feature["name"] == "critical_fix"

    def test_fifo_within_same_priority(self):
        """Within same priority, FIFO order"""
        queue = FeaturePriorityQueue()
        queue.add_feature({"name": "medium_1", "priority": PriorityLevel.MEDIUM})
        queue.add_feature({"name": "medium_2", "priority": PriorityLevel.MEDIUM})

        first = queue.get_next_feature()
        second = queue.get_next_feature()
        assert first["name"] == "medium_1"
        assert second["name"] == "medium_2"

    def test_priority_breakdown(self):
        """Should return count by priority"""
        queue = FeaturePriorityQueue()
        queue.add_feature({"name": "c1", "priority": PriorityLevel.CRITICAL})
        queue.add_feature({"name": "c2", "priority": PriorityLevel.CRITICAL})
        queue.add_feature({"name": "h1", "priority": PriorityLevel.HIGH})

        breakdown = queue.get_priority_breakdown()
        assert breakdown[PriorityLevel.CRITICAL] == 2
        assert breakdown[PriorityLevel.HIGH] == 1
        assert breakdown[PriorityLevel.MEDIUM] == 0
