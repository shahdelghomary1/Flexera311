# Exercise Counter API - Complete Setup Guide

## 📁 New File Structure

```
├── app/
│   └── api/
│       ├── __init__.py
│       └── exercise_api.py          # 🆕 ALL APIs in one file
├── flutter_exercise_app/            # Flutter mobile app  
├── run_api.py                       # 🆕 New API server launcher
└── API_SETUP.md                     # This guide
```

## 🚀 Quick Start

### 1. Start the API Server

```bash
# Method 1: Using the new launcher (Recommended)
python3 run_api.py

# Method 2: Direct uvicorn
uvicorn app.api.exercise_api:app --host 0.0.0.0 --port 8000 --reload
```

### 2. Run Flutter App

```bash
cd flutter_exercise_app
flutter pub get
flutter run
```

## 📡 API Endpoints

### **POST /count** - Main Exercise Counting
```bash
curl -X POST "http://localhost:8000/count" \
  -H "Content-Type: application/json" \
  -d '{
    "exercise_id": "01",
    "user_id": "user123", 
    "image_base64": "base64_encoded_camera_frame"
  }'
```

**Response:**
```json
{
  "success": true,
  "exercise_id": "01",
  "exercise_name": "Push-ups",
  "current_count": 5,
  "message": "Count: 5",
  "error": null
}
```

### **POST /reset/{user_id}/{exercise_id}** - Reset Count
```bash
curl -X POST "http://localhost:8000/reset/user123/01"
```

### **GET /exercises** - List All Exercises
```bash
curl "http://localhost:8000/exercises"
```

### **GET /health** - API Health Check
```bash
curl "http://localhost:8000/health"
```

### **GET /sessions** - Active Sessions
```bash
curl "http://localhost:8000/sessions"
```

### **DELETE /sessions/{user_id}** - Clear User Sessions
```bash
curl -X DELETE "http://localhost:8000/sessions/user123"
```

## 🔧 Configuration

### Flutter App API URL
Edit `flutter_exercise_app/lib/main.dart` line 45:
```dart
String _apiUrl = "http://192.168.1.100:8000"; // Use your computer's IP
```

### Find Your Computer's IP
```bash
# Linux/Mac
ip addr show | grep "inet " | grep -v 127.0.0.1

# Windows  
ipconfig | findstr IPv4
```

## 📋 Available Exercises

| ID | Exercise Name      | Category    | Session |
|----|-------------------|-------------|---------|
| 01 | Push-ups          | upper_left  | 1       |
| 02 | Squats            | lower_left  | 1       |
| 03 | Lunges            | lower_right | 1       |
| 04 | Planks            | upper_right | 1       |
| 05 | Jumping Jacks     | upper_left  | 2       |
| 06 | Burpees           | lower_left  | 2       |
| 07 | Mountain Climbers | lower_right | 2       |
| 08 | High Knees        | upper_right | 2       |
| 09 | Butt Kicks        | upper_left  | 1       |
| 10 | Leg Raises        | lower_left  | 1       |
| 11 | Russian Twists    | lower_right | 1       |
| 12 | Bicycle Crunches  | upper_right | 1       |
| 13 | Wall Sit          | upper_left  | 2       |
| 14 | Tricep Dips       | lower_left  | 2       |
| 15 | Calf Raises       | lower_right | 2       |
| 16 | Side Planks       | upper_right | 2       |

## 🛠️ Development Tools

### API Documentation
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Testing APIs

**Test with curl:**
```bash
# Health check
curl http://localhost:8000/health

# List exercises  
curl http://localhost:8000/exercises

# Test with dummy base64 (will fail gracefully)
curl -X POST http://localhost:8000/count \
  -H "Content-Type: application/json" \
  -d '{"exercise_id":"01","user_id":"test","image_base64":"dummy"}'
```

**Test with Python:**
```python
import requests
import base64

# Health check
response = requests.get("http://localhost:8000/health")
print(response.json())

# List exercises
response = requests.get("http://localhost:8000/exercises") 
print(response.json())
```

## 📱 Flutter App Usage

1. **Open App** → Camera permission will be requested
2. **Select Exercise** → Choose from dropdown (01-16)
3. **Press START** → Camera opens, counting begins
4. **Exercise** → Do the selected exercise in front of camera
5. **View Count** → Real-time count updates on screen
6. **STOP/RESET** → Control session as needed

## 🐛 Troubleshooting

### API Not Starting
```bash
# Check if port 8000 is in use
lsof -i :8000

# Kill process using port 8000
kill -9 $(lsof -t -i:8000)
```

### Model Loading Issues
- Ensure `yolov8n-pose.pt` exists in project root
- Check server logs for model loading errors
- Restart API server if model fails to load

### Flutter Connection Issues
- Verify API server is running: `curl http://localhost:8000/health`
- Update Flutter app IP address to your computer's IP
- Ensure phone and computer are on same network
- Check firewall settings (allow port 8000)

### Camera Permission Issues
- Go to Android Settings → Apps → Exercise Counter → Permissions
- Enable Camera permission manually

## 🔍 Monitoring

### View Server Logs
The API server shows detailed logs including:
- Model loading status
- Incoming requests
- Processing results
- Errors and exceptions

### Check Active Sessions
```bash
curl http://localhost:8000/sessions
```

### Monitor Health
```bash
watch -n 2 "curl -s http://localhost:8000/health | jq"
```

## 🎯 Key Features

✅ **All APIs in one file** (`app/api/exercise_api.py`)  
✅ **Simple startup script** (`run_api.py`)  
✅ **Complete API documentation** (Swagger UI)  
✅ **Health monitoring** endpoints  
✅ **Session management** (create/reset/list)  
✅ **Error handling** with proper HTTP codes  
✅ **CORS enabled** for cross-origin requests  
✅ **Base64 image processing** for camera frames  
✅ **Real-time exercise counting** with YOLOv8  

The entire API is now organized in a single, well-documented file for easy maintenance and deployment!