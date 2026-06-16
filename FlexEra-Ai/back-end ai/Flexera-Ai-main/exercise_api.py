"""
Simple Exercise API for Flutter Integration
Choose Exercise → Press Button → Open Camera → Exercise → Get Numbers
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Optional
import cv2
import numpy as np
import base64
import uuid
from datetime import datetime
import uvicorn

# Import exercise system
from app.core.exercise_rules import EXERCISE_RULES, EXERCISE_INSTRUCTIONS
from app.core.exercise_validator import MultiSideValidator
from app.core.exercise_correction import create_correction
from ultralytics import YOLO

# Simple FastAPI setup
app = FastAPI(title="Exercise API", version="1.0.0")

# CORS for Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables
pose_model = None
current_session = None  # Single session only

# ═══════════════════════════════════════════════════════════════
# SIMPLE MODELS FOR FLUTTER
# ═══════════════════════════════════════════════════════════════

class Exercise(BaseModel):
    key: str
    name: str
    category: str  # "upper_body" or "lower_body"
    side: str      # "left" or "right"

class StartExerciseRequest(BaseModel):
    exercise_key: str

class CameraFrameRequest(BaseModel):
    image_base64: str

class ExerciseResult(BaseModel):
    total_reps: int
    left_reps: int
    right_reps: int
    current_angle: float
    is_valid: bool
    feedback: str
    status: str  # "exercising", "good_form", "bad_form", "no_person"

# ═══════════════════════════════════════════════════════════════
# STARTUP
# ═══════════════════════════════════════════════════════════════

@app.on_event("startup")
async def startup_event():
    global pose_model
    try:
        pose_model = YOLO('yolov8n-pose.pt')
        pose_model.to('cpu')
        print("🚀 Simple Exercise API Started!")
        print("📱 Ready for Flutter: http://localhost:8000")
    except Exception as e:
        print(f"❌ Model loading failed: {e}")

# ═══════════════════════════════════════════════════════════════
# SIMPLE ENDPOINTS FOR FLUTTER
# ═══════════════════════════════════════════════════════════════

@app.get("/")
async def root():
    return {"message": "Exercise API Ready for Flutter!", "status": "ok"}

@app.get("/exercises", response_model=List[Exercise])
async def get_all_exercises():
    """
    STEP 1: Get list of all 16 exercises for Flutter to display
    """
    exercises = []
    
    for key in EXERCISE_RULES.keys():
        instructions = EXERCISE_INSTRUCTIONS.get(key, {})
        
        exercises.append(Exercise(
            key=key,
            name=instructions.get("name", key),
            category=_get_category(key),
            side=_get_side(key)
        ))
    
    return exercises

@app.post("/start-exercise")
async def start_exercise(request: StartExerciseRequest):
    """
    STEP 2: Start exercise when Flutter user presses button
    """
    global current_session
    
    if request.exercise_key not in EXERCISE_RULES:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    # Create new session (replace any existing one)
    current_session = {
        "exercise_key": request.exercise_key,
        "exercise_name": EXERCISE_INSTRUCTIONS.get(request.exercise_key, {}).get("name", request.exercise_key),
        "validator": MultiSideValidator(request.exercise_key, confidence_threshold=0.5),
        "correction": create_correction(voice_enabled=False),
        "started_at": datetime.now()
    }
    
    return {
        "message": "Exercise started! Open camera now.",
        "exercise_name": current_session["exercise_name"],
        "status": "ready_for_camera"
    }

@app.post("/camera-frame", response_model=ExerciseResult)
async def process_camera_frame(request: CameraFrameRequest):
    """
    STEP 3: Process camera frames - send from Flutter camera
    """
    global current_session
    
    if not current_session:
        raise HTTPException(status_code=400, detail="No active exercise session. Call /start-exercise first")
    
    if not pose_model:
        raise HTTPException(status_code=500, detail="AI model not ready")
    
    try:
        # Decode camera image from Flutter
        image_data = base64.b64decode(request.image_base64)
        nparr = np.frombuffer(image_data, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if frame is None:
            return ExerciseResult(
                total_reps=0,
                left_reps=0,
                right_reps=0,
                current_angle=0.0,
                is_valid=False,
                feedback="Invalid camera image",
                status="error"
            )
        
        # Run AI pose detection
        pose_results = pose_model(frame, verbose=False)
        if not pose_results or len(pose_results[0].keypoints.data) == 0:
            return ExerciseResult(
                total_reps=0,
                left_reps=0,
                right_reps=0,
                current_angle=0.0,
                is_valid=False,
                feedback="No person detected in camera",
                status="no_person"
            )
        
        # Get pose keypoints
        keypoints = pose_results[0].keypoints.data[0].cpu().numpy()
        
        # Validate exercise form
        validator = current_session["validator"]
        validation_results = validator.validate_frame(keypoints)
        
        left_result = validation_results['left']
        right_result = validation_results['right']
        
        # Determine active side and get feedback
        if left_result.rep_count > right_result.rep_count:
            active_result = left_result
            active_side = "left"
        else:
            active_result = right_result
            active_side = "right"
        
        # Generate feedback message
        correction = current_session["correction"]
        joint_angles = {f"{active_side}_knee": active_result.current_angle}
        
        feedback_data = correction.provide_feedback(
            exercise_name=current_session["exercise_key"],
            joint_angles=joint_angles,
            current_rep_state="neutral",
            is_valid_motion=active_result.is_valid,
            side=active_side
        )
        
        # Simple status
        if active_result.is_valid:
            status = "good_form"
        else:
            status = "bad_form"
        
        return ExerciseResult(
            total_reps=validator.get_total_reps(),
            left_reps=left_result.rep_count,
            right_reps=right_result.rep_count,
            current_angle=float(active_result.current_angle),
            is_valid=active_result.is_valid,
            feedback=feedback_data.get('recommendation', 'Keep going!'),
            status=status
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Processing failed: {str(e)}")

@app.get("/current-stats")
async def get_current_stats():
    """
    STEP 4: Get final numbers after exercise
    """
    if not current_session:
        raise HTTPException(status_code=400, detail="No active session")
    
    validator = current_session["validator"]
    duration = (datetime.now() - current_session["started_at"]).total_seconds()
    
    return {
        "exercise_name": current_session["exercise_name"],
        "total_reps": validator.get_total_reps(),
        "left_reps": validator.left_validator.rep_count.get('left', 0),
        "right_reps": validator.right_validator.rep_count.get('right', 0),
        "duration_seconds": int(duration),
        "session_active": True
    }

@app.post("/stop-exercise")
async def stop_exercise():
    """
    STEP 5: Stop exercise and clear session
    """
    global current_session
    
    if not current_session:
        raise HTTPException(status_code=400, detail="No active session")
    
    final_stats = {
        "exercise_name": current_session["exercise_name"],
        "total_reps": current_session["validator"].get_total_reps(),
        "left_reps": current_session["validator"].left_validator.rep_count.get('left', 0),
        "right_reps": current_session["validator"].right_validator.rep_count.get('right', 0),
        "duration_seconds": int((datetime.now() - current_session["started_at"]).total_seconds())
    }
    
    current_session = None  # Clear session
    
    return {
        "message": "Exercise completed!",
        "final_stats": final_stats,
        "status": "completed"
    }

# ═══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════

def _get_category(exercise_key: str) -> str:
    """Get exercise category"""
    if any(x in exercise_key for x in ['knee', 'leg', 'hip']):
        return 'lower_body'
    elif any(x in exercise_key for x in ['shoulder', 'arm', 'elbow']):
        return 'upper_body'
    return 'general'

def _get_side(exercise_key: str) -> str:
    """Get exercise side"""
    if 'left' in exercise_key:
        return 'left'
    elif 'right' in exercise_key:
        return 'right'
    return 'bilateral'

# ═══════════════════════════════════════════════════════════════
# RUN SERVER
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("🚀 Starting Simple Exercise API...")
    print("📱 Perfect for Flutter integration!")
    print("🌐 Server: http://localhost:8000")
    print("📚 API Docs: http://localhost:8000/docs")
    
    uvicorn.run(
        "exercise_api:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )