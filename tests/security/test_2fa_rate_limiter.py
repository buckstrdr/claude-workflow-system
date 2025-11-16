"""Test suite for 2FA rate limiting."""
import pytest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))
from security.two_fa_rate_limiter import attempt_2fa, reset_failures, LockoutStatus

class TestProgressiveLockout:
    def test_3_failures_triggers_cooldown(self):
        for _ in range(2):
            attempt_2fa("user1", success=False)
        result = attempt_2fa("user1", success=False)  # 3rd failure
        assert result["lockout_status"] == LockoutStatus.COOLDOWN

    def test_5_failures_triggers_extended_lockout(self):
        for _ in range(4):
            attempt_2fa("user2", success=False)
        result = attempt_2fa("user2", success=False)  # 5th failure
        assert result["lockout_status"] == LockoutStatus.EXTENDED_LOCKOUT

    def test_10_failures_triggers_admin_intervention(self):
        for _ in range(9):
            attempt_2fa("user3", success=False)
        result = attempt_2fa("user3", success=False)  # 10th failure
        assert result["lockout_status"] == LockoutStatus.ADMIN_REQUIRED

class TestRateLimiting:
    def test_success_resets_counter(self):
        attempt_2fa("user4", success=False)
        attempt_2fa("user4", success=False)
        attempt_2fa("user4", success=True)
        result = attempt_2fa("user4", success=False)
        assert result["failure_count"] == 1  # Reset after success
