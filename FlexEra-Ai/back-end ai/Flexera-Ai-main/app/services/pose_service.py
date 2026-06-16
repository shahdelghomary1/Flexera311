import cv2
import numpy as np
import base64

import app.state as state
from app.core.exercise_validator import ExerciseState, MultiSideValidator
from app.models.session import ExerciseSession


def decode_image_bytes(img_bytes: bytes) -> np.ndarray:
    nparr = np.frombuffer(img_bytes, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if frame is None:
        raise ValueError("Failed to decode image")
    return frame


def decode_base64_frame(image_base64: str) -> np.ndarray:
    return decode_image_bytes(base64.b64decode(image_base64))


def run_pose_and_validate(frame: np.ndarray, session: ExerciseSession) -> dict:
    results = state.pose_model(frame, verbose=False)

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
