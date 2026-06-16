import json
import asyncio
from datetime import datetime
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

import app.state as state
from app.services.pose_service import decode_base64_frame, decode_image_bytes, run_pose_and_validate
from app.services.frame_service import build_frame_response

router = APIRouter(tags=["WebSocket"])


@router.websocket("/ws/{session_key}")
async def websocket_endpoint(websocket: WebSocket, session_key: str):
    await websocket.accept()

    session = state.active_sessions.get(session_key)
    if not session:
        await websocket.send_json({"error": "Session not found. Call POST /session/start first."})
        await websocket.close()
        return

    print(f"[WS] Connected: session={session_key} user={session.user_id} exercise={session.exercise_name}")

    pending_frame = None
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
                if state.pose_model is None:
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

    async def enqueue_frame(frame):
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
