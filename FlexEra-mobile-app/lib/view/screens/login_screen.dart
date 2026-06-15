import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/view/widget/login_widgets.dart';
import 'package:flexera/view/widget/signup_widgets.dart';
import 'package:flexera/view_model/login_view_model.dart';
import 'package:flexera/view_model/signup_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final bool isDoctorLogin;
  final String? doctorId;

  const LoginScreen({
    super.key,
    this.isDoctorLogin = false,
    this.doctorId,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginSelected = true;

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F2F7),
      primaryColor: Colors.white,
      useMaterial3: true,
      textTheme:
          GoogleFonts.instrumentSansTextTheme(ThemeData.light().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF786AC8),
        brightness: Brightness.light,
      ),
    );

    return Theme(
      data: lightTheme,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              final viewModel = LoginViewModel();
              if (widget.isDoctorLogin && widget.doctorId != null) {
                viewModel.setDoctorLogin(true, widget.doctorId);
              }
              return viewModel;
            },
          ),
          ChangeNotifierProvider(
            create: (_) {
              final viewModel = SignupViewModel();
              if (widget.isDoctorLogin && widget.doctorId != null) {
                viewModel.setDoctorSignup(true, widget.doctorId);
              }
              return viewModel;
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F2F7),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Let's get started",
                          style: GoogleFonts.quicksand(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackcolor,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        if (!widget.isDoctorLogin) ...[
                          isLoginSelected
                              ? Consumer<LoginViewModel>(
                                  builder: (context, viewModel, _) =>
                                      GoogleSignInButton(viewModel: viewModel),
                                )
                              : Consumer<SignupViewModel>(
                                  builder: (context, viewModel, _) =>
                                      SignupGoogleButton(viewModel: viewModel),
                                ),
                          SizedBox(height: 28.h),
                          const OrDivider(),
                          SizedBox(height: 28.h),
                        ],
                        Container(
                          width: 387.w,
                          margin: EdgeInsets.only(left: 13.w, right: 13.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 32.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Column(
                            children: [
                              _buildTabSelector(),
                              SizedBox(height: 24.h),
                              isLoginSelected
                                  ? _buildLoginForm()
                                  : _buildSignupForm(),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        isLoginSelected
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isLoginSelected = false;
                                  });
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
                                        text: "Don't have an account? Sign up",
                                        style: GoogleFonts.quicksand(
                                          fontSize: 21.sp,
                                          fontWeight: FontWeight.w700,
                                          foreground: Paint()
                                            ..shader = const LinearGradient(
                                              colors: [
                                                Color(0xFF9FBEF9),
                                                Color(0xFF590B8D),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ).createShader(
                                              const Rect.fromLTWH(
                                                  0, 0, 200, 50),
                                            ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : LoginPrompt(
                                onTap: () {
                                  setState(() {
                                    isLoginSelected = true;
                                  });
                                },
                              ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      width: 360.w,
      height: 70.h,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color.fromARGB(240, 230, 230, 229),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isLoginSelected = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isLoginSelected
                      ? Colors.white
                      : const Color.fromARGB(240, 230, 230, 229),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: 1,
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
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isLoginSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
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

  Widget _buildLoginForm() {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            EmailInputField(viewModel: viewModel),
            SizedBox(height: 16.h),
            PasswordInputField(viewModel: viewModel),
            SizedBox(height: 16.h),
            RememberAndForgotRow(viewModel: viewModel),
            SizedBox(height: 25.h),
            LoginButton(viewModel: viewModel),
            SizedBox(height: 16.h),
            const TermsText(),
          ],
        );
      },
    );
  }

  Widget _buildSignupForm() {
    return Consumer<SignupViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            FullNameInputField(viewModel: viewModel),
            SizedBox(height: 10.h),
            SignupEmailInputField(viewModel: viewModel),
            SizedBox(height: 10.h),
            SignupPasswordInputField(viewModel: viewModel),
            SizedBox(height: 8.h),
            PasswordRequirementsText(viewModel: viewModel),
            SizedBox(height: 12.h),
            ConfirmPasswordInputField(viewModel: viewModel),
            SizedBox(height: 10.h),
            TermsAgreementCheckbox(viewModel: viewModel),
            SizedBox(height: 10.h),
            CreateAccountButton(viewModel: viewModel),
          ],
        );
      },
    );
  }
}
