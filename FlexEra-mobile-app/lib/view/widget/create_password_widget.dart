import 'package:flexera/view_model/forgot_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';

class CreatePasswordWidget extends StatelessWidget {
  const CreatePasswordWidget({super.key});

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
              'Create',
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
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
            SizedBox(width: 8.w),
            Transform.translate(
              offset: Offset(-37.w, 12.h),
              child: Text(
                'new password',
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
          "Please enter your new password",
          style: GoogleFonts.quicksand(
            fontSize: 15.sp,
            color: AppColors.darkgraycolor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 28.h),
        SizedBox(
          width: 330.w,
          child: TextField(
            onChanged: vm.onPasswordChanged,
            obscureText: !vm.isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'New Password',
              hintStyle: GoogleFonts.instrumentSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.idcolor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.iconcolor,
                ),
                onPressed: vm.togglePasswordVisibility,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: 330.w,
          child: TextField(
            onChanged: vm.onConfirmChanged,
            obscureText: !vm.isConfirmVisible,
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              hintStyle: GoogleFonts.instrumentSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.idcolor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  vm.isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.iconcolor,
                ),
                onPressed: vm.toggleConfirmVisibility,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 28.h),
        Padding(
          padding: EdgeInsets.only(left: 37.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Text(
                  "Make sure that",
                  style: GoogleFonts.instrumentSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: AppColors.blackcolor,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _condition("At least 8 characters", vm.password.length >= 8,
                        vm.password),
                    _condition("One uppercase letter",
                        vm.password.contains(RegExp(r'[A-Z]')), vm.password),
                    _condition("One lowercase letter",
                        vm.password.contains(RegExp(r'[a-z]')), vm.password),
                    _condition("Number or symbol",
                        vm.password.contains(RegExp(r'[0-9]')), vm.password),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 28.h),
        GestureDetector(
          onTap: (vm.isPasswordValid && vm.isConfirmValid && !vm.isLoading)
              ? () => vm.resetPassword(context)
              : null,
          child: Container(
            width: 201.w,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              gradient:
                  (vm.isPasswordValid && vm.isConfirmValid && !vm.isLoading)
                      ? const LinearGradient(
                          colors: [
                            AppColors.botton2color,
                            AppColors.lightpurplecolor,
                          ],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade300]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: vm.isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.w,
                      ),
                    )
                  : Text(
                      'Reset Password',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _condition(String text, bool valid, String password) {
    final bool startedTyping = password.isNotEmpty;

    Color currentColor;
    if (!startedTyping) {
      currentColor = AppColors.checkcolor1;
    } else {
      currentColor = valid ? Colors.green : Colors.red;
    }

    return Row(
      children: [
        Icon(Icons.circle, size: 6.r, color: currentColor),
        SizedBox(width: 6.w),
        Text(
          text,
          style: GoogleFonts.instrumentSans(
            fontSize: 13.sp,
            color: currentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
