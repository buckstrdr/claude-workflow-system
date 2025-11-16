"""2FA rate limiting with progressive lockout."""
from enum import Enum
from typing import Dict, Any
import json
from pathlib import Path
from datetime import datetime, timedelta

class LockoutStatus(Enum):
    OK = "OK"
    COOLDOWN = "COOLDOWN"              # 3 failures
    EXTENDED_LOCKOUT = "EXTENDED_LOCKOUT"  # 5 failures
    ADMIN_REQUIRED = "ADMIN_REQUIRED"  # 10 failures

STATE_FILE = Path(".git/audit/2fa-attempts.json")
LOCKOUT_THRESHOLDS = {3: LockoutStatus.COOLDOWN, 5: LockoutStatus.EXTENDED_LOCKOUT, 10: LockoutStatus.ADMIN_REQUIRED}

def attempt_2fa(user: str, success: bool) -> Dict[str, Any]:
    """Record 2FA attempt and enforce rate limiting."""
    state = _load_state()

    if user not in state:
        state[user] = {"failures": 0, "last_attempt": None}

    user_state = state[user]

    if success:
        user_state["failures"] = 0  # Reset on success
        status = LockoutStatus.OK
    else:
        user_state["failures"] += 1
        status = _determine_lockout_status(user_state["failures"])

    user_state["last_attempt"] = datetime.now().isoformat()
    state[user] = user_state
    _save_state(state)

    return {"lockout_status": status, "failure_count": user_state["failures"]}

def reset_failures(user: str) -> None:
    """Reset failure count for user (admin action)."""
    state = _load_state()
    if user in state:
        state[user]["failures"] = 0
        _save_state(state)

def _determine_lockout_status(failures: int) -> LockoutStatus:
    """Determine lockout status based on failure count."""
    for threshold, status in sorted(LOCKOUT_THRESHOLDS.items(), reverse=True):
        if failures >= threshold:
            return status
    return LockoutStatus.OK

def _load_state() -> Dict[str, Any]:
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    if STATE_FILE.exists():
        return json.loads(STATE_FILE.read_text())
    return {}

def _save_state(state: Dict[str, Any]) -> None:
    STATE_FILE.write_text(json.dumps(state, indent=2))
