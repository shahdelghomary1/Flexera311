import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/exercise_view_model.dart';

class ExerciseBody extends StatelessWidget {
  const ExerciseBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ExerciseViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExerciseCustomHeader(),

                SizedBox(height: 10.h),

                viewModel.isLoading
                    ? Padding(
                  padding: EdgeInsets.all(50.r),
                  child: const Center(child: CircularProgressIndicator()),
                )
                    : const ExerciseCategoriesList(),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExerciseCustomHeader extends StatelessWidget {
  const ExerciseCustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 389.h,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF786AC8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                  bottomRight: Radius.circular(50.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                  bottomRight: Radius.circular(50.r),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        AssetsManager.exercise,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 200.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF786AC8).withOpacity(0.0),
                              const Color(0xFF786AC8).withOpacity(0.6),
                              const Color(0xFF786AC8),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Let’s get moving!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.instrumentSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 20.sp,
                                height: 1.0,
                                letterSpacing: 0.1,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Ready for today's exercises?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            SizedBox(height: 5.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 50.h,
            left: 20.w,
            child:  GestureDetector(
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
          ),
        ],
      ),
    );
  }
}
class ExerciseCategoriesList extends StatelessWidget {
  const ExerciseCategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ExerciseViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < viewModel.categories.length; i++) ...[
          ExerciseCategorySection(category: viewModel.categories[i]),
          if (i < viewModel.categories.length - 1) SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class ExerciseCategorySection extends StatelessWidget {
  final ExerciseCategory category;

  const ExerciseCategorySection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
          child: Text(
            category.displayName,
            style: GoogleFonts.instrumentSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        ExerciseCategoryGrid(exercises: category.exercises),
      ],
    );
  }
}

class ExerciseCategoryGrid extends StatelessWidget {
  final List<Exercise> exercises;

  const ExerciseCategoryGrid({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 10.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 167 / 235,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return ExerciseCard(exercise: exercises[index]);
      },
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = Provider.of<ExerciseViewModel>(context, listen: false);

    return Container(
      width: 167.w,
      height: 235.h,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black54,
          width: 0.75.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.all(1.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: exercise.image != null
                    ? Image.asset(
                  exercise.image!,
                  fit: BoxFit.contain,
                )
                    : Center(
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.grey.withOpacity(0.5),
                    size: 40.r,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              exercise.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
                height: 20 / 15,
                letterSpacing: 0.1,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ExerciseStartButton(
              onTap: () => viewModel.onStartExercise(context, exercise),
            ),
          ),
        ],
      ),
    );
  }
}
class ExerciseStartButton extends StatelessWidget {
  final VoidCallback onTap;

  const ExerciseStartButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 102.w,
        height: 38.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF590B8D), Color(0xFF786AC8)],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start',
              style: GoogleFonts.instrumentSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Image.asset(
              AssetsManager.start_exercise,
              width: 18.w,
              height: 18.w,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
