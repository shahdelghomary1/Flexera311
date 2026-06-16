"""
Exercise Counter API
Dedicated API file with all endpoints for exercise counting functionality
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import base64
import io
import cv2
from PIL import Image
import numpy as np

import app.state as state
from app.services.pose_service import decode_base64_frame, run_pose_and_validate
from app.models.session import ExerciseSession
from app.config import EXERCISE_CATALOG


# Pydantic models for API requests/responses
class ExerciseCountRequest(BaseModel):
    exercise_id: str  # "01" to "16" 
    user_id: str
    image_base64: str


class ExerciseCountResponse(BaseModel):
    success: bool
    exercise_id: str
    exercise_name: str
    current_count: int
    message: str
    error: Optional[str] = None


class ExerciseListResponse(BaseModel):
    id: str
    name: str
    category: str
    session: int


class ResetResponse(BaseModel):
    success: bool
    message: str
    exercise_id: str
    user_id: str


class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    active_sessions: int
    version: str


# Create FastAPI app
app = FastAPI(
    title="Exercise Counter API",
    description="Simple exercise counting with camera integration",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Helper functions
# Use existing decode function from pose_service
# def decode_base64_image is now imported as decode_base64_frame


def get_or_create_session(user_id: str, exercise_id: str) -> ExerciseSession:
    """Get existing session or create new one"""
    session_key = f"{user_id}_{exercise_id}_simple"
    
    if session_key not in state.active_sessions:
        try:
            session = ExerciseSession(exercise_id, user_id)
            state.active_sessions[session_key] = session
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid exercise ID: {e}")
    
    return state.active_sessions[session_key]


# API Endpoints

@app.get("/", summary="API Root")
async def root():
    """Root endpoint with basic API information"""
    return {
        "message": "Exercise Counter API",
        "status": "ready",
        "endpoints": {
            "count": "POST /count - Process camera frame and get exercise count",
            "reset": "POST /reset/{user_id}/{exercise_id} - Reset exercise count",
            "exercises": "GET /exercises - List all available exercises",
            "health": "GET /health - API health status"
        }
    }


@app.get("/health", response_model=HealthResponse, summary="API Health Check")
async def health_check():
    """Check API health and model status"""
    return HealthResponse(
        status="healthy" if state.pose_model else "model_not_loaded",
        model_loaded=state.pose_model is not None,
        active_sessions=len(state.active_sessions),
        version="1.0.0"
    )


@app.get("/exercises", response_model=List[ExerciseListResponse], summary="List All Exercises")
async def list_exercises():
    """Get list of all available exercises (01-16)"""
    exercises = []
    for ex_id, info in EXERCISE_CATALOG.items():
        exercises.append(ExerciseListResponse(
            id=ex_id,
            name=info["name"],
            category=info["category"],
            session=info["session"]
        ))
    return exercises


@app.post("/count", response_model=ExerciseCountResponse, summary="Count Exercise Repetitions")
async def count_exercise(request: ExerciseCountRequest):
    """
    Process camera frame and return current exercise count
    
    - **exercise_id**: Exercise ID from "01" to "16"
    - **user_id**: Unique user identifier
    - **image_base64**: Base64 encoded camera frame (JPEG/PNG)
    """
    # Check if model is loaded
    if state.pose_model is None:
        raise HTTPException(status_code=503, detail="AI model is still loading")
    
    # Validate exercise_id
    if request.exercise_id not in EXERCISE_CATALOG:
        raise HTTPException(status_code=400, detail=f"Invalid exercise_id: {request.exercise_id}")
    
    try:
        # Get or create session
        session = get_or_create_session(request.user_id, request.exercise_id)
        
        # Decode image
        frame = decode_base64_frame(request.image_base64)
        
        # Process frame with AI
        result = run_pose_and_validate(frame, session)
        
        # Return response
        return ExerciseCountResponse(
            success=result.get("success", True),
            exercise_id=request.exercise_id,
            exercise_name=session.exercise_name,
            current_count=session.current_reps,
            message=f"Count: {session.current_reps}",
            error=None if result.get("success", True) else "Pose detection failed"
        )
        
    except ValueError as e:
        return ExerciseCountResponse(
            success=False,
            exercise_id=request.exercise_id,
            exercise_name=EXERCISE_CATALOG[request.exercise_id]["name"],
            current_count=0,
            message="Invalid image format",
            error=str(e)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Processing error: {str(e)}")


@app.post("/reset/{user_id}/{exercise_id}", response_model=ResetResponse, summary="Reset Exercise Count")
async def reset_exercise_count(user_id: str, exercise_id: str):
    """
    Reset exercise count to zero for specific user and exercise
    
    - **user_id**: User identifier
    - **exercise_id**: Exercise ID from "01" to "16"
    """
    # Validate exercise_id
    if exercise_id not in EXERCISE_CATALOG:
        raise HTTPException(status_code=400, detail=f"Invalid exercise_id: {exercise_id}")
    
    session_key = f"{user_id}_{exercise_id}_simple"
    
    # Remove session if exists
    if session_key in state.active_sessions:
        del state.active_sessions[session_key]
    
    return ResetResponse(
        success=True,
        message="Exercise count reset successfully",
        exercise_id=exercise_id,
        user_id=user_id
    )


@app.delete("/sessions/{user_id}", summary="Clear All User Sessions")
async def clear_user_sessions(user_id: str):
    """Clear all active sessions for a specific user"""
    removed_count = 0
    sessions_to_remove = []
    
    for session_key in state.active_sessions.keys():
        if session_key.startswith(f"{user_id}_"):
            sessions_to_remove.append(session_key)
    
    for session_key in sessions_to_remove:
        del state.active_sessions[session_key]
        removed_count += 1
    
    return {
        "success": True,
        "message": f"Cleared {removed_count} sessions for user {user_id}",
        "user_id": user_id,
        "removed_sessions": removed_count
    }


@app.get("/sessions", summary="List Active Sessions")
async def list_active_sessions():
    """List all currently active exercise sessions"""
    sessions = []
    for session_key, session in state.active_sessions.items():
        sessions.append({
            "session_key": session_key,
            "user_id": session.user_id,
            "exercise_id": session.exercise_id,
            "exercise_name": session.exercise_name,
            "current_count": session.current_reps,
            "started_at": session.started_at.isoformat() if hasattr(session, 'started_at') else None
        })
    
    return {
        "active_sessions": len(sessions),
        "sessions": sessions
    }


# Model loading event
@app.on_event("startup")
async def load_ai_model():
    """Load YOLOv8 pose detection model on startup"""
    try:
        from ultralytics import YOLO
        print("[Exercise Counter API] Loading YOLOv8n-pose model...")
        state.pose_model = YOLO("yolov8n-pose.pt")
        state.pose_model.to("cpu")
        print("[Exercise Counter API] ✅ Model loaded successfully!")
    except Exception as e:
        print(f"[Exercise Counter API] ❌ Failed to load model: {e}")
        state.pose_model = None


@app.on_event("shutdown")
async def cleanup():
    """Cleanup on shutdown"""
    print("[Exercise Counter API] Shutting down...")
    state.active_sessions.clear()
    print("[Exercise Counter API] ✅ Cleanup completed")


if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting Exercise Counter API...")
    print("📱 API docs: http://localhost:8000/docs")
    print("🔄 Health check: http://localhost:8000/health")
    print("📋 Exercises: http://localhost:8000/exercises")
    
    uvicorn.run(
        "exercise_api:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )