import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/ai_exercise_view_model.dart';
import '../widget/ai_exercise_widgets.dart';

class AiExerciseScreen extends StatelessWidget {
  final String exerciseKey;
  final String exerciseName;
  final int targetSets;
  final int targetReps;
  final String exerciseId;

  const AiExerciseScreen({
    super.key,
    required this.exerciseKey,
    required this.exerciseName,
    required this.targetSets,
    required this.targetReps,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiExerciseViewModel(
        exerciseName: exerciseName,
        targetSets: targetSets,
        targetReps: targetReps,
        exerciseId: exerciseId,
      ),
      child: const Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: AiExerciseBody()),
      ),
    );
  }
}
