"""
Simple inference script using existing Transformer model with YOLO person detection
Uses the pre-trained model: transformer_model_high_acc.keras
"""

import os
import cv2
import numpy as np
import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms
from ultralytics import YOLO
import tensorflow as tf

# Configuration
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
MODEL_PATH = "/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls/transformer_model_high_acc.keras"
IMG_SIZE = 224
MAX_FRAMES = 400
MIN_FRAMES = 30

# 8 Exercise classes (merged L/R)
EXERCISE_CLASSES = [
    "Bending knee no support seated",
    "Bending knee with support seated",
    "Lift extended leg supine",
    "Bending knee with bed support supine",
    "Shoulder flexion seated",
    "Horizontal weighted openings standing",
    "External rotation shoulders elastic",
    "Circular pendulum standing"
]

class SimpleExerciseClassifier:
    def __init__(self, model_path=MODEL_PATH):
        """Initialize classifier with existing model"""
        print("Initializing Exercise Classifier...")
        print(f"Device: {DEVICE}")

        # Load YOLO
        print("Loading YOLO model...")
        self.yolo_model = YOLO('yolov8n.pt')

        # Load ResNet50
        print("Loading ResNet50 model...")
        self.resnet_model = self._load_resnet50()
        self.transform = self._get_transform()

        # Load pre-trained Transformer model
        print(f"Loading pre-trained Transformer model from: {model_path}")
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model not found: {model_path}")
        self.transformer_model = tf.keras.models.load_model(model_path)

        print("✓ All models loaded successfully!")
        print(f"✓ Ready to classify {len(EXERCISE_CLASSES)} exercise types\n")

    def _load_resnet50(self):
        """Load ResNet50 feature extractor"""
        resnet50 = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
        feature_layers = list(resnet50.children())[:-1]
        resnet50_features = nn.Sequential(*feature_layers)
        feature_extractor = nn.Sequential(
            resnet50_features,
            nn.Flatten()
        )
        feature_extractor.to(DEVICE)
        feature_extractor.eval()
        return feature_extractor

    def _get_transform(self):
        """Get image transformation pipeline"""
        return transforms.Compose([
            transforms.ToPILImage(),
            transforms.Resize((IMG_SIZE, IMG_SIZE)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406],
                               std=[0.229, 0.224, 0.225])
        ])

    def detect_person(self, frame, conf_threshold=0.25):
        """Detect person using YOLO and return cropped region"""
        results = self.yolo_model(frame, conf=conf_threshold, verbose=False)

        # Filter for person class (class 0)
        person_detections = []
        for result in results:
            boxes = result.boxes
            for box in boxes:
                if int(box.cls[0]) == 0:  # person class
                    person_detections.append({
                        'bbox': box.xyxy[0].cpu().numpy(),
                        'conf': float(box.conf[0])
                    })

        if len(person_detections) == 0:
            return frame, None

        # Get highest confidence detection
        best_detection = max(person_detections, key=lambda x: x['conf'])
        x1, y1, x2, y2 = best_detection['bbox'].astype(int)

        # Add padding
        h, w = frame.shape[:2]
        padding = 20
        x1 = max(0, x1 - padding)
        y1 = max(0, y1 - padding)
        x2 = min(w, x2 + padding)
        y2 = min(h, y2 + padding)

        # Crop person region
        cropped = frame[y1:y2, x1:x2]
        bbox = (x1, y1, x2, y2)

        return (cropped if cropped.size > 0 else frame), bbox

    def extract_features(self, frame):
        """Extract ResNet50 features from frame"""
        # Convert to RGB
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Transform
        frame_tensor = self.transform(frame_rgb).unsqueeze(0).to(DEVICE)

        # Extract features
        with torch.no_grad():
            features = self.resnet_model(frame_tensor)

        return features.cpu().numpy()

    def classify_exercise(self, features_sequence):
        """
        Classify exercise from feature sequence
        Args:
            features_sequence: numpy array of shape (num_frames, 2048)
        Returns:
            (class_name, confidence, all_probabilities)
        """
        if len(features_sequence) < MIN_FRAMES:
            return None, 0.0, None

        # Trim to MAX_FRAMES if needed
        if len(features_sequence) > MAX_FRAMES:
            indices = np.linspace(0, len(features_sequence) - 1, MAX_FRAMES, dtype=int)
            features_sequence = features_sequence[indices]

        # Add batch dimension
        features_batch = np.expand_dims(features_sequence, axis=0)

        # Predict
        predictions = self.transformer_model.predict(features_batch, verbose=0)

        # Get results
        predicted_class = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class]
        class_name = EXERCISE_CLASSES[predicted_class]

        return class_name, confidence, predictions[0]

    def predict_video(self, video_path, display=True, save_output=None):
        """
        Predict exercise from video file
        Args:
            video_path: path to video file
            display: show video with predictions
            save_output: path to save output video (optional)
        Returns:
            (predicted_class, confidence)
        """
        if not os.path.exists(video_path):
            print(f"Error: Video not found: {video_path}")
            return None, 0.0

        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            print(f"Error: Could not open video: {video_path}")
            return None, 0.0

        fps = int(cap.get(cv2.CAP_PROP_FPS))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

        print(f"\n{'='*60}")
        print(f"Processing: {os.path.basename(video_path)}")
        print(f"Resolution: {width}x{height} @ {fps} FPS")
        print(f"Total frames: {total_frames}")
        print(f"{'='*60}\n")

        # Video writer
        out = None
        if save_output:
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(save_output, fourcc, fps, (width, height))

        features_buffer = []
        frame_count = 0
        current_prediction = None
        current_confidence = 0.0

        print("Extracting features from frames...")

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            frame_count += 1

            # Detect person and crop
            cropped_frame, bbox = self.detect_person(frame)

            # Extract features
            features = self.extract_features(cropped_frame)
            features_buffer.append(features[0])

            # Display frame
            display_frame = frame.copy()

            # Draw bounding box
            if bbox is not None:
                x1, y1, x2, y2 = bbox
                cv2.rectangle(display_frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

            # Update prediction every 10 frames
            if len(features_buffer) >= MIN_FRAMES and frame_count % 10 == 0:
                pred_name, pred_conf, _ = self.classify_exercise(np.array(features_buffer))
                if pred_name:
                    current_prediction = pred_name
                    current_confidence = pred_conf

            # Draw prediction
            if current_prediction:
                text = f"{current_prediction}"
                conf_text = f"Confidence: {current_confidence:.1%}"

                # Background for text
                cv2.rectangle(display_frame, (5, 5), (width - 5, 80), (0, 0, 0), -1)

                cv2.putText(display_frame, text, (10, 30),
                          cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
                cv2.putText(display_frame, conf_text, (10, 60),
                          cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

            # Frame counter
            cv2.putText(display_frame, f"Frame: {frame_count}/{total_frames}",
                       (10, height - 10),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

            # Display
            if display:
                cv2.imshow('Exercise Classification', display_frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

            # Save
            if out:
                out.write(display_frame)

            # Progress
            if frame_count % 30 == 0:
                print(f"  Progress: {frame_count}/{total_frames} frames ({frame_count/total_frames*100:.1f}%)")

        cap.release()
        if out:
            out.release()
        if display:
            cv2.destroyAllWindows()

        # Final classification
        print(f"\n{'='*60}")
        print("FINAL CLASSIFICATION")
        print(f"{'='*60}")

        if len(features_buffer) >= MIN_FRAMES:
            final_class, final_conf, all_probs = self.classify_exercise(np.array(features_buffer))

            print(f"\nPredicted Exercise: {final_class}")
            print(f"Confidence: {final_conf:.2%}")
            print(f"\nAll class probabilities:")
            for i, prob in enumerate(all_probs):
                marker = "★" if i == np.argmax(all_probs) else " "
                print(f"  {marker} {EXERCISE_CLASSES[i]:45s} {prob:.2%}")

            print(f"\n{'='*60}")
            print(f"Processed {frame_count} frames")
            if save_output:
                print(f"Saved output to: {save_output}")
            print(f"{'='*60}\n")

            return final_class, final_conf
        else:
            print(f"Error: Not enough frames ({len(features_buffer)} < {MIN_FRAMES})")
            print(f"{'='*60}\n")
            return None, 0.0


def main():
    """Main function"""
    import sys

    print("\n" + "="*60)
    print("Exercise Classification with YOLO + Transformer")
    print("="*60 + "\n")

    # Check if model exists
    if not os.path.exists(MODEL_PATH):
        print(f"Error: Model not found at {MODEL_PATH}")
        print("Please train the model first using 'Transformer-Conv1D Hybrid.py'")
        return

    # Initialize classifier
    try:
        classifier = SimpleExerciseClassifier()
    except Exception as e:
        print(f"Error initializing classifier: {e}")
        return

    # Get video path from command line or use default
    if len(sys.argv) > 1:
        video_path = sys.argv[1]
        save_output = sys.argv[2] if len(sys.argv) > 2 else None
    else:
        # Try to find a sample video
        sample_dir = "/home/abdelraheem/Documents/Graduation_test/clips_mp4"
        video_path = None

        if os.path.exists(sample_dir):
            for subject in sorted(os.listdir(sample_dir))[:1]:  # First subject
                subject_path = os.path.join(sample_dir, subject)
                if os.path.isdir(subject_path):
                    for exercise in sorted(os.listdir(subject_path))[:1]:  # First exercise
                        exercise_path = os.path.join(subject_path, exercise)
                        if os.path.isdir(exercise_path):
                            for video in sorted(os.listdir(exercise_path)):
                                if video.endswith('.mp4'):
                                    video_path = os.path.join(exercise_path, video)
                                    break
                            if video_path:
                                break
                    if video_path:
                        break

        if not video_path:
            print("Usage: python3 predict_with_yolo.py <video_path> [output_path]")
            print("\nExample:")
            print("  python3 predict_with_yolo.py /path/to/video.mp4")
            print("  python3 predict_with_yolo.py /path/to/video.mp4 /path/to/output.mp4")
            return

        print(f"No video specified. Using sample: {video_path}\n")
        save_output = None

    # Predict
    predicted_class, confidence = classifier.predict_video(
        video_path,
        display=True,
        save_output=save_output
    )


if __name__ == "__main__":
    main()
