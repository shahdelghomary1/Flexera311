# Postman Testing Guide for Exercise Counter API

## 1. Start Your API Server

```bash
cd /home/abdelraheem/Documents/Flutter_pro/yolo_implement
python run_api.py
```

Your API will be available at `https://unnoisy-atrial-nicolasa.ngrok-free.dev`

## 2. Test API Endpoints in Postman

### Test 1: Check API Health
**Method:** `GET`  
**URL:** `https://unnoisy-atrial-nicolasa.ngrok-free.dev/health`  
**Expected Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "active_sessions": 0
}
```

### Test 2: Get Available Exercises
**Method:** `GET`  
**URL:** `https://unnoisy-atrial-nicolasa.ngrok-free.dev/exercises`  
**Expected Response:**
```json
{
  "01": {"name": "Push-ups", "key": "pushups"},
  "02": {"name": "Squats", "key": "squats"},
  ...
}
```

### Test 3: Start Exercise Session
**Method:** `POST`  
**URL:** `https://unnoisy-atrial-nicolasa.ngrok-free.dev/session/start`  
**Headers:**
```
Content-Type: application/json
```
**Body (raw JSON):**
```json
{
  "exercise_id": "01",
  "user_id": "test_user"
}
```
**Expected Response:**
```json
{
  "session_key": "test_user_01_1712754123",
  "exercise_name": "Push-ups",
  "message": "Session started"
}
```

### Test 4: Process Frame (with base64 image)
**Method:** `POST`  
**URL:** `https://unnoisy-atrial-nicolasa.ngrok-free.dev/process`  
**Headers:**
```
Content-Type: application/json
```
**Body (raw JSON):**
```json
{
  "session_key": "test_user_01_1712754123",
  "image_base64": "YOUR_BASE64_IMAGE_HERE"
}
```

### Getting a Test Image (Base64)

**Option 1: Use a simple test image**
```bash
# Create a small test image and convert to base64
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==" 
```

**Option 2: Convert your own image**
```bash
base64 -i your_image.jpg
```

**Expected Response:**
```json
{
  "rep_count": 0,
  "feedback": "Position yourself in the camera view",
  "pose_detected": false,
  "exercise_quality": null
}
```

## 3. Postman Collection Setup

Create a new collection with these requests:

1. **Health Check** - GET `/health`
2. **List Exercises** - GET `/exercises` 
3. **Start Session** - POST `/session/start`
4. **Process Frame** - POST `/process`

### Environment Variables
Set these variables in Postman:
- `api_url`: `https://92xqktpp-8000.uks1.devtunnels.ms`
- `session_key`: (will be populated from Start Session response)

## 4. Testing Flow

1. **Start API server** with `python run_api.py`
2. **Test Health** - Should return healthy status
3. **List Exercises** - Should show all 16 exercises
4. **Start Session** - Copy the session_key from response
5. **Process Frame** - Use the session_key to process images

## 5. Common Issues

### CORS Errors
If you get CORS errors, the API already has CORS enabled for all origins.

### Session Not Found
Make sure you're using the correct `session_key` from the start session response.

### Model Loading
If you get "AI model is still loading", wait 10-15 seconds for YOLOv8 to load.

### Image Format
The `image_base64` should be a valid base64 encoded image (JPG, PNG, etc.).

## 6. Testing with Real Images

To test with real exercise poses:
1. Take a photo of someone doing push-ups
2. Convert to base64: `base64 -i pushup_photo.jpg`
3. Use the base64 string in the `/process` request
4. You should get rep_count > 0 and positive feedback

## 7. Sample Postman Collection JSON

```json
{
  "info": {
    "name": "Exercise Counter API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "api_url",
      "value": "https://unnoisy-atrial-nicolasa.ngrok-free.dev"
    }
  ],
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "{{api_url}}/health"
      }
    },
    {
      "name": "Start Session",
      "request": {
        "method": "POST",
        "url": "{{api_url}}/session/start",
        "header": [{"key": "Content-Type", "value": "application/json"}],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"exercise_id\": \"01\",\n  \"user_id\": \"test_user\"\n}"
        }
      }
    }
  ]
}
```