"""Test suite for enhanced collusion detection."""
import pytest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))
from security.collusion_detector import detect_collusion, SeverityLevel

class TestCollusionDetection:
    def test_no_collusion_under_threshold(self):
        result = detect_collusion("Dev-A", "Dev-B", approve_count=3, window_reviews=10)
        assert result["collusion_detected"] is False

    def test_collusion_detected_at_90_percent(self):
        result = detect_collusion("Dev-A", "Dev-B", approve_count=5, window_reviews=5)
        assert result["collusion_detected"] is True
        assert result["severity"] == SeverityLevel.WARNING

    def test_critical_severity_at_100_percent(self):
        result = detect_collusion("Dev-A", "Dev-B", approve_count=5, window_reviews=5, consecutive=True)
        assert result["severity"] == SeverityLevel.CRITICAL

class TestThresholds:
    def test_5_review_window(self):
        result = detect_collusion("Dev-A", "Dev-B", approve_count=5, window_reviews=5)
        assert result["rate"] == 1.0  # 100%

    def test_90_percent_threshold(self):
        result = detect_collusion("Dev-A", "Dev-B", approve_count=9, window_reviews=10)
        assert result["collusion_detected"] is False  # Exactly 90%, no detection
