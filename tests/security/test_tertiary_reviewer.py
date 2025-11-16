"""Test suite for tertiary reviewer independence."""
import pytest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))
from security.tertiary_reviewer import select_independent_reviewer, track_participation

class TestIndependence:
    def test_excludes_author_and_peer(self):
        reviewer = select_independent_reviewer("Dev-A", "Dev-B", "feature-123")
        assert reviewer not in ["Dev-A", "Dev-B"]

    def test_excludes_feature_participants(self):
        track_participation("feature-123", "Planner-A", "specification")
        track_participation("feature-123", "Architect-B", "architecture")
        reviewer = select_independent_reviewer("Dev-A", "Dev-B", "feature-123")
        assert reviewer not in ["Dev-A", "Dev-B", "Planner-A", "Architect-B"]

class TestParticipationTracking:
    def test_track_multiple_participants(self):
        track_participation("feature-456", "Planner-A", "specification")
        track_participation("feature-456", "Dev-A", "implementation")
        reviewer = select_independent_reviewer("Dev-A", "Dev-B", "feature-456")
        assert reviewer not in ["Dev-A", "Dev-B", "Planner-A"]
