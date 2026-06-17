import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../model/services/camera_service.dart';
import '../../model/services/exercise_api_service.dart';
import '../../model/services/voice_feedback_service.dart';
import '../../model/services/simple_voice_feedback_service.dart';
import '../../core/network/cache_helper.dart';
import '../core/network/constants.dart';
import '../core/network/dio_helper.dart';
import '../core/network/end_points.dart';

enum ExerciseState { notStarted, starting, active, paused, finished, error }

class AiExerciseViewModel extends ChangeNotifier {
  final String exerciseKey;
  final String exerciseName;
  final int targetSets;
  final int targetReps;
  final String exerciseId;

  final CameraService _cameraService = CameraService();
  final ExerciseApiService _apiService = ExerciseApiService();
  final VoiceFeedbackService _voiceService = VoiceFeedbackService();
  final SimpleVoiceFeedbackService _simpleVoiceService =
      SimpleVoiceFeedbackService();

  WebSocketChannel? _webSocketChannel;
  bool _usingSimpleVoice = false;
  ExerciseState _state = ExerciseState.notStarted;
  ExerciseStats? _currentStats;
  String? _errorMessage;
  bool _isInitializing = false;
  StreamSubscription<Uint8List>? _frameSubscription;

  // ── FIX 1: track whether the completion API was already called ──
  bool _completionCalled = false;

  AiExerciseViewModel({
    required this.exerciseKey,
    required this.exerciseName,
    required this.targetSets,
    required this.targetReps,
    required this.exerciseId,
  }) {
    _initializeCamera();
    _initializeVoice();
  }

  ExerciseState get state => _state;

  ExerciseStats? get currentStats => _currentStats;

  String? get errorMessage => _errorMessage;

  bool get isInitializing => _isInitializing;

  CameraService get cameraService => _cameraService;

  bool get isCameraInitialized => _cameraService.isInitialized;

  Future<void> _initializeCamera() async {
    try {
      _isInitializing = true;
      notifyListeners();
      await _cameraService.initialize();
      _isInitializing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Camera initialization failed: $e';
      _state = ExerciseState.error;
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> startExercise() async {
    if (_state == ExerciseState.active) return;

    try {
      _state = ExerciseState.starting;
      _errorMessage = null;
      _completionCalled = false; // reset on every new session
      notifyListeners();

      final String userId = CacheHelper.getData(key: 'uId') ?? "yasmin_user";

      // ── FIX 2: use the actual targetSets / targetReps passed in ──
      debugPrint(
        '🚀 Starting Session: Exercise ID $exerciseKey | '
        'User $userId | Sets $targetSets | Reps $targetReps',
      );

      final sessionKey = await _apiService.startExerciseSession(
        exerciseId: exerciseKey,
        userId: userId,
        targetSets: targetSets, // was hard-coded 3
        targetReps: targetReps, // was hard-coded 10
      );

      final String cleanSessionKey = sessionKey.trim().replaceAll('#', '');
      final String wsUrl = 'ws://135.225.104.150:8000/ws/$cleanSessionKey';

      debugPrint("🔌 Connecting $wsUrl");

      _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _webSocketChannel!.stream.listen(
        (message) {
          debugPrint("📩 Server: $message");

          final data = jsonDecode(message);
          _currentStats = ExerciseStats.fromJson(data);

          // ── FIX 3: detect completion from server stats ──
          _checkForCompletion();

          if (_currentStats?.feedback != null &&
              _currentStats!.feedback.isNotEmpty) {
            _speakFeedback(_currentStats!.feedback);
          }

          notifyListeners();
        },
        onError: (error) {
          debugPrint("❌ WS Error $error");
          _state = ExerciseState.error;
          notifyListeners();
        },
        onDone: () {
          debugPrint("📡 WS Closed");
          // Server closed the socket — treat as finished if we were active
          if (_state == ExerciseState.active) {
            _handleExerciseFinished();
          }
        },
      );

      // ── FIX 4: start camera BEFORE setting state to active ──
      // so frames are ready as soon as the WS is open
      await _cameraService.startCapturing();

      _state = ExerciseState.active;
      notifyListeners();

      _frameSubscription = _cameraService.frameStream?.listen((frame) {
        if (_webSocketChannel == null || _state != ExerciseState.active) return;
        try {
          _webSocketChannel!.sink.add(frame);
          debugPrint("📤 Binary JPEG Sent: ${frame.length} bytes");
        } catch (e) {
          debugPrint("❌ Send frame error $e");
        }
      });
    } catch (e) {
      debugPrint("❌ Start exercise error: $e");
      _errorMessage = "Failed to start: $e";
      _state = ExerciseState.error;
      notifyListeners();
    }
  }

  /// Called every time we receive a stats update from the server.
  void _checkForCompletion() {
    final stats = _currentStats;
    if (stats == null || _completionCalled) return;

    final bool allSetsComplete =
        stats.completedSets >= stats.totalSets && stats.totalSets > 0;

    // Some backends also signal via currentReps reaching targetReps on the
    // last set — cover both patterns:
    final bool lastRepComplete =
        stats.completedSets == stats.totalSets - 1 &&
        stats.currentReps >= targetReps;

    if (allSetsComplete || lastRepComplete) {
      debugPrint(
        "🏆 Exercise complete — sets ${stats.completedSets}/${stats.totalSets}",
      );
      _handleExerciseFinished();
    }
  }

  void _handleExerciseFinished() {
    _state = ExerciseState.finished;
    notifyListeners();
    _stopStreaming();
    if (!_completionCalled) {
      _completionCalled = true;
      _markExerciseCompleted();
    }
  }

  void _stopStreaming() {
    _cameraService.stopCapturing();
    _frameSubscription?.cancel();
    _webSocketChannel?.sink.close();
  }

  Future<void> stopExercise() async {
    _stopStreaming();
    _state = ExerciseState.finished;
    notifyListeners();
  }

  Future<void> _initializeVoice() async {
    try {
      await _voiceService.initialize();
      _usingSimpleVoice = !_voiceService.isEnabled;
    } catch (e) {
      await _simpleVoiceService.initialize();
      _usingSimpleVoice = true;
    }
  }

  Future<void> _speakFeedback(String feedback) async {
    if (_usingSimpleVoice) {
      await _simpleVoiceService.speak(feedback);
    } else {
      await _voiceService.speak(feedback);
    }
  }

  void clearError() {
    _errorMessage = null;
    _state = ExerciseState.notStarted;
    notifyListeners();
  }

  Future<void> _markExerciseCompleted() async {
    try {
      await DioHelper.postData(
        url: EndPoints.isCompleted,
        token: token,
        data: {'exercise_id': exerciseId, 'is_completed': true},
      );
      debugPrint("✅ Exercise marked as completed");
    } catch (e) {
      debugPrint("❌ Auto complete failed: $e");
    }
  }

  @override
  void dispose() {
    _frameSubscription?.cancel();
    _cameraService.stopCapturing();
    _webSocketChannel?.sink.close();
    _cameraService.dispose();
    _apiService.dispose();
    _voiceService.dispose();
    _simpleVoiceService.dispose();
    super.dispose();
  }
}
