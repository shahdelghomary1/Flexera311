import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../view/screens/exercise_completion_screen.dart';

class ExerciseSteps {
  final String name;
  final List<String> steps;

  ExerciseSteps({required this.name, required this.steps});

  factory ExerciseSteps.fromJson(Map<String, dynamic> json) {
    return ExerciseSteps(
      name: json['name'] as String,
      steps: List<String>.from(json['steps'] as List),
    );
  }
}

class ExerciseDetailViewModel extends ChangeNotifier {
  final String exerciseName;
  String? _exerciseImage;
  List<String> _steps = [];
  bool _isLoading = true;

  List<String> get steps => _steps;

  bool get isLoading => _isLoading;

  String? get exerciseImage => _exerciseImage;

  ExerciseDetailViewModel({required this.exerciseName}) {
    loadExerciseSteps();
  }

  Future<void> loadExerciseSteps() async {
    try {
      _isLoading = true;
      notifyListeners();

      final String jsonString = await rootBundle.loadString(
        'assets/steps_exercises.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> exercises = jsonData['exercises'] as List<dynamic>;

      for (var exercise in exercises) {
        final String name = exercise['name'] as String;
        if (name.toLowerCase() == exerciseName.toLowerCase()) {
          _steps = List<String>.from(exercise['steps'] as List);
          _exerciseImage = exercise['image'];
          break;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading exercise steps: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onStartPressed(BuildContext context) {
    debugPrint('Starting exercise: $exerciseName');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ExerciseCompletionScreen(exerciseName: exerciseName),
      ),
    );
  }
}
