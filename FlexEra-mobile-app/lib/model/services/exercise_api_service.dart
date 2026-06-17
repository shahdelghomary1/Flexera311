import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseStats {
  final int currentSet;
  final int completedSets;
  final int currentReps;
  final int totalSets;
  final String feedback;
  final double leftAngle;
  final double rightAngle;

  ExerciseStats({
    required this.currentSet,
    required this.completedSets,
    required this.currentReps,
    required this.totalSets,
    this.feedback = '',
    this.leftAngle = 0.0,
    this.rightAngle = 0.0,
  });

  factory ExerciseStats.fromJson(Map<String, dynamic> json) {
    return ExerciseStats(
      currentSet: json['current_set'] ?? 1,
      completedSets: json['completed_sets'] ?? 0,
      currentReps: json['current_reps'] ?? 0,
      totalSets: json['target_sets'] ?? 3,
      feedback: json['feedback'] ?? '',
      leftAngle: (json['left_angle'] ?? 0).toDouble(),
      rightAngle: (json['right_angle'] ?? 0).toDouble(),
    );
  }
}

class ExerciseApiService {
  static const String _baseUrl = 'http://135.225.104.150:8000';
  final http.Client _client = http.Client();

  Future<String> startExerciseSession({
    required String exerciseId,
    required String userId,
    required int targetSets,
    required int targetReps,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/session/start'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'exercise_id': exerciseId,
          'user_id': userId,
          'target_sets': targetSets,
          'target_reps': targetReps,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['session_key'];
      } else {
        throw Exception('Failure to start the session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Server connection error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
