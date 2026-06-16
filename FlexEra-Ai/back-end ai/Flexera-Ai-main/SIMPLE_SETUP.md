# Exercise Counter - Simple Setup

This is a simplified version that includes only:
- Camera integration
- Exercise counting
- Basic API endpoints

## Quick Start

### 1. Start the Python API Server

```bash
# Install dependencies (if not already done)
pip install -r requirements.txt

# Start the minimal API server
python3 run_minimal.py
```

The API will be available at: http://localhost:8000

### 2. Run the Flutter App

```bash
# Navigate to Flutter app directory
cd flutter_exercise_app

# Get dependencies
flutter pub get

# Run the app (make sure you have an Android device connected or emulator running)
flutter run
```

### 3. Using the App

1. **Select Exercise**: Choose from the dropdown (01-16 exercises available)
2. **Press START**: This will:
   - Open the camera
   - Start sending frames to the API
   - Begin counting exercise repetitions
3. **View Count**: See real-time count updates on the screen
4. **Press STOP**: Stop the counting session
5. **Press RESET**: Reset the count to zero

## API Endpoints

### POST /count
Send camera frame and get exercise count
```json
{
  "exercise_id": "01", 
  "user_id": "user123",
  "image_base64": "base64_encoded_image"
}
```

Response:
```json
{
  "success": true,
  "exercise_name": "Push-ups",
  "current_count": 5,
  "message": "Count: 5"
}
```

### POST /reset/{user_id}/{exercise_id}
Reset exercise count to zero

### GET /exercises
List all available exercises (01-16)

## Configuration

### Change API URL in Flutter App
Edit `flutter_exercise_app/lib/main.dart` line 45:
```dart
String _apiUrl = "http://YOUR_IP:8000"; // Change this to your server IP
```

### Available Exercises
- 01: Push-ups
- 02: Squats  
- 03: Lunges
- 04: Planks
- 05: Jumping Jacks
- 06: Burpees
- 07: Mountain Climbers
- 08: High Knees
- 09: Butt Kicks
- 10: Leg Raises
- 11: Russian Twists
- 12: Bicycle Crunches
- 13: Wall Sit
- 14: Tricep Dips
- 15: Calf Raises
- 16: Side Planks

## Troubleshooting

### Camera Permission Issues
Make sure camera permissions are granted in Android settings.

### Network Issues
- Make sure your phone and computer are on the same network
- Update the `_apiUrl` in Flutter app to use your computer's IP address
- Check if port 8000 is accessible

### API Not Responding
- Make sure the Python server is running
- Check the server logs for any errors
- Verify the YOLOv8 model file (yolov8n-pose.pt) exists

## Files Structure

```
├── app/
│   ├── main_minimal.py          # Simplified API server
│   └── routers/
│       └── simple_count.py      # Simple counting endpoint
├── flutter_exercise_app/        # Flutter mobile app
│   └── lib/
│       └── main.dart            # Main Flutter app code
├── run_minimal.py               # Server startup script
└── SIMPLE_SETUP.md             # This file
```