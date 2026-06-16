from datetime import datetime
from fastapi import APIRouter

import app.state as state
from app.models.schemas import HealthResponse

router = APIRouter(tags=["Health"])


@router.get("/", summary="Root health check")
async def root():
    return {
        "message": "FlexEra Exercise AI API is running",
        "docs": "/docs",
        "version": "2.0.0",
    }


@router.get("/health", response_model=HealthResponse, summary="Detailed health check")
async def health():
    return HealthResponse(
        status="ok" if state.pose_model is not None else "model_loading",
        model_loaded=state.pose_model is not None,
        active_sessions=len(state.active_sessions),
        version="2.0.0",
        timestamp=datetime.utcnow().isoformat(),
    )
