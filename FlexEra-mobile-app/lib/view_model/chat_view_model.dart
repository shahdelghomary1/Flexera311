import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../model/chat_message.dart';
import '../model/chat_session.dart';
import '../model/services/chat_storage_service.dart';
import '../model/services/gemini_service.dart';

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final TextEditingController messageController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final ChatStorageService _storage = ChatStorageService();

  bool _isTyping = false;
  bool _isOnline = true;

  String _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
  List<ChatSession> _sessions = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isOnline => _isOnline;
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  ChatViewModel() {
    loadSessions();
  }

  // ---------------------------------------------------------------------------
  // Session management
  // ---------------------------------------------------------------------------

  Future<void> loadSessions() async {
    _sessions = await _storage.loadAll();

    if (_sessions.isNotEmpty) {
      // Restore the most recent session
      final latest = _sessions.first;
      _currentSessionId = latest.id;
      _messages.clear();
      _messages.addAll(latest.messages);
    } else {
      _initializeChat();
    }
    notifyListeners();
  }

  Future<void> startNewChat() async {
    await _saveCurrentSession();

    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages.clear();
    _geminiService.resetHistory();
    _initializeChat();
    notifyListeners();
  }

  Future<void> loadSession(ChatSession session) async {
    await _saveCurrentSession();

    _currentSessionId = session.id;
    _messages.clear();
    _messages.addAll(session.messages);
    _geminiService.resetHistory();
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    await _storage.deleteSession(id);
    _sessions = await _storage.loadAll();
    notifyListeners();
  }

  Future<void> _saveCurrentSession() async {
    // Only save if there's at least one user message (don't persist welcome-only)
    final hasUserMsg = _messages.any((m) => m.sender == MessageSender.user);
    if (!hasUserMsg) return;

    final session = ChatSession.create(
      id: _currentSessionId,
      messages: _messages,
    );
    await _storage.saveSession(session);
    // Refresh local list
    _sessions = await _storage.loadAll();
  }

  // ---------------------------------------------------------------------------
  // Chat logic
  // ---------------------------------------------------------------------------

  void _initializeChat() {
    final welcomeMessage = ChatMessage.support(
      "Welcome to FlexEra.\nFlexEra is a physiotherapy and fitness management platform.\nI am your AI assistant. I am here to assist you with:\nPlease feel free to ask any question.",
    );
    _messages.add(welcomeMessage);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(text.trim());
    _messages.add(userMessage);
    messageController.clear();
    _isTyping = true;
    notifyListeners();

    _fetchGeminiResponse(text.trim());
  }

  Future<void> _fetchGeminiResponse(String userMessage) async {
    try {
      final response = await _geminiService.sendMessage(userMessage);
      _messages.add(ChatMessage.support(response));
    } catch (e, stack) {
      debugPrint('Gemini error: $e');
      debugPrint('Stack: $stack');
      if (e is DioException && e.response != null) {
        debugPrint('API response body: ${e.response!.data}');
      }
      String friendlyError = 'Something went wrong. Please try again.';
      if (e is DioException && e.response != null) {
        final code = e.response!.statusCode;
        if (code == 429) {
          friendlyError =
              'The AI service is temporarily unavailable due to quota limits. Please try again later.';
        } else if (code == 401 || code == 403) {
          friendlyError =
              'API authentication failed. Please check your API key.';
        } else if (code == 404) {
          friendlyError = 'AI model not found. Please contact support.';
        }
      }
      _messages.add(ChatMessage.support(friendlyError));
    } finally {
      _isTyping = false;
      notifyListeners();
      // Persist after every AI response
      await _saveCurrentSession();
    }
  }

  void clearChat() {
    _messages.clear();
    _initializeChat();
    notifyListeners();
  }

  void setOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
