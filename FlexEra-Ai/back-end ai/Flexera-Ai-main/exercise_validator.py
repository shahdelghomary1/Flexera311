"""
Exercise Validation System using YOLOv8 Pose and Joint Angle Analysis
Supports 8 physical therapy exercises with real-time repetition counting
"""

import numpy as np
from dataclasses import dataclass
from typing import Tuple, Dict, Optional, List
from enum import Enum


class ExerciseState(Enum):
    """Exercise movement states for repetition counting"""
    IDLE = "idle"
    MIN_POSITION = "min"
    TRANSITION = "transition"
    MAX_POSITION = "max"
    INVALID = "invalid"


@dataclass
class JointAngleRule:
    """Defines angle validation rules for a joint"""
    keypoint_indices: Tuple[int, int, int]  # (point_a, joint_b, point_c)
    min_angle: float
    max_angle: float
    name: str


@dataclass
class ExerciseRule:
    """Complete rule definition for an exercise"""
    name: str
    primary_joint: JointAngleRule
    secondary_joint: Optional[JointAngleRule] = None
    sides: List[str] = None  # ['left', 'right'] or ['both']
    continuous_oscillation: bool = False


@dataclass
class ValidationResult:
    """Result of exercise validation"""
    is_valid: bool
    current_angle: float
    rep_count: int
    state: ExerciseState
    feedback: str
    side: str


# YOLOv8 Pose COCO Keypoint Indices
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


# Exercise Rules Dictionary
EXERCISE_RULES = {
    'bending_knee_no_support_seated': ExerciseRule(
        name='Bending knee no support seated',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=70,
            max_angle=180,
            name='knee'
        ),
        sides=['left', 'right']
    ),

    'bending_knee_bed_support_supine': ExerciseRule(
        name='Bending knee with bed support supine',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=60,
            max_angle=150,
            name='knee'
        ),
        sides=['left', 'right']
    ),

    'bending_knee_with_support_seated': ExerciseRule(
        name='Bending knee with support seated',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=80,
            max_angle=160,
            name='knee'
        ),
        sides=['left', 'right']
    ),

    'circular_pendulum_standing': ExerciseRule(
        name='Circular pendulum standing',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow']),
            min_angle=10,
            max_angle=60,
            name='shoulder'
        ),
        sides=['left', 'right'],
        continuous_oscillation=True
    ),

    'external_rotation_shoulders_elastic': ExerciseRule(
        name='External rotation shoulders elastic',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow'], KEYPOINTS['left_wrist']),
            min_angle=70,
            max_angle=110,
            name='elbow'
        ),
        sides=['left', 'right']
    ),

    'horizontal_weighted_openings_standing': ExerciseRule(
        name='Horizontal weighted openings standing',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_elbow'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_hip']),
            min_angle=60,
            max_angle=120,
            name='shoulder'
        ),
        sides=['left', 'right']
    ),

    'lift_extended_leg_supine': ExerciseRule(
        name='Lift extended leg supine',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_shoulder'], KEYPOINTS['left_hip'], KEYPOINTS['left_knee']),
            min_angle=30,
            max_angle=70,
            name='hip'
        ),
        secondary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_knee'], KEYPOINTS['left_ankle']),
            min_angle=160,
            max_angle=180,
            name='knee_extension'
        ),
        sides=['left', 'right']
    ),

    'shoulder_flexion_seated': ExerciseRule(
        name='Shoulder flexion seated',
        primary_joint=JointAngleRule(
            keypoint_indices=(KEYPOINTS['left_hip'], KEYPOINTS['left_shoulder'], KEYPOINTS['left_elbow']),
            min_angle=10,
            max_angle=170,
            name='shoulder'
        ),
        sides=['left', 'right']
    ),
}


class ExerciseValidator:
    """Real-time exercise validation using pose keypoints and angle analysis"""

    def __init__(self, exercise_key: str, confidence_threshold: float = 0.5):
        """
        Initialize validator for a specific exercise

        Args:
            exercise_key: Key from EXERCISE_RULES dictionary
            confidence_threshold: Minimum keypoint confidence to consider valid
        """
        if exercise_key not in EXERCISE_RULES:
            raise ValueError(f"Unknown exercise: {exercise_key}. Available: {list(EXERCISE_RULES.keys())}")

        self.exercise = EXERCISE_RULES[exercise_key]
        self.confidence_threshold = confidence_threshold

        # State tracking for each side
        self.state = {'left': ExerciseState.IDLE, 'right': ExerciseState.IDLE}
        self.rep_count = {'left': 0, 'right': 0}
        self.reached_max = {'left': False, 'right': False}
        self.angle_buffer = {'left': [], 'right': []}
        self.buffer_size = 3

        # Angle tolerance for state detection (degrees)
        self.min_tolerance = 15
        self.max_tolerance = 15
        if self.exercise.primary_joint.name == 'shoulder':
            self.min_tolerance = 25
            self.max_tolerance = 20

    def calculate_angle(self, point_a: np.ndarray, point_b: np.ndarray, point_c: np.ndarray) -> float:
        
        vector_ba = point_a - point_b
        vector_bc = point_c - point_b

        # Calculate angle using dot product
        cos_angle = np.dot(vector_ba, vector_bc) / (
            np.linalg.norm(vector_ba) * np.linalg.norm(vector_bc) + 1e-6
        )

        # Clamp to valid range for arccos
        cos_angle = np.clip(cos_angle, -1.0, 1.0)
        angle = np.degrees(np.arccos(cos_angle))

        return angle

    def check_keypoint_confidence(
        self, keypoints: np.ndarray, indices: Tuple[int, int, int], min_required: int = 2
    ) -> bool:
        confident = sum(
            1 for idx in indices if keypoints[idx, 2] >= self.confidence_threshold
        )
        return confident >= min_required

    def get_side_adjusted_indices(self, side: str) -> Tuple[Tuple[int, int, int], Optional[Tuple[int, int, int]]]:
        
        primary = list(self.exercise.primary_joint.keypoint_indices)
        secondary = None

        if side == 'right':
            # Swap left keypoints to right
            primary = [self._swap_side(idx) for idx in primary]
            if self.exercise.secondary_joint:
                secondary = [self._swap_side(idx) for idx in self.exercise.secondary_joint.keypoint_indices]
        else:
            if self.exercise.secondary_joint:
                secondary = list(self.exercise.secondary_joint.keypoint_indices)

        return tuple(primary), tuple(secondary) if secondary else None

    def _swap_side(self, keypoint_idx: int) -> int:
        """Swap left keypoint index to right equivalent"""
        keypoint_map = {
            1: 2, 2: 1,  # eyes
            3: 4, 4: 3,  # ears
            5: 6, 6: 5,  # shoulders
            7: 8, 8: 7,  # elbows
            9: 10, 10: 9,  # wrists
            11: 12, 12: 11,  # hips
            13: 14, 14: 13,  # knees
            15: 16, 16: 15,  # ankles
        }
        return keypoint_map.get(keypoint_idx, keypoint_idx)

    def validate_angle(self, angle: float) -> Tuple[bool, bool, bool]:
        """
        Check if angle is within valid range and determine position

        Args:
            angle: Current joint angle

        Returns:
            Tuple of (is_valid, is_at_min, is_at_max)
        """
        min_angle = self.exercise.primary_joint.min_angle
        max_angle = self.exercise.primary_joint.max_angle

        is_valid = min_angle <= angle <= max_angle

        if (
            self.exercise.primary_joint.name == 'shoulder'
            and not self.exercise.continuous_oscillation
        ):
            span = max_angle - min_angle
            if span > 0:
                ratio = (angle - min_angle) / span
                is_at_min = ratio <= 0.25
                is_at_max = ratio >= 0.70
            else:
                is_at_min = abs(angle - min_angle) <= self.min_tolerance
                is_at_max = abs(angle - max_angle) <= self.max_tolerance
        else:
            is_at_min = abs(angle - min_angle) <= self.min_tolerance
            is_at_max = abs(angle - max_angle) <= self.max_tolerance

        return is_valid, is_at_min, is_at_max

    def update_state_machine(self, angle: float, side: str) -> bool:
        """
        Update state machine for repetition counting

        Args:
            angle: Current joint angle
            side: 'left' or 'right'

        Returns:
            True if a new repetition was completed
        """
        is_valid, is_at_min, is_at_max = self.validate_angle(angle)

        current_state = self.state[side]

        if not is_valid:
            if current_state not in (ExerciseState.MIN_POSITION, ExerciseState.MAX_POSITION):
                self.state[side] = ExerciseState.INVALID
            return False

        new_rep = False

        if self.exercise.continuous_oscillation:
            # For continuous oscillation (like pendulum), count each direction change
            if is_at_min and current_state in [ExerciseState.MAX_POSITION, ExerciseState.TRANSITION]:
                self.state[side] = ExerciseState.MIN_POSITION
                self.rep_count[side] += 1
                new_rep = True
            elif is_at_max and current_state in [ExerciseState.MIN_POSITION, ExerciseState.TRANSITION]:
                self.state[side] = ExerciseState.MAX_POSITION
            elif not is_at_min and not is_at_max:
                self.state[side] = ExerciseState.TRANSITION
        else:
            # Standard repetition: min -> max -> min counts as 1 rep
            if is_at_min:
                if self.reached_max[side] and current_state in (
                    ExerciseState.MAX_POSITION,
                    ExerciseState.TRANSITION,
                ):
                    self.rep_count[side] += 1
                    new_rep = True
                    self.reached_max[side] = False
                self.state[side] = ExerciseState.MIN_POSITION
            elif is_at_max:
                self.reached_max[side] = True
                if current_state in (
                    ExerciseState.MIN_POSITION,
                    ExerciseState.IDLE,
                    ExerciseState.INVALID,
                    ExerciseState.TRANSITION,
                ):
                    self.state[side] = ExerciseState.MAX_POSITION
            elif is_valid:
                if current_state in [ExerciseState.MIN_POSITION, ExerciseState.MAX_POSITION]:
                    self.state[side] = ExerciseState.TRANSITION

        return new_rep

    def validate_frame(self, keypoints: np.ndarray, side: str = 'left') -> ValidationResult:
        """
        Validate single frame of pose keypoints

        Args:
            keypoints: Array of shape (17, 3) with [x, y, confidence] for each keypoint
            side: Which side to validate ('left' or 'right')

        Returns:
            ValidationResult with angle, rep count, validity, and feedback
        """
        primary_indices, secondary_indices = self.get_side_adjusted_indices(side)

        # Check primary joint confidence
        if not self.check_keypoint_confidence(keypoints, primary_indices):
            return ValidationResult(
                is_valid=False,
                current_angle=0.0,
                rep_count=self.rep_count[side],
                state=ExerciseState.INVALID,
                feedback=f"Low confidence on {side} {self.exercise.primary_joint.name}",
                side=side
            )

        # Extract primary joint points
        point_a = keypoints[primary_indices[0], :2]
        point_b = keypoints[primary_indices[1], :2]
        point_c = keypoints[primary_indices[2], :2]

        # Calculate primary angle
        primary_angle = self.calculate_angle(point_a, point_b, point_c)

        # For lift extended leg, validate secondary joint (knee must stay extended)
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

            # Check if knee is extended
            sec_min = self.exercise.secondary_joint.min_angle
            sec_max = self.exercise.secondary_joint.max_angle
            if not (sec_min <= secondary_angle <= sec_max):
                return ValidationResult(
                    is_valid=False,
                    current_angle=primary_angle,
                    rep_count=self.rep_count[side],
                    state=ExerciseState.INVALID,
                    feedback=f"Keep {side} knee extended ({secondary_angle:.1f}°)",
                    side=side
                )

        # Smooth angle with buffer
        self.angle_buffer[side].append(primary_angle)
        if len(self.angle_buffer[side]) > self.buffer_size:
            self.angle_buffer[side].pop(0)
        smoothed_angle = np.mean(self.angle_buffer[side])

        # Update state machine
        new_rep = self.update_state_machine(smoothed_angle, side)

        # Generate feedback
        is_valid, is_at_min, is_at_max = self.validate_angle(smoothed_angle)

        if new_rep:
            feedback = f"Rep {self.rep_count[side]} complete!"
        elif not is_valid:
            if smoothed_angle < self.exercise.primary_joint.min_angle:
                feedback = f"Angle too small ({smoothed_angle:.1f}°)"
            else:
                feedback = f"Angle too large ({smoothed_angle:.1f}°)"
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
        """Reset all counters and state"""
        self.state = {'left': ExerciseState.IDLE, 'right': ExerciseState.IDLE}
        self.rep_count = {'left': 0, 'right': 0}
        self.reached_max = {'left': False, 'right': False}
        self.angle_buffer = {'left': [], 'right': []}


class MultiSideValidator:
    """Wrapper to validate both sides simultaneously"""

    def __init__(self, exercise_key: str, confidence_threshold: float = 0.5):
        self.left_validator = ExerciseValidator(exercise_key, confidence_threshold)
        self.right_validator = ExerciseValidator(exercise_key, confidence_threshold)
        self.exercise_key = exercise_key

    def validate_frame(self, keypoints: np.ndarray) -> Dict[str, ValidationResult]:
        """
        Validate both sides in a single frame

        Args:
            keypoints: Array of shape (17, 3) with [x, y, confidence]

        Returns:
            Dictionary with 'left' and 'right' ValidationResult objects
        """
        results = {
            'left': self.left_validator.validate_frame(keypoints, 'left'),
            'right': self.right_validator.validate_frame(keypoints, 'right')
        }
        return results

    def get_total_reps(self) -> int:
        """Reps on the active limb (max of left/right for unilateral exercises)."""
        left = self.left_validator.rep_count['left']
        right = self.right_validator.rep_count['right']
        return max(left, right)

    @staticmethod
    def pick_active_side(left: ValidationResult, right: ValidationResult) -> str:
        """Pick the side that is actually being exercised (not always left)."""
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
        """Reset both validators"""
        self.left_validator.reset()
        self.right_validator.reset()


def get_exercise_list() -> List[str]:
    """Get list of all available exercise keys"""
    return list(EXERCISE_RULES.keys())


def get_exercise_info(exercise_key: str) -> Dict:
    """
    Get detailed information about an exercise

    Args:
        exercise_key: Key from EXERCISE_RULES

    Returns:
        Dictionary with exercise details
    """
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


if __name__ == "__main__":
    # Example usage
    print("Available Exercises:")
    print("=" * 60)
    for i, key in enumerate(get_exercise_list(), 1):
        info = get_exercise_info(key)
        print(f"{i}. {info['name']}")
        print(f"   Joint: {info['primary_joint']['name']}")
        print(f"   Range: {info['primary_joint']['min_angle']}° - {info['primary_joint']['max_angle']}°")
        print()
