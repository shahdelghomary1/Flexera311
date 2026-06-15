import 'package:flexera/view/widget/resend_text.dart';
import 'package:flexera/view_model/forgot_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';

class EnterCodeWidget extends StatelessWidget {
  const EnterCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ForgotPasswordViewModel>(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 50.w),
            Text(
              'Check',
              style: GoogleFonts.homemadeApple(
                fontSize: 37.sp,
                fontWeight: FontWeight.w600,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [
                      AppColors.darkpurplecolor,
                      AppColors.lightpurplecolor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(
                    Rect.fromLTWH(0, 0, 200.w, 70.h),
                  ),
              ),
            ),
            SizedBox(width: 8.w),
            Transform.translate(
              offset: Offset(-20.w, 12.h),
              child: Text(
                'your email',
                style: GoogleFonts.quicksand(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 45.h),
        Text(
          "We’ve sent you a 4-digit code. \n Please enter it below.",
          style: GoogleFonts.quicksand(
            fontSize: 15.sp, // Font -> .sp
            color: AppColors.darkgraycolor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 28.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) {
            return Row(
              children: [
                SizedBox(
                  width: 66.w,
                  height: 60.h,
                  child: TextField(
                    controller: vm.codeControllers[i],
                    focusNode: vm.focusNodes[i],
                    onChanged: (v) => vm.onCodeChangedAt(i, v),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: GoogleFonts.quicksand(
                        fontSize: 18.sp, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide:
                            const BorderSide(color: AppColors.graycolor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: AppColors.darkpurplecolor,
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
                ),
                if (i < 3) SizedBox(width: 2.w),
              ],
            );
          }),
        ),
        SizedBox(height: 30.h),
        GestureDetector(
          onTap: (vm.isCodeValid && !vm.isLoading)
              ? () => vm.verifyOtp(context)
              : null,
          child: Container(
            width: 201.w,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              gradient: (vm.isCodeValid && !vm.isLoading)
                  ? const LinearGradient(
                      colors: [
                        AppColors.botton2color,
                        AppColors.lightpurplecolor,
                      ],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade300]),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Center(
              child: vm.isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Verify',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 30.h),
        const ResendText(),
      ],
    );
  }
}
