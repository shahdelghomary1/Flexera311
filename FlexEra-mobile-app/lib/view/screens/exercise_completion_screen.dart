import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/exercise_completion_widgets.dart';
import '../../view_model/exercise_completion_view_model.dart';

class ExerciseCompletionScreen extends StatelessWidget {
  final String exerciseName;

  const ExerciseCompletionScreen({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExerciseCompletionViewModel(exerciseName: exerciseName),
      child: const Scaffold(
        body: ExerciseCompletionBody(),
      ),
    );
  }
}
