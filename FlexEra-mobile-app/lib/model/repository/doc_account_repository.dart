import 'package:dio/dio.dart';
import '../../core/network/dio_helper.dart';
import '../../core/network/end_points.dart';
import '../doc_model/doc_account_model.dart';

class DocAccountRepository {
  /// Get doctor account information
  Future<DoctorAccountResponse> getDoctorAccount(String token) async {
    try {
      Response response = await DioHelper.getData(
        url: EndPoints.doctorAccount,
        token: token,
      );

      if (response.statusCode == 200) {
        return DoctorAccountResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to fetch account: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update doctor account information
  Future<DoctorAccountResponse> updateDoctorAccount({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? imageFile,
  }) async {
    try {
      final model = DoctorAccountModel(
        name: name,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      final formData = await model.toFormData(imageFile: imageFile);

      Response response = await DioHelper.putData(
        url: EndPoints.doctorAccount,
        data: formData,
        token: token,
      );

      if (response.statusCode == 200) {
        return DoctorAccountResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update account: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
