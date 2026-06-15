"""
Quick test script for the prediction scripts
Tests if everything is installed and ready to use
"""

import os
import sys


def test_imports():
    """Test if all packages are installed"""
    print("="*60)
    print("Testing Package Installation")
    print("="*60 + "\n")

    all_ok = True

    packages = {
        'torch': 'PyTorch',
        'torchvision': 'TorchVision',
        'tensorflow': 'TensorFlow',
        'ultralytics': 'Ultralytics YOLO',
        'cv2': 'OpenCV',
        'numpy': 'NumPy',
        'pandas': 'Pandas',
        'tqdm': 'tqdm'
    }

    for module, name in packages.items():
        try:
            if module == 'cv2':
                import cv2
                print(f"✓ {name:20s} {cv2.__version__}")
            elif module == 'torch':
                import torch
                print(f"✓ {name:20s} {torch.__version__}")
                print(f"  CUDA available: {torch.cuda.is_available()}")
                if torch.cuda.is_available():
                    print(f"  GPU: {torch.cuda.get_device_name(0)}")
            elif module == 'torchvision':
                import torchvision
                print(f"✓ {name:20s} {torchvision.__version__}")
            elif module == 'tensorflow':
                import tensorflow as tf
                print(f"✓ {name:20s} {tf.__version__}")
            elif module == 'ultralytics':
                from ultralytics import YOLO
                print(f"✓ {name:20s} installed")
            elif module == 'numpy':
                import numpy as np
                print(f"✓ {name:20s} {np.__version__}")
            elif module == 'pandas':
                import pandas as pd
                print(f"✓ {name:20s} {pd.__version__}")
            elif module == 'tqdm':
                import tqdm
                print(f"✓ {name:20s} {tqdm.__version__}")
        except ImportError:
            print(f"✗ {name:20s} NOT INSTALLED")
            all_ok = False

    print()
    return all_ok


def test_model():
    """Test if model exists"""
    print("="*60)
    print("Testing Model")
    print("="*60 + "\n")

    model_path = "/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls/transformer_model_high_acc.keras"

    if os.path.exists(model_path):
        size_mb = os.path.getsize(model_path) / (1024*1024)
        print(f"✓ Model found: {model_path}")
        print(f"  Size: {size_mb:.2f} MB\n")
        return True
    else:
        print(f"✗ Model NOT found: {model_path}\n")
        return False


def test_scripts():
    """Test if scripts exist"""
    print("="*60)
    print("Testing Scripts")
    print("="*60 + "\n")

    base_dir = "/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls"

    scripts = {
        'predict_with_yolo.py': 'Single video prediction',
        'batch_predict_yolo.py': 'Batch prediction',
        'QUICK_START.md': 'Quick start guide'
    }

    all_ok = True
    for script, description in scripts.items():
        script_path = os.path.join(base_dir, script)
        if os.path.exists(script_path):
            print(f"✓ {script:25s} {description}")
        else:
            print(f"✗ {script:25s} NOT FOUND")
            all_ok = False

    print()
    return all_ok


def test_data():
    """Test if data exists"""
    print("="*60)
    print("Testing Data")
    print("="*60 + "\n")

    data_dir = "/home/abdelraheem/Documents/Graduation_test/clips_mp4"

    if not os.path.exists(data_dir):
        print(f"✗ Data directory NOT found: {data_dir}\n")
        return False, None

    # Count subjects and videos
    num_subjects = 0
    num_videos = 0
    sample_video = None

    for subject in sorted(os.listdir(data_dir)):
        subject_path = os.path.join(data_dir, subject)
        if not os.path.isdir(subject_path):
            continue

        num_subjects += 1

        for exercise in os.listdir(subject_path):
            exercise_path = os.path.join(subject_path, exercise)
            if not os.path.isdir(exercise_path):
                continue

            for video in os.listdir(exercise_path):
                if video.endswith('.mp4'):
                    num_videos += 1
                    if sample_video is None:
                        sample_video = os.path.join(exercise_path, video)

    print(f"✓ Data directory: {data_dir}")
    print(f"  Subjects: {num_subjects}")
    print(f"  Total videos: {num_videos}")
    if sample_video:
        print(f"  Sample video: {sample_video}")
    print()

    return True, sample_video


def main():
    """Run all tests"""
    print("\n" + "="*60)
    print("QUICK PREDICTION TEST")
    print("Testing if everything is ready to use")
    print("="*60 + "\n")

    # Test imports
    imports_ok = test_imports()

    # Test model
    model_ok = test_model()

    # Test scripts
    scripts_ok = test_scripts()

    # Test data
    data_ok, sample_video = test_data()

    # Summary
    print("="*60)
    print("SUMMARY")
    print("="*60 + "\n")

    if imports_ok and model_ok and scripts_ok and data_ok:
        print("✓ Everything is ready!")
        print("\n" + "="*60)
        print("NEXT STEPS")
        print("="*60 + "\n")

        print("1. Test single video prediction:")
        if sample_video:
            print(f"   python3 predict_with_yolo.py '{sample_video}'")
        else:
            print("   python3 predict_with_yolo.py /path/to/video.mp4")

        print("\n2. Test batch prediction:")
        print("   python3 batch_predict_yolo.py /home/abdelraheem/Documents/Graduation_test/clips_mp4/0 test.csv")

        print("\n3. Read the quick start guide:")
        print("   cat QUICK_START.md")

    else:
        print("✗ Some issues found:")
        if not imports_ok:
            print("  - Install missing packages: pip3 install -r requirements.txt")
        if not model_ok:
            print("  - Train model or check model path")
        if not scripts_ok:
            print("  - Scripts are missing")
        if not data_ok:
            print("  - Data directory not found")

    print("\n" + "="*60 + "\n")


if __name__ == "__main__":
    main()
