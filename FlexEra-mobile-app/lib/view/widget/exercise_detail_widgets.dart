import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../view_model/exercise_detail_view_model.dart';

class ExerciseDetailBody extends StatelessWidget {
  const ExerciseDetailBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ExerciseDetailViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: isDark ? const Color(0xFF131313) : Colors.white,
              ),
            ),
            Positioned(
              top: 200.h,
              left: -5.w,
              child: Opacity(
                opacity: 0.8,
                child: Transform.rotate(
                  angle: -0.69 * 3.1415926535 / 180,
                  child: Image.asset(
                    AssetsManager.exerciseback,
                    width: 420.9870904181307.w,
                    height: 700.5646774866885.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ExerciseDetailAppBar(),
                    SizedBox(height: 10.h),
                    ExerciseDetailTitle(title: viewModel.exerciseName),
                    SizedBox(height: 60.h),
                    const ExerciseDetailBox(),
                    SizedBox(height: 60.h),
                    const HowToPerformTitle(),
                    SizedBox(height: 20.h),
                    viewModel.isLoading
                        ? Padding(
                            padding: EdgeInsets.all(30.r),
                            child: const CircularProgressIndicator(),
                          )
                        : const ExerciseStepsList(),
                    SizedBox(height: 40.h),
                    const ExerciseDetailStartButton(),
                    SizedBox(height: 1000.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ExerciseDetailAppBar extends StatelessWidget {
  const ExerciseDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = Provider.of<ExerciseDetailViewModel>(
      context,
      listen: false,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        isDark ? Colors.white : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/arrow.png',
                        width: 25.w,
                        height: 25.h,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Exercise',
                style: GoogleFonts.instrumentSans(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                  height: 20 / 18,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseDetailTitle extends StatelessWidget {
  final String title;

  const ExerciseDetailTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.instrumentSans(
          fontSize: 25.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
          height: 20 / 25,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class ExerciseDetailBox extends StatelessWidget {
  const ExerciseDetailBox({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = Provider.of<ExerciseDetailViewModel>(context);
    return Container(
      width: 338.w,
      height: 246.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black54,
          width: 0.75.w,
        ),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: viewModel.exerciseImage != null
            ? Padding(
                padding: EdgeInsets.all(
                  viewModel.exerciseName == "Shoulder flexion" ? 0 : 0,
                ),
                child: Image.asset(
                  viewModel.exerciseImage!,
                  fit: viewModel.exerciseName == "Shoulder flexion"
                      ? BoxFit.contain
                      : BoxFit.cover,

                  alignment:
                      viewModel.exerciseName ==
                          "Bending the knee with bed support"
                      ? Alignment.bottomCenter
                      : Alignment.center,
                ),
              )
            : Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 50.r,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }
}

class HowToPerformTitle extends StatelessWidget {
  const HowToPerformTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF590B8D), Color(0xFF6B48FF)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            'How to Perform?',
            textAlign: TextAlign.start,
            style: GoogleFonts.homemadeApple(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 20 / 18,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class ExerciseStepsList extends StatelessWidget {
  const ExerciseStepsList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ExerciseDetailViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (viewModel.steps.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        child: Text(
          'No steps available for this exercise.',
          textAlign: TextAlign.start,
          style: GoogleFonts.quicksand(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black54,
            height: 20 / 12,
            letterSpacing: 0.1,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < viewModel.steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                '${i + 1}- ${viewModel.steps[i]}',
                textAlign: TextAlign.start,
                style: GoogleFonts.quicksand(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                  height: 20 / 12,
                  letterSpacing: 0.1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ExerciseDetailStartButton extends StatelessWidget {
  const ExerciseDetailStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ExerciseDetailViewModel>(
      context,
      listen: false,
    );

    return GestureDetector(
      onTap: () => viewModel.onStartPressed(context),
      child: Container(
        width: 171.w,
        height: 38.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF590B8D), Color(0xFF786AC8)],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            'Start',
            style: GoogleFonts.quicksand(
              fontSize: 23.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
