import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/dio_helper.dart';
import '../core/network/end_points.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final PageController pageController = PageController();

  List<TextEditingController> codeControllers =
      List.generate(4, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  List<TextEditingController> idControllers =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> idFocusNodes = List.generate(6, (_) => FocusNode());

  FocusNode emailFocusNode = FocusNode();

  int currentPage = 0;
  String id = '';
  String email = '';
  String code = '';
  String password = '';
  String confirmPassword = '';

  bool isLoading = false;
  String? tempToken;
  String? resetToken;

  bool _isDoctor = false;

  bool isPasswordVisible = false;
  bool isConfirmVisible = false;

  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  void setRole({required bool isDoctor}) {
    _isDoctor = isDoctor;
  }

  bool get isIdValid {
    if (!_isDoctor) return true;

    id = idControllers.map((e) => e.text).join();
    return id.length == 6;
  }

  bool get isEmailValid => _emailRegex.hasMatch(email.trim()) && isIdValid;

  bool get isCodeValid => code.length == 4;

  bool get isPasswordValid =>
      password.length >= 8 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]')) &&
      password.contains(RegExp(r'[0-9]'));

  bool get isConfirmValid =>
      confirmPassword == password && confirmPassword.isNotEmpty;

  void onEmailChanged(String value) {
    email = value;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    password = value;
    notifyListeners();
  }

  void onConfirmChanged(String value) {
    confirmPassword = value;
    notifyListeners();
  }

  void updateCode() {
    code = codeControllers.map((e) => e.text).join();
    notifyListeners();
  }

  void onIdChangedAt(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5)
        idFocusNodes[index + 1].requestFocus();
      else
        emailFocusNode.requestFocus();
    } else if (index > 0) {
      idFocusNodes[index - 1].requestFocus();
    }
    id = idControllers.map((e) => e.text).join();
    notifyListeners();
  }

  void onCodeChangedAt(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3)
        focusNodes[index + 1].requestFocus();
      else
        focusNodes[index].unfocus();
    } else if (index > 0) focusNodes[index - 1].requestFocus();
    updateCode();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    isConfirmVisible = !isConfirmVisible;
    notifyListeners();
  }

  Future<void> sendOtp(BuildContext context) async {
    if (!isEmailValid) {
      String msg = _isDoctor
          ? "Please enter valid ID and Email"
          : "Please enter valid Email";
      _showSnackBar(context, msg, Colors.orange);
      return;
    }

    _setLoading(true);
    try {
      final Map<String, dynamic> data = {'email': email};

      if (_isDoctor) {
        id = idControllers.map((e) => e.text).join();
        data['_id'] = id;
      }

      final String url = _isDoctor
          ? EndPoints.doctorForgotPassword
          : EndPoints.userForgotPassword;

      debugPrint("📡 Sending Request to: $url");
      final response = await DioHelper.postData(url: url, data: data);

      debugPrint("🔍 FULL SERVER RESPONSE: ${response.data}");

      if (response.data['otpToken'] != null) {
        tempToken = response.data['otpToken'];
      } else if (response.data['resetToken'] != null) {
        tempToken = response.data['resetToken'];
      } else if (response.data['token'] != null) {
        tempToken = response.data['token'];
      } else if (response.data['tempToken'] != null) {
        tempToken = response.data['tempToken'];
      }

      debugPrint("👉 Token Captured: $tempToken");

      _showSnackBar(context,
          response.data['message'] ?? 'Code Sent Successfully', Colors.green);
      _moveToPage(1);
    } catch (e) {
      _handleError(context, e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    updateCode();
    final cleanCode = code.trim();

    debugPrint("🔍 Debugging Verify OTP...");
    debugPrint("👉 Code Entered: '$cleanCode'");
    debugPrint("👉 Code Length: ${cleanCode.length}");
    debugPrint("👉 Is Code Valid? $isCodeValid");

    if (cleanCode.length != 4) {
      _showSnackBar(context, "Please enter full 4-digit code", Colors.orange);
      debugPrint("❌ Verification Stopped: Code length is not 4");
      return;
    }

    debugPrint("👉 Temp Token value: $tempToken");
    if (tempToken == null || tempToken!.isEmpty) {
      _showSnackBar(context,
          "Session Error: Token is missing. Please resend code.", Colors.red);
      debugPrint("❌ Verification Stopped: Temp Token is NULL!");
      return;
    }

    _setLoading(true);
    try {
      final String url =
          _isDoctor ? EndPoints.doctorVerifyOtp : EndPoints.userVerifyOtp;
      debugPrint("📡 Sending Request to: $url");

      final response = await DioHelper.postData(
        url: url,
        token: tempToken,
        data: {"otp": cleanCode},
      );

      debugPrint("✅ Server Response Status: ${response.statusCode}");
      debugPrint("✅ Server Response Data: ${response.data}");

      if (response.statusCode == 200) {
        resetToken = response.data['resetToken'] ??
            response.data['token'] ??
            response.data['otpToken'];

        resetToken ??= tempToken;
        debugPrint("🎉 Success! Moving to Create Password Page...");
        _showSnackBar(context, "Code Verified", Colors.green);

        _moveToPage(2);
      } else {
        debugPrint("⚠️ Server refused verification");
      }
    } catch (e) {
      _handleError(context, e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    if (!isPasswordValid || !isConfirmValid) return;

    _setLoading(true);
    try {
      final String url = _isDoctor
          ? EndPoints.doctorResetPassword
          : EndPoints.userResetPassword;

      await DioHelper.postData(
        url: url,
        token: resetToken,
        data: {"newPassword": password, "confirmPassword": confirmPassword},
      );

      _showSnackBar(
          context, "Password reset successfully! Login now.", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _handleError(context, e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOtp(BuildContext context) async {
    await sendOtp(context);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _moveToPage(int page) {
    currentPage = page;
    pageController.animateToPage(currentPage,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    notifyListeners();
  }

  void _handleError(BuildContext context, dynamic error) {
    String msg = "Something went wrong";
    if (error is DioException) {
      if (error.response?.data is Map) {
        msg = error.response!.data['message'] ??
            error.response!.data['error'] ??
            error.message ??
            "Server Error";
      } else {
        msg = error.message ?? "Connection Error";
      }
    }
    _showSnackBar(context, msg, Colors.red);
  }

  void _showSnackBar(BuildContext context, String msg, Color color) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    for (var c in codeControllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    for (var c in idControllers) c.dispose();
    for (var f in idFocusNodes) f.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }
}
