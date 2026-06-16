import uuid
from datetime import datetime
from typing import Optional

from app.core.exercise_validator import MultiSideValidator
from app.core.exercise_correction import create_correction
from app.config import EXERCISE_CATALOG


class ExerciseSession:

    def __init__(self, exercise_id: str, user_id: str, user_gender: str = 'female', target_sets: int = 3, target_reps: int = 10):
        info = EXERCISE_CATALOG.get(exercise_id)
        if not info:
            raise ValueError(f"Unknown exercise ID: {exercise_id}")

        self.session_key = str(uuid.uuid4())[:8]
        self.user_id = user_id
        self.exercise_id = exercise_id
        self.exercise_key = info["key"]
        self.exercise_name = info["name"]
        self.target_sets = target_sets
        self.target_reps = target_reps
        self.current_set = 1
        self.completed_sets = 0
        self.is_complete = False
        self.started_at = datetime.utcnow().isoformat()
        self.completed_at: Optional[str] = None
        self.validator = MultiSideValidator(self.exercise_key, confidence_threshold=0.5)
        self.correction = create_correction(voice_enabled=False, cooldown=10.0, voice_gender=user_gender)

    def reset_set(self):
        self.validator.reset()
        self.correction.reset()

    def reset_all(self):
        self.current_set = 1
        self.completed_sets = 0
        self.is_complete = False
        self.completed_at = None
        self.validator.reset()
        self.correction.reset()

    def check_set_complete(self) -> bool:
        return self.validator.get_total_reps() >= self.target_reps

    def advance_set(self):
        self.completed_sets += 1
        if self.completed_sets >= self.target_sets:
            self.is_complete = True
            self.completed_at = datetime.utcnow().isoformat()
        else:
            self.current_set += 1
            self.reset_set()

    def to_dict(self) -> dict:
        return {
            "session_key": self.session_key,
            "user_id": self.user_id,
            "exercise_id": self.exercise_id,
            "exercise_name": self.exercise_name,
            "target_sets": self.target_sets,
            "target_reps": self.target_reps,
            "current_set": self.current_set,
            "completed_sets": self.completed_sets,
            "current_reps": self.validator.get_total_reps(),
            "is_complete": self.is_complete,
            "started_at": self.started_at,
            "completed_at": self.completed_at,
        }
