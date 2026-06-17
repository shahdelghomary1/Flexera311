import 'package:flutter/foundation.dart';

/// A fallback voice feedback service that provides text feedback when TTS is not available
class SimpleVoiceFeedbackService {
  static final SimpleVoiceFeedbackService _instance = SimpleVoiceFeedbackService._internal();
  factory SimpleVoiceFeedbackService() => _instance;
  SimpleVoiceFeedbackService._internal();

  bool _isEnabled = true;
  String? _lastFeedback;
  DateTime? _lastFeedbackTime;
  
  // Cooldown period to prevent spam
  static const Duration _cooldownDuration = Duration(seconds: 3);

  Future<void> initialize() async {
    debugPrint('Simple voice feedback service initialized (fallback mode)');
  }

  Future<bool> speak(String text, {bool force = false}) async {
    if (!_isEnabled || text.isEmpty) {
      return false;
    }

    // Apply cooldown to prevent spam (unless forced)
    if (!force && _shouldSkipDueToCooldown(text)) {
      return false;
    }

    try {
      _lastFeedback = text;
      _lastFeedbackTime = DateTime.now();
      
      // Since TTS might not work, at least log the feedback for debugging
      debugPrint('💬 Exercise Feedback: $text');
      
      // You could also emit this to a stream or callback for UI display
      return true;
    } catch (e) {
      debugPrint('Error in simple voice feedback: $e');
      return false;
    }
  }

  bool _shouldSkipDueToCooldown(String text) {
    if (_lastFeedback == null || _lastFeedbackTime == null) {
      return false;
    }

    // If it's the same message and within cooldown period, skip
    if (_lastFeedback == text &&
        DateTime.now().difference(_lastFeedbackTime!) < _cooldownDuration) {
      return true;
    }

    return false;
  }

  void enable() {
    _isEnabled = true;
    debugPrint('Simple voice feedback enabled');
  }

  void disable() {
    _isEnabled = false;
    debugPrint('Simple voice feedback disabled');
  }

  bool get isEnabled => _isEnabled;

  void clearCooldown() {
    _lastFeedback = null;
    _lastFeedbackTime = null;
  }

  Future<void> dispose() async {
    // Nothing to clean up for simple implementation
  }

  String? get lastFeedback => _lastFeedback;

  Future<void> testVoice() async {
    await speak('Simple voice feedback is working (text mode)!', force: true);
  }
}