import 'package:flexera/view/widget/exercise_card.dart';
import 'package:flexera/view/widget/motivational_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/view_model/my_exercises_view_model.dart';
import 'package:flexera/view_model/account_info_view_model.dart';
import 'package:flexera/view/widget/health_overview_widgets.dart';

import 'exercise_detail_screen.dart';

class HealthOverviewScreen extends StatefulWidget {
  const HealthOverviewScreen({super.key});

  @override
  State<HealthOverviewScreen> createState() => _HealthOverviewScreenState();
}

class _HealthOverviewScreenState extends State<HealthOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyExercisesViewModel>(
        context,
        listen: false,
      ).fetchMyExercises();
      Provider.of<AccountInfoViewModel>(context, listen: false).getMyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF363438);

    return AppTheme.progressBackground(
      context,
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer2<MyExercisesViewModel, AccountInfoViewModel>(
          builder: (context, exercisesVM, accountVM, child) {
            final String characterImage = exercisesVM.isProgressGood
                ? "assets/images/star.gif"
                : "assets/images/Tired.gif";

            final bool hasExercises =
                exercisesVM.currentPlan != null &&
                exercisesVM.currentPlan!.exerciseItems != null &&
                exercisesVM.currentPlan!.exerciseItems!.isNotEmpty;

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        HealthHeader(
                          userName: accountVM.fullNameController.text,
                          imageUrl: accountVM.networkImageUrl,
                          isDark: isDark,
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            HealthBackButton(isDark: isDark),
                            SizedBox(width: 15.w),
                            Text(
                              "Health Overview",
                              style: GoogleFonts.instrumentSans(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          ProgressSection(
                            progressPercent: exercisesVM.progressPercent,
                            isDark: isDark,
                            characterImage: characterImage,
                            textColor: textColor,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "Recent Activity",
                            style: GoogleFonts.instrumentSans(
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          exercisesVM.isLoading
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.r),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : !hasExercises
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(30.r),
                                    child: Text(
                                      "No exercises assigned yet.",
                                      style: GoogleFonts.quicksand(
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: exercisesVM
                                      .currentPlan!
                                      .exerciseItems!
                                      .length,
                                  itemBuilder: (context, index) {
                                    final item = exercisesVM
                                        .currentPlan!
                                        .exerciseItems![index];
                                    return ExerciseCard(
                                      item: item,
                                      isDark: isDark,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ExerciseDetailScreen(
                                                  exerciseName: item.name ?? "",
                                                ),
                                          ),
                                        );
                                      },
                                      onCheckboxChanged: (val) {
                                        exercisesVM.toggleExerciseCompletion(
                                          index,
                                        );
                                      },
                                    );
                                  },
                                ),
                          SizedBox(height: 35.h),
                          MotivationalFooter(textColor: textColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
