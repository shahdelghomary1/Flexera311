import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/network/cache_helper.dart';
import '../doc_model/doc_account_model.dart';
import '../repository/doc_account_repository.dart';

class DocAccountService {
  final DocAccountRepository _repository = DocAccountRepository();

  Future<DoctorAccountResponse> getDoctorAccount() async {
    try {
      final token = CacheHelper.getData(key: 'token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final accountResponse = await _repository.getDoctorAccount(token);
      return accountResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response!.data['message'] ?? 'Failed to fetch account');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<DoctorAccountResponse> updateDoctorAccount({
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? imageFile,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final accountResponse = await _repository.updateDoctorAccount(
        token: token,
        name: name,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        imageFile: imageFile,
      );

      debugPrint('✅ Account updated successfully');
      return accountResponse;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.response?.statusCode}');
      debugPrint('❌ Error Data: ${e.response?.data}');

      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map && errorData.containsKey('errors')) {
          throw Exception('${errorData['errors']}');
        } else if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception(
              'Failed to update account: ${e.response?.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      rethrow;
    }
  }
}
