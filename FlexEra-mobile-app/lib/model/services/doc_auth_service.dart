import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/network/cache_helper.dart';
import '../../core/network/dio_helper.dart';
import '../doc_model/doc_auth_model.dart';
import '../repository/doc_auth_repository.dart';

class DocAuthService {
  final DocAuthRepository _repository = DocAuthRepository();

  Future<bool> validateDoctorId(String doctorId) async {
    try {
      debugPrint('🔍 Validating Doctor ID: $doctorId');

      final response = await DioHelper.postData(
        url: 'doctors/login',
        data: {
          "_id": doctorId,
          "email": "placeholder@example.com",
          "password": "wrongpassword123",
        },
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('✅ Response Data: ${response.data}');

      if (response.data is Map) {
        final message =
            response.data['message']?.toString().toLowerCase() ?? '';
        debugPrint('✅ Message: $message');

        if (message.contains('login successful')) {
          debugPrint('✅ ID VALID - Login successful');
          return true;
        }

        if (message.contains('doctor not found')) {
          debugPrint('❌ ID INVALID - Doctor not found');
          return false;
        }
      }

      debugPrint('✅ ID VALID - 200 response');
      return true;
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null && e.response!.data is Map) {
        final message =
            e.response!.data['message']?.toString().toLowerCase() ?? '';
        debugPrint('❌ Error Message: $message');

        if (message.contains('doctor not found')) {
          debugPrint('❌ ID INVALID - Doctor not found');
          return false;
        }

        if (message.contains('wrong password') ||
            message.contains('incorrect password') ||
            message.contains('invalid credentials')) {
          debugPrint('✅ ID VALID - Wrong password (ID exists)');
          return true;
        }

        if (message.contains('email does not match') ||
            message.contains('email must match')) {
          debugPrint('✅ ID VALID - Email mismatch (ID exists)');
          return true;
        }

        debugPrint('❌ ID INVALID - Other error');
        return false;
      }

      debugPrint('❌ ID INVALID - No response');
      return false;
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return false;
    }
  }

  Future<DocAuthModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authModel = await _repository.loginWithEmail(
        email: email,
        password: password,
      );

      if (authModel.token != null) {
        await CacheHelper.saveData(key: 'token', value: authModel.token);

        if (authModel.doctor?.id != null) {
          await CacheHelper.saveData(
              key: 'doctor_id', value: authModel.doctor!.id);
          await CacheHelper.saveData(key: 'user_role', value: 'doctor');
        }
      }

      return authModel;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DocAuthModel> loginWithId({
    required String id,
    required String password,
  }) async {
    try {
      final authModel = await _repository.loginWithId(
        id: id,
        password: password,
      );

      if (authModel.token != null) {
        await CacheHelper.saveData(key: 'token', value: authModel.token);

        if (authModel.doctor?.id != null) {
          await CacheHelper.saveData(
              key: 'doctor_id', value: authModel.doctor!.id);
          await CacheHelper.saveData(key: 'user_role', value: 'doctor');
        }
      }

      return authModel;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DocAuthModel> login({
    String? id,
    String? email,
    required String password,
  }) async {
    try {
      final authModel = await _repository.login(
        id: id,
        email: email,
        password: password,
      );

      if (authModel.token != null) {
        await CacheHelper.saveData(key: 'token', value: authModel.token);

        if (authModel.doctor?.id != null) {
          await CacheHelper.saveData(
              key: 'doctor_id', value: authModel.doctor!.id);
          await CacheHelper.saveData(key: 'user_role', value: 'doctor');
        }
      }

      return authModel;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await CacheHelper.removeData(key: 'token');
      await CacheHelper.removeData(key: 'doctor_id');
      await CacheHelper.removeData(key: 'user_role');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  bool isLoggedIn() {
    final token = CacheHelper.getData(key: 'token');
    final role = CacheHelper.getData(key: 'user_role');
    return token != null && role == 'doctor';
  }
}
