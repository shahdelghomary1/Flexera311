import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/exercise_widgets.dart';
import '../../view_model/exercise_view_model.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExerciseViewModel(),
      child: const Scaffold(
        body: ExerciseBody(),
      ),
    );
  }
}
