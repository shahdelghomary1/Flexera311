import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;

  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isProcessing = false;

  DateTime? _lastFrameTime;

  int _targetFps = 10;
  int _jpegQuality = 85;
  int _imageSize = 512;

  int _droppedFrames = 0;
  int _processedFrames = 0;

  double _networkLatencyMs = 0;

  Uint8List? _lastSentFrame;

  final Queue<Uint8List> _frameQueue = Queue();

  bool _sendingFrame = false;

  final Map<String, double> _smoothedAngles = {};

  int _countdownSeconds = 3;

  Timer? _countdownTimer;

  StreamController<Uint8List>? _frameStreamController;

  Stream<Uint8List>? get frameStream => _frameStreamController?.stream;

  Future<void> initialize() async {
    try {
      final permission = await Permission.camera.request();

      if (!permission.isGranted) {
        throw Exception("Camera permission denied");
      }

      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      _frameStreamController = StreamController.broadcast();

      _isInitialized = true;

      debugPrint("📸 Camera initialized");
    } catch (e) {
      throw Exception("Camera init failed $e");
    }
  }

  Future<void> startCountdown() async {
    _countdownSeconds = 3;

    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSeconds--;

      debugPrint("⏳ Countdown $_countdownSeconds");

      if (_countdownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  int get countdown => _countdownSeconds;

  Future<void> startCapturing() async {
    if (!_isInitialized || _controller == null) {
      return;
    }

    if (_isCapturing) {
      return;
    }

    _isCapturing = true;

    await startCountdown();

    await _controller!.startImageStream((CameraImage image) async {
      if (_countdownSeconds > 0) {
        return;
      }

      final now = DateTime.now();

      if (_lastFrameTime != null) {
        final diff = now.difference(_lastFrameTime!).inMilliseconds;

        if (diff < 1000 ~/ _targetFps) {
          _droppedFrames++;

          return;
        }
      }

      _lastFrameTime = now;

      if (_isProcessing) {
        _droppedFrames++;

        return;
      }

      try {
        _isProcessing = true;

        final jpegBytes = _processFrame({
          "image": image,

          "size": _imageSize,

          "quality": _jpegQuality,
        });

        debugPrint("🖼 JPEG Created ${jpegBytes.length} bytes");


        if (_frameQueue.length > 2) {
          _frameQueue.removeFirst();
        }

        _frameQueue.add(jpegBytes);

        _sendNextFrame();

        _processedFrames++;
      } catch (e) {
        debugPrint("❌ Frame error $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  void _sendNextFrame() {
    if (_sendingFrame) {
      return;
    }

    if (_frameQueue.isEmpty) {
      return;
    }

    _sendingFrame = true;

    Future.microtask(() {
      try {
        final frame = _frameQueue.removeFirst();

        _frameStreamController?.add(frame);

        debugPrint("📤 Frame emitted ${frame.length}");
      } finally {
        _sendingFrame = false;

        if (_frameQueue.isNotEmpty) {
          _sendNextFrame();
        }
      }
    });
  }

  Future<void> stopCapturing() async {
    _isCapturing = false;

    _countdownTimer?.cancel();

    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  void updateLatency(double ms) {
    _networkLatencyMs = ms;
  }

  double smoothAngle(String key, double value) {
    const alpha = 0.7;

    if (!_smoothedAngles.containsKey(key)) {
      _smoothedAngles[key] = value;

      return value;
    }

    final result = alpha * _smoothedAngles[key]! + (1 - alpha) * value;

    _smoothedAngles[key] = result;

    return result;
  }

  CameraController? get controller => _controller;

  bool get isInitialized => _isInitialized;

  int get currentFps => _targetFps;

  int get currentQuality => _jpegQuality;

  int get currentImageSize => _imageSize;

  int get droppedFrames => _droppedFrames;

  int get processedFrames => _processedFrames;

  void dispose() {
    stopCapturing();

    _frameQueue.clear();

    _frameStreamController?.close();

    _controller?.dispose();
  }
}

Uint8List _processFrame(Map<String, dynamic> params) {
  final CameraImage image = params["image"];

  final int targetSize = params["size"];

  final int quality = params["quality"];

  final int width = image.width;

  final int height = image.height;

  final img.Image output = img.Image(width: width, height: height);

  final yPlane = image.planes[0];

  final uPlane = image.planes[1];

  final vPlane = image.planes[2];

  final yBytes = yPlane.bytes;

  final uBytes = uPlane.bytes;

  final vBytes = vPlane.bytes;

  final uvRow = uPlane.bytesPerRow;

  final uvPixel = uPlane.bytesPerPixel!;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final uvIndex = uvPixel * (x ~/ 2) + uvRow * (y ~/ 2);

      final index = y * width + x;

      final yp = yBytes[index];

      final up = uBytes[uvIndex];

      final vp = vBytes[uvIndex];

      int r = (yp + vp * 1436 / 1024 - 179).round();

      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round();

      int b = (yp + up * 1814 / 1024 - 227).round();

      output.setPixelRgb(
        x,
        y,
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
      );
    }
  }

  final resized = img.copyResize(output, width: targetSize, height: targetSize);

  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}
