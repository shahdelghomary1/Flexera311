import 'package:flutter/material.dart';

class ExerciseCompletionViewModel extends ChangeNotifier {
  final String exerciseName;

  ExerciseCompletionViewModel({required this.exerciseName});

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goToHome(BuildContext context) {
    // Pop all exercise screens and go back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
