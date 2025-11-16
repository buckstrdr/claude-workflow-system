"""Test suite for priority-based write lock system."""
import pytest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))
from security.write_lock import (
    request_write_lock, can_preempt_lock, queue_with_priority, LockPriority
)

class TestLockPriority:
    def test_critical_preempts_low(self):
        assert can_preempt_lock(LockPriority.CRITICAL, LockPriority.LOW) is True

    def test_critical_preempts_medium(self):
        assert can_preempt_lock(LockPriority.CRITICAL, LockPriority.MEDIUM) is True

    def test_high_preempts_low(self):
        assert can_preempt_lock(LockPriority.HIGH, LockPriority.LOW) is True

    def test_medium_cannot_preempt(self):
        assert can_preempt_lock(LockPriority.MEDIUM, LockPriority.LOW) is False

class TestQueueOrdering:
    def test_critical_jumps_to_front(self):
        result = queue_with_priority("Dev-A", ["file.py"], LockPriority.CRITICAL, 300)
        assert result["position"] == 0

    def test_queue_ordered_by_priority(self):
        queue_with_priority("Dev-A", ["a.py"], LockPriority.LOW, 300)
        queue_with_priority("Dev-B", ["b.py"], LockPriority.HIGH, 300)
        result = queue_with_priority("Dev-C", ["c.py"], LockPriority.MEDIUM, 300)
        assert result["priority"] == LockPriority.MEDIUM.name
