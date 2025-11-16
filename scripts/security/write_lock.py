"""Priority-based write lock system with preemption."""
from enum import Enum
from typing import Dict, Any, List
import json
from pathlib import Path
from datetime import datetime, timedelta

class LockPriority(Enum):
    CRITICAL = 0
    HIGH = 1
    MEDIUM = 2
    LOW = 3

LOCK_STATE_FILE = Path(".git/audit/write-lock-state.json")
GRACE_PERIODS = {LockPriority.CRITICAL: 5, LockPriority.HIGH: 15}

def can_preempt_lock(requesting: LockPriority, current: LockPriority) -> bool:
    """Determine if requesting priority can preempt current lock."""
    if requesting == LockPriority.CRITICAL and current in [LockPriority.MEDIUM, LockPriority.LOW]:
        return True
    elif requesting == LockPriority.HIGH and current == LockPriority.LOW:
        return True
    return False

def request_write_lock(requester: str, files: List[str], priority: LockPriority, estimated_time: int) -> Dict[str, Any]:
    """Request write lock with priority."""
    state = _load_state()
    if state["current_lock"] is None:
        _grant_lock(state, requester, files, priority, estimated_time)
        return {"status": "GRANTED"}
    return {"status": "QUEUED"}

def queue_with_priority(requester: str, files: List[str], priority: LockPriority, estimated_time: int) -> Dict[str, Any]:
    """Queue request with priority ordering."""
    state = _load_state()
    request = {"requester": requester, "files": files, "priority": priority.name, "estimated_time": estimated_time}
    insert_index = 0
    for i, q in enumerate(state["queue"]):
        if LockPriority[q["priority"]].value > priority.value:
            break
        insert_index = i + 1
    state["queue"].insert(insert_index, request)
    _save_state(state)
    return {"position": insert_index, "priority": priority.name}

def _load_state() -> Dict[str, Any]:
    LOCK_STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    if LOCK_STATE_FILE.exists():
        return json.loads(LOCK_STATE_FILE.read_text())
    return {"current_lock": None, "queue": [], "history": []}

def _save_state(state: Dict[str, Any]) -> None:
    LOCK_STATE_FILE.write_text(json.dumps(state, indent=2))

def _grant_lock(state: Dict[str, Any], requester: str, files: List[str], priority: LockPriority, estimated_time: int) -> None:
    state["current_lock"] = {"holder": requester, "files": files, "priority": priority.name,
                            "granted_at": datetime.now().isoformat(), "estimated_time": estimated_time}
    _save_state(state)
