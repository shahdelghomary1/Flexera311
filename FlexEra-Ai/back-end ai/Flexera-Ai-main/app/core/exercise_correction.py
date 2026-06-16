import time
from collections import deque

from app.core.voice_feedback import VoiceFeedback
from app.core.exercise_rules import ErrorDetection, ERROR_RULES

_RAISE_PHASE_ERRORS = frozenset({
    'insufficient_raise', 'insufficient_flexion', 'insufficient_opening',
    'insufficient_lift', 'insufficient_motion',
})
_LOWER_PHASE_ERRORS = frozenset({
    'incomplete_lowering', 'insufficient_extension', 'insufficient_closing',
})


class ExerciseCorrection:

    def __init__(self, voice_enabled=True, cooldown=3.0, voice_gender='female'):
        self.voice = VoiceFeedback(cooldown=cooldown, voice_gender=voice_gender)
        if not voice_enabled:
            self.voice.disable()
        self.angle_history = deque(maxlen=30)
        self.rep_start_time = None
        self.last_state = None
        self.error_counts = {}
        self.motion_stopped_frames = 0

    @staticmethod
    def _error_applies_for_rep_state(error_type, rep_state):
        if error_type in _RAISE_PHASE_ERRORS:
            return rep_state in ('transition', 'max')
        if error_type in _LOWER_PHASE_ERRORS:
            return rep_state == 'min'
        if error_type in ('excessive_raise', 'excessive_flexion', 'excessive_extension'):
            return rep_state in ('max', 'min')
        return True

    def detect_errors(self, exercise_name, joint_angles, current_rep_state, is_valid_motion, side='left'):
        errors = []
        if exercise_name not in ERROR_RULES:
            return errors

        rules = ERROR_RULES[exercise_name]
        primary_joint = rules['joint']
        min_angle = rules['min_angle']
        max_angle = rules['max_angle']

        primary_angle = joint_angles.get(f"{side}_{primary_joint}")
        if primary_angle is None:
            return errors

        self.angle_history.append({
            'angle': primary_angle,
            'time': time.time(),
            'state': current_rep_state,
        })

        for error_type, error_def in rules['errors'].items():
            if error_type == 'stopped_motion' and rules.get('continuous_motion'):
                if len(self.angle_history) >= 10:
                    recent = [h['angle'] for h in list(self.angle_history)[-10:]]
                    if max(recent) - min(recent) < 5:
                        self.motion_stopped_frames += 1
                        if self.motion_stopped_frames > 15:
                            errors.append(ErrorDetection(
                                error_type='stopped_motion',
                                severity=error_def['severity'],
                                recommendation=error_def['recommendation'],
                                joint_name=primary_joint,
                                current_value=primary_angle,
                                expected_range=(min_angle, max_angle),
                            ))
                    else:
                        self.motion_stopped_frames = 0
                continue

            if error_type == 'fast_motion':
                continue

            if not self._error_applies_for_rep_state(error_type, current_rep_state):
                continue

            if error_def['condition'](primary_angle, min_angle, max_angle):
                errors.append(ErrorDetection(
                    error_type=error_type,
                    severity=error_def['severity'],
                    recommendation=error_def['recommendation'],
                    joint_name=primary_joint,
                    current_value=primary_angle,
                    expected_range=(min_angle, max_angle),
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
                        expected_range=(sec_min, sec_max),
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
                                expected_range=(min_duration, 5.0),
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
                expected_range=(min_angle, max_angle),
            ))

        return errors

    def generate_recommendation(self, errors):
        if not errors:
            return None
        severity_priority = {'high': 3, 'medium': 2, 'low': 1}
        return sorted(errors, key=lambda e: severity_priority[e.severity], reverse=True)[0].recommendation

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
            'highest_severity': errors[0].severity if errors else None,
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
            'angle_history_size': len(self.angle_history),
        }


def create_correction(voice_enabled=True, cooldown=3.0, voice_gender='female'):
    return ExerciseCorrection(voice_enabled=voice_enabled, cooldown=cooldown, voice_gender=voice_gender)
