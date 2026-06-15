import 'package:flutter/material.dart';
import 'package:flexera/core/network/cache_helper.dart';

import '../model/auth_models/notification_model.dart';
import '../model/repository/notification_repo.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> allNotifications = [];

  List<NotificationModel> todayList = [];
  List<NotificationModel> weekList = [];
  List<NotificationModel> earlierList = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      String token = CacheHelper.getData(key: 'token');
      final response = await NotificationRepo.getNotifications(token: token);

      if (response.data['success'] == true) {
        var list = response.data['notifications'] as List;
        allNotifications =
            list.map((e) => NotificationModel.fromJson(e)).toList();
        _filterNotifications();
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> removeNotification(String id, BuildContext context) async {
    NotificationModel? deletedItem =
        allNotifications.firstWhere((element) => element.id == id);

    allNotifications.removeWhere((element) => element.id == id);
    _filterNotifications();
    notifyListeners();

    try {
      String token = CacheHelper.getData(key: 'token');
      await NotificationRepo.deleteNotification(id: id, token: token);
    } catch (e) {
      allNotifications.add(deletedItem);
      _filterNotifications();
      notifyListeners();
    }
  }

  Future<void> clearAllNotifications() async {
    if (allNotifications.isEmpty) return;

    var backupList = List<NotificationModel>.from(allNotifications);

    allNotifications.clear();
    _filterNotifications();
    notifyListeners();

    String token = CacheHelper.getData(key: 'token');

    for (var item in backupList) {
      try {
        await NotificationRepo.deleteNotification(id: item.id!, token: token);
      } catch (e) {
        print("Error deleting ${item.id}: $e");
      }
    }
  }

  void _filterNotifications() {
    todayList.clear();
    weekList.clear();
    earlierList.clear();

    final now = DateTime.now();
    for (var note in allNotifications) {
      if (note.createdAt == null) continue;
      DateTime date = DateTime.parse(note.createdAt!).toLocal();

      final difference = now.difference(date).inDays;

      if (difference == 0 && date.day == now.day) {
        todayList.add(note);
      } else if (difference < 7) {
        weekList.add(note);
      } else {
        earlierList.add(note);
      }
    }
  }

  Future<void> markAsRead(String id) async {
    int index = allNotifications.indexWhere((element) => element.id == id);
    if (index != -1) {
      allNotifications[index].isRead = true;
      _filterNotifications();
      notifyListeners();
    }

    try {
      String token = CacheHelper.getData(key: 'token');
      await NotificationRepo.markAsRead(id: id, token: token);
    } catch (e) {
      print("Error marking as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    var unreadList = allNotifications.where((n) => n.isRead == false).toList();

    if (unreadList.isEmpty) return;

    for (var note in allNotifications) {
      note.isRead = true;
    }
    _filterNotifications();
    notifyListeners();

    String token = CacheHelper.getData(key: 'token');
    for (var note in unreadList) {
      try {
        NotificationRepo.markAsRead(id: note.id!, token: token);
      } catch (e) {
        print(e);
      }
    }
  }
}
