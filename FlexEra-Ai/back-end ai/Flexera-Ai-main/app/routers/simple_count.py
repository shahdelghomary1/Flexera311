from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

import app.state as state
from app.services.pose_service import decode_base64_frame, run_pose_and_validate

router = APIRouter(tags=["Simple Count"])


class SimpleCountRequest(BaseModel):
    exercise_id: str  # 01-16
    user_id: str
    image_base64: str


class SimpleCountResponse(BaseModel):
    success: bool
    exercise_name: str
    current_count: int
    message: str


@router.post("/count", response_model=SimpleCountResponse, summary="Simple exercise counting")
async def count_exercise(req: SimpleCountRequest):
    """Simplified endpoint that just returns current exercise count"""
    if state.pose_model is None:
        raise HTTPException(status_code=503, detail="AI model is still loading")

    # Get or create simple session
    session_key = f"{req.user_id}_{req.exercise_id}_simple"
    
    if session_key not in state.active_sessions:
        # Create new session
        from app.models.session import ExerciseSession
        try:
            session = ExerciseSession(req.exercise_id, req.user_id)
            state.active_sessions[session_key] = session
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid exercise ID: {e}")
    
    session = state.active_sessions[session_key]

    try:
        frame = decode_base64_frame(req.image_base64)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image data: {e}")

    raw = run_pose_and_validate(frame, session)
    
    return SimpleCountResponse(
        success=raw["success"],
        exercise_name=session.exercise_name,
        current_count=session.current_reps,
        message=f"Count: {session.current_reps}"
    )


@router.post("/reset/{user_id}/{exercise_id}", summary="Reset exercise count")
async def reset_count(user_id: str, exercise_id: str):
    """Reset the count for a specific exercise"""
    session_key = f"{user_id}_{exercise_id}_simple"
    
    if session_key in state.active_sessions:
        del state.active_sessions[session_key]
    
    return {"message": "Count reset", "session_key": session_key}