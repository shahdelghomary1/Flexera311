import numpy as np
from dataclasses import dataclass, field
from typing import Tuple, Dict, Optional, List
from enum import Enum

from app.core.constants import KEYPOINTS


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


EXERCISE_RULES = {
    'bending_knee_no_support_seated': ExerciseRule(
        name='Bending knee no support seated',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=70,
            max_angle=180,
            name='knee',
        ),
        sides=['left', 'right'],
    ),
    'bending_knee_bed_support_supine': ExerciseRule(
        name='Bending knee with bed support supine',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=60,
            max_angle=150,
            name='knee',
        ),
        sides=['left', 'right'],
    ),
    'bending_knee_with_support_seated': ExerciseRule(
        name='Bending knee with support seated',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=80,
            max_angle=160,
            name='knee',
        ),
        sides=['left', 'right'],
    ),
    'circular_pendulum_standing': ExerciseRule(
        name='Circular pendulum standing',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow']),
            min_angle=10,
            max_angle=60,
            name='shoulder',
        ),
        sides=['left', 'right'],
        continuous_oscillation=True,
    ),
    'external_rotation_shoulders_elastic': ExerciseRule(
        name='External rotation shoulders elastic',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow'], KEYPOINTS['left_wrist']),
            min_angle=70,
            max_angle=110,
            name='elbow',
        ),
        sides=['left', 'right'],
    ),
    'horizontal_weighted_openings_standing': ExerciseRule(
        name='Horizontal weighted openings standing',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_elbow'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_hip']),
            min_angle=60,
            max_angle=120,
            name='shoulder',
        ),
        sides=['left', 'right'],
    ),
    'lift_extended_leg_supine': ExerciseRule(
        name='Lift extended leg supine',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_shoulder'], KEYPOINTS['left_hip'], KEYPOINTS['left_knee']),
            min_angle=30,
            max_angle=70,
            name='hip',
        ),
        secondary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=160,
            max_angle=180,
            name='knee_extension',
        ),
        sides=['left', 'right'],
    ),
    'shoulder_flexion_seated': ExerciseRule(
        name='Shoulder flexion seated',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow']),
            min_angle=10,
            max_angle=170,
            name='shoulder',
        ),
        sides=['left', 'right'],
    ),
}

SIDE_SWAP = {
    1: 2, 2: 1, 3: 4, 4: 3,
    5: 6, 6: 5, 7: 8, 8: 7,
    9: 10, 10: 9, 11: 12, 12: 11,
    13: 14, 14: 13, 15: 16, 16: 15,
}


class ExerciseValidator:

    def __init__(self, exercise_key: str, confidence_threshold: float = 0.5):
        # Map side-specific exercise keys to base exercise keys
        base_exercise_key = self._get_base_exercise_key(exercise_key)
        
        if base_exercise_key not in EXERCISE_RULES:
            raise ValueError(f"Unknown exercise: {exercise_key}. Base: {base_exercise_key}. Available: {list(EXERCISE_RULES.keys())}")

        self.exercise = EXERCISE_RULES[base_exercise_key]
        self.confidence_threshold = confidence_threshold
        self.state = {'left': ExerciseState.IDLE, 'right': ExerciseState.IDLE}
        self.rep_count = {'left': 0, 'right': 0}
        self.reached_max = {'left': False, 'right': False}
        self.angle_buffer = {'left': [], 'right': []}
        self.buffer_size = 3
        self.min_tolerance = 15
        self.max_tolerance = 15
        if self.exercise.primary_joint.name == 'shoulder':
            self.min_tolerance = 25
            self.max_tolerance = 20

    def _get_base_exercise_key(self, exercise_key: str) -> str:
        """Convert side-specific exercise key to base exercise key"""
        # Remove _left or _right suffix if present
        if exercise_key.endswith('_left') or exercise_key.endswith('_right'):
            return exercise_key.rsplit('_', 1)[0]
        return exercise_key

    def calculate_angle(self, point_a: np.ndarray, point_b: np.ndarray, point_c: np.ndarray) -> float:
        ba = point_a - point_b
        bc = point_c - point_b
        cos_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc) + 1e-6)
        return np.degrees(np.arccos(np.clip(cos_angle, -1.0, 1.0)))

    def check_keypoint_confidence(self, keypoints: np.ndarray, indices: Tuple[int, int, int], min_required: int = 2) -> bool:
        confident = sum(
            1 for idx in indices if keypoints[idx, 2] >= self.confidence_threshold
        )
        return confident >= min_required

    def get_side_adjusted_indices(self, side: str):
        primary = list(self.exercise.primary_joint.keypoint_indices)
        secondary = None

        if side == 'right':
            primary = [SIDE_SWAP.get(i, i) for i in primary]
            if self.exercise.secondary_joint:
                secondary = tuple(SIDE_SWAP.get(i, i) for i in self.exercise.secondary_joint.keypoint_indices)
        else:
            if self.exercise.secondary_joint:
                secondary = tuple(self.exercise.secondary_joint.keypoint_indices)

        return tuple(primary), secondary

    def validate_angle(self, angle: float):
        min_a = self.exercise.primary_joint.min_angle
        max_a = self.exercise.primary_joint.max_angle
        is_valid = min_a <= angle <= max_a

        if (
            self.exercise.primary_joint.name == 'shoulder'
            and not self.exercise.continuous_oscillation
        ):
            span = max_a - min_a
            if span > 0:
                ratio = (angle - min_a) / span
                is_at_min = ratio <= 0.25
                is_at_max = ratio >= 0.70
            else:
                is_at_min = abs(angle - min_a) <= self.min_tolerance
                is_at_max = abs(angle - max_a) <= self.max_tolerance
        else:
            is_at_min = abs(angle - min_a) <= self.min_tolerance
            is_at_max = abs(angle - max_a) <= self.max_tolerance

        return is_valid, is_at_min, is_at_max

    def update_state_machine(self, angle: float, side: str) -> bool:
        is_valid, is_at_min, is_at_max = self.validate_angle(angle)

        current = self.state[side]

        if not is_valid:
            if current not in (ExerciseState.MIN_POSITION, ExerciseState.MAX_POSITION):
                self.state[side] = ExerciseState.INVALID
            return False

        new_rep = False

        if self.exercise.continuous_oscillation:
            if is_at_min and current in [ExerciseState.MAX_POSITION, ExerciseState.TRANSITION]:
                self.state[side] = ExerciseState.MIN_POSITION
                self.rep_count[side] += 1
                new_rep = True
            elif is_at_max and current in [ExerciseState.MIN_POSITION, ExerciseState.TRANSITION]:
                self.state[side] = ExerciseState.MAX_POSITION
            elif not is_at_min and not is_at_max:
                self.state[side] = ExerciseState.TRANSITION
        else:
            if is_at_min:
                if self.reached_max[side] and current in (
                    ExerciseState.MAX_POSITION,
                    ExerciseState.TRANSITION,
                ):
                    self.rep_count[side] += 1
                    new_rep = True
                    self.reached_max[side] = False
                self.state[side] = ExerciseState.MIN_POSITION
            elif is_at_max:
                self.reached_max[side] = True
                if current in (
                    ExerciseState.MIN_POSITION,
                    ExerciseState.IDLE,
                    ExerciseState.INVALID,
                    ExerciseState.TRANSITION,
                ):
                    self.state[side] = ExerciseState.MAX_POSITION
            elif is_valid:
                if current in [ExerciseState.MIN_POSITION, ExerciseState.MAX_POSITION]:
                    self.state[side] = ExerciseState.TRANSITION

        return new_rep

    def validate_frame(self, keypoints: np.ndarray, side: str = 'left') -> ValidationResult:
        primary_indices, secondary_indices = self.get_side_adjusted_indices(side)

        if not self.check_keypoint_confidence(keypoints, primary_indices):
            return ValidationResult(
                is_valid=False,
                current_angle=0.0,
                rep_count=self.rep_count[side],
                state=ExerciseState.INVALID,
                feedback=f"Low confidence on {side} {self.exercise.primary_joint.name}",
                side=side,
            )

        primary_angle = self.calculate_angle(
            keypoints[primary_indices[0], :2],
            keypoints[primary_indices[1], :2],
            keypoints[primary_indices[2], :2],
        )

        if self.exercise.secondary_joint and secondary_indices:
            if not self.check_keypoint_confidence(keypoints, secondary_indices):
                return ValidationResult(
                    is_valid=False,
                    current_angle=primary_angle,
                    rep_count=self.rep_count[side],
                    state=ExerciseState.INVALID,
                    feedback=f"Low confidence on {side} {self.exercise.secondary_joint.name}",
                    side=side,
                )

            secondary_angle = self.calculate_angle(
                keypoints[secondary_indices[0], :2],
                keypoints[secondary_indices[1], :2],
                keypoints[secondary_indices[2], :2],
            )

            sec = self.exercise.secondary_joint
            if not (sec.min_angle <= secondary_angle <= sec.max_angle):
                return ValidationResult(
                    is_valid=False,
                    current_angle=primary_angle,
                    rep_count=self.rep_count[side],
                    state=ExerciseState.INVALID,
                    feedback=f"Keep {side} knee extended ({secondary_angle:.1f}°)",
                    side=side,
                )

        self.angle_buffer[side].append(primary_angle)
        if len(self.angle_buffer[side]) > self.buffer_size:
            self.angle_buffer[side].pop(0)
        smoothed = np.mean(self.angle_buffer[side])

        new_rep = self.update_state_machine(smoothed, side)
        is_valid, is_at_min, is_at_max = self.validate_angle(smoothed)

        if new_rep:
            feedback = f"Rep {self.rep_count[side]} complete!"
        elif not is_valid:
            feedback = f"Angle too small ({smoothed:.1f}°)" if smoothed < self.exercise.primary_joint.min_angle else f"Angle too large ({smoothed:.1f}°)"
        elif is_at_min:
            feedback = "At minimum position"
        elif is_at_max:
            feedback = "At maximum position"
        else:
            feedback = "In transition"

        return ValidationResult(
            is_valid=is_valid,
            current_angle=smoothed,
            rep_count=self.rep_count[side],
            state=self.state[side],
            feedback=feedback,
            side=side,
        )

    def reset(self):
        self.state = {'left': ExerciseState.IDLE, 'right': ExerciseState.IDLE}
        self.rep_count = {'left': 0, 'right': 0}
        self.reached_max = {'left': False, 'right': False}
        self.angle_buffer = {'left': [], 'right': []}


class MultiSideValidator:

    def __init__(self, exercise_key: str, confidence_threshold: float = 0.5):
        self.left_validator = ExerciseValidator(exercise_key, confidence_threshold)
        self.right_validator = ExerciseValidator(exercise_key, confidence_threshold)
        self.exercise_key = exercise_key

    def validate_frame(self, keypoints: np.ndarray) -> Dict[str, ValidationResult]:
        return {
            'left': self.left_validator.validate_frame(keypoints, 'left'),
            'right': self.right_validator.validate_frame(keypoints, 'right'),
        }

    def get_total_reps(self) -> int:
        left = self.left_validator.rep_count['left']
        right = self.right_validator.rep_count['right']
        return max(left, right)

    @staticmethod
    def pick_active_side(left: ValidationResult, right: ValidationResult) -> str:
        if left.rep_count > right.rep_count:
            return "left"
        if right.rep_count > left.rep_count:
            return "right"

        left_detected = left.current_angle > 0
        right_detected = right.current_angle > 0
        if left_detected and not right_detected:
            return "left"
        if right_detected and not left_detected:
            return "right"

        if left.is_valid and not right.is_valid:
            return "left"
        if right.is_valid and not left.is_valid:
            return "right"

        return "left" if left.current_angle >= right.current_angle else "right"

    def reset(self):
        self.left_validator.reset()
        self.right_validator.reset()


def get_exercise_list() -> List[str]:
    return list(EXERCISE_RULES.keys())


def get_exercise_info(exercise_key: str) -> Dict:
    if exercise_key not in EXERCISE_RULES:
        raise ValueError(f"Unknown exercise: {exercise_key}")

    exercise = EXERCISE_RULES[exercise_key]
    info = {
        'name': exercise.name,
        'primary_joint': {
            'name': exercise.primary_joint.name,
            'min_angle': exercise.primary_joint.min_angle,
            'max_angle': exercise.primary_joint.max_angle,
        },
        'sides': exercise.sides,
        'continuous_oscillation': exercise.continuous_oscillation,
    }

    if exercise.secondary_joint:
        info['secondary_joint'] = {
            'name': exercise.secondary_joint.name,
            'min_angle': exercise.secondary_joint.min_angle,
            'max_angle': exercise.secondary_joint.max_angle,
        }

    return info
