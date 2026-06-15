import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../view/screens/exercise_detail_screen.dart';

class Exercise {
  final String name;
  final String category;
  final String? image;

  Exercise({required this.name, required this.category, this.image});
}

class ExerciseCategory {
  final String name;
  final String displayName;
  final List<Exercise> exercises;

  ExerciseCategory({
    required this.name,
    required this.displayName,
    required this.exercises,
  });
}

class ExerciseViewModel extends ChangeNotifier {
  List<ExerciseCategory> _categories = [];
  bool _isLoading = true;

  List<ExerciseCategory> get categories => _categories;

  bool get isLoading => _isLoading;

  String _formatCategoryName(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  ExerciseViewModel() {
    loadAllExercises();
  }

  Future<void> loadAllExercises() async {
    try {
      _isLoading = true;
      notifyListeners();

      final String jsonString = await rootBundle.loadString('assets/ex.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _categories = [];

      jsonData.forEach((categoryKey, exerciseList) {
        if (exerciseList is List) {
          List<Exercise> exercises = [];
          for (var item in exerciseList) {
            exercises.add(
              Exercise(
                name: item['name'],
                category: categoryKey,
                image: item['image'],
              ),
            );
          }
          _categories.add(
            ExerciseCategory(
              name: categoryKey,
              displayName: _formatCategoryName(categoryKey),
              exercises: exercises,
            ),
          );
        }
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading exercises: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void onStartExercise(BuildContext context, Exercise exercise) {
    debugPrint('Starting exercise: ${exercise.name}');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exerciseName: exercise.name),
      ),
    );
  }

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
