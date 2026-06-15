"""
Test script to verify the YOLO + Transformer pipeline
"""

import os
import sys

def test_imports():
    """Test if all required packages are installed"""
    print("Testing imports...")
    try:
        import torch
        print(f"  ✓ PyTorch {torch.__version__}")
    except ImportError:
        print("  ✗ PyTorch not installed")
        return False

    try:
        import torchvision
        print(f"  ✓ TorchVision {torchvision.__version__}")
    except ImportError:
        print("  ✗ TorchVision not installed")
        return False

    try:
        import tensorflow as tf
        print(f"  ✓ TensorFlow {tf.__version__}")
    except ImportError:
        print("  ✗ TensorFlow not installed")
        return False

    try:
        from ultralytics import YOLO
        print(f"  ✓ Ultralytics YOLO")
    except ImportError:
        print("  ✗ Ultralytics not installed")
        return False

    try:
        import cv2
        print(f"  ✓ OpenCV {cv2.__version__}")
    except ImportError:
        print("  ✗ OpenCV not installed")
        return False

    try:
        import numpy as np
        print(f"  ✓ NumPy {np.__version__}")
    except ImportError:
        print("  ✗ NumPy not installed")
        return False

    return True

def test_model_exists():
    """Test if the trained model exists"""
    print("\nChecking for trained model...")
    model_path = "/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls/transformer_model_high_acc.keras"
    if os.path.exists(model_path):
        print(f"  ✓ Model found: {model_path}")
        return True
    else:
        print(f"  ✗ Model not found: {model_path}")
        print("  You need to train the model first using 'Transformer-Conv1D Hybrid.py'")
        return False

def test_data_exists():
    """Test if the data directory exists"""
    print("\nChecking for data directory...")
    data_dir = "/home/abdelraheem/Documents/Graduation_test/clips_mp4"
    if os.path.exists(data_dir):
        num_subjects = len([d for d in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, d)) and d.isdigit()])
        print(f"  ✓ Data directory found: {data_dir}")
        print(f"  ✓ Found {num_subjects} subjects")
        return True
    else:
        print(f"  ✗ Data directory not found: {data_dir}")
        return False

def test_inference_script():
    """Test if inference script can be imported"""
    print("\nTesting inference script...")
    try:
        sys.path.insert(0, '/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls')
        from inference_yolo_transformer import ExerciseClassifier
        print("  ✓ Inference script can be imported")
        return True
    except Exception as e:
        print(f"  ✗ Error importing inference script: {e}")
        return False

def test_sample_video():
    """Test processing a sample video"""
    print("\nLooking for a sample video to test...")
    data_dir = "/home/abdelraheem/Documents/Graduation_test/clips_mp4"

    # Find first video
    for subject in sorted(os.listdir(data_dir)):
        subject_path = os.path.join(data_dir, subject)
        if not os.path.isdir(subject_path):
            continue

        for exercise in sorted(os.listdir(subject_path)):
            exercise_path = os.path.join(subject_path, exercise)
            if not os.path.isdir(exercise_path):
                continue

            for video_file in sorted(os.listdir(exercise_path)):
                if video_file.endswith('.mp4'):
                    video_path = os.path.join(exercise_path, video_file)
                    print(f"  Found sample video: {video_path}")
                    print(f"  Subject: {subject}, Exercise: {exercise}, Camera: {video_file}")
                    return video_path

    print("  ✗ No sample video found")
    return None

def main():
    """Run all tests"""
    print("=" * 60)
    print("YOLO + Transformer Pipeline Test")
    print("=" * 60)

    all_passed = True

    # Test imports
    if not test_imports():
        all_passed = False
        print("\n⚠ Please install missing packages:")
        print("  pip install -r requirements.txt")

    # Test model
    if not test_model_exists():
        all_passed = False

    # Test data
    if not test_data_exists():
        all_passed = False

    # Test inference script
    if not test_inference_script():
        all_passed = False

    # Find sample video
    sample_video = test_sample_video()

    print("\n" + "=" * 60)
    if all_passed:
        print("✓ All tests passed!")
        print("\nYou can now:")
        print("1. Extract features with YOLO detection:")
        print("   python extract_resnet50_yolo.py")
        print("\n2. Train the model (if not already trained):")
        print("   python 'Transformer-Conv1D Hybrid.py'")
        print("\n3. Run inference on a video:")
        print("   python inference_yolo_transformer.py <video_path>")
        if sample_video:
            print(f"\n   Example:")
            print(f"   python inference_yolo_transformer.py '{sample_video}'")
        print("\n4. Run inference on webcam:")
        print("   python inference_yolo_transformer.py")
    else:
        print("✗ Some tests failed. Please fix the issues above.")

    print("=" * 60)

if __name__ == "__main__":
    main()
