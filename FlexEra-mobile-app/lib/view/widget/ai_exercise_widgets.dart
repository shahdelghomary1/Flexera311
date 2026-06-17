import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../view_model/ai_exercise_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../model/services/exercise_api_service.dart';

class AiExerciseBody extends StatelessWidget {
  const AiExerciseBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiExerciseViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.state == ExerciseState.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop(true);
          });
        }
        if (viewModel.isInitializing) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Initializing camera...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: viewModel.clearError,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(flex: 3, child: CameraPreviewWidget(viewModel: viewModel)),
            Expanded(
              flex: 1,
              child: ExerciseControlsWidget(viewModel: viewModel),
            ),
          ],
        );
      },
    );
  }
}

class CameraPreviewWidget extends StatelessWidget {
  final AiExerciseViewModel viewModel;

  const CameraPreviewWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (!viewModel.isCameraInitialized ||
        viewModel.cameraService.controller == null) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: CameraPreview(viewModel.cameraService.controller!),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ExerciseStatsWidget(stats: viewModel.currentStats),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

class ExerciseStatsWidget extends StatelessWidget {
  final ExerciseStats? stats;

  const ExerciseStatsWidget({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Text(
        'No stats available',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          label: 'Sets',
          value: '${stats!.completedSets}/${stats!.totalSets}',
        ),
        _StatItem(label: 'Current Reps', value: '${stats!.currentReps}'),
        _StatItem(label: 'Set No.', value: '${stats!.currentSet}'),
        _StatItem(
          label: 'L-Angle',
          value: '${stats!.leftAngle.toStringAsFixed(0)}°',
        ),
        _StatItem(
          label: 'R-Angle',
          value: '${stats!.rightAngle.toStringAsFixed(0)}°',
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class ExerciseControlsWidget extends StatelessWidget {
  final AiExerciseViewModel viewModel;

  const ExerciseControlsWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [_buildStatusIndicator(), _buildControlButtons(context)],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    String statusText;
    Color statusColor;

    switch (viewModel.state) {
      case ExerciseState.notStarted:
        statusText = 'Ready to start';
        statusColor = Colors.white;
        break;
      case ExerciseState.starting:
        statusText = 'Starting exercise...';
        statusColor = AppColors.primary;
        break;
      case ExerciseState.active:
        statusText = 'Exercise in progress';
        statusColor = Colors.green;
        break;
      case ExerciseState.paused:
        statusText = 'Exercise paused';
        statusColor = Colors.orange;
        break;
      case ExerciseState.finished:
        statusText = 'Exercise completed!';
        statusColor = Colors.green;
        break;
      case ExerciseState.error:
        statusText = 'Error occurred';
        statusColor = Colors.red;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (viewModel.state == ExerciseState.notStarted)
          _ControlButton(
            icon: Icons.play_arrow,
            label: 'Start',
            color: AppColors.primary,
            onPressed: viewModel.startExercise,
          ),

        // if (viewModel.state == ExerciseState.active)
        //   _ControlButton(
        //     icon: Icons.pause,
        //     label: 'Pause',
        //     color: Colors.orange,
        //     onPressed: viewModel.pauseExercise,
        //   ),
        //
        // if (viewModel.state == ExerciseState.paused)
        //   _ControlButton(
        //     icon: Icons.play_arrow,
        //     label: 'Resume',
        //     color: AppColors.primary,
        //     onPressed: viewModel.resumeExercise,
        //   ),
        if (viewModel.state == ExerciseState.active ||
            viewModel.state == ExerciseState.paused)
          _ControlButton(
            icon: Icons.stop,
            label: 'Stop',
            color: Colors.red,
            onPressed: viewModel.stopExercise,
          ),

        if (viewModel.state == ExerciseState.finished)
          _ControlButton(
            icon: Icons.check_circle,
            label: 'Complete',
            color: Colors.green,
            onPressed: () => Navigator.of(context).pop(true),
          ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
