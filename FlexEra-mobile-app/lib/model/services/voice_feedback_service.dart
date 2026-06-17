import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class VoiceFeedbackService {
  static final VoiceFeedbackService _instance = VoiceFeedbackService._internal();
  factory VoiceFeedbackService() => _instance;
  VoiceFeedbackService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isEnabled = true;
  String? _lastFeedback;
  DateTime? _lastFeedbackTime;
  
  // Cooldown period to prevent spam
  static const Duration _cooldownDuration = Duration(seconds: 3);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();
      
      // Test if the plugin is available by trying to get available languages
      await _flutterTts!.getLanguages;
      
      // Configure TTS settings
      await _flutterTts!.setLanguage('en-US');
      await _flutterTts!.setPitch(1.0);
      await _flutterTts!.setSpeechRate(0.5); // Slower speech for better understanding
      await _flutterTts!.setVolume(0.8);
      
      // Set voice to female if available
      await _setFemaleVoice();
      
      _isInitialized = true;
      debugPrint('Voice feedback service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize voice feedback service: $e');
      // Disable voice feedback if initialization fails
      _isEnabled = false;
      _flutterTts = null;
    }
  }

  Future<void> _setFemaleVoice() async {
    try {
      List<dynamic> voices = await _flutterTts!.getVoices;
      
      // Look for female voices
      for (var voice in voices) {
        String voiceName = voice['name']?.toString().toLowerCase() ?? '';
        String locale = voice['locale']?.toString() ?? '';
        
        // Check if it's an English female voice
        if (locale.startsWith('en-') && 
            (voiceName.contains('female') || 
             voiceName.contains('samantha') ||
             voiceName.contains('susan') ||
             voiceName.contains('karen') ||
             voiceName.contains('moira'))) {
          
          await _flutterTts!.setVoice(voice);
          debugPrint('Set female voice: $voiceName');
          return;
        }
      }
      
      debugPrint('No female voice found, using default voice');
    } catch (e) {
      debugPrint('Error setting female voice: $e');
    }
  }

  Future<bool> speak(String text, {bool force = false}) async {
    if (!_isEnabled || !_isInitialized || _flutterTts == null) {
      debugPrint('Voice not available: enabled=$_isEnabled, initialized=$_isInitialized, tts=${_flutterTts != null}');
      return false;
    }

    if (text.isEmpty) return false;

    // Apply cooldown to prevent spam (unless forced)
    if (!force && _shouldSkipDueToCooldown(text)) {
      return false;
    }

    try {
      // Stop any current speech
      await _flutterTts!.stop();
      
      // Speak the text
      await _flutterTts!.speak(text);
      
      _lastFeedback = text;
      _lastFeedbackTime = DateTime.now();
      
      debugPrint('Speaking: $text');
      return true;
    } catch (e) {
      debugPrint('Error speaking text: $e');
      // If there's a plugin issue, disable voice feedback
      if (e.toString().contains('MissingPluginException')) {
        debugPrint('TTS plugin not available, disabling voice feedback');
        _isEnabled = false;
      }
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

  Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
  }

  void enable() {
    _isEnabled = true;
    debugPrint('Voice feedback enabled');
  }

  void disable() {
    _isEnabled = false;
    debugPrint('Voice feedback disabled');
  }

  bool get isEnabled => _isEnabled;

  void clearCooldown() {
    _lastFeedback = null;
    _lastFeedbackTime = null;
  }

  Future<void> dispose() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
    _isInitialized = false;
  }

  // Test method to check if TTS is working
  Future<void> testVoice() async {
    await speak('Voice feedback is working correctly!', force: true);
  }
}