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
  bool hasAppointment = false;

  AppointmentCardViewModel() {
    getAppointmentSummary();
  }

  Future<void> getAppointmentSummary() async {
    _loadFromCache();

    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.getData(
        url: EndPoints.authSummary,
        token: token,
      );

      if (response.data['success'] == true &&
          response.data['appointment'] != null) {
        final appointment = response.data['appointment'];
        final doctor = appointment['doctor'];

        doctorName = doctor['name'] ?? 'Unknown Doctor';

        jobTitle = 'Specialist';

        doctorImage = doctor['image'] ?? '';

        timeDisplay = appointment['time'] ?? '';
        dateDisplay = _formatDate(appointment['date']);

        hasAppointment = true;

        CacheHelper.saveData(key: 'summary_docName', value: doctorName);
        CacheHelper.saveData(key: 'summary_docImage', value: doctorImage);
        CacheHelper.saveData(key: 'summary_time', value: timeDisplay);
        CacheHelper.saveData(key: 'summary_date', value: dateDisplay);
        CacheHelper.saveData(key: 'summary_has_apt', value: true);

        notifyListeners();
      } else {
        hasAppointment = false;
        CacheHelper.saveData(key: 'summary_has_apt', value: false);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching summary: $e');
    }
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
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2]);

        final date = DateTime(year, month, day);

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
          'Dec'
        ];

        String dayName = days[date.weekday - 1];
        String monthName = months[date.month - 1];

        return '$dayName, $monthName $day';
      }
    } catch (e) {
      return dateStr;
    }
    return dateStr;
  }
}
