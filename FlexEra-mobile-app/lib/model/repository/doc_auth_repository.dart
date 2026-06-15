import 'package:dio/dio.dart';
import '../../core/network/dio_helper.dart';
import '../../core/network/end_points.dart';
import '../doc_model/doc_auth_model.dart';

class DocAuthRepository {
  Map<String, dynamic> _fixResponseData(dynamic data) {
    if (data is List) {
      if (data.isNotEmpty) {
        if (data[0] is Map) {
          return data[0] as Map<String, dynamic>;
        } else {
          return {'message': data[0].toString()};
        }
      } else {
        return {'message': 'Empty list response'};
      }
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      return {'message': data.toString()};
    }
  }

  /// Doctor login with email and password
  Future<DocAuthModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      Response response = await DioHelper.postData(
        url: EndPoints.doctorLogin,
        data: {
          "email": email,
          "password": password,
        },
      );

      final cleanData = _fixResponseData(response.data);

      if (response.statusCode == 200) {
        return DocAuthModel.fromJson(cleanData);
      } else {
        throw Exception(cleanData['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Doctor login with ID and password
  Future<DocAuthModel> loginWithId({
    required String id,
    required String password,
  }) async {
    try {
      Response response = await DioHelper.postData(
        url: EndPoints.doctorLogin,
        data: {
          "_id": id,
          "password": password,
        },
      );

      final cleanData = _fixResponseData(response.data);

      if (response.statusCode == 200) {
        return DocAuthModel.fromJson(cleanData);
      } else {
        throw Exception(cleanData['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Doctor login flexible
  Future<DocAuthModel> login({
    String? id,
    String? email,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> data = {"password": password};

      if (id != null && id.isNotEmpty) {
        data["_id"] = id;
      }
      if (email != null && email.isNotEmpty) {
        data["email"] = email;
      }

      Response response = await DioHelper.postData(
        url: EndPoints.doctorLogin,
        data: data,
      );

      final cleanData = _fixResponseData(response.data);

      if (response.statusCode == 200) {
        return DocAuthModel.fromJson(cleanData);
      } else {
        throw Exception(cleanData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = _fixResponseData(e.response!.data);
        throw Exception(errorData['message'] ?? 'Server Error');
      }
      rethrow;
    }
  }
}
