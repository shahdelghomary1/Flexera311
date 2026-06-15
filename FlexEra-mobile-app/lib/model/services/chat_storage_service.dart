import '../../core/network/cache_helper.dart';
import '../chat_session.dart';

class ChatStorageService {
  static const String _key = 'chat_sessions';
  static const int _maxSessions = 50;

  Future<List<ChatSession>> loadAll() async {
    final raw = CacheHelper.getStringList(key: _key);
    if (raw == null || raw.isEmpty) return [];

    final sessions = <ChatSession>[];
    for (final s in raw) {
      try {
        sessions.add(ChatSession.fromJsonString(s));
      } catch (_) {
        // skip corrupted entries
      }
    }
    // newest first
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  Future<void> saveSession(ChatSession session) async {
    final existing = await loadAll();

    // Remove old version of this session (upsert)
    final updated = existing.where((s) => s.id != session.id).toList();
    updated.insert(0, session);

    // Enforce max cap — keep the most-recent _maxSessions entries
    final capped =
        updated.length > _maxSessions ? updated.sublist(0, _maxSessions) : updated;

    await CacheHelper.saveStringList(
      key: _key,
      value: capped.map((s) => s.toJsonString()).toList(),
    );
  }

  Future<void> deleteSession(String id) async {
    final existing = await loadAll();
    final updated = existing.where((s) => s.id != id).toList();
    await CacheHelper.saveStringList(
      key: _key,
      value: updated.map((s) => s.toJsonString()).toList(),
    );
  }

  Future<void> deleteAll() async {
    await CacheHelper.saveStringList(key: _key, value: []);
  }
}
