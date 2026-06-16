from typing import Optional, List, Literal
from pydantic import BaseModel, Field


class SessionStartRequest(BaseModel):
    exercise_id: str = Field(..., description="Exercise ID (01-16)")
    user_id: str = Field(..., description="Flutter app user ID")
    user_gender: Literal["male", "female"] = Field("female", description="User gender: 'male' or 'female'")
    target_sets: int = Field(3, ge=1, le=20, description="Number of sets to complete")
    target_reps: int = Field(10, ge=1, le=100, description="Reps per set")


class SessionStatusResponse(BaseModel):
    session_key: str
    user_id: str
    exercise_id: str
    exercise_name: str
    target_sets: int
    target_reps: int
    current_set: int
    completed_sets: int
    current_reps: int
    is_complete: bool
    started_at: str
    completed_at: Optional[str]


class FrameProcessRequest(BaseModel):
    session_key: str = Field(..., description="Active session key")
    image_base64: str = Field(..., description="Base64 encoded JPEG/PNG frame")


class FrameProcessResponse(BaseModel):
    success: bool
    session_key: str
    current_reps: int
    target_reps: int
    current_set: int
    completed_sets: int
    target_sets: int
    set_complete: bool
    exercise_complete: bool
    left_angle: float
    right_angle: float
    is_valid_form: bool
    feedback: str
    active_side: str
    rep_state: str
    keypoints: Optional[List[List[float]]] = None


class ExerciseListItem(BaseModel):
    id: str
    name: str
    key: str
    category: str
    session: int
    image: str


class ExerciseDetailResponse(BaseModel):
    id: str
    name: str
    key: str
    category: str
    session: int
    image: str
    instructions: dict
    camera_config: dict
    rules: Optional[dict] = None


class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    active_sessions: int
    version: str
    timestamp: str
