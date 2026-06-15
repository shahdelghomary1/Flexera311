"""
Real-time Exercise Classification using YOLO + ResNet50 + Transformer
Two-stage pipeline:
1. YOLO detects person in frame
2. ResNet50 extracts features from detected person
3. Transformer model classifies the exercise
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
from collections import deque

# Configuration
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
MODEL_PATH = "/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls/transformer_model_high_acc.keras"
IMG_SIZE = 224
MAX_FRAMES = 400  # Maximum frames to collect before classification
MIN_FRAMES = 30   # Minimum frames needed for classification

# Exercise classes (8 merged classes)
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

class ExerciseClassifier:
    def __init__(self, model_path=MODEL_PATH):
        """Initialize the exercise classifier with YOLO, ResNet50, and Transformer"""
        print("Initializing Exercise Classifier...")

        # Load YOLO for person detection
        print("Loading YOLO model...")
        self.yolo_model = YOLO('yolov8n.pt')

        # Load ResNet50 for feature extraction
        print("Loading ResNet50 model...")
        self.resnet_model = self._load_resnet50()
        self.transform = self._get_transform()

        # Load Transformer classifier
        print("Loading Transformer model...")
        self.transformer_model = tf.keras.models.load_model(model_path)

        print("All models loaded successfully!")

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
        """
        Detect person in frame using YOLO
        Returns: cropped person region or original frame if no person detected
        """
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

        # Get detection with highest confidence
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
        """Extract ResNet50 features from a single frame"""
        # Convert to RGB
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Transform
        frame_tensor = self.transform(frame_rgb).unsqueeze(0).to(DEVICE)

        # Extract features
        with torch.no_grad():
            features = self.resnet_model(frame_tensor)

        return features.cpu().numpy()

    def classify_sequence(self, features_sequence):
        """
        Classify a sequence of features using the Transformer model
        features_sequence: numpy array of shape (num_frames, 2048)
        Returns: (predicted_class_index, confidence, class_name)
        """
        # Ensure we have at least MIN_FRAMES
        if len(features_sequence) < MIN_FRAMES:
            return None, 0.0, "Not enough frames"

        # Trim to MAX_FRAMES if necessary
        if len(features_sequence) > MAX_FRAMES:
            # Sample frames evenly
            indices = np.linspace(0, len(features_sequence) - 1, MAX_FRAMES, dtype=int)
            features_sequence = features_sequence[indices]

        # Add batch dimension
        features_batch = np.expand_dims(features_sequence, axis=0)

        # Predict
        predictions = self.transformer_model.predict(features_batch, verbose=0)

        # Get class and confidence
        predicted_class = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class]
        class_name = EXERCISE_CLASSES[predicted_class]

        return predicted_class, confidence, class_name

    def process_video(self, video_path, display=True, save_output=None):
        """
        Process a video file and classify the exercise
        Args:
            video_path: path to video file
            display: whether to display the video with predictions
            save_output: path to save output video (optional)
        """
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            print(f"Error: Could not open video {video_path}")
            return None

        fps = int(cap.get(cv2.CAP_PROP_FPS))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        # Video writer if saving
        out = None
        if save_output:
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(save_output, fourcc, fps, (width, height))

        features_buffer = []
        frame_count = 0
        final_prediction = None
        final_confidence = 0.0

        print(f"Processing video: {video_path}")
        print("Collecting frames and extracting features...")

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

            # Draw bounding box if person detected
            display_frame = frame.copy()
            if bbox is not None:
                x1, y1, x2, y2 = bbox
                cv2.rectangle(display_frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

            # Classify if we have enough frames
            if len(features_buffer) >= MIN_FRAMES and len(features_buffer) % 10 == 0:
                pred_class, confidence, class_name = self.classify_sequence(np.array(features_buffer))
                if pred_class is not None:
                    final_prediction = class_name
                    final_confidence = confidence

            # Display prediction on frame
            if final_prediction:
                text = f"{final_prediction} ({final_confidence:.2%})"
                cv2.putText(display_frame, text, (10, 30),
                          cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

            cv2.putText(display_frame, f"Frames: {frame_count}", (10, 60),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

            # Display
            if display:
                cv2.imshow('Exercise Classification', display_frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

            # Save output
            if out:
                out.write(display_frame)

        cap.release()
        if out:
            out.release()
        if display:
            cv2.destroyAllWindows()

        # Final classification on all frames
        if len(features_buffer) >= MIN_FRAMES:
            pred_class, confidence, class_name = self.classify_sequence(np.array(features_buffer))
            print(f"\nFinal Classification:")
            print(f"  Exercise: {class_name}")
            print(f"  Confidence: {confidence:.2%}")
            print(f"  Total frames processed: {frame_count}")
            return class_name, confidence
        else:
            print("Not enough frames for classification")
            return None, 0.0

    def process_webcam(self, buffer_size=MAX_FRAMES):
        """
        Process webcam feed for real-time classification
        Press 'q' to quit, 'c' to clear buffer and restart classification
        """
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            print("Error: Could not open webcam")
            return

        features_buffer = deque(maxlen=buffer_size)
        current_prediction = None
        current_confidence = 0.0
        frame_count = 0

        print("Starting webcam... Press 'q' to quit, 'c' to clear buffer")

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

            # Draw bounding box
            if bbox is not None:
                x1, y1, x2, y2 = bbox
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

            # Classify every 15 frames if we have enough data
            if len(features_buffer) >= MIN_FRAMES and frame_count % 15 == 0:
                pred_class, confidence, class_name = self.classify_sequence(np.array(features_buffer))
                if pred_class is not None:
                    current_prediction = class_name
                    current_confidence = confidence

            # Display prediction
            if current_prediction:
                text = f"{current_prediction}"
                conf_text = f"Confidence: {current_confidence:.2%}"
                cv2.putText(frame, text, (10, 30),
                          cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
                cv2.putText(frame, conf_text, (10, 60),
                          cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

            # Display buffer info
            buffer_text = f"Buffer: {len(features_buffer)}/{buffer_size}"
            cv2.putText(frame, buffer_text, (10, frame.shape[0] - 10),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

            # Display
            cv2.imshow('Real-time Exercise Classification', frame)

            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):
                break
            elif key == ord('c'):
                features_buffer.clear()
                current_prediction = None
                current_confidence = 0.0
                frame_count = 0
                print("Buffer cleared!")

        cap.release()
        cv2.destroyAllWindows()


def main():
    """Main function with examples"""
    import sys

    # Initialize classifier
    classifier = ExerciseClassifier()

    if len(sys.argv) > 1:
        # Process video file
        video_path = sys.argv[1]
        save_output = sys.argv[2] if len(sys.argv) > 2 else None
        classifier.process_video(video_path, display=True, save_output=save_output)
    else:
        # Process webcam
        print("\nNo video file provided. Starting webcam mode...")
        print("Usage: python inference_yolo_transformer.py [video_path] [output_path]")
        print("\nStarting webcam in 3 seconds...")
        import time
        time.sleep(3)
        classifier.process_webcam()


if __name__ == "__main__":
    main()
