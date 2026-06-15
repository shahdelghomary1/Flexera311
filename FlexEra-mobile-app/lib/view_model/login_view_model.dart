import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexera/core/network/cache_helper.dart';
import 'package:flexera/core/network/constants.dart';
import 'package:flexera/core/network/dio_helper.dart';
import 'package:flexera/core/network/end_points.dart';
import 'package:flexera/model/auth_models/auth_model.dart';
import 'package:flexera/model/repository/notification_repo.dart';
import 'package:flexera/model/services/notification_service.dart';
import 'package:flexera/view/screens/home_screen.dart';
import 'package:flexera/model/services/doc_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../view/screens/doc_home_screen.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DocAuthService _docAuthService = DocAuthService();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isDoctorLogin = false;
  String? _doctorId;

  bool get isPasswordVisible => _isPasswordVisible;

  bool get rememberMe => _rememberMe;

  bool get isLoading => _isLoading;

  bool get isDoctorLogin => _isDoctorLogin;

  String? get doctorId => _doctorId;

  // Email validation using regex
  bool get isEmailValid {
    if (emailController.text.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(emailController.text);
  }

  // Password validation (at least 6 characters for basic login)
  bool get isPasswordValid {
    return passwordController.text.isNotEmpty &&
        passwordController.text.length >= 6;
  }

  // Check if form is valid
  bool get isFormValid {
    return isEmailValid && isPasswordValid;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Toggle remember me checkbox
  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  // Set doctor login mode
  void setDoctorLogin(bool isDoctor, String? doctorId) {
    _isDoctorLogin = isDoctor;
    _doctorId = doctorId;
    notifyListeners();
  }

  // Login with email and password
  Future<void> login(BuildContext context) async {
    if (!isFormValid) {
      String validationMsg = "";
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        validationMsg = "Please fill in all fields";
      } else if (!isEmailValid) {
        validationMsg = "Please enter a valid email address";
      } else if (!isPasswordValid) {
        validationMsg = "Password must be at least 6 characters";
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationMsg),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    if (_isDoctorLogin) {
      await _loginDoctor(context);
      _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      Response response = await DioHelper.postData(
        url: EndPoints.login,
        data: {
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      debugPrint('✅ Login Response Status: ${response.statusCode}');

      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 404) {
        debugPrint('⚠️ Server Error Body: ${response.data}');

        if (context.mounted) {
          String errorMsg = "Login Failed";

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

      if (response.statusCode == 200) {
        final authModel = AuthModel.fromJson(response.data);

        if (authModel.token != null) {
          debugPrint('Login Success Token: ${authModel.token}');

          token = authModel.token;
          await CacheHelper.saveData(key: 'token', value: authModel.token);
          await CacheHelper.saveData(key: 'isDoctor', value: false);

          try {
            String? fcmToken = await FirebaseMessaging.instance.getToken();

            if (fcmToken != null) {
              debugPrint("🚀 Sending FCM Token to Backend: $fcmToken");
              await NotificationRepo.sendFcmToken(
                fcmToken: fcmToken,
                token: authModel.token!,
              );
              debugPrint("✅ FCM Token Updated Successfully!");
            }
          } catch (e) {
            debugPrint("⚠️ Failed to update FCM token: $e");
          }
          if (response.data['user'] != null) {
            String userId =
                response.data['user']['_id'] ?? response.data['user']['id'];

            await CacheHelper.saveData(key: 'id', value: userId);

            await CacheHelper.saveData(key: 'userId', value: userId);
            debugPrint('✅ User ID Saved Successfully: $userId');

            await NotificationService.connectUser();
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login Successful!"),
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
      debugPrint('Request Path: ${e.requestOptions.path}');
      debugPrint('Sent Data: ${e.requestOptions.data}');

      String errorMessage = "Login Failed";
      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Login doctor
  Future<void> _loginDoctor(BuildContext context) async {
    try {
      debugPrint('ID sent: $_doctorId');
      debugPrint('Email sent: ${emailController.text}');

      final authModel = await _docAuthService.login(
        id: _doctorId,
        email: emailController.text,
        password: passwordController.text,
      );

      if (authModel.token != null) {
        debugPrint('Doctor Login Success Token: ${authModel.token}');
        debugPrint('Doctor Info: ${authModel.doctor?.name}');

        token = authModel.token;
        await CacheHelper.saveData(key: 'token', value: authModel.token);
        await CacheHelper.saveData(key: 'isDoctor', value: true);

        if (authModel.doctor?.id != null) {
          await CacheHelper.saveData(key: 'id', value: authModel.doctor!.id);
          debugPrint('✅ Doctor ID Saved: ${authModel.doctor!.id}');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome Dr. ${authModel.doctor?.name ?? ""}!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DocHomeScreen()),
            (route) => false,
          );
        }
      }
    } on DioException catch (e) {
      String errorMessage = "Login Failed";

      if (e.response != null && e.response?.data is Map) {
        if (e.response!.data['errors'] != null &&
            e.response!.data['errors'] is List &&
            (e.response!.data['errors'] as List).isNotEmpty) {
          List<String> errors = (e.response!.data['errors'] as List)
              .map((er) => er.toString())
              .toList();
          errorMessage = errors.join('\n• ');
          errorMessage = '• $errorMessage';
        } else {
          errorMessage = e.response?.data['message'] ??
              e.response?.data['error'] ??
              errorMessage;
        }
      }

      debugPrint('Doctor Login Error (Server): $errorMessage');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Doctor Login General Error: $e');

      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
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
          await CacheHelper.saveData(key: 'isDoctor', value: false);
          token = serverToken;

          try {
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              debugPrint(
                  "🚀 Google Login: Sending FCM Token to Backend: $fcmToken");
              await NotificationRepo.sendFcmToken(
                fcmToken: fcmToken,
                token: serverToken,
              );
              debugPrint("✅ Google Login: FCM Token Updated Successfully!");
            }
          } catch (e) {
            debugPrint("⚠️ Google Login: Failed to update FCM token: $e");
          }

          if (data['user'] != null) {
            String userId = data['user']['_id'] ?? data['user']['id'];

            await CacheHelper.saveData(key: 'id', value: userId);
            await CacheHelper.saveData(key: 'userId', value: userId);
            await NotificationService.connectUser();

            debugPrint("✅ Google User ID Saved: $userId");
          }

          debugPrint(" Google Login Success. Token Saved.");

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? "Welcome Back!"),
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
      String errorMsg = "Login Failed";
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
