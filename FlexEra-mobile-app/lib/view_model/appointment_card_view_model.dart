import 'package:flutter/material.dart';
import '../../core/network/cache_helper.dart';
import '../../core/network/dio_helper.dart';
import '../../core/network/end_points.dart';

class AppointmentCardViewModel extends ChangeNotifier {
  String doctorName = 'Loading...';
  String jobTitle = '';
  String dateDisplay = '';
  String timeDisplay = '';
  String doctorImage = '';

  List<dynamic> upcomingAppointments = [];
  List<dynamic> pastAppointments = [];

  bool hasAppointment = false;
  bool isLoadingHistory = false;

  AppointmentCardViewModel() {
    getAppointmentSummary();
  }

  Future<void> getAppointmentSummary() async {
    _loadFromCache();
    isLoadingHistory = true;
    notifyListeners();

    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.getData(
        url: EndPoints.authSummary,
        token: token,
      );

      if (response.data['success'] == true) {
        List<dynamic> allApts = response.data['appointments'] ?? [];

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);

        upcomingAppointments = allApts.where((apt) {
          DateTime aptDate = DateTime.parse(apt['date']);
          return aptDate.isAfter(today) || _isSameDay(aptDate, today);
        }).toList();

        pastAppointments = allApts.where((apt) {
          DateTime aptDate = DateTime.parse(apt['date']);
          return aptDate.isBefore(today) && !_isSameDay(aptDate, today);
        }).toList();

        if (upcomingAppointments.isNotEmpty) {
          upcomingAppointments.sort(
            (a, b) =>
                DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
          );

          final nextApt = upcomingAppointments.first;
          _updateCardData(nextApt);
          hasAppointment = true;

          _saveToCache();
        } else {
          hasAppointment = false;
          CacheHelper.saveData(key: 'summary_has_apt', value: false);
        }
      } else {
        hasAppointment = false;
        CacheHelper.saveData(key: 'summary_has_apt', value: false);
      }
    } catch (e) {
      debugPrint('Error fetching summary: $e');
    } finally {
      isLoadingHistory = false;
      notifyListeners();
    }
  }

  void _updateCardData(dynamic apt) {
    final doctor = apt['doctor'] ?? {};
    doctorName = doctor['name'] ?? 'Unknown Doctor';
    jobTitle = 'Physiotherapy Session';
    doctorImage = doctor['image'] ?? '';
    timeDisplay = apt['time'] ?? '';
    dateDisplay = _formatDate(apt['date']);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _saveToCache() {
    CacheHelper.saveData(key: 'summary_docName', value: doctorName);
    CacheHelper.saveData(key: 'summary_docImage', value: doctorImage);
    CacheHelper.saveData(key: 'summary_time', value: timeDisplay);
    CacheHelper.saveData(key: 'summary_date', value: dateDisplay);
    CacheHelper.saveData(key: 'summary_has_apt', value: true);
  }

  void _loadFromCache() {
    hasAppointment = CacheHelper.getData(key: 'summary_has_apt') ?? false;
    if (hasAppointment) {
      doctorName = CacheHelper.getData(key: 'summary_docName') ?? '';
      doctorImage = CacheHelper.getData(key: 'summary_docImage') ?? '';
      timeDisplay = CacheHelper.getData(key: 'summary_time') ?? '';
      dateDisplay = CacheHelper.getData(key: 'summary_date') ?? '';
      notifyListeners();
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      String dayName = days[date.weekday - 1];
      String monthName = months[date.month - 1];

      return '$dayName, $monthName ${date.day}';
    } catch (e) {
      return dateStr;
    }
  }
}
