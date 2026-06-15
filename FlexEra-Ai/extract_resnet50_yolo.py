import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms
import os
import cv2
import numpy as np
from tqdm import tqdm
import warnings
from datetime import datetime
import gc
from ultralytics import YOLO

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
BASE_DIR = "/home/abdelraheem/Documents/Graduation_test/clips_mp4"
SAVE_DIR = "/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls"
NPZ_FILE = os.path.join(SAVE_DIR, "features_resnet50_yolo.npz")
batch_size_extract = 32
img_size = 224
max_frames = 400

# Exercise map for 8 classes (merged L/R)
exercise_map = {
    "01": "Bending knee no support seated",
    "02": "Bending knee with support seated",
    "03": "Lift extended leg supine",
    "04": "Bending knee with bed support supine",
    "05": "Bending knee no support seated",
    "06": "Bending knee with support seated",
    "07": "Lift extended leg supine",
    "08": "Bending knee with bed support supine",
    "09": "Shoulder flexion seated",
    "10": "Horizontal weighted openings standing",
    "11": "External rotation shoulders elastic",
    "12": "Circular pendulum standing",
    "13": "Shoulder flexion seated",
    "14": "Horizontal weighted openings standing",
    "15": "External rotation shoulders elastic",
    "16": "Circular pendulum standing",
}

warnings.filterwarnings('ignore')

def save_dir():
    if not os.path.exists(SAVE_DIR):
        os.makedirs(SAVE_DIR)
        print(f"dir created: {SAVE_DIR}")
    return True

def get_base_transform():
    return transforms.Compose([
        transforms.ToPILImage(),
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225])
    ])

def load_yolo():
    """Load YOLOv8 model for person detection"""
    print("Loading YOLOv8 for person detection...")
    yolo_model = YOLO('yolov8n.pt')  # nano model for speed
    return yolo_model

def load_resnet50():
    print("Loading ResNet50 for feature extraction...")
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

def detect_person(frame, yolo_model, conf_threshold=0.25):
    """
    Detect person in frame using YOLO and return cropped region
    Returns: cropped person region or original frame if no person detected
    """
    # Run YOLO detection
    results = yolo_model(frame, conf=conf_threshold, verbose=False)

    # Filter for person class (class 0 in COCO dataset)
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
        # No person detected, return original frame
        return frame

    # Get the detection with highest confidence
    best_detection = max(person_detections, key=lambda x: x['conf'])
    x1, y1, x2, y2 = best_detection['bbox'].astype(int)

    # Add some padding to the bounding box
    h, w = frame.shape[:2]
    padding = 20
    x1 = max(0, x1 - padding)
    y1 = max(0, y1 - padding)
    x2 = min(w, x2 + padding)
    y2 = min(h, y2 + padding)

    # Crop the person region
    cropped = frame[y1:y2, x1:x2]

    return cropped if cropped.size > 0 else frame

def extract_frames_from_video(video_path, yolo_model, max_frames_limit=max_frames):
    """
    Extract frames from video and detect person using YOLO
    """
    frames = []
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"failed to open video: {os.path.basename(video_path)}")
        return None

    all_frames_list = []
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        all_frames_list.append(frame)
    cap.release()

    if len(all_frames_list) == 0:
        return None

    # Sample frames
    if len(all_frames_list) <= max_frames_limit:
        selected_indices = list(range(len(all_frames_list)))
    else:
        selected_indices = np.linspace(0, len(all_frames_list) - 1, max_frames_limit, dtype=int)

    for idx in selected_indices:
        frame = all_frames_list[idx]

        # Detect person and crop
        frame = detect_person(frame, yolo_model)

        # Resize and convert
        frame = cv2.resize(frame, (img_size, img_size), interpolation=cv2.INTER_LINEAR)
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        frames.append(frame)

    return np.array(frames)

def extract_features(frames, model, transform, batch_size=batch_size_extract):
    if frames is None or len(frames) == 0:
        return None
    features = []
    with torch.no_grad():
        for i in range(0, len(frames), batch_size):
            batch_frames = frames[i:i + batch_size]
            batch_tensors = []
            for frame in batch_frames:
                frame_tensor = transform(frame)
                batch_tensors.append(frame_tensor)

            batch_tensor = torch.stack(batch_tensors).to(DEVICE)
            batch_features = model(batch_tensor)
            features.append(batch_features.cpu().numpy())
    return np.concatenate(features, axis=0) if features else None

def extract_all_features(base_dir, exercise_map):
    save_dir()
    yolo_model = load_yolo()
    resnet_model = load_resnet50()
    transform = get_base_transform()

    all_features = []
    all_labels = []
    all_subjects = []
    all_cameras = []
    all_exercises = []
    video_info = []
    video_paths = []

    subject_dirs = sorted([d for d in os.listdir(base_dir) if d.isdigit()])
    print(f"\nnum found {len(subject_dirs)} subjects")
    print(f"Subject order: {subject_dirs}\n")

    for subject_idx, subject_id_str in enumerate(subject_dirs, 1):
        subject_id = int(subject_id_str)
        subject_path = os.path.join(base_dir, subject_id_str)
        exercise_dirs = sorted([d for d in os.listdir(subject_path) if d.isdigit() or (d.startswith('0') and d[1:].isdigit())])
        print(f"[{subject_idx}/{len(subject_dirs)}] Subject {subject_id}: {len(exercise_dirs)} exercises")
        print(f"Subject {subject_id} - Exercise folders: {exercise_dirs}")

        for exercise_idx, exercise_id_str in enumerate(exercise_dirs, 1):
            exercise_padded = f"{int(exercise_id_str):02d}"
            if exercise_padded not in exercise_map:
                print(f"  Exercise {exercise_padded} not in map - SKIPPING")
                continue

            exercise_path = os.path.join(subject_path, exercise_id_str)
            camera_files = sorted([f for f in os.listdir(exercise_path) if f.lower().endswith('.mp4')])
            print(f"[{exercise_idx}/16] Exercise {exercise_padded}: {exercise_map[exercise_padded]} - {len(camera_files)} videos")

            for video_idx, video_file in enumerate(camera_files, 1):
                video_path = os.path.join(exercise_path, video_file)
                print(f"    Video {video_idx}: {video_file}")
                video_paths.append({
                    'path': video_path,
                    'subject': subject_id,
                    'exercise': exercise_padded,
                    'exercise_name': exercise_map[exercise_padded],
                    'file': video_file,
                    'camera': video_file.replace('.mp4', '')
                })

    print(f"\nprocessing videos with YOLO person detection")
    print(f"total videos to process: {len(video_paths)}")

    failed = 0
    processed = 0
    for indx, video_data in enumerate(tqdm(video_paths, desc="Processing")):
        if indx > 0 and indx % 50 == 0:
             print(f"progress: {indx}/{len(video_paths)}")

        frames = extract_frames_from_video(video_data['path'], yolo_model, max_frames_limit=max_frames)
        if frames is None or len(frames) == 0:
            failed += 1
            continue

        features = extract_features(frames, resnet_model, transform)
        if features is None or features.shape[0] == 0:
            failed += 1
            continue

        all_features.append(features)
        all_labels.append(video_data['exercise_name'])
        all_subjects.append(video_data['subject'])
        all_cameras.append(video_data['camera'])
        all_exercises.append(video_data['exercise'])
        processed += 1

        video_info.append({
            'subject': video_data['subject'],
            'exercise': video_data['exercise'],
            'exercise_name': video_data['exercise_name'],
            'camera': video_data['camera'],
            'num_frames': len(frames),
            'feature_shape': str(features.shape),
            'video_file': video_data['file']
        })

        del frames, features
        gc.collect()

    print(f"\ntotal processed: {processed} videos")
    print(f"total failed: {failed} videos")
    print("saving to npz file")

    features_array = np.array(all_features, dtype=object)
    labels_array = np.array(all_labels)
    subjects_array = np.array(all_subjects)
    cameras_array = np.array(all_cameras)
    exercises_array = np.array(all_exercises)

    if len(features_array) > 0:
        np.savez(
            NPZ_FILE,
            features=features_array,
            labels=labels_array,
            subjects=subjects_array,
            cameras=cameras_array,
            exercises=exercises_array,
            video_info=np.array(video_info, dtype=object)
        )
        print(f"\nNPZ file saved: {NPZ_FILE}")
        print(f"videos: {processed}")
        print(f"classes: 8 (merged L/R)")
        print(f"feature dimension: 2048")
        print(f"max frames per video: {max_frames}")
    else:
        print("no npz file created")

    return NPZ_FILE

def main():
    print(f"Device: {DEVICE}")
    print(f"max_frames: {max_frames}")
    print(f"extraction using YOLO + ResNet50")
    start_time = datetime.now()
    npz_file = extract_all_features(BASE_DIR, exercise_map)
    end_time = datetime.now()
    elapsed = (end_time - start_time).total_seconds()
    print(f"\ntotal extraction time: {elapsed/3600:.2f} hours")
    if not os.path.exists(npz_file):
        print("npz file was not created")
        return

if __name__ == "__main__":
    main()
