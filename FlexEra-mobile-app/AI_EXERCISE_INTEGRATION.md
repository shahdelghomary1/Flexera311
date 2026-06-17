# AI Exercise Integration Guide

This document explains how to integrate the AI Exercise functionality with camera and API into your Flutter application.

## Overview

The AI Exercise system consists of:
1. **Camera Service** - Captures and processes camera frames
2. **API Service** - Communicates with the AI backend
3. **UI Components** - Provides camera preview and exercise controls
4. **Integration Components** - Easily integrate with existing exercise screens

## Files Added

### Services
- `lib/model/services/exercise_api_service.dart` - API communication with AI backend
- `lib/model/services/camera_service.dart` - Camera capture and frame processing

### UI Components
- `lib/view/screens/ai_exercise_screen.dart` - Main AI exercise screen
- `lib/view_model/ai_exercise_view_model.dart` - Business logic for AI exercises
- `lib/view/widget/ai_exercise_widgets.dart` - UI widgets for camera preview and controls
- `lib/view/widget/ai_exercise_button.dart` - Button to launch AI exercise from existing screens

### Configuration
- Updated `pubspec.yaml` with required dependencies
- Updated `.env` with API configuration

## API Endpoints

The system integrates with the following API endpoints:

1. **GET /exercises** - Returns list of available exercises
2. **POST /start-exercise** - Starts an exercise session
3. **POST /camera-frame** - Sends camera frames for AI processing
4. **GET /current-stats** - Gets real-time exercise statistics
5. **POST /stop-exercise** - Ends the exercise session

## Configuration

### Environment Variables

Add to your `.env` file:
```
AI_EXERCISE_API_BASE_URL=http://your-api-base-url.com/api
```

### Dependencies

The following dependencies were added to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  camera: ^0.10.5+5
  image: ^4.1.3
```

## Usage

### Option 1: Direct Navigation

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => AiExerciseScreen(
      exerciseKey: 'push_ups',
      exerciseName: 'Push Ups',
    ),
  ),
);
```

### Option 2: Using the Integration Button

Add the `AiExerciseButton` to any existing exercise screen:

```dart
import 'package:flexera/view/widget/ai_exercise_button.dart';

// In your exercise detail screen:
AiExerciseButton(
  exerciseName: 'Push Ups',
  exerciseKey: 'push_ups', // optional, will be generated if not provided
)
```

## Camera Permissions

The app automatically requests camera permissions when initializing. Make sure your app has the necessary permissions configured:

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera for AI-powered exercise tracking</string>
```

## Error Handling

The system includes comprehensive error handling for:
- Camera initialization failures
- Network connectivity issues
- API timeouts and errors
- Permission denials
- Invalid JSON responses

## Exercise Flow

1. **Initialization**: Camera permissions requested and camera initialized
2. **Start Exercise**: API call to start exercise session
3. **Active Session**: Camera frames sent to AI backend every second
4. **Real-time Stats**: Exercise statistics polled every 2 seconds
5. **Pause/Resume**: Camera capture can be paused and resumed
6. **Stop Exercise**: Session ended and final stats retrieved

## Customization

### Frame Capture Interval

Modify the frame capture interval in `CameraService.startCapturing()`:

```dart
await _cameraService.startCapturing(intervalMs: 500); // 500ms = 2 FPS
```

### API Timeout

Modify the timeout in `ExerciseApiService`:

```dart
static const int _timeoutSeconds = 30; // 30 seconds
```

### Camera Resolution

Modify the camera resolution in `CameraService.initialize()`:

```dart
_controller = CameraController(
  cameras.first,
  ResolutionPreset.high, // Change to high/low/medium/max
  enableAudio: false,
);
```

## Integration with Existing Exercise System

To integrate with your existing exercise system:

1. Add the `AiExerciseButton` to your exercise detail screens
2. Map your existing exercise names to API keys
3. Optionally modify the UI colors to match your theme
4. Configure your backend API URL in the `.env` file

## Backend Requirements

Your AI backend should implement the specified endpoints and:
- Accept base64-encoded image frames
- Return exercise statistics in the expected JSON format
- Handle exercise session management
- Provide real-time feedback on exercise form/accuracy

## Troubleshooting

### Common Issues

1. **Camera not working**: Check permissions and device compatibility
2. **API errors**: Verify backend URL and network connectivity
3. **Frame sending fails**: Check image processing and base64 encoding
4. **UI not updating**: Ensure proper state management and notifyListeners() calls

### Debugging

Enable debug logging by checking the console for:
- Camera initialization messages
- API request/response logs
- Frame processing timing
- Permission status updates