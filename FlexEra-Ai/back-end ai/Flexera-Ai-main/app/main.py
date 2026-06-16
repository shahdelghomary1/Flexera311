from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO

import app.state as state
from app.routers import health, exercises, sessions, process, websocket

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

app.include_router(health.router)
app.include_router(exercises.router)
app.include_router(sessions.router)
app.include_router(process.router)
app.include_router(websocket.router)


@app.on_event("startup")
async def load_model():
    print("[FlexEra API] Loading YOLOv8n-pose model...")
    state.pose_model = YOLO("yolov8n-pose.pt")
    state.pose_model.to("cpu")
    print("[FlexEra API] Model ready. Server is up.")
