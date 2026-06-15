import 'dart:convert';
import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  factory ChatSession.create({
    required String id,
    required List<ChatMessage> messages,
  }) {
    final firstUserMsg = messages.firstWhere(
      (m) => m.sender == MessageSender.user,
      orElse: () => ChatMessage.user('New Chat'),
    );
    final raw = firstUserMsg.text.trim();
    final title = raw.length > 40 ? '${raw.substring(0, 40)}…' : raw;

    return ChatSession(
      id: id,
      title: title,
      createdAt: DateTime.now(),
      messages: List.of(messages),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        messages: (json['messages'] as List<dynamic>)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory ChatSession.fromJsonString(String s) =>
      ChatSession.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
