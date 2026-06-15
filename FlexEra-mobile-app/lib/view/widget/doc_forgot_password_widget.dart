import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/view_model/forgot_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';

class DocForgotPasswordWidget extends StatelessWidget {
  const DocForgotPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordViewModel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: 50.w),
                Text(
                  'Forgot ',
                  style: GoogleFonts.homemadeApple(
                    fontSize: 37,
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
                Transform.translate(
                  offset: Offset(-40.w, 15.h),
                  child: Text(
                    'your password',
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
              "Enter your email address and \n we’ll send you a verification code",
              style: GoogleFonts.quicksand(
                fontSize: 15.sp,
                color: AppColors.darkgraycolor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter Your ID',
                style: GoogleFonts.instrumentSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.idcolor,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 57.w,
                          height: 53.h,
                          child: TextField(
                            controller: vm.idControllers[i],
                            focusNode: vm.idFocusNodes[i],
                            onChanged: (v) => vm.onIdChangedAt(i, v),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: GoogleFonts.quicksand(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppColors.graycolor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: AppColors.darkpurplecolor,
                                  width: 2.w,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (i < 4) const SizedBox(width: 0),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: 345.w,
                  child: TextField(
                    focusNode: vm.emailFocusNode,
                    onChanged: vm.onEmailChanged,
                    decoration: InputDecoration(
                      hintText: 'Enter Your Email',
                      hintStyle: GoogleFonts.instrumentSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.idcolor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(17.0.r),
                        child: Image.asset(
                          AssetsManager.email,
                          width: 22.w,
                          height: 22.h,
                          color: AppColors.iconcolor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: (vm.isEmailValid && !vm.isLoading)
                  ? () => vm.sendOtp(context)
                  : null,
              child: Container(
                width: 201.w,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: vm.isEmailValid
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
                  child: Text(
                    'Send Code',
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
      },
    );
  }
}
