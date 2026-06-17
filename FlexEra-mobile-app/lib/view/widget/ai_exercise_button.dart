import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/ai_exercise_screen.dart';
import '../screens/exercise_completion_screen.dart';

class AiExerciseButton extends StatelessWidget {
  final String exerciseName;
  final String? exerciseKey;
  final int targetSets;
  final int targetReps;
  final String exerciseId;

  const AiExerciseButton({
    super.key,
    required this.exerciseName,
    this.exerciseKey,
    required this.targetSets,
    required this.targetReps,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final String finalExerciseKey =
        exerciseKey ?? _generateExerciseKey(exerciseName);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: GestureDetector(
        onTap: () => _launchAiExercise(context, finalExerciseKey),
        child: Container(
          width: 200.w,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF590B8D), Color(0xFF786AC8)],
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.white, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'Start AI Exercise',
                style: GoogleFonts.quicksand(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateExerciseKey(String name) {
    String cleanName = name.trim();

    if (cleanName.contains("Bending the knee") &&
        cleanName.contains("without support")) {
      return "01";
    }

    if (cleanName.contains("Bending the knee") &&
        cleanName.contains("with support")) {
      return "02";
    }

    if (cleanName.contains("Lift the extended leg")) return "03";
    if (cleanName.contains("Bending the knee with bed support")) return "04";
    if (cleanName.contains("Shoulder flexion")) return "09";
    if (cleanName.contains("Horizontal weighted openings")) return "10";
    if (cleanName.contains("External rotation")) return "11";
    if (cleanName.contains("Circular pendulum")) return "12";

    return "01";
  }

  Future<void> _launchAiExercise(
    BuildContext context,
    String exerciseKey,
  ) async {
    final bool? isCompleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AiExerciseScreen(
          exerciseKey: exerciseKey,
          exerciseName: exerciseName,
          targetSets: targetSets,
          targetReps: targetReps,
          exerciseId: exerciseId,
        ),
      ),
    );

    if (isCompleted == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseCompletionScreen(exerciseName: exerciseName),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Exercise Incomplete"),
          content: const Text(
            "You didn't complete the exercise correctly.\nPlease try again.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
  }
}
