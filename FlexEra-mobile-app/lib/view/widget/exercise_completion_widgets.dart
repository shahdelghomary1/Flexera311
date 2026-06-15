import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../view_model/exercise_completion_view_model.dart';

class ExerciseCompletionBody extends StatelessWidget {
  const ExerciseCompletionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ExerciseCompletionViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: isDark ? const Color(0xFF131313) : Colors.white,
              ),
            ),
            const CompletionBackgroundDecoration(),
            SafeArea(
              child: Column(
                children: [
                  const CompletionAppBar(),
                  const Spacer(flex: 1),
                  const AchievementCircle(),
                  SizedBox(height: 2.h),
                  const CompletionMessage(),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CompletionBackgroundDecoration extends StatelessWidget {
  const CompletionBackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -58.h,
          left: -45.w,
          child: Opacity(
            opacity: 0.99,
            child: Transform.rotate(
              angle: 5.16 * 3.1415926535 / 180,
              child: Image.asset(
                AssetsManager.achievement_up,
                width: 483.99.w,
                height: 524.73.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -20.h,
          child: Opacity(
            opacity: 0.99,
            child: Transform.rotate(
              angle: -1.06 * 3.1415926535 / 180,
              child: Image.asset(
                AssetsManager.achievement_down,
                width: 450.99.w,
                height: 400.56.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CompletionAppBar extends StatelessWidget {
  const CompletionAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = Provider.of<ExerciseCompletionViewModel>(
      context,
      listen: false,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => viewModel.goBack(context),
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                  width: 1.w,
                ),
              ),
              child: Center(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/arrow.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class AchievementCircle extends StatelessWidget {
  const AchievementCircle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 480.w,
      height: 360.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -50.h,
            left: 0,
            child: Image.asset(
              AssetsManager.achievenement,
              width: 420.w,
              height: 360.h,
            ),
          ),
          Container(
            width: 250.w,
            height: 250.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 600.w,
            height: 600.w,
            child: Center(
              child: Image.asset(
                AssetsManager.prize,
                width: 480.w,
                height: 360.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompletionMessage extends StatelessWidget {
  const CompletionMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        "Amazing work today!\nYou completed all your exercises\nyou're making real progress 💪.",
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black,
          height: 1.2,
        ),
      ),
    );
  }
}
