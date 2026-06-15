import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/view/screens/doc_forgot_password_screen.dart';
import 'package:flexera/view/screens/forgot_password_screen.dart';
import 'package:flexera/view_model/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatelessWidget {
  final LoginViewModel viewModel;

  const GoogleSignInButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: viewModel.isLoading
              ? null
              : () => viewModel.loginWithGoogle(context),
          borderRadius: BorderRadius.circular(14.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                width: 24.w,
                height: 24.w,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: AppColors.purplecolor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 12.w),
              Text(
                'Continue with Google',
                style: GoogleFonts.instrumentSans(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackcolor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 110.w,
          child: Divider(color: Colors.black, thickness: 1.h),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
          child: Text(
            'or',
            style: GoogleFonts.quicksand(
              fontSize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          width: 110.w,
          child: Divider(color: Colors.black, thickness: 1.h),
        ),
      ],
    );
  }
}

class EmailInputField extends StatelessWidget {
  final LoginViewModel viewModel;

  const EmailInputField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330.w,
      child: TextField(
        controller: viewModel.emailController,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.instrumentSans(
          fontSize: 16.sp,
          color: AppColors.blackcolor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          hintText: 'Your Email',
          hintStyle: GoogleFonts.instrumentSans(
            fontSize: 14.sp,
            color: AppColors.blackcolor,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.all(12.0.r),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
              child: Center(
                child: Image.asset(
                  'assets/icons/email.png',
                  width: 19.w,
                  height: 19.w,
                  color: AppColors.graycolor,
                ),
              ),
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.graycolor, width: 2.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.graycolor, width: 2.w),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
        onChanged: (_) => viewModel.notifyListeners(),
      ),
    );
  }
}

class PasswordInputField extends StatelessWidget {
  final LoginViewModel viewModel;

  const PasswordInputField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330.w,
      child: TextField(
        controller: viewModel.passwordController,
        obscureText: !viewModel.isPasswordVisible,
        style: GoogleFonts.instrumentSans(
          fontSize: 16.sp,
          color: AppColors.blackcolor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          hintText: 'Password',
          hintStyle: GoogleFonts.instrumentSans(
            fontSize: 14.sp,
            color: AppColors.blackcolor,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.graycolor,
              size: 25.w,
            ),
            onPressed: viewModel.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.graycolor, width: 2.w),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.graycolor, width: 2.w),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
        onChanged: (_) => viewModel.notifyListeners(),
      ),
    );
  }
}

class RememberAndForgotRow extends StatelessWidget {
  final LoginViewModel viewModel;

  const RememberAndForgotRow({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: Checkbox(
                  value: viewModel.rememberMe,
                  onChanged: (_) => viewModel.toggleRememberMe(),
                  activeColor: AppColors.purplecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  side: BorderSide(
                    color: AppColors.graycolor.withOpacity(0.5),
                    width: 1.5.w,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Remember me',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14.sp,
                  color: AppColors.blackcolor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              final isDoctor = context.read<LoginViewModel>().isDoctorLogin;

              if (isDoctor) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DocForgotPasswordScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen()),
                );
              }
            },
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.instrumentSans(
                fontSize: 16.sp,
                color: AppColors.blackcolor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final LoginViewModel viewModel;

  const LoginButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isValid = viewModel.isFormValid;

    return Container(
      width: 330.w,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF786AC8), Color(0xFF5B5F9C)],
        ),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: viewModel.isLoading
              ? null
              : () {
                  viewModel.login(context);
                },
          borderRadius: BorderRadius.circular(15.r),
          child: Center(
            child: viewModel.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Login',
                    style: GoogleFonts.quicksand(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.w,
      child: Text(
        'I agree to the Terms of Service and Privacy Policy',
        textAlign: TextAlign.center,
        style: GoogleFonts.instrumentSans(
          fontSize: 14.sp,
          color: AppColors.graycolor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
