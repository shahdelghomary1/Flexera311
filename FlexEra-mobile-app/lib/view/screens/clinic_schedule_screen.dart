import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/clinic_schedule_view_model.dart';
import '../../view_model/doc_main_view_model.dart';
import '../widget/clinic_schedule_widgets.dart';
import '../widget/doc_navbar.dart';

class ClinicScheduleScreen extends StatelessWidget {
  const ClinicScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the existing ClinicScheduleViewModel from the parent provider
    // instead of creating a new one
    return const ClinicScheduleBody();
  }
}

class ClinicScheduleBody extends StatefulWidget {
  const ClinicScheduleBody({super.key});

  @override
  State<ClinicScheduleBody> createState() => _ClinicScheduleBodyState();
}

class _ClinicScheduleBodyState extends State<ClinicScheduleBody> {
  @override
  void initState() {
    super.initState();
    // Fetch schedules when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ClinicScheduleViewModel>();
      viewModel.fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackcolor : Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark ? AppColors.blackcolor : Colors.white,
            ),
          ),
          Positioned(
            bottom: -100.h,
            left: 0.w,
            child: Image.asset(
              AssetsManager.backSetting,
              width: 420.w,
              height: 650.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -388.3.h,
            left: 0.w,
            child: Transform.rotate(
              angle: 240 * math.pi / 180,
              child: Image.asset(
                AssetsManager.backgroundBlob,
                width: 554.w,
                height: 750.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                const ClinicScheduleHeader(),
                Expanded(
                  child: Consumer<ClinicScheduleViewModel>(
                    builder: (context, viewModel, _) {
                      // Show loading indicator
                      if (viewModel.isLoading && viewModel.schedules.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF8B5CF6),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Loading schedules...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isDark
                                      ? AppColors.whiteColor.withOpacity(0.7)
                                      : AppColors.darkgraycolor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Show error message if any
                      if (viewModel.errorMessage != null) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.r),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64.r,
                                  color: Colors.red.withOpacity(0.7),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Error loading schedules',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.whiteColor
                                        : AppColors.blackcolor,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  viewModel.errorMessage!
                                      .replaceFirst('Exception: ', ''),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isDark
                                        ? AppColors.whiteColor.withOpacity(0.7)
                                        : AppColors.darkgraycolor,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                ElevatedButton(
                                  onPressed: () {
                                    viewModel.clearError();
                                    viewModel.fetchSchedules();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5CF6),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32.w,
                                      vertical: 12.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.only(top: 20.h, bottom: 40.h),
                        child: Column(
                          children: [
                            CalendarWidget(viewModel: viewModel),
                            SizedBox(height: 24.h),
                            UpcomingAppointmentsWidget(viewModel: viewModel),
                            SizedBox(height: 24.h),
                            ScheduleListWidget(
                              viewModel: viewModel,
                              onAddMore: () {},
                            ),
                            SizedBox(height: 100.h),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
