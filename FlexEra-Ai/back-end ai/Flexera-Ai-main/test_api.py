#!/usr/bin/env python3
"""
Simple test script for the Exercise API
Run this to verify all endpoints work correctly
"""

import uvicorn
import time
import requests
import threading
import base64
from exercise_api import app

def start_server():
    """Start the API server in background"""
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="error")

def test_api():
    """Test all API endpoints"""
    base_url = "http://localhost:8000"
    
    print("🧪 Testing Exercise API...")
    time.sleep(3)  # Wait for server to start
    
    try:
        # Test 1: Root endpoint
        print("1. Testing root endpoint...")
        response = requests.get(f"{base_url}/")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}")
        
        # Test 2: Get exercises
        print("\n2. Testing exercises list...")
        response = requests.get(f"{base_url}/exercises")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            exercises = response.json()
            print(f"   Found {len(exercises)} exercises")
            print(f"   First exercise: {exercises[0]['name']}")
        
        # Test 3: Start exercise
        print("\n3. Testing start exercise...")
        exercise_key = "bending_knee_no_support_seated_left"
        response = requests.post(
            f"{base_url}/start-exercise",
            json={"exercise_key": exercise_key}
        )
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}")
        
        # Test 4: Camera frame (with dummy image)
        print("\n4. Testing camera frame...")
        dummy_image = base64.b64encode(b"dummy_image_data").decode()
        response = requests.post(
            f"{base_url}/camera-frame",
            json={"image_base64": dummy_image}
        )
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"   Feedback: {result.get('feedback', 'None')}")
            print(f"   Status: {result.get('status', 'Unknown')}")
        else:
            print(f"   Error: {response.text}")
        
        # Test 5: Get stats
        print("\n5. Testing current stats...")
        response = requests.get(f"{base_url}/current-stats")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            stats = response.json()
            print(f"   Exercise: {stats.get('exercise_name', 'Unknown')}")
            print(f"   Total reps: {stats.get('total_reps', 0)}")
        
        # Test 6: Stop exercise
        print("\n6. Testing stop exercise...")
        response = requests.post(f"{base_url}/stop-exercise")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.json()}")
        
        print("\n✅ All API tests completed!")
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")

if __name__ == "__main__":
    print("🚀 Starting API Server...")
    
    # Start server in background thread
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()
    
    # Run tests
    test_api()
    
    print("\n💡 To test manually:")
    print("   1. Run: python exercise_api.py")
    print("   2. Visit: http://localhost:8000/docs")
    print("   3. Test endpoints with Flutter app")