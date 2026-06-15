import 'package:dio/dio.dart';
import 'package:flexera/core/network/dio_helper.dart';
import 'package:flexera/core/network/end_points.dart';

class NotificationRepo {
  static Future<Response> getNotifications({required String token}) async {
    return await DioHelper.getData(
      url: EndPoints.getNotifications,
      token: token,
    );
  }
  static Future<Response> sendFcmToken({
    required String fcmToken,
    required String token,
  }) async {
    return await DioHelper.postData(
      url: 'notifications/fcm-token',
      data: {
        "fcmToken": fcmToken,
      },
      token: token,
    );
  }
  static Future<Response> markAsRead({required String id, required String token}) async {
    return await DioHelper.putData(
      url: EndPoints.markNotificationRead(id),
      data: {},
      token: token,
    );
  }
  static Future<Response> deleteNotification(
      {required String id, required String token}) async {
    return await DioHelper.deleteData(
      url: EndPoints.deleteNotification(id),
      token: token,
    );
  }
}
