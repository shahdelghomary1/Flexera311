import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/exercise_detail_widgets.dart';
import '../../view_model/exercise_detail_view_model.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseName;

  const ExerciseDetailScreen({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExerciseDetailViewModel(exerciseName: exerciseName),
      child: const Scaffold(
        body: ExerciseDetailBody(),
      ),
    );
  }
}
