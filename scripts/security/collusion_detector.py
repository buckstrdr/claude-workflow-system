"""Enhanced collusion detection with 5-review window and 90% threshold."""
from enum import Enum
from typing import Dict, Any
import json
from pathlib import Path
from datetime import datetime

class SeverityLevel(Enum):
    WARNING = "WARNING"
    CRITICAL = "CRITICAL"

COLLUSION_THRESHOLD = 0.90
REVIEW_WINDOW = 5

def detect_collusion(author: str, reviewer: str, approve_count: int, window_reviews: int, consecutive: bool = False) -> Dict[str, Any]:
    """Detect collusion between author and reviewer."""
    if window_reviews == 0:
        return {"collusion_detected": False, "rate": 0.0}

    rate = approve_count / window_reviews
    detected = rate > COLLUSION_THRESHOLD

    if detected:
        severity = SeverityLevel.CRITICAL if consecutive else SeverityLevel.WARNING
        _log_detection(author, reviewer, rate, severity)
        return {"collusion_detected": True, "rate": rate, "severity": severity}

    return {"collusion_detected": False, "rate": rate}

def _log_detection(author: str, reviewer: str, rate: float, severity: SeverityLevel) -> None:
    """Log collusion detection to audit trail."""
    log_file = Path(".git/audit/collusion-detections.json")
    log_file.parent.mkdir(parents=True, exist_ok=True)

    entry = {"author": author, "reviewer": reviewer, "approval_rate": rate,
             "severity": severity.value, "timestamp": datetime.now().isoformat()}

    if log_file.exists():
        data = json.loads(log_file.read_text())
    else:
        data = []

    data.append(entry)
    log_file.write_text(json.dumps(data, indent=2))
