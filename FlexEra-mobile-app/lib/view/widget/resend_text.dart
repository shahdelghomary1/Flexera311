import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/forgot_password_view_model.dart';

class ResendText extends StatefulWidget {
  const ResendText({super.key});

  @override
  State<ResendText> createState() => _ResendTextState();
}

class _ResendTextState extends State<ResendText> {
  bool _isWaiting = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  void _startTimer() {
    if (!mounted) return;
    setState(() {
      _isWaiting = true;
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isWaiting = false;
        });
      }
    });
  }

  Future<void> _onResendPressed(ForgotPasswordViewModel vm) async {
    if (_isWaiting || vm.isLoading) return;

    await vm.resendOtp(context);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ForgotPasswordViewModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.resndcolor1,
              AppColors.darkpurplecolor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            "Didn't receive the code?",
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap:
              (_isWaiting || vm.isLoading) ? null : () => _onResendPressed(vm),
          child: _isWaiting
              ? Text(
                  "Resend in $_secondsRemaining s",
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                )
              : vm.isLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.darkpurplecolor,
                      ),
                    )
                  : ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.resndcolor1,
                          AppColors.darkpurplecolor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        "Resend",
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.transparent,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
