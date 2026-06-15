import 'package:flexera/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep;

  const BookingStepper({super.key, this.currentStep = 1});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStep(
                1, "Select Appointment", currentStep, AppColors.whiteColor),
            _buildLine(1, currentStep, AppColors.whiteColor),
            _buildStep(2, "Choose Date", currentStep, AppColors.whiteColor),
            _buildLine(2, currentStep, AppColors.whiteColor),
            _buildStep(3, "Payment Info", currentStep, AppColors.whiteColor),
            _buildLine(3, currentStep, AppColors.whiteColor),
            _buildStep(4, "Confirmation", currentStep, AppColors.whiteColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String label, int currentStep, Color white) {
    double circleSize = 30.0.r;

    bool isCompletedOrActive = index <= currentStep;

    const Color purpleColor = Color(0xFF515BD4);
    const Color greenColor = Color(0xFF4CAF50);
    Color currentColor =
        (index == 4 && isCompletedOrActive) ? greenColor : purpleColor;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompletedOrActive ? currentColor : white,
            border: Border.all(color: currentColor, width: 1.5.w),
          ),
          child: isCompletedOrActive
              ? Icon(Icons.check, size: 18.r, color: Colors.white)
              : Center(
                  child: Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: currentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
        ),
        Positioned(
          top: 36.h,
          child: SizedBox(
            width: 70.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 8.sp,
                fontWeight:
                    index == currentStep ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLine(int index, int currentStep, Color white) {
    bool isLineActive = index < currentStep;

    const Color purpleColor = Color(0xFF515BD4);

    return Container(
      width: 40.w,
      height: 1.5.h,
      color: isLineActive ? purpleColor : white,
    );
  }
}
