import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/view_model/signup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupTabSelector extends StatefulWidget {
  const SignupTabSelector({super.key});

  @override
  State<SignupTabSelector> createState() => _SignupTabSelectorState();
}

class _SignupTabSelectorState extends State<SignupTabSelector> {
  bool isLoginSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      height: 70.h,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color.fromARGB(240, 230, 230, 229),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isLoginSelected
                      ? Colors.white
                      : const Color.fromARGB(240, 230, 230, 229),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: Offset(0, 4.h),
                            blurRadius: 6.r,
                            spreadRadius: 1.r,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Log In',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isLoginSelected = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: !isLoginSelected
                      ? Colors.white
                      : const Color.fromARGB(240, 230, 230, 229),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: !isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignupGoogleButton extends StatelessWidget {
  final SignupViewModel viewModel;

  const SignupGoogleButton({super.key, required this.viewModel});

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
              : () {
                  viewModel.signupWithGoogle(context);
                },
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

class FullNameInputField extends StatelessWidget {
  final SignupViewModel viewModel;

  const FullNameInputField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330.w,
      child: TextField(
        controller: viewModel.fullNameController,
        keyboardType: TextInputType.name,
        style: GoogleFonts.instrumentSans(
          fontSize: 16.sp,
          color: AppColors.blackcolor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          hintText: 'Full Name',
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
                  'assets/icons/Icon (1).png',
                  width: 22.w,
                  height: 22.w,
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

class SignupEmailInputField extends StatelessWidget {
  final SignupViewModel viewModel;

  const SignupEmailInputField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
                      color: AppColors.graycolor,
                      width: 20.w,
                      height: 20.w,
                    ),
                  ),
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
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
            onChanged: (value) => viewModel.onEmailChanged(value),
          ),
        ),
        if (viewModel.showEmailSuggestion) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: InkWell(
              onTap: viewModel.acceptEmailCorrection,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16.w),
                  SizedBox(width: 6.w),
                  RichText(
                    text: TextSpan(
                      text: "Did you mean ",
                      style: GoogleFonts.instrumentSans(
                        color: Colors.black54,
                        fontSize: 12.sp,
                      ),
                      children: [
                        TextSpan(
                          text: "${viewModel.emailSuggestion}?",
                          style: GoogleFonts.instrumentSans(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SignupPasswordInputField extends StatelessWidget {
  final SignupViewModel viewModel;

  const SignupPasswordInputField({super.key, required this.viewModel});

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

class PasswordRequirementsText extends StatelessWidget {
  final SignupViewModel viewModel;

  const PasswordRequirementsText({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330.w,
      child: Text(
        'At least 8 characters, with one uppercase and one lowercase letter',
        style: GoogleFonts.instrumentSans(
          fontSize: 12.sp,
          color: AppColors.graycolor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class ConfirmPasswordInputField extends StatelessWidget {
  final SignupViewModel viewModel;

  const ConfirmPasswordInputField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330.w,
      child: TextField(
        controller: viewModel.confirmPasswordController,
        obscureText: !viewModel.isConfirmPasswordVisible,
        style: GoogleFonts.instrumentSans(
          fontSize: 16.sp,
          color: AppColors.blackcolor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          hintText: 'Confirm Password',
          hintStyle: GoogleFonts.instrumentSans(
            fontSize: 14.sp,
            color: AppColors.blackcolor,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.isConfirmPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.graycolor,
              size: 25.w,
            ),
            onPressed: viewModel.toggleConfirmPasswordVisibility,
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

class TermsAgreementCheckbox extends StatelessWidget {
  final SignupViewModel viewModel;

  const TermsAgreementCheckbox({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320.w,
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: Checkbox(
              value: viewModel.agreeToTerms,
              onChanged: (_) => viewModel.toggleAgreeToTerms(),
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
          SizedBox(width: 4.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.graycolor,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: 'I agree to the processing of '),
                  TextSpan(
                    text: 'Personal data',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 18.sp,
                      color: AppColors.purplecolor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateAccountButton extends StatelessWidget {
  final SignupViewModel viewModel;

  const CreateAccountButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
          onTap: () {
            debugPrint("🛑 1. UI: Button was pressed!");

            if (viewModel.isLoading) {
              debugPrint("⚠️ Button is disabled because isLoading is TRUE");
            } else {
              debugPrint("✅ Calling signup function...");
              viewModel.signup(context);
            }
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
                    'Create Account',
                    style: GoogleFonts.quicksand(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class LoginPrompt extends StatelessWidget {
  final VoidCallback? onTap;

  const LoginPrompt({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.pop(context);
          },
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.quicksand(
            fontSize: 21.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          children: [
            TextSpan(
              text: "Already have an account? Log in",
              style: GoogleFonts.quicksand(
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF9FBEF9), Color(0xFF590B8D)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(Rect.fromLTWH(0, 0, 200.w, 50.h)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
