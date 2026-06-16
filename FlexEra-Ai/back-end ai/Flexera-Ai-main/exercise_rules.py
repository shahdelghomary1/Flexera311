from dataclasses import dataclass
from typing import Tuple, List, Dict


@dataclass
class ErrorDetection:
    error_type: str
    severity: str
    recommendation: str
    joint_name: str
    current_value: float
    expected_range: Tuple[float, float]


EXERCISE_CAMERA_CONFIG = {
    'bending_knee_no_support_seated': {
        'focus_area': 'lower_body',
        'zoom_level': 0.6,
        'key_landmarks': [11, 12, 13, 14, 15, 16],  # hips, knees, ankles
        'camera_hint': "Position camera to show your full legs while seated"
    },
    'bending_knee_bed_support_supine': {
        'focus_area': 'lower_body',
        'zoom_level': 0.5,
        'key_landmarks': [11, 12, 13, 14, 15, 16],  # hips, knees, ankles
        'camera_hint': "Position camera at your side to show your full leg"
    },
    'bending_knee_with_support_seated': {
        'focus_area': 'lower_body',
        'zoom_level': 0.6,
        'key_landmarks': [11, 12, 13, 14, 15, 16],  # hips, knees, ankles
        'camera_hint': "Position camera to show your legs while seated"
    },
    'circular_pendulum_standing': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [5, 6, 7, 8, 9, 10],  # shoulders, elbows, wrists
        'camera_hint': "Position camera to show your upper body and arms"
    },
    'external_rotation_shoulders_elastic': {
        'focus_area': 'upper_body',
        'zoom_level': 0.6,
        'key_landmarks': [5, 6, 7, 8, 9, 10],  # shoulders, elbows, wrists
        'camera_hint': "Position camera to clearly show your arms and elbows"
    },
    'horizontal_weighted_openings_standing': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [5, 6, 7, 8, 9, 10],  # shoulders, elbows, wrists
        'camera_hint': "Stand back so camera shows your full arm span"
    },
    'lift_extended_leg_supine': {
        'focus_area': 'full_body',
        'zoom_level': 0.8,
        'key_landmarks': [11, 12, 13, 14, 15, 16],  # hips, knees, ankles
        'camera_hint': "Position camera at your side to show your full body lying down"
    },
    'shoulder_flexion_seated': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [5, 6, 7, 8, 9, 10, 11, 12],  # shoulders, elbows, wrists, hips
        'camera_hint': "Position camera to show your full arm movement overhead"
    }
}


# Exercise instructions for starting and how-to guide
EXERCISE_INSTRUCTIONS = {
    'bending_knee_no_support_seated': {
        'name': "Knee Bending - Seated Without Support",
        'starting_position': [
            "Sit on a chair with your back straight",
            "Keep your feet flat on the floor",
            "Hold the sides of the chair for balance"
        ],
        'how_to': [
            "Slowly lift one foot off the floor",
            "Straighten your leg until it is parallel to the ground",
            "Hold for 2 seconds",
            "Slowly bend your knee and lower your foot back down",
            "Repeat with the same leg or alternate"
        ],
        'tips': [
            "Keep your back against the chair",
            "Move slowly and controlled",
            "Do not lock your knee at full extension"
        ],
        'voice_intro': "Knee bending exercise, seated without support. Sit with your back straight and feet flat on the floor."
    },
    'bending_knee_bed_support_supine': {
        'name': "Knee Bending - Lying Down With Support",
        'starting_position': [
            "Lie on your back on a bed or mat",
            "Keep your legs straight",
            "Arms at your sides for support"
        ],
        'how_to': [
            "Slowly slide one heel toward your buttocks",
            "Bend your knee as far as comfortable",
            "Hold for 2 seconds",
            "Slowly slide your heel back to straighten your leg",
            "Repeat with the same leg"
        ],
        'tips': [
            "Keep your lower back pressed to the surface",
            "Move smoothly without jerking",
            "Use the bed surface to support your leg"
        ],
        'voice_intro': "Knee bending exercise, lying down. Lie on your back with legs straight and arms at your sides."
    },
    'bending_knee_with_support_seated': {
        'name': "Knee Bending - Seated With Support",
        'starting_position': [
            "Sit on a chair with back support",
            "Keep your feet flat on the floor",
            "Use a towel under your thigh if needed"
        ],
        'how_to': [
            "Slowly extend one leg forward",
            "Straighten your knee as much as possible",
            "Hold for 2 seconds",
            "Slowly lower your foot back to the floor",
            "Repeat with the same leg"
        ],
        'tips': [
            "Use the chair support to maintain posture",
            "Focus on controlled movement",
            "Breathe normally throughout"
        ],
        'voice_intro': "Knee bending with support. Sit with back support and feet flat on the floor."
    },
    'circular_pendulum_standing': {
        'name': "Circular Pendulum - Standing",
        'starting_position': [
            "Stand next to a table or chair for support",
            "Bend forward slightly at the waist",
            "Let your arm hang down freely"
        ],
        'how_to': [
            "Gently swing your arm in small circles",
            "Start with clockwise circles",
            "Keep the circles small and controlled",
            "After 10 circles, switch to counter-clockwise",
            "Keep your arm relaxed throughout"
        ],
        'tips': [
            "Use your body to create momentum, not your shoulder",
            "Keep circles small, about 30 centimeters",
            "Stay relaxed, do not tense your shoulder"
        ],
        'voice_intro': "Circular pendulum exercise. Stand with support and let your arm hang freely."
    },
    'external_rotation_shoulders_elastic': {
        'name': "External Rotation With Elastic Band",
        'starting_position': [
            "Stand or sit with good posture",
            "Hold the elastic band with both hands",
            "Keep your elbows at your sides, bent at 90 degrees"
        ],
        'how_to': [
            "Keep your elbows tucked to your sides",
            "Slowly rotate your forearms outward",
            "Stretch the band by moving hands apart",
            "Hold for 2 seconds at maximum rotation",
            "Slowly return to starting position"
        ],
        'tips': [
            "Keep elbows glued to your sides",
            "Do not let elbows drift forward",
            "Control the band on the way back"
        ],
        'voice_intro': "External rotation with elastic band. Hold the band with elbows at your sides, bent at 90 degrees."
    },
    'horizontal_weighted_openings_standing': {
        'name': "Horizontal Openings With Weights",
        'starting_position': [
            "Stand with feet shoulder-width apart",
            "Hold light weights in each hand",
            "Extend arms forward at shoulder height"
        ],
        'how_to': [
            "Start with arms extended in front of you",
            "Slowly open your arms out to the sides",
            "Keep arms at shoulder height throughout",
            "Stop when arms are in line with your body",
            "Slowly bring arms back together"
        ],
        'tips': [
            "Keep a slight bend in your elbows",
            "Do not arch your back",
            "Move slowly and with control"
        ],
        'voice_intro': "Horizontal openings with weights. Stand with arms extended forward at shoulder height."
    },
    'lift_extended_leg_supine': {
        'name': "Straight Leg Raise - Lying Down",
        'starting_position': [
            "Lie on your back on a firm surface",
            "Keep one leg bent with foot flat",
            "Keep the other leg straight"
        ],
        'how_to': [
            "Tighten the thigh muscle of your straight leg",
            "Slowly lift the straight leg up",
            "Raise to about 45 degrees",
            "Hold for 2 seconds",
            "Slowly lower back down"
        ],
        'tips': [
            "Keep your leg completely straight",
            "Do not bend your knee while lifting",
            "Keep your lower back pressed to the floor"
        ],
        'voice_intro': "Straight leg raise. Lie on your back with one leg bent and one leg straight."
    },
    'shoulder_flexion_seated': {
        'name': "Shoulder Flexion - Seated",
        'starting_position': [
            "Sit on a chair with back support",
            "Keep your feet flat on the floor",
            "Arms resting at your sides"
        ],
        'how_to': [
            "Keep your arm straight",
            "Slowly raise your arm forward and up",
            "Continue until arm is overhead",
            "Hold for 2 seconds",
            "Slowly lower your arm back down"
        ],
        'tips': [
            "Keep your elbow straight but not locked",
            "Do not arch your back as you lift",
            "Move smoothly through the full range"
        ],
        'voice_intro': "Shoulder flexion, seated. Sit with back support and arms at your sides."
    }
}


# Skeleton connections for drawing landmarks
SKELETON_CONNECTIONS = [
    # Face
    (0, 1), (0, 2), (1, 3), (2, 4),
    # Upper body
    (5, 6),   # shoulders
    (5, 7), (7, 9),   # left arm
    (6, 8), (8, 10),  # right arm
    # Torso
    (5, 11), (6, 12), (11, 12),
    # Lower body
    (11, 13), (13, 15),  # left leg
    (12, 14), (14, 16)   # right leg
]

# Landmark names for reference
LANDMARK_NAMES = {
    0: 'nose', 1: 'left_eye', 2: 'right_eye', 3: 'left_ear', 4: 'right_ear',
    5: 'left_shoulder', 6: 'right_shoulder', 7: 'left_elbow', 8: 'right_elbow',
    9: 'left_wrist', 10: 'right_wrist', 11: 'left_hip', 12: 'right_hip',
    13: 'left_knee', 14: 'right_knee', 15: 'left_ankle', 16: 'right_ankle'
}


EXERCISE_RULES = {
    'bending_knee_no_support_seated': {
        'joint': 'knee',
        'min_angle': 70,
        'max_angle': 180,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Bend your knee more",
                'severity': 'medium'
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not over-bend your knee",
                'severity': 'high'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 20,
                'recommendation': "Straighten your leg fully",
                'severity': 'medium'
            },
            'excessive_extension': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 5,
                'recommendation': "Relax your knee slightly",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },

    'bending_knee_bed_support_supine': {
        'joint': 'knee',
        'min_angle': 60,
        'max_angle': 150,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your knee closer to your chest",
                'severity': 'medium'
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not pull your knee too close",
                'severity': 'high'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Extend your leg more",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },

    'bending_knee_with_support_seated': {
        'joint': 'knee',
        'min_angle': 80,
        'max_angle': 160,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your knee a bit more",
                'severity': 'medium'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Straighten your leg more",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },

    'circular_pendulum_standing': {
        'joint': 'shoulder',
        'min_angle': 10,
        'max_angle': 60,
        'errors': {
            'excessive_motion': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Make smaller circles with your arm",
                'severity': 'medium'
            },
            'insufficient_motion': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 5,
                'recommendation': "Move your arm in a bigger circle",
                'severity': 'low'
            },
            'stopped_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Keep your arm moving gently",
                'severity': 'medium'
            }
        },
        'continuous_motion': True,
        'movement_speed_check': False
    },

    'external_rotation_shoulders_elastic': {
        'joint': 'elbow',
        'min_angle': 70,
        'max_angle': 110,
        'errors': {
            'elbow_too_open': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Keep your elbow closer to your body",
                'severity': 'high'
            },
            'elbow_too_closed': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Open your elbow slightly",
                'severity': 'medium'
            },
            'fast_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Control the elastic band slowly",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },

    'horizontal_weighted_openings_standing': {
        'joint': 'shoulder',
        'min_angle': 60,
        'max_angle': 120,
        'errors': {
            'insufficient_opening': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Open your arms wider",
                'severity': 'medium'
            },
            'excessive_opening': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not over-extend your arms",
                'severity': 'high'
            },
            'insufficient_closing': {
                'condition': lambda angle, min_a, max_a: angle > max_a - 10,
                'recommendation': "Bring your arms closer together",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },

    'lift_extended_leg_supine': {
        'joint': 'hip',
        'min_angle': 30,
        'max_angle': 70,
        'secondary_joint': 'knee',
        'secondary_min': 160,
        'secondary_max': 180,
        'errors': {
            'leg_not_straight': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Keep your leg straight",
                'severity': 'high'
            },
            'insufficient_lift': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Lift your leg higher",
                'severity': 'medium'
            },
            'excessive_lift': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not raise your leg too high",
                'severity': 'high'
            },
            'leg_lowered_incomplete': {
                'condition': lambda angle, min_a, max_a: angle > min_a - 5,
                'recommendation': "Lower your leg completely",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },

    'shoulder_flexion_seated': {
        'joint': 'shoulder',
        'min_angle': 10,
        'max_angle': 170,
        'errors': {
            'insufficient_raise': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 30,
                'recommendation': "Lift your arm higher",
                'severity': 'medium'
            },
            'excessive_raise': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 15,
                'recommendation': "Lower your arm slightly",
                'severity': 'low'
            },
            'incomplete_lowering': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Lower your arm completely",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    }
}
