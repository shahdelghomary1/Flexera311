import 'package:dio/dio.dart';

import '../../core/network/cache_helper.dart';
import '../../core/network/dio_helper.dart';
import '../../core/network/end_points.dart';
import '../auth_models/update_profile_model.dart';

class AccountRepository {
  Future<Response> updateAccount(UpdateProfileModel model) async {
    try {
      FormData formData = await model.toFormData();

      String? token = CacheHelper.getData(key: 'token');

      return await DioHelper.putData(
        url: EndPoints.updateAccount,
        data: formData,
        token: token,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfileData() async {
    try {
      String? token = CacheHelper.getData(key: 'token');

      return await DioHelper.getData(
        url: EndPoints.updateAccount,
        token: token,
      );
    } catch (e) {
      rethrow;
    }
  }
}
