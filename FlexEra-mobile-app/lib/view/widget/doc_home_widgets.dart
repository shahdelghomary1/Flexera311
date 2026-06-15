import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/assets/assets_manager.dart';
import '../../view_model/doc_account_info_view_model.dart';
import '../../view_model/doc_main_view_model.dart';
import 'doctor_image_widget.dart';

class DocHomeHeader extends StatelessWidget {
  const DocHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<DocAccountInfoViewModel, DocMainViewModel>(
      builder: (context, accountProvider, mainViewModel, child) {
        final doctorName = accountProvider.fullNameController.text.isNotEmpty
            ? accountProvider.fullNameController.text
            : 'Dr. ...';

        final imageUrl = accountProvider.currentImageUrl ?? '';

        return Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          mainViewModel.setNavIndex(2);
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44.w,
                                height: 44.w,
                                child: ClipOval(
                                  child: DoctorImageWidget(
                                    imageUrl: imageUrl,
                                    defaultImage: AssetsManager.doctor,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back 👋',
                                      style: GoogleFonts.inter(
                                        fontSize: 15.sp,
                                        color: AppColors.darkgraycolor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      doctorName,
                                      style: GoogleFonts.inter(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DocOverviewHeader extends StatelessWidget {
  const DocOverviewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Overview",
          style: GoogleFonts.quicksand(
            fontSize: 35.sp,
            color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 7.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            "Here's a quick look at your daily activity",
            style: GoogleFonts.instrumentSans(
              fontSize: 17.sp, // Font -> .sp
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class DocOverviewCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double? iconWidth;
  final double? iconHeight;
  final double? iconRight;

  const DocOverviewCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.width,
    this.height,
    this.iconWidth,
    this.iconHeight,
    this.iconRight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (width ?? 296).w,
        height: (height ?? 107).h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(23.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackcolor.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20.w,
              top: 0,
              bottom: 0,
              right: 60.w,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 26.sp,
                    color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              right: (iconRight ?? 20).w,
              top: 0,
              bottom: 0,
              child: Center(
                child: Image.asset(
                  icon,
                  width: (iconWidth ?? 79).w,
                  height: (iconHeight ?? 60).h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPatientsCard extends StatelessWidget {
  final VoidCallback onTap;

  const MyPatientsCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DocOverviewCard(
      title: 'My Patients',
      icon: AssetsManager.doc_patient,
      onTap: onTap,
      iconWidth: 79,
      iconHeight: 60,
    );
  }
}

class AppointmentsCard extends StatelessWidget {
  final VoidCallback onTap;

  const AppointmentsCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DocOverviewCard(
      title: 'Appointments',
      icon: AssetsManager.appointment,
      onTap: onTap,
      iconWidth: 103,
      iconHeight: 69,
      iconRight: 5,
    );
  }
}

class ClinicSchedule extends StatelessWidget {
  final VoidCallback onTap;

  const ClinicSchedule({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DocOverviewCard(
      title: 'Clinic Schedule',
      icon: AssetsManager.clinic_appointment,
      onTap: onTap,
      iconWidth: 65,
      iconHeight: 69,
      iconRight: 15,
    );
  }
}
