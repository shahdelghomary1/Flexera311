# Flutter Exercise Counter Integration Guide

## Overview

This guide shows you how to integrate exercise counting functionality into your existing Flutter app using your Python API.

## Prerequisites

- Your Python API running on `https://unnoisy-atrial-nicolasa.ngrok-free.dev`
- Existing Flutter app
- Android/iOS device with camera

## Step 1: Add Dependencies

Add these to your `pubspec.yaml`:

```bash
flutter pub add camera http permission_handler
```

## Step 2: Add Permissions

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to count exercises</string>
```

## Step 3: Core Integration Code

Create `lib/exercise_camera.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class ExerciseCamera extends StatefulWidget {
  final String apiUrl;
  final String exerciseId;
  final String userId;
  final Function(int count, String feedback)? onUpdate;

  const ExerciseCamera({
    Key? key,
    this.apiUrl = 'https://unnoisy-atrial-nicolasa.ngrok-free.dev',
    required this.exerciseId,
    required this.userId,
    this.onUpdate,
  }) : super(key: key);

  @override
  _ExerciseCameraState createState() => _ExerciseCameraState();
}

class _ExerciseCameraState extends State<ExerciseCamera> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _sessionKey = '';
  int _count = 0;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final permission = await Permission.camera.request();
    if (permission != PermissionStatus.granted) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() => _isInitialized = true);
  }

  Future<void> startSession() async {
    try {
      final response = await http.post(
        Uri.parse('${widget.apiUrl}/session/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'exercise_id': widget.exerciseId,
          'user_id': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionKey = data['session_key'];
        _startProcessing();
      }
    } catch (e) {
      print('Session error: $e');
    }
  }

  void _startProcessing() {
    Stream.periodic(const Duration(milliseconds: 500)).listen((_) {
      if (!_isProcessing && _sessionKey.isNotEmpty && mounted) {
        _processFrame();
      }
    });
  }

  Future<void> _processFrame() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('${widget.apiUrl}/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_key': _sessionKey,
          'image_base64': base64Image,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _count = data['rep_count'] ?? 0;
        _feedback = data['feedback'] ?? '';

        if (widget.onUpdate != null) {
          widget.onUpdate!(_count, _feedback);
        }
        setState(() {});
      }

      await File(image.path).delete();
    } catch (e) {
      print('Processing error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(child: CameraPreview(_controller!)),
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.black87,
          child: Column(
            children: [
              Text('Count: $_count',
                style: const TextStyle(color: Colors.white, fontSize: 32)),
              Text(_feedback,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
              ElevatedButton(
                onPressed: startSession,
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

## Step 4: Usage in Your App

```dart
import 'package:flutter/material.dart';
import 'exercise_camera.dart';

class MyExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise')),
      body: ExerciseCamera(
        exerciseId: '01', // Push-ups
        userId: 'user123',
        apiUrl: 'https://unnoisy-atrial-nicolasa.ngrok-free.dev', // Your API URL
        onUpdate: (count, feedback) {
          print('Count: $count, Feedback: $feedback');
        },
      ),
    );
  }
}
```

## CLI Commands Summary

```bash
# 1. Add dependencies
flutter pub add camera http permission_handler

# 2. Create the integration file
# Copy the ExerciseCamera widget code to lib/exercise_camera.dart

# 3. Add permissions to AndroidManifest.xml and Info.plist

# 4. Use in your app
# Import and use ExerciseCamera widget

# 5. Build and test
flutter run
```

## Exercise IDs

- "01": Push-ups
- "02": Squats
- "03": Lunges
- "04": Planks
- "05": Jumping Jacks
- "06": Burpees
- "07": Mountain Climbers
- "08": High Knees
- "09": Butt Kicks
- "10": Leg Raises
- "11": Russian Twists
- "12": Bicycle Crunches
- "13": Wall Sit
- "14": Tricep Dips
- "15": Calf Raises
- "16": Side Planks

## API Endpoints Used

- `POST /session/start` - Start exercise session
- `POST /process` - Process camera frame
