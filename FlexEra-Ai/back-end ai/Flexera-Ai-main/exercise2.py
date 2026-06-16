import cv2
import numpy as np
import time
import threading
import pyttsx3
from ultralytics import YOLO
from dataclasses import dataclass
from typing import Tuple, Dict, Optional, List
from enum import Enum
from collections import deque

@dataclass
class ErrorDetection:
    error_type: str
    severity: str
    recommendation: str
    joint_name: str
    current_value: float
    expected_range: Tuple[float, float]

EXERCISE_RULES = {
    'bending_knee_no_support_seated_L': {
        'joint': 'knee', 'min_angle': 91, 'max_angle': 154,
        'errors': {
            'insufficient_flexion':  {'condition': lambda a, mn, mx: a > mn + 20, 'recommendation': "Bend your left knee more", 'severity': 'medium'},
            'insufficient_extension':{'condition': lambda a, mn, mx: a < mx - 20, 'recommendation': "Straighten your left leg fully", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'bending_knee_with_support_seated_L': {
        'joint': 'knee', 'min_angle': 90, 'max_angle': 177,
        'errors': {
            'insufficient_flexion':  {'condition': lambda a, mn, mx: a > mn + 15, 'recommendation': "Bend your left knee more", 'severity': 'medium'},
            'insufficient_extension':{'condition': lambda a, mn, mx: a < mx - 15, 'recommendation': "Straighten your left leg more", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'lift_extended_leg_supine_L': {
        'joint': 'hip', 'min_angle': 141, 'max_angle': 180,
        'secondary_joint': 'knee', 'secondary_min': 165, 'secondary_max': 180,
        'errors': {
            'leg_not_straight': {'condition': lambda a, mn, mx: False, 'recommendation': "Keep your left leg straight", 'severity': 'high'},
            'insufficient_lift': {'condition': lambda a, mn, mx: a > mx - 20, 'recommendation': "Lift your left leg higher", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.5
    },
    'bending_knee_bed_support_supine_L': {
        'joint': 'knee', 'min_angle': 87, 'max_angle': 150,
        'errors': {
            'insufficient_flexion':  {'condition': lambda a, mn, mx: a > mn + 15, 'recommendation': "Bend your left knee more", 'severity': 'medium'},
            'insufficient_extension':{'condition': lambda a, mn, mx: a < mx - 15, 'recommendation': "Extend your left leg more", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.5
    },
    'bending_knee_no_support_seated_R': {
        'joint': 'knee', 'min_angle': 96, 'max_angle': 161,
        'errors': {
            'insufficient_flexion':  {'condition': lambda a, mn, mx: a > mn + 20, 'recommendation': "Bend your right knee more", 'severity': 'medium'},
            'insufficient_extension':{'condition': lambda a, mn, mx: a < mx - 20, 'recommendation': "Straighten your right leg fully", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'bending_knee_with_support_seated_R': {
        'joint': 'knee', 'min_angle': 101, 'max_angle': 180,
        'errors': {
            'insufficient_flexion':  {'condition': lambda a, mn, mx: a > mn + 15, 'recommendation': "Bend your right knee more", 'severity': 'medium'},
            'insufficient_extension':{'condition': lambda a, mn, mx: a < mx - 15, 'recommendation': "Straighten your right leg more", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'lift_extended_leg_supine_R': {
        'joint': 'hip', 'min_angle': 152, 'max_angle': 180,
        'secondary_joint': 'knee', 'secondary_min': 165, 'secondary_max': 180,
        'errors': {
            'leg_not_straight': {'condition': lambda a, mn, mx: False, 'recommendation': "Keep your right leg straight", 'severity': 'high'},
            'insufficient_lift': {'condition': lambda a, mn, mx: a > mx - 20, 'recommendation': "Lift your right leg higher", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.5
    },
    'bending_knee_bed_support_supine_R': {
        'joint': 'knee', 'min_angle': 97, 'max_angle': 160,
        'errors': {
            'insufficient_flexion':  {'condition': lambda a, mn, mx: a > mn + 15, 'recommendation': "Bend your right knee more", 'severity': 'medium'},
            'insufficient_extension':{'condition': lambda a, mn, mx: a < mx - 15, 'recommendation': "Extend your right leg more", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.5
    },
    'shoulder_flexion_seated_L': {
        'joint': 'shoulder', 'min_angle': 0, 'max_angle': 164,
        'errors': {
            'insufficient_raise':   {'condition': lambda a, mn, mx: a < mx - 30, 'recommendation': "Lift your left arm higher", 'severity': 'medium'},
            'incomplete_lowering':  {'condition': lambda a, mn, mx: a > mn + 20, 'recommendation': "Lower your left arm completely", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'horizontal_weighted_openings_standing_L': {
        'joint': 'shoulder', 'min_angle': 84, 'max_angle': 180,
        'errors': {
            'insufficient_opening': {'condition': lambda a, mn, mx: a < mn + 20, 'recommendation': "Open your arms wider", 'severity': 'medium'},
            'insufficient_closing': {'condition': lambda a, mn, mx: a > mx - 20, 'recommendation': "Bring your arms together", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'external_rotation_shoulders_elastic_L': {
        'joint': 'elbow', 'min_angle': 31, 'max_angle': 178,
        'secondary_joint': 'elbow_bend', 'secondary_min': 65, 'secondary_max': 115,
        'errors': {
            'elbow_not_bent':       {'condition': lambda a, mn, mx: False, 'recommendation': "Keep your left elbow bent at 90 degrees", 'severity': 'high'},
            'insufficient_rotation':{'condition': lambda a, mn, mx: a < mx - 20, 'recommendation': "Rotate your left wrist further outward", 'severity': 'medium'},
            'insufficient_return':  {'condition': lambda a, mn, mx: a > mn + 20, 'recommendation': "Return your left wrist to center", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.5
    },
    'circular_pendulum_standing_L': {
        'joint': 'shoulder', 'min_angle': 26, 'max_angle': 85,
        'errors': {
            'stopped_motion':     {'condition': lambda a, mn, mx: False, 'recommendation': "Keep your left arm moving", 'severity': 'medium'},
            'insufficient_motion':{'condition': lambda a, mn, mx: a < mn + 5,  'recommendation': "Make bigger circles with your left arm", 'severity': 'low'},
        },
        'continuous_motion': True, 'movement_speed_check': False
    },
    'shoulder_flexion_seated_R': {
        'joint': 'shoulder', 'min_angle': 0, 'max_angle': 163,
        'errors': {
            'insufficient_raise':  {'condition': lambda a, mn, mx: a < mx - 30, 'recommendation': "Lift your right arm higher", 'severity': 'medium'},
            'incomplete_lowering': {'condition': lambda a, mn, mx: a > mn + 20, 'recommendation': "Lower your right arm completely", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'horizontal_weighted_openings_standing_R': {
        'joint': 'shoulder', 'min_angle': 74, 'max_angle': 180,
        'errors': {
            'insufficient_opening': {'condition': lambda a, mn, mx: a < mn + 20, 'recommendation': "Open your arms wider", 'severity': 'medium'},
            'insufficient_closing': {'condition': lambda a, mn, mx: a > mx - 20, 'recommendation': "Bring your arms together", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.0
    },
    'external_rotation_shoulders_elastic_R': {
        'joint': 'elbow', 'min_angle': 31, 'max_angle': 173,
        'secondary_joint': 'elbow_bend', 'secondary_min': 65, 'secondary_max': 115,
        'errors': {
            'elbow_not_bent':       {'condition': lambda a, mn, mx: False, 'recommendation': "Keep your right elbow bent at 90 degrees", 'severity': 'high'},
            'insufficient_rotation':{'condition': lambda a, mn, mx: a < mx - 20, 'recommendation': "Rotate your right wrist further outward", 'severity': 'medium'},
            'insufficient_return':  {'condition': lambda a, mn, mx: a > mn + 20, 'recommendation': "Return your right wrist to center", 'severity': 'medium'},
        },
        'movement_speed_check': True, 'min_rep_duration': 2.5
    },
    'circular_pendulum_standing_R': {
        'joint': 'shoulder', 'min_angle': 29, 'max_angle': 84,
        'errors': {
            'stopped_motion':     {'condition': lambda a, mn, mx: False, 'recommendation': "Keep your right arm moving", 'severity': 'medium'},
            'insufficient_motion':{'condition': lambda a, mn, mx: a < mn + 5,  'recommendation': "Make bigger circles with your right arm", 'severity': 'low'},
        },
        'continuous_motion': True, 'movement_speed_check': False
    },
}

class VoiceFeedback:

    def __init__(self, rate=150, volume=0.9, cooldown=3.0):
        self.engine = pyttsx3.init()
        self.engine.setProperty('rate', rate)
        self.engine.setProperty('volume', volume)
        self.enabled = True
        self.is_speaking = False
        self.last_messages = {}
        self.cooldown = cooldown
        self.lock = threading.Lock()

    def speak(self, text, force=False):
        if not self.enabled or not text:
            return False

        current_time = time.time()

        with self.lock:
            if not force and text in self.last_messages:
                if current_time - self.last_messages[text] < self.cooldown:
                    return False
            self.last_messages[text] = current_time

        thread = threading.Thread(target=self._speak_thread, args=(text,))
        thread.daemon = True
        thread.start()
        return True

    def _speak_thread(self, text):
        self.is_speaking = True
        try:
            self.engine.say(text)
            self.engine.runAndWait()
        except:
            pass
        finally:
            self.is_speaking = False

    def enable(self):
        self.enabled = True

    def disable(self):
        self.enabled = False

    def clear_cooldown(self):
        with self.lock:
            self.last_messages.clear()

    def stop(self):
        try:
            self.engine.stop()
        except:
            pass

class ExerciseState(Enum):
    IDLE = "idle"
    MIN_POSITION = "min"
    TRANSITION = "transition"
    MAX_POSITION = "max"
    INVALID = "invalid"

@dataclass
class JointAngleRule:
    keypoint_indices: Tuple[int, int, int]
    min_angle: float
    max_angle: float
    name: str

@dataclass
class ExerciseRule:
    name: str
    primary_joint: JointAngleRule
    secondary_joint: Optional[JointAngleRule] = None
    sides: List[str] = None
    continuous_oscillation: bool = False

@dataclass
class ValidationResult:
    is_valid: bool
    current_angle: float
    rep_count: int
    state: ExerciseState
    feedback: str
    side: str

KEYPOINTS = {
    'nose': 0,
    'left_eye': 1,
    'right_eye': 2,
    'left_ear': 3,
    'right_ear': 4,
    'left_shoulder': 5,
    'right_shoulder': 6,
    'left_elbow': 7,
    'right_elbow': 8,
    'left_wrist': 9,
    'right_wrist': 10,
    'left_hip': 11,
    'right_hip': 12,
    'left_knee': 13,
    'right_knee': 14,
    'left_ankle': 15,
    'right_ankle': 16,
}

VALIDATOR_EXERCISE_RULES = {
    'bending_knee_no_support_seated_L': ExerciseRule(
        name='Bending knee no support seated L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=91, max_angle=154, name='knee'
        ), sides=['left']
    ),
    'bending_knee_with_support_seated_L': ExerciseRule(
        name='Bending knee with support seated L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=90, max_angle=177, name='knee'
        ), sides=['left']
    ),
    'lift_extended_leg_supine_L': ExerciseRule(
        name='Lift extended leg supine L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_shoulder'], KEYPOINTS['left_hip'], KEYPOINTS['left_knee']),
            min_angle=140, max_angle=170, name='hip'
        ),
        secondary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=150, max_angle=185, name='knee_extension'
        ),
        sides=['left']
    ),
    'bending_knee_bed_support_supine_L': ExerciseRule(
        name='Bending knee with bed support supine L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=87, max_angle=160, name='knee'
        ), sides=['left']
    ),
    'bending_knee_no_support_seated_R': ExerciseRule(
        name='Bending knee no support seated R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_hip'], KEYPOINTS['right_knee'], KEYPOINTS['right_ankle']),
            min_angle=96, max_angle=161, name='knee'
        ), sides=['right']
    ),
    'bending_knee_with_support_seated_R': ExerciseRule(
        name='Bending knee with support seated R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_hip'], KEYPOINTS['right_knee'], KEYPOINTS['right_ankle']),
            min_angle=101, max_angle=180, name='knee'
        ), sides=['right']
    ),
    'lift_extended_leg_supine_R': ExerciseRule(
        name='Lift extended leg supine R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_shoulder'], KEYPOINTS['right_hip'], KEYPOINTS['right_knee']),
            min_angle=140, max_angle=170, name='hip'
        ),
        secondary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_hip'], KEYPOINTS['right_knee'], KEYPOINTS['right_ankle']),
            min_angle=150, max_angle=185, name='knee_extension'
        ),
        sides=['right']
    ),
    'bending_knee_bed_support_supine_R': ExerciseRule(
        name='Bending knee with bed support supine R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_hip'], KEYPOINTS['right_knee'], KEYPOINTS['right_ankle']),
            min_angle=97, max_angle=160, name='knee'
        ), sides=['right']
    ),
    'shoulder_flexion_seated_L': ExerciseRule(
        name='Shoulder flexion seated L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow']),
            min_angle=0, max_angle=164, name='shoulder'
        ), sides=['left']
    ),
    'horizontal_weighted_openings_standing_L': ExerciseRule(
        name='Horizontal weighted openings standing L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_elbow'], KEYPOINTS['left_shoulder'], KEYPOINTS['right_elbow']),
            min_angle=84, max_angle=180, name='shoulder_opening'
        ), sides=['left']
    ),
    'external_rotation_shoulders_elastic_L': ExerciseRule(
        name='External rotation shoulders elastic L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow'], KEYPOINTS['left_wrist']),
            min_angle=31, max_angle=178, name='elbow'
        ),
        secondary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow'], KEYPOINTS['left_wrist']),
            min_angle=65, max_angle=115, name='elbow_bend'
        ),
        sides=['left']
    ),
    'circular_pendulum_standing_L': ExerciseRule(
        name='Circular pendulum standing L',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow']),
            min_angle=26, max_angle=85, name='shoulder'
        ),
        sides=['left'],
        continuous_oscillation=True
    ),
    'shoulder_flexion_seated_R': ExerciseRule(
        name='Shoulder flexion seated R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_hip'], KEYPOINTS['right_shoulder'], KEYPOINTS['right_elbow']),
            min_angle=0, max_angle=163, name='shoulder'
        ), sides=['right']
    ),
    'horizontal_weighted_openings_standing_R': ExerciseRule(
        name='Horizontal weighted openings standing R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_elbow'], KEYPOINTS['left_shoulder'], KEYPOINTS['right_elbow']),
            min_angle=74, max_angle=180, name='shoulder_opening'
        ), sides=['right']
    ),
    'external_rotation_shoulders_elastic_R': ExerciseRule(
        name='External rotation shoulders elastic R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_shoulder'], KEYPOINTS['right_elbow'], KEYPOINTS['right_wrist']),
            min_angle=31, max_angle=173, name='elbow'
        ),
        secondary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_shoulder'], KEYPOINTS['right_elbow'], KEYPOINTS['right_wrist']),
            min_angle=65, max_angle=115, name='elbow_bend'
        ),
        sides=['right']
    ),
    'circular_pendulum_standing_R': ExerciseRule(
        name='Circular pendulum standing R',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['right_hip'], KEYPOINTS['right_shoulder'], KEYPOINTS['right_elbow']),
            min_angle=29, max_angle=84, name='shoulder'
        ),
        sides=['right'],
        continuous_oscillation=True
    ),
}

class ExerciseValidator:

    def __init__(self, exercise_key: str, confidence_threshold: float = 0.5):
        if exercise_key not in VALIDATOR_EXERCISE_RULES:
            raise ValueError(f"Unknown exercise: {exercise_key}. Available: {list(VALIDATOR_EXERCISE_RULES.keys())}")

        self.exercise = VALIDATOR_EXERCISE_RULES[exercise_key]
        self.confidence_threshold = confidence_threshold

        self.state = {'left': ExerciseState.IDLE, 'right': ExerciseState.IDLE}
        self.rep_count = {'left': 0, 'right': 0}
        self.angle_buffer = {'left': [], 'right': []}
        self.buffer_size = 15

        self.min_tolerance = 15
        self.max_tolerance = 15

    def calculate_angle(self, point_a: np.ndarray, point_b: np.ndarray, point_c: np.ndarray) -> float:
    
        vector_ba = point_a - point_b
        vector_bc = point_c - point_b

        cos_angle = np.dot(vector_ba, vector_bc) / (
            np.linalg.norm(vector_ba) * np.linalg.norm(vector_bc) + 1e-6
        )
        cos_angle = np.clip(cos_angle, -1.0, 1.0)
        angle = np.degrees(np.arccos(cos_angle))

        return angle

    def check_keypoint_confidence(self, keypoints: np.ndarray, indices: Tuple[int, int, int]) -> bool:
        for idx in indices:
            if keypoints[idx, 2] < self.confidence_threshold:
                return False
        return True

    def get_side_adjusted_indices(self, side: str) -> Tuple[Tuple[int, int, int], Optional[Tuple[int, int, int]]]:
        primary   = tuple(self.exercise.primary_joint.keypoint_indices)
        secondary = tuple(self.exercise.secondary_joint.keypoint_indices) if self.exercise.secondary_joint else None
        return primary, secondary

    def _swap_side(self, keypoint_idx: int) -> int:
        keypoint_map = {
            1: 2, 2: 1,
            3: 4, 4: 3,
            5: 6, 6: 5,
            7: 8, 8: 7,
            9: 10, 10: 9,
            11: 12, 12: 11,
            13: 14, 14: 13,
            15: 16, 16: 15,
        }
        return keypoint_map.get(keypoint_idx, keypoint_idx)

    def validate_angle(self, angle: float) -> Tuple[bool, bool]:
        min_angle = self.exercise.primary_joint.min_angle
        max_angle = self.exercise.primary_joint.max_angle
        margin = 20
        is_valid = (min_angle - margin) <= angle <= (max_angle + margin)
        is_at_min = abs(angle - min_angle) <= self.min_tolerance
        is_at_max = abs(angle - max_angle) <= self.max_tolerance
        return is_valid, is_at_min, is_at_max

    def update_state_machine(self, angle: float, side: str) -> bool:
        is_valid, is_at_min, is_at_max = self.validate_angle(angle)

        if not is_valid:
            self.state[side] = ExerciseState.INVALID
            return False

        current_state = self.state[side]
        new_rep = False

        if self.exercise.continuous_oscillation:
            if is_at_min and current_state in [ExerciseState.IDLE, ExerciseState.MAX_POSITION, ExerciseState.TRANSITION]:
                self.state[side] = ExerciseState.MIN_POSITION
                if current_state != ExerciseState.IDLE:
                    self.rep_count[side] += 1
                    new_rep = True
            elif is_at_max and current_state in [ExerciseState.IDLE, ExerciseState.MIN_POSITION, ExerciseState.TRANSITION]:
                self.state[side] = ExerciseState.MAX_POSITION
            elif not is_at_min and not is_at_max:
                self.state[side] = ExerciseState.TRANSITION
        else:
            if is_at_max:
                if current_state != ExerciseState.MAX_POSITION:
                    self.rep_count[side] += 1
                    new_rep = True
                    print(f"\n*** REP COUNTED: {self.rep_count[side]} (side={side}) ***")
                self.state[side] = ExerciseState.MAX_POSITION
            elif is_at_min:
                self.state[side] = ExerciseState.MIN_POSITION
            else:
                self.state[side] = ExerciseState.TRANSITION

        return new_rep

    def validate_frame(self, keypoints: np.ndarray, side: str = 'left') -> ValidationResult:
        if self.exercise.sides and len(self.exercise.sides) == 1:
            side = self.exercise.sides[0]
        primary_indices, secondary_indices = self.get_side_adjusted_indices(side)

        if not self.check_keypoint_confidence(keypoints, primary_indices):
            return ValidationResult(
                is_valid=False,
                current_angle=0.0,
                rep_count=self.rep_count[side],
                state=ExerciseState.INVALID,
                feedback=f"Low confidence on {side} {self.exercise.primary_joint.name}",
                side=side
            )

        point_a = keypoints[primary_indices[0], :2]
        point_b = keypoints[primary_indices[1], :2]
        point_c = keypoints[primary_indices[2], :2]

        primary_angle = self.calculate_angle(point_a, point_b, point_c)

        if self.exercise.secondary_joint and secondary_indices:
            if not self.check_keypoint_confidence(keypoints, secondary_indices):
                return ValidationResult(
                    is_valid=False,
                    current_angle=primary_angle,
                    rep_count=self.rep_count[side],
                    state=ExerciseState.INVALID,
                    feedback=f"Low confidence on {side} {self.exercise.secondary_joint.name}",
                    side=side
                )

            sec_point_a = keypoints[secondary_indices[0], :2]
            sec_point_b = keypoints[secondary_indices[1], :2]
            sec_point_c = keypoints[secondary_indices[2], :2]
            secondary_angle = self.calculate_angle(sec_point_a, sec_point_b, sec_point_c)

            sec_min = self.exercise.secondary_joint.min_angle
            sec_max = self.exercise.secondary_joint.max_angle
            if not (sec_min <= secondary_angle <= sec_max):
                return ValidationResult(
                    is_valid=False,
                    current_angle=primary_angle,
                    rep_count=self.rep_count[side],
                    state=ExerciseState.INVALID,
                    feedback=f"Keep {side} knee extended ({secondary_angle:.1f})",
                    side=side
                )

        self.angle_buffer[side].append(primary_angle)
        if len(self.angle_buffer[side]) > self.buffer_size:
            self.angle_buffer[side].pop(0)
        smoothed_angle = np.mean(self.angle_buffer[side])

        new_rep = self.update_state_machine(smoothed_angle, side)

        is_valid, is_at_min, is_at_max = self.validate_angle(smoothed_angle)

        if new_rep:
            feedback = f"Rep {self.rep_count[side]} complete!"
        elif not is_valid:
            if smoothed_angle < self.exercise.primary_joint.min_angle:
                feedback = f"Angle too small ({smoothed_angle:.1f})"
            else:
                feedback = f"Angle too large ({smoothed_angle:.1f})"
        elif is_at_min:
            feedback = "At minimum position"
        elif is_at_max:
            feedback = "At maximum position"
        else:
            feedback = "In transition"

        return ValidationResult(
            is_valid=is_valid,
            current_angle=smoothed_angle,
            rep_count=self.rep_count[side],
            state=self.state[side],
            feedback=feedback,
            side=side
        )

    def reset(self):
        self.state = {'left': ExerciseState.IDLE, 'right': ExerciseState.IDLE}
        self.rep_count = {'left': 0, 'right': 0}
        self.angle_buffer = {'left': [], 'right': []}

class MultiSideValidator:

    def __init__(self, exercise_key: str, confidence_threshold: float = 0.5):
        self.validator = ExerciseValidator(exercise_key, confidence_threshold)
        self.exercise_key = exercise_key
        sides = VALIDATOR_EXERCISE_RULES[exercise_key].sides
        self.side = sides[0] if sides and len(sides) == 1 else 'left'

    def validate_frame(self, keypoints: np.ndarray) -> Dict[str, ValidationResult]:
        """Validate the correct side for this exercise"""
        result = self.validator.validate_frame(keypoints, self.side)
        other_side = 'right' if self.side == 'left' else 'left'
        dummy = ValidationResult(
            is_valid=False, current_angle=0.0,
            rep_count=0, state=ExerciseState.IDLE,
            feedback='', side=other_side
        )
        return {self.side: result, other_side: dummy}

    def get_total_reps(self) -> int:
        return self.validator.rep_count[self.side]

    def reset(self):
        self.validator.reset()

class ExerciseCorrection:

    def __init__(self, voice_enabled=True, cooldown=3.0):
        self.voice = VoiceFeedback(cooldown=cooldown)
        if not voice_enabled:
            self.voice.disable()
        self.angle_history = deque(maxlen=30)
        self.rep_start_time = None
        self.last_state = None
        self.error_counts = {}
        self.motion_stopped_frames = 0

    def detect_errors(self, exercise_name, joint_angles, current_rep_state, is_valid_motion, side='left'):
        errors = []
        if exercise_name not in EXERCISE_RULES:
            return errors

        rules = EXERCISE_RULES[exercise_name]
        primary_joint = rules['joint']
        min_angle = rules['min_angle']
        max_angle = rules['max_angle']

        primary_angle = joint_angles.get(f"{side}_{primary_joint}")
        if primary_angle is None:
            return errors

        self.angle_history.append({
            'angle': primary_angle,
            'time': time.time(),
            'state': current_rep_state
        })

        for error_type, error_def in rules['errors'].items():
            if error_type == 'stopped_motion' and rules.get('continuous_motion'):
                if len(self.angle_history) >= 10:
                    recent_angles = [h['angle'] for h in list(self.angle_history)[-10:]]
                    angle_variance = max(recent_angles) - min(recent_angles)
                    if angle_variance < 5:
                        self.motion_stopped_frames += 1
                        if self.motion_stopped_frames > 15:
                            errors.append(ErrorDetection(
                                error_type='stopped_motion',
                                severity=error_def['severity'],
                                recommendation=error_def['recommendation'],
                                joint_name=primary_joint,
                                current_value=primary_angle,
                                expected_range=(min_angle, max_angle)
                            ))
                    else:
                        self.motion_stopped_frames = 0
                continue

            if error_type == 'fast_motion':
                continue

            if error_def['condition'](primary_angle, min_angle, max_angle):
                errors.append(ErrorDetection(
                    error_type=error_type,
                    severity=error_def['severity'],
                    recommendation=error_def['recommendation'],
                    joint_name=primary_joint,
                    current_value=primary_angle,
                    expected_range=(min_angle, max_angle)
                ))

        if 'secondary_joint' in rules:
            sec_joint = rules['secondary_joint']
            sec_angle = joint_angles.get(f"{side}_{sec_joint}")
            if sec_angle is not None:
                sec_min = rules['secondary_min']
                sec_max = rules['secondary_max']
                if not (sec_min <= sec_angle <= sec_max):
                    errors.append(ErrorDetection(
                        error_type='leg_not_straight',
                        severity='high',
                        recommendation="Keep your leg straight",
                        joint_name=sec_joint,
                        current_value=sec_angle,
                        expected_range=(sec_min, sec_max)
                    ))

        if rules.get('movement_speed_check'):
            if current_rep_state != self.last_state:
                if current_rep_state == 'min' and self.last_state == 'max':
                    if self.rep_start_time is not None:
                        rep_duration = time.time() - self.rep_start_time
                        min_duration = rules.get('min_rep_duration', 2.0)
                        if rep_duration < min_duration:
                            errors.append(ErrorDetection(
                                error_type='too_fast',
                                severity='medium',
                                recommendation="Slow down your movement",
                                joint_name=primary_joint,
                                current_value=rep_duration,
                                expected_range=(min_duration, 5.0)
                            ))
                    self.rep_start_time = time.time()
                elif current_rep_state == 'min':
                    self.rep_start_time = time.time()

        self.last_state = current_rep_state

        if not is_valid_motion and current_rep_state != 'neutral':
            errors.append(ErrorDetection(
                error_type='incomplete_rep',
                severity='medium',
                recommendation="Complete the full movement",
                joint_name=primary_joint,
                current_value=primary_angle,
                expected_range=(min_angle, max_angle)
            ))

        return errors

    def generate_recommendation(self, errors):
        if not errors:
            return None
        severity_priority = {'high': 3, 'medium': 2, 'low': 1}
        sorted_errors = sorted(errors, key=lambda e: severity_priority[e.severity], reverse=True)
        return sorted_errors[0].recommendation

    def provide_feedback(self, exercise_name, joint_angles, current_rep_state, is_valid_motion, side='left', force_speak=False):
        errors = self.detect_errors(exercise_name, joint_angles, current_rep_state, is_valid_motion, side)
        recommendation = self.generate_recommendation(errors)
        spoken = False
        if recommendation:
            spoken = self.voice.speak(recommendation, force=force_speak)
        return {
            'errors': errors,
            'recommendation': recommendation,
            'spoken': spoken,
            'error_count': len(errors),
            'highest_severity': errors[0].severity if errors else None
        }

    def enable_voice(self):
        self.voice.enable()

    def disable_voice(self):
        self.voice.disable()

    def reset(self):
        self.angle_history.clear()
        self.rep_start_time = None
        self.last_state = None
        self.error_counts.clear()
        self.motion_stopped_frames = 0
        self.voice.clear_cooldown()

    def get_statistics(self):
        return {
            'total_errors': sum(self.error_counts.values()),
            'error_breakdown': dict(self.error_counts),
            'angle_history_size': len(self.angle_history)
        }

def create_correction(voice_enabled=True, cooldown=3.0):
    return ExerciseCorrection(voice_enabled=voice_enabled, cooldown=cooldown)

class CompleteSystem:

    def __init__(self, exercise_key):
        print(f"Loading system for: {exercise_key}")
        self.pose_model = YOLO('yolov8n-pose.pt')
        self.validator = MultiSideValidator(exercise_key, confidence_threshold=0.5)
        self.correction = create_correction(voice_enabled=True, cooldown=3.0)
        self.exercise_key = exercise_key
        self._last_tip = None
        self._last_tip_frame = 0
        self._frame_count = 0
        self._tip_hold_frames = 20

    def process_frame(self, frame):
        pose_results = self.pose_model(frame, verbose=False)
        if not pose_results or len(pose_results[0].keypoints.data) == 0:
            return None, frame

        keypoints = pose_results[0].keypoints.data[0].cpu().numpy()
        validation_results = self.validator.validate_frame(keypoints)
        active_side = self.validator.side
        res = validation_results[active_side]
        mn  = self.validator.validator.exercise.primary_joint.min_angle
        mx  = self.validator.validator.exercise.primary_joint.max_angle
        tol = self.validator.validator.min_tolerance
        at_min = abs(res.current_angle - mn) <= tol
        at_max = abs(res.current_angle - mx) <= tol
        print(f"\r{active_side.upper()} angle={res.current_angle:.1f}° "
              f"state={res.state.value:<12} "
              f"valid={res.is_valid} "
              f"at_min={at_min}({mn}°±{tol}) "
              f"at_max={at_max}({mx}°±{tol}) "
              f"reps={res.rep_count}",
              end='', flush=True)

        active_side = self.validator.side
        active_result = validation_results[active_side]

        joint_angles = {
            f'{active_side}_knee':     active_result.current_angle,
            f'{active_side}_shoulder': active_result.current_angle,
            f'{active_side}_hip':      active_result.current_angle,
            f'{active_side}_elbow':    active_result.current_angle,
        }

        state_mapping = {
            'IDLE': 'neutral',
            'MIN_POSITION': 'min',
            'MAX_POSITION': 'max',
            'TRANSITION': 'transition',
            'INVALID': 'neutral'
        }

        rep_state = state_mapping.get(active_result.state.value, 'neutral')

        feedback = self.correction.provide_feedback(
            exercise_name=self.exercise_key,
            joint_angles=joint_angles,
            current_rep_state=rep_state,
            is_valid_motion=active_result.is_valid,
            side=active_side
        )

        self._frame_count += 1
        new_tip = feedback.get('recommendation')
        if new_tip != self._last_tip:
            if self._frame_count - self._last_tip_frame >= self._tip_hold_frames:
                self._last_tip = new_tip
                self._last_tip_frame = self._frame_count
        feedback['recommendation'] = self._last_tip

        return {
            'validation': validation_results,
            'feedback': feedback,
            'total_reps': self.validator.get_total_reps(),
            'active_side': active_side
        }, frame

    def draw_feedback(self, frame, validation_results, feedback):
        h, w = frame.shape[:2]
        overlay = frame.copy()
        cv2.rectangle(overlay, (10, 10), (450, 300), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.7, frame, 0.3, 0, frame)

        y_pos = 40
        cv2.putText(frame, "LEFT SIDE", (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        y_pos += 30

        left = validation_results['left']
        left_color = (0, 255, 0) if left.is_valid else (0, 0, 255)
        cv2.putText(frame, f"Angle: {left.current_angle:.1f} deg", (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.5, left_color, 1)
        y_pos += 25
        cv2.putText(frame, f"Reps: {left.rep_count}", (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        y_pos += 35

        cv2.putText(frame, "RIGHT SIDE", (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        y_pos += 30

        right = validation_results['right']
        right_color = (0, 255, 0) if right.is_valid else (0, 0, 255)
        cv2.putText(frame, f"Angle: {right.current_angle:.1f} deg", (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.5, right_color, 1)
        y_pos += 25
        cv2.putText(frame, f"Reps: {right.rep_count}", (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        y_pos += 35

        if feedback['recommendation']:
            cv2.rectangle(frame, (15, y_pos - 20), (435, y_pos + 30), (0, 255, 255), 2)
            cv2.putText(frame, "TIP:", (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 2)
            y_pos += 25
            cv2.putText(frame, feedback['recommendation'], (20, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.45, (255, 255, 255), 1)

        total = self.validator.get_total_reps()
        cv2.putText(frame, f"TOTAL: {total}", (w - 200, h - 40), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 255, 255), 3)
        cv2.putText(frame, "Q:Quit | R:Reset | V:Voice", (20, h - 20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return frame

    def run(self):
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            print("Error: Could not open webcam")
            return

        print("System running. Press Q=quit, R=reset, V=toggle voice\n")

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            result, raw_frame = self.process_frame(frame)
            display_frame = cv2.flip(raw_frame, 1)
            if result is None:
                cv2.putText(display_frame, "NO PERSON DETECTED", (100, 360), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 0, 255), 2)
            else:
                display_frame = self.draw_feedback(display_frame, result['validation'], result['feedback'])

            cv2.imshow('Complete Exercise System', display_frame)

            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):
                break
            elif key == ord('r'):
                self.validator.reset()
                self.correction.reset()
                print("System reset")
            elif key == ord('v'):
                if self.correction.voice.enabled:
                    self.correction.disable_voice()
                    print("Voice OFF")
                else:
                    self.correction.enable_voice()
                    print("Voice ON")

        cap.release()
        cv2.destroyAllWindows()

        print("SESSION SUMMARY")
        print(f"Exercise: {self.exercise_key}")
        print(f"Total Reps: {self.validator.get_total_reps()}")
        print(f"Side tracked: {self.validator.side}")
        print(f"Reps: {self.validator.get_total_reps()}")


if __name__ == "__main__":
    exercise_list = list(VALIDATOR_EXERCISE_RULES.keys())

    print("AVAILABLE EXERCISES")
    for i, key in enumerate(exercise_list, 1):
        print(f"  {i}. {key}")

    while True:
        try:
            choice = int(input(f"\nSelect exercise (1-{len(exercise_list)}): "))
            if 1 <= choice <= len(exercise_list):
                selected = exercise_list[choice - 1]
                break
            print(f"Invalid. Enter 1-{len(exercise_list)}.")
        except ValueError:
            print("Invalid input.")

    print(f"\nSelected: {selected}")
    system = CompleteSystem(selected)
    system.run()