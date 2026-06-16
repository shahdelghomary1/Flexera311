from dataclasses import dataclass
from typing import Tuple


@dataclass
class ErrorDetection:
    error_type: str
    severity: str
    recommendation: str
    joint_name: str
    current_value: float
    expected_range: Tuple[float, float]


EXERCISE_CAMERA_CONFIG = {
    # Lower Left Exercises
    'bending_knee_no_support_seated_left': {
        'focus_area': 'lower_body',
        'zoom_level': 0.6,
        'key_landmarks': [11, 13, 15],  # Left hip, knee, ankle
        'camera_hint': "Position camera to show your left leg while seated",
    },
    'bending_knee_with_support_seated_left': {
        'focus_area': 'lower_body',
        'zoom_level': 0.6,
        'key_landmarks': [11, 13, 15],  # Left hip, knee, ankle
        'camera_hint': "Position camera to show your left leg while seated with support",
    },
    'lift_extended_leg_supine_left': {
        'focus_area': 'full_body',
        'zoom_level': 0.8,
        'key_landmarks': [11, 13, 15],  # Left hip, knee, ankle
        'camera_hint': "Position camera at your right side to show your left leg lying down",
    },
    'bending_knee_bed_support_supine_left': {
        'focus_area': 'lower_body',
        'zoom_level': 0.5,
        'key_landmarks': [11, 13, 15],  # Left hip, knee, ankle
        'camera_hint': "Position camera at your right side to show your left leg",
    },
    
    # Lower Right Exercises
    'bending_knee_no_support_seated_right': {
        'focus_area': 'lower_body',
        'zoom_level': 0.6,
        'key_landmarks': [12, 14, 16],  # Right hip, knee, ankle
        'camera_hint': "Position camera to show your right leg while seated",
    },
    'bending_knee_with_support_seated_right': {
        'focus_area': 'lower_body',
        'zoom_level': 0.6,
        'key_landmarks': [12, 14, 16],  # Right hip, knee, ankle
        'camera_hint': "Position camera to show your right leg while seated with support",
    },
    'lift_extended_leg_supine_right': {
        'focus_area': 'full_body',
        'zoom_level': 0.8,
        'key_landmarks': [12, 14, 16],  # Right hip, knee, ankle
        'camera_hint': "Position camera at your left side to show your right leg lying down",
    },
    'bending_knee_bed_support_supine_right': {
        'focus_area': 'lower_body',
        'zoom_level': 0.5,
        'key_landmarks': [12, 14, 16],  # Right hip, knee, ankle
        'camera_hint': "Position camera at your left side to show your right leg",
    },
    
    # Upper Left Exercises
    'shoulder_flexion_seated_left': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [5, 7, 9, 11],  # Left shoulder, elbow, wrist, hip
        'camera_hint': "Position camera to show your left arm movement overhead",
    },
    'horizontal_weighted_openings_standing_left': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [5, 7, 9],  # Left shoulder, elbow, wrist
        'camera_hint': "Stand back so camera shows your left arm movement",
    },
    'external_rotation_shoulders_elastic_left': {
        'focus_area': 'upper_body',
        'zoom_level': 0.6,
        'key_landmarks': [5, 7, 9],  # Left shoulder, elbow, wrist
        'camera_hint': "Position camera to clearly show your left arm and elbow",
    },
    'circular_pendulum_standing_left': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [5, 7, 9],  # Left shoulder, elbow, wrist
        'camera_hint': "Position camera to show your left arm pendulum movement",
    },
    
    # Upper Right Exercises
    'shoulder_flexion_seated_right': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [6, 8, 10, 12],  # Right shoulder, elbow, wrist, hip
        'camera_hint': "Position camera to show your right arm movement overhead",
    },
    'horizontal_weighted_openings_standing_right': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [6, 8, 10],  # Right shoulder, elbow, wrist
        'camera_hint': "Stand back so camera shows your right arm movement",
    },
    'external_rotation_shoulders_elastic_right': {
        'focus_area': 'upper_body',
        'zoom_level': 0.6,
        'key_landmarks': [6, 8, 10],  # Right shoulder, elbow, wrist
        'camera_hint': "Position camera to clearly show your right arm and elbow",
    },
    'circular_pendulum_standing_right': {
        'focus_area': 'upper_body',
        'zoom_level': 0.7,
        'key_landmarks': [6, 8, 10],  # Right shoulder, elbow, wrist
        'camera_hint': "Position camera to show your right arm pendulum movement",
    },
}


EXERCISE_INSTRUCTIONS = {
    # Lower Left Exercises
    'bending_knee_no_support_seated_left': {
        'name': "Left Knee Bending - Seated Without Support",
        'starting_position': [
            "Sit on a chair with your back straight",
            "Keep your right foot flat on the floor for stability",
            "Hold the sides of the chair for balance",
        ],
        'how_to': [
            "Slowly lift your left foot off the floor",
            "Straighten your left leg until it is parallel to the ground",
            "Hold for 2 seconds",
            "Slowly bend your left knee and lower your foot back down",
            "Repeat with your left leg",
        ],
        'tips': [
            "Keep your back against the chair",
            "Move slowly and controlled",
            "Do not lock your left knee at full extension",
        ],
        'voice_intro': "Left knee bending exercise, seated without support. Focus on your left leg movement.",
    },
    'bending_knee_with_support_seated_left': {
        'name': "Left Knee Bending - Seated With Support",
        'starting_position': [
            "Sit on a chair with back support",
            "Keep your right foot flat on the floor",
            "Use a towel under your left thigh if needed",
        ],
        'how_to': [
            "Slowly extend your left leg forward",
            "Straighten your left knee as much as possible",
            "Hold for 2 seconds",
            "Slowly lower your left foot back to the floor",
            "Repeat with your left leg",
        ],
        'tips': [
            "Use the chair support to maintain posture",
            "Focus on controlled left leg movement",
            "Breathe normally throughout",
        ],
        'voice_intro': "Left knee bending with support. Focus on your left leg extension.",
    },
    'lift_extended_leg_supine_left': {
        'name': "Left Straight Leg Raise - Lying Down",
        'starting_position': [
            "Lie on your back on a firm surface",
            "Keep your right leg bent with foot flat",
            "Keep your left leg straight",
        ],
        'how_to': [
            "Tighten the thigh muscle of your left leg",
            "Slowly lift your left leg up",
            "Raise to about 45 degrees",
            "Hold for 2 seconds",
            "Slowly lower your left leg back down",
        ],
        'tips': [
            "Keep your left leg completely straight",
            "Do not bend your left knee while lifting",
            "Keep your lower back pressed to the floor",
        ],
        'voice_intro': "Left straight leg raise. Focus on lifting your left leg while keeping it straight.",
    },
    'bending_knee_bed_support_supine_left': {
        'name': "Left Knee Bending - Lying Down With Support",
        'starting_position': [
            "Lie on your back on a bed or mat",
            "Keep your right leg straight or slightly bent",
            "Arms at your sides for support",
        ],
        'how_to': [
            "Slowly slide your left heel toward your buttocks",
            "Bend your left knee as far as comfortable",
            "Hold for 2 seconds",
            "Slowly slide your left heel back to straighten your leg",
            "Repeat with your left leg",
        ],
        'tips': [
            "Keep your lower back pressed to the surface",
            "Move your left leg smoothly without jerking",
            "Use the bed surface to support your movement",
        ],
        'voice_intro': "Left knee bending exercise, lying down. Focus on your left leg movement.",
    },

    # Lower Right Exercises
    'bending_knee_no_support_seated_right': {
        'name': "Right Knee Bending - Seated Without Support",
        'starting_position': [
            "Sit on a chair with your back straight",
            "Keep your left foot flat on the floor for stability",
            "Hold the sides of the chair for balance",
        ],
        'how_to': [
            "Slowly lift your right foot off the floor",
            "Straighten your right leg until it is parallel to the ground",
            "Hold for 2 seconds",
            "Slowly bend your right knee and lower your foot back down",
            "Repeat with your right leg",
        ],
        'tips': [
            "Keep your back against the chair",
            "Move slowly and controlled",
            "Do not lock your right knee at full extension",
        ],
        'voice_intro': "Right knee bending exercise, seated without support. Focus on your right leg movement.",
    },
    'bending_knee_with_support_seated_right': {
        'name': "Right Knee Bending - Seated With Support",
        'starting_position': [
            "Sit on a chair with back support",
            "Keep your left foot flat on the floor",
            "Use a towel under your right thigh if needed",
        ],
        'how_to': [
            "Slowly extend your right leg forward",
            "Straighten your right knee as much as possible",
            "Hold for 2 seconds",
            "Slowly lower your right foot back to the floor",
            "Repeat with your right leg",
        ],
        'tips': [
            "Use the chair support to maintain posture",
            "Focus on controlled right leg movement",
            "Breathe normally throughout",
        ],
        'voice_intro': "Right knee bending with support. Focus on your right leg extension.",
    },
    'lift_extended_leg_supine_right': {
        'name': "Right Straight Leg Raise - Lying Down",
        'starting_position': [
            "Lie on your back on a firm surface",
            "Keep your left leg bent with foot flat",
            "Keep your right leg straight",
        ],
        'how_to': [
            "Tighten the thigh muscle of your right leg",
            "Slowly lift your right leg up",
            "Raise to about 45 degrees",
            "Hold for 2 seconds",
            "Slowly lower your right leg back down",
        ],
        'tips': [
            "Keep your right leg completely straight",
            "Do not bend your right knee while lifting",
            "Keep your lower back pressed to the floor",
        ],
        'voice_intro': "Right straight leg raise. Focus on lifting your right leg while keeping it straight.",
    },
    'bending_knee_bed_support_supine_right': {
        'name': "Right Knee Bending - Lying Down With Support",
        'starting_position': [
            "Lie on your back on a bed or mat",
            "Keep your left leg straight or slightly bent",
            "Arms at your sides for support",
        ],
        'how_to': [
            "Slowly slide your right heel toward your buttocks",
            "Bend your right knee as far as comfortable",
            "Hold for 2 seconds",
            "Slowly slide your right heel back to straighten your leg",
            "Repeat with your right leg",
        ],
        'tips': [
            "Keep your lower back pressed to the surface",
            "Move your right leg smoothly without jerking",
            "Use the bed surface to support your movement",
        ],
        'voice_intro': "Right knee bending exercise, lying down. Focus on your right leg movement.",
    },

    # Upper Left Exercises
    'shoulder_flexion_seated_left': {
        'name': "Left Shoulder Flexion - Seated",
        'starting_position': [
            "Sit on a chair with back support",
            "Keep your feet flat on the floor",
            "Rest your right arm at your side",
        ],
        'how_to': [
            "Keep your left arm straight",
            "Slowly raise your left arm forward and up",
            "Continue until your left arm is overhead",
            "Hold for 2 seconds",
            "Slowly lower your left arm back down",
        ],
        'tips': [
            "Keep your left elbow straight but not locked",
            "Do not arch your back as you lift",
            "Move your left arm smoothly through the full range",
        ],
        'voice_intro': "Left shoulder flexion, seated. Focus on raising your left arm overhead.",
    },
    'horizontal_weighted_openings_standing_left': {
        'name': "Left Horizontal Openings With Weights",
        'starting_position': [
            "Stand with feet shoulder-width apart",
            "Hold a light weight in your left hand",
            "Extend your left arm forward at shoulder height",
        ],
        'how_to': [
            "Start with your left arm extended in front of you",
            "Slowly open your left arm out to the side",
            "Keep your left arm at shoulder height throughout",
            "Stop when your left arm is in line with your body",
            "Slowly bring your left arm back to center",
        ],
        'tips': [
            "Keep a slight bend in your left elbow",
            "Do not arch your back",
            "Move your left arm slowly and with control",
        ],
        'voice_intro': "Left horizontal openings with weight. Focus on your left arm movement.",
    },
    'external_rotation_shoulders_elastic_left': {
        'name': "Left External Rotation With Elastic Band",
        'starting_position': [
            "Stand or sit with good posture",
            "Hold the elastic band with your left hand",
            "Keep your left elbow at your side, bent at 90 degrees",
        ],
        'how_to': [
            "Keep your left elbow tucked to your side",
            "Slowly rotate your left forearm outward",
            "Stretch the band by moving your left hand away",
            "Hold for 2 seconds at maximum rotation",
            "Slowly return to starting position",
        ],
        'tips': [
            "Keep your left elbow glued to your side",
            "Do not let your left elbow drift forward",
            "Control the band on the way back",
        ],
        'voice_intro': "Left external rotation with elastic band. Focus on your left arm rotation.",
    },
    'circular_pendulum_standing_left': {
        'name': "Left Circular Pendulum - Standing",
        'starting_position': [
            "Stand next to a table or chair for support with your right hand",
            "Bend forward slightly at the waist",
            "Let your left arm hang down freely",
        ],
        'how_to': [
            "Gently swing your left arm in small circles",
            "Start with clockwise circles",
            "Keep the circles small and controlled",
            "After 10 circles, switch to counter-clockwise",
            "Keep your left arm relaxed throughout",
        ],
        'tips': [
            "Use your body to create momentum, not your left shoulder",
            "Keep circles small, about 30 centimeters",
            "Stay relaxed, do not tense your left shoulder",
        ],
        'voice_intro': "Left circular pendulum exercise. Let your left arm hang freely and create small circles.",
    },

    # Upper Right Exercises
    'shoulder_flexion_seated_right': {
        'name': "Right Shoulder Flexion - Seated",
        'starting_position': [
            "Sit on a chair with back support",
            "Keep your feet flat on the floor",
            "Rest your left arm at your side",
        ],
        'how_to': [
            "Keep your right arm straight",
            "Slowly raise your right arm forward and up",
            "Continue until your right arm is overhead",
            "Hold for 2 seconds",
            "Slowly lower your right arm back down",
        ],
        'tips': [
            "Keep your right elbow straight but not locked",
            "Do not arch your back as you lift",
            "Move your right arm smoothly through the full range",
        ],
        'voice_intro': "Right shoulder flexion, seated. Focus on raising your right arm overhead.",
    },
    'horizontal_weighted_openings_standing_right': {
        'name': "Right Horizontal Openings With Weights",
        'starting_position': [
            "Stand with feet shoulder-width apart",
            "Hold a light weight in your right hand",
            "Extend your right arm forward at shoulder height",
        ],
        'how_to': [
            "Start with your right arm extended in front of you",
            "Slowly open your right arm out to the side",
            "Keep your right arm at shoulder height throughout",
            "Stop when your right arm is in line with your body",
            "Slowly bring your right arm back to center",
        ],
        'tips': [
            "Keep a slight bend in your right elbow",
            "Do not arch your back",
            "Move your right arm slowly and with control",
        ],
        'voice_intro': "Right horizontal openings with weight. Focus on your right arm movement.",
    },
    'external_rotation_shoulders_elastic_right': {
        'name': "Right External Rotation With Elastic Band",
        'starting_position': [
            "Stand or sit with good posture",
            "Hold the elastic band with your right hand",
            "Keep your right elbow at your side, bent at 90 degrees",
        ],
        'how_to': [
            "Keep your right elbow tucked to your side",
            "Slowly rotate your right forearm outward",
            "Stretch the band by moving your right hand away",
            "Hold for 2 seconds at maximum rotation",
            "Slowly return to starting position",
        ],
        'tips': [
            "Keep your right elbow glued to your side",
            "Do not let your right elbow drift forward",
            "Control the band on the way back",
        ],
        'voice_intro': "Right external rotation with elastic band. Focus on your right arm rotation.",
    },
    'circular_pendulum_standing_right': {
        'name': "Right Circular Pendulum - Standing",
        'starting_position': [
            "Stand next to a table or chair for support with your left hand",
            "Bend forward slightly at the waist",
            "Let your right arm hang down freely",
        ],
        'how_to': [
            "Gently swing your right arm in small circles",
            "Start with clockwise circles",
            "Keep the circles small and controlled",
            "After 10 circles, switch to counter-clockwise",
            "Keep your right arm relaxed throughout",
        ],
        'tips': [
            "Use your body to create momentum, not your right shoulder",
            "Keep circles small, about 30 centimeters",
            "Stay relaxed, do not tense your right shoulder",
        ],
        'voice_intro': "Right circular pendulum exercise. Let your right arm hang freely and create small circles.",
    },
}


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
    # Lower Left Exercises
    'bending_knee_no_support_seated_left': {
        'joint': 'left_knee',
        'min_angle': 70,
        'max_angle': 180,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Bend your left knee more",
                'severity': 'medium'
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not over-bend your left knee",
                'severity': 'high'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 20,
                'recommendation': "Straighten your left leg fully",
                'severity': 'medium'
            },
            'excessive_extension': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 5,
                'recommendation': "Relax your left knee slightly",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'bending_knee_with_support_seated_left': {
        'joint': 'left_knee',
        'min_angle': 80,
        'max_angle': 160,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your left knee a bit more",
                'severity': 'medium'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Straighten your left leg more",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'lift_extended_leg_supine_left': {
        'joint': 'left_hip',
        'min_angle': 30,
        'max_angle': 70,
        'secondary_joint': 'left_knee',
        'secondary_min': 160,
        'secondary_max': 180,
        'errors': {
            'leg_not_straight': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Keep your left leg straight",
                'severity': 'high'
            },
            'insufficient_lift': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Lift your left leg higher",
                'severity': 'medium'
            },
            'excessive_lift': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not raise your left leg too high",
                'severity': 'high'
            },
            'leg_lowered_incomplete': {
                'condition': lambda angle, min_a, max_a: angle > min_a - 5,
                'recommendation': "Lower your left leg completely",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },
    'bending_knee_bed_support_supine_left': {
        'joint': 'left_knee',
        'min_angle': 60,
        'max_angle': 150,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your left knee closer to your chest",
                'severity': 'medium'
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not pull your left knee too close",
                'severity': 'high'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Extend your left leg more",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },

    # Lower Right Exercises
    'bending_knee_no_support_seated_right': {
        'joint': 'right_knee',
        'min_angle': 70,
        'max_angle': 180,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Bend your right knee more",
                'severity': 'medium'
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not over-bend your right knee",
                'severity': 'high'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 20,
                'recommendation': "Straighten your right leg fully",
                'severity': 'medium'
            },
            'excessive_extension': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 5,
                'recommendation': "Relax your right knee slightly",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'bending_knee_with_support_seated_right': {
        'joint': 'right_knee',
        'min_angle': 80,
        'max_angle': 160,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your right knee a bit more",
                'severity': 'medium'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Straighten your right leg more",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'lift_extended_leg_supine_right': {
        'joint': 'right_hip',
        'min_angle': 30,
        'max_angle': 70,
        'secondary_joint': 'right_knee',
        'secondary_min': 160,
        'secondary_max': 180,
        'errors': {
            'leg_not_straight': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Keep your right leg straight",
                'severity': 'high'
            },
            'insufficient_lift': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Lift your right leg higher",
                'severity': 'medium'
            },
            'excessive_lift': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not raise your right leg too high",
                'severity': 'high'
            },
            'leg_lowered_incomplete': {
                'condition': lambda angle, min_a, max_a: angle > min_a - 5,
                'recommendation': "Lower your right leg completely",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },
    'bending_knee_bed_support_supine_right': {
        'joint': 'right_knee',
        'min_angle': 60,
        'max_angle': 150,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your right knee closer to your chest",
                'severity': 'medium'
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not pull your right knee too close",
                'severity': 'high'
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Extend your right leg more",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },

    # Upper Left Exercises
    'shoulder_flexion_seated_left': {
        'joint': 'left_shoulder',
        'min_angle': 10,
        'max_angle': 170,
        'errors': {
            'insufficient_raise': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 30,
                'recommendation': "Lift your left arm higher",
                'severity': 'medium'
            },
            'excessive_raise': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 15,
                'recommendation': "Lower your left arm slightly",
                'severity': 'low'
            },
            'incomplete_lowering': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Lower your left arm completely",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'horizontal_weighted_openings_standing_left': {
        'joint': 'left_shoulder',
        'min_angle': 60,
        'max_angle': 120,
        'errors': {
            'insufficient_opening': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Open your left arm wider",
                'severity': 'medium'
            },
            'excessive_opening': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not over-extend your left arm",
                'severity': 'high'
            },
            'insufficient_closing': {
                'condition': lambda angle, min_a, max_a: angle > max_a - 10,
                'recommendation': "Bring your left arm closer to center",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'external_rotation_shoulders_elastic_left': {
        'joint': 'left_elbow',
        'min_angle': 70,
        'max_angle': 110,
        'errors': {
            'elbow_too_open': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Keep your left elbow closer to your body",
                'severity': 'high'
            },
            'elbow_too_closed': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Open your left elbow slightly",
                'severity': 'medium'
            },
            'fast_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Control the elastic band slowly with your left arm",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },
    'circular_pendulum_standing_left': {
        'joint': 'left_shoulder',
        'min_angle': 10,
        'max_angle': 60,
        'errors': {
            'excessive_motion': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Make smaller circles with your left arm",
                'severity': 'medium'
            },
            'insufficient_motion': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 5,
                'recommendation': "Move your left arm in a bigger circle",
                'severity': 'low'
            },
            'stopped_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Keep your left arm moving gently",
                'severity': 'medium'
            }
        },
        'continuous_motion': True,
        'movement_speed_check': False
    },

    # Upper Right Exercises
    'shoulder_flexion_seated_right': {
        'joint': 'right_shoulder',
        'min_angle': 10,
        'max_angle': 170,
        'errors': {
            'insufficient_raise': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 30,
                'recommendation': "Lift your right arm higher",
                'severity': 'medium'
            },
            'excessive_raise': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 15,
                'recommendation': "Lower your right arm slightly",
                'severity': 'low'
            },
            'incomplete_lowering': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Lower your right arm completely",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'horizontal_weighted_openings_standing_right': {
        'joint': 'right_shoulder',
        'min_angle': 60,
        'max_angle': 120,
        'errors': {
            'insufficient_opening': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Open your right arm wider",
                'severity': 'medium'
            },
            'excessive_opening': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not over-extend your right arm",
                'severity': 'high'
            },
            'insufficient_closing': {
                'condition': lambda angle, min_a, max_a: angle > max_a - 10,
                'recommendation': "Bring your right arm closer to center",
                'severity': 'low'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0
    },
    'external_rotation_shoulders_elastic_right': {
        'joint': 'right_elbow',
        'min_angle': 70,
        'max_angle': 110,
        'errors': {
            'elbow_too_open': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Keep your right elbow closer to your body",
                'severity': 'high'
            },
            'elbow_too_closed': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Open your right elbow slightly",
                'severity': 'medium'
            },
            'fast_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Control the elastic band slowly with your right arm",
                'severity': 'medium'
            }
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5
    },
    'circular_pendulum_standing_right': {
        'joint': 'right_shoulder',
        'min_angle': 10,
        'max_angle': 60,
        'errors': {
            'excessive_motion': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Make smaller circles with your right arm",
                'severity': 'medium'
            },
            'insufficient_motion': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 5,
                'recommendation': "Move your right arm in a bigger circle",
                'severity': 'low'
            },
            'stopped_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Keep your right arm moving gently",
                'severity': 'medium'
            }
        },
        'continuous_motion': True,
        'movement_speed_check': False
    }
}


ERROR_RULES = {
    'bending_knee_no_support_seated': {
        'joint': 'knee',
        'min_angle': 70,
        'max_angle': 180,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Bend your knee more",
                'severity': 'medium',
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not over-bend your knee",
                'severity': 'high',
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 20,
                'recommendation': "Straighten your leg fully",
                'severity': 'medium',
            },
            'excessive_extension': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 5,
                'recommendation': "Relax your knee slightly",
                'severity': 'low',
            },
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0,
    },
    'bending_knee_bed_support_supine': {
        'joint': 'knee',
        'min_angle': 60,
        'max_angle': 150,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your knee closer to your chest",
                'severity': 'medium',
            },
            'excessive_flexion': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Do not pull your knee too close",
                'severity': 'high',
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Extend your leg more",
                'severity': 'medium',
            },
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5,
    },
    'bending_knee_with_support_seated': {
        'joint': 'knee',
        'min_angle': 80,
        'max_angle': 160,
        'errors': {
            'insufficient_flexion': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 15,
                'recommendation': "Bend your knee a bit more",
                'severity': 'medium',
            },
            'insufficient_extension': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 15,
                'recommendation': "Straighten your leg more",
                'severity': 'medium',
            },
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0,
    },
    'circular_pendulum_standing': {
        'joint': 'shoulder',
        'min_angle': 10,
        'max_angle': 60,
        'errors': {
            'excessive_motion': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Make smaller circles with your arm",
                'severity': 'medium',
            },
            'insufficient_motion': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 5,
                'recommendation': "Move your arm in a bigger circle",
                'severity': 'low',
            },
            'stopped_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Keep your arm moving gently",
                'severity': 'medium',
            },
        },
        'continuous_motion': True,
        'movement_speed_check': False,
    },
    'external_rotation_shoulders_elastic': {
        'joint': 'elbow',
        'min_angle': 70,
        'max_angle': 110,
        'errors': {
            'elbow_too_open': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Keep your elbow closer to your body",
                'severity': 'high',
            },
            'elbow_too_closed': {
                'condition': lambda angle, min_a, max_a: angle < min_a - 10,
                'recommendation': "Open your elbow slightly",
                'severity': 'medium',
            },
            'fast_motion': {
                'condition': lambda angle, min_a, max_a: False,
                'recommendation': "Control the elastic band slowly",
                'severity': 'medium',
            },
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5,
    },
    'horizontal_weighted_openings_standing': {
        'joint': 'shoulder',
        'min_angle': 60,
        'max_angle': 120,
        'errors': {
            'insufficient_opening': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Open your arms wider",
                'severity': 'medium',
            },
            'excessive_opening': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not over-extend your arms",
                'severity': 'high',
            },
            'insufficient_closing': {
                'condition': lambda angle, min_a, max_a: angle > max_a - 10,
                'recommendation': "Bring your arms closer together",
                'severity': 'low',
            },
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0,
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
                'severity': 'high',
            },
            'insufficient_lift': {
                'condition': lambda angle, min_a, max_a: angle < min_a + 10,
                'recommendation': "Lift your leg higher",
                'severity': 'medium',
            },
            'excessive_lift': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 10,
                'recommendation': "Do not raise your leg too high",
                'severity': 'high',
            },
            'leg_lowered_incomplete': {
                'condition': lambda angle, min_a, max_a: angle > min_a - 5,
                'recommendation': "Lower your leg completely",
                'severity': 'low',
            },
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.5,
    },
    'shoulder_flexion_seated': {
        'joint': 'shoulder',
        'min_angle': 10,
        'max_angle': 170,
        'errors': {
            'insufficient_raise': {
                'condition': lambda angle, min_a, max_a: angle < max_a - 30,
                'recommendation': "Lift your arm higher",
                'severity': 'medium',
            },
            'excessive_raise': {
                'condition': lambda angle, min_a, max_a: angle > max_a + 15,
                'recommendation': "Lower your arm slightly",
                'severity': 'low',
            },
            'incomplete_lowering': {
                'condition': lambda angle, min_a, max_a: angle > min_a + 20,
                'recommendation': "Lower your arm completely",
                'severity': 'medium',
            },
        },
        'movement_speed_check': True,
        'min_rep_duration': 2.0,
    },
}
