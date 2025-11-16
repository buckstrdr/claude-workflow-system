"""Tertiary reviewer selection with feature participation tracking."""
from typing import List, Optional
import json
import random
from pathlib import Path
from datetime import datetime

PARTICIPANTS_FILE = Path(".git/audit/feature-participants.json")
ALL_REVIEWERS = ["Dev-A", "Dev-B", "QA-A", "QA-B", "Architect-A", "Architect-B", "Architect-C"]

def track_participation(feature_id: str, role: str, contribution: str) -> None:
    """Track role participation in feature."""
    PARTICIPANTS_FILE.parent.mkdir(parents=True, exist_ok=True)

    if PARTICIPANTS_FILE.exists():
        data = json.loads(PARTICIPANTS_FILE.read_text())
    else:
        data = {}

    if feature_id not in data:
        data[feature_id] = {"participants": []}

    data[feature_id]["participants"].append({
        "role": role,
        "contribution": contribution,
        "timestamp": datetime.now().isoformat()
    })

    PARTICIPANTS_FILE.write_text(json.dumps(data, indent=2))

def select_independent_reviewer(author: str, peer: str, feature_id: str) -> str:
    """Select tertiary reviewer independent from feature."""
    excluded = {author, peer}

    # Load feature participants
    if PARTICIPANTS_FILE.exists():
        data = json.loads(PARTICIPANTS_FILE.read_text())
        if feature_id in data:
            for p in data[feature_id]["participants"]:
                excluded.add(p["role"])

    # Select from independent reviewers
    independent = [r for r in ALL_REVIEWERS if r not in excluded]

    if not independent:
        raise ValueError("No independent reviewers available")

    return random.choice(independent)
