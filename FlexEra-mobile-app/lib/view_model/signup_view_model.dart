import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flexera/core/network/cache_helper.dart';
import 'package:flexera/core/network/constants.dart';
import 'package:flexera/core/network/dio_helper.dart';
import 'package:flexera/core/network/end_points.dart';
import 'package:flexera/core/utils/signup_formatters.dart';
import 'package:flexera/model/auth_models/auth_model.dart';
import 'package:flexera/view/screens/home_screen.dart';
import 'package:flexera/view/screens/doc_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupViewModel extends ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  bool _isDoctorSignup = false;
  String? _doctorId;

  String? _emailSuggestion;
  bool _showEmailSuggestion = false;

  bool get isPasswordVisible => _isPasswordVisible;

  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  bool get agreeToTerms => _agreeToTerms;

  bool get isLoading => _isLoading;

  String? get emailSuggestion => _emailSuggestion;

  bool get showEmailSuggestion => _showEmailSuggestion;

  bool get isFullNameValid => fullNameController.text.trim().length >= 2;

  bool get isEmailValid {
    final text = emailController.text.trim();
    if (text.isEmpty) return false;
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(text);
  }

  String? _validatePassword(String value) {
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return "Password must contain at least one uppercase letter";
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return "Password must contain at least one lowercase letter";
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return "Password must contain at least one number";
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "Password must contain at least one special character (@, #, etc.)";
    }
    return null;
  }

  bool get isPasswordValid => passwordController.text.length >= 6;

  bool get isConfirmPasswordValid =>
      confirmPasswordController.text == passwordController.text;

  bool get isFormValid =>
      isFullNameValid &&
      isEmailValid &&
      isPasswordValid &&
      isConfirmPasswordValid &&
      agreeToTerms;

  void onEmailChanged(String value) {
    String? suggestion = SignupFormatters.getEmailCorrection(value);

    if (suggestion != null) {
      _emailSuggestion = suggestion;
      _showEmailSuggestion = true;
    } else {
      _showEmailSuggestion = false;
      _emailSuggestion = null;
    }
    notifyListeners();
  }

  void acceptEmailCorrection() {
    if (_emailSuggestion == null) return;

    final currentEmail = emailController.text;
    final parts = currentEmail.split('@');

    if (parts.isNotEmpty) {
      final newEmail = "${parts[0]}@$_emailSuggestion";

      emailController.text = newEmail;

      emailController.selection =
          TextSelection.fromPosition(TextPosition(offset: newEmail.length));

      _showEmailSuggestion = false;
      _emailSuggestion = null;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void toggleAgreeToTerms() {
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  }

  void setDoctorSignup(bool isDoctor, String? id) {
    _isDoctorSignup = isDoctor;
    _doctorId = id;
  }

  Future<void> signup(BuildContext context) async {
    debugPrint("🚀 1. Inside signup function");

    debugPrint("📋 Data Check:");
    debugPrint("   - Name: '${fullNameController.text}'");
    debugPrint("   - Email: '${emailController.text}'");
    debugPrint("   - Password: '${passwordController.text}'");
    debugPrint("   - Confirm: '${confirmPasswordController.text}'");
    debugPrint("   - Agree Terms: $_agreeToTerms");

    final String name = fullNameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    String? validationMessage;

    String? passwordError = _validatePassword(password);
    debugPrint("🔒 Password Validation Result: $passwordError");

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      validationMessage = "Please fill in all fields.";
      debugPrint("❌ Validation Failed: Empty Fields");
    } else if (name.length < 2) {
      validationMessage = "Name must be at least 2 characters.";
      debugPrint("❌ Validation Failed: Name too short");
    } else if (!isEmailValid) {
      validationMessage = "Please enter a valid email address.";
      debugPrint("❌ Validation Failed: Invalid Email Regex");
    } else if (passwordError != null) {
      validationMessage = passwordError;
      debugPrint("❌ Validation Failed: Password Policy -> $passwordError");
    } else if (password != confirmPassword) {
      validationMessage = "Passwords do not match.";
      debugPrint("❌ Validation Failed: Passwords mismatch");
    } else if (!_agreeToTerms) {
      validationMessage = "You must agree to the Terms & Conditions.";
      debugPrint("❌ Validation Failed: Terms not checked");
    }

    if (validationMessage != null) {
      debugPrint("🛑 Stopping Signup because: $validationMessage");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationMessage),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        debugPrint("⚠️ Context is NOT mounted, cannot show SnackBar");
      }
      return;
    }

    debugPrint("✅ All Validations Passed! Starting API Call...");

    _isLoading = true;
    notifyListeners();

    if (_isDoctorSignup) {
      await _signupDoctor(context);
    } else {
      await _signupUser(context);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _signupUser(BuildContext context) async {
    try {
      Response response = await DioHelper.postData(
        url: EndPoints.register,
        data: {
          "name": fullNameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "confirmPassword": confirmPasswordController.text,
        },
      );

      debugPrint('✅ Response Received: ${response.statusCode}');
      if (response.statusCode == 400 || response.statusCode == 409) {
        debugPrint('⚠️ Server Error Body: ${response.data}');

        if (context.mounted) {
          String errorMsg = "User already exists";

          if (response.data['errors'] != null &&
              response.data['errors'] is List &&
              (response.data['errors'] as List).isNotEmpty) {
            List<String> errors = (response.data['errors'] as List)
                .map((e) => e.toString())
                .toList();
            errorMsg = errors.join('\n• ');
            errorMsg = '• $errorMsg';
          } else {
            errorMsg =
                response.data['message'] ?? response.data['error'] ?? errorMsg;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4)),
          );
        }
        return;
      }

      await _handleSuccessResponse(context, response, isDoctor: false);
    } on DioException catch (e) {
      debugPrint("💥 DioError Caught!");
      _handleErrorResponse(context, e);
    } catch (e) {
      debugPrint("💥 UNKNOWN Error: $e");
    }
  }

  Future<void> _signupDoctor(BuildContext context) async {
    try {
      debugPrint('Sending Doctor Signup Request... ID: $_doctorId');

      final Map<String, dynamic> requestData = {
        "name": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "confirmPassword": confirmPasswordController.text,
        "_id": _doctorId,
      };

      Response response = await DioHelper.postData(
        url: 'doctors/signup',
        data: requestData,
      );

      await _handleSuccessResponse(context, response, isDoctor: true);
    } on DioException catch (e) {
      _handleErrorResponse(context, e);
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    }
  }

  Future<void> _handleSuccessResponse(BuildContext context, Response response,
      {required bool isDoctor}) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final authModel = AuthModel.fromJson(response.data);

      if (authModel.token != null) {
        await CacheHelper.saveData(key: 'token', value: authModel.token);
        await CacheHelper.saveData(key: 'isDoctor', value: isDoctor);
        token = authModel.token;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isDoctor
                  ? "Doctor Account Created!"
                  : "Account Created Successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    isDoctor ? const DocHomeScreen() : const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        String errorMsg = "Registration Failed";

        if (response.data is Map<String, dynamic>) {
          errorMsg = response.data['message'] ??
              response.data['error'] ??
              "Unknown Error Occurred";
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleErrorResponse(BuildContext context, DioException e) {
    String finalErrorMessage = "Something went wrong. Please try again.";

    if (e.response != null) {
      debugPrint("🛑 Server Error Body: ${e.response?.data}");

      final data = e.response?.data;
      String serverMessage = "";

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) {
          serverMessage = data['message'];
        } else if (data.containsKey('error')) {
          serverMessage = data['error'];
        }
      } else if (data is String) {
        serverMessage = data;
      }

      final lowerMsg = serverMessage.toLowerCase();

      if (lowerMsg.contains("user already exists") ||
          lowerMsg.contains("email") && lowerMsg.contains("exist")) {
        finalErrorMessage =
            "This email is already registered. Please login instead.";
      } else if (serverMessage.isNotEmpty) {
        finalErrorMessage = serverMessage;
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      finalErrorMessage = "Connection timeout. Check your internet.";
    } else if (e.type == DioExceptionType.connectionError) {
      finalErrorMessage = "No internet connection.";
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  finalErrorMessage,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> signupWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    const String iosClientId =
        "145334392661-5rjoo4ukvqgo7ckueasn2l27d09bd2hj.apps.googleusercontent.com";

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: Platform.isIOS ? iosClientId : null,
    );

    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      Response response = await DioHelper.postData(
        url: EndPoints.googleLogin,
        data: {
          "idToken": googleAuth.idToken,
          "platform": Platform.isIOS ? 'ios' : 'android',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          String serverToken = data['token'];
          await CacheHelper.saveData(key: 'token', value: serverToken);
          token = serverToken;

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(data['message'] ?? "Account Created Successfully!"),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      }
    } on DioException catch (e) {
      _handleErrorResponse(context, e);
    } catch (e) {
      debugPrint("Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("An error occurred"), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
