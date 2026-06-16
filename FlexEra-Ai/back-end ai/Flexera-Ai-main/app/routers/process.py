from fastapi import APIRouter, HTTPException

import app.state as state
from app.models.schemas import FrameProcessRequest, FrameProcessResponse
from app.services.pose_service import decode_base64_frame, run_pose_and_validate
from app.services.frame_service import build_frame_response

router = APIRouter(tags=["Frame Processing"])


@router.post("/process", response_model=FrameProcessResponse, summary="Process a single camera frame")
async def process_frame(req: FrameProcessRequest):
    if state.pose_model is None:
        raise HTTPException(status_code=503, detail="AI model is still loading")

    session = state.active_sessions.get(req.session_key)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found. Call /session/start first.")

    try:
        frame = decode_base64_frame(req.image_base64)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid image data: {e}")

    raw = run_pose_and_validate(frame, session)

    if raw["success"] and session.check_set_complete() and not session.is_complete:
        session.advance_set()

    return FrameProcessResponse(**build_frame_response(session, raw))
