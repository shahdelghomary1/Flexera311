"""
Batch prediction script - Process multiple videos using existing model
"""

import os
import sys
import cv2
import numpy as np
import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms
from ultralytics import YOLO
import tensorflow as tf
from tqdm import tqdm
import pandas as pd

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


class BatchExercisePredictor:
    def __init__(self, model_path=MODEL_PATH):
        """Initialize predictor"""
        print("Initializing Batch Exercise Predictor...")

        # Load YOLO
        self.yolo_model = YOLO('yolov8n.pt')

        # Load ResNet50
        resnet50 = models.resnet50(weights=models.ResNet50_Weights.DEFAULT)
        feature_layers = list(resnet50.children())[:-1]
        resnet50_features = nn.Sequential(*feature_layers)
        self.resnet_model = nn.Sequential(resnet50_features, nn.Flatten())
        self.resnet_model.to(DEVICE)
        self.resnet_model.eval()

        # Transform
        self.transform = transforms.Compose([
            transforms.ToPILImage(),
            transforms.Resize((IMG_SIZE, IMG_SIZE)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406],
                               std=[0.229, 0.224, 0.225])
        ])

        # Load Transformer model
        self.transformer_model = tf.keras.models.load_model(model_path)

        print("✓ Models loaded!\n")

    def detect_person(self, frame):
        """Detect and crop person"""
        results = self.yolo_model(frame, conf=0.25, verbose=False)

        for result in results:
            for box in result.boxes:
                if int(box.cls[0]) == 0:  # person
                    x1, y1, x2, y2 = box.xyxy[0].cpu().numpy().astype(int)

                    # Add padding
                    h, w = frame.shape[:2]
                    padding = 20
                    x1 = max(0, x1 - padding)
                    y1 = max(0, y1 - padding)
                    x2 = min(w, x2 + padding)
                    y2 = min(h, y2 + padding)

                    cropped = frame[y1:y2, x1:x2]
                    return cropped if cropped.size > 0 else frame

        return frame

    def extract_video_features(self, video_path):
        """Extract features from entire video"""
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            return None

        features = []
        frame_count = 0

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            # Detect person
            cropped = self.detect_person(frame)

            # Extract features
            frame_rgb = cv2.cvtColor(cropped, cv2.COLOR_BGR2RGB)
            frame_tensor = self.transform(frame_rgb).unsqueeze(0).to(DEVICE)

            with torch.no_grad():
                feat = self.resnet_model(frame_tensor)
            features.append(feat.cpu().numpy()[0])

            frame_count += 1

        cap.release()

        if len(features) < MIN_FRAMES:
            return None

        # Trim if needed
        if len(features) > MAX_FRAMES:
            indices = np.linspace(0, len(features) - 1, MAX_FRAMES, dtype=int)
            features = [features[i] for i in indices]

        return np.array(features)

    def predict(self, features):
        """Predict exercise class"""
        features_batch = np.expand_dims(features, axis=0)
        predictions = self.transformer_model.predict(features_batch, verbose=0)

        predicted_class = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class]
        class_name = EXERCISE_CLASSES[predicted_class]

        return class_name, confidence, predictions[0]

    def process_videos(self, video_paths, output_csv=None):
        """Process multiple videos"""
        results = []

        print(f"Processing {len(video_paths)} videos...\n")

        for video_path in tqdm(video_paths, desc="Predicting"):
            video_name = os.path.basename(video_path)

            # Extract features
            features = self.extract_video_features(video_path)

            if features is None:
                results.append({
                    'video': video_name,
                    'path': video_path,
                    'predicted_class': 'ERROR',
                    'confidence': 0.0,
                    'status': 'Failed to extract features'
                })
                continue

            # Predict
            class_name, confidence, probs = self.predict(features)

            result = {
                'video': video_name,
                'path': video_path,
                'predicted_class': class_name,
                'confidence': confidence,
                'status': 'Success'
            }

            # Add individual class probabilities
            for i, cls in enumerate(EXERCISE_CLASSES):
                result[f'prob_{cls}'] = probs[i]

            results.append(result)

        # Create DataFrame
        df = pd.DataFrame(results)

        # Save to CSV
        if output_csv:
            df.to_csv(output_csv, index=False)
            print(f"\n✓ Results saved to: {output_csv}")

        return df


def process_folder(folder_path, output_csv='predictions.csv'):
    """Process all videos in a folder"""
    if not os.path.exists(folder_path):
        print(f"Error: Folder not found: {folder_path}")
        return

    # Find all MP4 files
    video_files = []
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.lower().endswith('.mp4'):
                video_files.append(os.path.join(root, file))

    if len(video_files) == 0:
        print(f"No MP4 files found in {folder_path}")
        return

    print(f"Found {len(video_files)} videos\n")

    # Initialize predictor
    predictor = BatchExercisePredictor()

    # Process
    results_df = predictor.process_videos(video_files, output_csv)

    # Print summary
    print("\n" + "="*60)
    print("PREDICTION SUMMARY")
    print("="*60)

    print(f"\nTotal videos: {len(results_df)}")
    print(f"Successful: {len(results_df[results_df['status'] == 'Success'])}")
    print(f"Failed: {len(results_df[results_df['status'] != 'Success'])}")

    print("\nClass distribution:")
    class_counts = results_df[results_df['status'] == 'Success']['predicted_class'].value_counts()
    for cls, count in class_counts.items():
        print(f"  {cls:45s} {count:3d} videos")

    print("\nAverage confidence by class:")
    for cls in EXERCISE_CLASSES:
        cls_df = results_df[results_df['predicted_class'] == cls]
        if len(cls_df) > 0:
            avg_conf = cls_df['confidence'].mean()
            print(f"  {cls:45s} {avg_conf:.2%}")

    print("="*60 + "\n")

    return results_df


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 batch_predict_yolo.py <folder_path> [output.csv]")
        print("\nExample:")
        print("  python3 batch_predict_yolo.py /path/to/videos predictions.csv")
        print("  python3 batch_predict_yolo.py /home/abdelraheem/Documents/Graduation_test/clips_mp4/0")
        return

    folder_path = sys.argv[1]
    output_csv = sys.argv[2] if len(sys.argv) > 2 else 'predictions.csv'

    process_folder(folder_path, output_csv)


if __name__ == "__main__":
    main()
