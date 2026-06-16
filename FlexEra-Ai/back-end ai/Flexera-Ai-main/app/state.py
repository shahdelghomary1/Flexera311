from typing import Dict, TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.session import ExerciseSession

pose_model = None
active_sessions: Dict[str, "ExerciseSession"] = {}
