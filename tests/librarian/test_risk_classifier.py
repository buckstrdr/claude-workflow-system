"""
Test suite for Librarian risk classification system.

Tests the 4-tier risk classification (LOW/MEDIUM/HIGH/CRITICAL) and auto-approval logic.
"""

import pytest
import sys
from pathlib import Path

# Add scripts to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))

from librarian.risk_classifier import (
    RiskTier,
    classify_request_risk,
    auto_approve_eligible,
    process_co_signature_request
)


class TestRiskClassification:
    """Test risk tier classification logic"""

    def test_classify_emergency_bypass_as_critical(self):
        """Emergency bypass requests must be CRITICAL tier"""
        request = {
            "type": "EMERGENCY_BYPASS",
            "files": "src/normal.py",
            "total_loc": 10,
            "gate": "RED_TO_GREEN"
        }
        assert classify_request_risk(request) == RiskTier.CRITICAL

    def test_classify_auth_changes_as_high(self):
        """Changes to authentication code must be HIGH risk"""
        request = {
            "type": "GATE_TRANSITION",
            "files": "src/auth/login.py",
            "total_loc": 50,
            "gate": "RED_TO_GREEN"
        }
        assert classify_request_risk(request) == RiskTier.HIGH

    def test_classify_payment_changes_as_high(self):
        """Changes to payment code must be HIGH risk"""
        request = {
            "type": "GATE_TRANSITION",
            "files": "src/payment/processor.py",
            "total_loc": 30,
            "gate": "GREEN_TO_PEER"
        }
        assert classify_request_risk(request) == RiskTier.HIGH

    def test_classify_security_changes_as_high(self):
        """Changes to security code must be HIGH risk"""
        request = {
            "type": "GATE_TRANSITION",
            "files": "src/security/encryption.py",
            "total_loc": 75,
            "gate": "RED_TO_GREEN"
        }
        assert classify_request_risk(request) == RiskTier.HIGH

    def test_classify_large_changes_as_high(self):
        """Changes >200 LOC must be HIGH risk regardless of area"""
        request = {
            "type": "GATE_TRANSITION",
            "files": "src/utils/helpers.py",
            "total_loc": 250,
            "gate": "GREEN_TO_PEER"
        }
        assert classify_request_risk(request) == RiskTier.HIGH

    def test_classify_small_feature_as_low(self):
        """Small features (<50 LOC, gate 1→2) should be LOW risk"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30
        }
        assert classify_request_risk(request) == RiskTier.LOW

    def test_classify_medium_feature_as_medium(self):
        """Medium features (50-200 LOC, gate 2→3) should be MEDIUM risk"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "GREEN_TO_PEER",
            "files": "src/services/api.py",
            "total_loc": 150
        }
        assert classify_request_risk(request) == RiskTier.MEDIUM


class TestAutoApproval:
    """Test auto-approval eligibility logic"""

    def test_critical_tier_never_auto_approved(self):
        """CRITICAL tier requests must never be auto-approved"""
        request = {
            "type": "EMERGENCY_BYPASS",
            "files": "src/normal.py",
            "total_loc": 10,
            "gate": "RED_TO_GREEN",
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.85,
            "security_clean": True
        }
        risk_tier = classify_request_risk(request)
        assert risk_tier == RiskTier.CRITICAL
        assert auto_approve_eligible(request, risk_tier) == False

    def test_high_tier_never_auto_approved(self):
        """HIGH tier requests must never be auto-approved"""
        request = {
            "type": "GATE_TRANSITION",
            "files": "src/auth/login.py",
            "total_loc": 50,
            "gate": "RED_TO_GREEN",
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.90,
            "security_clean": True
        }
        risk_tier = classify_request_risk(request)
        assert risk_tier == RiskTier.HIGH
        assert auto_approve_eligible(request, risk_tier) == False

    def test_low_tier_auto_approved_when_checks_pass(self):
        """LOW tier auto-approves when all checks pass"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30,
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.85,
            "security_clean": True
        }
        risk_tier = classify_request_risk(request)
        assert risk_tier == RiskTier.LOW
        assert auto_approve_eligible(request, risk_tier) == True

    def test_medium_tier_auto_approved_when_checks_pass(self):
        """MEDIUM tier auto-approves when all checks pass"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "GREEN_TO_PEER",
            "files": "src/services/api.py",
            "total_loc": 150,
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.82,
            "security_clean": True
        }
        risk_tier = classify_request_risk(request)
        assert risk_tier == RiskTier.MEDIUM
        assert auto_approve_eligible(request, risk_tier) == True

    def test_auto_approval_fails_without_signoffs(self):
        """Auto-approval requires all signoffs present"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30,
            "signoffs_present": False,  # Missing signoffs
            "tests_passing": True,
            "coverage": 0.85,
            "security_clean": True
        }
        risk_tier = classify_request_risk(request)
        assert auto_approve_eligible(request, risk_tier) == False

    def test_auto_approval_fails_with_failing_tests(self):
        """Auto-approval requires tests passing"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30,
            "signoffs_present": True,
            "tests_passing": False,  # Tests failing
            "coverage": 0.85,
            "security_clean": True
        }
        risk_tier = classify_request_risk(request)
        assert auto_approve_eligible(request, risk_tier) == False

    def test_auto_approval_fails_with_low_coverage(self):
        """Auto-approval requires >=80% coverage"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30,
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.75,  # Below 80% threshold
            "security_clean": True,
            "requires_coverage": True
        }
        risk_tier = classify_request_risk(request)
        assert auto_approve_eligible(request, risk_tier) == False

    def test_auto_approval_fails_with_security_issues(self):
        """Auto-approval requires clean security scan"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30,
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.85,
            "security_clean": False  # Security issues found
        }
        risk_tier = classify_request_risk(request)
        assert auto_approve_eligible(request, risk_tier) == False


class TestWorkflowIntegration:
    """Test complete co-signature processing workflow"""

    def test_critical_request_triggers_manual_review(self):
        """CRITICAL requests must trigger manual review + user notification"""
        request = {
            "type": "EMERGENCY_BYPASS",
            "files": "src/normal.py",
            "total_loc": 10,
            "gate": "RED_TO_GREEN"
        }
        result = process_co_signature_request(request)
        assert result["status"] == "PENDING_MANUAL_REVIEW"
        assert result["reason"] == "CRITICAL_TIER"
        assert result["user_notified"] == True

    def test_high_request_triggers_manual_review(self):
        """HIGH requests must trigger manual review"""
        request = {
            "type": "GATE_TRANSITION",
            "files": "src/auth/login.py",
            "total_loc": 50,
            "gate": "RED_TO_GREEN"
        }
        result = process_co_signature_request(request)
        assert result["status"] == "PENDING_MANUAL_REVIEW"
        assert result["reason"] == "HIGH_TIER"

    def test_low_request_auto_approved(self):
        """LOW requests auto-approve when checks pass"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30,
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.85,
            "security_clean": True
        }
        result = process_co_signature_request(request)
        assert result["status"] == "AUTO_APPROVED"
        assert result["risk_tier"] == "LOW"
        assert isinstance(result["spot_check_scheduled"], bool)

    def test_medium_request_auto_approved(self):
        """MEDIUM requests auto-approve when checks pass"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "GREEN_TO_PEER",
            "files": "src/services/api.py",
            "total_loc": 150,
            "signoffs_present": True,
            "tests_passing": True,
            "coverage": 0.82,
            "security_clean": True
        }
        result = process_co_signature_request(request)
        assert result["status"] == "AUTO_APPROVED"
        assert result["risk_tier"] == "MEDIUM"
        assert isinstance(result["spot_check_scheduled"], bool)

    def test_low_request_manual_review_on_failed_checks(self):
        """LOW requests fall back to manual review if checks fail"""
        request = {
            "type": "GATE_TRANSITION",
            "gate": "RED_TO_GREEN",
            "files": "src/utils/formatter.py",
            "total_loc": 30,
            "signoffs_present": True,
            "tests_passing": False,  # Failed check
            "coverage": 0.85,
            "security_clean": True
        }
        result = process_co_signature_request(request)
        assert result["status"] == "PENDING_MANUAL_REVIEW"
        assert result["reason"] == "AUTO_APPROVAL_FAILED"
