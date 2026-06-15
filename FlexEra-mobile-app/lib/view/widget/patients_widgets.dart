import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_colors.dart';
import '../../core/assets/assets_manager.dart';
import '../../view_model/patients_view_model.dart';

class PatientsSearchBar extends StatelessWidget {
  const PatientsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 304.w,
      height: 45.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackcolor.withOpacity(isDark ? 0.3 : 0.07),
            blurRadius: 10.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'What are you searching for...',
                style: GoogleFonts.instrumentSans(
                  fontSize: 16.sp,
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ),
          ),
          Image.asset(
            AssetsManager.doc_search_icon,
            width: 29.w,
            height: 29.w,
            color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
          ),
        ],
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 296.w,
        height: 120.h,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(23.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackcolor.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 58.w,
              height: 58.w,
              child: CircleAvatar(
                radius: 29.r,
                backgroundImage: patient.avatarPath != null
                    ? (patient.avatarPath!.startsWith('http')
                        ? NetworkImage(patient.avatarPath!)
                        : AssetImage(patient.avatarPath!))
                    : null,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                child: patient.avatarPath == null
                    ? Icon(Icons.person,
                        color: isDark ? Colors.white : Colors.grey)
                    : null,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    patient.name,
                    style: GoogleFonts.quicksand(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.whiteColor : AppColors.blackcolor,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Last Session: ${patient.lastSession ?? patient.date ?? "N/A"}',
                    style: GoogleFonts.quicksand(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppColors.whiteColor : AppColors.blackcolor,
                      height: 1.2,
                    ),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                  if (patient.time != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Time: ${patient.time}',
                      style: GoogleFonts.quicksand(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 65.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 69.w,
                      height: 23.h,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: isDark
                              ? AppColors.whiteColor
                              : AppColors.blackcolor,
                          width: 1.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'view',
                          style: GoogleFonts.quicksand(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.whiteColor
                                : AppColors.blackcolor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
