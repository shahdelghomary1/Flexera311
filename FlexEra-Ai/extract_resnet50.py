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

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
BASE_DIR = r"C:\Users\yasmin\Downloads\Ai_FlexEra\clips_mp4"
SAVE_DIR = r"C:\Users\yasmin\Downloads\Ai_FlexEra"
NPZ_FILE = os.path.join(SAVE_DIR, "features_resnet50.npz")
batch_size_extract = 32
img_size = 224
max_frames = 400
exercise_map = {
    "01": "Bending knee no support seated L",
    "02": "Bending knee with support seated L",
    "03": "Lift extended leg supine L",
    "04": "Bending knee with bed support supine L",
    "05": "Bending knee no support seated R",
    "06": "Bending knee with support seated R",
    "07": "Lift extended leg supine R",
    "08": "Bending knee with bed support supine R",
    "09": "Shoulder flexion seated L",
    "10": "Horizontal weighted openings standing L",
    "11": "External rotation shoulders elastic L",
    "12": "Circular pendulum standing L",
    "13": "Shoulder flexion seated R",
    "14": "Horizontal weighted openings standing R",
    "15": "External rotation shoulders elastic R",
    "16": "Circular pendulum standing R",
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

def load_resnet50():
    print("resnet50")
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

def extract_frames_from_video(video_path, max_frames_limit=max_frames):
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
    if len(all_frames_list) <= max_frames_limit:
        selected_indices = list(range(len(all_frames_list)))
    else:
        selected_indices = np.linspace(0, len(all_frames_list) - 1, max_frames_limit, dtype=int)
    for idx in selected_indices:
        frame = all_frames_list[idx]
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
    model = load_resnet50()
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
    print(f"\nprocessing videos")
    print(f"total videos to process: {len(video_paths)}")
    print("expected videos 2160\n")
    
    failed = 0
    processed = 0
    for indx, video_data in enumerate(tqdm(video_paths, desc="Processing")):
        if indx > 0 and indx % 50 == 0:
             print(f"progress: {indx}/{len(video_paths)}")
        frames = extract_frames_from_video(video_data['path'], max_frames_limit=max_frames)
        if frames is None or len(frames) == 0:
            failed += 1
            continue
        features = extract_features(frames, model, transform)
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
        gc.collect()####
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
        )######
        print(f"\nNPZ file saved: {NPZ_FILE}")
        print(f"videos: {processed}")
        print(f"classes: {len(exercise_map)}")
        print(f"feature dimension: 2048")
        print(f"max frames per video: {max_frames}")
    else:
        print("no npz file created")
    return NPZ_FILE

def main():
    print(f"Device: {DEVICE}")
    print(f"max_frames: {max_frames}")
    print(f"extraction using pytorcg")   
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