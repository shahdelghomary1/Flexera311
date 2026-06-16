from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO

import app.state as state
from app.routers import health, exercises, simple_count

app = FastAPI(
    title="Exercise Counter API - Minimal",
    description="Simplified exercise counting using YOLOv8 pose detection",
    version="1.0.0",
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

# Only include essential routers
app.include_router(health.router)
app.include_router(exercises.router)
app.include_router(simple_count.router)


@app.on_event("startup")
async def load_model():
    print("[Exercise Counter API] Loading YOLOv8n-pose model...")
    state.pose_model = YOLO("yolov8n-pose.pt")
    state.pose_model.to("cpu")
    print("[Exercise Counter API] Model ready. Server is up.")


@app.get("/")
async def root():
    return {"message": "Exercise Counter API - Ready", "endpoints": ["/count", "/reset/{user_id}/{exercise_id}", "/exercises"]}