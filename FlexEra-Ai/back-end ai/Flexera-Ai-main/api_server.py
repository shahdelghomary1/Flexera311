"""
FlexEra Exercise AI API
=======================
FastAPI backend for real-time exercise validation using YOLOv8 pose detection.
Designed for direct integration with the FlexEra Flutter app.

Run:
    uvicorn api_server:app --host 0.0.0.0 --port 8000 --reload

Flutter Base URL:
    http://<your-server-ip>:8000
"""

import cv2
import numpy as np
import base64
import json
import uuid
import asyncio
from datetime import datetime
from typing import Optional, List, Dict, Any

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from ultralytics import YOLO

from exercise_validator import MultiSideValidator, ExerciseState
from exercise_correction import create_correction
from exercise_rules import EXERCISE_RULES, EXERCISE_INSTRUCTIONS, EXERCISE_CAMERA_CONFIG


# ---------------------------------------------------------------------------
# App Setup
# ---------------------------------------------------------------------------

app = FastAPI(
    title="FlexEra Exercise AI API",
    description="Real-time exercise validation using YOLOv8 pose detection for the FlexEra physiotherapy app",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Global State
# ---------------------------------------------------------------------------

pose_model: Optional[YOLO] = None

# Maps exercise_id -> metadata (matches Flutter's category naming)
EXERCISE_CATALOG: Dict[str, dict] = {
    "01": {
        "key": "bending_knee_no_support_seated",
        "name": "Bending the knee without support while sitting",
        "category": "lower_left",
        "session": 1,
        "image": "assets/images/Bending the knee without support while sitting.png",
    },
    "02": {
        "key": "bending_knee_with_support_seated",
        "name": "Bending the knee with support while sitting",
        "category": "lower_right",
        "session": 1,
        "image": "assets/images/Bending the knee with support while sitting.png",
    },
    "03": {
        "key": "lift_extended_leg_supine",
        "name": "Lift the extended leg",
        "category": "lower_left",
        "session": 1,
        "image": "assets/images/Lift the extended leg.png",
    },
    "04": {
        "key": "bending_knee_bed_support_supine",
        "name": "Bending the knee with bed support",
        "category": "lower_right",
        "session": 1,
        "image": "assets/images/Bending the knee with bed support.png",
    },
    "05": {
        "key": "bending_knee_no_support_seated",
        "name": "Bending the knee without support while sitting",
        "category": "lower_left",
        "session": 2,
        "image": "assets/images/Bending the knee without support while sitting.png",
    },
    "06": {
        "key": "bending_knee_with_support_seated",
        "name": "Bending the knee with support while sitting",
        "category": "lower_right",
        "session": 2,
        "image": "assets/images/Bending the knee with support while sitting.png",
    },
    "07": {
        "key": "lift_extended_leg_supine",
        "name": "Lift the extended leg",
        "category": "lower_left",
        "session": 2,
        "image": "assets/images/Lift the extended leg.png",
    },
    "08": {
        "key": "bending_knee_bed_support_supine",
        "name": "Bending the knee with bed support",
        "category": "lower_right",
        "session": 2,
        "image": "assets/images/Bending the knee with bed support.png",
    },
    "09": {
        "key": "shoulder_flexion_seated",
        "name": "Shoulder flexion",
        "category": "upper_left",
        "session": 1,
        "image": "assets/images/Shoulder flexion seated.png",
    },
    "10": {
        "key": "horizontal_weighted_openings_standing",
        "name": "Horizontal weighted openings",
        "category": "upper_right",
        "session": 1,
        "image": "assets/images/Horizontal weighted openings standing.png",
    },
    "11": {
        "key": "external_rotation_shoulders_elastic",
        "name": "External rotation of shoulders with elastic band",
        "category": "upper_left",
        "session": 1,
        "image": "assets/images/External rotation of shoulders with elastic band.png",
    },
    "12": {
        "key": "circular_pendulum_standing",
        "name": "Circular pendulum",
        "category": "upper_right",
        "session": 1,
        "image": "assets/images/Circular pendulum standing.png",
    },
    "13": {
        "key": "shoulder_flexion_seated",
        "name": "Shoulder flexion",
        "category": "upper_left",
        "session": 2,
        "image": "assets/images/Shoulder flexion seated.png",
    },
    "14": {
        "key": "horizontal_weighted_openings_standing",
        "name": "Horizontal weighted openings",
        "category": "upper_right",
        "session": 2,
        "image": "assets/images/Horizontal weighted openings standing.png",
    },
    "15": {
        "key": "external_rotation_shoulders_elastic",
        "name": "External rotation of shoulders with elastic band",
        "category": "upper_left",
        "session": 2,
        "image": "assets/images/External rotation of shoulders with elastic band.png",
    },
    "16": {
        "key": "circular_pendulum_standing",
        "name": "Circular pendulum",
        "category": "upper_right",
        "session": 2,
        "image": "assets/images/Circular pendulum standing.png",
    },
}

# Active exercise sessions { session_key: ExerciseSession }
active_sessions: Dict[str, "ExerciseSession"] = {}


# ---------------------------------------------------------------------------
# Data Classes
# ---------------------------------------------------------------------------

class ExerciseSession:
    """Tracks a single user's exercise session including progress."""

    def __init__(
        self,
        exercise_id: str,
        user_id: str,
        target_sets: int = 3,
        target_reps: int = 10,
    ):
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
        self.correction = create_correction(voice_enabled=False, cooldown=3.0)

    def reset_set(self):
        """Reset rep counter for the next set."""
        self.validator.reset()
        self.correction.reset()

    def reset_all(self):
        """Reset entire session from the beginning."""
        self.current_set = 1
        self.completed_sets = 0
        self.is_complete = False
        self.completed_at = None
        self.validator.reset()
        self.correction.reset()

    def check_set_complete(self) -> bool:
        """Returns True if the current set's rep target has been reached."""
        return self.validator.get_total_reps() >= self.target_reps

    def advance_set(self):
        """Move to next set or mark exercise as complete."""
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


# ---------------------------------------------------------------------------
# Pydantic Request / Response Models
# ---------------------------------------------------------------------------

class SessionStartRequest(BaseModel):
    exercise_id: str = Field(..., description="Exercise ID (01-16)")
    user_id: str = Field(..., description="Flutter app user ID")
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


# ---------------------------------------------------------------------------
# Startup
# ---------------------------------------------------------------------------

@app.on_event("startup")
async def load_model():
    global pose_model
    print("[FlexEra API] Loading YOLOv8n-pose model...")
    pose_model = YOLO("yolov8n-pose.pt")
    pose_model.to("cpu")
    print("[FlexEra API] Model ready. Server is up.")


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

def decode_image_bytes(img_bytes: bytes) -> np.ndarray:
    """Decode raw JPEG/PNG bytes to an OpenCV image array."""
    nparr = np.frombuffer(img_bytes, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if frame is None:
        raise ValueError("Failed to decode image")
    return frame


def decode_base64_frame(image_base64: str) -> np.ndarray:
    """Decode a base64 string to an OpenCV image array."""
    return decode_image_bytes(base64.b64decode(image_base64))


def run_pose_and_validate(frame: np.ndarray, session: ExerciseSession) -> dict:
    """
    Core logic: run YOLOv8 pose on a frame, validate the exercise,
    and return a structured result dict.
    """
    global pose_model

    results = pose_model(frame, verbose=False)

    if not results or len(results[0].keypoints.data) == 0:
        return {
            "success": False,
            "left_angle": 0.0,
            "right_angle": 0.0,
            "left_reps": 0,
            "right_reps": 0,
            "total_reps": session.validator.get_total_reps(),
            "is_valid": False,
            "feedback": "No person detected - please position yourself in the camera view",
            "active_side": "none",
            "state": "idle",
            "keypoints": None,
        }

    keypoints = results[0].keypoints.data[0].cpu().numpy()
    validation = session.validator.validate_frame(keypoints)

    left = validation["left"]
    right = validation["right"]
    active_side = MultiSideValidator.pick_active_side(left, right)
    active = validation[active_side]

    joint_angles = {
        f"{active_side}_knee": active.current_angle,
        f"{active_side}_shoulder": active.current_angle,
        f"{active_side}_hip": active.current_angle,
        f"{active_side}_elbow": active.current_angle,
    }

    rep_state = "idle" if active.state == ExerciseState.INVALID else active.state.value

    feedback_result = session.correction.provide_feedback(
        exercise_name=session.exercise_key,
        joint_angles=joint_angles,
        current_rep_state=rep_state,
        is_valid_motion=active.is_valid,
        side=active_side,
    )

    return {
        "success": True,
        "left_angle": float(left.current_angle),
        "right_angle": float(right.current_angle),
        "left_reps": int(left.rep_count),
        "right_reps": int(right.rep_count),
        "total_reps": int(session.validator.get_total_reps()),
        "is_valid": bool(active.is_valid),
        "feedback": feedback_result.get("recommendation", "Keep going!"),
        "active_side": active_side,
        "state": rep_state,
        "keypoints": keypoints.tolist(),
    }


def build_frame_response(session: ExerciseSession, raw: dict) -> dict:
    """
    Combine raw pose result with session progress into the final
    Flutter-ready FrameProcessResponse dict.
    """
    set_complete = session.check_set_complete()

    return {
        "success": raw["success"],
        "session_key": session.session_key,
        "current_reps": raw["total_reps"],
        "left_reps": raw.get("left_reps", 0),
        "right_reps": raw.get("right_reps", 0),
        "target_reps": session.target_reps,
        "current_set": session.current_set,
        "completed_sets": session.completed_sets,
        "target_sets": session.target_sets,
        "set_complete": set_complete,
        "exercise_complete": session.is_complete,
        "left_angle": raw["left_angle"],
        "right_angle": raw["right_angle"],
        "is_valid_form": raw["is_valid"],
        "feedback": raw["feedback"],
        "active_side": raw["active_side"],
        "rep_state": raw["state"],
        "keypoints": raw.get("keypoints"),
    }


# ---------------------------------------------------------------------------
# Health & Status
# ---------------------------------------------------------------------------

@app.get("/", summary="Root health check")
async def root():
    return {
        "message": "FlexEra Exercise AI API is running",
        "docs": "/docs",
        "version": "2.0.0",
    }


@app.get("/health", response_model=HealthResponse, summary="Detailed health check")
async def health():
    return HealthResponse(
        status="ok" if pose_model is not None else "model_loading",
        model_loaded=pose_model is not None,
        active_sessions=len(active_sessions),
        version="2.0.0",
        timestamp=datetime.utcnow().isoformat(),
    )


# ---------------------------------------------------------------------------
# Exercise Catalog Endpoints
# ---------------------------------------------------------------------------

@app.get("/exercises", response_model=List[ExerciseListItem], summary="List all exercises")
async def list_exercises():
    """
    Returns all 16 exercises in a format compatible with Flutter's ExerciseItem model.
    Categories match the Flutter app: lower_left, lower_right, upper_left, upper_right.
    """
    return [
        ExerciseListItem(
            id=ex_id,
            name=info["name"],
            key=info["key"],
            category=info["category"],
            session=info["session"],
            image=info["image"],
        )
        for ex_id, info in EXERCISE_CATALOG.items()
    ]


@app.get(
    "/exercises/category/{category}",
    response_model=List[ExerciseListItem],
    summary="Get exercises by category",
)
async def get_exercises_by_category(category: str):
    """
    Filter exercises by Flutter category:
    lower_left | lower_right | upper_left | upper_right | knee | shoulder
    """
    # Support both Flutter-style (lower_left) and simple (knee/shoulder) lookups
    category_map = {
        "knee": ["lower_left", "lower_right"],
        "shoulder": ["upper_left", "upper_right"],
    }
    target_categories = category_map.get(category, [category])

    results = [
        ExerciseListItem(
            id=ex_id,
            name=info["name"],
            key=info["key"],
            category=info["category"],
            session=info["session"],
            image=info["image"],
        )
        for ex_id, info in EXERCISE_CATALOG.items()
        if info["category"] in target_categories
    ]

    if not results:
        raise HTTPException(status_code=404, detail=f"No exercises found for category: {category}")
    return results


@app.get(
    "/exercises/{exercise_id}",
    response_model=ExerciseDetailResponse,
    summary="Get exercise detail",
)
async def get_exercise_detail(exercise_id: str):
    """
    Full exercise info including instructions, camera guidance, and angle rules.
    Use this to populate the ExerciseDetailScreen in Flutter.
    """
    info = EXERCISE_CATALOG.get(exercise_id)
    if not info:
        raise HTTPException(status_code=404, detail=f"Exercise {exercise_id} not found")

    key = info["key"]
    instructions = EXERCISE_INSTRUCTIONS.get(key, {})
    camera_config = EXERCISE_CAMERA_CONFIG.get(key, {})

    # Serialize rules (exclude lambdas)
    raw_rules = EXERCISE_RULES.get(key, {})
    safe_rules: dict = {}
    for k, v in raw_rules.items():
        if k == "errors":
            safe_rules["errors"] = {
                err_name: {
                    "recommendation": err_data["recommendation"],
                    "severity": err_data["severity"],
                }
                for err_name, err_data in v.items()
            }
        elif not callable(v):
            safe_rules[k] = v

    return ExerciseDetailResponse(
        id=exercise_id,
        name=info["name"],
        key=key,
        category=info["category"],
        session=info["session"],
        image=info["image"],
        instructions=instructions,
        camera_config=camera_config,
        rules=safe_rules,
    )


# ---------------------------------------------------------------------------
# Session Management
# ---------------------------------------------------------------------------

@app.post(
    "/session/start",
    response_model=SessionStatusResponse,
    summary="Start an exercise session",
)
async def start_session(req: SessionStartRequest):
    """
    Start a new AI validation session for a user.
    Returns a session_key to use in subsequent /process or WebSocket calls.

    Flutter usage: call this when user taps 'Start Exercise'.
    """
    if req.exercise_id not in EXERCISE_CATALOG:
        raise HTTPException(status_code=404, detail=f"Exercise {req.exercise_id} not found")

    if pose_model is None:
        raise HTTPException(status_code=503, detail="AI model is still loading, try again shortly")

    session = ExerciseSession(
        exercise_id=req.exercise_id,
        user_id=req.user_id,
        target_sets=req.target_sets,
        target_reps=req.target_reps,
    )
    active_sessions[session.session_key] = session

    return SessionStatusResponse(**session.to_dict())


@app.get(
    "/session/{session_key}",
    response_model=SessionStatusResponse,
    summary="Get session progress",
)
async def get_session(session_key: str):
    """Get the current progress of an active exercise session."""
    session = active_sessions.get(session_key)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found or expired")
    return SessionStatusResponse(**session.to_dict())


@app.post(
    "/session/{session_key}/next-set",
    response_model=SessionStatusResponse,
    summary="Advance to next set",
)
async def advance_to_next_set(session_key: str):
    """
    Manually advance the session to the next set (or mark complete).
    Flutter should call this after the user confirms a set is done.
    """
    session = active_sessions.get(session_key)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found or expired")
    if session.is_complete:
        raise HTTPException(status_code=400, detail="Exercise is already complete")

    session.advance_set()
    return SessionStatusResponse(**session.to_dict())


@app.post(
    "/session/{session_key}/reset",
    response_model=SessionStatusResponse,
    summary="Reset session from beginning",
)
async def reset_session(session_key: str):
    """Reset the session back to set 1, rep 0."""
    session = active_sessions.get(session_key)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found or expired")
    session.reset_all()
    return SessionStatusResponse(**session.to_dict())


@app.delete(
    "/session/{session_key}",
    summary="End and remove a session",
)
async def end_session(session_key: str):
    """
    Delete the session when the user exits the exercise screen.
    Flutter should call this in the screen's dispose() method.
    """
    if session_key not in active_sessions:
        raise HTTPException(status_code=404, detail="Session not found or expired")
    del active_sessions[session_key]
    return {"message": "Session ended", "session_key": session_key}


# ---------------------------------------------------------------------------
# Frame Processing - REST (single frame)
# ---------------------------------------------------------------------------

@app.post(
    "/process",
    response_model=FrameProcessResponse,
    summary="Process a single camera frame",
)
async def process_frame(req: FrameProcessRequest):
    """
    Send one base64-encoded camera frame and receive exercise validation feedback.

    For continuous real-time usage prefer the WebSocket endpoint /ws/{session_key}.
    Use this REST endpoint for testing or low-frequency polling.
    """
    if pose_model is None:
        raise HTTPException(status_code=503, detail="AI model is still loading")

    session = active_sessions.get(req.session_key)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found. Call /session/start first.")

    try:
        frame = decode_base64_frame(req.image_base64)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image data: {e}")

    raw = run_pose_and_validate(frame, session)

    # Auto-advance set if rep target hit
    if raw["success"] and session.check_set_complete() and not session.is_complete:
        session.advance_set()

    return FrameProcessResponse(**build_frame_response(session, raw))


# ---------------------------------------------------------------------------
# WebSocket - real-time frame streaming
# ---------------------------------------------------------------------------

@app.websocket("/ws/{session_key}")
async def websocket_endpoint(websocket: WebSocket, session_key: str):
    """
    Real-time exercise validation via WebSocket.

    Frames (preferred — smaller & faster):
        Send raw JPEG/PNG bytes as a binary WebSocket message.

    Legacy frames (still supported):
        { "type": "frame", "data": "<base64_image>" }

    Control messages (JSON text only):
        { "type": "reset" }
        { "type": "ping" }
        { "type": "next_set" }
        { "type": "status" }

    Server responds with FrameProcessResponse JSON.

    Connection URL: ws://<host>:8000/ws/<session_key>
    """
    await websocket.accept()

    session = active_sessions.get(session_key)
    if not session:
        await websocket.send_json({"error": "Session not found. Call POST /session/start first."})
        await websocket.close()
        return

    print(f"[WS] Connected: session={session_key} user={session.user_id} exercise={session.exercise_name}")

    pending_frame: Optional[np.ndarray] = None
    processing = False

    async def drain_frame_queue():
        nonlocal pending_frame, processing
        if processing:
            return
        processing = True
        try:
            while pending_frame is not None:
                frame = pending_frame
                pending_frame = None
                if pose_model is None:
                    await websocket.send_json({"error": "Model not ready"})
                    continue
                raw = await asyncio.to_thread(run_pose_and_validate, frame, session)
                if raw["success"] and session.check_set_complete() and not session.is_complete:
                    session.advance_set()
                await websocket.send_json(build_frame_response(session, raw))
        finally:
            processing = False
            if pending_frame is not None:
                asyncio.create_task(drain_frame_queue())

    async def enqueue_frame(frame: np.ndarray):
        nonlocal pending_frame
        pending_frame = frame
        await drain_frame_queue()

    try:
        while True:
            message = await websocket.receive()

            if message.get("type") == "websocket.disconnect":
                break

            if message.get("bytes") is not None:
                try:
                    frame = decode_image_bytes(message["bytes"])
                except Exception as e:
                    await websocket.send_json({"error": f"Bad image: {e}"})
                    continue
                await enqueue_frame(frame)
                continue

            data = message.get("text")
            if data is None:
                continue

            try:
                msg = json.loads(data)
                msg_type = msg.get("type", "frame")

                if msg_type == "frame":
                    try:
                        frame = decode_base64_frame(msg["data"])
                    except Exception as e:
                        await websocket.send_json({"error": f"Bad image: {e}"})
                        continue
                    await enqueue_frame(frame)

                elif msg_type == "next_set":
                    if not session.is_complete:
                        session.advance_set()
                    await websocket.send_json({"type": "session_update", **session.to_dict()})

                elif msg_type == "reset":
                    session.reset_all()
                    await websocket.send_json({"type": "session_update", **session.to_dict()})

                elif msg_type == "ping":
                    await websocket.send_json({"type": "pong", "timestamp": datetime.utcnow().isoformat()})

                elif msg_type == "status":
                    await websocket.send_json({"type": "session_update", **session.to_dict()})

                else:
                    await websocket.send_json({"error": f"Unknown message type: {msg_type}"})

            except json.JSONDecodeError:
                await websocket.send_json({"error": "Invalid JSON"})
            except Exception as e:
                await websocket.send_json({"error": str(e)})

    except (WebSocketDisconnect, RuntimeError):
        print(f"[WS] Disconnected: session={session_key}")


# ---------------------------------------------------------------------------
# Entry Point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=False)
