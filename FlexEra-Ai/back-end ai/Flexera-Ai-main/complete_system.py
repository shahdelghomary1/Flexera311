import cv2
import numpy as np
import time
import threading
import speech_recognition as sr
from ultralytics import YOLO
from app.core.exercise_validator import MultiSideValidator
from app.core.exercise_correction import create_correction
from app.core.exercise_rules import (
    EXERCISE_RULES,
    EXERCISE_CAMERA_CONFIG,
    EXERCISE_INSTRUCTIONS,
    SKELETON_CONNECTIONS,
    LANDMARK_NAMES
)




class CompleteSystem:


    def __init__(self, exercise_key):
        print(f"Loading system for: {exercise_key}")
        self.pose_model = YOLO('yolov8n-pose.pt')
        self.pose_model.to('cpu')

        self.validator   = MultiSideValidator(exercise_key, confidence_threshold=0.5)
        self.correction  = create_correction(voice_enabled=True, cooldown=3.0, voice_gender='female')
        self.exercise_key    = exercise_key
        self.camera_config   = EXERCISE_CAMERA_CONFIG.get(exercise_key, {})
        self.instructions    = EXERCISE_INSTRUCTIONS.get(exercise_key, {})
        self.key_landmarks   = self.camera_config.get('key_landmarks', [])

        self.show_landmarks      = True
        self.started             = False
        self.preparation_done    = False
        self.voice_start_requested = False

    # ── Voice Listener ────────────────────────────────────────────────────────

    def _start_voice_listener(self):
        """
        Start a background thread that listens for the word 'start'.
        The mic stays open in ONE persistent session for reliability.
        Call this AFTER any TTS intro so the speaker output doesn't confuse it.
        """
        def listen_loop():
            recognizer = sr.Recognizer()
            recognizer.energy_threshold    = 300
            recognizer.dynamic_energy_threshold = True

            try:
                mic = sr.Microphone()
            except Exception as e:
                print(f"[Voice] Microphone not available: {e}")
                return

            # Calibrate once, then keep the mic open for the whole wait
            print("[Voice] Calibrating microphone...")
            with mic as source:
                recognizer.adjust_for_ambient_noise(source, duration=1)

            print("[Voice] Ready — say  'start'  to begin the exercise")

            # ← single persistent mic session (no reconnect per iteration)
            with mic as source:
                while not self.started:
                    try:
                        audio = recognizer.listen(source, timeout=5, phrase_time_limit=3)
                        text  = recognizer.recognize_google(audio).lower()
                        print(f"[Voice] Heard: '{text}'")
                        if "start" in text:
                            self.voice_start_requested = True
                    except sr.WaitTimeoutError:
                        pass        # silence — keep waiting
                    except sr.UnknownValueError:
                        pass        # unclear audio — keep waiting
                    except Exception as e:
                        print(f"[Voice] Error: {e}")
                        break

        thread = threading.Thread(target=listen_loop, daemon=True)
        thread.start()

    # ── Drawing & Display ─────────────────────────────────────────────────────

    def draw_landmarks(self, frame, keypoints, confidence_threshold=0.5):
        """Draw skeleton landmarks on the frame."""
        if not self.show_landmarks:
            return frame

        h, w        = frame.shape[:2]
        key_indices = set(self.key_landmarks)

        # Skeleton connections
        for pt1_idx, pt2_idx in SKELETON_CONNECTIONS:
            if pt1_idx >= len(keypoints) or pt2_idx >= len(keypoints):
                continue
            pt1, pt2 = keypoints[pt1_idx], keypoints[pt2_idx]
            if len(pt1) > 2 and (pt1[2] < confidence_threshold or pt2[2] < confidence_threshold):
                continue
            x1, y1 = int(pt1[0]), int(pt1[1])
            x2, y2 = int(pt2[0]), int(pt2[1])
            if x1 > 0 and y1 > 0 and x2 > 0 and y2 > 0:
                is_key    = pt1_idx in key_indices or pt2_idx in key_indices
                color     = (0, 255, 255) if is_key else (200, 200, 200)
                thickness = 3             if is_key else 2
                cv2.line(frame, (x1, y1), (x2, y2), color, thickness)

        # Keypoints
        for idx, kp in enumerate(keypoints):
            if len(kp) > 2 and kp[2] < confidence_threshold:
                continue
            x, y = int(kp[0]), int(kp[1])
            if x > 0 and y > 0:
                if idx in key_indices:
                    cv2.circle(frame, (x, y),  8, (0, 255, 0),     -1)
                    cv2.circle(frame, (x, y), 10, (255, 255, 255),   2)
                else:
                    cv2.circle(frame, (x, y),  5, (255, 100, 100), -1)

        return frame

    def draw_feedback(self, frame, validation_results, feedback):
        """Draw rep counts, angles, and tip overlay on the frame."""
        h, w    = frame.shape[:2]
        overlay = frame.copy()
        cv2.rectangle(overlay, (10, 10), (450, 320), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.7, frame, 0.3, 0, frame)

        y = 35
        name = self.instructions.get('name', self.exercise_key)
        cv2.putText(frame, name[:30], (20, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        y += 30

        for side_label, key in [("LEFT SIDE", 'left'), ("RIGHT SIDE", 'right')]:
            res   = validation_results[key]
            color = (0, 255, 0) if res.is_valid else (0, 0, 255)
            cv2.putText(frame, side_label,                          (20, y), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2); y += 30
            cv2.putText(frame, f"Angle: {res.current_angle:.1f}°", (20, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color,            1); y += 25
            cv2.putText(frame, f"Reps:  {res.rep_count}",          (20, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255),  1); y += 35

        if feedback['recommendation']:
            cv2.rectangle(frame, (15, y - 20), (435, y + 30), (0, 255, 255), 2)
            cv2.putText(frame, "TIP:",                         (20, y),      cv2.FONT_HERSHEY_SIMPLEX, 0.5,  (0, 255, 255),   2); y += 25
            cv2.putText(frame, feedback['recommendation'],     (20, y),      cv2.FONT_HERSHEY_SIMPLEX, 0.45, (255, 255, 255), 1)

        total = self.validator.get_total_reps()
        cv2.putText(frame, f"TOTAL: {total}", (w - 200, h - 40), cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 255, 255), 3)
        cv2.putText(frame, "Q:Quit | R:Reset | V:Voice | L:Landmarks | I:Instructions",
                    (20, h - 20), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)
        return frame

    def show_instructions_screen(self, frame):
        """Display the exercise instructions overlay."""
        h, w    = frame.shape[:2]
        overlay = frame.copy()
        cv2.rectangle(overlay, (50, 50), (w - 50, h - 50), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.85, frame, 0.15, 0, frame)

        name = self.instructions.get('name', self.exercise_key)
        cv2.putText(frame, name, (70, 100), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 255), 2)

        y = 150

        camera_hint = self.camera_config.get('camera_hint', '')
        if camera_hint:
            cv2.putText(frame, "CAMERA SETUP:", (70, y), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 165, 0),   2); y += 30
            cv2.putText(frame, camera_hint,      (90, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1); y += 40

        cv2.putText(frame, "STARTING POSITION:", (70, y), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2); y += 30
        for step in self.instructions.get('starting_position', []):
            cv2.putText(frame, f"- {step}", (90, y), cv2.FONT_HERSHEY_SIMPLEX, 0.45, (255, 255, 255), 1); y += 25

        y += 15
        cv2.putText(frame, "HOW TO PERFORM:", (70, y), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 200, 255), 2); y += 30
        for i, step in enumerate(self.instructions.get('how_to', [])[:5], 1):
            cv2.putText(frame, f"{i}. {step}", (90, y), cv2.FONT_HERSHEY_SIMPLEX, 0.45, (255, 255, 255), 1); y += 25

        y += 15
        cv2.putText(frame, "TIPS:", (70, y), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 100, 100), 2); y += 30
        for tip in self.instructions.get('tips', [])[:3]:
            cv2.putText(frame, f"* {tip}", (90, y), cv2.FONT_HERSHEY_SIMPLEX, 0.45, (200, 200, 200), 1); y += 25

        cv2.putText(frame, "Say 'START' or Press SPACE  |  Press I for instructions",
                    (w // 2 - 250, h - 80), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)
        return frame

    def show_countdown(self, cap, seconds=3):
        """Show a 3-2-1 countdown before the exercise begins."""
        for i in range(seconds, 0, -1):
            ret, frame = cap.read()
            if not ret:
                continue
            frame   = cv2.flip(frame, 1)
            h, w    = frame.shape[:2]
            overlay = frame.copy()
            cv2.rectangle(overlay, (0, 0), (w, h), (0, 0, 0), -1)
            cv2.addWeighted(overlay, 0.5, frame, 0.5, 0, frame)
            cv2.putText(frame, str(i),       (w // 2 - 50,  h // 2 + 50),  cv2.FONT_HERSHEY_SIMPLEX, 5.0, (0, 255, 255), 10)
            cv2.putText(frame, "Get Ready!", (w // 2 - 100, h // 2 - 80),  cv2.FONT_HERSHEY_SIMPLEX, 1.0, (255, 255, 255), 2)
            cv2.imshow('Complete Exercise System', frame)
            cv2.waitKey(1000)

        ret, frame = cap.read()
        if ret:
            frame   = cv2.flip(frame, 1)
            h, w    = frame.shape[:2]
            overlay = frame.copy()
            cv2.rectangle(overlay, (0, 0), (w, h), (0, 0, 0), -1)
            cv2.addWeighted(overlay, 0.5, frame, 0.5, 0, frame)
            cv2.putText(frame, "GO!", (w // 2 - 80, h // 2 + 50), cv2.FONT_HERSHEY_SIMPLEX, 4.0, (0, 255, 0), 8)
            cv2.imshow('Complete Exercise System', frame)
            cv2.waitKey(500)

    # ── Frame Processing ──────────────────────────────────────────────────────

    def speak_instructions(self):
        """Speak the exercise introduction via TTS."""
        voice_intro = self.instructions.get('voice_intro', '')
        if voice_intro and self.correction.voice.enabled:
            self.correction.voice.speak(voice_intro, force=True)
            time.sleep(0.5)

    def process_frame(self, frame):
        """Run pose estimation and validation on one frame."""
        pose_results = self.pose_model(frame, verbose=False)
        if not pose_results or len(pose_results[0].keypoints.data) == 0:
            return None, frame

        keypoints = pose_results[0].keypoints.data[0].cpu().numpy()
        frame     = self.draw_landmarks(frame, keypoints)

        validation_results = self.validator.validate_frame(keypoints)
        left_result        = validation_results['left']
        right_result       = validation_results['right']
        active_side        = 'left' if left_result.rep_count >= right_result.rep_count else 'right'
        active_result      = validation_results[active_side]

        joint_angles = {
            f"{active_side}_knee":     active_result.current_angle,
            f"{active_side}_shoulder": active_result.current_angle,
            f"{active_side}_hip":      active_result.current_angle,
            f"{active_side}_elbow":    active_result.current_angle,
        }

        state_mapping = {
            'IDLE':         'neutral',
            'MIN_POSITION': 'min',
            'MAX_POSITION': 'max',
            'TRANSITION':   'transition',
            'INVALID':      'neutral',
        }
        rep_state = state_mapping.get(active_result.state.value, 'neutral')

        feedback = self.correction.provide_feedback(
            exercise_name    = self.exercise_key,
            joint_angles     = joint_angles,
            current_rep_state= rep_state,
            is_valid_motion  = active_result.is_valid,
            side             = active_side
        )

        frame = self.draw_feedback(frame, validation_results, feedback)

        return {
            'validation': validation_results,
            'feedback':   feedback,
            'total_reps': self.validator.get_total_reps(),
            'active_side':active_side,
        }, frame

    # ── Main Loop ─────────────────────────────────────────────────────────────

    def run(self):
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            print("Error: Could not open webcam")
            return

        print("\nControls:")
        print("  SAY 'start' or SPACE = Start exercise")
        print("  Q                    = Quit")
        print("  R                    = Reset counters")
        print("  V                    = Toggle voice feedback")
        print("  L                    = Toggle landmarks")
        print("  I                    = Show/hide instructions\n")

        # Speak intro FIRST, then start the voice listener so the TTS
        # output doesn't get picked up by the microphone as a false trigger.
        self.speak_instructions()
        self._start_voice_listener()

        show_instructions = True

        while True:
            ret, frame = cap.read()
            if not ret:
                break
            frame = cv2.flip(frame, 1)

            if show_instructions and not self.started:
                annotated_frame = self.show_instructions_screen(frame.copy())
            else:
                result, annotated_frame = self.process_frame(frame)
                if result is None:
                    cv2.putText(annotated_frame, "NO PERSON DETECTED", (100, 360),
                                cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 0, 255), 2)

            cv2.imshow('Complete Exercise System', annotated_frame)

            key = cv2.waitKey(1) & 0xFF

            # ── Quit ──────────────────────────────────────────────────────────
            if key == ord('q'):
                break

            # ── Start (voice or space) ────────────────────────────────────────
            elif key == ord(' ') or self.voice_start_requested:
                self.voice_start_requested = False
                if not self.started:
                    show_instructions = False
                    self.show_countdown(cap)
                    self.started = True
                    if self.correction.voice.enabled:
                        self.correction.voice.speak("Begin exercise now", force=True)

            # ── Reset ─────────────────────────────────────────────────────────
            elif key == ord('r'):
                self.validator.reset()
                self.correction.reset()
                print("System reset")
                if self.correction.voice.enabled:
                    self.correction.voice.speak("Exercise reset", force=True)

            # ── Toggle voice feedback ─────────────────────────────────────────
            elif key == ord('v'):
                if self.correction.voice.enabled:
                    self.correction.disable_voice()
                    print("Voice feedback OFF")
                else:
                    self.correction.enable_voice()
                    print("Voice feedback ON")

            # ── Toggle landmarks ──────────────────────────────────────────────
            elif key == ord('l'):
                self.show_landmarks = not self.show_landmarks
                print(f"Landmarks {'ON' if self.show_landmarks else 'OFF'}")

            # ── Toggle instructions (only after started) ──────────────────────
            elif key == ord('i') and self.started:
                show_instructions = not show_instructions
                self.started      = not show_instructions

        cap.release()
        cv2.destroyAllWindows()
        self._print_summary()

    # ── Session Summary ───────────────────────────────────────────────────────

    def _print_summary(self):
        sep = "=" * 60
        print(f"\n{sep}")
        print("SESSION SUMMARY")
        print(sep)
        print(f"Exercise  : {self.instructions.get('name', self.exercise_key)}")
        print(f"Total Reps: {self.validator.get_total_reps()}")
        print(f"  Left    : {self.validator.left_validator.rep_count['left']} reps")
        print(f"  Right   : {self.validator.right_validator.rep_count['right']} reps")
        print(f"{sep}\n")


# ─────────────────────────────────────────────────────────────────────────────
#  Entry Point
# ─────────────────────────────────────────────────────────────────────────────

def main():
    sep = "=" * 60
    print(f"\n{sep}")
    print("COMPLETE EXERCISE SYSTEM")
    print("Validation + Correction + Voice Feedback")
    print(f"{sep}\n")

    exercises = list(EXERCISE_RULES.keys())
    for i, key in enumerate(exercises, 1):
        name = EXERCISE_INSTRUCTIONS.get(key, {}).get('name', key)
        print(f"  {i}. {name}")

    print(f"\n{sep}")

    while True:
        try:
            choice = int(input(f"\nSelect exercise (1-{len(exercises)}): "))
            if 1 <= choice <= len(exercises):
                selected = exercises[choice - 1]
                break
            print(f"Invalid. Enter 1-{len(exercises)}.")
        except ValueError:
            print("Invalid input.")

    system = CompleteSystem(selected)
    system.run()


if __name__ == "__main__":
    main()
